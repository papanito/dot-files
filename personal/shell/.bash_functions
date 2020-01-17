###### Good bash tips for everyone
function bashtips() {
   # copyright 2007 - 2010 Christopher Bratusek
   echo "
DIRECTORIES
-----------
~-          Previous working directory
pushd tmp   Push tmp && cd tmp
popd        Pop && cd
GLOBBING AND OUTPUT SUBSTITUTION
--------------------------------
ls a[b-dx]e Globs abe, ace, ade, axe
ls a{c,bl}e Globs ace, able
\$(ls)      \`ls\` (but nestable!)
HISTORY MANIPULATION
--------------------
!!        Last command
!?foo     Last command containing \`foo'
^foo^bar^ Last command containing \`foo', but substitute \`bar'
!!:0      Last command word
!!:^      Last command's first argument
!\$       Last command's last argument
!!:*      Last command's arguments
!!:x-y    Arguments x to y of last command
C-s       search forwards in history
C-r       search backwards in history
LINE EDITING
------------
M-d        kill to end of word
C-w        kill to beginning of word
C-k        kill to end of line
C-u        kill to beginning of line
M-r        revert all modifications to current line
C-]        search forwards in line
M-C-]      search backwards in line
C-t        transpose characters
M-t        transpose words
M-u        uppercase word
M-l        lowercase word
M-c        capitalize word
COMPLETION
----------
M-/        complete filename
M-~        complete user name
M-@        complete host name
M-\$       complete variable name
M-!        complete command name
M-^        complete history"
}

######
# used for bash nautilus scripts to show a warning if something goes wrong
# use as follows in your scripts
# trap errormsg  SIGINT SIGTERM ERR
function errormsg() {
    zenity --warning \
   --text $1 
}

# https://software.rajivprab.com/2019/07/14/ssh-considered-harmful/
function tsh {
    host=$1
    session_name=$2
    if [ -z "$session_name" ]; then
        echo "Need to provide session-name. Example: tsh <hostname> main"
        return 1;
    fi
    ssh $host -t "tmux attach -t $session_name || tmux new -s $session_name"
}

######  Checks to ensure that all environment variables are valid
# looks at SHELL, HOME, PATH, EDITOR, MAIL, and PAGER
function path_validator()
{
   errors=0
   function in_path()
   {
      # given a command and the PATH, try to find the command. Returns
      # 1 if found, 0 if not.  Note that this temporarily modifies the
      # the IFS input field seperator, but restores it upon completion.
      cmd=$1    path=$2    retval=0
      oldIFS=$IFS; IFS=":"
        for directory in $path
        do
         if [ -x $directory/$cmd ] ; then
            retval=1      # if we're here, we found $cmd in $directory
         fi
      done
      IFS=$oldIFS
      return $retval
   }
   function validate()
   {
      varname=$1    varvalue=$2
      if [ ! -z $varvalue ] ; then
         if [ "${varvalue%${varvalue#?}}" = "/" ] ; then
            if [ ! -x $varvalue ] ; then
               echo "** $varname set to $varvalue, but I cannot find executable."
               errors=$(( $errors + 1 ))
            fi
         else
            if in_path $varvalue $PATH ; then
            echo "** $varname set to $varvalue, but I cannot find it in PATH."
            errors=$(( $errors + 1 ))
         fi
         fi
      fi
   }
    # Beginning of actual shell script
   if [ ! -x ${SHELL:?"Cannot proceed without SHELL being defined."} ] ; then
      echo "** SHELL set to $SHELL, but I cannot find that executable."
      errors=$(( $errors + 1 ))
   fi
   if [ ! -d ${HOME:?"You need to have your HOME set to your home directory"} ]
   then
      echo "** HOME set to $HOME, but it's not a directory."
      errors=$(( $errors + 1 ))
   fi
   # Our first interesting test: are all the paths in PATH valid?
   oldIFS=$IFS; IFS=":"     # IFS is the field separator. We'll change to ':'
   for directory in $PATH
   do
      if [ ! -d $directory ] ; then
         echo "** PATH contains invalid directory $directory"
         errors=$(( $errors + 1 ))
      fi
   done
   IFS=$oldIFS             # restore value for rest of script
   # Following can be undefined, & also be a progname, rather than fully qualified path.
   # Add additional variables as necessary for your site and user community.
   validate "EDITOR" $EDITOR
   validate "MAILER" $MAILER
   validate "PAGER"  $PAGER
   # and, finally, a different ending depending on whether errors > 0
   if [ $errors -gt 0 ] ; then
      echo "Errors encountered. Please notify sysadmin for help."
   else
      echo "Your environment checks out fine."
   fi
}

###### Add a function you've defined to .bash_functions
function addfunction() { declare -f $1 >> ~/.bash_functions ; }

##### Automatically inputs aliases here in .bash_aliases
# Usage: addalias <name> "<command>"
# Example: addalias rm "rm -i"
function addalias()
{
   if [[ $1 && $2 ]]
   then
   echo -e "alias $1=\"$2\"" >> ~/.bash_aliases
   alias $1=$2
   fi
}

###### Reminder for whatever whenever
function remindme()
{
   sleep $1 && zenity --info --text "$2" &
}

###### Manpage to pdf document
# example:   man2pdf wipe   =   wipe.pdf
# copyright 2007 - 2010 Christopher Bratusek
function man2pdf()
{
   case $1 in
      *help | "" )
         echo -e "\nUsage:"
         echo -e   "\nman2pdf | <manualpage> [generate a pdf from <manualpage>]\n"
         tput sgr0
      ;;
      * )
         check_opt ps2pdf man2pdf
         if [[ $? != "1"  && $1 ]]; then
            man -t $1 | ps2pdf - >$1.pdf
         else   echo "No manpage given."
         fi
      ;;
   esac
}

###### Manpage to txt document
# example:   man2text wipe   =   wipe.txt
function man2text()
{
   man "$1" | col -b > ~/man_"$1".txt
}

###### ISO-writer
function writeiso() {
   # copyright 2007 - 2010 Christopher Bratusek
   if [[ $CD_WRITER ]]; then
      cdrecord dev=$CD_WRITER "$1"
   else   cdrecord deV=/dev/dvdrw "$1"
   fi
}

###### cp with progress bar (using pv)
function cp_p() {
   if [ `echo "$2" | grep ".*\/$"` ]
   then
      pv "$1" > "$2""$1"
   else
      pv "$1" > "$2"/"$1"
   fi
}

###### Shot - takes a screenshot of your current window 
function shot()
{
   import -frame -strip -quality 75 "$HOME/$(date +%s).png"
}

###### Screencasting with mplayer webcam window
function screencastw()
{
   mplayer -cache 128 -tv driver=v4l2:width=176:height=177 -vo xv tv:// -noborder -geometry "95%:93%" -ontop | ffmpeg -y -f alsa -ac 2 -i pulse -f x11grab -r 30 -s `xdpyinfo | grep 'dimensions:'|awk '{print $2}'` -i :0.0 -acodec pcm_s16le output.wav -an -vcodec libx264 -vpre lossless_ultrafast -threads 0 output.mp4
}

###### Email yourself a short note
function quickemail() { 
   echo "$*" | mail -s "$*" aedu@wyssmann.com;
}

######  Corporate ldapsearch for users
function ldapfind() {
   ldapsearch -x -h ldap.foo.bar.com -b dc=bar,dc=com uid=$1
}

###############################################################################
# Power Management
###############################################################################
function pwr-low {
   #Suggestion: Enable the CONFIG_INOTIFY kernel configuration option.
   #This option allows programs to wait for changes in files and directories
   #instead of having to poll for these changes

   # Enable SATA ALPM link power management
   sudo echo min_power > /sys/class/scsi_host/host0/link_power_management_policy
   sudo echo min_power > /sys/class/scsi_host/host1/link_power_management_policy
   sudo echo min_power > /sys/class/scsi_host/host2/link_power_management_policy
   sudo echo min_power > /sys/class/scsi_host/host3/link_power_management_policy
   iwconfig wlan0 power timeout 500ms
   
   # disable the NMI watchdog by executing the following command:
   sudo echo 0 > /proc/sys/kernel/nmi_watchdog
   
   # enable HD audio powersave mode by executing the following command:
   sudo echo 1 > /sys/module/snd_hda_intel/parameters/power_save
}

function pwr-high {
   # diasble SATA ALPM link power management
   sudo echo max_performance > /sys/class/scsi_host/host0/link_power_management_policy
   sudo echo max_performance > /sys/class/scsi_host/host1/link_power_management_policy
   sudo echo max_performance > /sys/class/scsi_host/host2/link_power_management_policy
   sudo echo max_performance > /sys/class/scsi_host/host3/link_power_management_policy
   
   # disable HD audio powersave mode by executing the following command:
   sudo echo 0 > /sys/module/snd_hda_intel/parameters/power_save
   
}

###############################################################################
# Systemd service
###############################################################################
###### start a service
function start() {
   sudo systemctl start $1.service
}

###### stop a service
function stop() {
   sudo systemctl stop $1.service
}

###### query status of a service
function status() {
   sudo systemctl status $1.service
}

###### query status of a service
function sstatus() {
   sudo systemctl | grep $1
}

###### enable a service
function senable() {
   sudo systemctl status $1.service
}

###### list available systemd services
function services() {
   ll /usr/lib/systemd/system
}

###############################################################################
# Directories/Folders
###############################################################################
##### Change directory and list files
function cds() {
    # only change directory if a directory is specified
    [ -n "${1}" ] && cd $1
    ll
}

##### Makes directory then moves into it
function mkdircd() {
    mkdir -p -v $1
    cd $1
}

###### Show empty files in the directed directory
function empty() {
   # copyright 2007 - 2010 Christopher Bratusek
   find "$1" -empty
}

###### Count files in current directory
function count_files()
# copyright 2007 - 2010 Christopher Bratusek
{
   case $1 in
      *+h)
         echo $(($(ls --color=no -1 -la . | grep -v ^l | wc -l)-1))
      ;;
      *-h)
         echo $(($(ls --color=no -1 -l . | grep -v ^l | wc -l)-1))
      ;;
      *+d)
         echo $(($(ls --color=no -1 -la . | grep -v ^- | wc -l)-1))
      ;;
      *-d)
         echo $(($(ls --color=no -1 -l . | grep -v ^- | wc -l)-1))
      ;;
      *+f)
         echo $(($(ls --color=no -1 -la . | grep -v ^d | wc -l)-1))
      ;;
      *-f)
         echo $(($(ls --color=no -1 -l . | grep -v ^d | wc -l)-1))
      ;;
      *)
         echo -e "\n${ewhite}Usage:"
         echo -e "\n${eorange}count_files${ewhite} | ${egreen}+h ${eiceblue}[count files and folders - include hidden ones] \
         \n${eorange}count_files${ewhite} | ${egreen}-h ${eiceblue}[count files and folders - exclude hidden ones] \
         \n${eorange}count_files${ewhite} | ${egreen}+d ${eiceblue}[count folders - include hidden ones] \
         \n${eorange}count_files${ewhite} | ${egreen}-d ${eiceblue}[count folders - exclude hidden ones] \
         \n${eorange}count_files${ewhite} | ${egreen}+f ${eiceblue}[count files - include hidden ones] \
         \n${eorange}count_files${ewhite} | ${egreen}-f ${eiceblue}[count files - exclude hidden ones]\n"
         tput sgr0
      ;;
   esac
}

###### Dirsize - finds directory sizes and lists them for the current directory
function dirsize()
{
   du -shx * .[a-zA-Z0-9_]* 2> /dev/null | \
   egrep '^ *[0-9.]*[MG]' | sort -n > /tmp/list
   egrep '^ *[0-9.]*M' /tmp/list
   egrep '^ *[0-9.]*G' /tmp/list
   rm /tmp/list
}

###### Size of directories in MB   
function ds()
{
    echo "size of directories in MB"
    if [ $# -lt 1 ] || [ $# -gt 2 ]; then
      echo "you did not specify a directy, using pwd"
      DIR=$(pwd)
      find $DIR -maxdepth 1 -type d -exec du -sm \{\} \; | sort -nr
    else
      find $1 -maxdepth 1 -type d -exec du -sm \{\} \; | sort -nr
    fi
}

###### Size of items in directory
function dubigf() {
   du -sh * | awk '/[[:space:]]*[[:digit:]]+,*[[:digit:]]*G/' | sort -nr
   du -sh * | awk '/[[:space:]]*[[:digit:]]+,*[[:digit:]]*M/' | sort -nr
}

###############################################################################
# Directory operations: editd, flipd, popd, printd, pushd, rotd, swapd
###############################################################################
###### Edit directory stack
function editd() {
   export EDITDNO=$((${EDITDNO:=0} + 1))
   typeset FiLe=/tmp/`basename -- $0`$$.${EDITDNO}
   printd >${FiLe}
   ${EDITOR} ${FiLe}
   DS=`while read ea; do echo -n "$ea:"; done <${FiLe}`
   rm -f ${FiLe}
}

###### flip back-and-forth between current dir and top of stack (like "cd -")
function flipd() {
   if [ "$DS" ]
   then
      cd "${DS%%:*}"
      export DS="$OLDPWD:${DS#*:}"
   else
      echo "$0: empty directory stack" >&2
   fi
}

###### pop top dir off stack and cd to it
function popd() {
   if [ "$DS" ]
   then
      cd "${DS%%:*}"
      export DS="${DS#*:}"
   else
      echo "$0: empty directory stack" >&2
   fi
}

###### Print directory stack
function printd() {
   ( IFS=:; for each in $DS; do echo $each; done; )
}

###### Change to new dir, pushing current onto stack
function pushd() {
   export DS="$PWD:$DS"
   if [ -n "$1" ]; then cd "$1"; else cd; fi || export DS="${DS#*:}"
}

###### rotate thru directory stack (from bottom to top)
function rotd() {
   if [ "$DS" ]
   then
      typeset DSr="${DS%:*:}"
      [ "${DSr}" = "${DS}" ] || export DS="${DS##${DSr}:}$DSr:"
      flipd
   else
      echo "$0: directory stack is empty" >&2
   fi
}

###### swap top two dir stack entries
function swapd() {
   typeset DSr="${DS#*:}"
   if [ "$DSr" ]
   then
      export DS="${DSr%%:*}:${DS%%:*}:${DSr#*:}"
   else
      echo "$0: less than two on directory stack" >&2
   fi
}

if [ ! -f ${HOME}/.lastdir ];then
   cat > ${HOME}/.lastdir
fi


###############################################################################
# Tree stuff
###############################################################################
###### shows directory tree (requires 'tree': sudo apt-get install tree)
function treecd() {
   builtin cd "${@}" &>/dev/null
   . $BSNG_RC_DIR/dirinfo/display
   dirinfo_display
   echo -e "${epink}content:"
   tree -L 1 $TREE_OPTS
   echo "$PWD" > $HOME/.lastpwd
}

###### displays a tree of the arborescence
function treefind() {
   find "$@" | sed 's/[^/]*\//|   /g;s/| *\([^| ]\)/+--- \1/'
}


###############################################################################
# System Information
###############################################################################
function show_battery_load()
# copyright 2007 - 2010 Christopher Bratusek
{
   case $1 in
      *acpi )
         check_opt acpi show_battery_load::acpi
         if [[ $? != "1" ]]; then
            load=$(acpi -b | sed -e "s/.* \([1-9][0-9]*\)%.*/\1/")
            out="$(acpi -b)"
            state="$(echo "${out}" | awk '{print $3}')"
            case ${state} in
               charging,)
                  statesign="^"
               ;;
               discharging,)
                  statesign="v"
               ;;
               charged,)
                  statesign="°"
               ;;
            esac
            battery="${statesign}${load}"
            echo $battery
         fi
      ;;
      *apm )
         check_opt apm show_battery_load::apm
         if [[ $? != "1" ]]; then
            result="$(apm)"
            case ${result} in
               *'AC on'*)
                  state="^"
               ;;
               *'AC off'*)
                  state="v"
               ;;
            esac
            load="${temp##* }"
            battery="${state}${load}"
            echo $battery
         fi
      ;;
      * )
         echo -e "\n${ewhite}Usage:\n"
         echo -e "${eorange}show_battery_load${ewhite} |${egreen} --acpi${eiceblue} [show batteryload using acpi]\
         \n${eorange}show_battery_load${ewhite} |${egreen} --apm${eiceblue} [show batteryload using apm]" | column -t
         echo ""
         tput sgr0
      ;;
   esac
}



function show_cpu_load()
# copyright 2007 - 2010 Christopher Bratusek
{
   case $1 in
      *help )
         echo -e "\n${ewhite}Usage:\n"
         echo -e "${eorange}show_cpu_load${ewhite} |${egreen} ! no options !\n"
         tput sgr0
      ;;
      * )
         NICE_IGNORE=20
         t="0"
         while read cpu ni; do
            if [[ $ni == *-* || $ni -le $NICE_IGNORE ]]; then
               t="$t + $cpu"
            fi
            if [[ ${cpu%%.*} -eq 0 ]]; then
               break
            fi
         done < <(ps -o "%cpu= ni="| sort -r)
         cpu=$(echo "$t" | bc)
         if [[ ! "${cpu#.}x" = "${cpu}x" ]]; then
            cpu="0${cpu}"
         fi
         cpu=${cpu%%.*}
         if [[ $cpu -gt 100 ]]; then
            cpu=100
         fi
         if [[ $cpu -lt 16 ]]; then
            color=${eiceblue}
         elif [[ $cpu -lt 26 ]]; then
            color=${eturqoise}
         elif [[ $cpu -lt 41 ]]; then
            color=${esmoothgreen}
         elif [[ $cpu -lt 61 ]]; then
            color=${egreen}
         elif [[ $cpu -lt 81 ]]; then
            color=${eyellow}
         else   color=${ered}
         fi
         if [[ $cpu -lt 10 ]]; then
            prepend=00
         elif [[ $cpu -lt 100 ]]; then
            prepend=0
         fi
         if [[ $enabcol == true ]]; then
            echo -e "$color$prepend$cpu"
         else   echo $prepend$cpu
         fi
      ;;
   esac
}



function show_mem() {
   # copyright 2007 - 2010 Christopher Bratusek
   case $1 in
      *used )
         used=$(free -m | grep 'buffers/cache' | awk '{print $3}')
         if [[ $used -lt 1000 ]]; then
            echo 0$used
         elif [[ $used -lt 100 ]]; then
            echo 00$used
         else   echo $used
         fi
      ;;
      *free )
         free=$(free -m | grep 'buffers/cache' | awk '{print $4}')
         if [[ $free -lt 1000 ]]; then
            echo 0$free
         elif [[ $free -lt 100 ]]; then
            echo 00$ree
         else   echo $free
         fi
      ;;
      *used-percent )
         free | {
            read
            read m t u f s b c;
            f=$[$f + $b + $c]
            f=$[100-100*$f/$t]
            if [ $f -gt 100 ]; then
               f=100
            fi
            echo ${f}%
      }
      ;;
      *free-percent )
         free | {
            read
            read m t u f s b c;
            f=$[$f + $b + $c]
            f=$[100-100*$f/$t]
            if [ $f -gt 100 ]; then
               f=100
            fi
            echo $((100-${f}))%
            }
      ;;
      * )
         echo -e "\n${ewhite}Usage:\n"
         echo -e "\n${eorange}show_mem ${ewhite}|${egreen} --used ${eiceblue}[display used memory in mb]\
         \n${eorange}show_mem ${ewhite}|${egreen} --free ${eiceblue}[display free memory in mb]\
         \n${eorange}show_mem ${ewhite}|${egreen} --percent-used ${eiceblue}[display used memory in %]\
         \n${eorange}show_mem ${ewhite}|${egreen} --percent-free ${eiceblue}[display free memory in %]" | column -t
         echo ""
         tput sgr0
      ;;
   esac
}



function show_size()
# copyright 2007 - 2010 Christopher Bratusek
{
   case $1 in
      *help )
         echo -e "\n${ewhite}Usage:\n"
         echo -e "${eorange}show_size ${ewhite}|${egreen} ! no options !\n"
         tput sgr0
      ;;
      * )
         let TotalBytes=0
         for Bytes in $(ls -lA -1 | grep "^-" | awk '{ print $5 }'); do
            let TotalBytes=$TotalBytes+$Bytes
         done
         if [ $TotalBytes -lt 1024 ]; then
            TotalSize=$(echo -e "scale=1 \n$TotalBytes \nquit" | bc)
            suffix="B"
         elif [ $TotalBytes -lt 1048576 ]; then
            TotalSize=$(echo -e "scale=1 \n$TotalBytes/1024 \nquit" | bc)
            suffix="KB"
         elif [ $TotalBytes -lt 1073741824 ]; then
            TotalSize=$(echo -e "scale=1 \n$TotalBytes/1048576 \nquit" | bc)
            suffix="MB"
         else
            TotalSize=$(echo -e "scale=1 \n$TotalBytes/1073741824 \nquit" | bc)
            suffix="GB"
         fi
         echo "${TotalSize} ${suffix}"
      ;;
   esac
}



function show_space()
# copyright 2007 - 2010 Christopher Bratusek
{
   case $1 in
      *used-percent )
         echo $(df | grep -w $2 | gawk '{print $5}')
      ;;
      *free-percent )
         echo $((100-$(df | grep -w $2 | gawk '{print $5}' | sed -e 's/\%//g')))%
      ;;
      *used )
         echo $(df -h | grep -w $2 | gawk '{print $3}')B
      ;;
      *free )
         echo $(df -h | grep -w $2 | gawk '{print $4}')B
      ;;
      *total )
         echo $(df -h | grep -w $2 | gawk '{print $2}')B
      ;;
      * )
         echo -e "\n${ewhite}Usage:\n"
         echo -e "${eorange}show_space ${ewhite}|${egreen} --used ${eiceblue}[display used space in mb/gb]\
         \n${eorange}show_space ${ewhite}|${egreen} --free ${eiceblue}[display free space in mb/gb]\
         \n${eorange}show_space ${ewhite}|${egreen} --percent-used ${eiceblue}[display used space in %]\
         \n${eorange}show_space ${ewhite}|${egreen} --percent-free ${eiceblue}[display free space in %]" | column -t
         echo ""
         tput sgr0
      ;;
   esac
}

function show_system_load() {
   # copyright 2007 - 2010 Christopher Bratusek
   case $1 in
      1 )
         load=$(uptime | sed -e "s/.*load average: \(.*\...\), \(.*\...\), \(.*\...\)/\1/" -e "s/ //g")
      ;;
      10 )
         load=$(uptime | sed -e "s/.*load average: \(.*\...\), \(.*\...\), \(.*\...\)/\2/" -e "s/ //g")
      ;;
      15 )
         load=$(uptime | sed -e "s/.*load average: \(.*\...\), \(.*\...\), \(.*\...\)/\3/" -e "s/ //g")
      ;;
      *help | "")
         echo -e "\n${ewhite}Usage:\n"
         echo -e "${eorange}show_system_load${ewhite} | ${egreen}1 ${eiceblue}[load average for 1 minute]\
         \n${eorange}show_system_load${ewhite} | ${egreen}10 ${eiceblue}[load average for 10 minutes]\
         \n${eorange}show_system_load${ewhite} | ${egreen}15 ${eiceblue}[load average for 15 minutes]\n" | column -t
         tput sgr0
      ;;
   esac
   if [[ $load != "" ]]; then
   tmp=$(echo $load*100 | bc)
   load100=${tmp%.*}
   if [[ $enabcol == true ]]; then
      if [[ ${load100} -lt 35 ]]; then
         loadcolor=${eblue}
      elif [[ ${load100} -ge 35 ]] && [[ ${load100} -lt 120 ]]; then
         loadcolor=${eiceblue}
      elif [[ ${load100} -ge 120 ]] && [[ ${load100} -lt 200 ]]; then
         loadcolor=${egreen}
      elif [[ ${load100} -ge 200 ]] && [[ ${load100} -lt 300 ]]; then
         loadcolor=${eyellow}
      else   loadcolor=${ered}
      fi
   fi
   echo -e $loadcolor$load
   fi
}

function show_tty()
# copyright 2007 - 2010 Christopher Bratusek
{
   case $1 in
      *help )
         echo -e "\n${ewhite}Usage:\n"
         echo -e "${eorange}show_tty${ewhite}|${egreen} ! no options !\n"
         tput sgr0
      ;;
      * )
         TTY=$(tty)
         echo ${TTY:5} | sed -e 's/\//\:/g'
      ;;
   esac
}

function show_uptime() {
   # copyright 2007 - 2010 Christopher Bratusek
   case $1 in
      *help )
         echo -e "\n${ewhite}Usage:\n"
         echo -e "${eorange}show_uptime${ewhite} |${egreen} ! no options !\n"
         tput sgr0
      ;;
      * )
         uptime=$(</proc/uptime)
         timeused=${uptime%%.*}
         if (( timeused > 86400 )); then
         ((
            daysused=timeused/86400,
            hoursused=timeused/3600-daysused*24,
            minutesused=timeused/60-hoursused*60-daysused*60*24,
            secondsused=timeused-minutesused*60-hoursused*3600-daysused*3600*24
         ))
            if (( hoursused < 10 )); then
               hoursused=0${hoursused}
            fi
            if (( minutesused < 10 )); then
               minutesused=0${minutesused}
            fi
            if (( secondsused < 10 )); then
               secondsused=0${secondsused}
            fi
            output="${daysused}d ${hoursused}h:${minutesused}m:${secondsused}s"
         elif (( timeused < 10 )); then
            output="0d 00h:00m:0$(timeused)s"
         elif (( timeused < 60 )); then
            output="0d 00h:00m:${timeused}s"
         elif (( timeused < 3600 )); then
         ((
            minutesused=timeused/60,
            secondsused=timeused-minutesused*60
         ))
            if (( minutesused < 10 )); then
               minutesused=0${minutesused}
            fi
            if (( secondsused < 10 )); then
               secondsused=0${secondsused}
            fi
            output="0d 00h:${minutesused}m:${secondsused}s"
         elif (( timeused < 86400 )); then
         ((
            hoursused=timeused/3600,
            minutesused=timeused/60-hoursused*60,
            secondsused=timeused-minutesused*60-hoursused*3600
         ))
            if (( hoursused < 10 )); then
               hoursused=0${hoursused}
            fi
            if (( minutesused < 10 )); then
               minutesused=0${minutesused}
            fi
            if (( secondsused < 10 )); then
               secondsused=0${secondsused}
            fi
            output="0d ${hoursused}h:${minutesused}m:${secondsused}s"
         fi
         echo "$output"
      ;;
   esac
}

# copyright 2007 - 2010 Christopher Bratusek
function system_infos()
{
   case $1 in
      *cpu)
         echo -e "${ewhite}CPU:\n"
         echo -e "${eorange}Model:${eiceblue} $(grep "model name" /proc/cpuinfo | sed -e 's/.*: //g')"
         echo -e "${eorange}MHz  :${eiceblue} $(grep "cpu MHz" /proc/cpuinfo | sed -e 's/.*: //g')\n"
      ;;
      *kernel)
         echo -e "${ewhite}Kernel:\n"
         echo -e "${eorange}Release:${eiceblue} $(uname -r)"
         echo -e "${eorange}Version:${eiceblue} $(uname -v)"
         echo -e "${eorange}Machine:${eiceblue} $(uname -m)\n"
      ;;
      *mem | *ram | memory)
         echo -e "${ewhite}RAM:\n"
         echo -e "${eorange}Total:${eiceblue} $(((`showmem --free`) + (`showmem --used`))) MB"
         echo -e "${eorange}Free :${eiceblue} $(showmem --free) MB"
         echo -e "${eorange}Used :${eiceblue} $(showmem --used) MB\n"
      ;;
      *partitions)
         echo -e "${ewhite}Partitions:${eorange}\n"
         echo -e "major minor blocks device-node ${eiceblue}\
         \n$(cat /proc/partitions | sed -e '1,2d')" | column -t
         echo ""
      ;;
      *pci)
         check_opt lspci systeminfos::pci
         if [[ $? != "1" ]]; then
            echo -e "${ewhite}PCI Devices:\n${eiceblue}"
            lspci -vkmm
            echo ""
         fi
      ;;
      *usb)
         check_opt lsusb systeminfos::usb
         if [[ $? != "1" ]]; then
            echo -e "${ewhite}USB Devices:\n${eiceblue}"
            lsusb -v
            echo ""
         fi
      ;;
      *mounts)
         echo -e "${ewhite}Mounts:\n${eorange}\
         \ndevice-node on mount-point type filesystem options\n" ${eiceblue} "\n\n$(mount)" | column -t
         echo ""
      ;;
      *bios)
         check_opt dmidecode systeminfos::bios
         if [[ $? != "1" && $EUID == 0 ]]; then
            echo -e "${ewhite}SMBIOS/DMI Infos:${eiceblue}\n"
            dmidecode -q
         fi
      ;;
      *all)
         system_infos cpu
         system_infos kernel
         system_infos memory
         system_infos partitions
         system_infos pci
         # system_infos_usb
         system_infos mounts
         # system_infos_bios
      ;;
      *)
         echo -e "\n${ewhite}Usage:\n"
         echo -e "${eorange}system_infos ${ewhite}|${egreen} --cpu      ${eiceblue}[Display CPU Model and Freq]\
         \n${eorange}system_infos ${ewhite}|${egreen} --kernel   ${eiceblue}    [Display Kernel Version, Release and Machine]\
         \n${eorange}system_infos ${ewhite}|${egreen} --memory   ${eiceblue}    [Display Total, Free and Used RAM]\
         \n${eorange}system_infos ${ewhite}|${egreen} --partitions   ${eiceblue}[Display Major, Minor, Blocks and Node for all Paritions]\
         \n${eorange}system_infos ${ewhite}|${egreen} --pci      ${eiceblue}[Display Infos about all PCI Devices (and their kernel-module)]\
         \n${eorange}system_infos ${ewhite}|${egreen} --usb      ${eiceblue}[Display Infos about all USB Devices (and their kernel-module)]\
         \n${eorange}system_infos ${ewhite}|${egreen} --bios   ${eiceblue}    [Display SMBIOS DMI Infos]\
         \n${eorange}system_infos ${ewhite}|${egreen} --mounts   ${eiceblue}    [Display all mounted devices]\n"
         tput sgr0
      ;;
   esac
}

###############################################################################
# Process Management
###############################################################################
###### Kill a process by name
# example: killps firefox-bin
function killps()
{
    local pid pname sig="-TERM" # default signal
    if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
      echo "Usage: killps [-SIGNAL] pattern"
      return;
    fi
    if [ $# = 2 ]; then sig=$1 ; fi
    for pid in $(myps | nawk '!/nawk/ && $0~pat { print $2 }' pat=${!#}) ; do
      pname=$(myps | nawk '$2~var { print $6 }' var=$pid )
      if ask "Kill process $pid <$pname> with signal $sig ? "
         then kill $sig $pid
      fi
    done
}


###### Count processes that are running
# copyright 2007 - 2010 Christopher Bratusek
function count_processes()
{
   case $1 in
      *help )
         echo -e "\n${ewhite}Usage:"
         echo -e "\n${eorange}count_processes${ewhite} | ${egreen}! no options !\n"
         tput sgr0
      ;;
      * )
         procs=$(ps ax | wc -l | awk '{print $1}')
         if [[ $procs -lt 10 ]]; then
            echo "000$procs"
         elif [[ $procs -lt 100 ]]; then
            echo "00$procs"
         elif [[ $procs -lt 1000 ]]; then
            echo "0$procs"
         fi
      ;;
   esac
}


###############################################################################
# Terminal functions
###############################################################################
###### Example: batchexec sh ls      # lists all files that have the extension 'sh'
# Example: batchexec sh chmod 755   # 'chmod 755' all files that have the extension 'sh'
function batchexec()
{
   find . -type f -iname '*.'${1}'' -exec ${@:2}  {} \; ;
}

##### Temporarily add to PATH
function apath()
{
   if [ $# -lt 1 ] || [ $# -gt 2 ]; then
      echo "Temporarily add to PATH"
      echo "usage: apath [dir]"
   else
      PATH=$1:$PATH
   fi
}

##### Function you want after you've overwritten some important file using > instead of >> ^^
function append() {
   lastarg="${!#}"
   echo "${@:1:$(($#-1))}" >> "$lastarg"
}

###### center text in console with simple pipe like
function align_center() {
   l="$(cat -)"; s=$(echo -e "$l"| wc -L); echo "$l" | while read l;do j=$(((s-${#l})/2));echo "$(while ((--j>0)); do printf " ";done;)$l";done;
} #; ls --color=none / | center

###### right-align text in console using pipe like ( command | right )
function align_right() {
   l="$(cat -)"; [ -n "$1" ] && s=$1 || s=$(echo -e "$l"| wc -L); echo "$l" | while read l;do j=$(((s-${#l})));echo "$(while ((j-->0)); do printf " ";done;)$l";done;
} #; ls --color=none / | right 150

###### Set terminal title
function terminal_title {
    echo -en "\033]2;$@\007"
}

###### Adds some text in the terminal frame
function xtitle()
{
    case "$TERM" in
   *term | rxvt)
       echo -n -e "\033]0;$*\007" ;;
   *)
       ;;
    esac
}

###### Open a GUI app from CLI
function open() {
   $1 >/dev/null 2>&1 &
}

###### Super stealth background launch
function daemon()
{
    (exec "$@" >&/dev/null &)
}

###### Shell function to exit script with error in exit status and print optional message to stderr
function die() { 
   result=$1;shift;[ -n "$*" ]&&printf "%s\n" "$*" >&2;exit $result;
}

###### Run a command, redirecting output to a file, then edit the file with vim
function vimcmd() { 
   $1 > $2 && vim $2;
}

###### Ask
function ask()
{
    echo -n "$@" '[y/n] ' ; read ans
    case "$ans" in
      y*|Y*) return 0 ;;
      *) return 1 ;;
    esac
}

###### Repeats a command every x seconds   
# Usage: repeat PERIOD COMMAND
function repeat() {
    local period
    period=$1; shift;
    while (true); do
   eval "$@";
    sleep $period;
    done
}

###### Function that outputs dots every second until command completes
function progress() { 
   while `ps -p $1 &>/dev/null`; do echo -n "${2:-.}"; sleep ${3:-1}; done; 
}

function progressbar()
# copyright 2007 - 2010 Christopher Bratusek
{
   SP_COLOUR="\e[37;44m"
   SP_WIDTH=5.5
   SP_DELAY=0.2
   SP_STRING=${2:-"'|/=\'"}
   while [ -d /proc/$1 ]
   do
      printf "$SP_COLOUR\e7  %${SP_WIDTH}s  \e8\e[01;37m" "$SP_STRING"
      sleep ${SP_DELAY:-.2}
      SP_STRING=${SP_STRING#"${SP_STRING%?}"}${SP_STRING%?}
   done
   tput sgr0
}

###### please wait...
# copyright 2007 - 2010 Christopher Bratusek
function spanner() {
   PROC=$1;COUNT=0
   echo -n "Please wait "
   while [ -d /proc/$PROC ];do
      while [ "$COUNT" -lt 10 ];do
         echo -ne '\x08  ' ; sleep 0.1
         ((COUNT++))
      done
      until [ "$COUNT" -eq 0 ];do
         echo -ne '\x08\x08 ' ; sleep 0.1
         ((COUNT -= 1))
      done
   done
}

function spin() {
   # copyright 2007 - 2010 Christopher Bratusek
   echo -n "|/     |"
   while [ -d /proc/$1 ]
   do
   # moving right
   echo -ne "\b\b\b\b\b\b\b-     |"
   sleep .05
   echo -ne "\b\b\b\b\b\b\b\\     |"
   sleep .05
   echo -ne "\b\b\b\b\b\b\b|     |"
   sleep .05
   echo -ne "\b\b\b\b\b\b\b /    |"
   sleep .05
   echo -ne "\b\b\b\b\b\b-    |"
   sleep .05
   echo -ne "\b\b\b\b\b\b\\    |"
   sleep .05
   echo -ne "\b\b\b\b\b\b|    |"
   sleep .05
   echo -ne "\b\b\b\b\b\b /   |"
   sleep .05
   echo -ne "\b\b\b\b\b-   |"
   sleep .05
   echo -ne "\b\b\b\b\b\\   |"
   sleep .05
   echo -ne "\b\b\b\b\b|   |"
   sleep .05
   echo -ne "\b\b\b\b\b /  |"
   sleep .05
   echo -ne "\b\b\b\b-  |"
   sleep .05
   echo -ne "\b\b\b\b\\  |"
   sleep .05
   echo -ne "\b\b\b\b|  |"
   sleep .05
   echo -ne "\b\b\b\b / |"
   sleep .05
   echo -ne "\b\b\b- |"
   sleep .05
   echo -ne "\b\b\b\\ |"
   sleep .05
   echo -ne "\b\b\b| |"
   sleep .05
   echo -ne "\b\b\b /|"
   sleep .05
   echo -ne "\b\b-|"
   sleep .05
   echo -ne "\b\b\\|"
   sleep .05
   echo -ne "\b\b||"
   sleep .05
   echo -ne "\b\b/|"
   sleep .05
   # moving left
   echo -ne "\b\b||"
   sleep .05
   echo -ne "\b\b\\|"
   sleep .05
   echo -ne "\b\b-|"
   sleep .05
   echo -ne "\b\b\b/ |"
   sleep .05
   echo -ne "\b\b\b| |"
   sleep .05
   echo -ne "\b\b\b\\ |"
   sleep .05
   echo -ne "\b\b\b- |"
   sleep .05
   echo -ne "\b\b\b\b/  |"
   sleep .05
   echo -ne "\b\b\b\b|  |"
   sleep .05
   echo -ne "\b\b\b\b\\  |"
   sleep .05
   echo -ne "\b\b\b\b-  |"
   sleep .05
   echo -ne "\b\b\b\b\b/   |"
   sleep .05
   echo -ne "\b\b\b\b\b|   |"
   sleep .05
   echo -ne "\b\b\b\b\b\\   |"
   sleep .05
   echo -ne "\b\b\b\b\b-   |"
   sleep .05
   echo -ne "\b\b\b\b\b\b/    |"
   sleep .05
   echo -ne "\b\b\b\b\b\b|    |"
   sleep .05
   echo -ne "\b\b\b\b\b\b\\    |"
   sleep .05
   echo -ne "\b\b\b\b\b\b-    |"
   sleep .05
   echo -ne "\b\b\b\b\b\b\b/     |"
   sleep .05
   done
   echo -e "\b\b\b\b\b\b\b\b\b|=======| done!"
}

function spinner()
# copyright 2007 - 2010 Christopher Bratusek
{
   PROC=$1
   while [ -d /proc/$PROC ];do
      echo -ne '\e[01;32m/\x08' ; sleep 0.05
      echo -ne '\e[01;32m-\x08' ; sleep 0.05
      echo -ne '\e[01;32m\\\x08' ; sleep 0.05
      echo -ne '\e[01;32m|\x08' ; sleep 0.05
   done
}

###### Display a progress process
# To start the spinner2 function, you have to send the function
# into the background. To stop the spinner2 function, you have
# to define the argument "stop".
# EXAMPLE:
#    echo -n "Starting some daemon "; spinner2 &
#    if sleep 10; then
#       spinner2 "stop"; echo -e "   [ OK ]"
#    else
#       spinner2 "stop"; echo -e "   [ FAILED ]"
#    fi
function spinner2() {
      local action=${1:-"start"}
      declare -a sign=( "-" "/" "|" "\\\\" )
      # define singnal file...
      [ "$action" = "start" ] && echo 1 > /tmp/signal
      [ "$action" = "stop" ] && echo 0 > /tmp/signal
      while [ "$( cat /tmp/signal 2>/dev/null )" == "1" ] ; do
     for (( i=0; i<${#sign[@]}; i++ )); do
         echo -en "${sign[$i]}\b"
         # with this command you can use millisecond as sleep time - perl rules ;-)
         perl -e 'select( undef, undef, undef, 0.1 );'
     done
      done
      # clear the last ${sign[$i]} sign at finish...
      [ "$action" = "stop" ] && echo -ne " \b"
}

function sh_colormsg()
{
   [ -n "$1" ] && echo -en "${fg_bold}${@}${reset_color}"
}

function sh_error()
{
   echo -e "${fg_bold}[ e ]${reset_color} $@"
}

function sh_info()
{
   echo -e "${fg_bold}[ i ]${reset_color} $@"
}

function sh_success()
{
   echo -e "${fg_bold}[ k ]${reset_color} $@"
}

function sh_mesg()
{
   echo -e "${fg_bold}[ m ]${reset_color} $@"
}

###### Extract a particular column of space-separated output
# e.g.: lsof | getcolumn 0 | sort | uniq
function getcolumn() { 
   perl -ne '@cols = split; print "$cols['$1']\n"' ;
}

###### Surround lines with quotes (useful in pipes) - from mervTormel
function enquote() { /usr/bin/sed 's/^/"/;s/$/"/' ; }

###### Determining the meaning of error codes
function err()
{
    grep --recursive --color=auto --recursive -- "$@" /usr/include/*/errno.h
    if [ "${?}" != 0 ]; then
      echo "Not found."
    fi
}

###### print all 256 colors for testing TERM or for a quick reference
# show numerical values for each of the 256 colors in bash
function colors2nums()
{
   for code in {0..255}; do echo -e "\e[38;05;${code}m $code: Test"; done
}


###### takes a name of a color and some text and then echoes out the text in the named color
# Usage:   colorize_text "color" "whatever text"
function colorize-text()
{
   b='[0;30m'
   # Implement command-line options
   while getopts "nr" opt
   do
      case $opt in
         n  )  o='-n' ;;
         r  )  b=''   ;;
      esac
   done
   shift $(($OPTIND - 1))
   # Set variables
   col=$1
   shift
   text="$*"
   # Set a to console color code
   case $col in
       'black'  ) a='[0;30m' ;;
       'blue'   ) a='[0;34m' ;;
       'green'  ) a='[0;32m' ;;
       'cyan'   ) a='[0;36m' ;;
       'red'    ) a='[0;31m' ;;
       'purple' ) a='[0;35m' ;;
       'brown'  ) a='[0;33m' ;;
       'ltgray' ) a='[0;37m' ;;
       'white'  ) a='[1;30m' ;;
       'ltblue' ) a='[1;34m' ;;
       'ltgreen') a='[1;32m' ;;
       'ltcyan' ) a='[1;36m' ;;
       'ltred'  ) a='[1;31m' ;;
       'pink'   ) a='[1;35m' ;;
       'yellow' ) a='[1;33m' ;;
       'gray'   ) a='[1;37m' ;;
   esac
   # Display text in designated color, no newline
   echo -en "\033$a$text"
   # If 'b' switch not on, restore color to black
   if [ -n $b ]
   then
      echo -en "\033$b"
   fi
   # If 'n' switch on, do not display final newline
   # otherwise output newline
   echo $o   
}

###### displays all 256 possible background colors, using ANSI escape sequences.
# author: Chetankumar Phulpagare
# used in ABS Guide with permission.
function colors2()
{
   T1=8
   T2=6
   T3=36
   offset=0
   for num1 in {0..7}
   do {
      for num2 in {0,1}
         do {
        shownum=`echo "$offset + $T1 * ${num2} + $num1" | bc`
        echo -en "\E[0;48;5;${shownum}m color ${shownum} \E[0m"
        }
         done
      echo
      }
   done
   offset=16
   for num1 in {0..5}
   do {
      for num2 in {0..5}
         do {
        for num3 in {0..5}
           do {
              shownum=`echo "$offset + $T2 * ${num3} \
              + $num2 + $T3 * ${num1}" | bc`
              echo -en "\E[0;48;5;${shownum}m color ${shownum} \E[0m"
              }
            done
        echo
        }
         done
   }
   done
   offset=232
   for num1 in {0..23}
   do {
      shownum=`expr $offset + $num1`
      echo -en "\E[0;48;5;${shownum}m ${shownum}\E[0m"
   }
   done
   echo
}

###############################################################################
# Bash History
###############################################################################
###### hgrep, hgrepl 
function hgrepl() {
    if [ $# -lt 1 ] || [ $# -gt 1 ]; then
      echo "search bash history"
      echo "usage: hgrepl [search pattern]"
    else
      history | sed s/.*\ \ // | grep $@
   fi
}

function hgrep() {
    if [ $# -lt 1 ] || [ $# -gt 1 ]; then
      echo "search bash history"
      echo "usage: hgrep [search pattern]"
    else
      history | sed s/.*\ \ // | grep $@ | tail -n 30
   fi
}

function hhgrep() {
    if [ $# -lt 1 ] || [ $# -gt 1 ]; then
      echo "search bash history"
      echo "usage: hhgrep [search pattern]"
    else
      history | egrep "$@" | egrep -v "hgrep $@"
   fi
}

###### Analyze your bash usage
function histtop()
{
   cut -f1 -d" " .bash_history | sort | uniq -c | sort -nr | head -n 30
}

###### Edit your history file
function he() {
   history -a ; vi ~/.bash_history ; history -r ;
}

###############################################################################
# Common commands piped through grep
###############################################################################
###### grep by paragraph instead of by line
function grepp() { [ $# -eq 1 ] && perl -00ne "print if /$1/i" || perl -00ne "print if /$1/i" < "$2";}

function lsofg()
{
    if [ $# -lt 1 ] || [ $# -gt 1 ]; then
      echo "grep lsof"
      echo "usage: losfg [port/program/whatever]"
    else
      lsof | grep -i $1 | less
    fi
}

function psg()
{
    if [ $# -lt 1 ] || [ $# -gt 1 ]; then
      echo "grep running processes"
      echo "usage: psg [process]"
    else
      ps aux | grep USER | grep -v grep
      ps aux | grep -i $1 | grep -v grep
    fi
}

###############################################################################
# Archiving
###############################################################################
###### Roll - archive wrapper
# usage: roll <foo.tar.gz> ./foo ./bar
function roll()
{
  FILE=$1
  case $FILE in
    *.tar.bz2) shift && tar cjf $FILE $* ;;
    *.tar.gz) shift && tar czf $FILE $* ;;
    *.tgz) shift && tar czf $FILE $* ;;
    *.zip) shift && zip $FILE $* ;;
    *.rar) shift && rar $FILE $* ;;
  esac
}

###### Pull a single file out of a .tar.gz
function pullout() {
   if [ $# -ne 2 ]; then
      echo "need proper arguments:"
      echo "pullout [file] [archive.tar.gz]"
      return 1
   fi
   case $2 in
      *.tar.gz|*.tgz)
         gunzip < $2 | tar -xf - $1
         ;;
      *)
         echo $2 is not a valid archive
         return 1
         ;;
      esac
   return 0
}

###### Creates an archive from directory
function mktar() { tar cvf  "${1%%/}-`date +%Y%m%d`.tar"     "${1%%/}/"; }
function mktbz() { tar cvjf "${1%%/}-`date +%Y%m%d`.tar.bz2" "${1%%/}/"; }
function mktgz() { tar cvzf "${1%%/}-`date +%Y%m%d`.tar.gz"  "${1%%/}/"; }
function mkzip() { zip -r "$1"-`date +%Y%m%d`.zip "$1" ; }

######  Escape potential tarbombs
function atb() { l=$(tar tf $1); if [ $(echo "$l" | wc -l) -eq $(echo "$l" | grep $(echo "$l" | head -n1) | wc -l) ]; then tar xf $1; else mkdir ${1%.tar.gz} && tar xf $1 -C ${1%.tar.gz}; fi ; }

###### Extract - extract most common compression types
function extract() {
   local e=0 i c
   for i; do
      if [[ -f $i && -r $i ]]; then
      c=''
      case $i in
         #*.t@(gz|lz|xz|b@(2|z?(2))|a@(z|r?(.@(Z|bz?(2)|gz|lzma|xz)))))
         #       c='bsdtar xvf' ;;
         *.7z)  c='7z x'       ;;
         *.Z)   c='uncompress' ;;
         *.bz2) c='bunzip2'    ;;
         *.exe) c='cabextract' ;;
         *.gz)  c='gunzip'     ;;
         *.rar) c='unrar x'    ;;
         *.xz)  c='unxz'       ;;
         *.zip) c='unzip'      ;;
         *)     echo "$0: cannot extract \`$i': Unrecognized file extension" >&2; e=1 ;;
      esac
      [[ $c ]] && command $c "$i"
      else
         echo "$0: cannot extract \`$i': File is unreadable" >&2; e=2
      fi
   done
   return $e
}

###### Sets the compression level for file-roller
function compression_level()
{
   echo -n "Please enter the number for the desired compression level for file-roller:

   (1) very_fast
   (2) fast
   (3) normal
   (4) maximum

   Press 'Enter' for default (default is '3')...

   "
   read COMPRESSION_LEVEL_NUMBER
   # extra blank space
   echo "
   "
   # default
   if [[ -z $COMPRESSION_LEVEL_NUMBER ]] ; then
   # If no COMPRESSION_LEVEL passed, default to '3'
      COMPRESSION_LEVEL=normal
   fi
   # preset
   if [[ $COMPRESSION_LEVEL_NUMBER = 1 ]] ; then
      COMPRESSION_LEVEL=very_fast
   fi
   if [[ $COMPRESSION_LEVEL_NUMBER = 2 ]] ; then
      COMPRESSION_LEVEL=fast
   fi
   if [[ $COMPRESSION_LEVEL_NUMBER = 3 ]] ; then
      COMPRESSION_LEVEL=normal
   fi
   if [[ $COMPRESSION_LEVEL_NUMBER = 4 ]] ; then
      COMPRESSION_LEVEL=maximum
   fi

   gconftool-2 --set /apps/file-roller/general/compression_level --type string "$COMPRESSION_LEVEL"
}

###############################################################################
# Uppercase, lowercase, & cleanup strings & names
###############################################################################
###### Convert the first letter into lowercase letters
function lcfirst() {
      if [ -n "$1" ]; then
     perl -e 'print lcfirst('$1')'
      else
     cat - | perl -ne 'print lcfirst($_)'
      fi
}


###### Remove whitespace at the beginning of a string
#  @param string $1 string (optional, can also handle STDIN)
#  @return string
#  @example:    echo " That is a sentinece " | trim
function ltrim() {
      if [ -n "$1" ]; then
         echo $1 | sed 's/^[[:space:]]*//g'
      else
         cat - | sed 's/^[[:space:]]*//g'
      fi
}

###### Remove whitespace at the end of a string
#  @param string $1 string (optional, can also handle STDIN)
#  @return string
#  @example:    echo "That is a sentinece " | rtrim
function rtrim() {
      if [ -n "$1" ]; then
         echo $1 | sed 's/[[:space:]]*$//g'
      else
         cat - | sed 's/[[:space:]]*$//g'
      fi
}

###### Cut a string after X chars and append three points
# string strim( string string [, int length ] )
function strim() {
      local string="$1"
      local length=${2:-30}
      [ "${#string}" -gt ${length} ] && string="${string:0:${length}}..."
      echo $string
}

###### Convert all alphabetic characters to lowercase
#  @param string $1|STDIN string
#  @return string
function strtolower() {
      if [ -n "$1" ]; then
         echo $1 | tr '[:upper:]' '[:lower:]'
      else
         cat - | tr '[:upper:]' '[:lower:]'
      fi
}

###### Convert all alphabetic characters converted to uppercase
#  @param string $1|STDIN string
#  @return string
function strtoupper() {
      if [ -n "$1" ]; then
         echo $1 | tr '[:lower:]' '[:upper:]'
      else
         cat - | tr '[:lower:]' '[:upper:]'
      fi
}

###### Remove whitespace at the beginning and end of a string
#  @param string $1 string (optional, can also handle STDIN)
#  @return string
#  @example:    echo " That is a sentinece " | trim
function trim() {
      if [ -n "$1" ]; then
         echo $1 | sed 's/^[[:space:]]*//g' | sed 's/[[:space:]]*$//g'
      else
         cat - | sed 's/^[[:space:]]*//g' | sed 's/[[:space:]]*$//g'
      fi
}

###### Convert the first letter into uppercase letters
function ucfirst() {
      if [ -n "$1" ]; then
     perl -e 'print ucfirst('$1')'
      else
     cat - | perl -ne 'print ucfirst($_)'
      fi
}

###### Converts first letter of each word within a string into an uppercase, all other to lowercase
# string ucwords( string string )
function ucwords() {
      local string="$*"
      for word in $string; do
        # Get the first character with cut and convert them into uppercase.
        local first="$( echo $word | cut -c1 | tr '[:lower:]' '[:upper:]' )"
        # Convert the rest of the word into lowercase and append them to the first character.
        word="$first$( echo $word | cut -c2-${#word} | tr '[:upper:]' '[:lower:]' )"
        # Put together the sentence.
        local phrase="$phrase $word"
      done
      echo "$phrase"
}

###############################################################################
# Find a file(s) ...
###############################################################################
###### ... with pattern $1 in name and Execute $2 on it
function find_execute() { find . -type f -iname '*'$1'*' -exec "${2:-file}" {} \;  ; }
alias fe='find_execute'

###### ... under the current directory
function find_current() { /usr/bin/find . -name "$@" ; }
alias fc='find_current'

###### ... whose name ends with a given string
function find_endswith() { /usr/bin/find . -name '*'"$@" ; }
alias fe='find_endswith'

###### ... whose name starts with a given string
function find_startwith() { /usr/bin/find . -name "$@"'*' ; }
alias fs='find_startwith'

###### ... larger than a certain size (in bytes)
function find_larger() { find . -type f -size +${1}c ; }
alias fl='find_larger'

###### find a file with a pattern in name in the local directory
function find_pattern()   { find . -type f -iname '*'$*'*' -ls ; }
alias fp='find_pattern'

###### Find in file and ( AND relation )       #
# Will search PWD for text files that contain $1 AND $2 AND $3 etc...
# Actually it does the same as grep word1|grep word2|grep word3 etc, but in a more elegant way.
function find_and() { (($# < 2)) && { echo "usage: ffa pat1 pat2 [...]" >&2; return 1; };awk "/$1/$(printf "&&/%s/" "${@:2}")"'{ print FILENAME ":" $0 }' *; }
alias ffa='find_and'

###### to grep through files found by find, e.g. grepf pattern '*.c'
# note that 'grep -r pattern dir_name' is an alternative if want all files
function grepfind() { find . -type f -name "$2" -print0 | xargs -0 grep "$1" ; }

###### find pattern in a set of files and highlight them
function fstr()
{
    OPTIND=1
    local case=""
    local usage="fstr: find string in files.
   Usage: fstr [-i] \"pattern\" [\"filename pattern\"] "
    while getopts :it opt
    do
      case "$opt" in
         i) case="-i " ;;
         *) echo "$usage"; return;;
         esac
    done
    shift $(( $OPTIND - 1 ))
    if [ "$#" -lt 1 ]; then
      echo "$usage"
      return;
    fi
    local SMSO=$(tput smso)
    local RMSO=$(tput rmso)
    find . -type f -name "${2:-*}" -print0 | xargs -0 grep -sn ${case} "$1" 2>&- | \
   sed "s/$1/${SMSO}\0${RMSO}/gI" | more
}

###### searches through the text of all the files in your current directory
# http://seanp2k.com/?p=13
# Good for debugging a PHP script you didn't write and can't trackdown where MySQL connect string actually is
function grip() {
   grep -ir "$1" "$PWD"
}

###### ... who is the newest file in a directory
function newest() { find ${1:-\.} -type f |xargs ls -lrt ; }

###############################################################################
# File Edit and File Info
###############################################################################
###### Echo the lines of a file preceded by line   number
function numLines() { 
   perl -pe 's/^/$. /' "$@" ;
}

###### How many pages will my text files print on?
function numpages() { 
   echo $(($(wc -l $* | sed -n 's/ total$//p')/60));
}

###### Computes most frequent used words of text file
# usage:   most_frequent "file.txt"
function most_frequent()
{
   cat "$1" | tr -cs "[:alnum:]" "\n"| tr "[:lower:]" "[:upper:]" | awk '{h[$1]++}END{for (i in h){print h[i]" "i}}'|sort -nr | cat -n | head -n 30
}

###### Wordcount counts frequency of words in a file
function wordfreq()
{
   cat "$1"|tr -d '[:punct:]'|tr '[:upper:]' '[:lower:]'|tr -s ' ' '\n'|sort|uniq -c|sort -rn
}

###### word counter
# counts words in selection and displays result in zenity window
# dependencies xsel, wc, zenity
function numWords()
{
   text=$(xsel)
   words=$(wc -w <<<$text)
   zenity --info --title "Word Count" --text "Words in selection:\n${words}\n\n\"${text}\""
}


###### Show the contents of a file, including additional useful info
function showfile()
{
   width=72
   for input
   do
   lines="$(wc -l < $input | sed 's/ //g')"
   chars="$(wc -c < $input | sed 's/ //g')"
   owner="$(ls -ld $input | awk '{print $3}')"
   echo "-----------------------------------------------------------------"
   echo "File $input ($lines lines, $chars characters, owned by $owner):"
   echo "-----------------------------------------------------------------"
   while read line
      do
         if [ ${#line} -gt $width ] ; then
            echo "$line" | fmt | sed -e '1s/^/  /' -e '2,$s/^/+ /'
         else
            echo "  $line"
         fi
      done < $input
      echo "-----------------------------------------------------------------"
   done | more
}

###### Search and replace words/phrases from text file
# usage:   searchnreplace "whatever oldtext" "whatever newtext" "file(s) to act on"
function searchnreplace()
{
   # Store old text and new text in variables
   old=$1;
   new=$2;
   # Shift positional parameters to places to left (get rid of old and
   # new from command line)
   shift;
   shift;
   # Store list of files as a variable
   files=$@;
   a='';
   for a in $files
   do
      temp=$(echo "/tmp/$LOGNAME-$a");
      # echo "$temp";
      echo -n ".";
      sed -e "s/$old/$new/g" $a > $temp;
      mv $temp $a;
   done
   echo;
   echo -e "Searched $# files for '$old' and replaced with '$new'";
}

###### Make a backup before editing a file
function safeedit() {
   cp $1 ${1}.backup && vim $1
}

###### sort lines in a text file
function linesort()
{
   sort -u "$1" > "$1".new
}

###### remove duplicate lines in a file (without resorting)
function removeduplines()
{
   awk '!x[$0]++' "$1" > "$1".new
}

###### Edit files in place to ensure Unix line-endings
function fixlines() {
   /usr/bin/perl -pi~ -e 's/\r\n?/\n/g' "$@" ;
}
   
###### finds all functions defined in any shell script secified, including .bashrc
function functions() { 
   read -p $1; sort -d $REPLY | grep "() {" | sed -e 's/() {//g' | less;
}

###############################################################################
# File Properties manipulation
###############################################################################
###### Changes spaces to underscores in names
function underscore()
{
   for f in * ; do
       [ "${f}" != "${f// /_}" ]
      mv -- "${f}" "${f// /_}"
   done
}

###### move filenames to lowercase
function lcfiles()
{
    for file ; do
      filename=${file##*/}
      case "$filename" in
         */*) dirname==${file%/*} ;;
         *) dirname=.;;
         esac
         nf=$(echo $filename | tr A-Z a-z)
         newname="${dirname}/${nf}"
      if [ "$nf" != "$filename" ]; then
         mv "$file" "$newname"
         echo "lowercase: $file --> $newname"
      else
         echo "lowercase: $file not changed."
      fi
    done
}

###### lowercase all files in the current directory
function lcdir() {
   print -n 'Really lowercase all files? (y/n) '
   if read -q ; then
      for i in * ; do
         mv $i $i:l
   done
   fi
}


###### Moves specified files to ~/.Trash. Will not overwrite files that have the same name
function trashit()
{   local trash_dir=$HOME/.Trash
    for file in "$@" ; do
   if [[ -d $file ]] ; then
       local already_trashed=$trash_dir/`basename $file`
       if [[ -n `/bin/ls -d $already_trashed*` ]] ; then
           local count=`/bin/ls -d $already_trashed* | /usr/bin/wc -l`
           count=$((++count))
           /bin/mv --verbose "$file" "$trash_dir/$file$count"
           continue
       fi
   fi
   /bin/mv --verbose --backup=numbered "$file" $HOME/.Trash
    done
}

###### Swap 2 filenames around (from Uzi's bashrc)
function swap()
{
    local TMPFILE=tmp.$$
    [ $# -ne 2 ] && echo "swap: 2 arguments needed" && return 1
    [ ! -e $1 ] && echo "swap: $1 does not exist" && return 1
    [ ! -e $2 ] && echo "swap: $2 does not exist" && return 1
    mv "$1" $TMPFILE
    mv "$2" "$1"
    mv $TMPFILE "$2"
}

###### Swap 2 filenames around
function swap2() {
   if [ -f "$1" -a -f "$2" ]; then mv "$1" "$1.$$" && mv "$2" "$1" && mv "$1.$$" "$2" && echo "Success"; else echo "Fail"; fi;
}

###### Count total number of subdirectories in current directory starting with specific name.
function subdir_find()
{
   find . -type d -name "*$1*" | wc -l
}

######  Sanitize - set file/directory owner and permissions to normal values (644/755)
# usage: sanitize <file>
function sanitize()
{
   chmod -R u=rwX,go=rX "$@"
   chown -R ${USER}:users "$@"
}

###### ShowTimes: show the modification, metadata-change, and access times of a file
function showTimes() { stat -f "%N:   %m %c %a" "$@" ; }

##### Ownership Changes { own file user }
function own() { 
   chown -R "$2":"$2" ${1:-.};
}

###### Set permissions to "standard" values (644/755), recursive
# Usage: resetp
function resetp() {
    chmod -R u=rwX,go=rX "$@"
}

###### Delete function
function del()
{
    mv "$@" "/${HOME}/.local/share/Trash/files/"
}

######  Log rm commands
function rm() {
   workingdir=$( pwdx $$ | awk '{print $2}' ) 
   /usr/bin/rm $*
   echo "rm $* issued at $(date) by the user $(who am i| awk '{print $1} ') in the directory ${workingdir}"  >> /tmp/rm.out ; 
}

###### Show all strings (ASCII & Unicode) in a file    #
function allStrings() { cat "$1" | tr -d "\0" | strings ; }

###############################################################################
# Backup
###############################################################################
######  Backup .bash* files
function bak-bashfiles()
{
   ARCHIVE="$HOME/bash_dotfiles_$(date +%Y%m%d%H%M%S).tar.gz";
   cd ~
   tar -czvf $ARCHIVE .bash_profile .bashrc .bash_functions .bash_aliases .bash_prompt
   echo "All backed up in $ARCHIVE";
}
alias=""

###### Creates a backup of the file passed as parameter with the date and time
function bak()
{
    if [ $# -lt 1 ] || [ $# -gt 1 ]; then
      echo "Creates a backup of the file passed as parameter with the date and time"
      echo "usage: bak [filename]"
    else
      cp $1 ${1}-`date +%Y%m%d%H%M`.backup
    fi
}

###############################################################################
# Wipe and Secure Delete
###############################################################################
###### Overwrite a file with zeros
function zero() {
   case "$1" in
           "")     echo "Usage: zero <file>"

                   return -1;
   esac
   filesize=`wc -c  "$1" | awk '{print $1}'`
   `dd if=/dev/zero of=$1 count=$filesize bs=1`
}

###############################################################################
# Passwording
###############################################################################
###### fake name and pass
function fakepass()
{
   local l=8
   [ -n "$1" ] && l=$1
   dd if=/dev/random count=1 2> /dev/null | uuencode -m - | head -n 2 | tail -n 1 | cut -c $l
}

###### generate a random password
#   $1 = number of characters; defaults to 32
#   $2 = include special characters; 1 = yes, 0 = no; defaults to 1
# copyright 2007 - 2010 Christopher Bratusek
function randompw() {
   if [[ $2 == "!" ]]; then
      echo $(cat /dev/random | tr -cd '[:graph:]' | head -c ${1:-32})
   else
      echo $(cat /dev/random | tr -cd '[:alnum:]' | head -c ${1:-32})
   fi
}

###### generate a unique and secure password for every website that you login to
function sitepass() {
   echo -n "$@" |  md5sum | sha1sum | sha224sum | sha256sum | sha384sum | sha512sum | gzip - | strings -n 1 | tr -d "[:space:]"  | tr -s '[:print:]' | tr '!-~' 'P-~!-O' | rev | cut -b 2-11; history -d $(($HISTCMD-1));
}

###### generates a unique and secure password with SALT for every website that you login to
function sitepass2()
{
   salt="this_salt";pass=`echo -n "$@"`;for i in {1..500};do pass=`echo -n $pass$salt|sha512sum`;done;echo$pass|gzip -|strings -n 1|tr -d "[:space:]"|tr -s '[:print:]' |tr '!-~' 'P-~!-O'|rev|cut -b 2-15;history -d $(($HISTCMD-1));
}

###############################################################################
# Encryption / decryption
###############################################################################
###### More advanced encryption / decryption
# example: "encrypt filename" or "decrypt filename"
function encrypt()
{
   # Author: Martin Langasek <cz4160@gmail.com>
   case $LANG in
     * )
      err_title="Error"
      err_files="No file selected"
      encrypt="Encrypt"
      decrypt="Decrypt"
      file_msg="file:"
      pass_msg="Enter passphrase";;
   esac
   if [ "$1" != "" ]
   then
     i=1
     file=`echo "$1" | sed ''$i'!d'`
     while [ "$file" != "" ]
     do
      ext=`echo "$file" | grep [.]gpg$ 2>&1`
      if [ "$ext" != "" ]
      then
        pass_decrypt=`zenity --entry --entry-text "$pass_decrypt" --hide-text --title "$pass_msg" --text "$decrypt $file_msg ${file##*/}" "" 2>&1`
        if [ "$pass_decrypt" != "" ]
        then
      output=${file%.*}
      echo "$pass_decrypt" | gpg -o "$output" --batch --passphrase-fd 0 -d "$file"
        fi
      else
        pass_encrypt=`zenity --entry --hide-text --entry-text "$pass_encrypt" --title "$pass_msg" --text "$encrypt $file_msg ${file##*/}" "" 2>&1`
        if [ "$pass_encrypt" != "" ]
        then
      echo "$pass_encrypt" | gpg --batch --passphrase-fd 0 --cipher-algo aes256 -c "$file"
        fi
      fi
      i=$(($i+1))
      file=`echo "$1" | sed ''$i'!d'`
     done
   else
     zenity --error --title "$err_title" --text "$err_files"
   fi
}

alias decrypt='encrypt'

###### rot13 ("rotate alphabet 13 places" Caesar-cypher encryption)
function rot13()
{
    if [ $# -lt 1 ] || [ $# -gt 1 ]; then
      echo "Seriously?  You don't know what rot13 does?"
    else
      echo $@ | tr A-Za-z N-ZA-Mn-za-m
    fi
}



###### rot47 ("rotate ASCII characters from '!" to '~' 47 places" Caesar-cypher encryption)
function rot47()
{
    if [ $# -lt 1 ] || [ $# -gt 1 ]; then
      echo "Seriously?  You don't know what rot47 does?"
    else
      echo $@ | tr '!-~' 'P-~!-O'
    fi
}

###############################################################################
# OpenPGP/GPG pubkeys stuff (for Launchpad / etc.
###############################################################################

###### to export public OpenPGP keys to a file for safe keeping and potential restoration
alias exportmykeys='exportmykeys_private && exportmykeys_public'

###### to export private OpenPGP keys to a file for safe keeping and potential restoration
# using 'mykeys', put the appropriate GPG key after you type this function
function exportmykeys_private()
{
   gpg --list-secret-keys
   echo -n "Please enter the appropriate private key...
   Look for the line that starts something like "sec 1024D/".
   The part after the 1024D is the key_id.
   ...like this: '2942FE31'...

   "
   read MYKEYPRIV
   gpg -ao Private_Keys-private.key --export-secret-keys "$MYKEYPRIV"
   echo -n "All done."
}


###### to export public OpenPGP keys to a file for safe keeping and potential restoration
# using 'mykeys', put the appropriate GPG key after you type this function
function exportmykeys_public()
{
   gpg --list-keys
   echo -n "Please enter the appropriate public key...
   Look for line that starts something like "pub 1024D/".
   The part after the 1024D is the public key_id.
   ...like this: '2942FE31'...

   "
   read MYKEYPUB
   gpg -ao Public_Keys-public.key --export "$MYKEYPUB"
   echo -n "All done."
}

###### to get the new key fingerprint for use in the appropriate section on Launchpad.net to start verification process
alias fingerprintmykeys='gpg --fingerprint'

###### to get a list of your public and private OpenPGP/GPG pubkeys
alias mykeys='gpg --list-keys && gpg --list-secret-keys'

###### publish newly-created mykeys for use on Launchpad / etc.
alias publishmykeys='gpg --keyserver hkp://keyserver.ubuntu.com --send-keys'

###### to restore your public and private OpenPGP keys
# from Public_Key-public.key and Private_Keys-private.key files:
function restoremykeys()
{
   echo -n "Please enter the full path to Public keys (spaces are fine)...

   Example: '/home/(your username)/Public_Key-public.key'...

   "
   read MYKEYS_PUBLIC_LOCATION
   gpg --import "$MYKEYS_PUBLIC_LOCATION"
   echo -n "Please enter the full path to Private keys (spaces are fine)...

   Example: '/home/(your username)/Private_Keys-private.key'...

   "
   read MYKEYS_PRIVATE_LOCATION
   gpg --import "$MYKEYS_PRIVATE_LOCATION"
   echo -n "All done."
}

###### to setup new public and private OpenPGP keys
function setupmykeys()
{
   # Generate new key
   gpg --gen-key
   # Publish new key to Ubuntu keyserver
   gpg --keyserver hkp://keyserver.ubuntu.com --send-keys
   # Import an OpenPGP key
   gpg --fingerprint
   # Verify new key
   read -sn 1 -p "Before you continue, you must enter the fingerprint
   in the appropriate place in your Launchpad PPA on their website...

   Once you have successfully inputed it, wait for your email before
   you press any key to continue...

   "
   gedit $HOME/file.txt
   read -sn 1 -p "Once you have received your email from Launchpad to
   verify your new key, copy and paste the email message received upon
   import of OpenPGP key from "-----BEGIN PGP MESSAGE-----" till
   "-----END PGP MESSAGE-----" to the 'file.txt' in your home folder
   that was just opened for you

   Once you have successfully copied and pasted it, save it and
   press any key to continue...

   "
   gpg -d $HOME/file.txt
   echo -n "All done."
}

###############################################################################
# Numerical conversions and numbers stuff
###############################################################################
###### convert arabic to roman numerals
# Copyright 2007 - 2010 Christopher Bratusek
function arabic2roman() {
   echo $1 | sed -e 's/1...$/M&/;s/2...$/MM&/;s/3...$/MMM&/;s/4...$/MMMM&/
   s/6..$/DC&/;s/7..$/DCC&/;s/8..$/DCCC&/;s/9..$/CM&/
   s/1..$/C&/;s/2..$/CC&/;s/3..$/CCC&/;s/4..$/CD&/;s/5..$/D&/
   s/6.$/LX&/;s/7.$/LXX&/;s/8.$/LXXX&/;s/9.$/XC&/
   s/1.$/X&/;s/2.$/XX&/;s/3.$/XXX&/;s/4.$/XL&/;s/5.$/L&/
   s/1$/I/;s/2$/II/;s/3$/III/;s/4$/IV/;s/5$/V/
   s/6$/VI/;s/7$/VII/;s/8$/VIII/;s/9$/IX/
   s/[0-9]//g'
}

###### convert ascii
# copyright 2007 - 2010 Christopher Bratusek
function asc2all() {
   if [[ $1 ]]; then
      echo "ascii $1 = binary $(asc2bin $1)"
      echo "ascii $1 = octal $(asc2oct $1)"
      echo "ascii $1 = decimal $(asc2dec $1)"
      echo "ascii $1 = hexadecimal $(asc2hex $1)"
      echo "ascii $1 = base32 $(asc2b32 $1)"
      echo "ascii $1 = base64 $(asc2b64 $1)"
   fi
}


function asc2bin() {
   if [[ $1 ]]; then
      echo "obase=2 ; $(asc2dec $1)" | bc
   fi
}

function asc2b64() {
   if [[ $1 ]]; then
      echo "obase=64 ; $(asc2dec $1)" | bc
   fi
}

function asc2b32() {
   if [[ $1 ]]; then
      echo "obase=32 ; $(asc2dec $1)" | bc
   fi
}

function asc2dec() {
   if [[ $1 ]]; then
      printf '%d\n' "'$1'"
   fi
}

function asc2hex() {
   if [[ $1 ]]; then
      echo "obase=16 ; $(asc2dec $1)" | bc
   fi
}

function asc2oct() {
   if [[ $1 ]]; then
      echo "obase=8 ; $(asc2dec $1)" | bc
   fi
}

###### Averaging columns of numbers
# Computes a columns average in a file. Input parameters = column number and optional pattern.
function avg() { awk "/$2/{sum += \$$1; lc += 1;} END {printf \"Average over %d lines: %f\n\", lc, sum/lc}"; }

###### convert binaries
# copyright 2007 - 2010 Christopher Bratusek
function bin2all() {
   if [[ $1 ]]; then
      echo "binary $1 = octal $(bin2oct $1)"
      echo "binary $1 = decimal $(bin2dec $1)"
      echo "binary $1 = hexadecimal $(bin2hex $1)"
      echo "binary $1 = base32 $(bin2b32 $1)"
      echo "binary $1 = base64 $(bin2b64 $1)"
      echo "binary $1 = ascii $(bin2asc $1)"
   fi
}

function bin2asc() {
   if [[ $1 ]]; then
      echo -e "\0$(printf %o $((2#$1)))"
   fi
}

function bin2b64() {
   if [[ $1 ]]; then
      echo "obase=64 ; ibase=2 ; $1" | bc
   fi
}

function bin2b32() {
   if [[ $1 ]]; then
      echo "obase=32 ; ibase=2 ; $1 " | bc
   fi
}

function bin2dec() {
   if [[ $1 ]]; then
      echo $((2#$1))
   fi
}

function bin2hex() {
   if [[ $1 ]]; then
      echo "obase=16 ; ibase=2 ; $1" | bc
   fi
}

function bin2oct() {
   if [[ $1 ]]; then
      echo "obase=8 ; ibase=2 ; $1" | bc
   fi
}

###### temperature conversion
# Copyright 2007 - 2010 Christopher Bratusek
function cel2fah() {
   if [[ $1 ]]; then
      echo "scale=2; $1 * 1.8  + 32" | bc
   fi
}

function cel2kel() {
   if [[ $1 ]]; then
      echo "scale=2; $1 + 237.15" | bc
   fi
}

function fah2cel() {
   if [[ $1 ]]; then
      echo "scale=2 ; ( $1 - 32  ) / 1.8" | bc
   fi
}

function fah2kel() {
   if [[ $1 ]]; then
      echo "scale=2; ( $1 + 459.67 ) / 1.8 " | bc
   fi
}

function kel2cel() {
   if [[ $1 ]]; then
      echo "scale=2; $1 - 273.15" | bc
   fi
}

function kel2fah() {
   if [[ $1 ]]; then
      echo "scale=2; $1 * 1.8 - 459,67" | bc
   fi
}

###### Output an ASCII character given its decimal equivalent
function chr() { printf \\$(($1/64*100+$1%64/8*10+$1%8)); }


###### the notorious "hailstone" or Collatz series.
function collatz()
{
   # get the integer "seed" from the command-line to generate the integer "result"
   # if NUMBER is even, divide by 2, or if odd, multiply by 3 and add 1
   # the theory is that every sequence eventually settles down to repeating "4,2,1..." cycles
   MAX_ITERATIONS=200
   # For large seed numbers (>32000), try increasing MAX_ITERATIONS.
   h=${1:-$$}                      #  Seed. #  Use $PID as seed, #+ if not specified as command-line arg.
   echo
   echo "C($h) --- $MAX_ITERATIONS Iterations"
   echo
   for ((i=1; i<=MAX_ITERATIONS; i++))
   do
      COLWIDTH=%7d
      printf $COLWIDTH $h
      let "remainder = h % 2"
      if [ "$remainder" -eq 0 ]   # Even?
         then
         let "h /= 2"              # Divide by 2.
      else
         let "h = h*3 + 1"         # Multiply by 3 and add 1.
      fi
      COLUMNS=10                    # Output 10 values per line.
      let "line_break = i % $COLUMNS"
      if [ "$line_break" -eq 0 ]
         then
           echo
      fi
   done
   echo
}

###### convert hexadecimal numbers to decimals
function dec()  { printf "%d\n" $1; }

###### convert decimals to hexadecimal numbers
function hex()  { printf "0x%08x\n" $1; }

###### convert decimals
# copyright 2007 - 2010 Christopher Bratusek
function dec2all() {
   if [[ $1 ]]; then
      echo "decimal $1 = binary $(dec2bin $1)"
      echo "decimal $1 = octal $(dec2oct $1)"
      echo "decimal $1 = hexadecimal $(dec2hex $1)"
      echo "decimal $1 = base32 $(dec2b32 $1)"
      echo "decimal $1 = base64 $(dec2b64 $1)"
      echo "deciaml $1 = ascii $(dec2asc $1)"
   fi
}

function dec2asc() {
   if [[ $1 ]]; then
      echo -e "\0$(printf %o 97)"
   fi
}

function dec2bin() {
   if [[ $1 ]]; then
      echo "obase=2 ; $1" | bc
   fi
}

function dec2b64() {
   if [[ $1 ]]; then
      echo "obase=64 ; $1" | bc
   fi
}

function dec2b32() {
   if [[ $1 ]]; then
      echo "obase=32 ; $1" | bc
   fi
}

function dec2hex() {
   if [[ $1 ]]; then
      echo "obase=16 ; $1" | bc
   fi
}

function dec2oct() {
   if [[ $1 ]]; then
      echo "obase=8 ; $1" | bc
   fi
}

###### number --- convert decimal integer to english words
# total number
# Usage:   dec2text 1234 -> one thousand two hundred thirty-four
# Author: Noah Friedman <friedman@prep.ai.mit.edu>
function dec2text()
{
   prog=`echo "$0" | sed -e 's/[^\/]*\///g'`
   garbage=`echo "$*" | sed -e 's/[0-9,.]//g'`
   if test ".$garbage" != "."; then
     echo "$prog: Invalid character in argument." 1>&2
   fi
   case "$*" in
   # This doesn't always seem to work.
   #   *[!0-9,.]* ) echo "$prog: Invalid character in argument." 1>&2; ;;
      *.* ) echo "$prog: fractions not supported (yet)." 1>&2; ;;
      '' ) echo "Usage: $prog [decimal integer]" 1>&2; ;;
   esac
   result=
   eval set - "`echo ${1+\"$@\"} | sed -n -e '
     s/[, ]//g
     s/^00*/0/g
     s/\(.\)\(.\)\(.\)$/\"\1 \2 \3\"/
     :l
     /[0-9][0-9][0-9]/{
       s/\([^\" ][^\" ]*\)\([^\" ]\)\([^\" ]\)\([^\" ]\)/\1\"\2 \3 \4\"/g
       t l
     }
     /^[0-9][0-9][0-9]/s/\([^\" ]\)\([^\" ]\)\([^\" ]\)/\"\1 \2 \3\"/
     /^[0-9][0-9]/s/\([^\" ]\)\([^\" ]\)/\"\1 \2\"/
     /^[0-9]/s/^\([^\" ][^\" ]*\)/\"\1\"/g;s/\"\"/\" \"/g
     p'`"
   while test $# -ne 0 ; do
     eval `set - $1;
      d3='' d2='' d1=''
      case $# in
        1 ) d1=$1 ;;
        2 ) d2=$1 d1=$2 ;;
        3 ) d3=$1 d2=$2 d1=$3 ;;
      esac
      echo "d3=\"$d3\" d2=\"$d2\" d1=\"$d1\""`
     val1='' val2='' val3=''
     case "$d3" in
      1 ) val3=one   ;;     6 ) val3=six   ;;
      2 ) val3=two   ;;     7 ) val3=seven ;;
      3 ) val3=three ;;     8 ) val3=eight ;;
      4 ) val3=four  ;;     9 ) val3=nine  ;;
      5 ) val3=five  ;;
     esac
     case "$d2" in
      1 ) val2=teen   ;;    6 ) val2=sixty   ;;
      2 ) val2=twenty ;;    7 ) val2=seventy ;;
      3 ) val2=thirty ;;    8 ) val2=eighty  ;;
      4 ) val2=forty  ;;    9 ) val2=ninety  ;;
      5 ) val2=fifty  ;;
     esac
     case "$val2" in
      teen )
        val2=
        case "$d1" in
      0 ) val1=ten      ;;     5 ) val1=fifteen   ;;
      1 ) val1=eleven   ;;     6 ) val1=sixteen   ;;
      2 ) val1=twelve   ;;     7 ) val1=seventeen ;;
      3 ) val1=thirteen ;;     8 ) val1=eighteen  ;;
      4 ) val1=fourteen ;;     9 ) val1=nineteen  ;;
        esac
       ;;
      0 ) : ;;
      * )
        test ".$val2" != '.' -a ".$d1" != '.0' \
         && val2="${val2}-"
        case "$d1" in
      0 ) val2="$val2 " ;;     5 ) val1=five  ;;
      1 ) val1=one      ;;     6 ) val1=six   ;;
      2 ) val1=two      ;;     7 ) val1=seven ;;
      3 ) val1=three    ;;     8 ) val1=eight ;;
      4 ) val1=four     ;;     9 ) val1=nine  ;;
        esac
       ;;
     esac
     test ".$val3" != '.' && result="$result$val3 hundred "
     test ".$val2" != '.' && result="$result$val2"
     test ".$val1" != '.' && result="$result$val1 "
     if test ".$d1$d2$d3" != '.000' ; then
      case $# in
         0 | 1 ) ;;
         2 ) result="${result}thousand "          ;;
         3 ) result="${result}million "           ;;
         4 ) result="${result}billion "           ;;
         5 ) result="${result}trillion "          ;;
         6 ) result="${result}quadrillion "       ;;
         7 ) result="${result}quintillion "       ;;
         8 ) result="${result}sextillion "        ;;
         9 ) result="${result}septillion "        ;;
        10 ) result="${result}octillion "         ;;
        11 ) result="${result}nonillion "         ;;
        12 ) result="${result}decillion "         ;;
        13 ) result="${result}undecillion "       ;;
        14 ) result="${result}duodecillion "      ;;
        15 ) result="${result}tredecillion "      ;;
        16 ) result="${result}quattuordecillion " ;;
        17 ) result="${result}quindecillion "     ;;
        18 ) result="${result}sexdecillion "      ;;
        19 ) result="${result}septendecillion "   ;;
        20 ) result="${result}octodecillion "     ;;
        21 ) result="${result}novemdecillion "    ;;
        22 ) result="${result}vigintillion "      ;;
        * ) echo "Error: number too large (66 digits max)." 1>&2; ;;
      esac
     fi
     shift
   done
   set $result > /dev/null
   case "$*" in
     '') set zero ;;
   esac
   echo ${1+"$@"}
   # number ends here
}

