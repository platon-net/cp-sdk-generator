@echo off
setlocal EnableExtensions

set "EXTRA_ARGS="
if not "%~1"=="" (
  if /I "%~1"=="--clean" (
    set "EXTRA_ARGS=--clean"
  ) else (
    echo Error: Usage: %~nx0 [--clean] 1>&2
    exit /b 1
  )
)

call "%~dp0fetch-openapi.bat"
if errorlevel 1 exit /b 1
call "%~dp0validate-openapi.bat"
if errorlevel 1 exit /b 1
call "%~dp0generate-php.bat" %EXTRA_ARGS%
if errorlevel 1 exit /b 1
call "%~dp0generate-typescript.bat" %EXTRA_ARGS%
if errorlevel 1 exit /b 1
call "%~dp0generate-kotlin.bat" %EXTRA_ARGS%
if errorlevel 1 exit /b 1
call "%~dp0generate-swift.bat" %EXTRA_ARGS%
exit /b %errorlevel%
