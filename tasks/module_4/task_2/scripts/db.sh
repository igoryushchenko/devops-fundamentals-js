#!/bin/bash

typeset fileName=users.db
typeset fileDir=../data
typeset filePath=$fileDir/$fileName

# Check if users.db exists
if [[ "$1" != "help" && "$1" != "" && ! -f ../data/users.db ]]; then
  # Prompt user to confirm creation of users.db
  read -r -p "users.db file not found. Do you want to create it now? [Y/n]" confirm
  if [[ $confirm =~ ^[Yy]$ ]]; then
    touch $filePath
    echo "$fileName created successfully."
  else
    echo "Aborted. Cannot proceed with initial operation without $fileName."
    exit 1
  fi
fi

validate_latin_letters() {
  if [[ $1 =~ ^[[:alpha:]]+$ ]]; then
    return 0
  else
    return 1
  fi
}

add() {
  read -p "Enter user name: " username
  validate_latin_letters $username
  if [[ "$?" == 1 ]]; then
    echo "Name must have only latin letters. Try again."
    exit 1
  fi

  read -p "Enter user role: " role
  validate_latin_letters $role
  if [[ "$?" == 1 ]]; then
    echo "Role must have only latin letters. Try again."
    exit 1
  fi

  echo "${username}, ${role}" | tee -a $filePath
}

backup() {
  backupFileName=$(date +'%Y-%m-%d-%H-%M-%S')-users.db.backup
  cp $filePath $fileDir/$backupFileName

  echo "Backup is created."
}

restore() {
  latestBackupFile=$(ls $fileDir/*-$fileName.backup | tail -n 1)

  if [[ ! -f $latestBackupFile ]]; then
    echo "No backup file found."
    exit 1
  fi

  cat $latestBackupFile >$filePath

  echo "Backup is restored."
}

search() {
  read -p "Enter username to search: " username

  awk -F, -v x=$username '$1 ~ x' ../data/users.db

  if [[ "$?" == 1 ]]; then
    echo "User not found."
    exit 1
  fi
}

inverseParam=$2
list() {
  if [[ $inverseParam == "--inverse" ]]; then
    cat --number $filePath | tac
  else
    cat --number $filePath
  fi
}

help() {
  # Display Help
  echo "Manages users in db. It accepts a single parameter with a command name."
  echo
  echo "Syntax: db.sh [command]"
  echo "options:"
  echo "add       Adds a new line to the users.db. Script must prompt user to type a
                    username of new entity. After entering username, user must be prompted to
                    type a role."
  echo "backup    Creates a new file, named" $filePath".backup which is a copy of
                    current" $fileName
  echo "find      Prompts user to type a username, then prints username and role if such
                    exists in users.db. If there is no user with selected username, script must print:
                    “User not found”. If there is more than one user with such username, print all
                    found entries."
  echo "list      Prints contents of $fileName in format: N. username, role
                    where N – a line number of an actual record
                    Accepts an additional optional parameter inverse which allows to get
                    result in an opposite order – from bottom to top"
  echo
}

case $1 in
add) add ;;
backup) backup ;;
restore) restore ;;
find) search ;;
list) list ;;
help | '' | *) help ;;
esac