# individual numbers
# Usage:   dec2text 1234 -> one two three four
function dec2text_()
{
   # This script is part of nixCraft shell script collection (NSSC)
   # Visit http://bash.cyberciti.biz/ for more information.
   n=$1
   len=$(echo $n | wc -c)
   len=$(( $len - 1 ))
   for (( i=1; i<=$len; i++ ))
   do
      # get one digit at a time
      digit=$(echo $n | cut -c $i)
      # use case control structure to find digit equivalent in words
      case $digit in
      0) echo -n "zero " ;;
      1) echo -n "one " ;;
      2) echo -n "two " ;;
      3) echo -n "three " ;;
      4) echo -n "four " ;;
      5) echo -n "five " ;;
      6) echo -n "six " ;;
      7) echo -n "seven " ;;
      8) echo -n "eight " ;;
      9) echo -n "nine " ;;
      esac
   done
   # just print new line
   echo ""
}

function d2u() {
   # copyright 2007 - 2010 Christopher Bratusek
   if [[ -e "$1" ]]; then
      sed -r 's/\r$//' -i "$1"
   fi
}

function u2d() {
   # copyright 2007 - 2010 Christopher Bratusek
   if [[ -e "$1" ]]; then
      sed -r 's/$/\r/' -i "$1"
   fi
}

