#!/bin/bash
# read the option and store in the variable, $option
while getopts ":f" option; do
    case ${option} in
    f ) #For option f
    echo "Force creating symlinks, i.e. override existing files"
    force="f"
    ;;
    \? ) #For invalid option
    echo "You have to use: [-f] "
    ;;
    esac
done
for filename in .*; do
    echo Make symbolic link for $filename
    ln -s$force $(pwd)/$filename ~/$filename
done