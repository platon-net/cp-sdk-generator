@echo off
call "%~dp0generate-sdk.bat" typescript %*
exit /b %errorlevel%
