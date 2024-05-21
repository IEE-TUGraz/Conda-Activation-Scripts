#!/bin/bash
## Initializes 'conda' and activates environment 'LEGO_env'. If it doesn't exist or doesn't fulfill the requirements
## from 'environment.yml', it creates the environment newly from 'environment.yml'.
## Notes: Uses functions instead of goto to resemble structure of Windows script - initializeConda is start function

## Conda should be already available in the shell (i.e., 'conda activate xxx' should work)
initializeConda() {
  if ! command -v conda &> /dev/null
  then
    echo "ERROR: 'conda' initialization failed! Please follow the setup instructions in README.md"
  else
    echo "OK: 'conda' was initialized successfully!"
    findEnvironment
  fi
}

## Check if 'LEGO_env' exists
findEnvironment() {
  if ! conda env list | grep -q LEGO_env
  then
    echo "WARNING: 'conda' environment 'LEGO_env' does not exist"
    choiceCreate
  else
    echo "OK: 'conda' environment 'LEGO_env' found!"
    checkEnvironment
  fi
}

## Check if conda environment 'LEGO_env' fulfills all requirements from 'environment.yml'
checkEnvironment() {
  if ! conda compare -n LEGO_env environment.yml &> /dev/null
  then
    echo "WARNING: 'LEGO_env' does not fulfill all requirements from 'environment.yml'"
    choiceUpdate
  else
    echo "OK: 'LEGO_env' fulfills all requirements from 'environment.yml'"
    activateEnvironment
  fi
}

## Activate 'LEGO_env'
activateEnvironment() {
  if ! conda activate LEGO_env
  then
    echo "ERROR: 'LEGO_env' could not be activated - some error occurred!"
  else
    echo "SUCCESS: 'LEGO_env' was activated successfully!"
  fi
}

## Delete 'LEGO_env' if the user wants to
choiceUpdate() {
  echo "Should 'LEGO_env' environment be updated according to 'environment.yml'? [Y/N] "
    c=''
    while [[ ! $c =~ ^[YyNn]$ ]]; do
      read -r c
      case $c in
          [Yy] ) updateEnvironment ;;
          [Nn] ) dontUpdateEnvironment ;;
          *) echo "Faulty input: '$c' - Please choose 'Y' or 'N'!" ;;
      esac
    done
}

## Update 'LEGO_env'
updateEnvironment() {
  if ! conda env update --name LEGO_env --file environment.yml --prune
  then
    echo "ERROR: 'LEGO_env' could not be updated - some error occurred!"
  else
    echo "OK: 'LEGO_env' was updated successfully!"
    activateEnvironment
  fi
}

## Don't update 'LEGO_env'
dontUpdateEnvironment() {
  echo "WARNING: 'LEGO_env' was not updated"
  activateEnvironment
}

## Create 'LEGO_env' newly from 'environment.yml' if the user wants to
choiceCreate() {
  echo "Should 'LEGO_env' be newly created from 'environment.yml'? [Y/N] "
    c=''
    while [[ ! $c =~ ^[YyNn]$ ]]; do
      read -r c
      case $c in
          [Yy] ) createEnvironment ;;
          [Nn] ) dontCreateEnvironment ;;
          *) echo "Faulty input: '$c' - Please choose 'Y' or 'N'!" ;;
      esac
    done
}

## Create 'LEGO_env' from 'environment.yml'
createEnvironment() {
  if ! conda env create -f environment.yml
  then
    echo "ERROR: 'LEGO_env' could not be created from 'environment.yml' - some error occurred!"
  else
    echo "OK: 'LEGO_env' was created from environment.yml!"
    activateEnvironment
  fi
}

## Don't create 'LEGO_env' from 'environment.yml'
dontCreateEnvironment() {
  echo "ERROR: 'LEGO_env' was not created and thus also not activated"
}

initializeConda