###### factorial for integers
function factorial()
{
   echo "Enter an integer: "
   read n
   # Below we define the factorial function in bc syntax
   fact="define f (x) {
   i=x
   fact=1
   while (i > 1) {
      fact=fact*i
      i=i-1
      }
         return fact
      }"
   # Below we pass the function defined above, and call it with n as a parameter and pipe it to bc
   factorial=`echo "$fact;f($n)" | bc -l`
   echo "$n! = $factorial"
}

###### convert hexadecimal numbers
# copyright 2007 - 2010 Christopher Bratusek
function hex2all() {
   if [[ $1 ]]; then
      echo "hexadecimal $1 = binary $(hex2bin $1)"
      echo "hexadecimal $1 = octal $(hex2oct $1)"
      echo "hexadecimal $1 = decimal $(hex2dec $1)"
      echo "hexadecimal $1 = base32 $(hex2b32 $1)"
      echo "hexadecimal $1 = base64 $(hex2b64 $1)"
      echo "hexadecimal $1 = ascii $(hex2asc $1)"
   fi
}

function hex2asc() {
   if [[ $1 ]]; then
      echo -e "\0$(printf %o $((16#$1)))"
   fi
}

function hex2bin() {
   if [[ $1 ]]; then
      echo "obase=2 ; ibase=16 ; $1" | bc
   fi
}

