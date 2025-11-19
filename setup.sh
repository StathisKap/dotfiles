#! /bin/bash

# Help message function
show_help() {
    echo "Usage: ./setup.sh [OPTIONS]"
    echo "Set up development environment with dotfiles and required tools"
    echo ""
    echo "Options:"
    echo "  -n, --dry-run    Run in dry-run mode (show what would be done without making changes)"
    echo "  -h, --help       Show this help message"
    echo ""
    echo "Example:"
    echo "  ./setup.sh       # Normal installation"
    echo "  ./setup.sh -n    # Dry run to see what would be installed"
}

# Parse command line arguments
DRY_RUN=0
while getopts "nh" opt; do
    case $opt in
        n) DRY_RUN=1 ;;
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

# Only enable debug output when not in dry-run mode
[ "$DRY_RUN" -eq 0 ] && set -x
set -e  # Exit on error
trap 'echo "Error occurred. Exiting..." >&2' ERR

# Function to check if a command exists
command_exists () {
    type "$1" &> /dev/null
}

# Function to check if a brew package is installed
brew_package_exists() {
    brew list --formula "$1" &> /dev/null
}

# Function to backup file or directory with timestamp
backup_if_exists() {
    local target="$1"
    if [ -e "$target" ]; then
        local timestamp=$(date +%Y-%m-%d-%H-%M)
        local backup_path="${target}.${timestamp}.bak"
        echo "Backing up existing $target to $backup_path"
        run_command mv "$target" "$backup_path"
    fi
}

# Function to install Mac packages
install_mac_packages() {
    [ "$OS_TYPE" != "Darwin" ] && return

    command_exists brew || {
        echo "Installing Homebrew..."
        run_command /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    }

    for pkg in zsh neovim curl bat zoxide nodejs eza tldr ctags awscli yq; do
        if command_exists $pkg; then
            continue
        fi
        brew_package_exists $pkg || run_command brew install $pkg
    done

    # Install bun
    command_exists bun || {
        echo "Installing Bun..."
        run_command curl -fsSL https://bun.sh/install | bash
    }

    # Install kubectl
    if ! command_exists kubectl; then
        brew_package_exists kubectl || {
            echo "Installing kubectl..."
            run_command brew install kubectl
        }
    fi
}

# Function to install Linux packages
install_linux_packages() {
    [ "$OS_TYPE" != "Linux" ] && return

    run_command apt-get update
    run_command apt-get install nala -y
    run_command nala upgrade -y

    [ "$(lsb_release -rs)" != "22.04" ] && {
        for pkg in zsh neovim tldr bat nodejs ctags; do
            command_exists $pkg || run_command sudo apt install -y $pkg
        done
        return
    }

    for pkg in bat zoxide eza zsh neovim nodejs tldr ctags; do
        command_exists $pkg || run_command sudo nala install $pkg -y
    done

    # Install bun
    command_exists bun || {
        echo "Installing Bun..."
        run_command curl -fsSL https://bun.sh/install | bash
    }

    # Install kubectl
    command_exists kubectl || {
        echo "Installing kubectl..."
        run_command curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
        echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
        run_command sudo apt-get update
        run_command sudo apt-get install -y kubectl
    }

    # Install AWS CLI
    command_exists aws || {
        echo "Installing AWS CLI..."
        run_command curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        run_command unzip awscliv2.zip
        run_command sudo ./aws/install
        run_command rm -rf aws awscliv2.zip
    }

    # Install yq
    command_exists yq || {
        echo "Installing yq..."
        run_command sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
        run_command sudo chmod a+x /usr/local/bin/yq
    }
}

# Function to install Miniconda
install_miniconda() {
    # Check if conda is already installed
    if command_exists conda || [ -d "$HOME/miniconda3" ]; then
        echo "Miniconda is already installed, skipping..."
        return
    fi

    backup_if_exists "$HOME/miniconda3"
    backup_if_exists "$HOME/.miniconda3"

    run_command mkdir -p ~/.miniconda3
    if [ "$OS_TYPE" == "Darwin" ]; then
        run_command curl https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh -o ~/.miniconda3/miniconda.sh
    else
        run_command wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/.miniconda3/miniconda.sh
    fi
    run_command bash ~/.miniconda3/miniconda.sh -b -u -p ~/miniconda3
    run_command rm -rf ~/.miniconda3/miniconda.sh
}

