:: Initializes 'conda' and activates environment from parent folder. If it doesn't exist or doesn't fulfill the
:: requirements from 'environment.yml', it creates the environment newly from 'environment.yml'.
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

@REM Check if environment file exists or needs to be created
:findEnvironment

@call conda env list | findstr %envName% > nul
IF %ERRORLEVEL% NEQ 0 (
    echo WARNING: Conda environment '%envName%' does not exist
    @REM Reset error level
    @call cmd /c exit /b 0
    goto :choiceCreate
)
echo OK: 'conda' environment '%envName%' found!
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
@call cmd /k
