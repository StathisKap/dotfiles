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

# Mac Install
if [ "$OS_TYPE" == "Darwin" ]; then
	sudo brew install zsh neovim curl bat zoxide nodejs exa tldr
fi

# Linux Install
if [ "$OS_TYPE" == "Linux" ]; then
	# Install NodeJS
	sudo apt-get update
	sudo apt-get install -y ca-certificates curl gnupg
	sudo mkdir -p /etc/apt/keyrings
	curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
	NODE_MAJOR=20
	echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
fi


# Linux Install 22.04
if ([ "$OS_TYPE" == "Linux" ] && [ "$(lsb_release -rs)" == "22.04" ]); then
	sudo apt update && sudo apt upgrade -y
	sudo apt install nala -y
	sudo nala install zsh neovim curl bat zoxide nodejs exa tldr -y
fi

# Linux Install 20.04
if ([ "$OS_TYPE" == "Linux" ] && [ "$(lsb_release -rs)" != "22.04" ]); then
	sudo apt update && sudo apt upgrade -y
	sudo apt install zsh neovim curl bat nodejs tldr -y
fi

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

. ~/.zshrc && echo "Done!"
