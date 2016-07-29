#!/usr/bin/bash

LOCKFILE=~/workspace/drew/.lock

if [ $# -ne 1 ]; then
    echo "lock.sh must have exactly 1 arg"
    exit 1
fi

MODE="$1"

if [ "$MODE" == "--acquire" ]; then
    if [ -f $LOCKFILE ]; then
        echo "Lock file: '.lock' file exists, is someone running terraform?"
        exit 2
    fi
    touch $LOCKFILE;

elif [ "$MODE" == "--release" ]; then
    if [ -f $LOCKFILE ]; then
        rm $LOCKFILE
    else
        echo "There is no lock to release!"
        exit 3
    fi

else
    echo "Invalid argument for lock.sh"
    exit 4
fi





