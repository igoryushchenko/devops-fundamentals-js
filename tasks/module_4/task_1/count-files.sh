#!/bin/bash

# loop over all arguments
for directory in $@
do
  # check if directory exists
  if [ -d $directory ]
  then
    # count number of files recursively in directory and its subdirectories
    num_files=$(find $directory -type f | wc -l)
    echo "Directory $directory contains $num_files files."
  else
    echo "Directory $directory does not exist."
  fi
done