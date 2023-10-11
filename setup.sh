#! /bin/bash
set -x

# Function to check if a command exists
command_exists () {
    type "$1" &> /dev/null ;
}

# Copy custom configs
cp ./vimrc $HOME/.vimrc
cp ./zshrc $HOME/.zshrc

OS_TYPE=$(uname -s)

# Mac Install
if [ "$OS_TYPE" == "Darwin" ]; then
    # Install brew packages only if they don't exist
    for pkg in zsh neovim curl bat zoxide nodejs exa tldr; do
        if ! command_exists $pkg ; then
            brew install $pkg
        fi
    done

    # Install Miniconda if it doesn't exist
    if [ ! -d "$HOME/.miniconda" ]; then
        mkdir -p ~/.miniconda
        curl https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh -o ~/.miniconda/miniconda.sh
        bash ~/.miniconda/miniconda.sh -b -u -p ~/.miniconda
        rm -rf ~/.miniconda/miniconda.sh
    fi
fi

# Linux Install
if [ "$OS_TYPE" == "Linux" ]; then
    # For Ubuntu 22.04, use Nala instead of apt for certain packages
    if [ "$(lsb_release -rs)" == "22.04" ]; then
        for pkg in bat zoxide exa; do
            if ! command_exists $pkg ; then
                sudo nala install $pkg -y
            fi
        done
    else
        for pkg in zsh neovim tldr bat nodejs; do
            if ! command_exists $pkg ; then
                sudo apt install -y $pkg
            fi
        done
    fi

    # Install Miniconda if it doesn't exist
    if [ ! -d "$HOME/.miniconda" ]; then
        mkdir -p ~/.miniconda
        wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/.miniconda/miniconda.sh
        bash ~/.miniconda/miniconda.sh -b -u -p ~/.miniconda
        rm -rf ~/.miniconda/miniconda.sh
    fi
fi

# Initialize Miniconda if it hasn't been initialized
if [ ! -f "$HOME/.zshrc" ] || ! grep -q 'conda initialize' "$HOME/.zshrc"; then
    ~/.miniconda/bin/conda init zsh
fi


if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# oh-my-zsh and plugins
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

# Install other global utilities if they don't exist
for pkg in pnpm fzf; do
    if ! command_exists $pkg ; then
        if [ "$pkg" == "pnpm" ]; then
            curl -fsSL https://get.pnpm.io/install.sh | sh -
        elif [ "$pkg" == "fzf" ]; then
            if [ ! -d "$HOME/.fzf" ]; then
                git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
                ~/.fzf/install
            fi
        fi
    fi
done

# Additional custom configurations
mkdir -p $HOME/.config/nvim
cp ./init.vim $HOME/.config/nvim/init.vim
mkdir -p $HOME/.local/bin
cp ./tailc $HOME/.local/bin/tailc

# Set up Git config
git config --global user.email "stathiskap75@gmail.com"
git config --global user.name "StathisKap"



echo "Done!"
exec zsh

