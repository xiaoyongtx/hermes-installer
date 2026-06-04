@echo off
setlocal

set HERMES_HOME=%HERMES_HOME%
if "%HERMES_HOME%"=="" set HERMES_HOME=%USERPROFILE%\.hermes
if not exist "%HERMES_HOME%" mkdir "%HERMES_HOME%"

set SCRIPT_DIR=%~dp0
set HERMES_REPO=%HERMES_REPO%
if "%HERMES_REPO%"=="" set HERMES_REPO=%SCRIPT_DIR%

if exist "%HERMES_REPO%\.venv\Scripts\hermes.exe" (
    set HERMES_BIN=%HERMES_REPO%\.venv\Scripts\hermes.exe
    goto :run
)
if exist "%HERMES_REPO%\venv\Scripts\hermes.exe" (
    set HERMES_BIN=%HERMES_REPO%\venv\Scripts\hermes.exe
    goto :run
)
where hermes >nul 2>&1
if %ERRORLEVEL%==0 (
    for /f "delims=" %%i in ('where hermes') do set HERMES_BIN=%%i
    goto :run
)
if exist "%HERMES_REPO%\hermes.exe" (
    set HERMES_BIN=%HERMES_REPO%\hermes.exe
    goto :run
)

echo Hermes executable not found. >&2
echo Set HERMES_REPO to your hermes-agent directory or install hermes on PATH. >&2
exit /b 1

:run
"%HERMES_BIN%" %*
