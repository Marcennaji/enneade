@echo off

if %1.==--env. goto DISPLAY_ENV
if %*.==. goto SET_ENV

:HELP
echo Usage: enneade_env [-h, --help] [--env]
echo enneade_env is an internal script intended to be used by Enneade tool and Enneade wrappers only.
echo It sets all the environment variables required by the Enneade to run correctly (Java, MPI, etc).
echo Options:
echo    -h, --help show this help message and exit
echo    -env show the environment list and exit
echo.
echo The following variables are used to set the path and classpath for the prerequisite of Enneade.
echo.
echo ENNEADE_PATH: full path of Enneade executable
echo ENNEADE_MPI_COMMAND: MPI command to call the Enneade tool
echo ENNEADE_JAVA_PATH: path of Java tool, to add in path
echo ENNEADE_CLASSPATH: Enneade java libraries, to add in classpath
echo ENNEADE_DRIVERS_PATH: search path of the drivers (by default Enneade bin directory if not defined)
echo.
echo If they are not already defined, the following variables used by Enneade are set:
echo.
echo ENNEADE_LAST_RUN_DIR: directory where Enneade writes output command file and log
echo   (when not defined with -e and -o)
echo ENNEADE_PROC_NUMBER: processes number launched by Enneade (it's default value corresponds to the
echo   number of physical cores of the computer)
echo.
echo The following variables are not defined by default and can be used to change some default
echo  properties of Enneade:
echo.
echo ENNEADE_TMP_DIR: Enneade temporary directory location (default: the system default).
echo   This location can be modified from the tool as well.
echo ENNEADE_MEMORY_LIMIT: Enneade memory limit in MB (default: the system memory limit).
echo   The minimum value is 100 MB; this setting is ignored if it is above the system's memory limit.
echo   It can only be reduced from the tool.
echo ENNEADE_API_MODE: standard or api mode for the management of output result files created by Enneade
echo   In standard mode, the result files are stored in the train database directory,
echo   unless an absolute path is specified, and the file extension is forced if necessary.
echo   In api mode, the result files are stored in the current working directory, using the specified results as is.
echo   . default behavior if not set: standard mode
echo   . set to 'false' to force standard mode
echo   . set to 'true' to force api mode
echo ENNEADE_RAW_GUI: graphical user interface for file name selection
echo   . default behavior if not set: depending on the file drivers available for Enneade
echo   . set to 'true' to allow file name selection with uri schemas
echo   . set to 'false' to allow local file name selection only with a file selection dialog
echo.
echo In case of configuration problems, the variables ENNEADE_JAVA_ERROR and ENNEADE_MPI_ERROR contain error messages.

if not %2.==. exit /b 1
if %1.==-h. exit /b 0
if %1.==--help. exit /b 0
exit /b 1

REM Set Enneade environment variables
:DISPLAY_ENV
setlocal
set DISPLAY_ENV=true

:SET_ENV
REM Initialize exported variables
set "ENNEADE_PATH="
set "ENNEADE_MPI_COMMAND="
set "ENNEADE_JAVA_PATH="
set "ENNEADE_CLASSPATH="
set "ENNEADE_JAVA_ERROR="
set "ENNEADE_MPI_ERROR="

REM Set Enneade home to parent directory
for %%a in ("%~dp0..") do set "_ENNEADE_HOME=%%~fa"

REM ENNEADE_PATH
set "ENNEADE_PATH=%_ENNEADE_HOME%\bin\enneade.exe"

REM ENNEADE_LAST_RUN_DIR
if "%ENNEADE_LAST_RUN_DIR%". == "". set "ENNEADE_LAST_RUN_DIR=%USERPROFILE%\enneade_data\lastrun"

REM ENNEADE_PROC_NUMBER
if "%ENNEADE_PROC_NUMBER%". == "". for /f %%i in ('"%~dp0_khiopsgetprocnumber"') do set "ENNEADE_PROC_NUMBER=%%i"
if "%ENNEADE_PROC_NUMBER%". == "". set "ENNEADE_PROC_NUMBER=1"

REM Set MPI binary (mpiexec)
if %ENNEADE_PROC_NUMBER% LEQ 2 goto MPI_DONE
goto SET_MPI_SYSTEM_WIDE

:MPI_PARAMS
REM Add the MPI parameters
if not "%ENNEADE_MPI_COMMAND%." == "." set "ENNEADE_MPI_COMMAND="%ENNEADE_MPI_COMMAND%" -n %ENNEADE_PROC_NUMBER%"
:MPI_DONE

