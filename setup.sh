#! /bin/bash
sudo apt-get install nala
sudo nala install zsh neovim curl bat zoxide -y
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
cp ./vimrc $HOME/.vimrc
cp ./zshrc $HOME/.zshrc
cp ./config $HOME/.config
