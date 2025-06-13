#!/bin/bash

#set -x

address=""
count=""

usage()
{
  echo "Usage: $0 -a [address] -c [count] -h"
  echo "-a [address]  set ipv4 address to ping in format <255.255.255.255>"
  echo "-c [count]  set count of ipng messages"
  echo "-h (help) to see this message"
}

exit_abnormal()
{
  usage
  exit 1
}

while getopts ":a:c:h" options; do   

  case "${options}" in
    a)
      address=${OPTARG}

      addrRegexp='^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'

      if ! [[ $address =~ $addrRegexp ]]
      then
        exit_abnormal
      fi
    ;;

    c)
      count=${OPTARG}
      countRegexp='^[1-9][0-9]{0,3}$'

      if ! [[ $count =~ $countRegexp ]]
      then
        exit_abnormal
      fi
    ;;

    h)
      usage
      exit 0
    ;;

    :)
      echo "Error: -${OPTARG} requires an argument."
      exit_abnormal
    ;;

    *)
      exit_abnormal
    ;;
  esac
done


if ping "$address" -c "$count" -q > ping.txt;
then
  echo "Ping succeed!"
else
  errorText=$(cat ping.txt)

  errIp=$(awk 'NR==1 {print $2}' <<< "$errorText")
  pkgLoss=$(awk -F "," 'NR==4 {print $3, $NF}' <<< "$errorText")
  wstdTime=$(awk 'NR==4 {print $NF}' <<< "$errorText")

  echo -e "Ping failed! \n addr: $errIp \n pkg loss: $pkgLoss \n wasted time: $wstdTime "
fi
