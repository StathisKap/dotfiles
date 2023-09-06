#! /bin/bash
set -x

# Copy custom configs
cp ./vimrc $HOME/.vimrc
cp ./zshrc $HOME/.zshrc

OS_TYPE=$(uname -s)

if [ "$OS_TYPE" == "Darwin" ]; then
	sudo brew install zsh neovim curl bat zoxide nodejs exa tldr
fi

OS_TYPE=$(uname -s)

if [ "$OS_TYPE" == "Darwin" ]; then
	sudo brew install zsh neovim curl bat zoxide nodejs exa tldr
fi


if ([ "$OS_TYPE" == "Linux" ] && [ "$(lsb_release -rs)" == "22.04" ]); then
	sudo apt update && sudo apt upgrade -y
	sudo apt install nala -y
	sudo nala install zsh neovim curl bat zoxide nodejs exa tldr -y
fi

if ([ "$OS_TYPE" == "Linux" ] && [ "$(lsb_release -rs)" != "22.04" ]); then
	sudo apt update && sudo apt upgrade -y
	sudo apt install zsh neovim curl bat nodejs tldr -y
fi

# Latest Node
# curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - &&\

# PNPM Install
curl -fsSL https://get.pnpm.io/install.sh | sh -

# vim-plug Install
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

# Custom init.vim
mkdir -p $HOME/.config/nvim
cp ./init.vim $HOME/.config/nvim/init.vim

# oh-my-zsh Install
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# zsh-syntax-highlighting Install
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# fzf Install
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# Custom tmux
cd
git clone https://github.com/gpakosz/.tmux.git
ln -s -f .tmux/.tmux.conf
cp .tmux/.tmux.conf.local .
