:: Initializes Conda and activates environment from parent folder. If it doesn't exist or doesn't fulfill the
:: requirements from the environment file, it creates the environment according to this file.
:: Notes: Has to use goto instead of (much prettier) if/else to handle error-levels correctly
@echo off
@goto :initializeConda

@REM Initialize conda from anaconda3
:initializeConda
@set installPathConda=C:\Users\%USERNAME%\anaconda3
@call "%installPathConda%\Scripts\activate.bat" "%installPathConda%"
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: Conda initialization failed! Please follow the setup instructions in README.md
    echo ERROR: If it is not installed at "%installPathConda%", please adjust the path in the activation script
    goto :end
)
echo OK: Conda was initialized successfully!
goto :findEnvironmentFile

@REM Check if environment file exists or needs to be created
:findEnvironmentFile
@REM Check if 'environment.yml' exists in parent folder, else if it exists in the same folder
if exist ../environment.yml (
    set p=../environment.yml
    echo OK: '../environment.yml' file found in parent folder!
    goto :findCondaEnvironment
) else (
    if exist environment.yml (
        set p=environment.yml
        echo OK: 'environment.yml' file found in same folder!
        goto :findCondaEnvironment
    ) else (
        echo WARNING: 'environment.yml' does not exist in parent folder ^('../environment.yml'^) or in same folder ^('environment.yml'^)!
        goto :choiceEnvironmentPath
    )
)

@REM Give user the option to specify path to environment file
:choiceEnvironmentPath
set /P p="Please define path to environment file: "
IF NOT EXIST %p% (
    echo ERROR: '%p%' not found!
    goto :choiceEnvironmentPath
)

echo OK: '%p%' file found!
goto :findCondaEnvironment

@REM Get environment name from first line of environment file
:findCondaEnvironment
@REM See https://groups.google.com/g/alt.msdos.batch.nt/c/hpmCem5GnM0/m/lIHHsMoIsVMJ for details
for /f "delims=" %%a in (%p%) do set "envName=%%a"&goto :stop
:stop

@REM Remove 'name: ' from 'name: [NameOfEnvironment]' to get the name of the environment
set envName=%envName:~6%
echo OK: Looking for conda environment '%envName%'!

@REM Check if conda environment exists
@call conda env list | findstr %envName% > nul
IF %ERRORLEVEL% NEQ 0 (
    echo WARNING: Conda environment '%envName%' does not exist!
    @REM Reset error level
    @call cmd /c exit /b 0
    goto :choiceCreate
)
echo OK: Conda environment '%envName%' found!
goto :checkEnvironment

@REM Check if conda environment fulfills all requirements from environment file
:checkEnvironment
@call conda compare -n %envName% %p% > nul
IF %ERRORLEVEL% NEQ 0 (
    echo WARNING: '%envName%' does not fulfill all requirements from '%p%'
    @REM Reset error level
    @call cmd /c exit /b 0
    goto :choiceUpdate
)
echo OK: '%envName%' fulfills all requirements from '%p%'
goto :activateEnvironment

@REM Activate environment
:activateEnvironment
@call conda activate %envName%
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: '%envName%' could not be activated - some error occurred!
    goto :end
)
echo SUCCESS: '%envName%' was activated successfully!
goto :end

:choiceUpdate
@REM Update environment according to environment file if the user wants to
set /P c="Should '%envName%' environment be updated according to '%p%'? [Y/N] "
IF /I "%c%" EQU "Y" goto :updateEnvironment
IF /I "%c%" EQU "N" goto :dontUpdateEnvironment
@REM If this point is reached, the input was faulty
echo Faulty input: '%c%' - Please choose 'Y' or 'N'!
goto :choiceUpdate

@REM Update environment
:updateEnvironment
call conda env update --name %envName% --file %p% --prune
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: '%envName%' could not be updated - some error occurred!
    goto :end
)
echo OK: '%envName%' was updated successfully!
goto :activateEnvironment

@REM Don't update environment
:dontUpdateEnvironment
echo WARNING: '%envName%' was not updated
goto :activateEnvironment

@REM Create environment newly from environment file if the user wants to
:choiceCreate
set /P c="Should '%envName%' be newly created from '%p%'? [Y/N] "
IF /I "%c%" EQU "Y" goto :createEnvironment
IF /I "%c%" EQU "N" goto :dontCreateEnvironment
@REM If this point is reached, the input was faulty
echo Faulty input: '%c%' - Please choose 'Y' or 'N'!
goto :choiceCreate

@REM Create environment from environment file
:createEnvironment
call conda env create -f %p%
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: '%envName%' could not be created from '%p%' - some error occurred!
    goto :end
)
echo OK: '%envName%' was created from %p%!
goto :activateEnvironment

@REM Don't create environment from environment file
:dontCreateEnvironment
echo ERROR: '%envName%' was not created and thus also not activated
goto :end

:end
@REM Keep the command line open
@call cmd /k cd .
