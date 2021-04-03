# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block, everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Created by newuser for 5.2
# The following lines were added by compinstall

zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}' 'r:|[._-]=** r:|=**'
zstyle :compinstall filename '/home/aedu/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

autoload -U add-zsh-hook                      # Load the zsh hook module. 
add-zsh-hook preexec pre_validation           # Adds the hook 

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt appendhistory autocd extendedglob notify hist_ignore_all_dups hist_ignore_space
bindkey -e
# End of lines configured by zsh-newuser-install

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    archlinux
    ansible
    docker
    docker-compose
    flutter
    gnu-utils
    gcloud
    git
    git-extras
    gitfast
    git-flow
    github
    gitignore
    git-prompt
    golang
    gradle
    helm
    heroku
    history-substring-search
    kubectl
    pip
    python
    rake
    ruby
    ssh-agent
    tmux
    zsh-navigation-tools
    zsh_reload
)

ZSH=~/.oh-my-zsh
ZSH_THEME=powerlevel10k/powerlevel10k
source $ZSH/oh-my-zsh.sh

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

if [ -f ~/.aliases ]; then . ~/.aliases ; fi
if [ -f ~/.functions ]; then . ~/.functions ; fi
if [ -f ~/.exports ]; then . ~/.exports ; fi
if [ -f ~/.tokens ]; then . ~/.tokens ; fi
if [ -f ~/.azure_completion ]; then . ~/.azure_completion ; fi

setopt COMPLETE_ALIASES

# https://gnunn1.github.io/tilix-web/manual/vteconfig/
if [ $TILIX_ID ] || [ $VTE_VERSION ]; then
    source /etc/profile.d/vte.sh
fi

# https://github.com/zsh-users/zsh-history-substring-search
#export zsh_plugin_dir=/usr/share/oh-my-zsh/custom/plugins/
#source $zsh_plugin_dir/zsh_history_substring_search/zsh-syntax-highlighting.zsh
#source $zsh_plugin_dir/zsh_history_substring_search/zsh-history-substring-search.zsh
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down