function hex2b64() {
   if [[ $1 ]]; then
      echo "obase=64 ; ibase=16 ; $1" | bc
   fi
}

function hex2b32() {
   if [[ $1 ]]; then
      echo "obase=32 ; ibase=16 ; $1" | bc
   fi
}

function hex2dec() {
   if [[ $1 ]]; then
       echo $((16#$1))
   fi
}

function hex2oct() {
   if [[ $1 ]]; then
      echo "obase=8 ; ibase=16 ; $1" | bc
   fi
}

###### length
function length()
{
    if [ $# -lt 1 ]; then
      echo "count # of chars in arugment"
      echo "usage: length [string]"
    else
      echo -n $@ | wc -c
    fi
}

###### finding logs for numbers
function math-log()
{
   echo "Enter value: "
   read x
   echo "Natural Log: ln($x) :"
   echo "l($x)" | bc -l
   echo "Ten Base Log: log($x) :"
   echo "l($x)/l(10)" | bc -l
}

###### convert normal to unix
function normal2unix()
{
    echo "${@}" | awk '{print mktime($0)}';
}

###### convert unix to normal
function unix2normal()
{
    echo $1 | awk '{print strftime("%Y-%m-%d %H:%M:%S",$1)}';
}

###### list of numbers with equal width
function nseq()
{
   seq -w 0 "$1"
}

###### convert octals
# copyright 2007 - 2010 Christopher Bratusek
function oct2all() {
   if [[ $1 ]]; then
      echo "octal $1 = binary $(oct2bin $1)"
      echo "octal $1 = decimal $(oct2dec $1)"
      echo "octal $1 = hexadecimal $(oct2hex $1)"
      echo "octal $1 = base32 $(oct2b32 $1)"
      echo "octal $1 = base64 $(oct2b64 $1)"
      echo "octal $1 = ascii $(oct2asc $1)"
   fi
}

function oct2asc() {
   if [[ $1 ]]; then
      echo -e "\0$(printf %o $((8#$1)))"
   fi
}

function oct2bin() {
   if [[ $1 ]]; then
      echo "obase=2 ; ibase=8 ; $1" | bc
   fi
}

function oct2b64() {
   if [[ $1 ]]; then
      echo "obase=64 ; ibase=8 ; $1" | bc
   fi
}

function oct2b32() {
   if [[ $1 ]]; then
      echo "obase=32 ; ibase=8 ; $1" | bc
   fi
}

function oct2dec() {
   if [[ $1 ]]; then
      echo $((8#$1))
   fi
}

function oct2hex() {
   if [[ $1 ]]; then
      echo "obase=16 ; ibase=8 ; $1" | bc
   fi
}

###### powers of numerals
# copyright 2007 - 2010 Christopher Bratusek
function power() {
   if [[ $1 ]]; then
      if [[ $2 ]]; then
         echo "$1 ^ $2" | bc
      else   echo "$1 ^ 2" | bc
      fi
   fi
}

###### generate prime numbers, without using arrays.
# script contributed by Stephane Chazelas.
function primes()
{
   LIMIT=1000                    # Primes, 2 ... 1000.
   Primes()
   {
      (( n = $1 + 1 ))             # Bump to next integer.
      shift                        # Next parameter in list.
      #  echo "_n=$n i=$i_"
      if (( n == LIMIT ))
      then echo $*
         return
      fi
      for i; do                    # "i" set to "@", previous values of $n.
         #   echo "-n=$n i=$i-"
         (( i * i > n )) && break   # Optimization.
         (( n % i )) && continue    # Sift out non-primes using modulo operator.
         Primes $n $@               # Recursion inside loop.
         return
      done
      Primes $n $@ $n      #  Recursion outside loop.
                     #  Successively accumulate
                     #+ positional parameters.
                     #  "$@" is the accumulating list of primes.
   }
   Primes 1
}

###### radicals of numbers
# copyright 2007 - 2010 Christopher Bratusek
function radical() {
   if [[ $1 ]]; then
      echo "sqrt($1)" | bc -l
   fi
}

###### convert to roman numerals
function roman-numeral()
{
   python -c 'while True: print (lambda y,x=[],nums={ 1000:"M",900:"CM",500:"D",400:"CD",100:"C",90:"XC",
50:"L",40:"XL",10:"X",9:"IX",5:"V",4:"IV",1:"I"}: (lambda ro=(lambda : map(lambda g,r=lambda b:x.append(
y[-1]/b),t=lambda v:y.append(y[-1]%v):map(eval,["r(g)","t(g)"]),sorted(nums.keys())[::-1]))():"".join(
map(lambda fg: map(lambda ht: nums[ht],sorted(nums.keys())[::-1])[fg] * x[fg],range(len(x)))))())([int(
raw_input("Please enter a number between 1 and 4000: "))])'
}

###### round numerals to whole numbers
# copyright 2007 - 2010 Christopher Bratusek
function round() {
   if [[ $1 ]]; then
      if [[ $2 ]]; then
         echo "$(printf %.${2}f $1)"
      else   echo "$(printf %.0f $1)"
      fi
   fi
}

###### ruler that stretches across the terminal
function ruler() { for s in '....^....|' '1234567890'; do w=${#s}; str=$( for (( i=1; $i<=$(( ($COLUMNS + $w) / $w )) ; i=$i+1 )); do echo -n $s; done ); str=$(echo $str | cut -c -$COLUMNS) ; echo $str; done; }

###### convert seconds to minutes, hours, days, and etc.
# inputs a number of seconds, outputs a string like "2 minutes, 1 second"
# $1: number of seconds
function sec2all()
{
    local millennia=$((0))
    local centuries=$((0))
    local years=$((0))
    local days=$((0))
    local hour=$((0))
    local mins=$((0))
    local secs=$1
    local text=""
    # convert seconds to days, hours, etc
    millennia=$((secs / 31536000000))
    secs=$((secs % 31536000000))
    centuries=$((secs / 3153600000))
    secs=$((secs % 3153600000))
    years=$((secs / 31536000))
    secs=$((secs % 31536000))
    days=$((secs / 86400))
    secs=$((secs % 86400))
    hour=$((secs / 3600))
    secs=$((secs % 3600))
    mins=$((secs / 60))
    secs=$((secs % 60))
    # build full string from unit strings
    text="$text$(seconds-convert-part $millennia "millennia")"
    text="$text$(seconds-convert-part $centuries "century")"
    text="$text$(seconds-convert-part $years "year")"
    text="$text$(seconds-convert-part $days "day")"
    text="$text$(seconds-convert-part $hour "hour")"
    text="$text$(seconds-convert-part $mins "minute")"
    text="$text$(seconds-convert-part $secs "second")"
    # trim leading and trailing whitespace"
    text=${text## }
    text=${text%% }
    # special case for zero seconds
    if [ "$text" == "" ]; then
      text="0 seconds"
    fi
    # echo output for the caller
    echo ${text}
}

# formats a time unit into a string
# $1: integer count of units: 0, 6, etc
# $2: unit name: "hour", "minute", etc
function seconds-convert-part()
{
    local unit=$1
    local name=$2
    if [ $unit -ge 2 ]; then
   echo " ${unit} ${name}s"
    elif [ $unit -ge 1 ]; then
   echo " ${unit} ${name}"
    else
   echo ""
    fi
}

###### finding the square root of numbers
function sqrt()
{
   echo "sqrt ("$1")" | bc -l
}

###### converts a string (words, text) to binary"
function string2bin()
{
   perl -nle 'printf "%0*v8b\n"," ",$_'
}

###### trigonmetry calculations with angles
function trig-angle()
{
   echo "Enter angle in degree: "
   read deg
   # Note: Pi calculation
   # tan(pi/4) = 1
   # atan(1) = pi/4 and
   # pi = 4*atan(1)
   pi=`echo "4*a(1)" | bc -l`
   rad=`echo "$deg*($pi/180)" | bc -l`
   echo "$deg Degree = $rad Radian"
   echo "Sin($deg): "
   echo "s($rad)" | bc -l
   echo "Cos($deg): "
   echo "c($rad)" | bc -l
   echo "Tan($deg): "
   echo "s($rad)/c($rad)" | bc -l
}

###############################################################################
# Proxy and Anomymization
###############################################################################
######  Set/Unset a proxy for the terminal using tor
# For a HTTP proxy in a single terminal window, simply run the following command in a terminal:
# export http_proxy='http://YOUR_USERNAME:YOUR_PASSWORD@PROXY_IP:PROXY_PORT/'
# For a secure connection (HTTPS), use:
# export https_proxy='http://YOUR_USERNAME:YOUR_PASSWORD@PROXY_IP:PROXY_PORT/'
# Obviously, replace everything with your username, password, proxy ip and port.
# If the proxy does not require an username and password, skip that part
function termproxy()
{
   export http_proxy='http://localhost:8118'
   export https_proxy='http://localhost:8118'
}

###### To close the HTTP proxy in the terminal, either close the terminal, or enter this:
function termproxyX()
{
   unset http_proxy
   unset https_proxy
}

###### Switch tor on and off (requires privoxy)
function torswitch() {
   # copyright 2007 - 2010 Christopher Bratusek
   if [[ $EUID == 0 ]]; then
      case $1 in
         *on )
            if [[ $(grep forward-socks4a /etc/privoxy/config) == "" ]]; then
               echo "forward-socks4a / 127.0.0.1:9050 ." >> /etc/privoxy/config
            else
               sed -e 's/\# forward-socks4a/forward-socks4a/g' -i /etc/privoxy/config
               /etc/init.d/tor restart
               /etc/init.d/privoxy restart
            fi
         ;;
         *off )
            sed -e 's/forward-socks4a/\# forward-socks4a/g' -i /etc/privoxy/config
            /etc/init.d/tor restart
            /etc/init.d/privoxy restart
         ;;
      esac
   fi
}

###############################################################################
# Time Functions
###############################################################################
###### Easily decode unix-time (function)
function utime() { perl -e "print localtime($1).\"\n\"";}

###### binary clock
function bclock()
{
   watch -n 1 'echo "obase=2;`date +%s`" | bc'
}

###### Clock - A bash clock that can run in you
function clock()
{
   while true;do clear;echo "===========";date +"%r";echo "===========";sleep 1;done
}

###############################################################################
# Stopwatch and Countdown Timer
###############################################################################
function stopwatch() {
   # copyright 2007 - 2010 Christopher Bratusek
   BEGIN=$(date +%s)
   while true; do
      NOW=$(date +%s)
      DIFF=$(($NOW - $BEGIN))
      MINS=$(($DIFF / 60))
      SECS=$(($DIFF % 60))
      echo -ne "Time elapsed: $MINS:`printf %02d $SECS`\r"
      sleep .1
   done
}

###### stopwatch with log
function stop_watch()
{
   START=$( date +%s ); while true; do CURRENT=$( date +%s ) ; echo $(( CURRENT-START )) ; sleep 1 ; echo -n ^[[A ; done
}

###### countdown clock
function countdown() { case "$1" in -s) shift;; *) set $(($1 * 60));; esac; local S=" "; for i in $(seq "$1" -1 1); do echo -ne "$S\r $i\r"; sleep 1; done; echo -e "$S\rBOOM!"; }

###### countdown clock
alias countdown2='MIN=1 && for i in $(seq $(($MIN*60)) -1 1); do echo -n "$i, "; sleep 1; done; echo -e "\n\nBOOOM! Time to start."'

###### Timer function
# Elapsed time.  Usage:
#   t=$(timer)
#   ... # do something
#   printf 'Elapsed time: %s\n' $(timer $t)
#      ===> Elapsed time: 0:01:12
# If called with no arguments a new timer is returned.
# If called with arguments the first is used as a timer
# value and the elapsed time is returned in the form HH:MM:SS.
function timer()
{
    if [[ $# -eq 0 ]]; then
      echo $(date '+%s')
    else
      local  stime=$1
      etime=$(date '+%s')
      if [[ -z "$stime" ]]; then stime=$etime; fi
      dt=$((etime - stime))
      ds=$((dt % 60))
      dm=$(((dt / 60) % 60))
      dh=$((dt / 3600))
      printf '%d:%02d:%02d' $dh $dm $ds
    fi
}

###############################################################################
# Checksum
###############################################################################
function checksum()
# copyright 2007 - 2010 Christopher Bratusek
{
   action=$1
   shift
   if [[ ( $action == "-c" || $action == "--check" ) && $1 == *.* ]]; then
      type="${1/*./}"
   else   type=$1
      shift
   fi
   case $type in
      md5 )
         checktool=md5sum
      ;;
      sha1 | sha )
         checktool=sha1sum
      ;;
      sha224 )
         checktool=sha224sum
      ;;
      sha256 )
         checktool=sha256sum
      ;;
      sha384 )
         checktool=sha384sum
      ;;
      sha512 )
         checktool=sha512sum
      ;;
   esac
   case $action in
      -g | --generate )
         for file in "${@}"; do
            $checktool "${file}" > "${file}".$type
         done
      ;;
      -c | --check )
         for file in "${@}"; do
            if [[ "${file}" == *.$type ]]; then
               $checktool --check "${file}"
            else   $checktool --check "${file}".$type
            fi
         done
      ;;
      -h | --help )
      ;;
   esac
}

