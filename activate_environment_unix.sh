#!/bin/bash
## Initializes Conda and activates environment from parent folder. If it doesn't exist or doesn't fulfill the
## requirements from the environment file, it creates the environment according to this file.
## Notes: Uses functions instead of goto to resemble structure of Windows script - initializeConda is start function

## Conda should be already available in the shell (i.e., 'conda activate xxx' should work)
initializeConda() {
  if ! command -v conda &> /dev/null
  then
    echo "ERROR: Conda initialization failed! Please follow the setup instructions in README.md"
  else
    echo "OK: Conda was initialized successfully!"
    findEnvironmentFile
  fi
}

## Check if environment file exists or needs to be created
findEnvironmentFile() {
  ## Check if 'environment.yml' exists in parent folder, else if it exists in the same folder
  if [ -f ../environment.yml ]
  then
    p="../environment.yml"
    echo "OK: '../environment.yml' file found in parent folder!"
    findCondaEnvironment
  elif [ -f environment.yml ]
  then
    p="environment.yml"
    echo "OK: 'environment.yml' file found in same folder!"
    findCondaEnvironment
  else
    echo "WARNING: 'environment.yml' does not exist in parent folder ('../environment.yml') or in same folder ('environment.yml')!"
    choiceEnvironmentPath
  fi
}

## Give user the option to specify path to environment file
choiceEnvironmentPath() {
  echo "Please define path to environment file: "
  p=''
  read -r p
  while [ ! -f $p ]; do
    echo "ERROR: '$p' not found!"
    read -r p
  done
  echo "OK: '$p' file found!"
  findCondaEnvironment
}

## Get environment name from first line of environment file
findCondaEnvironment() {
  envName=$(head -n 1 $p | cut -d ' ' -f 2)
  echo "OK: Looking for conda environment '$envName'!"

  ## Check if conda environment exists
  if ! conda env list | grep -q $envName
  then
    echo "WARNING: Conda environment '$envName' does not exist!"
    choiceCreate
  else
    echo "OK: Conda environment '$envName' found!"
    checkEnvironment
  fi
}

## Check if conda environment fulfills all requirements from environment file
checkEnvironment() {
  if ! conda compare -n $envName $p &> /dev/null
  then
    echo "WARNING: '$envName' does not fulfill all requirements from '$p'"
    choiceUpdate
  else
    echo "OK: '$envName' fulfills all requirements from '$p'"
    activateEnvironment
  fi
}

## Activate environment
activateEnvironment() {
  source activate base
  if ! conda activate $envName
  then
    echo "ERROR: '$envName' could not be activated - some error occurred!"
  else
    echo "SUCCESS: '$envName' was activated successfully!"
  fi
  cd .
}

## Update environment according to environment file if the user wants to
choiceUpdate() {
  echo "Should '$envName' environment be updated according to '$p'? [Y/N] "
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

## Update environment
updateEnvironment() {
  if ! conda env update --name $envName --file $p --prune
  then
    echo "ERROR: '$envName' could not be updated - some error occurred!"
  else
    echo "OK: '$envName' was updated successfully!"
    activateEnvironment
  fi
}

## Don't update environment
dontUpdateEnvironment() {
  echo "WARNING: '$envName' was not updated"
  activateEnvironment
}

## Create environment newly from environment file if the user wants to
choiceCreate() {
  echo "Should '$envName' be newly created from '$p'? [Y/N] "
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

## Create environment from environment file
createEnvironment() {
  if ! conda env create -f $p
  then
    echo "ERROR: '$envName' could not be created from '$p' - some error occurred!"
  else
    echo "OK: '$envName' was created from $p!"
    activateEnvironment
  fi
}

## Don't create environment from environment file
dontCreateEnvironment() {
  echo "ERROR: '$envName' was not created and thus also not activated"
}

initializeConda
