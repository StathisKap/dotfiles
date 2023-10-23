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
    if [ ! -d "$HOME/miniconda3" ]; then
        mkdir -p ~/.miniconda3
        curl https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh -o ~/.miniconda3/miniconda.sh
        bash ~/.miniconda3/miniconda.sh -b -u -p ~/miniconda3
        rm -rf ~/.miniconda3/miniconda.sh
    fi
fi


# Linux Install
if [ "$OS_TYPE" == "Linux" ]; then
    # For Ubuntu 22.04, use Nala instead of apt for certain packages
    apt-get update
    apt-get install nala -y
    nala upgrade -y
    if [ "$(lsb_release -rs)" == "22.04" ]; then
        for pkg in bat zoxide exa zsh neovim nodejs tldr; do
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
    if [ ! -d "$HOME/miniconda3" ]; then
        mkdir -p ~/.miniconda3
        wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/.miniconda3/miniconda.sh
        bash ~/.miniconda3/miniconda.sh -b -u -p ~/miniconda3
        rm -rf ~/.miniconda3/miniconda.sh
    fi
fi

# Initialize Miniconda if it hasn't been initialized
if [ ! -f "$HOME/.zshrc" ] || ! grep -q 'conda initialize' "$HOME/.zshrc"; then
    ~/.miniconda3/bin/conda init zsh
fi

# Install other global utilities if they don't exist
for pkg in pnpm fzf; do
    if ! command_exists $pkg ; then
        if [ "$pkg" == "pnpm" ]; then
            curl -fsSL https://get.pnpm.io/install.sh | sh -
        elif [ "$pkg" == "fzf" ]; then
            git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
            ~/.fzf/install
        fi
    fi
done

# Install vim-plug for Neovim if it doesn't exist
if [ ! -f "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim" ]; then
    sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
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

# Additional custom configurations
rm $HOME/.zshrc
cp ./zshrc $HOME/.zshrc
mkdir -p $HOME/.config/nvim
rm $HOME/.config/nvim/init.vim
cp ./init.vim $HOME/.config/nvim/init.vim
mkdir -p $HOME/.local/bin
rm $HOME/.local/bin/tailc
cp ./tailc $HOME/.local/bin/tailc

git config --global user.email "stathiskap75@gmail.com"
git config --global user.name "StathisKap"

echo "Done!"
exec zsh
