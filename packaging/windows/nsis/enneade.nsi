# Enneade installer builder NSIS script

# Set Unicode to avoid warning 7998: "ANSI targets are deprecated"
Unicode True

# Set compresion to LZMA (faster)
SetCompressor /SOLID lzma
#SetCompress off

# Include NSIS librairies
!include "LogicLib.nsh"
!include "MUI2.nsh"
!include "FileFunc.nsh"
!include "x64.nsh"
!include "winmessages.nsh"

# Include Custom libraries
!include "EnneadeGlobals.nsh"
!include "EnneadePrerequisiteFunc.nsh"
!include "ReplaceInFile.nsh"



# Definitions for registry change notification
!define SHCNE_ASSOCCHANGED 0x8000000
!define SHCNF_IDLIST 0

# Get installation folder from registry if available
InstallDirRegKey HKLM Software\enneade ""

# Request admin privileges
RequestExecutionLevel admin

# Make it aware of HiDPI screens
ManifestDPIAware true

# Macro to check input parameter definitions
!macro CheckInputParameter ParameterName
  !ifndef ${ParameterName}
    !error "${ParameterName} is not defined. Use the flag '-D${ParameterName}=...' to define it."
  !endif
!macroend

# Check the mandatory input definitions
!insertmacro CheckInputParameter ENNEADE_VERSION
!insertmacro CheckInputParameter ENNEADE_REDUCED_VERSION
!insertmacro CheckInputParameter ENNEADE_WINDOWS_BUILD_DIR
!insertmacro CheckInputParameter JRE_PATH
!insertmacro CheckInputParameter MSMPI_INSTALLER_PATH
!insertmacro CheckInputParameter MSMPI_VERSION
!insertmacro CheckInputParameter ENNEADE_SAMPLES_DIR
!insertmacro CheckInputParameter ENNEADE_DOC_DIR

# Application name and installer file name
Name "Enneade ${ENNEADE_VERSION}"
OutFile "enneade-${ENNEADE_VERSION}-setup.exe"

########################
# Variable definitions #
########################

# Requirements installation flags
Var /GLOBAL MPIInstallationNeeded

# Requirements installation messages
Var /GLOBAL MPIInstallationMessage

# Previous Uninstaller data
Var /GLOBAL PreviousUninstaller
Var /GLOBAL PreviousVersion

# %Public%, %AllUsersProfile% (%ProgramData%) and samples directory
Var /GLOBAL WinPublicDir
Var /GLOBAL AllUsersProfileDir
Var /GLOBAL GlobalEnneadeDataDir
Var /GLOBAL SamplesInstallDir

# Root key for the uninstaller in the windows registry
!define UninstallerKey "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"

#####################################
# Modern UI Interface Configuration #
#####################################

# General configuration
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP ".\images\headerimage.bmp"
!define MUI_HEADERIMAGE_LEFT
!define MUI_WELCOMEFINISHPAGE_BITMAP ".\images\welcomefinish.bmp"
!define MUI_ABORTWARNING
!define MUI_ICON ".\images\installer.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\win-uninstall.ico"
BrandingText "Enneade ${ENNEADE_VERSION}"

# Welcome page
!define MUI_WELCOMEPAGE_TITLE "Welcome to the Enneade ${ENNEADE_VERSION} Setup Wizard"
!define MUI_WELCOMEPAGE_TEXT \
    "Enneade is a machine learning clustering tool based on the Khiops ML libraries.$\r$\n$\r$\n$\r$\n$\r$\n$(MUI_${MUI_PAGE_UNINSTALLER_PREFIX}TEXT_WELCOME_INFO_TEXT)"
!insertmacro MUI_PAGE_WELCOME

# Licence page
!insertmacro MUI_PAGE_LICENSE "..\..\..\LICENSE"

# Custom page for requirements software
Page custom RequirementsPageShow RequirementsPageLeave

# Install directory choice page
!insertmacro MUI_PAGE_DIRECTORY

# Install files choice page
!insertmacro MUI_PAGE_INSTFILES

# Final page
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_TEXT "Create desktop shortcut"
!define MUI_FINISHPAGE_RUN_FUNCTION "CreateDesktopShortcuts"
!define MUI_FINISHPAGE_TEXT "$\r$\n$\r$\nThank you for installing Enneade."
!define MUI_FINISHPAGE_LINK "enneade.org"
!define MUI_FINISHPAGE_LINK_LOCATION "https://enneade.org"
!insertmacro MUI_PAGE_FINISH

