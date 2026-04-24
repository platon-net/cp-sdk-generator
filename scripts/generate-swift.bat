@echo off
call "%~dp0generate-sdk.bat" swift %*
exit /b %errorlevel%