###### MD5 checksum
function md5()
{
    echo -n $@ | md5sum
}

###### Encode a string in md5 hash of 32 characters
# You can short the length with the second parameter.
#  @param string $1 string (required)
#  @param integer $2 length (option, default: 32)
#  @return string
#  @example:    md5 "Hello World" 8
function md5_() {
      local length=${2:-32}
      local string=$( echo "$1" | md5sum | awk '{ print $1 }' )
      echo ${string:0:${length}}
}

###############################################################################
# Network information and IP address stuff
###############################################################################
###### Scans a port, returns what's on it.
function port() {
   lsof -i :"$1"
}

###### Lists unique IPs currently connected to logged-in system & how many concurrent connections each IP has
function doscheck()
{
   "netstat -ntu | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -n"
}

###### clear iptables rules safely
function clearIptables()
{
   iptables -P INPUT ACCEPT; iptables -P FORWARD ACCEPT; iptables -P OUTPUT ACCEPT; iptables -F; iptables -X; iptables -L
}

###### find an unused unprivileged TCP port
function findtcp()
{
   (netstat  -atn | awk '{printf "%s\n%s\n", $4, $4}' | grep -oE '[0-9]*$'; seq 32768 61000) | sort -n | uniq -u | head -n 1
}

###### Get just the HTTP headers from a web page (and its redirects)
function http_headers() { 
   /usr/bin/curl -I -L $@ ;
}

