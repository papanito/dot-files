# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# OHZ::tmux config adjustments
export EDITOR=vi
export ZSH_TMUX_FIXTERM=false

# My own stuff
export DOCRENAMERCONFIGDIR=~/config/docrenamer

export GITHUB_USERNAME=papanito