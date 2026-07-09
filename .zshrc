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
plugins=(
    git
    zsh-syntax-highlighting
    zsh-autosuggestions
    1password
    aliases
    argocd
    gh
    helm
)

source $ZSH/oh-my-zsh.sh

#### Load in Private Env variables if the file exists ####
[[ -f ~/.private_env ]] && source ~/.private_env

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

# Edit .zsrhc
alias zshrc='nvim ~/.zshrc'

# Pnpm
alias dev='pnpm run dev'
alias build='pnpm run build'
alias preview='pnpm run preview'
alias deploy='pnpm run build && pnpm dlx wrangler pages deploy .svelte-kit/cloudflare'

# Bun
alias start='bun run start'

# Colorised ls
alias ls='ls -G --color -t'
alias ll='ls -lG --color -t'

# Mosh no init
alias mosh='mosh --no-init'

# Git
alias gcau='git add . && git commit -v -a -m'

# Kubernetes
alias k="kubectl"
alias pods="kubectl get pods"
alias nodes="kubectl get nodes"
alias svc="kubectl get svc"
alias all="kubectl get all"
alias events="kubectl get events --sort-by=.metadata.creationTimestamp"
alias apply="kubectl apply -f"
alias kx="kubectx"
alias kns="kubens"
alias token="cat ~/Code/MLX/mlx/setup/dashboard/stathis-admin.txt -p | pbcopy"
alias describe='kubectl describe'

# Terraform
#alias tfcheck='terraform validate'
alias tf='terraform'

# Neovim
alias n='nvim'

# CSVlens
alias csvlens='csvlens --color-columns'

# Fuck
alias fk='fuck'

# ArgoCD
alias argocd='argocd --grpc-web'

# Functions
## Copy the contents of a file
copy() {
  /bin/cat "$1" | pbcopy
}

pcopy() {
  realpath "$1" | pbcopy
}

## Add module to requirements.txt
add(){
    echo '$1\n'>> requirements.txt; bat requirements.txt;
}

## Adding Syntx Highlighting on man pages ##
man() {
	LESS_TERMCAP_md=$'\e[01;31m'  \
	LESS_TERMCAP_me=$'\e[0m'      \
	LESS_TERMCAP_us=$'\e[01;32m'  \
	LESS_TERMCAP_ue=$'\e[0m'      \
	LESS_TERMCAP_so=$'\e[45;93m'  \
	LESS_TERMCAP_se=$'\e[0m'      \
	command man "$@"
}

## Check MLX-CRA github actions
function ghac() {
    if [ $# -lt 1 ]; then
        echo "Usage: ghac <owner/repo>"
        echo "Example: ghac StathisKap/dotfiles"
        return 1
    fi
    local owner_repo="$1" # Expecting 'owner/repo' format

    json=$(curl -s -H "Authorization: token ${GH_TOKEN}" "https://api.github.com/repos/$owner_repo/actions/runs?per_page=1")

    echo $json | yq '.workflow_runs[0] | (.status, .conclusion, .run_started_at, .html_url)'
}

## Fold Text
function fold_text() {
    pbpaste | fold -w $1 -s | awk '{sub(/[ \t]+$/, ""); print}' | pbcopy
}

## K8s info
function k8s_info() {
  local kubeconfig

  if [[ -n "$KUBECONFIG" ]]; then
    kubeconfig="${KUBECONFIG%%:*}"
  else
    kubeconfig="$HOME/.kube/config"
  fi

  [[ -f "$kubeconfig" ]] || return

  local context namespace
  context=$(yq '.current-context' "$kubeconfig" 2>/dev/null)

  [[ -z "$context" || "$context" == "null" ]] && return

  namespace=$(yq '.contexts[] | select(.name == "'"$context"'") | .context.namespace' "$kubeconfig" 2>/dev/null)
  [[ -z "$namespace" || "$namespace" == "null" ]] && namespace="default"

  echo "%{$fg[cyan]%}⎈ ${namespace}@${context}%{$reset_color%} "
}

## Base64
function b64() {
  printf "%s" "$1" | base64
}
function b64d() {
  printf "%s" "$1" | base64 -d
}

## Exports ##

# TLDR config
export TLRC_CONFIG="$HOME/.config/tlrc/config.toml"

# .local/bin
export PATH="$HOME/.local/bin/:$PATH"

# .cargo/bin
export PATH="$HOME/.cargo/bin/:$PATH"

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

    # Customised cat
    alias cat='bat'


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

# Configurations for Linux ONLY
if [[ "$OS_TYPE" == "Linux" ]]; then
    # Configurations specific ONLY to Linux

    # Customised cat
    alias cat='batcat'

    :
fi


# Configurations for BOTH MacOS and Ubuntu 22.04
if [[ "$OS_TYPE" == "Darwin" ]] || ( [[ "$OS_TYPE" == "Linux" ]] && [[ "$(lsb_release -rs)" == "22.04" ]] ); then
    # Configurations for both MacOS and Ubuntu 22.04
    # Colorised tree
    alias tree='eza --tree'

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

# pnpm
export PNPM_HOME="/Users/stathis/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# bun completions
[ -s "/Users/stathis/.bun/_bun" ] && source "/Users/stathis/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/stathis/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/stathis/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/stathis/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/stathis/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/stathis/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
export PATH="/opt/homebrew/bin:$PATH"
export NVM_DIR="$HOME/.nvm"
source "$(brew --prefix nvm)/nvm.sh"
export PATH="$HOME/.tfenv/bin:$PATH"
source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"
RPROMPT='$(k8s_info)%B%F{green}%~%f%b %# '

alias gam="/Users/stathis/bin/gam7/gam"

eval $(thefuck --alias)

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/stathis/.lmstudio/bin"
# End of LM Studio CLI section
