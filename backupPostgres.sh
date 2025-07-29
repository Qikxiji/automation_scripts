#!/usr/bin/env bash

#security flags
set -eu

#variables
DB_NAMES=("name_1" "name_2")
DATE=$(date +"%Y-%m-%d_%H-%M")
LOG_PATH=/var/log/postgresql/backup.log
BACKUP_DIR=/var/lib/postgresql/backup
BACKUP_USER=postgres

#loop for every single db in $DB_NAMES list
for i in "${DB_NAMES[@]}";
do
  #write log about begin db backup in $LOG_PATH
  echo "$(date +"%Y-%m-%d_%H-%M-%S") begin backup $i" >> $LOG_PATH

  #make dump by $USER, save in $BACKUP_DIR, named with $DATE.
  #errors forwarded to $LOG_PATH 
  pg_dump -U $BACKUP_USER $i > $BACKUP_DIR/$DATE-$i.sql 2>> $LOG_PATH

  #if dump succeed, pg_dump make "dump complete" message in the end of dump.
  #Checking for this message. If it is $DUMP_SUCCEED=1, otherwise $DUMP_SUCCEED=0
  DUMP_SUCCEED=$(tail -n 5 $BACKUP_DIR/$DATE-$i.sql | grep "^-- PostgreSQL database dump complete$" | wc -l)
  if [[ $DUMP_SUCCEED == 1 ]]
  then
    #logging success
    echo "Backup ${i} SUCCEED!" >> $LOG_PATH

    #if dump succeed, make gzip copy of dump, remove default dump
    gzip -c $BACKUP_DIR/$DATE-$i.sql > $BACKUP_DIR/$DATE-$i.sql.gz
    rm $BACKUP_DIR/$DATE-$i.sql
  else
    #else logging fail
    echo "Backup ${i} FAILED!" >> $LOG_PATH
  fi
  #logging finish of backup
  echo "$(date +"%Y-%m-%d_%H-%M-%S") end backup $i" >> $LOG_PATH
  echo "--------------------------------------------------" >> $LOG_PATH
done