# Uninstaller pages
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

# Language (must be defined after uninstaller)
!insertmacro MUI_LANGUAGE "English"

#######################
# Version Information #
#######################

VIProductVersion "${ENNEADE_REDUCED_VERSION}.0"
VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductName" "Enneade"
VIAddVersionKey /LANG=${LANG_ENGLISH} "CompanyName" "Open Source Community"
VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalCopyright" "Copyright © 2025 Open Source Contributors"
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileDescription" "Enneade Installer"
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileVersion" "${ENNEADE_VERSION}"

######################
# Installer Sections #
######################

Section "Install" SecInstall
  # In order to have shortcuts and documents for all users
  SetShellVarContext all
  
  # Detect Java
  Call RequirementsDetection


  # MPI installation is always required, because Enneade is linked with MPI DLL
  ${If} $MPIInstallationNeeded == "1"
      Call InstallMPI
  ${EndIf}

  # Activate file overwrite
  SetOverwrite on

  # Install executables and java libraries
  SetOutPath "$INSTDIR\bin"
  File "${ENNEADE_WINDOWS_BUILD_DIR}\Release\enneade.exe"
  File "${ENNEADE_WINDOWS_BUILD_DIR}\bin\_khiopsgetprocnumber.exe"
  File "${ENNEADE_WINDOWS_BUILD_DIR}\jars\norm.jar"
  File "..\enneade.jar"
  File "..\enneade_env.cmd"
  File "..\enneade.cmd"
 
  # Install Docs
  SetOutPath "$INSTDIR"
  File "/oname=LICENSE.txt" "..\..\..\LICENSE"
  SetOutPath "$INSTDIR\doc"
  File /nonfatal /a /r "${ENNEADE_DOC_DIR}\"

  # Install icons
  SetOutPath "$INSTDIR\bin\icons"
  File ".\images\installer.ico"
  File ".\images\enneade.ico"
 
  # Set the samples directory to be located either within %PUBLIC% or %ALLUSERSPROFILE% as fallback
  ReadEnvStr $WinPublicDir PUBLIC
  ReadEnvStr $AllUsersProfileDir ALLUSERSPROFILE
  ${If} $WinPublicDir != ""
    StrCpy $GlobalEnneadeDataDir "$WinPublicDir\enneade_data"
  ${ElseIf} $AllUsersProfileDir != ""
    StrCpy $GlobalEnneadeDataDir "$AllUsersProfileDir\enneade_data"
  ${Else}
    StrCpy $GlobalEnneadeDataDir ""
  ${EndIf}

  # Debug message
  !ifdef DEBUG
    ${If} $GlobalEnneadeDataDir == ""
      Messagebox MB_OK "Could find PUBLIC nor ALLUSERSPROFILE directories. Samples not installed."
    ${Else}
      Messagebox MB_OK "Samples will be installed at $GlobalEnneadeDataDir\samples."
    ${EndIf}
  !endif

  # Install samples only if the directory is defined
  ${If} $GlobalEnneadeDataDir != ""
    StrCpy $SamplesInstallDir "$GlobalEnneadeDataDir\samples"
    SetOutPath "$SamplesInstallDir"
    File "/oname=README.txt" "${ENNEADE_SAMPLES_DIR}\README.md"
    SetOutPath "$SamplesInstallDir\Adult"
    File "${ENNEADE_SAMPLES_DIR}\Adult\Adult.kdic"
    File "${ENNEADE_SAMPLES_DIR}\Adult\Adult.txt"
    SetOutPath "$SamplesInstallDir\Iris"
    File "${ENNEADE_SAMPLES_DIR}\Iris\Iris.kdic"
    File "${ENNEADE_SAMPLES_DIR}\Iris\Iris.txt"
    SetOutPath "$SamplesInstallDir\Mushroom"
    File "${ENNEADE_SAMPLES_DIR}\Mushroom\Mushroom.kdic"
    File "${ENNEADE_SAMPLES_DIR}\Mushroom\Mushroom.txt"
    SetOutPath "$SamplesInstallDir\Letter"
    File "${ENNEADE_SAMPLES_DIR}\Letter\Letter.kdic"
    File "${ENNEADE_SAMPLES_DIR}\Letter\Letter.txt"
    SetOutPath "$SamplesInstallDir\SpliceJunction"
    File "${ENNEADE_SAMPLES_DIR}\SpliceJunction\SpliceJunction.kdic"
    File "${ENNEADE_SAMPLES_DIR}\SpliceJunction\SpliceJunction.txt"
    File "${ENNEADE_SAMPLES_DIR}\SpliceJunction\SpliceJunctionDNA.txt"
    SetOutPath "$SamplesInstallDir\Accidents"
    File "${ENNEADE_SAMPLES_DIR}\Accidents\Accidents.kdic"
    File "${ENNEADE_SAMPLES_DIR}\Accidents\Accidents.txt"
    File "${ENNEADE_SAMPLES_DIR}\Accidents\Places.txt"
    File "${ENNEADE_SAMPLES_DIR}\Accidents\Users.txt"
    File "${ENNEADE_SAMPLES_DIR}\Accidents\Vehicles.txt"
    File "${ENNEADE_SAMPLES_DIR}\Accidents\train.py"
    File "/oname=README.txt" "${ENNEADE_SAMPLES_DIR}\Accidents\README.md"
    SetOutPath "$SamplesInstallDir\Accidents\raw"
    File "${ENNEADE_SAMPLES_DIR}\Accidents\raw\AccidentsPreprocess.kdic"
    File "${ENNEADE_SAMPLES_DIR}\Accidents\raw\Description_BD_ONISR.pdf"
    File "${ENNEADE_SAMPLES_DIR}\Accidents\raw\Licence_Ouverte.pdf"
    File "${ENNEADE_SAMPLES_DIR}\Accidents\raw\caracteristiques-2018.csv"
    File "${ENNEADE_SAMPLES_DIR}\Accidents\raw\lieux-2018.csv"
    File "${ENNEADE_SAMPLES_DIR}\Accidents\raw\usagers-2018.csv"
    File "${ENNEADE_SAMPLES_DIR}\Accidents\raw\vehicules-2018.csv"
    File "${ENNEADE_SAMPLES_DIR}\Accidents\raw\preprocess.py"
    File "/oname=README.txt" "${ENNEADE_SAMPLES_DIR}\Accidents\raw\README.md"
    SetOutPath "$SamplesInstallDir\AccidentsSummary"
    File "${ENNEADE_SAMPLES_DIR}\AccidentsSummary\Accidents.kdic"
    File "${ENNEADE_SAMPLES_DIR}\AccidentsSummary\Accidents.txt"
    File "${ENNEADE_SAMPLES_DIR}\AccidentsSummary\Vehicles.txt"
    File "/oname=README.txt" "${ENNEADE_SAMPLES_DIR}\AccidentsSummary\README.md"
    SetOutPath "$SamplesInstallDir\Customer"
    File "${ENNEADE_SAMPLES_DIR}\Customer\Customer.kdic"
    File "${ENNEADE_SAMPLES_DIR}\Customer\CustomerRecoded.kdic"
    File "${ENNEADE_SAMPLES_DIR}\Customer\Customer.txt"
    File "${ENNEADE_SAMPLES_DIR}\Customer\Address.txt"
    File "${ENNEADE_SAMPLES_DIR}\Customer\Service.txt"
    File "${ENNEADE_SAMPLES_DIR}\Customer\Usage.txt"
    File "${ENNEADE_SAMPLES_DIR}\Customer\sort_and_recode_customer.py"
    File "/oname=README.txt" "${ENNEADE_SAMPLES_DIR}\Customer\README.md"
    SetOutPath "$SamplesInstallDir\Customer\unsorted"
    File "${ENNEADE_SAMPLES_DIR}\Customer\unsorted\Customer-unsorted.txt"
    File "${ENNEADE_SAMPLES_DIR}\Customer\unsorted\Address-unsorted.txt"
    File "${ENNEADE_SAMPLES_DIR}\Customer\unsorted\Service-unsorted.txt"
    File "${ENNEADE_SAMPLES_DIR}\Customer\unsorted\Usage-unsorted.txt"
    SetOutPath "$SamplesInstallDir\CustomerExtended"
    File "${ENNEADE_SAMPLES_DIR}\CustomerExtended\Customer.kdic"
    File "${ENNEADE_SAMPLES_DIR}\CustomerExtended\CustomerRecoded.kdic"
    File "${ENNEADE_SAMPLES_DIR}\CustomerExtended\Customer.txt"
    File "${ENNEADE_SAMPLES_DIR}\CustomerExtended\Address.txt"
    File "${ENNEADE_SAMPLES_DIR}\CustomerExtended\Service.txt"
    File "${ENNEADE_SAMPLES_DIR}\CustomerExtended\Usage.txt"
    File "${ENNEADE_SAMPLES_DIR}\CustomerExtended\City.txt"
    File "${ENNEADE_SAMPLES_DIR}\CustomerExtended\Country.txt"
    File "${ENNEADE_SAMPLES_DIR}\CustomerExtended\Product.txt"
    File "${ENNEADE_SAMPLES_DIR}\CustomerExtended\recode_customer.py"
    File "/oname=README.txt" "${ENNEADE_SAMPLES_DIR}\CustomerExtended\README.md"
  ${EndIf}

  # Install JRE
  SetOutPath $INSTDIR\jre
  File /nonfatal /a /r "${JRE_PATH}\"

  
  # Add the installer file
  SetOutPath $TEMP
  
  
  #############################
  # Finalize the installation #
  #############################

  # Setting up the GUI in enneade_env.cmd: replace @GUI_STATUS@ by "true" in the installed file
  Push @GUI_STATUS@ 
  Push 'true' 
  Push all 
  Push all 
  Push $INSTDIR\bin\enneade_env.cmd
  Call ReplaceInFile

  # Setting up MPI in enneade_env.cmd: replace @SET_MPI@ by "SET_MPI_SYSTEM_WIDE" in the installed file
  Push @SET_MPI@
  Push SET_MPI_SYSTEM_WIDE 
  Push all 
  Push all 
  Push $INSTDIR\bin\enneade_env.cmd
  Call ReplaceInFile

  # Setting up IS_CONDA_VAR variable in enneade_env.cmd: replace @SET_MPI@ by an empty string: this is not an installer for conda
  Push @IS_CONDA_VAR@
  Push "" 
  Push all 
  Push all 
  Push $INSTDIR\bin\enneade_env.cmd
  Call ReplaceInFile

  # Create the Enneade shell
  FileOpen $0 "$INSTDIR\bin\shell_enneade.cmd" w
  FileWrite $0 '@echo off$\r$\n'
  FileWrite $0 'REM Open a shell session with access to Enneade$\r$\n'
  FileWrite $0 `if "%ENNEADE_HOME%".=="". set ENNEADE_HOME=$INSTDIR$\r$\n`
  FileWrite $0 'set path=%ENNEADE_HOME%\bin;%path%$\r$\n'
  FileWrite $0 'title Shell Enneade$\r$\n'
  FileWrite $0 '%comspec% /K "echo Welcome to Enneade scripting mode & echo Type enneade -h to get help'
  FileClose $0

  # Create the uninstaller
  WriteUninstaller "$INSTDIR\uninstall-enneade.exe"


  #####################################
  # Windows environment customization #
  # ###################################

  # Write registry keys to add Enneade in the Add/Remove Programs pane
  WriteRegStr HKLM "Software\Enneade" "" $INSTDIR
  WriteRegStr HKLM "${UninstallerKey}\Enneade" "UninstallString" '"$INSTDIR\uninstall-enneade.exe"'
  WriteRegStr HKLM "${UninstallerKey}\Enneade" "InstallLocation" "$INSTDIR"
  WriteRegStr HKLM "${UninstallerKey}\Enneade" "DisplayName" "Enneade"
  WriteRegStr HKLM "${UninstallerKey}\Enneade" "Publisher" "Open Source Community"
  WriteRegStr HKLM "${UninstallerKey}\Enneade" "DisplayIcon" "$INSTDIR\bin\icons\installer.ico"
  WriteRegStr HKLM "${UninstallerKey}\Enneade" "DisplayVersion" "${ENNEADE_VERSION}"
  WriteRegStr HKLM "${UninstallerKey}\Enneade" "URLInfoAbout" "https://github.com/Marcennaji/enneade"
  WriteRegDWORD HKLM "${UninstallerKey}\Enneade" "NoModify" "1"
  WriteRegDWORD HKLM "${UninstallerKey}\Enneade" "NoRepair" "1"

  # Set as the startup dir for all executable shortcuts (yes it is done with SetOutPath!)
  ${If} $GlobalEnneadeDataDir != ""
    SetOutPath $GlobalEnneadeDataDir
  ${Else}
    SetOutPath $INSTDIR
  ${EndIf}

  # Create application shortcuts in the installation directory
  DetailPrint "Installing Start menu Shortcut..."
  CreateShortCut "$INSTDIR\Enneade.lnk" "$INSTDIR\bin\enneade.cmd" "" "$INSTDIR\bin\icons\enneade.ico" 0 SW_SHOWMINIMIZED
  ExpandEnvStrings $R0 "%COMSPEC%"
  CreateShortCut "$INSTDIR\Shell Enneade.lnk" "$INSTDIR\bin\shell_enneade.cmd" "" "$R0"

  # Create start menu shortcuts for the executables and documentation
  DetailPrint "Installing Start menu Shortcut..."
  CreateDirectory "$SMPROGRAMS\Enneade"
  CreateShortCut "$SMPROGRAMS\Enneade\Enneade.lnk" "$INSTDIR\bin\enneade.cmd" "" "$INSTDIR\bin\icons\enneade.ico" 0 SW_SHOWMINIMIZED
  ExpandEnvStrings $R0 "%COMSPEC%"
  CreateShortCut "$SMPROGRAMS\Enneade\Shell Enneade.lnk" "$INSTDIR\bin\shell_enneade.cmd" "" "$R0"
  CreateShortCut "$SMPROGRAMS\Enneade\Uninstall.lnk" "$INSTDIR\uninstall-enneade.exe"
  CreateDirectory "$SMPROGRAMS\Enneade\doc"
  CreateShortCut "$SMPROGRAMS\Enneade\doc\Tutorial.lnk" "$INSTDIR\doc\EnneadeTutorial.pdf"
  CreateShortCut "$SMPROGRAMS\Enneade\doc\Enneade.lnk" "$INSTDIR\doc\EnneadeGuide.pdf"
  SetOutPath "$INSTDIR"

  # Define aliases for the following registry keys (also used in the uninstaller section)
  # - HKLM (all users)
  # - HKCU (current user)
  !define env_hklm 'HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"'
  !define env_hkcu 'HKCU "Environment"'

  # Set ENNEADE_HOME for the local machine and current user
  WriteRegExpandStr ${env_hklm} "ENNEADE_HOME" "$INSTDIR"
  WriteRegExpandStr ${env_hkcu} "ENNEADE_HOME" "$INSTDIR"

  # Make sure windows knows about the change
  SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000

  # Enneade dictionary file extension
  ReadRegStr $R0 HKCR ".kdic" ""
  ${if} $R0 == "Enneade.Dictionary.File"
    DeleteRegKey HKCR "Enneade.Dictionary.File"
  ${EndIf}
  WriteRegStr HKCR ".kdic" "" "Enneade.Dictionary.File"
  WriteRegStr HKCR "Enneade.Dictionary.File" "" "Enneade Dictionary File"
  ReadRegStr $R0 HKCR "Enneade.Dictionary.File\shell\open\command" ""
  ${If} $R0 == ""
    WriteRegStr HKCR "Enneade.Dictionary.File\shell" "" "open"
    WriteRegStr HKCR "Enneade.Dictionary.File\shell\open\command" "" 'notepad.exe "%1"'
  ${EndIf}

  # Enneade scenario file
  ReadRegStr $R0 HKCR "._kh" ""
  ${if} $R0 == "Enneade.File"
    DeleteRegKey HKCR "Enneade.File"
  ${EndIf}
  WriteRegStr HKCR "._kh" "" "Enneade.File"
  WriteRegStr HKCR "Enneade.File" "" "Enneade File"
  WriteRegStr HKCR "Enneade.File\DefaultIcon" "" "$INSTDIR\bin\icons\enneade.ico"
  ReadRegStr $R0 HKCR "Enneade.File\shell\open\command" ""
  ${If} $R0 == ""
    WriteRegStr HKCR "Enneade.File\shell" "" "open"
    WriteRegStr HKCR "Enneade.File\shell\open\command" "" 'notepad.exe "%1"'
  ${EndIf}
  WriteRegStr HKCR "Enneade.File\shell\compile" "" "Execute Enneade Script"
  WriteRegStr HKCR "Enneade.File\shell\compile\command" "" '"$INSTDIR\bin\enneade.cmd" -i "%1"'

    # Notify the file extension changes
  System::Call 'Shell32::SHChangeNotify(i ${SHCNE_ASSOCCHANGED}, i ${SHCNF_IDLIST}, i 0, i 0)'

  # Debug message
  !ifdef DEBUG
    Messagebox MB_OK "Installation finished!"
  !endif