# Function to install global utilities
install_global_utils() {
    for pkg in pnpm fzf; do
        command_exists $pkg && continue

        [ "$pkg" == "pnpm" ] && {
            run_command curl -fsSL https://get.pnpm.io/install.sh | sh -
            continue
        }

        [ "$pkg" == "fzf" ] && {
            backup_if_exists "$HOME/.fzf"
            run_command git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
            run_command ~/.fzf/install
        }
    done
}

# Function to install vim plugins
install_vim_plugins() {
    [ -f "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim" ] && return

    run_command sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
}

# Function to install oh-my-zsh and plugins
install_oh_my_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        backup_if_exists "$HOME/.oh-my-zsh"
        run_command sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi

    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
        run_command git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    fi

    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
        run_command git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    fi
}

# Function to copy config files
copy_config_files() {
    # Check if nvim directory exists (not init.vim specifically)
    if [ -d "./nvim" ]; then
        backup_if_exists "$HOME/.config/nvim"
        run_command mkdir -p $HOME/.config
        run_command cp -r ./nvim $HOME/.config/nvim
    fi

    # Handle old-style init.vim if it exists
    if [ -f "./init.vim" ]; then
        backup_if_exists "$HOME/.config/nvim/init.vim"
        run_command mkdir -p $HOME/.config/nvim
        run_command cp ./init.vim $HOME/.config/nvim/init.vim
    fi

    # Handle vim directory if it exists
    if [ -d "./vim" ]; then
        backup_if_exists "$HOME/.vim"
        run_command cp -r ./vim $HOME/.vim
    fi

    # Handle individual config files
    if [ -f "./vimrc" ]; then
        backup_if_exists "$HOME/.vimrc"
        run_command cp ./vimrc $HOME/.vimrc
    fi

    if [ -f "./zshrc" ]; then
        backup_if_exists "$HOME/.zshrc"
        run_command cp ./zshrc $HOME/.zshrc
    fi

    if [ -f "./tmux.conf" ]; then
        backup_if_exists "$HOME/.tmux.conf"
        run_command cp ./tmux.conf $HOME/.tmux.conf
    fi

    # Handle tmux directory if it exists
    if [ -d "./tmux" ]; then
        backup_if_exists "$HOME/.tmux"
        run_command cp -r ./tmux $HOME/.tmux
    fi

    # Handle zsh directory if it exists
    if [ -d "./zsh" ]; then
        backup_if_exists "$HOME/.zsh"
        run_command cp -r ./zsh $HOME/.zsh
    fi

    # Handle local bin scripts
    run_command mkdir -p $HOME/.local/bin

    if [ -f "./tailc" ]; then
        backup_if_exists "$HOME/.local/bin/tailc"
        run_command cp ./tailc $HOME/.local/bin/tailc
    fi

    if [ -f "./yqli" ]; then
        backup_if_exists "$HOME/.local/bin/yqli"
        run_command cp ./yqli $HOME/.local/bin/yqli
    fi
}

# Main script
OS_TYPE=$(uname -s)
export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTEND=none

# Install packages based on OS
install_mac_packages
install_linux_packages

# Install Miniconda and initialize it
install_miniconda
if [ ! -f "$HOME/.zshrc" ] || ! grep -q 'conda initialize' "$HOME/.zshrc" 2>/dev/null; then
    run_command ~/miniconda3/bin/conda init zsh
fi

# Install global utilities and plugins
install_global_utils
install_vim_plugins
install_oh_my_zsh

# Configure git
run_command git config --global user.email "stathiskap75@gmail.com"
run_command git config --global user.name "StathisKap"

# Copy config files last to prevent overwrites
copy_config_files

echo "Done!"
[ "$DRY_RUN" -eq 0 ] && exec zsh
