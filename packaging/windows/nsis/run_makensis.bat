REM We assume the package assets were downloaded to packaging\windows\nsis\assets
REM Before building the installer, update the following script arguments, mainly:
REM - ENNEADE_VERSION: Enneade version for the installer.
REM - ENNEADE_REDUCED_VERSION: Enneade version without suffix and only digits and periods.
REM                           Thus, the pre-release fields of ENNEADE_VERSION are ignored in ENNEADE_REDUCED_VERSION.

makensis ^
   /DENNEADE_VERSION=10.7.0-b.0 ^
   /DENNEADE_REDUCED_VERSION=10.7.0 ^
   /DENNEADE_WINDOWS_BUILD_DIR=..\..\..\build ^
   /DJRE_PATH=.\assets\jre\ ^
   /DMSMPI_INSTALLER_PATH=.\assets\msmpisetup.exe ^
   /DMSMPI_VERSION=10.1.3 ^
   /DENNEADE_SAMPLES_DIR=.\assets\samples ^
   /DENNEADE_DOC_DIR=.\assets\doc ^
   enneade.nsi