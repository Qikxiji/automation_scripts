#!/usr/bin/env bash

##############_FLAGS_###############
#set "security" flags
set -eu


############_VARIABLES_############
#dir to be backuped
BACKUP_SOURCE="/home/qikxiji/1study/scripts"

#dir to store backups
BACKUP_LOCATION="/home/qikxiji/1study/backups debil"


############_FUNCTIONS_############
#usage function to describe script
usage()
{
  echo "This script backup dir defined in var \$BACKUP_PATH to dir \$BACKUP_LOCATION"
  echo "Backups saving in format \"scripts_backup_YYYY-MM-DD_HH:MM\""
  echo "Usage: $0 -h or $0"
  echo ""
}


#############_MAIN_##############
#check input params. Accept nothing or -h
if [[ $# -gt 0 ]]
then
  if [[ "$1" == "-h" ]]
  then
    usage
    exit 0
  else
    echo "Error! Script does not accept parameters except for -h"
    exit 1
  fi

fi

#create backup location (if not exist) 
mkdir -p $BACKUP_LOCATION

#build backup file name
DATE=$(date +"%F_%R")
BACKUP_NAME="scripts_backup_$DATE.tar.gz"

#backup, output confirm
if tar -Pczf "$BACKUP_LOCATION/$BACKUP_NAME" "$BACKUP_SOURCE";
then
  echo "Backup created successfully: $BACKUP_LOCATION/$BACKUP_NAME"
fi

