# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="jonathan"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

#### User configuration ####

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nvim'
else
  export EDITOR='vim'
fi

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.

### Common Configuration ###

## Aliases ##

alias dev='pnpm run dev'
alias build='pnpm run build'
alias deploy='pnpm run build && pnpm dlx wrangler pages deploy .svelte-kit/cloudflare'

# Colorised ls
alias ls='ls -G --color'
alias ll='ls -lG --color'

# Customised cat
alias cat='bat'

## Exports ##

# TLDR colors
export TLDR_COLOR_NAME="cyan"
export TLDR_COLOR_DESCRIPTION="white"
export TLDR_COLOR_EXAMPLE="green"
export TLDR_COLOR_COMMAND="red"
export TLDR_COLOR_PARAMETER="white"
export TLDR_LANGUAGE="en"
export TLDR_CACHE_ENABLED=1
export TLDR_CACHE_MAX_AGE=720
export TLDR_PAGES_SOURCE_LOCATION="https://raw.githubusercontent.com/tldr-pages/tldr/master/pages"
export TLDR_DOWNLOAD_CACHE_LOCATION="https://tldr-pages.github.io/assets/tldr.zip"

# .local/bin
export PATH="$HOME/.local/bin/:$PATH"

# create
export PATH="$HOME/.local/create/:$PATH"


# Identify the operating system
OS_TYPE=$(uname -s)

# Configurations for MacOS ONLY
if [[ "$OS_TYPE" == "Darwin" ]]; then
    # Configurations specific ONLY to MacOS
    # HomeBrew
    export PATH="/opt/homebrew/bin:$PATH"

    # Python pip3
    export PATH="$HOME/Library/Python/3.8/bin:$PATH"

    # ctags
    alias ctags=/opt/homebrew/bin/ctags
    export PATH="/opt/homebrew/sbin:$PATH"


    # IP brief command
    ip() {
        if [[ "$1" == "-brief" && ("$2" == "a" || "$2" == "addr" || "$2" == "address" || "$2" == "addr show") ]]; then
            netstat -i -f inet | awk 'NR>1 {print $1 " up " $4}'
        else
            command ip "$@"
        fi
    }
    :
fi


# Configurations for BOTH MacOS and Ubuntu 22.04
if [[ "$OS_TYPE" == "Darwin" ]] || ( [[ "$OS_TYPE" == "Linux" ]] && [[ "$(lsb_release -rs)" == "22.04" ]] ); then
    # Configurations for both MacOS and Ubuntu 22.04
    # Colorised tree
    alias tree='exa --tree'

    # Zoxide to cd
    eval "$(zoxide init zsh)"
    alias cd='z'
    :
fi

# Configurations for all other cases
if [[ "$OS_TYPE" != "Darwin" ]] && ( [[ "$OS_TYPE" != "Linux" ]] || [[ "$(lsb_release -rs)" != "22.04" ]] ); then
    # Configurations for all other OS types and versions
    :
fi


############################################################
#### ALL INSTALLATIONS BELOW THIS LINE ARE AUTOMATICALLY ###
#### HANDLED BY THE INSTALLATION SCRIPTS. DO NOT MODIFY. ###
############################################################


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('$HOME/.miniforge/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOME/.miniforge/etc/profile.d/conda.sh" ]; then
        . "$HOME/.miniforge/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/.miniforge/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


# pnpm
export PNPM_HOME="/Users/stathis/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Fuzzy search (command history etc)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


