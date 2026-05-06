@echo off
REM build_apk.bat - Build Flutter debug/release APKs for Windows PowerShell environment
REM Usage: build_apk.bat [debug|release|both|clean]

SETLOCAL ENABLEDELAYEDEXPANSION

n:: Determine command - default to both
IF "%1"=="" (
  SET CMD=both
) ELSE (
  SET CMD=%1
)

n:: Project root (this script location)
SET SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

nECHO Running from: %CD%

n:: Helper to run flutter and bail out on error
:run_flutter
ECHO.
ECHO Running: flutter %*
flutter %*
IF NOT %ERRORLEVEL%==0 (
  ECHO.
  ECHO flutter command failed with exit code %ERRORLEVEL%.
  EXIT /B %ERRORLEVEL%
)
GOTO :eof

nIF /I "%CMD%"=="clean" (
  CALL :run_flutter clean
  ECHO Clean finished.
  EXIT /B 0
)

nIF /I "%CMD%"=="debug" (
  REM Build debug APK (unobfuscated, debuggable)
  CALL :run_flutter build apk --debug --target-platform android-arm,android-arm64,android-x64
  ECHO Debug APK build finished.
  EXIT /B 0
)

nIF /I "%CMD%"=="release" (
  REM Build release APK (split per ABI by default). To get universal, add --split-per-abi=false and --target-platform option.
  CALL :run_flutter build apk --release
  ECHO Release APK build finished.
  EXIT /B 0
)

nIF /I "%CMD%"=="both" (
  ECHO Building debug APK...
  CALL :run_flutter build apk --debug --target-platform android-arm,android-arm64,android-x64
  ECHO Debug APK build finished.
  ECHO.
  ECHO Building release APK...
  CALL :run_flutter build apk --release
  ECHO Release APK build finished.
  EXIT /B 0
)

nECHO Unknown command: %CMD%
ECHO Usage: build_apk.bat [debug|release|both|clean]
EXIT /B 1
