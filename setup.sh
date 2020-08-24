#!/bin/bash
# read the option and store in the variable, $option
TARGETDIR=~/
DEFAULTPROFILE=personal
RESTOW=
ADOPT=

# Function: Print a help message.
usage() {
  echo "Usage: $0 [ -p PRFOILE ] -R PACKAGNAME|all" 1>&2 
}

# Function: Exit with error.
exit_abnormal() {
  usage
  exit 1
}

while getopts "aRDp:" option; do
   case ${option} in
      a )
         echo "do an 'adopt'"
         ADOPT="--adopt --override='.*'"
         ;;
      R )
         echo "do a 'restow' i.e. stow -D followed by stow -S"
         RESTOW="-R"
         ;;
      D )
         echo "delete i.e. stow -D followed by stow -S"
         DELETE="-R"
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
if [ ! $1 ]
then
   echo "no packages specified. syou can use 'all' if you want to install all from the profile or use one of these:"
   echo $(ls)
   exit_abnormal
else
   PACKAGE=$1
   if [ $PACKAGE == "all" ]
   then
      echo "Install all available packages"
      for filename in *; do
         echo stow $RESTOW $DELETE $ADOPT $filename -t $TARGETDIR
         stow $RESTOW $DELETE $ADOPT $filename -t $TARGETDIR
      done
   elif [ -d "./$PACKAGE" ]
   then
      echo stow $RESTOW $DELETE $ADOPT $PACKAGE -t $TARGETDIR
      stow $RESTOW $DELETE $ADOPT $PACKAGE -t $TARGETDIR
   else
      echo "package '$PACKAGE' missing"
   fi
fi

popd