#! /bin/bash
cp ./vimrc $HOME/.vimrc
cp ./zshrc $HOME/.zshrc
cp -r ./config $HOME/.config

sudo apt update
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - &&\
sudo apt install nala -y
sudo nala install zsh neovim curl bat zoxide nodejs exa tldr -y
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install