SectionEnd


###############
# Uninstaller #
###############

Section "Uninstall"
  # In order to have shortcuts and documents for all users
  SetShellVarContext all

  # Restore Registry #
  # Unregister file associations
  DetailPrint "Uninstalling Enneade Shell Extensions..."

  # Unregister Enneade dictionary file extension
  ${If} $R0 == "Enneade.Dictionary.File"
    DeleteRegKey HKCR ".kdic"
  ${EndIf}
  DeleteRegKey HKCR "Enneade.Dictionary.File"

  # Unregister Enneade file extension
  ${If} $R0 == "Enneade.File"
    DeleteRegKey HKCR "._kh"
  ${EndIf}
  DeleteRegKey HKCR "Enneade.File"

  # Notify file extension changes
  System::Call 'Shell32::SHChangeNotify(i ${SHCNE_ASSOCCHANGED}, i ${SHCNF_IDLIST}, i 0, i 0)'

  # Delete installation folder key
  DeleteRegKey HKLM "${UninstallerKey}\Enneade"
  DeleteRegKey HKLM "Software\Enneade"

  # Delete environement variable ENNEADE_HOME
  DeleteRegValue ${env_hklm} "ENNEADE_HOME"
  DeleteRegValue ${env_hkcu} "ENNEADE_HOME"

  # Delete deprecated environment variable EnneadeHome
  DeleteRegValue ${env_hklm} "EnneadeHome"
  DeleteRegValue ${env_hkcu} "EnneadeHome"

  # Make sure windows knows about the changes in the environment
  SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000

  # Delete files #
  # Note: Some directories are removed only if they are completely empty (no "/r" RMDir flag)
  DetailPrint "Deleting Files ..."

  # Delete docs
  Delete "$INSTDIR\LICENSE.txt"
  Delete "$INSTDIR\README.txt"
  Delete "$INSTDIR\WHATSNEW.txt"
  RMDir /r "$INSTDIR\doc"

  # Delete jre
  RMDir /r "$INSTDIR\jre"

  # Delete icons
  RMDir /r "$INSTDIR\bin\icons"

  # Delete executables and scripts
  Delete "$INSTDIR\bin\enneade_env.cmd"
  Delete "$INSTDIR\bin\enneade.cmd"
  Delete "$INSTDIR\bin\enneade.exe"
  Delete "$INSTDIR\bin\_khiopsgetprocnumber.exe"
  Delete "$INSTDIR\bin\norm.jar"
  Delete "$INSTDIR\bin\enneade.jar"
  Delete "$INSTDIR\bin\shell_enneade.cmd"
  RMDir "$INSTDIR\bin"

  # Delete shortcuts from install dir
  Delete "$INSTDIR\Enneade.lnk"
  Delete "$INSTDIR\Shell Enneade.lnk"

  # Delete the installer
  Delete "$INSTDIR\uninstall-enneade.exe"

  # Remove install directory
  RMDir "$INSTDIR"

  # Delete desktop shortcuts
  Delete "$DESKTOP\Enneade.lnk"
  Delete "$DESKTOP\Shell Enneade.lnk"

  # Delete Start Menu Shortcuts
  RMDir /r "$SMPROGRAMS\Enneade"

  # Set the samples directory to be located either within %PUBLIC% or %ALLUSERSPROFILE% as fallback
  ReadEnvStr $WinPublicDir PUBLIC
  ReadEnvStr $AllUsersProfileDir ALLUSERSPROFILE
  ${If} $WinPublicDir != ""
    StrCpy $GlobalEnneadeDataDir "$WinPublicDir\enneade_data"
  ${ElseIf} $AllUsersProfileDir != ""
    StrCpy $GlobalEnneadeDataDir "$AllUsersProfileDir\enneade_data"
  ${Else}
    StrCpy $GlobalEnneadeDataDir ""
  ${EndIf}

  # Delete sample datasets
  # We do not remove the whole directory to save the users results from Enneade' analyses
  ${If} $GlobalEnneadeDataDir != ""
    StrCpy $SamplesInstallDir "$GlobalEnneadeDataDir\samples"
    Delete "$SamplesInstallDir\AccidentsSummary\Accidents.kdic"
    Delete "$SamplesInstallDir\AccidentsSummary\Accidents.txt"
    Delete "$SamplesInstallDir\AccidentsSummary\README.txt"
    Delete "$SamplesInstallDir\AccidentsSummary\Vehicles.txt"
    Delete "$SamplesInstallDir\Accidents\Accidents.kdic"
    Delete "$SamplesInstallDir\Accidents\Accidents.txt"
    Delete "$SamplesInstallDir\Accidents\Places.txt"
    Delete "$SamplesInstallDir\Accidents\README.txt"
    Delete "$SamplesInstallDir\Accidents\Users.txt"
    Delete "$SamplesInstallDir\Accidents\Vehicles.txt"
    Delete "$SamplesInstallDir\Accidents\raw\AccidentsPreprocess.kdic"
    Delete "$SamplesInstallDir\Accidents\raw\Description_BD_ONISR.pdf"
    Delete "$SamplesInstallDir\Accidents\raw\Licence_Ouverte.pdf"
    Delete "$SamplesInstallDir\Accidents\raw\README.txt"
    Delete "$SamplesInstallDir\Accidents\raw\caracteristiques-2018.csv"
    Delete "$SamplesInstallDir\Accidents\raw\lieux-2018.csv"
    Delete "$SamplesInstallDir\Accidents\raw\preprocess.py"
    Delete "$SamplesInstallDir\Accidents\raw\usagers-2018.csv"
    Delete "$SamplesInstallDir\Accidents\raw\vehicules-2018.csv"
    Delete "$SamplesInstallDir\Accidents\train.py"
    Delete "$SamplesInstallDir\Adult\Adult.kdic"
    Delete "$SamplesInstallDir\Adult\Adult.txt"
    Delete "$SamplesInstallDir\CustomerExtended\Address.txt"
    Delete "$SamplesInstallDir\CustomerExtended\City.txt"
    Delete "$SamplesInstallDir\CustomerExtended\Country.txt"
    Delete "$SamplesInstallDir\CustomerExtended\Customer.kdic"
    Delete "$SamplesInstallDir\CustomerExtended\Customer.txt"
    Delete "$SamplesInstallDir\CustomerExtended\CustomerRecoded.kdic"
    Delete "$SamplesInstallDir\CustomerExtended\Product.txt"
    Delete "$SamplesInstallDir\CustomerExtended\README.txt"
    Delete "$SamplesInstallDir\CustomerExtended\Service.txt"
    Delete "$SamplesInstallDir\CustomerExtended\Usage.txt"
    Delete "$SamplesInstallDir\CustomerExtended\recode_customer.py"
    Delete "$SamplesInstallDir\Customer\Address.txt"
    Delete "$SamplesInstallDir\Customer\Customer.kdic"
    Delete "$SamplesInstallDir\Customer\Customer.txt"
    Delete "$SamplesInstallDir\Customer\CustomerRecoded.kdic"
    Delete "$SamplesInstallDir\Customer\README.txt"
    Delete "$SamplesInstallDir\Customer\Service.txt"
    Delete "$SamplesInstallDir\Customer\Usage.txt"
    Delete "$SamplesInstallDir\Customer\sort_and_recode_customer.py"
    Delete "$SamplesInstallDir\Customer\unsorted\Address-unsorted.txt"
    Delete "$SamplesInstallDir\Customer\unsorted\Customer-unsorted.txt"
    Delete "$SamplesInstallDir\Customer\unsorted\Service-unsorted.txt"
    Delete "$SamplesInstallDir\Customer\unsorted\Usage-unsorted.txt"
    Delete "$SamplesInstallDir\Iris\Iris.kdic"
    Delete "$SamplesInstallDir\Iris\Iris.txt"
    Delete "$SamplesInstallDir\Letter\Letter.kdic"
    Delete "$SamplesInstallDir\Letter\Letter.txt"
    Delete "$SamplesInstallDir\Mushroom\Mushroom.kdic"
    Delete "$SamplesInstallDir\Mushroom\Mushroom.txt"
    Delete "$SamplesInstallDir\README.txt"
    Delete "$SamplesInstallDir\SpliceJunction\SpliceJunction.kdic"
    Delete "$SamplesInstallDir\SpliceJunction\SpliceJunction.txt"
    Delete "$SamplesInstallDir\SpliceJunction\SpliceJunctionDNA.txt"
    RMDir "$SamplesInstallDir\AccidentsSummary\"
    RMDir "$SamplesInstallDir\Accidents\raw\"
    RMDir "$SamplesInstallDir\Accidents\"
    RMDir "$SamplesInstallDir\Adult\"
    RMDir "$SamplesInstallDir\CustomerExtended\"
    RMDir "$SamplesInstallDir\Customer\unsorted\"
    RMDir "$SamplesInstallDir\Customer\"
    RMDir "$SamplesInstallDir\Iris\"
    RMDir "$SamplesInstallDir\Letter\"
    RMDir "$SamplesInstallDir\Mushroom\"
    RMDir "$SamplesInstallDir\SpliceJunction\"
    RMDir "$SamplesInstallDir"
  ${EndIf}
