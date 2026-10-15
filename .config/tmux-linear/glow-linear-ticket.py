#!/usr/bin/env python3
"""Run Glow unchanged, intercepting only the `o` key to open a Linear issue."""

import os
import pty
import fcntl
import select
import signal
import struct
import subprocess
import sys
import termios
import tty
from pathlib import Path


def main() -> int:
    if len(sys.argv) != 3:
        print(f"usage: {sys.argv[0]} LINEAR_URL MARKDOWN_FILE", file=sys.stderr)
        return 2

    ticket_url, markdown_file = sys.argv[1:]
    opener = Path.home() / ".config" / "tmux-linear" / "open-linear-ticket.sh"

    def read_keyboard(fd: int) -> bytes:
        data = os.read(fd, 1024)
        if b"o" not in data:
            return data

        for _ in range(data.count(b"o")):
            subprocess.Popen(
                [str(opener), ticket_url],
                stdin=subprocess.DEVNULL,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                start_new_session=True,
            )
        return data.replace(b"o", b"")

    child_pid, master_fd = pty.fork()
    if child_pid == 0:
        os.execvp("glow", ["glow", "-p", markdown_file])

    stdin_fd = sys.stdin.fileno()
    stdout_fd = sys.stdout.fileno()
    terminal_rows = 1
    legend_dirty = True

    def draw_legend() -> None:
        legend = b"  \033[1mo\033[22m open in Linear  \xc2\xb7  \033[1mq\033[22m quit"
        os.write(
            stdout_fd,
            b"\0337"
            + f"\033[{terminal_rows};1H".encode()
            + b"\033[2K\033[2m"
            + legend
            + b"\033[0m\0338",
        )

    def resize(_signum: int | None = None, _frame: object = None) -> None:
        nonlocal legend_dirty, terminal_rows
        try:
            size = fcntl.ioctl(stdin_fd, termios.TIOCGWINSZ, b"\0" * 8)
            rows, columns, x_pixels, y_pixels = struct.unpack("HHHH", size)
            terminal_rows = max(rows, 1)
            child_size = struct.pack(
                "HHHH", max(rows - 1, 1), columns, x_pixels, y_pixels
            )
            fcntl.ioctl(master_fd, termios.TIOCSWINSZ, child_size)
            os.kill(child_pid, signal.SIGWINCH)
            legend_dirty = True
        except OSError:
            pass

    resize()
    previous_winch = signal.signal(signal.SIGWINCH, resize)
    previous_mode = termios.tcgetattr(stdin_fd)
    tty.setraw(stdin_fd)
    draw_legend()
    legend_dirty = False

    try:
        while True:
            readable, _, _ = select.select([stdin_fd, master_fd], [], [], 0.02)
            if not readable and legend_dirty:
                draw_legend()
                legend_dirty = False
                continue
            if stdin_fd in readable:
                keyboard_data = read_keyboard(stdin_fd)
                if keyboard_data:
                    os.write(master_fd, keyboard_data)
            if master_fd in readable:
                try:
                    output = os.read(master_fd, 4096)
                except OSError:
                    break
                if not output:
                    break
                os.write(stdout_fd, output)
                legend_dirty = True
    finally:
        termios.tcsetattr(stdin_fd, termios.TCSAFLUSH, previous_mode)
        signal.signal(signal.SIGWINCH, previous_winch)
        os.close(master_fd)

    _, status = os.waitpid(child_pid, 0)
    return os.waitstatus_to_exitcode(status)


if __name__ == "__main__":
    raise SystemExit(main())
