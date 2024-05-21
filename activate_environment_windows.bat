:: Initializes 'conda' and activates environment 'LEGO_env'. If it doesn't exist or doesn't fulfill the requirements
:: from 'environment.yml', it creates the environment newly from 'environment.yml'.
:: Notes: Has to use goto instead of (much prettier) if/else to handle error-levels correctly
@goto :initializeConda

@REM Initialize conda from anaconda3
:initializeConda
@call "C:\Users\%USERNAME%\anaconda3\Scripts\activate.bat" "C:\Users\%USERNAME%\anaconda3"
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: 'conda' initialization failed! Please follow the setup instructions in README.md
    goto :end
)
echo OK: 'conda' was initialized successfully!
goto :findEnvironment

@REM Check if 'LEGO_env' exists
:findEnvironment
@call conda env list | findstr LEGO_env > nul
IF %ERRORLEVEL% NEQ 0 (
    echo WARNING: 'conda' environment 'LEGO_env' does not exist
    @REM Reset error level
    @call cmd /c exit /b 0
    goto :choiceCreate
)
echo OK: 'conda' environment 'LEGO_env' found!
goto :checkEnvironment

@REM Check if conda environment 'LEGO_env' fulfills all requirements from 'environment.yml'
:checkEnvironment
@call conda compare -n LEGO_env environment.yml > nul
IF %ERRORLEVEL% NEQ 0 (
    echo WARNING: 'LEGO_env' does not fulfill all requirements from 'environment.yml'
    @REM Reset error level
    @call cmd /c exit /b 0
    goto :choiceUpdate
)
echo OK: 'LEGO_env' fulfills all requirements from 'environment.yml'
goto :activateEnvironment

@REM Activate 'LEGO_env'
:activateEnvironment
@call conda activate LEGO_env
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: 'LEGO_env' could not be activated - some error occurred!
    goto :end
)
echo SUCCESS: 'LEGO_env' was activated successfully!
goto :end

:choiceUpdate
@REM Update 'LEGO_env' according to 'environment.yml' if the user wants to
set /P c="Should 'LEGO_env' environment be updated according to 'environment.yml'? [Y/N] "
IF /I "%c%" EQU "Y" goto :updateEnvironment
IF /I "%c%" EQU "N" goto :dontUpdateEnvironment
@REM If this point is reached, the input was faulty
echo Faulty input: '%c%' - Please choose 'Y' or 'N'!
goto :choiceUpdate

@REM Update 'LEGO_env'
:updateEnvironment
call conda env update --name LEGO_env --file environment.yml --prune
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: 'LEGO_env' could not be updated - some error occurred!
    goto :end
)
echo OK: 'LEGO_env' was updated successfully!
goto :activateEnvironment

@REM Don't update 'LEGO_env'
:dontUpdateEnvironment
echo WARNING: 'LEGO_env' was not updated
goto :activateEnvironment

@REM Create 'LEGO_env' newly from 'environment.yml' if the user wants to
:choiceCreate
set /P c="Should 'LEGO_env' be newly created from 'environment.yml'? [Y/N] "
IF /I "%c%" EQU "Y" goto :createEnvironment
IF /I "%c%" EQU "N" goto :dontCreateEnvironment
@REM If this point is reached, the input was faulty
echo Faulty input: '%c%' - Please choose 'Y' or 'N'!
goto :choiceCreate

@REM Create 'LEGO_env' from 'environment.yml'
:createEnvironment
call conda env create -f environment.yml
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: 'LEGO_env' could not be created from 'environment.yml' - some error occurred!
    goto :end
)
echo OK: 'LEGO_env' was created from environment.yml!
goto :activateEnvironment

@REM Don't create 'LEGO_env' from 'environment.yml'
:dontCreateEnvironment
echo ERROR: 'LEGO_env' was not created and thus also not activated
goto :end

:end
@REM Keep the command line open
@call cmd /k