SectionEnd


#######################
# Installer Functions #
#######################

Function "CreateDesktopShortcuts"
  # Set as the startup dir for all executable shortcuts (yes it is done with SetOutPath!)
  ${If} $GlobalEnneadeDataDir != ""
    SetOutPath $GlobalEnneadeDataDir
  ${Else}
    SetOutPath $INSTDIR
  ${EndIf}

  # Create the shortcuts
  DetailPrint "Installing Desktop Shortcut..."
  CreateShortCut "$DESKTOP\Enneade.lnk" "$INSTDIR\bin\enneade.cmd" "" "$INSTDIR\bin\icons\enneade.ico" 0 SW_SHOWMINIMIZED
FunctionEnd

# Predefined initialization install function
Function .onInit

  # Read location of the uninstaller
  ReadRegStr $PreviousUninstaller HKLM "${UninstallerKey}\Enneade" "UninstallString"
  ReadRegStr $PreviousVersion HKLM "${UninstallerKey}\Enneade" "DisplayVersion"

  # Ask the user to proceed if there was already a previous Enneade version installed
  # In silent mode: remove previous version
  ${If} $PreviousUninstaller != ""
    MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION \
       "Enneade $PreviousVersion is already installed. $\n$\nClick OK to remove the \
       previous version $\n$\nor Cancel to cancel this upgrade." \
       /SD IDOK IDOK uninst
    Abort

    # Run the uninstaller
    uninst:
    ClearErrors
    ExecWait '$PreviousUninstaller /S _?=$INSTDIR'

    # Run again the uninstaller to delete the uninstaller itself and the root dir (without waiting)
    # Must not be used in silent mode (may delete files from silent following installation)
    ${IfNot} ${Silent}
       ExecWait '$PreviousUninstaller /S'
    ${EndIf}
  ${EndIf}

  # Choice of default installation directory, for windows 32 or 64
  ${If} $INSTDIR == ""
    ${If} ${RunningX64}
      StrCpy $INSTDIR "$PROGRAMFILES64\enneade"
      # No 32-bit install
    ${EndIf}
  ${EndIf}