###### Download a web page and show info on whattook time
function http_debug() { 
   /usr/bin/curl $@ -o /dev/null -w "dns: %{time_namelookup} connect: %{time_connect} pretransfer: %{time_pretransfer} starttransfer: %{time_starttransfer} total: %{time_total}\n" ; 
}

###### usage: liveh [-i interface] [output-file] && firefox &
function liveh() { 
   tcpdump -lnnAs512 ${1-} tcp |sed ' s/.*GET /GET /;s/.*Host: /Host: /;s/.*POST /POST /;/[GPH][EOo][TSs]/!d;w '"${2-liveh.txt}"' ' >/dev/null ; 
}

###### geolocate a given IP address
function ip2loc() { 
   wget -qO - www.ip2location.com/$1 | grep "<span id=\"dgLookup__ctl2_lblICountry\">" | sed 's/<[^>]*>//g; s/^[   ]*//; s/&quot;/"/g; s/</</g; s/>/>/g; s/&amp;/\&/g';
}


function ip2locall() {
   # best if used through a proxy, as ip2loc's free usage only lets you search a maximum of 20 times per day
   # currently set on using a proxy through tor; if don't want that, just comment out the two 'export..' and 'unset...' lines
   export http_proxy='http://localhost:8118'
   export https_proxy='http://localhost:8118'
   echo ""
   echo "Country:"
   wget -qO - www.ip2location.com/$1 | grep "<span id=\"dgLookup__ctl2_lblICountry\">" | sed 's/<[^>]*>//g; s/^[   ]*//; s/&quot;/"/g; s/</</g; s/>/>/g; s/&amp;/\&/g';
   echo ""
   echo "Region (State, Province, Etc.):"
   wget -qO - www.ip2location.com/$1 | grep "<span id=\"dgLookup__ctl2_lblIRegion\">" | sed 's/<[^>]*>//g; s/^[   ]*//; s/&quot;/"/g; s/</</g; s/>/>/g; s/&amp;/\&/g';
   echo ""
   echo "City:"
   wget -qO - www.ip2location.com/$1 | grep "<span id=\"dgLookup__ctl2_lblICity\">" | sed 's/<[^>]*>//g; s/^[   ]*//; s/&quot;/"/g; s/</</g; s/>/>/g; s/&amp;/\&/g';
   echo ""
   echo "Latitude:"
   wget -qO - www.ip2location.com/$1 | grep "<span id=\"dgLookup__ctl2_lblILatitude\">" | sed 's/<[^>]*>//g; s/^[   ]*//; s/&quot;/"/g; s/</</g; s/>/>/g; s/&amp;/\&/g';
   echo ""
   echo "Longitude:"
   wget -qO - www.ip2location.com/$1 | grep "<span id=\"dgLookup__ctl2_lblILongitude\">" | sed 's/<[^>]*>//g; s/^[   ]*//; s/&quot;/"/g; s/</</g; s/>/>/g; s/&amp;/\&/g';
   echo ""
   echo "ZIP Code:"
   wget -qO - www.ip2location.com/$1 | grep "<span id=\"dgLookup__ctl2_lblIZIPCode\">" | sed 's/<[^>]*>//g; s/^[   ]*//; s/&quot;/"/g; s/</</g; s/>/>/g; s/&amp;/\&/g';
   echo ""
   echo "Time Zone:"
   wget -qO - www.ip2location.com/$1 | grep "<span id=\"dgLookup__ctl2_lblITimeZone\">" | sed 's/<[^>]*>//g; s/^[   ]*//; s/&quot;/"/g; s/</</g; s/>/>/g; s/&amp;/\&/g';
   echo ""
   echo "Net Speed:"
   wget -qO - www.ip2location.com/$1 | grep "<span id=\"dgLookup__ctl2_lblINetSpeed\">" | sed 's/<[^>]*>//g; s/^[   ]*//; s/&quot;/"/g; s/</</g; s/>/>/g; s/&amp;/\&/g';
   echo ""
   echo "ISP:"
   wget -qO - www.ip2location.com/$1 | grep "<span id=\"dgLookup__ctl2_lblIISP\">" | sed 's/<[^>]*>//g; s/^[   ]*//; s/&quot;/"/g; s/</</g; s/>/>/g; s/&amp;/\&/g';
   echo ""
   echo "Domain:"
   wget -qO - www.ip2location.com/$1 | grep "<span id=\"dgLookup__ctl2_lblIDomain\">" | sed 's/<[^>]*>//g; s/^[   ]*//; s/&quot;/"/g; s/</</g; s/>/>/g; s/&amp;/\&/g';
   echo ""
   echo "IDD Code:"
   wget -qO - www.ip2location.com/$1 | grep "<span id=\"dgLookup__ctl2_lblIIDDCode\">" | sed 's/<[^>]*>//g; s/^[   ]*//; s/&quot;/"/g; s/</</g; s/>/>/g; s/&amp;/\&/g';
   echo ""
   echo "Area Code:"
   wget -qO - www.ip2location.com/$1 | grep "<span id=\"dgLookup__ctl2_lblIAreaCode\">" | sed 's/<[^>]*>//g; s/^[   ]*//; s/&quot;/"/g; s/</</g; s/>/>/g; s/&amp;/\&/g';
   echo ""
   echo "Weather Station:"
   wget -qO - www.ip2location.com/$1 | grep "<span id=\"dgLookup__ctl2_lblIWeatherStation\">" | sed 's/<[^>]*>//g; s/^[   ]*//; s/&quot;/"/g; s/</</g; s/>/>/g; s/&amp;/\&/g';
   echo ""
   echo "MCC:"
   wget -qO - www.ip2location.com/$1 | grep "<span id=\"dgLookup__ctl2_lblIMCC\">" | sed 's/<[^>]*>//g; s/^[   ]*//; s/&quot;/"/g; s/</</g; s/>/>/g; s/&amp;/\&/g';
   echo ""
   echo "MNC:"
   wget -qO - www.ip2location.com/$1 | grep "<span id=\"dgLookup__ctl2_lblIMNC\">" | sed 's/<[^>]*>//g; s/^[   ]*//; s/&quot;/"/g; s/</</g; s/>/>/g; s/&amp;/\&/g';
   echo ""
   echo "Mobile Brand:"
   wget -qO - www.ip2location.com/$1 | grep "<span id=\"dgLookup__ctl2_lblIMobileBrand\">" | sed 's/<[^>]*>//g; s/^[   ]*//; s/&quot;/"/g; s/</</g; s/>/>/g; s/&amp;/\&/g';
   echo ""
   unset http_proxy
   unset https_proxy
}



function ip2locate() {
   # best if used through a proxy, as ip2loc's free usage only lets you search a maximum of 20 times per day
   # currently set on using a proxy through tor; if don't want that, just comment out the two 'export..' and 'unset...' lines
   export http_proxy='http://localhost:8118'
   export https_proxy='http://localhost:8118'
   echo ""
   echo "Country:"
   wget -qO - www.ip2location.com/$1 | grep "<span id=\"dgLookup__ctl2_lblICountry\">" | sed 's/<[^>]*>//g; s/^[   ]*//; s/&quot;/"/g; s/</</g; s/>/>/g; s/&amp;/\&/g';
   echo ""
   echo "Region (State, Province, Etc.):"
   wget -qO - www.ip2location.com/$1 | grep "<span id=\"dgLookup__ctl2_lblIRegion\">" | sed 's/<[^>]*>//g; s/^[   ]*//; s/&quot;/"/g; s/</</g; s/>/>/g; s/&amp;/\&/g';
   echo ""
   echo "City:"
   wget -qO - www.ip2location.com/$1 | grep "<span id=\"dgLookup__ctl2_lblICity\">" | sed 's/<[^>]*>//g; s/^[   ]*//; s/&quot;/"/g; s/</</g; s/>/>/g; s/&amp;/\&/g';
   echo ""
   echo "Latitude:"
   wget -qO - www.ip2location.com/$1 | grep "<span id=\"dgLookup__ctl2_lblILatitude\">" | sed 's/<[^>]*>//g; s/^[   ]*//; s/&quot;/"/g; s/</</g; s/>/>/g; s/&amp;/\&/g';
   echo ""
   echo "Longitude:"
   wget -qO - www.ip2location.com/$1 | grep "<span id=\"dgLookup__ctl2_lblILongitude\">" | sed 's/<[^>]*>//g; s/^[   ]*//; s/&quot;/"/g; s/</</g; s/>/>/g; s/&amp;/\&/g';
   echo ""
   unset http_proxy
   unset https_proxy
}

###### myip - finds your current IP if your connected to the internet
function myip()
{
   lynx -dump -hiddenlinks=ignore -nolist http://checkip.dyndns.org:8245/ | awk '{ print $4 }' | sed '/^$/d; s/^[ ]*//g; s/[ ]*$//g'
}

###### netinfo - shows network information for your system
function netinfo()
{
   echo "--------------- Network Information ---------------"
   /sbin/ip addr | awk /'inet addr/ {print $2}'
   /sbin/ip addr | awk /'Bcast/ {print $3}'
   /sbin/ip addr | awk /'inet addr/ {print $4}'
   /sbin/ip addr | awk /'HWaddr/ {print $4,$5}'
   myip=`lynx -dump -hiddenlinks=ignore -nolist http://checkip.dyndns.org:8245/ | sed '/^$/d; s/^[ ]*//g; s/[ ]*$//g' `
   echo "${myip}"
   echo "---------------------------------------------------"
}

###### check whether or not a port on your box is open
function portcheck() { for i in $@;do curl -s "deluge-torrent.org/test-port.php?port=$i" | sed '/^$/d;s/<br><br>/ /g';done; }

