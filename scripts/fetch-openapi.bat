@echo off
setlocal EnableExtensions
call "%~dp0common.bat" fetch_openapi
exit /b %errorlevel%
