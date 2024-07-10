# Conda-Activation-Scripts

This is a collection of activation scripts for conda environments, also taking care of setting up new environments
if they don't exist yet. 

## Setup

Install Anaconda to manage Python packages:
https://www.anaconda.com/download

Choose **"Just Me (recommended)"** when asked for the installation type.

Leave **all other options on default**.

_For Unix_: Additionally prepare conda by executing ```conda init```

_For Pros_: You can create an environment using the `environment.yml` file - for all others, 
the scripts take care of that.

## Activating the environment

When executing the script, the environment placed in the parent folder or in the current folder (if there is none in the 
parent folder) will be activated. If there is no environment.yml, the script will ask for an alternative path to an 
environment file. 

- **Windows**: Execute the `activate_environment_windows.bat` file
- **Unix**: Execute the `activate_environment_unix.sh` file
  - When executing it from terminal, use ```source activate_environment_unix.sh```
- _For Pros_: Activate your own environment

In the now opened command line, you can use the activated environment. The working directory will be the 
**current folder** of the script.