FunctionEnd


# Function to show the page for requirements
Function RequirementsPageShow
  # Detect requirements
  Call RequirementsDetection

  # Creation of page, with title and subtitle
  nsDialogs::Create 1018
  !insertmacro MUI_HEADER_TEXT "Check software requirements" "Check Microsoft MPI"

  # Message to show for the Microsoft MPI installation
  ${NSD_CreateLabel} 0 20u 100% 10u $MPIInstallationMessage

  # Show page
  nsDialogs::Show
FunctionEnd


# Requirements detection
# - Detects if the system architecture is 64-bit
# - Detects whether Java JRE and MPI are installed and their versions
Function RequirementsDetection
  # Abort installation if the machine does not have 64-bit architecture
  ${IfNot} ${RunningX64}
    Messagebox MB_OK "Enneade works only on Windows 64 bits: installation will be terminated." /SD IDOK
    Quit
  ${EndIf}

  # Decide if MPI is required by detecting the number of cores
  # Note: This call defines MPIInstalledVersion
  Call DetectAndLoadMPIEnvironment

  # Try to install MPI
  StrCpy $MPIInstallationNeeded "0"
  StrCpy $MPIInstallationMessage ""
 
  # If it is not installed install it
  ${If} $MPIInstalledVersion == "0"
      StrCpy $MPIInstallationMessage "Microsoft MPI version ${MSMPI_VERSION} will be installed"
      StrCpy $MPIInstallationNeeded "1"
  # Otherwise install only if the required version is newer than the installed one
  ${Else}
      ${VersionCompare} "${MPIRequiredVersion}" "$MPIInstalledVersion" $0
      ${If} $0 == 1
        StrCpy $MPIInstallationMessage "Microsoft MPI will be upgraded to version ${MSMPI_VERSION}"
        StrCpy $MPIInstallationNeeded "1"
      ${Else}
        StrCpy $MPIInstallationMessage "Microsoft MPI version already installed"
      ${EndIf}
  ${EndIf}
 

  # Show debug information
  !ifdef DEBUG
    Messagebox MB_OK "MS-MPI: needed=$MPIInstallationNeeded required=${MPIRequiredVersion} installed=$MPIInstalledVersion"
  !endif

FunctionEnd

# No leave page for required software
Function RequirementsPageLeave
FunctionEnd
