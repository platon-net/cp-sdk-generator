@echo off
call "%~dp0generate-sdk.bat" php %*
exit /b %errorlevel%
