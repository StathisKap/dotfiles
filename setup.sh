#! /bin/bash
sudo apt install zsh neovim curl bat zoxide -y --ignore-missing
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
cp ./vimrc $HOME/.vimrc
cp ./zshrc $HOME/.zshrc
cp ./config $HOME/.config