###### show Url information
# Usage:   url-info "ur"
# This script is part of nixCraft shell script collection (NSSC)
# Visit http://bash.cyberciti.biz/ for more information.
# Modified by Silviu Silaghi (http://docs.opensourcesolutions.ro) to handle
# more ip adresses on the domains on which this is available (eg google.com or yahoo.com)
# Last updated on Sep/06/2010
function url-info()
{
   doms=$@
   if [ $# -eq 0 ]; then
      echo -e "No domain given\nTry $0 domain.com domain2.org anyotherdomain.net"
   fi
   for i in $doms; do
      _ip=$(host $i|grep 'has address'|awk {'print $4'})
      if [ "$_ip" == "" ]; then
         echo -e "\nERROR: $i DNS error or not a valid domain\n"
         continue
      fi
      ip=`echo ${_ip[*]}|tr " " "|"`
      echo -e "\nInformation for domain: $i [ $ip ]\nQuerying individual IPs"
      for j in ${_ip[*]}; do
         echo -e "\n$j results:"
         whois $j |egrep -w 'OrgName:|City:|Country:|OriginAS:|NetRange:'
      done
   done
}


###### cleanly list available wireless networks (using iwlist)
function wscan()
{
   iwlist wlan0 scan | sed -ne 's#^[[:space:]]*\(Quality=\|Encryption key:\|ESSID:\)#\1#p' -e 's#^[[:space:]]*\(Mode:.*\)$#\1\n#p'
}

###############################################################################
# Source control (GIT, Subversion)
###############################################################################
###### copyright 2007 - 2010 Christopher Bratusek
function git_action() {
   if [[ -d .git ]]; then
      if [[ -f .git/dotest/rebasing ]]; then
         ACTION="rebase"
      elif [[ -f .git/dotest/applying ]]; then
         ACTION="apply"
      elif [[ -f .git/dotest-merge/interactive ]]; then
         ACTION="rebase -i"
      elif [[ -d .git/dotest-merge ]]; then
         ACTION="rebase -m"
      elif [[ -f .git/MERGE_HEAD ]]; then
         ACTION="merge"
      elif [[ -f .git/index.lock ]]; then
         ACTION="locked"
      elif [[ -f .git/BISECT_LOG ]]; then
         ACTION="bisect"
      else   ACTION="nothing"
      fi
      echo $ACTION
   else   echo --
   fi
}

function git_branch() {
   if [[ -d .git ]]; then
      BRANCH=$(git symbolic-ref HEAD 2>/dev/null)
      echo ${BRANCH#refs/heads/}
   else   echo --
   fi
}

function git_bzip() {
   git archive master | bzip2 -9 >"$PWD".tar.bz2
}

function git_e() {
   if [[ "$SVN_USER_ENLIGTENMENT" && $1 == "-m" ]]; then
      svn co svn+ssh://"$SVN_USER_ENLIGTENMENT"@svn.enlightenment.org/var/svn/$2
   else
      svn co http://svn.enlightenment.org/svn/$2
   fi
}

function git_export() {
   if [[ "$1" != "" ]]; then
      git checkout-index --prefix="$1"/ -a
   fi
}

function git_revision() {
   if [[ -d .git ]]; then
      REVISION=$(git rev-parse HEAD 2>/dev/null)
      REVISION=${REVISION/HEAD/}
      echo ${REVISION:0:6}
   else   echo --
   fi
}

###### Telling you from where your commit come from
function git_where()
{
   COUNT=0; while [ `where_arg $1~$COUNT | wc -w` == 0 ]; do let COUNT=COUNT+1; done; echo "$1 is ahead of "; where_arg $1~$COUNT; echo "by $COUNT commits";};function where_arg() { git log $@ --decorate -1 | head -n1 | cut -d ' ' -f3- ;
}

###### edit the svn log at  the given revision
function svnlogedit() {
    svn propedit svn:log --revprop -r$1 --editor-cmd gedit
}

###### svn recursive directory/file adder
# this will recursively add files/directories in SVN
function svnradd() {
   for i in $1/*;do if [ -e "$i" ];then if [ -d "$i" ];then svn add $i;svnradd $i;else svn add $i;fi; fi;done 
}

###### display the revision number of the current repository                #
function svn_rev() {
   svn info $@ | awk '/^Revision:/ {print $2}'
}

###### do a svn update and show the log messages since the last update
function svn_uplog() {
   local old_revision=`svn_rev $@`
   local first_update=$((${old_revision} + 1))

   svn up -q $@
   if [ $(svn_rev $@) -gt ${old_revision} ]
   then
      svn log -v -rHEAD:${first_update} $@
   else
      echo "No Changes."
   fi
}

###############################################################################
# Development
###############################################################################
###### Decompiler for jar files using jad
function unjar() { 
   mkdir -p /tmp/unjar/$1 ; unzip -d /tmp/unjar/$1 $1 *class 1>/dev/null && find /tmp/unjar/$1 -name *class -type f | xargs jad -ff -nl -nonlb -o -p -pi99 -space -stat ; rm -r /tmp/unjar/$1 ; 
}

###### Computer the speed of two commands
function comp() { # compare the speed of two commands (loop $1 times)
   if [[ $# -ne 3 ]] ; then return 1 ; fi
   echo -n 1
   time for ((i=0;i<$1;i++)) ; do $2 ; done >/dev/null 2>&1
   echo -n 2
   time for ((i=0;i<$1;i++)) ; do $3 ; done >/dev/null 2>&1
}

###### Count opening and closing braces in a string
function countbraces() { 
   COUNT_OPENING=$(echo $1 | grep -o "(" | wc -l); COUNT_CLOSING=$(echo $1 | grep -o ")" | wc -l); echo Opening: $COUNT_OPENING; echo Closing: $COUNT_CLOSING; 
}

###############################################################################
# Hardware releated functions
###############################################################################
###### Mount CIFS shares; pseudo-replacement for smbmount
# $1 = remote share name in form of //server/share
# $2 = local mount point
function cifsmount() { 
    if [ $# -lt 1 ] || [ $# -gt 2 ]; then
      echo "Mount CIFS shares; pseudo-replacement for smbmount"
      echo "cifsmount: [remote share name in form  //server/share] [local mount point]"
   else
      sudo mount -t cifs -o username=${USER},uid=${UID},gid=${GROUPS} $1 $2
   fi
}

###### Remount a device
function remount() {
   # copyright 2007 - 2010 Christopher Bratusek
   DEVICE=$1
   shift
   mount -oremount,$@ $DEVICE
}

###### Mount Fat   
function mount_fat()
{
    local _DEF_PATH="/media/tmp1"
    if [ -n "$2" ];then
      sudo mount -t vfat -o rw,users,flush,umask=0000 "$1" "$2"
    else
      sudo mount -t vfat -o rw,users,flush,umask=0000 "$1" $_DEF_PATH
    fi
}

###### Touchpad: to get information on touchpad
alias touchpad_id='xinput list | grep -i touchpad'

###### Touchpad: to disable
# using 'touchpad_id', set the number for your touchpad (default is 12)
function touchpad_off()
{
   touchpad=12
   xinput set-prop $touchpad "Device Enabled" 0
}

###### Touchpad: to enable
# using 'touchpad_id', set the number for your touchpad (default is 12)
function touchpad_on()
{
   touchpad=12
   xinput set-prop $touchpad "Device Enabled" 1
}

###############################################################################
# Arch Linux
###############################################################################
######  Arch-wiki-docs simple search
function archwikisearch() {
   # old version
   # cd /usr/share/doc/arch-wiki/html/
   # grep -i "$1" index.html | sed 's/.*HREF=.\(.*\.html\).*/\1/g' | xargs opera -newpage
   cd /usr/share/doc/arch-wiki/html/
   for i in $(grep -li $1 *)
   do
      STRING=`grep -m1 -o 'wgTitle = "[[:print:]]\+"' $i`
      LEN=${#STRING}
      let LEN=LEN-12
      STRING=${STRING:11:LEN}
      LOCATION="/usr/share/doc/arch-wiki/html/$i"
      echo -e " \E[33m$STRING   \E[37m$LOCATION"
   done
}

###### Pacman Search
function pacsearch() {
       echo -e "$(pacman -Ss $@ | sed \
       -e 's#core/.*#\\033[1;31m&\\033[0;37m#g' \
       -e 's#extra/.*#\\033[0;32m&\\033[0;37m#g' \
       -e 's#community/.*#\\033[1;35m&\\033[0;37m#g' \
       -e 's#^.*/.* [0-9].*#\\033[0;36m&\\033[0;37m#g' )"
}

###### Pacman remove oprhans
orphans() {
  if [[ ! -n $(pacman -Qdt) ]]; then
    echo no orphans to remove
  else
    sudo pacman -Rs $(pacman -Qdtq)
  fi
}

###############################################################################
# URL
###############################################################################
###### Short URLs with ur1.ca
function ur1() {
   curl -s --url http://ur1.ca/ -d longurl="$1" | sed -n -e '/Your ur1/!d;s/.*<a href="\(.*\)">.*$/\1/;p' ; 
}

###### Create an easy to pronounce shortened URL from CLI
function shout() { 
   curl -s "http://shoutkey.com/new?url=$1" | sed -n 's/\<h1\>/\&/p' | sed 's/<[^>]*>//g;/</N;//b' ;
}

###### Create QR codes from a URL
function qrurl() {
   curl -sS "http://chart.apis.google.com/chart?chs=200x200&cht=qr&chld=H|0&chl=$1" -o - | display -filter point -resize 600x600 png:-;
}

###############################################################################
# Image and PDF manipulation
###############################################################################
##### Convert a single-page PDF to a hi-res PNG, at 300dpi
# If you skip this part: -density 300x300, you'll get a very lo-res image
function pdf2png()
{
   convert -density 300x300 $1 $2
}

##### Extract pages from pdf
# http://www.linuxjournal.com/content/tech-tip-extract-pages-pdf
function pdfpextr()
{
    # this function uses 3 arguments:
    #     $1 is the first page of the range to extract
    #     $2 is the last page of the range to extract
    #     $3 is the input file
    #     output file will be named "inputfile_pXX-pYY.pdf"
    gs -sDEVICE=pdfwrite -dNOPAUSE -dBATCH -dSAFER \
       -dFirstPage=${1} \
       -dLastPage=${2} \
       -sOutputFile="${3%.pdf}_p${1}-p${2}.pdf" \
       "${3}"
}

##### Reduce PDF
function pdfreduce()
{
   # this function uses 2 arguments:
   #     $1 file to reduce
   #     $2 dpi
   gs -dNOPAUSE -dBATCH -sDEVICE=pdfwrite \
      -dCompatibilityLevel=1.4 \
      -dDownsampleColorImages=true \
      -dDownsampleGrayImages=true \
      -dDownsampleMonoImages=true \
      -dColorImageResolution=${2} \
      -dGrayImageResolution=${2} \
      -dMonoImageResolution=${2} \
      -sOutputFile="${1}_${2}dpi" \
      "${1}"
}

###### batch resize image
function resizeimg()
{
         NAME_="resizeimg"
         HTML_="batch resize image"
      PURPOSE_="resize bitmap image"
      PURPOSE_="resize bitmap image"
      SYNOPSIS_="$NAME_ [-hlv] -w <n> <file> [file...]"
      REQUIRES_="standard GNU commands, ImageMagick"
      VERSION_="1.2"
         DATE_="2001-04-22; last update: 2004-10-02"
       AUTHOR_="Dawid Michalczyk <dm@eonworks.com>"
         URL_="www.comp.eonworks.com"
      CATEGORY_="gfx"
      PLATFORM_="Linux"
        SHELL_="bash"
    DISTRIBUTE_="yes"
   # This program is distributed under the terms of the GNU General Public License
   usage () {
   echo >&2 "$NAME_ $VERSION_ - $PURPOSE_
   Usage: $SYNOPSIS_
   Requires: $REQUIRES_
   Options:
       -w <n>, an integer referring to width in pixels; aspect ratio will be preserved
       -v, verbose
       -h, usage and options (this help)
       -l, see this script"
      exit 1
   }
   gfx_resizeImage() {
      # arg check
      [[ $1 == *[!0-9]* ]] && { echo >&2 $1 must be an integer; exit 1; }
      [ ! -f $2 ] && { echo >&2 file $2 not found; continue ;}
      # scaling down to value in width
      mogrify -geometry $1 $2
   }
   # args check
   [ $# -eq 0 ] && { echo >&2 missing argument, type $NAME_ -h for help; exit 1; }
   # var init
   verbose=
   width=
   # option and arg handling
   while getopts vhlw: options; do
      case $options in
      v) verbose=on ;;
      w) width=$OPTARG ;;
      h) usage ;;
      l) more $0; exit 1 ;;
         \?) echo invalid argument, type $NAME_ -h for help; exit 1 ;;
      esac
   done
   shift $(( $OPTIND - 1 ))
   # check if required command is in $PATH variable
   which mogrify &> /dev/null
   [[ $? != 0 ]] && { echo >&2 the required ImageMagick \"mogrify\" command \
   is not in your PATH variable; exit 1; }
   for a in "$@";do
      gfx_resizeImage $width $a
      [[ $verbose ]] && echo ${NAME_}: $a
   done
}

