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
the scripts below will take care of that.

## Activating the environment

When executing the script, the environment placed in the parent folder will be activated. If you want to
activate a different environment, call the scripts with the path to the environment.yml file as an argument. 

- **Windows**: Execute the `activate_environment_windows.bat [optional: path/to/file]` file
- **Unix**: Execute the `activate_environment_unix.sh [optional: path/to/file]` file
  - When executing it from terminal, use ```source activate_environment_unix.sh [optional: path/to/file]```
- _For Pros_: Activate your own environment

In the now opened command line, you can use the activated environment.
