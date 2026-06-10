@echo off
setlocal

set HERMES_HOME=%HERMES_HOME%
if "%HERMES_HOME%"=="" set HERMES_HOME=%USERPROFILE%\.hermes
if not exist "%HERMES_HOME%" mkdir "%HERMES_HOME%"

set SCRIPT_DIR=%~dp0
set HERMES_REPO=%HERMES_REPO%
if "%HERMES_REPO%"=="" set HERMES_REPO=%SCRIPT_DIR%

:: 1. 检查 PATH 中的 hermes
where hermes >nul 2>&1
if %ERRORLEVEL%==0 (
    for /f "delims=" %%i in ('where hermes') do set HERMES_BIN=%%i
    goto :run
)

:: 2. 检查 Hermes 桌面版安装路径
for /r "%LOCALAPPDATA%\Programs\hermes-cn-desktop" %%f in (hermes.exe) do (
    if exist "%%f" (
        set "HERMES_BIN=%%f"
        goto :run
    )
)
for /r "%PROGRAMFILES%\Hermes Agent CN Desktop" %%f in (hermes.exe) do (
    if exist "%%f" (
        set "HERMES_BIN=%%f"
        goto :run
    )
)

:: 3. 检查传统 venv 安装路径
if exist "%HERMES_REPO%\.venv\Scripts\hermes.exe" (
    set HERMES_BIN=%HERMES_REPO%\.venv\Scripts\hermes.exe
    goto :run
)
if exist "%HERMES_REPO%\venv\Scripts\hermes.exe" (
    set HERMES_BIN=%HERMES_REPO%\venv\Scripts\hermes.exe
    goto :run
)
if exist "%HERMES_REPO%\hermes.exe" (
    set HERMES_BIN=%HERMES_REPO%\hermes.exe
    goto :run
)

echo Hermes executable not found. >&2
echo Install Hermes Desktop from https://desktop.hermesagent.org.cn/ >&2
echo Or set HERMES_REPO to your hermes-agent directory. >&2
exit /b 1

:run
"%HERMES_BIN%" %*
