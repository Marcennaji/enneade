@echo off
setlocal

REM ========================================================
REM See the enneade_env script for full documentation on the
REM environment variables used by Enneade
REM ========================================================

REM ========================================================
REM Initialization of the installation directory of Enneade

REM Test is enneade_env is present
if not exist "%~dp0enneade_env.cmd" goto ERR_PATH_1

REM Initialize Enneade env variables
call "%~dp0enneade_env"

REM Test is Enneade environment already set up
if not exist "%ENNEADE_PATH%" goto ERR_PATH_2

REM display mpi configuration problems if any
if not "%ENNEADE_MPI_ERROR%". == "". echo %ENNEADE_MPI_ERROR%

REM Test if batch mode from parameters
set ENNEADE_BATCH_MODE=false
for %%i in (%*) do (
    for %%f in ("-h" "-b" "-s" "-v") do if /I "%%~i"=="%%~f" (
        set ENNEADE_BATCH_MODE=true
        goto BREAK_LOOP
    ) 
)
:BREAK_LOOP

if "%ENNEADE_BATCH_MODE%" == "true" if not "%ENNEADE_JAVA_ERROR%". == "". goto ERR_JAVA 
if "%_IS_CONDA%" == "true" if not "%ENNEADE_BATCH_MODE%" == "true" goto ERR_CONDA

REM Set path
set path=%~dp0;%ENNEADE_JAVA_PATH%;%path%
set classpath=%ENNEADE_CLASSPATH%;%classpath%

REM unset local variables
set "ENNEADE_BATCH_MODE="
set "_IS_CONDA="

REM ========================================================
REM Start Enneade (with or without parameteres)

if %1.==. goto NOPARAMS
if not %1.==. goto PARAMS

REM Start without parameters
:NOPARAMS
if not exist "%ENNEADE_LAST_RUN_DIR%" md "%ENNEADE_LAST_RUN_DIR%"
if not exist "%ENNEADE_LAST_RUN_DIR%" goto PARAMS

%ENNEADE_MPI_COMMAND% "%ENNEADE_PATH%" -o "%ENNEADE_LAST_RUN_DIR%\scenario._kh" -e "%ENNEADE_LAST_RUN_DIR%\log.txt"
if %errorlevel% EQU 0 goto END
goto ERR_RETURN_CODE

REM Start with parameters
:PARAMS
%ENNEADE_MPI_COMMAND% "%ENNEADE_PATH%" %*
if %errorlevel% EQU 0 goto END
goto ERR_RETURN_CODE

REM ========================================================
REM Error messages

:ERR_PATH_1
start "ENNEADE CONFIGURATION PROBLEM" echo ERROR "enneade_env.cmd is missing in directory %~dp0"
exit /b 1

:ERR_PATH_2
start "ENNEADE CONFIGURATION PROBLEM" echo ERROR "Incorrect installation directory for Enneade (File %ENNEADE_PATH% not found)"
exit /b 1

:ERR_RETURN_CODE
start "ENNEADE EXECUTION PROBLEM" cmd /k "echo ERROR Enneade ended with return code %errorlevel% & echo Contents of the log file at %ENNEADE_LAST_RUN_DIR%\log.txt: & type %ENNEADE_LAST_RUN_DIR%\log.txt"
goto END

:ERR_JAVA
start "ENNEADE CONFIGURATION PROBLEM" echo ERROR "%ENNEADE_JAVA_ERROR%"
exit /b 1

:ERR_CONDA
echo GUI is not available, please use the '-b' flag
exit /b 1

:END
endlocal

REM Return 1 if fatal error, 0 otherwise
exit /b %errorlevel%