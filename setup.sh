#!/bin/bash
# read the option and store in the variable, $option
TARGETDIR=~
DEFAULTPROFILE=personal
RESTOW=

# Function: Print a help message.
usage() {
  echo "Usage: $0 [ -p PRFOILE ] -R PACKAGNAME|all" 1>&2 
}

# Function: Exit with error.
exit_abnormal() {
  usage
  exit 1
}

while getopts "Rp:" option; do
   case ${option} in
      R )
         echo "do a 'restow' i.e. stow -D followed by stow -S"
         RESTOW="-R"
         ;;
      p )
         PROFILE=${OPTARG}
         echo "profile '$PROFILE' selected\n"c
         ;;
      \? )
         exit_abnormal
      ;;
      *)
         exit_abnormal
      ;;
    esac
done

if [ ! $PROFILE ]; then
   if [ $DEFAULTPROFILE ]; then
      echo "using default profile '$DEFAULTPROFILE'"
      PROFILE=$DEFAULTPROFILE
   else
      echo "-p PROFILE was not specified"
      exit_abnormal
   fi
fi

SOURCE=$(pwd)/$PROFILE
if [ ! -d "$SOURCE" ]; then
   echo "Invalid profile '$PROFILE' (path '$SOURCE' missing)"
   exit_abnormal
fi

pushd $SOURCE

shift $(($OPTIND - 1))
echo arguments $1
if [ ! $1 ]; then
   printf "no packages specified. you can use 'all' if you want to install all from the profile"
   exit_abnormal
else
   PACKAGE=$SOURCE/$1
   case $1 in
      all )
         echo "Install all available packages"
         for filename in *; do
            #stow $filename -t $TARGETDIR
            echo $RESTOW $filename
         done
         ;;
      p )
         PROFILE=${OPTARG}
         echo "profile '$PROFILE' selected\n"c
         ;;
      *)
         exit_abnormal
      ;;
    esac   

fi