###### Optimize PNG files
function pngoptim()
{
         NAME_="pngoptim"
         HTML_="optimize png files"
      PURPOSE_="reduce the size of a PNG file if possible"
      SYNOPSIS_="$NAME_ [-hl] <file> [file...]"
      REQUIRES_="standard GNU commands, pngcrush"
      VERSION_="1.0"
         DATE_="2004-06-29; last update: 2004-12-30"
       AUTHOR_="Dawid Michalczyk <dm@eonworks.com>"
      URL_="www.comp.eonworks.com"
      CATEGORY_="gfx"
      PLATFORM_="Linux"
        SHELL_="bash"
    DISTRIBUTE_="yes"
   # This program is distributed under the terms of the GNU General Public License
   usage() {
   echo >&2 "$NAME_ $VERSION_ - $PURPOSE_
   Usage: $SYNOPSIS_
   Requires: $REQUIRES_
   Options:
       -h, usage and options (this help)
       -l, see this script"
   exit 1
   }
   # tmp file set up
   tmp_1=/tmp/tmp.${RANDOM}$$
   # signal trapping and tmp file removal
   trap 'rm -f $tmp_1 >/dev/null 2>&1' 0
   trap "exit 1" 1 2 3 15
   # var init
   old_total=0
   new_total=0
   # arg handling and main execution
   case "$1" in
      -h) usage ;;
      -l) more $0; exit 1 ;;
       *.*) # main execution
      # check if required command is in $PATH variable
      which pngcrush &> /dev/null
      [[ $? != 0 ]] && { echo >&2 required \"pngcrush\" command is not in your PATH; exit 1; }
      for a in "$@";do
         if [ -f $a ] && [[ ${a##*.} == [pP][nN][gG] ]]; then
             old_size=$(ls -l $a | { read b c d e f g; echo $f ;} )
             echo -n "${NAME_}: $a $old_size -> "
             pngcrush -q $a $tmp_1
             rm -f -- $a
             mv -- $tmp_1 $a
             new_size=$(ls -l $a | { read b c d e f g; echo $f ;} )
             echo $new_size bytes
             (( old_total += old_size ))
             (( new_total += new_size ))
         else
             echo ${NAME_}: file $a either does not exist or is not a png file
         fi
      done ;;
      *) echo ${NAME_}: skipping $1 ; continue ;;
   esac
   percentage=$(echo "scale = 2; ($new_total*100)/$old_total" | bc)
   reduction=$(echo $(( old_total - new_total )) \
   | sed '{ s/$/@/; : loop; s/\(...\)@/@.\1/; t loop; s/@//; s/^\.//; }')
   echo "${NAME_}: total size reduction: $reduction bytes (total size reduced to ${percentage}%)"
}

###### replaces a color in PDF document (useful for removing dark background for printing)
# usage:   pdf_uncolor input.pdf output.pdf
function pdf_uncolor()
{
   convert -density 300 "$1" -fill "rgb(255,255,255)" -opaque "rgb(0,0,0)" "$2"
}

###### Convert text file to pdf
# Requires:txt2html python-pisa
function txt2pdf() { 
   xhtml2pdf -b "${1%.*}" < <(txt2html "$1");
}

###### Resizing an image
# USAGE: image_resize "percentage of image resize" "input image" "output image"
function image_resize()
{
   convert -sample "$1"%x"$1"% "$2" "$3"
}
###############################################################################
# Weather and stuff
###############################################################################
###### get sunrise and sunset times
function suntimes()
{
   l=12765843;curl -s http://weather.yahooapis.com/forecastrss?w=$l|grep astronomy| awk -F\" '{print $2 "\n" $4;}'
}

###### weather by US zip code - Can be called two ways   weather 50315, weather "Des Moines"
function weather()
{
   declare -a WEATHERARRAY
   WEATHERARRAY=( `lynx -dump http://google.com/search?q=weather+$1 | grep -A 5 '^ *Weather for' | grep -v 'Add to'`)
   echo ${WEATHERARRAY[@]}
}

###### track flights from the command line (requires html2text)
function flight_status() { if [[ $# -eq 3 ]];then offset=$3; else offset=0; fi; curl "http://mobile.flightview.com/TrackByRoute.aspx?view=detail&al="$1"&fn="$2"&dpdat=$(date +%Y%m%d -d ${offset}day)" 2>/dev/null |html2text |grep ":"; }

###### Stock prices - can be called two ways:
# stock novl  (this shows stock pricing):
# stock "novell"  (this way shows stock symbol for novell)
function stock()
{
   stockname=`lynx -dump http://www.google.com/finance?q=${1} | grep -i ":${1})" | sed -e 's/Delayed.*$//'`
   stockadvise="${stockname} - delayed quote."
   declare -a STOCKINFO
   STOCKINFO=(` lynx -dump http://www.google.com/finance?q=${1} | egrep -i "52 week"`)
   stockdata=`echo ${STOCKINFO[@]}`
   if [[ ${#stockname} != 0 ]] ;then
      echo "${stockadvise}"
      echo "${stockdata}"
   else
      stockname2=${1}
      lookupsymbol=`lynx -dump -nolist http://www.google.com/finance?q="${1}" | grep -A 1 -m 1 "Portfolio" | grep -v "Portfolio" | sed 's/\(.*\)Add/\1 /'`
      if [[ ${#lookupsymbol} != 0 ]] ;then
          echo "${lookupsymbol}"
      else
         echo "Sorry $USER, I can not find ${1}."
       fi
   fi
}

###############################################################################
# Randomness
###############################################################################
###### This script models Brownian motion:
# random wanderings of tiny particles in fluid, as they are buffeted
# by random currents and collisions (colloquially known as "Drunkard's Walk")
# Author: Mendel Cooper
function brownian()
{
   PASSES=500                  #  Number of particle interactions / marbles.
   ROWS=10                     #  Number of "collisions" (or horiz. peg rows).
   RANGE=3                     #  0 - 2 output range from $RANDOM.
   POS=0                       #  Left/right position.
   RANDOM=$$                   #  Seeds the random number generator from PID of script.
   declare -a Slots            # Array holding cumulative results of passes.
   NUMSLOTS=21                 # Number of slots at bottom of board.
   function Initialize_Slots() {    # Zero out all elements of the array.
   for i in $( seq $NUMSLOTS )
   do
     Slots[$i]=0
   done
   echo                        # Blank line at beginning of run.
     }
   function Show_Slots() {
   echo -n " "
   for i in $( seq $NUMSLOTS )      # Pretty-print array elements.
   do
     printf "%3d" ${Slots[$i]}      # Allot three spaces per result.
   done
   echo             # Row of slots:
   echo " |__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|"
   echo "                                ^^"
   echo             #  Note that if the count within any particular slot exceeds 99,
                   #+ it messes up the display.
                   #  Running only(!) 500 passes usually avoids this.
     }
   function Move() {                 # Move one unit right / left, or stay put.
     Move=$RANDOM               # How random is $RANDOM? Well, let's see ...
     let "Move %= RANGE"        # Normalize into range of 0 - 2.
     case "$Move" in
      0 ) ;;                 # Do nothing, i.e., stay in place.
      1 ) ((POS--));;        # Left.
      2 ) ((POS++));;        # Right.
      * ) echo -n "Error ";;      # Anomaly! (Should never occur.)
     esac
     }
   function Play() {               # Single pass (inner loop).
   i=0
   while [ "$i" -lt "$ROWS" ]      # One event per row.
   do
     Move
     ((i++));
   done
   SHIFT=11                        # Why 11, and not 10?
   let "POS += $SHIFT"             # Shift "zero position" to center.
   (( Slots[$POS]++ ))             # DEBUG: echo $POS
     }
   function Run() {                # Outer loop.
   p=0
   while [ "$p" -lt "$PASSES" ]
   do
     Play
     (( p++ ))
     POS=0                         # Reset to zero. Why?
   done
     }
   # main()
   Initialize_Slots
   Run
   Show_Slots
}

###### flip a single coin 1000 times and show results
function coin-flip()
{
   SEED=$"(head -1 /dev/urandom | od -N 1 | awk '{ print $2 }')"
   RANDOM=$SEED
   SIDES=2             # A coin has 2 sides.
   MAXTHROWS=1000      # Increase this if you have nothing better to do with your time.
   throw=0            # Throw count.
   heads=0             # Must initialize counts to zero,
   tails=0             # since an uninitialized variable is null, not zero.
   function print_result()
   {
      echo
      echo "heads =   $heads"
      echo "tails =   $tails"
      echo
   }
   function update_count()
   {
      case "$1" in
        0) let "heads += 1";; # Since coin has no "zero", this corresponds to 1.
        1) let "tails += 1";; # And this to 2, etc.
      esac
   }
   echo
   while [ "$throw" -lt "$MAXTHROWS" ]
   do
   let "coin1 = RANDOM % $SIDES"
   update_count $coin1
   let "throw += 1"
   done
   print_result
   echo "Out of a total of "$MAXTHROWS" tosses."
   echo "Change \"MAXTHROWS=1000\" if you want a different number of tosses."
}

###### roll a single die of "$1" sides, just once
# default number of sides is 6
# written by Dallas Vogels
function one-die()
{
   function roll_die() {
     # capture parameter
     declare -i DIE_SIDES=$1
     # check for die sides
     if [ ! $DIE_SIDES -gt 0 ]; then
      # default to 6
      DIE_SIDES=6
     fi
     # echo to screen
     echo $[ ( $RANDOM % $DIE_SIDES )  + 1 ]
   }
   # roll_die 10  # returns 1 to 10 as per 10 sides
   # roll_die 2   # returns 1 or 2 as per 2 sides
   roll_die "$1"
}

###### select random card from a deck
function pick-card()
{
   # This is an example of choosing random elements of an array.
   # Pick a card, any card.
   Suites="Clubs
   Diamonds
   Hearts
   Spades"
   Denominations="2
   3
   4
   5
   6
   7
   8
   9
   10
   Jack
   Queen
   King
   Ace"
   # Note variables spread over multiple lines.
   suite=($Suites)                # Read into array variable.
   denomination=($Denominations)
   num_suites=${#suite[*]}        # Count how many elements.
   num_denominations=${#denomination[*]}
   echo -n "${denomination[$((RANDOM%num_denominations))]} of "
   echo ${suite[$((RANDOM%num_suites))]}
   # $bozo sh pick-cards.sh
   # Jack of Clubs
   # Thank you, "jipe," for pointing out this use of $RANDOM.
}

###### random number (out of whatever you input)
# example:   random 10   =   4
# copyright 2007 - 2010 Christopher Bratusek
function random() {
   if [[ $1 == -l ]]; then
      echo $(cat /dev/urandom | tr -cd '[:digit:]' | head -c ${2-5})
   elif [[ $1 == -r ]]; then
      echo $((RANDOM%${2}))
   else
      echo $((RANDOM%${1}))
   fi
}

###############################################################################
# Google searching
###############################################################################
###### convert currencies
# usage:   currency_convert 1 usd eur
# for currency shorthand: http://www.xe.com/currency/
function currency_convert() { 
    if [ $# -lt 3 ]; then
      echo "convert currencies"
      echo "usage: currency_convert [amount] [crrency from] [currency to]"
      currency_convert_help
    else
      (wget -qO- "http://www.google.com/finance/converter?a=$1&from=$2&to=$3&hl=es" | sed '/res/!d;s/<[^>]*>//g')
    fi
}

function currency_convert_help() {
   echo "AED - Emirati Dirham
   AFN - Afghan Afghani
   ALL - Albanian Lek
   AMD - Armenian Dram
   ANG - Dutch Guilder
   AOA - Angolan Kwanza
   ARS - Argentine Peso
   AUD - Australian Dollar
   AWG - Aruban or Dutch Guilder
   AZN - Azerbaijani New Manat
   BAM - Bosnian Convertible Marka
   BBD - Barbadian or Bajan Dollar
   BDT - Bangladeshi Taka
   BGN - Bulgarian Lev
   BHD - Bahraini Dinar
   BIF - Burundian Franc
   BMD - Bermudian Dollar
   BND - Bruneian Dollar
   BOB - Bolivian Boliviano
   BRL - Brazilian Real
   BSD - Bahamian Dollar
   BTN - Bhutanese Ngultrum
   BWP - Batswana Pula
   BYR - Belarusian Ruble
   BZD - Belizean Dollar
   CAD - Canadian Dollar
   CDF - Congolese Franc
   CHF - Swiss Franc
   CLP - Chilean Peso
   CNY - Chinese Yuan Renminbi
   COP - Colombian Peso
   CRC - Costa Rican Colon
   CUC - Cuban Convertible Peso
   CUP - Cuban Peso
   CVE - Cape Verdean Escudo
   CZK - Czech Koruna
   DJF - Djiboutian Franc
   DKK - Danish Krone
   DOP - Dominican Peso
   DZD - Algerian Dinar
   EEK - Estonian Kroon
   EGP - Egyptian Pound
   ERN - Eritrean Nakfa
   ETB - Ethiopian Birr
   EUR - Euro
   FJD - Fijian Dollar
   FKP - Falkland Island Pound
   GBP - British Pound
   GEL - Georgian Lari
   GGP - Guernsey Pound
   GHS - Ghanaian Cedi
   GIP - Gibraltar Pound
   GMD - Gambian Dalasi
   GNF - Guinean Franc
   GTQ - Guatemalan Quetzal
   GYD - Guyanese Dollar
   HKD - Hong Kong Dollar
   HNL - Honduran Lempira
   HRK - Croatian Kuna
   HTG - Haitian Gourde
   HUF - Hungarian Forint
   IDR - Indonesian Rupiah
   ILS - Israeli Shekel
   IMP - Isle of Man Pound
   INR - Indian Rupee
   IQD - Iraqi Dinar
   IRR - Iranian Rial
   ISK - Icelandic Krona
   JEP - Jersey Pound
   JMD - Jamaican Dollar
   JOD - Jordanian Dinar
   JPY - Japanese Yen
   KES - Kenyan Shilling
   KGS - Kyrgyzstani Som
   KHR - Cambodian Riel
   KMF - Comoran Franc
   KPW - Korean Won
   KRW - Korean Won
   KWD - Kuwaiti Dinar
   KYD - Caymanian Dollar
   KZT - Kazakhstani Tenge
   LAK - Lao or Laotian Kip
   LBP - Lebanese Pound
   LKR - Sri Lankan Rupee
   LRD - Liberian Dollar
   LSL - Basotho Loti
   LTL - Lithuanian Litas
   LVL - Latvian Lat
   LYD - Libyan Dinar
   MAD - Moroccan Dirham
   MDL - Moldovan Leu
   MGA - Malagasy Ariary
   MKD - Macedonian Denar
   MMK - Burmese Kyat
   MNT - Mongolian Tughrik
   MOP - Macau Pataca
   MRO - Mauritian Ouguiya
   MUR - Mauritian Rupee
   MVR - Maldivian Rufiyaa
   MWK - Malawian Kwacha
   MXN - Mexican Peso
   MYR - Malaysian Ringgit
   MZN - Mozambican Metical
   NAD - Namibian Dollar
   NGN - Nigerian Naira
   NIO - Nicaraguan Cordoba
   NOK - Norwegian Krone
   NPR - Nepalese Rupee
   NZD - New Zealand Dollar
   OMR - Omani Rial
   PAB - Panamanian Balboa
   PEN - Peruvian Nuevo Sol
   PGK - Papua New Guinean Kina
   PHP - Philippine Peso
   PKR - Pakistani Rupee
   PLN - Polish Zloty
   PYG - Paraguayan Guarani
   QAR - Qatari Riyal
   RON - Romanian New Leu
   RSD - Serbian Dinar
   RUB - Russian Ruble
   RWF - Rwandan Franc
   SAR - Saudi or Saudi Arabian Riyal
   SBD - Solomon Islander Dollar
   SCR - Seychellois Rupee
   SDG - Sudanese Pound
   SEK - Swedish Krona
   SGD - Singapore Dollar
   SHP - Saint Helenian Pound
   SLL - Sierra Leonean Leone
   SOS - Somali Shilling
   SPL - Seborgan Luigino
   SRD - Surinamese Dollar
   STD - Sao Tomean Dobra
   SVC - Salvadoran Colon
   SYP - Syrian Pound
   SZL - Swazi Lilangeni
   THB - Thai Baht
   TJS - Tajikistani Somoni
   TMT - Turkmenistani Manat
   TND - Tunisian Dinar
   TOP - Tongan Pa'anga
   TRY - Turkish Lira
   TTD - Trinidadian Dollar
   TVD - Tuvaluan Dollar
   TWD - Taiwan New Dollar
   TZS - Tanzanian Shilling
   UAH - Ukrainian Hryvna
   UGX - Ugandan Shilling
   USD - US Dollar
   UYU - Uruguayan Peso
   UZS - Uzbekistani Som
   VEF - Venezuelan Bolivar Fuerte
   VND - Vietnamese Dong
   VUV - Ni-Vanuatu Vatu
   WST - Samoan Tala
   XAF - Central African CFA Franc BEAC
   XCD - East Caribbean Dollar
   XDR - IMF Special Drawing Rights
   XOF - CFA Franc
   XPF - CFP Franc
   YER - Yemeni Rial
   ZAR - South African Rand
   ZMK - Zambian Kwacha
   ZWD - Zimbabwean Dollar"
}

###### find a location's coordinates
# usage:   findlocation "Las Vegas, Nevada" = coordinates: [ -115.1728160, 36.1146460, 0 ]
function findlocation() { place=`echo $1 | sed 's/ /%20/g'` ; curl -s "http://maps.google.com/maps/geo?output=json&oe=utf-8&q=$place" | grep -e "address" -e "coordinates" | sed -e 's/^ *//' -e 's/"//g' -e 's/address/Full Address/';}

###### Google search (example: google dog)
function google() {
   firefox "http://www.google.com/search?&num=100&q=${@}" &
}

###############################################################################
# Translation and Dictionary
###############################################################################
###### Lookup a word with dict.org
function dic() { 
   curl dict://dict.org/d:"$@" ; 
}


###### find matches of $1, with optional strat $2 and optional db $3
function ref()
{
    if [[ -z $3 ]]; then
      curl dict://dict.org/m:${1}:english:${2};
    else
      curl dict://dict.org/m:${1}:${3}:${2};
    fi
}

###### look in Webster
function webster() { 
   curl dict://dict.org/d:${1}:web1913; 
}


###### look in WordNet
function wordnet() { 
   curl dict://dict.org/d:${1}:wn;
}

###### define a word - USAGE: define dog
function define() {
   local LNG=$(echo $LANG | cut -d '_' -f 1)
   local CHARSET=$(echo $LANG | cut -d '.' -f 2)
   lynx -accept_all_cookies -dump -hiddenlinks=ignore -nonumbers -assume_charset="$CHARSET" -display_charset="$CHARSET" "http://www.google.com/search?hl=${LNG}&q=define%3A+${1}&btnG=Google+Search" | grep -m 5 -C 2 -A 5 -w "*" > /tmp/define
   if [ ! -s /tmp/define ]; then
      echo "Sorry, google doesn't know this one..."
      rm -f /tmp/define
      return 1
   else
      cat /tmp/define | grep -v Search
      echo ""
   fi
   rm -f /tmp/define
   return 0
}

###### detect language of a string
function detectlanguage() { 
   curl -s "http://ajax.googleapis.com/ajax/services/language/detect?v=1.0&q=$@" | sed 's/{"responseData": {"language":"\([^"]*\)".*/\1\n/'; 
}


###### Google text-to-speech in mp3/wav format
function say() { 
   mplayer -user-agent Mozilla "http://translate.google.com/translate_tts?tl=en&q=$(echo $* | sed 's#\ #\+#g')" > /dev/null 2>&1 ;
}


###### translate a word using Google
# usage: translate <phrase> <output-language>
# example: translate "hello" es = hola (will auto-detect source language)
# for a list of language codes: http://en.wikipedia.org/wiki/List_of_ISO_639-1_codes
function translate() { 
   wget -qO- "http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&q=$1&langpair=%7C${2:-en}" | sed 's/.*{"translatedText":"\([^"]*\)".*/\1\n/'; 
}

function translate_help() {
   echo"Language   ISO
   (Afan) Oromo           om
   Abkhazian              ab
   Afar                   aa
   Afrikaans              af
   Albanian               sq
   Amharic                am
   Arabic                 ar
   Armenian               hy
   Assamese               as
   Aymara                 ay
   Azerbaijani            az
   Bashkir                ba
   Basque                 eu
   Bengali                bn
   Bhutani                dz
   Bihari                 bh
   Bislama                bi
   Breton                 br
   Bulgarian              bg
   Burmese                my
   Byelorussian           be
   Cambodian              km
   Catalan                ca
   Chinese                zh
   Corsican               co
   Croatian               hr
   Czech                  cs
   Danish                 da
   Dutch                  nl
   English                en
   Esperanto              eo
   Estonian               et
   Faeroese               fo
   Fiji                   fj
   Finnish                fi
   French                 fr
   Frisian                fy
   Galician               gl
   Georgian               ka
   German                 de
   Greek                  el
   Greenlandic            kl
   Guarani                gn
   Gujarati               gu
   Hausa                  ha
   Hebrew                 he (former iw) 
   Hindi                  hi
   Hungarian              hu
   Icelandic              is
   Indonesian             id (former in)
   Interlingua            ia
   Interlingue            ie
   Inupiak                ik
   Inuktitut (Eskimo)     iu
   Irish                  ga
   Italian                it
   Japanese               ja
   Javanese               jw
   Kannada                kn
   Kashmiri               ks
   Kazakh                 kk
   Kinyarwanda            rw
   Kirghiz                ky
   Kirundi                rn
   Korean                 ko
   Kurdish                ku
   Laothian               lo
   Latin                  la
   Latvian, Lettish       lv
   Lingala                ln
   Lithuania              lt
   Macedonia              mk
   Malagasy               mg
   Malay                  ms
   Malayalam              ml
   Maltese                mt
   Maori                  mi
   Marathi                mr
   Moldavian              mo
   Mongolian              mn
   Nauru                  na
   Nepali                 ne
   Norwegian              no
   Occitan                oc
   Oriya                  or
   Pashto, Pushto         ps
   Persian                fa
   Polish                 pl
   Portuguese             pt
   Punjabi                pa
   Quechua                qu
   Rhaeto-Romance         rm
   Romanian               ro
   Russian                ru
   Samoan                  sm
   Sangro                 sg
   Sanskrit               sa
   Scots Gaelic           gd
   Serbian                sr
   Serbo-Croatian         sh
   Sesotho                st
   Setswana               tn
   Shona                  sn
   Sindhi                 sd
   Singhalese             si
   Siswati                ss
   Slovak                 sk
   Slovenian              sl
   Somali                 so
   Spanish                es
   Sudanese               su
   Swahili                sw
   Swedish                sv
   Tagalog                tl
   Tajik                  tg
   Tamil                  ta
   Tatar                  tt
   Tegulu                 te
   Thai                   th
   Tibetan                bo
   Tigrinya               ti
   Tonga                  to
   Tsonga                 ts
   Turkish                tr
   Turkmen                tk
   Twi                    tw
   Uigur                  ug
   Ukrainian              uk
   Urdu                   ur
   Uzbek                  uz
   Vietnamese             vi
   Volapuk                vo
   Welch                  cy
   Wolof                  wo
   Xhosa                  xh
   Yiddish                yi (former ji)
   Yoruba                 yo
   Zhuang                 za
   Zulu                   zu"
}

###############################################################################
# Commandlinefu.com and Shell-fu.org stuff
###############################################################################

###### Search commandlinefu.com from the command line
# using the API
# Usage: cmdfu hello world
function cmdfu() { 
   curl "http://www.commandlinefu.com/commands/matching/$@/$(echo -n $@ | openssl base64)/plaintext"; 
}

###### automatically downloads all commands from http://www.commandlinefu.com into a single text file
alias cmdfu_dl='mkdir /tmp/commandlinefu && cd /tmp/commandlinefu && curl -O http://www.commandlinefu.com/commands/browse/sort-by-votes/plaintext/[0-2400:25] && ls -1 | sort -n | while read mork ; do cat $mork >> commandlinefu.txt ; ls -ald $mork; done && mv commandlinefu.txt $HOME && rm -rf /tmp/commandlinefu'

###### find a CommandlineFu users average command rating
function cmdfu_rating()
{
   wget -qO- www.commandlinefu.com/commands/by/PhillipNordwall | awk -F\> '/class="num-votes"/{S+=$2; I++}END{print S/I}'
}

function cmdfu_rating_()
{
   curl -s www.commandlinefu.com/commands/by/PhillipNordwall | awk -F\> '/class="num-votes"/{S+=$2; I++}END{print S/I}'
}

###### fuman, an alternative to the 'man' command that shows commandlinefu.com examples
function fuman() {
   lynx -width=$COLUMNS -nonumbers -dump "http://www.commandlinefu.com/commands/using/$1" |sed '/Add to favourites/,/This is sample output/!d' |sed 's/ *Add to favourites/----/' |less -r; 
}

###### Random Commandlinefu command
function fur() { 
   curl -sL 'http://www.commandlinefu.com/commands/random/plaintext' | grep -v "^# commandlinefu" ; 
}

###### Prepare a commandlinefu command
function goclf()
{
   type "$1" | sed '1d' | tr -d "\n" | tr -s '[:space:]'; echo
}

###############################################################################
# Fun
###############################################################################
###### Have your sound card call out elapsed time. By http://www.commandlinefu.com/commands/by/claudelepoisson
function tellElapsedTime {
   for ((x=0;;x+=$1)); do sleep $1; espeak $x & done
}

###### pretend to be busy in office to enjoy a cup of coffee
function grepcolor()
{
   cat /dev/urandom | hexdump -C | grep --color=auto "ca fe"
}

###### fake error string
function error()
{
   while true; do awk '{ print ; system("let R=$RANDOM%10; sleep $R") }' compiler.log; done
}

###### View daily comics (set on Viewnior as image viewer...can use 'eog' or whatever instead)
function comics() {
   # xkcd
   XKCD_FILE="/tmp/xkcd"
   wget -q $(curl -s http://xkcd.com/ | sed -n 's/<h3>Image URL.*: \(.*\)<\/h3>/\1/p') -O $XKCD_FILE
   # Geek and Poke
   GAP_FILE="/tmp/geekandpoke"
   wget -q $(lynx --dump 'http://geekandpoke.typepad.com/' | grep '\/.a\/' | grep '\-pi' | head -n 1 | awk '{print $2}') -O $GAP_FILE
   viewnior $XKCD_FILE
   viewnior $GAP_FILE
}

###############################################################################
# Gnome
###############################################################################
gnome-extensiones-enable() {
   localPath=~/.local/share/gnome-shell/extensions/
   for i in $localPath/*;do echo $(basename $i);gnome-extensions enable "$(basename $i)";done
   gnome-extensions enable GPaste@gnome-shell-extensions.gnome.org
   gnome-extensions enable gnome-shell-extensions.gcampax.github.com
}