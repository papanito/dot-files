# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block, everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Created by newuser for 5.2
# The following lines were added by compinstall
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

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

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

ZSH_DOTENV_FILE=.dotenv
if [ -f ~/.aliases ]; then . ~/.aliases ; fi
if [ -f ~/.functions ]; then . ~/.functions ; fi
if [ -f ~/.azure_completion ]; then . ~/.azure_completion ; fi
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
setopt COMPLETE_ALIASES

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
autoload 0-Uz _zi
(( ${+_comps} )) && _comps[zi]=_zi

# history-substring-search-up
zi light romkatv/powerlevel10k

# https://github.com/z-shell/zsh-navigation-tools
zi load z-shell/zsh-navigation-tools

autoload znt-history-widget
zle -N znt-history-widget
bindkey "^R" znt-history-widget

zle -N znt-cd-widget
bindkey "^B" znt-cd-widget
zle -N znt-kill-widget
bindkey "^Y" znt-kill-widget

zi light z-shell/F-Sy-H

## https://z.digitalclouds.dev/docs/getting_started/overview/
zi snippet OMZ::plugins/archlinux
zi snippet OMZ::plugins/ansible
zi snippet OMZ::plugins/dotenv
zi snippet OMZ::plugins/docker
zi snippet OMZ::plugins/docker-compose
zi snippet OMZ::plugins/flutter
zi snippet OMZ::plugins/gnu-utils
zi snippet OMZ::plugins/gcloud
zi snippet OMZ::plugins/git
zi snippet OMZ::plugins/git-extras
#zi snippet OMZ::plugins/gitfast
#zi snippet OMZ::plugins/git-flow
zi snippet OMZ::plugins/github
zi snippet OMZ::plugins/gitignore
zi snippet OMZ::plugins/git-prompt
zi snippet OMZ::plugins/golang
zi snippet OMZ::plugins/gradle
zi snippet OMZ::plugins/helm
zi snippet OMZ::plugins/heroku
#zi snippet OMZ::plugins/history-substring-search
zi snippet OMZ::plugins/jump
zi snippet OMZ::plugins/kubectl
zi snippet OMZ::plugins/pip
zi snippet OMZ::plugins/python
#zi snippet OMZ::plugins/rake
#zi snippet OMZ::plugins/ruby
zi snippet OMZ::plugins/ssh-agent
zi snippet OMZ::plugins/tmux
#zi snippet OMZ::plugins/zsh_reload

# https://github.com/zsh-users/zsh-history-substring-search
zi light zsh-users/zsh-history-substring-search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

export exa_params=('--git' '--classify' '--group-directories-first' '--time-style=long-iso' '--group' '--color-scale')
zi light zplugin/zsh-exa

# Enrich with some neat tools
eval "$(navi widget zsh)"
eval "$(direnv hook zsh)"
