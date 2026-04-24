@echo off
setlocal EnableExtensions

set "LANGUAGE=%~1"
if not defined LANGUAGE (
  echo Error: Usage: %~nx0 ^<php^|typescript^|kotlin^|swift^> 1>&2
  exit /b 1
)

if /I "%LANGUAGE%"=="php" (
  echo Publish workflow is intentionally a scaffold only.
  echo Publish via Composer package workflow for platon-net/cp-php-sdk.
  exit /b 1
)
if /I "%LANGUAGE%"=="typescript" (
  echo Publish workflow is intentionally a scaffold only.
  echo Publish via npm workflow for cp-typescript-sdk.
  exit /b 1
)
if /I "%LANGUAGE%"=="kotlin" (
  echo Publish workflow is intentionally a scaffold only.
  echo Publish via Maven Central or internal Maven workflow for cp-kotlin-sdk.
  exit /b 1
)
if /I "%LANGUAGE%"=="swift" (
  echo Publish workflow is intentionally a scaffold only.
  echo Publish via SwiftPM and optional CocoaPods workflow for cp-swift-sdk.
  exit /b 1
)

echo Error: Unsupported SDK language: %LANGUAGE% 1>&2
exit /b 1
