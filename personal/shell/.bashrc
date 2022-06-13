# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

case ${TERM} in
    xterm*|rxvt*|Eterm|aterm|kterm|gnome*)
        PROMPT_COMMAND=${PROMPT_COMMAND:+$PROMPT_COMMAND; }'printf "\033]0;%s@%s:%s\007" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}"'
        ;;
    screen)
        PROMPT_COMMAND=${PROMPT_COMMAND:+$PROMPT_COMMAND; }'printf "\033_%s@%s:%s\033\\" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}"'
        ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
# if [ -f /etc/bash_completion ]; then . /etc/bash_completion ; complete -cf sudo; fi
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
if [ -f ~/.aliases ]; then . ~/.aliases fi
if [ -f ~/.functions ]; then . ~/.functions ; fi
if [ -f ~/.azure_completion ]; then . ~/.azure_completion ; fi
if [ -f ~/.bashlocalrc ]; then . ~/.bashlocalrc ; fi # settings that vary per workstation

###############################################################################
# Miscellaneous
###############################################################################

if [ "$PS1" ]; then # if running interactively, then run till 'fi' at EOF:
    ############################################################################
    # Command Prompt
    ############################################################################

    ##### Prompt escapes
    # Bash allows these prompt strings to be customized by inserting a
    # number of backslash-escaped special characters that are
    # decoded as follows:
    #  \a         an ASCII bell character (07)
    #  \d         the date in "Weekday Month Date" format (e.g., "Tue May 26")
    #  \D{format} the format is passed to strftime(3) and the result
    #             is inserted into the prompt string an empty format
    #             results in a locale-specific time representation.
    #             The braces are required
    #  \e         an ASCII escape character (033)
    #  \h         the hostname up to the first `.'
    #  \H         the hostname
    #  \j         the number of jobs currently managed by the shell
    #  \l         the basename of the shell's terminal device name
    #  \n         newline
    #  \r         carriage return
    #  \s         the name of the shell, the basename of $0 (the portion following
    #             the final slash)
    #  \t         the current time in 24-hour HH:MM:SS format
    #  \T         the current time in 12-hour HH:MM:SS format
    #  \@         the current time in 12-hour am/pm format
    #  \A         the current time in 24-hour HH:MM format
    #  \u         the username of the current user
    #  \v         the version of bash (e.g., 2.00)
    #  \V         the release of bash, version + patch level (e.g., 2.00.0)
    #  \w         the current working directory, with $HOME abbreviated with a tilde
    #  \W         the basename of the current working directory, with $HOME
    #             abbreviated with a tilde
    #  \!         the history number of this command
    #  \#         the command number of this command
    #  \$         if the effective UID is 0, a #, otherwise a $
    #  \nnn       the character corresponding to the octal number nnn
    #  \\         a backslash
    #  \[         begin a sequence of non-printing characters, which could be used
    #             to embed a terminal control sequence into the prompt
    #  \]         end a sequence of non-printing characters
    #
    #  The command number and the history number are usually different:
    #  the history number of a command is its position in the history
    #  list, which may include commands restored from the history file
    #  (see HISTORY below), while the command number is the position in
    #  the sequence of commands executed during the current shell session.
    #  After the string is decoded, it is expanded via parameter
    #  expansion, command substitution, arithmetic expansion, and quote
    #  removal, subject to the value of the promptvars shell option (see
    #  the description of the shopt command under SHELL BUILTIN COMMANDS
    #  below).

    ##### Color chart
    txtblk='\e[0;30m' # Black - Regular
    txtred='\e[0;31m' # Red
    txtgrn='\e[0;32m' # Green
    txtylw='\e[0;33m' # Yellow
    txtblu='\e[0;34m' # Blue
    txtpur='\e[0;35m' # Purple
    txtcyn='\e[0;36m' # Cyan
    txtwht='\e[0;37m' # White
    bldblk='\e[1;30m' # Black - Bold
    bldred='\e[1;31m' # Red
    bldgrn='\e[1;32m' # Green
    bldylw='\e[1;33m' # Yellow
    bldblu='\e[1;34m' # Blue
    bldpur='\e[1;35m' # Purple
    bldcyn='\e[1;36m' # Cyan
    bldwht='\e[1;37m' # White
    unkblk='\e[4;30m' # Black - Underline
    undred='\e[4;31m' # Red
    undgrn='\e[4;32m' # Green
    undylw='\e[4;33m' # Yellow
    undblu='\e[4;34m' # Blue
    undpur='\e[4;35m' # Purple
    undcyn='\e[4;36m' # Cyan
    undwht='\e[4;37m' # White
    bakblk='\e[40m'   # Black - Background
    bakred='\e[41m'   # Red
    badgrn='\e[42m'   # Green
    bakylw='\e[43m'   # Yellow
    bakblu='\e[44m'   # Blue
    bakpur='\e[45m'   # Purple
    bakcyn='\e[46m'   # Cyan
    bakwht='\e[47m'   # White
    txtrst='\e[0m'    # Text Reset

    # Multi lines prompt. If you’re the type who wants to pack your prompt full of information, then here’s the one for you. This one is a multi-line prompt containing date/time, full path, user and host, active terminal, even file count and space usage
    # PS1="\n\[\033[35m\]\$(/bin/date)\n\[\033[32m\]\w\n\[\033[1;31m\]\u@\h: \[\033[1;34m\]\$(/usr/bin/tty | /bin/sed -e 's:/dev/::'): \[\033[1;36m\]\$(/bin/ls -1 | /usr/bin/wc -l | /bin/sed 's: ::g') files \[\033[1;33m\]\$(/bin/ls -lah | /bin/grep -m 1 total | /bin/sed 's/total //')b\[\033[0m\] -> \[\033[0m\]"
    # Color manage your prompt. There’s nothing particularly fancy about this prompt, other than the good use of color to separate the different pieces of information. As you can see, it provides time, username, hostname, and current directory. Fairly minimal but useful.	
    PS1="\[\033[35m\]\t\[\033[m\]-\[\033[36m\]\u\[\033[m\]@\[\033[32m\]\h: \[\033[33;1m\]\w\[\033[m\]\n> "

    ##################################################
    # More PROMPT_COMMANDS
    ##################################################

    ###### Annoying PROMPT_COMMAND animation
    # PROMPT_COMMAND='seq $COLUMNS | xargs -IX printf "%Xs\r" @'

    ###### Saves terminal commands in history file in real time (for use with 'shopt -s histappend')
    PROMPT_COMMAND="history -a;$PROMPT_COMMAND"	# use with 'shopt -s histappend';save terminal commands in history file in real time

    ###### Share history between using multiple commands (press enter before get history from other bash shells)
    # PROMPT_COMMAND='history -a && history -n'

    ###### Shows date
    # PROMPT_COMMAND='date +%k:%m:%S'

    ###### Shows memory, load average, and history
    # PROMPT_COMMAND='history -a;echo -en "\033[m\033[38;5;2m"$(( `sed -nu "s/MemFree:[\t ]\+\([0-9]\+\) kB/\1/p" /proc/meminfo`/1024))"\033[38;5;22m/"$((`sed -nu "s/MemTotal:[\t ]\+\([0-9]\+\) kB/\1/Ip" /proc/meminfo`/1024 ))MB"\t\033[m\033[38;5;55m$(< /proc/loadavg)\033[m"'

    ###### Shows the return value of the last executed command (using smileys as to whether it was successful or not)
    # PROMPT_COMMAND='RET=$?; if [[ $RET -eq 0 ]]; then echo -ne "\033[0;32m$RET\033[0m ;)"; else echo -ne "\033[0;31m$RET\033[0m ;("; fi; echo -n " "'

    ##### Bash Settings
    # autoload -U compinit
    # compinit
    export BLOCKSIZE=K
    export BROWSER='firefox'
    # export BROWSER=$(find_alternatives chromium-browser google-chrome opera firefox firefox-bin iceweasel konqueror w3m lynx)	# uses function 'find_alternatives'
    export CDDIR="$HOME/work"			# for use with the function 'cd' and the alias 'cdd'
    # export CDPATH=.:~:~/src:/etc
    # export DISPLAY=:79
    # export EDITOR="gedit -w --resume" Typing 'fc'	# open last command for editing in gedit, then execute on save
    export EDITOR='vi'
    export VISUAL="vi"
    # export ftp_proxy=${MY_PROXY}
    # export GPG_TTY='tty'				# gpg-agent says it needs this
    # export GREP_OPTIONS='-D skip --binary-files=without-match --ignore-case'		# most commonly used grep options
    export HISTCONTROL=ignoreboth:erasedups		# for 'ignoreboth': ignore duplicates and /^\s/
    # export HISTCONTROL=ignoreboth			# ignore spaced commands and prevents storing of duplicate commands (ie, ignoredups & ignorespace)
    # export HISTCONTROL=ignoredups			# don't put duplicate lines in the history. See bash(1) for more options
    # export HISTCONTROL=ignorespace		# will make sure that bash don’t store any command beginning with the space character
    # export HISTFILE=/dev/null			# disable history for current shell session
    # export HISTFILE='$HOME/.history'
    # export HISTFILESIZE=10000			# increase or decrease the size of the history to '10,000'
    # export HISTFILESIZE=${HISTSIZE}		# bash will remember 'N' commands
    export HISTIGNORE='&:bg:fg:ll:h'
    # export HISTIGNORE='${HISTIGNORE:+$HISTIGNORE:}la:ll:lah:lat:;a:-:fg:bg:j:sync:esu:rma:rmp:fol:pfol'
    # export HISTIGNORE="&:ls:[bf]g:exit"		# duplicate entries in bash history, as well as ls, bg, fg & exit, making for cleaner bash history
    # export HISTIGNORE="&:ls:ll:la:l.:pwd:exit:clear"
    # export HISTIGNORE='pwd:cd:ls:ls -l:'		# ignore commands given
    export HISTSIZE=10000				# increase or decrease the size of the history to '10,000'
    # export HISTTIMEFORMAT='| %d/%m/%y %T | '	# make 'History' Show The Date For Each Command
    # export HISTTIMEFORMAT='%F %T '		# adds date and time to history
    export HISTTIMEFORMAT='%H:%M > '
    # export HISTTIMEFORMAT='%s' 			# the beloved Second of Our Linux
    # export HISTTIMEFORMAT='%Y-%b-%d::%Hh:%Mm:%Ss '
    export HISTTIMEFORMAT='%Y-%m-%d_%H:%M:%S_%a  '	# makes history display in YYYY-MM-DD_HH:MM:SS_3CharWeekdaySpaceSpace format
    export HOSTFILE=$HOME/.hosts    		# put list of remote hosts in ~/.hosts ...
    # export http_proxy=${MY_PROXY}
    # export https_proxy=${MY_PROXY}
    # export IGNOREEOF=1				# prevent CTRL-D from immediately logging out
    # export INPUTRC=/etc/inputrc			# it's possible that this will make bash find my delete key (and everything else)((but i don't think it did))
    # export INPUTRC=$HOME/.inputrc			# type in ‘whatever’ and press ‘Page Up’ key and bash automatically fetches last command that starts with whatever and completes the command for you (requires '$HOME/.inputrc' with these lines: #Page up/page down && "\e[5~": history-search-backward && "\e[6~": history-search-forward)
    # export LC_COLLATE="en_CA.utf8"		# change sorting methods [a-Z] instead of [A-Z]
    export LESSCHARSET='latin1'
    export LESS='-i -N -w  -z-4 -g -e -M -X -F -R -P%t?f%f \'
    # export LESSOPEN="|lesspipe.sh %s"; export LESSOPEN
    export LESSOPEN='|/usr/bin/lesspipe.sh %s 2>&-'	# use this if lesspipe.sh exists
    # export LESS="-QR"				# tell less not to beep and also display colours
    # export LESS='-R'
    # export LESS_TERMCAP_mb=$'\E[01;31m'      	# less colors for Man pages # begin blinking
    # export LESS_TERMCAP_md=$'\E[01;38;5;74m'  	# less colors for Man pages # begin bold
    # export LESS_TERMCAP_me=$'\E[0m'           	# less colors for Man pages # end mode
    # export LESS_TERMCAP_se=$'\E[0m'           	# less colors for Man pages # end standout-mode
    # export LESS_TERMCAP_so=$'\E[38;5;246m'    	# less colors for Man pages # begin standout-mode - info box
    # export LESS_TERMCAP_ue=$'\E[0m'           	# less colors for Man pages # end underline
    # export LESS_TERMCAP_us=$'\E[04;38;5;146m' 	# less colors for Man pages # begin underline
    # export MY_PROXY='http://YOUR_USERNAME:YOUR_PASSWORD@PROXY_IP:PROXY_PORT/'
    # export OOO_FORCE_DESKTOP=gnome   		# openoffice preferences
    export PAGER='less -e'
    export PATH=./node_modules:~/.npm:/usr/lib/node_modules:/home/aedu/bin:/home/aedu/bin/scripts:/home/aedu/bin/go/bin:/home/aedu/.gem/ruby/2.7.0/bin:/opt/atlassian-plugin-sdk/bin:/opt/flutter/bin:$PATH:~/bin
    # export PILOTRATE=57600			# make pilot-xfer go faster than 9600
    export TERM='xterm'
    export TIMEFORMAT=$'\nreal %3R\tuser %3U\tsys %3S\tpcpu %P\n'
    export TMOUT=1200				# auto logout after n seconds of inactivity
    # export USER_CLIENT=deluge
    # export USER_DPRT=22218
    # export USER_OPRT=47426
    # export USER_VPRT=79
    # export USER_WPRT=30818
    # export wpsetters=feh
    export VIEWER=eog
    # ${file%\.[^.]*}				# to remove filename extensions in bash
    # fortune -a					# fortunes at each new shell
    # mesg n              				#
    set -b						# causes output from background processes to be output right away, not on wait for next primary prompt
    # set bell-style visible			# I hate noise
    # set completion-ignore-case on 		# complete things that have been typed in the wrong case
    # set -o ignoreeof				# can't c-d out of shell
    # set -o noclobber				# disallow > to work on files that already exist (prevents catting over file)
    set -o notify					# notify when jobs running in background terminate
    # set -o nounset				# attempt to use undefined variable outputs error message and forces exit (messes up completion if enabled)
    # set +o nounset          			# otherwise some completions will fail
    # setopt autopushd pushdminus pushdsilent pushdtohome
    # setopt correct
    # setopt extendedglob
    # setopt hist_ignore_space    			# prepend ' ' to not be saved
    # setopt hist_verify          			# verify when using !
    # setopt nocheckjobs          			# don't complain about background jobs on e
    # setopt no_clobber           			# don't overwrite files when redirect
    # setopt nohup               			# don't kill bg jobs when tty quits
    # setopt printexitvalue       			# print exit value from jobs
    # setopt share_history
    # set -o xtrace					# useful for debuging
    # setterm -blength 0				# set the bell duration in milliseconds (silence the beeps)
    # set visible-stats on 				# when listing possible file completions, put / after directory names and * after programs
    shopt -s cdable_vars				# set the bash option so that no '$' is required (disallow write access to terminal)
    shopt -s cdspell				# this will correct minor spelling errors in a cd command
    shopt -s checkhash
    shopt -s checkwinsize				# update windows size on command
    shopt -s cmdhist          			# save multi-line commands in history as single line
    # shopt -s dotglob				# files beginning with . to be returned in the results of path-name expansion
    # shopt -s expand aliases			# expand aliases
    shopt -s extglob				# necessary for bash completion (programmable completion)
    # shopt -s globstar				# enables the ** globbing operator
    # shopt -s histappend				# bash history is only saved when close terminal, not after each command and this fixes it
    shopt -s histappend histreedit histverify
    # shopt -s histreedit
    # shopt -s histverify
    # shopt -s hostcomplete     			# attempt hostname expansion when @ is at the beginning of a word
    # shopt -s huponexit
    shopt -s mailwarn				# keep an eye on the mail file (access time)
    # shopt -s nocaseglob cdspell histappend
    shopt -s nocaseglob       			# pathname expansion will be treated as case-insensitive (auto-corrects the case)
    shopt -s no_empty_cmd_completion		# no empty completion (bash>=2.04 only)
    # shopt -s nullglob dotglob
    shopt -s sourcepath
    # shopt -u cmdhist				# do not treat multiple line commands as a single entry
    # shopt -u force_fignore			# expand to complete an ignored word, if no other words match.
    # shopt -u mailwarn
    # shopt -u sourcepath
    # stty -ixon					# disable XON/XOFF flow control (^s/^q)
    stty start undef
    stty stop undef
    # stty stop ''					# use C-s to search forward through history (do not block output)
    # ulimit -c unlimited				# let me have core dumps
    ulimit -S -c 0          			# (core file size) don't want any coredumps
    # ulimit -S -f 1024   				# open files
    # ulimit -S -s 8192  				# stack size
    # ulimit -S -u 256    				# max user processes
    # umask 007                     # all files created 660, dirs 770
    # umask 022                     # makes new files have permissions: rwxr-xr-x
    # umask 077                     # after everything is installed, uncomment this and the mkdir alias below ((base 8) 777 & ~077 = 700 = u=rwx,g=,o=)
    # unset HISTFILESIZE            # infinite History
    # unset HISTSIZE                # infinite History
    unset MAILCHECK                 # don't want my shell to warn me of incoming mail
    # unsetopt bgnice               # don't nice bg command

    if [ -d $HOME/Maildir/ ]; then
        export MAIL=$HOME/Maildir/
        export MAILPATH=$HOME/Maildir/
        export MAILDIR=$HOME/Maildir/
    elif [ -f /var/mail/$USER ]; then
        export MAIL="/var/mail/$USER"
    fi

    if [ "$TERM" = "screen" ]; then
        export TERM=$TERMINAL
    fi

    function get_xserver()
    {
        case $TERM in
            xterm )
                XSERVER=$(who am i | awk '{print $NF}' | tr -d ')''(' )
                # Ane-Pieter Wieringa suggests the following alternative:
                # I_AM=$(who am i)
                # SERVER=${I_AM#*(}
                # SERVER=${SERVER%*)}
                XSERVER=${XSERVER%%:*}
                ;;
            aterm | rxvt)
                # Find some code that works here. ...
                ;;
        esac
    }
    if [ -z ${DISPLAY:=""} ]; then
        get_xserver
        if [[ -z ${XSERVER}  || ${XSERVER} == $(hostname) || \
            ${XSERVER} == "unix" ]]; then
            DISPLAY=":0.0"          # Display on local host.
        else
            DISPLAY=${XSERVER}:0.0  # Display on remote host.
        fi
    fi
    export DISPLAY

    ##### PATH
    if [ "$UID" -eq 0 ]; then
        PATH=$PATH:/usr/local:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games
    fi

    # remove duplicate path entries
    export PATH=$(echo $PATH | awk -F: '
    { for (i = 1; i <= NF; i++) arr[$i]; }
    END { for (i in arr) printf "%s:" , i; printf "\n"; } ')

    # autocomplete ssh commands
    # TBD fix: complete -W "$(echo `cat ~/.bash_history | egrep '^ssh ' | sort | uniq | sed 's/^ssh //'`;)" ssh

    ##### Bashrc greeting
    # from Jonathan's .bashrc file (by ~71KR117) greeting
    # get current hour (24 clock format i.e. 0-23)
    hour=$(date +"%H")
    # if it is midnight to midafternoon will say G'morning
    if [ $hour -ge 0 -a $hour -lt 12 ]
        then
        greet="Good Morning, $USER. Welcome back."
        # if it is midafternoon to evening ( before 6 pm) will say G'noon
    elif [ $hour -ge 12 -a $hour -lt 18 ]
        then
        greet="Good Afternoon, $USER. Welcome back."
    else # it is good evening till midnight
        greet="Good Evening, $USER. Welcome back."
    fi
    # display greeting
    echo $greet

    ###############################################################################
    # Completions
    ###############################################################################

    ##################################################
    # Completion functions (only since Bash-2.04)	 #
    ##################################################

    ###### This is a 'universal' completion function - it works when commands have
    # a so-called 'long options' mode , ie: 'ls --all' instead of 'ls -a'
    # Needs the '-o' option of grep
    # (try the commented-out version if not available).
    # First, remove '=' from completion word separators
    # (this will allow completions like 'ls --color=auto' to work correctly).

    COMP_WORDBREAKS=${COMP_WORDBREAKS/=/}

    ###### avoid tilde expansion from the bash_completion script
    function _expand()
    {
        [ "$cur" != "${cur%\\}" ] && cur="$cur\\";
        if [[ "$cur" == \~*/* ]]; then
            #eval cur=$cur;
            :;
        else
            if [[ "$cur" == \~* ]]; then
                cur=${cur#\~};
                COMPREPLY=($( compgen -P '~' -u $cur ));
                return ${#COMPREPLY[@]};
            fi;
        fi
    }

    function _get_longopts()
    {
        # $1 --help | sed  -e '/--/!d' -e 's/.*--\([^[:space:].,]*\).*/--\1/'| \
        l# grep ^"$2" |sort -u ;
        $1 --help | grep -o -e "--[^[:space:].,]*" | grep -e "$2" |sort -u
    }

    function _killall()
    {
        local cur prev
        COMPREPLY=()
        cur=${COMP_WORDS[COMP_CWORD]}
        # get a list of processes (the first sed evaluation
        # takes care of swapped out processes, the second
        # takes care of getting the basename of the process)
        COMPREPLY=( $( /usr/bin/ps -u $USER -o comm  | \
        sed -e '1,1d' -e 's#[]\[]##g' -e 's#^.*/##'| \
        awk '{if ($0 ~ /^'$cur'/) print $0}' ))
        return 0
    }
    complete -F _killall killall killps

    function _longopts()
    {
        local cur
        cur=${COMP_WORDS[COMP_CWORD]}
        case "${cur:-*}" in
           -*)      ;;
            *)      return ;;
        esac
        case "$1" in
            \~*)     eval cmd="$1" ;;
            *)       cmd="$1" ;;
        esac
        COMPREPLY=( $(_get_longopts ${1} ${cur} ) )
    }
    complete  -o default -F _longopts configure bash
    complete  -o default -F _longopts wget id info a2ps ls recode

    ###### A meta-command completion function for commands like sudo(8), which need to
    # first complete on a command, then complete according to that command's own
    # completion definition - currently not quite foolproof,
    # but still quite useful (By Ian McDonald, modified by me).
    function _meta_comp()
    {
        local cur func cline cspec
        COMPREPLY=()
        cur=${COMP_WORDS[COMP_CWORD]}
        cmdline=${COMP_WORDS[@]}
        if [ $COMP_CWORD = 1 ]; then
            COMPREPLY=( $( compgen -c $cur ) )
        else
            cmd=${COMP_WORDS[1]}            # Find command.
            cspec=$( complete -p ${cmd} )   # Find spec of that command.
            # COMP_CWORD and COMP_WORDS() are not read-only,
            # so we can set them before handing off to regular
            # completion routine:
            # Get current command line minus initial command,
            cline="${COMP_LINE#$1 }"
            # split current command line tokens into array,
            COMP_WORDS=( $cline )
            # set current token number to 1 less than now.
            COMP_CWORD=$(( $COMP_CWORD - 1 ))
            # If current arg is empty, add it to COMP_WORDS array
            # (otherwise that information will be lost).
            if [ -z $cur ]; then COMP_WORDS[COMP_CWORD]=""  ; fi
            if [ "${cspec%%-F *}" != "${cspec}" ]; then
                # if -F then get function:
                func=${cspec#*-F }
                func=${func%% *}
                eval $func $cline   # Evaluate it.
            else
                func=$( echo $cspec | sed -e 's/^complete//' -e 's/[^ ]*$//' )
                COMPREPLY=( $( eval compgen $func $cur ) )
            fi
        fi
    }
fi
fi
