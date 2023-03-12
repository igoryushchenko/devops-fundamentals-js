#!/bin/bash

# check if user provided threshold value, otherwise set default
if [ $# -eq 0 ]
  then
    threshold=10
  else
    threshold=$1
fi

# loop to continuously check free disk space
while true
do
  free=$(df / | awk '{print $4}' | tail -n 1) # get free disk space in root directory
  if [ $free -lt $threshold ]
  then
    echo "WARNING: Free disk space below threshold of $threshold MB"
  fi
  sleep 2m # wait for 5 minutes before checking again
done