@echo off
setlocal EnableExtensions
call "%~dp0common.bat" validate_openapi
exit /b %errorlevel%