set _ENNEADE_GUI=
if "%_ENNEADE_GUI%" == "false" GOTO SKIP_GUI

REM Set Java environment
set _JAVA_ERROR=false
if not exist "%_ENNEADE_HOME%\jre\bin\server\" set _JAVA_ERROR=true
if not exist "%_ENNEADE_HOME%\jre\bin\" set _JAVA_ERROR=true

if  "%_JAVA_ERROR%" == "false" (
    set "ENNEADE_JAVA_PATH=%_ENNEADE_HOME%\jre\bin\server\;%_ENNEADE_HOME%\jre\bin\"
) else set "ENNEADE_JAVA_ERROR=The JRE is missing in Enneade home directory, please reinstall Enneade"

REM ENNEADE_CLASSPATH
set "ENNEADE_CLASSPATH=%_ENNEADE_HOME%\bin\norm.jar"
set "ENNEADE_CLASSPATH=%_ENNEADE_HOME%\bin\enneade.jar;%ENNEADE_CLASSPATH%"

:SKIP_GUI





REM unset local variables
set "_ENNEADE_GUI="
set "_JAVA_ERROR="
set "_ENNEADE_HOME="

if not "%DISPLAY_ENV%" == "true" exit /b 0

REM Print the environment list on the standard output
echo ENNEADE_PATH %ENNEADE_PATH%
echo ENNEADE_MPI_COMMAND %ENNEADE_MPI_COMMAND%
echo ENNEADE_JAVA_PATH %ENNEADE_JAVA_PATH%
echo ENNEADE_CLASSPATH %ENNEADE_CLASSPATH%
echo ENNEADE_LAST_RUN_DIR %ENNEADE_LAST_RUN_DIR%
echo ENNEADE_PROC_NUMBER %ENNEADE_PROC_NUMBER%
echo ENNEADE_TMP_DIR %ENNEADE_TMP_DIR%
echo ENNEADE_MEMORY_LIMIT %ENNEADE_MEMORY_LIMIT%
echo ENNEADE_API_MODE %ENNEADE_API_MODE%
echo ENNEADE_RAW_GUI %ENNEADE_RAW_GUI%
echo ENNEADE_DRIVERS_PATH %ENNEADE_DRIVERS_PATH%
echo ENNEADE_JAVA_ERROR %ENNEADE_JAVA_ERROR%
echo ENNEADE_MPI_ERROR %ENNEADE_MPI_ERROR%
endlocal
exit /b 0

REM Set mpiexec path for conda installation
:SET_MPI_CONDA
set "ENNEADE_MPI_COMMAND=%_ENNEADE_HOME%\Library\bin\mpiexec.exe"
if not exist "%ENNEADE_MPI_COMMAND%" goto ERR_MPI
goto MPI_PARAMS

REM Set mpiexec path for system wide installation
:SET_MPI_SYSTEM_WIDE
REM ... with the standard variable MSMPI_BIN
set "ENNEADE_MPI_COMMAND=%MSMPI_BIN%mpiexec.exe"
if  exist "%ENNEADE_MPI_COMMAND%" goto MPI_PARAMS
REM ... if MSMPI_BIN is not correctly defined 
REM ... we try to call directly mpiexec (assuming its path is in the 'path' variable)
set "ENNEADE_MPI_COMMAND=mpiexec"
where /q "%ENNEADE_MPI_COMMAND%"
if ERRORLEVEL 1 goto ERR_MPI
REM ... finally we check if it is the good MPI implementation: "Microsoft MPI"
"%ENNEADE_MPI_COMMAND%" | findstr /c:"Microsoft MPI" > nul
if ERRORLEVEL 1 goto ERR_MPI_IMPL
goto MPI_PARAMS


:ERR_MPI
set "ENNEADE_MPI_ERROR=We didn't find mpiexec in the regular path. Parallel computation is unavailable: Enneade is launched in serial"
set "ENNEADE_MPI_COMMAND="
goto MPI_DONE

:ERR_MPI_IMPL
set "ENNEADE_MPI_ERROR=We can't find the right implementation of mpiexec, we expect to find Microsoft MPI. Parallel computation is unavailable: Enneade is launched in serial"
set "ENNEADE_MPI_COMMAND="
goto MPI_DONE
