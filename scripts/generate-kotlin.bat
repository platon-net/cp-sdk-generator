@echo off
call "%~dp0generate-sdk.bat" kotlin %*
exit /b %errorlevel%
