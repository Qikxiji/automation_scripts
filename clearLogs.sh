#!/usr/bin/env bash

##############_FLAGS_###############
#set "security" flags
set -eu


############_VARIABLES_############
#dir to be backuped
LOG_PATH=""


############_FUNCTIONS_############
#func to describe options
usage()
{
  echo -e "Usage: $0 -h -p [/path/to/dir]\n"
  echo "Enter \"bash clearUserJournal.sh -p [/var/log/...]\" to clear log dir"
  echo -e "Enter \"bash clearUserJournal.sh -h\" to see help (this) message\n"
  echo "Script removes ALL FILES from /path/to/dir older than 7 day (not inclusive)"
  echo "/path/to/dir must starts with \"/var/log/\" and exist."
}

#func to prevent rm anything other than logs
secureFilesystem()
{
  if ! grep "/var/log/.*" <<< "$LOG_PATH";
  then
    echo "script is using only for dir inside /var/log/ (not $LOG_PATH)"
    echo "change input for -p option to correct."
    exit 1
  fi
}


#############_MAIN_##############
#script must take an argument
if [[ $# -eq 0 ]]
then
  echo "Invalid argument. Script stopped."
  exit 1
fi

#getopts construction to safe argument handling
# -p takes path to log dir
# -h show help message
# other options are rejected 
while getopts ":p:h" options; do   

  case "${options}" in
    p)
      LOG_PATH=${OPTARG}
      secureFilesystem
    ;;

    h)
      usage
      exit 0
    ;;

    :)
      echo "Error: -${OPTARG} requires an argument."
      exit 1
    ;;

    *)
      echo "Invalid argument. Script stopped."
      exit 1
    ;;
  esac
done

#take current size of dir
currentSize=$(awk '{print $1}' <<< "$(du -sm "$LOG_PATH" 2> /dev/null)")

#find all files in dir (recursively) older than 2 days before toady and remove silent (-f)
find "$LOG_PATH" -type f -mtime +7 -exec rm -f {} \;

#take new size of dir
newSize=$(awk '{print $1}' <<< "$(du -sm "$LOG_PATH" 2> /dev/null)")

#count diff
freedSize=$((currentSize - newSize))

#print diff and succeed message
echo -e "\n freed $freedSize Mb from $LOG_PATH by log clearing"
