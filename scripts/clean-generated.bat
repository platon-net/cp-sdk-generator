@echo off
setlocal EnableExtensions

set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..") do set "REPO_ROOT=%%~fI"
set "TARGET=%~1"
if not defined TARGET set "TARGET=all"

if /I "%TARGET%"=="all" (
  call "%SCRIPT_DIR%common.bat" :clean_generated_dir "%REPO_ROOT%\sdk\php"
  if errorlevel 1 exit /b 1
  call "%SCRIPT_DIR%common.bat" :clean_generated_dir "%REPO_ROOT%\sdk\typescript"
  if errorlevel 1 exit /b 1
  call "%SCRIPT_DIR%common.bat" :clean_generated_dir "%REPO_ROOT%\sdk\kotlin"
  if errorlevel 1 exit /b 1
  call "%SCRIPT_DIR%common.bat" :clean_generated_dir "%REPO_ROOT%\sdk\swift"
  exit /b %errorlevel%
)

if /I "%TARGET%"=="php" (
  call "%SCRIPT_DIR%common.bat" :clean_generated_dir "%REPO_ROOT%\sdk\php"
  exit /b %errorlevel%
)
if /I "%TARGET%"=="typescript" (
  call "%SCRIPT_DIR%common.bat" :clean_generated_dir "%REPO_ROOT%\sdk\typescript"
  exit /b %errorlevel%
)
if /I "%TARGET%"=="kotlin" (
  call "%SCRIPT_DIR%common.bat" :clean_generated_dir "%REPO_ROOT%\sdk\kotlin"
  exit /b %errorlevel%
)
if /I "%TARGET%"=="swift" (
  call "%SCRIPT_DIR%common.bat" :clean_generated_dir "%REPO_ROOT%\sdk\swift"
  exit /b %errorlevel%
)

echo Error: Usage: %~nx0 [php^|typescript^|kotlin^|swift^|all] 1>&2
exit /b 1
