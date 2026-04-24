@echo off
setlocal EnableExtensions

set "LANGUAGE=%~1"
if not defined LANGUAGE (
  echo Error: Usage: %~nx0 ^<php^|typescript^|kotlin^|swift^> [--clean] 1>&2
  exit /b 1
)
shift

set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..") do set "REPO_ROOT=%%~fI"

set "CLEAN_FIRST=0"
:parse_args
if "%~1"=="" goto parsed_args
if /I "%~1"=="--clean" (
  set "CLEAN_FIRST=1"
  shift
  goto parse_args
)
echo Error: Unknown argument: %~1 1>&2
exit /b 1

:parsed_args
if /I "%LANGUAGE%"=="php" (
  set "GENERATOR=php"
  set "CONFIG=%REPO_ROOT%\config\php.yaml"
  set "OUTPUT=%REPO_ROOT%\sdk\php"
  set "REPO_ID=cp-php-sdk"
) else if /I "%LANGUAGE%"=="typescript" (
  set "GENERATOR=typescript-axios"
  set "CONFIG=%REPO_ROOT%\config\typescript.yaml"
  set "OUTPUT=%REPO_ROOT%\sdk\typescript"
  set "REPO_ID=cp-typescript-sdk"
) else if /I "%LANGUAGE%"=="kotlin" (
  set "GENERATOR=kotlin"
  set "CONFIG=%REPO_ROOT%\config\kotlin.yaml"
  set "OUTPUT=%REPO_ROOT%\sdk\kotlin"
  set "REPO_ID=cp-kotlin-sdk"
) else if /I "%LANGUAGE%"=="swift" (
  set "GENERATOR=swift6"
  set "CONFIG=%REPO_ROOT%\config\swift.yaml"
  set "OUTPUT=%REPO_ROOT%\sdk\swift"
  set "REPO_ID=cp-swift-sdk"
) else (
  echo Error: Unsupported SDK language: %LANGUAGE% 1>&2
  exit /b 1
)

if "%CLEAN_FIRST%"=="1" (
  call "%SCRIPT_DIR%common.bat" :clean_generated_dir "%OUTPUT%"
  if errorlevel 1 exit /b 1
)

call "%SCRIPT_DIR%common.bat" :generate_sdk "%LANGUAGE%" "%GENERATOR%" "%CONFIG%" "%OUTPUT%" "%REPO_ID%"
exit /b %errorlevel%
