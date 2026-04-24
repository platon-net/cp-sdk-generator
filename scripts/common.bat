@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..") do set "REPO_ROOT=%%~fI"

if not defined OPENAPI_SPEC_URL set "OPENAPI_SPEC_URL=https://setup.platon.sk/api/openapi.json"
if not defined OPENAPI_FILE set "OPENAPI_FILE=%REPO_ROOT%\openapi\openapi.json"
if not defined OPENAPI_GENERATOR_CMD set "OPENAPI_GENERATOR_CMD=openapi-generator-cli.cmd"
if not defined SDK_VERSION set "SDK_VERSION=1.0.0"
if not defined GIT_HOST set "GIT_HOST=github.com"
if not defined GIT_USER_ID set "GIT_USER_ID=platon-net"

if "%~1"=="" exit /b 0
set "ACTION=%~1"
if "%ACTION:~0,1%"==":" set "ACTION=%ACTION:~1%"
shift
goto %ACTION%

:log
echo ==^> %~1
exit /b 0

:fail
echo Error: %~1 1>&2
exit /b 1

:ensure_spec_dir
if not exist "%REPO_ROOT%\openapi" mkdir "%REPO_ROOT%\openapi"
if errorlevel 1 exit /b 1
exit /b 0

:ensure_openapi
if exist "%OPENAPI_FILE%" exit /b 0
call :fetch_openapi
exit /b %errorlevel%

:ensure_submodule_dir
set "TARGET_DIR=%~f1"
if not exist "%TARGET_DIR%" (
  call :fail "Directory does not exist: %TARGET_DIR%"
  exit /b 1
)
if not exist "%TARGET_DIR%\.git" (
  call :fail "Expected git submodule metadata in: %TARGET_DIR%"
  exit /b 1
)
exit /b 0

:fetch_openapi
call :ensure_spec_dir
if errorlevel 1 exit /b 1

set "TMP_FILE=%OPENAPI_FILE%.tmp"
call :log "Fetching OpenAPI spec from %OPENAPI_SPEC_URL%"
curl.exe --fail --location --silent --show-error -o "%TMP_FILE%" "%OPENAPI_SPEC_URL%"
if errorlevel 1 (
  powershell -NoProfile -Command "Invoke-WebRequest -Uri '%OPENAPI_SPEC_URL%' -OutFile '%TMP_FILE%'"
  if errorlevel 1 exit /b 1
)

move /Y "%TMP_FILE%" "%OPENAPI_FILE%" >nul
if errorlevel 1 exit /b 1
call :log "Saved spec to %OPENAPI_FILE%"
exit /b 0

:validate_openapi
call :ensure_openapi
if errorlevel 1 exit /b 1
call :log "Validating %OPENAPI_FILE%"
call "%OPENAPI_GENERATOR_CMD%" validate -i "%OPENAPI_FILE%" --recommend
exit /b %errorlevel%

:clean_generated_dir
set "TARGET_DIR=%~f1"
call :ensure_submodule_dir "%TARGET_DIR%"
if errorlevel 1 exit /b 1

set "SDK_PREFIX=%REPO_ROOT%\sdk\"
if /I "!TARGET_DIR:%SDK_PREFIX%=!"=="!TARGET_DIR!" (
  call :fail "Refusing to clean a directory outside %SDK_PREFIX%"
  exit /b 1
)

call :log "Cleaning generated files in %TARGET_DIR%"
for /f "delims=" %%I in ('dir /b /a "%TARGET_DIR%"') do (
  if /I not "%%I"==".git" (
    rd /s /q "%TARGET_DIR%\%%I" 2>nul
    del /f /q "%TARGET_DIR%\%%I" 2>nul
  )
)
exit /b 0

:run_postprocess_hook
set "LANGUAGE=%~1"
set "OUTPUT_DIR=%~f2"
set "HOOK=%REPO_ROOT%\scripts\postprocess\%LANGUAGE%.bat"
if exist "%HOOK%" (
  call :log "Running post-process hook %HOOK%"
  call "%HOOK%" "%OUTPUT_DIR%"
  exit /b %errorlevel%
)
exit /b 0

:generate_sdk
set "LANGUAGE=%~1"
set "GENERATOR=%~2"
set "CONFIG=%~f3"
set "OUTPUT_DIR=%~f4"
set "REPO_ID=%~5"

call :ensure_openapi
if errorlevel 1 exit /b 1
call :ensure_submodule_dir "%OUTPUT_DIR%"
if errorlevel 1 exit /b 1

if not exist "%CONFIG%" (
  call :fail "Generator config does not exist: %CONFIG%"
  exit /b 1
)

set "USE_TEMPLATE_DIR="
if defined TEMPLATE_DIR (
  if exist "%TEMPLATE_DIR%" set "USE_TEMPLATE_DIR=%TEMPLATE_DIR%"
)
if not defined USE_TEMPLATE_DIR (
  if exist "%REPO_ROOT%\templates\%LANGUAGE%" set "USE_TEMPLATE_DIR=%REPO_ROOT%\templates\%LANGUAGE%"
)

set "VERSION_VALUE="
if /I "%LANGUAGE%"=="php" set "VERSION_VALUE=artifactVersion=%SDK_VERSION%"
if /I "%LANGUAGE%"=="typescript" set "VERSION_VALUE=npmVersion=%SDK_VERSION%"
if /I "%LANGUAGE%"=="kotlin" set "VERSION_VALUE=artifactVersion=%SDK_VERSION%"
if /I "%LANGUAGE%"=="swift" set "VERSION_VALUE=podVersion=%SDK_VERSION%"

call :log "Generating %LANGUAGE% SDK into %OUTPUT_DIR%"

if defined USE_TEMPLATE_DIR (
  if defined VERSION_VALUE (
    call "%OPENAPI_GENERATOR_CMD%" generate -i "%OPENAPI_FILE%" -g "%GENERATOR%" -c "%CONFIG%" -o "%OUTPUT_DIR%" --git-host "%GIT_HOST%" --git-user-id "%GIT_USER_ID%" --git-repo-id "%REPO_ID%" --template-dir "%USE_TEMPLATE_DIR%" --additional-properties "%VERSION_VALUE%"
  ) else (
    call "%OPENAPI_GENERATOR_CMD%" generate -i "%OPENAPI_FILE%" -g "%GENERATOR%" -c "%CONFIG%" -o "%OUTPUT_DIR%" --git-host "%GIT_HOST%" --git-user-id "%GIT_USER_ID%" --git-repo-id "%REPO_ID%" --template-dir "%USE_TEMPLATE_DIR%"
  )
) else (
  if defined VERSION_VALUE (
    call "%OPENAPI_GENERATOR_CMD%" generate -i "%OPENAPI_FILE%" -g "%GENERATOR%" -c "%CONFIG%" -o "%OUTPUT_DIR%" --git-host "%GIT_HOST%" --git-user-id "%GIT_USER_ID%" --git-repo-id "%REPO_ID%" --additional-properties "%VERSION_VALUE%"
  ) else (
    call "%OPENAPI_GENERATOR_CMD%" generate -i "%OPENAPI_FILE%" -g "%GENERATOR%" -c "%CONFIG%" -o "%OUTPUT_DIR%" --git-host "%GIT_HOST%" --git-user-id "%GIT_USER_ID%" --git-repo-id "%REPO_ID%"
  )
)
if errorlevel 1 exit /b 1

call :run_postprocess_hook "%LANGUAGE%" "%OUTPUT_DIR%"
exit /b %errorlevel%
