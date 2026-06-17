# dotfiles

Managed with [yadm](https://yadm.io). Files are tracked at their real `$HOME` paths — `yadm clone` drops them straight into place and runs the bootstrap.

## New machine

```bash
brew install yadm   # or: apt install yadm
yadm clone git@github.com:StathisKap/dotfiles.git
```

`yadm clone` checks out into `$HOME` and runs `~/.config/yadm/bootstrap`, which installs Homebrew/apt packages, oh-my-zsh, fzf, miniconda, vim-plug, and a few CLIs (`bun`, `kubectl`, `aws`, `yq`).

Re-run later with:

```bash
yadm bootstrap
```

## Day-to-day

```bash
yadm status
yadm diff
yadm add ~/.zshrc
yadm commit -m "tweak zshrc"
yadm push
```

Every git command works — just swap `git` for `yadm`.

## What's tracked

- `~/.zshrc`, `~/.vimrc`, `~/.tmux.conf`
- `~/.vim/vimrc`
- `~/.config/nvim/` (init.lua, coc-settings, snippets)
- `~/.local/bin/tailc`, `~/.local/bin/yqli`
- `~/.config/yadm/bootstrap`

This `README.md` is **not** tracked by yadm (it would otherwise land in `$HOME`). It's committed to the repo directly via regular `git` from a separate clone.

## SSH push setup

The remote uses an SSH host alias so the right key is picked up. In `~/.ssh/config`:

```ssh-config
Host stathiskap
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_stathis_personal
  IdentitiesOnly yes
```

Remote URL: `git@stathiskap:StathisKap/dotfiles.git`
