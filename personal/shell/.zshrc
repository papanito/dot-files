# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block, everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# # enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# https://gnunn1.github.io/tilix-web/manual/vteconfig/
if [ $TILIX_ID ] || [ $VTE_VERSION ]; then
    source /etc/profile.d/vte.sh
fi

# https://z.digitalclouds.dev/docs/getting_started/installation/#-setup-zi-directory
if [[ ! -f $HOME/.zi/bin/zi.zsh ]]; then
  print -P "%F{33}▓▒░ %F{160}Installing (%F{33}z-shell/zi%F{160})…%f"
  command mkdir -p "$HOME/.zi" && command chmod g-rwX "$HOME/.zi"
  command git clone -q --depth=1 --branch "main" https://github.com/z-shell/zi "$HOME/.zi/bin" && \
    print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
    print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi
zi_home="${HOME}/.zi"
source "${zi_home}/bin/zi.zsh"
autoload -Uz _zi
(( ${+_comps} )) && _comps[zi]=_zi

autoload -Uz compinit; compinit

# define the completer we’ll use for our completion system
# The order matter: the completion system will try each of these completer one after the other
zstyle ':completion:*' completer _expand_alias _expand _complete _correct _approximate

# If you end up using a directory as argument, this will remove the trailing slash (usefull in ln)
zstyle ':completion:*' squeeze-slashes true

# cd will never select the parent directory (e.g.: cd ../<TAB>):
zstyle ':completion:*:cd:*' ignore-parents parent pwd

# Using a cache for the completion can speed up some commands, like apt for example. Let’s add the following in our file to enable it:
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/.zcompcache"

# To group the different type of matches under their descriptions,
zstyle ':completion:*' group-name ''
zstyle ':completion:*:*:-command-:*:*' group-order aliases builtins functions commands

zstyle ':completion:*:*:-command-:*:*' group-order alias builtins functions commands
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' menu select=2

zstyle ':completion:*:*:*:*:corrections' format '%F{yellow}!- %d (errors: %e) -!%f'
zstyle ':completion:*:*:*:*:descriptions' format '%F{blue}-- %D %d --%f'
zstyle ':completion:*:*:*:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:*:*:*:warnings' format ' %F{red}-- no matches found --%f'
# zstyle ':completion:*:default' list-prompt '%S%M matches%s'
# Colors for files and directory
zstyle ':completion:*:*:*:*:default' list-colors ${(s.:.)LS_COLORS}

zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
# Completing process IDs with menu selection:
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*'   force-list always

# See ZSHCOMPWID "completion matching control"
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

zstyle ':completion:*' keep-prefix true

# zstyle -e ':completion:*:(ssh|scp|sftp|rsh|rsync):hosts' hosts 'reply=(${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) /dev/null)"}%%[# ]*}//,/ })'

HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt appendhistory autocd extendedglob notify hist_ignore_all_dups hist_ignore_space
bindkey -e

zi light zsh-users/zsh-autosuggestions
zi light z-shell/F-Sy-H

zi load romkatv/powerlevel10k

# https://github.com/z-shell/zsh-navigation-tools
zi load z-shell/zsh-navigation-tools

# autoload znt-history-widget
# zle -N znt-history-widget
# bindkey "^R" znt-history-widget

zle -N znt-cd-widget
bindkey "^B" znt-cd-widget

zle -N znt-kill-widget
bindkey "^Y" znt-kill-widget

## https://z.digitalclouds.dev/docs/getting_started/overview/
zi snippet OMZ::plugins/archlinux
zi snippet OMZ::plugins/ansible
zi snippet OMZ::plugins/dotenv
zi snippet OMZ::plugins/docker
zi snippet OMZ::plugins/docker-compose
zi snippet OMZ::plugins/fzf
zi snippet OMZ::plugins/flutter
zi snippet OMZ::plugins/gnu-utils
zi snippet OMZ::plugins/gcloud
zi snippet OMZ::plugins/git
zi snippet OMZ::plugins/git-extras
zi snippet OMZ::plugins/github
zi snippet OMZ::plugins/gitignore
zi snippet OMZ::plugins/git-prompt
zi snippet OMZ::plugins/golang
zi snippet OMZ::plugins/gradle
zi snippet OMZ::plugins/helm
zi snippet OMZ::plugins/heroku
zi snippet OMZ::plugins/jump
zi snippet OMZ::plugins/kubectl
zi snippet OMZ::plugins/pip
zi snippet OMZ::plugins/python
zi snippet OMZ::plugins/ssh-agent
zi snippet OMZ::plugins/tmux
zi snippet OMZ::plugins/terraform

# https://github.com/zsh-users/zsh-history-substring-search
zi light zsh-users/zsh-history-substring-search
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "^[[A" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down
bindkey "^[[B" history-substring-search-down

export exa_params=('--git' '--classify' '--group-directories-first' '--time-style=long-iso' '--group' '--color-scale')
zi light zplugin/zsh-exa

zi light Aloxaf/fzf-tab

zi ice as'null' from"gh-r" sbin
zi light ajeetdsouza/zoxide
zi ice has'zoxide'
zi light z-shell/zsh-zoxide

eval "$(navi widget zsh)"
eval "$(direnv hook zsh)"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
if [ -f ~/.aliases ]; then . ~/.aliases ; fi
if [ -f ~/.functions ]; then . ~/.functions ; fi
if [ -f ~/.azure_completion ]; then . ~/.azure_completion ; fi

autoload -U add-zsh-hook                      # Load the zsh hook module. 
add-zsh-hook preexec pre_validation           # Adds the hook

## enable autocompletion
source <(kubectl completion zsh)

autoload -U +X bashcompinit && bashcompinit

TF=/usr/bin/terraform 
[[ ! -f $TF  ]] || complete -o nospace -C $TF terraform
AZCOMP=/etc/bash_completion.d/azure-cli
[[ ! -f $AZCOMP  ]] || source /etc/bash_completion.d/azure-cli
