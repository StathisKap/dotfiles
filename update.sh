#!/bin/bash

# Help message function
show_help() {
    echo "Usage: ./update.sh [OPTIONS]"
    echo "Update dotfiles repository with changes from home directory"
    echo ""
    echo "Options:"
    echo "  -n, --dry-run    Run in dry-run mode (show what would be updated without making changes)"
    echo "  -v, --verbose    Show diffs when changes are detected"
    echo "  -h, --help       Show this help message"
    echo ""
    echo "Example:"
    echo "  ./update.sh       # Normal update"
    echo "  ./update.sh -n    # Dry run to see what would be updated"
    echo "  ./update.sh -v    # Update and show diffs"
    echo "  ./update.sh -nv   # Dry run with diffs"
}

# Parse command line arguments
DRY_RUN=0
VERBOSE=0
while getopts "nvh" opt; do
    case $opt in
        n) DRY_RUN=1 ;;
        v) VERBOSE=1 ;;
        h) show_help; exit 0 ;;
        \?) show_help; exit 1 ;;
    esac
done

# Function to handle dry-run mode
run_command() {
    if [ "$DRY_RUN" -eq 1 ]; then
        echo "[DRY RUN] Would execute: $*"
        return
    fi
    "$@"
}

set -e  # Exit on error
trap 'echo "Error occurred. Exiting..." >&2' ERR

# Function to compute hash of a file
file_hash() {
    local file="$1"
    if [ -f "$file" ]; then
        if command -v md5sum &> /dev/null; then
            md5sum "$file" | cut -d' ' -f1
        elif command -v md5 &> /dev/null; then
            md5 -q "$file"
        else
            echo "ERROR: No hash command available" >&2
            return 1
        fi
    fi
}

# Function to compute hash of a directory (recursive)
dir_hash() {
    local dir="$1"
    if [ -d "$dir" ]; then
        if command -v md5sum &> /dev/null; then
            find "$dir" -type f -not -path "*/.git/*" -exec md5sum {} \; | sort -k 2 | md5sum | cut -d' ' -f1
        elif command -v md5 &> /dev/null; then
            find "$dir" -type f -not -path "*/.git/*" -exec md5 -q {} \; | sort | md5 -q
        else
            echo "ERROR: No hash command available" >&2
            return 1
        fi
    fi
}

# Function to sync directory from home to dotfiles
sync_directory() {
    local src="$1"
    local dest="$2"

    # Skip if source doesn't exist
    if [ ! -d "$src" ]; then
        return
    fi

    # If dest doesn't exist but source does, create it
    if [ ! -d "$dest" ]; then
        echo "New directory found: $dest (from $src)"
        if [ "$DRY_RUN" -eq 0 ]; then
            run_command mkdir -p "$dest"
            run_command rsync -a --exclude='.git*' --exclude='pack/' --exclude='undodir/' --exclude='*.swp' --exclude='*.swo' "$src/" "$dest/"
        fi
        return
    fi

    # Compare directory hashes
    local src_hash=$(dir_hash "$src")
    local dest_hash=$(dir_hash "$dest")

    if [ "$src_hash" != "$dest_hash" ]; then
        echo "Updating directory: $dest (from $src)"

        if [ "$VERBOSE" -eq 1 ]; then
            echo ""
            echo "=== Diff for $dest ==="
            diff -ru --exclude='.git*' --exclude='pack' --exclude='undodir' "$dest" "$src" 2>/dev/null || true
            echo "=== End diff ==="
            echo ""
        fi

        if [ "$DRY_RUN" -eq 1 ]; then
            echo "[DRY RUN] Would sync $src -> $dest"
        else
            run_command rsync -a --delete --exclude='.git*' --exclude='pack/' --exclude='undodir/' --exclude='*.swp' --exclude='*.swo' "$src/" "$dest/"
        fi
    fi
}

# Function to sync file from home to dotfiles
sync_file() {
    local src="$1"
    local dest="$2"

    # Skip if source doesn't exist
    if [ ! -f "$src" ]; then
        return
    fi

    # If dest doesn't exist, copy it
    if [ ! -f "$dest" ]; then
        echo "New file found: $dest (from $src)"
        run_command cp "$src" "$dest"
        return
    fi

    # Compare hashes
    local src_hash=$(file_hash "$src")
    local dest_hash=$(file_hash "$dest")

    if [ "$src_hash" != "$dest_hash" ]; then
        echo "Updating file: $dest (from $src)"

        if [ "$VERBOSE" -eq 1 ]; then
            echo ""
            echo "=== Diff for $dest ==="
            diff -u "$dest" "$src" 2>/dev/null || true
            echo "=== End diff ==="
            echo ""
        fi

        run_command cp "$src" "$dest"
    fi
}

echo "Checking for updates from home directory to dotfiles..."
echo ""

# Sync config directories
sync_directory "$HOME/.config/nvim" "./nvim"
sync_directory "$HOME/.vim" "./vim"
sync_directory "$HOME/.tmux" "./tmux"
sync_directory "$HOME/.zsh" "./zsh"

# Sync individual config files only if their directory counterparts don't exist
# This avoids duplication (e.g., don't sync ./init.vim if ./nvim/ already exists)
if [ ! -d "./nvim" ]; then
    sync_file "$HOME/.config/nvim/init.vim" "./init.vim"
fi

if [ ! -d "./vim" ]; then
    sync_file "$HOME/.vimrc" "./vimrc"
fi

if [ ! -d "./zsh" ]; then
    sync_file "$HOME/.zshrc" "./zshrc"
fi

if [ ! -d "./tmux" ]; then
    sync_file "$HOME/.tmux.conf" "./tmux.conf"
fi

# Sync local bin scripts
sync_file "$HOME/.local/bin/tailc" "./tailc"
sync_file "$HOME/.local/bin/yqli" "./yqli"

echo ""
echo "Update complete!"

if [ "$DRY_RUN" -eq 0 ]; then
    echo ""
    echo "Don't forget to commit and push your changes:"
    echo "  git add -A"
    echo "  git commit -m 'Update dotfiles'"
    echo "  git push"
fi
