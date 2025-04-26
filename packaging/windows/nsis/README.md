# Enneade NSIS packaging
This folder contains the scripts to generate the Enneade Windows installer. It is built with
[NSIS](https://nsis.sourceforge.io/Download). See also the [Release Process wiki
page](https://github.com/EnneadeML/enneade/wiki/Release-Process).

## What the installer does
Besides installing the Enneade executables, the installer automatically detects the presence of:
- [Microsoft MPI](https://learn.microsoft.com/en-us/message-passing-interface/microsoft-mpi)

and installs it if necessary.


It also installs:
- The JRE from [Eclipse Temurin](https://adoptium.net/fr/temurin/releases/)
- The [sample datasets](https://github.com/EnneadeML/enneade-samples/releases/latest).
- Documentation files:
  - PDF Guides .

## How to obtain the package assets
All the package assets (installers, documentation, etc) are available at the
[`enneade-win-install-assets`](https://github.com/EnneadeML/enneade-win-install-assets/releases/latest)
repository.

## How to build the installer manually
1) Install NSIS and make sure `makensis` it is available in the `%PATH%`.
2) Position the local repo to the desired tag (ex: `git checkout 10.2.0-rc1`)
3) Download and decompress the package assets to your machine, on `packaging\windows\nsis\assets`
4) [Build Enneade in Release mode](https://github.com/EnneadeML/enneade/wiki/Building-Enneade), to build the binaries and the jars
5) In a console, go to the `packaging/windows/nsis` directory and execute
```bat
%REM We assume the package assets were downloaded to packaging\windows\nsis\assets
%REM Before building the installer, update the following script arguments, mainly:
%REM - ENNEADE_VERSION: Enneade version for the installer.
%REM                   Should be identical to the value that is set in ENNEADE_STR in src/Learning/KWUtils/KWEnneadeVersion.h
%REM - ENNEADE_REDUCED_VERSION: Enneade version without suffix and only digits and periods.
%REM                           Thus, the pre-release fields of ENNEADE_VERSION are ignored in ENNEADE_REDUCED_VERSION.

makensis ^
   /DENNEADE_VERSION=10.7.0-b.0 ^
   /DENNEADE_REDUCED_VERSION=10.7.0 ^
   /DENNEADE_WINDOWS_BUILD_DIR=..\..\..\build\Release ^
   /DJRE_PATH=.\assets\jre\ ^
   /DMSMPI_INSTALLER_PATH=.\assets\msmpisetup.exe ^
   /DMSMPI_VERSION=10.1.3 ^
   /DENNEADE_SAMPLES_DIR=.\assets\samples ^
   /DENNEADE_DOC_DIR=.\assets\doc ^
   enneade.nsi
```
The resulting installer will be at `packaging/windows/nsis/enneade-10.7.0-b.0-setup.exe`.

## Signature of binaries and installer
For a release version of the installer, the binaries and the installer need to be signed
4.bis) Sign the binary: `enneade.exe`
5.bis) Sign the installer


_Note 1_: See [below](#build-script-arguments) for the details of the installer builder script arguments.

_Note 2_: If your are using powershell replace the `^` characters by backticks `` ` `` in the
multi-line command.


## Github Workflow
This process is automatized in the [pack-nsis.yml workflow](../../../.github/workflows/pack-nsis.yml).

## Build script arguments
All the arguments are mandatory except for `DEBUG`, they must be prefixed by `/D` and post fixed by
`=<value>` to specify a value.

- `DEBUG`: Enables debug messages in the installer. They are "OK" message boxes.
- `ENNEADE_VERSION`: Enneade version for the installer.
- `ENNEADE_REDUCED_VERSION`: Enneade version without suffix and only digits and periods.
- `ENNEADE_WINDOWS_BUILD_DIR`: Build directory for (usually `build` relative to
  the project root).
- `JRE_PATH`: Path to the Java Runtime Environment (JRE) directory.
- `MSMPI_INSTALLER_PATH`: Path to the Microsoft MPI (MS-MPI) installer.
- `MSMPI_MPI_VERSION`: MS-MPI version.
- `ENNEADE_SAMPLES_DIR`: Path to the sample datasets directory.
- `ENNEADE_DOC_DIR`: Path to the directory containing the documentation.
