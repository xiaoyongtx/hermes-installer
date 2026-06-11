@echo off
setlocal

set HERMES_HOME=%HERMES_HOME%
if "%HERMES_HOME%"=="" set HERMES_HOME=%USERPROFILE%\.hermes
if not exist "%HERMES_HOME%" mkdir "%HERMES_HOME%"

:: 0. 优先查找 hermes-agent venv 安装（安装脚本放在 %HERMES_HOME%\hermes-agent\venv）
if exist "%HERMES_HOME%\hermes-agent\venv\Scripts\hermes.exe" (
    set "HERMES_BIN=%HERMES_HOME%\hermes-agent\venv\Scripts\hermes.exe"
    goto :run
)

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

:: 3. 检查插件目录下的传统 venv 安装路径
set SCRIPT_DIR=%~dp0
if exist "%SCRIPT_DIR%\.venv\Scripts\hermes.exe" (
    set "HERMES_BIN=%SCRIPT_DIR%\.venv\Scripts\hermes.exe"
    goto :run
)
if exist "%SCRIPT_DIR%\venv\Scripts\hermes.exe" (
    set "HERMES_BIN=%SCRIPT_DIR%\venv\Scripts\hermes.exe"
    goto :run
)

:: 4. 通过 HERMES_REPO 环境变量查找
if not "%HERMES_REPO%"=="" (
    if exist "%HERMES_REPO%\venv\Scripts\hermes.exe" (
        set "HERMES_BIN=%HERMES_REPO%\venv\Scripts\hermes.exe"
        goto :run
    )
    if exist "%HERMES_REPO%\.venv\Scripts\hermes.exe" (
        set "HERMES_BIN=%HERMES_REPO%\.venv\Scripts\hermes.exe"
        goto :run
    )
)

echo Hermes executable not found. >&2
echo Tried: >&2
echo   - %%HERMES_HOME%%\hermes-agent\venv\Scripts\hermes.exe >&2
echo   - hermes in PATH >&2
echo   - Hermes Desktop install paths >&2
echo   - %%SCRIPT_DIR%%\venv\Scripts\hermes.exe >&2
echo   - %%HERMES_REPO%%\venv\Scripts\hermes.exe >&2
echo. >&2
echo Install Hermes: https://desktop.hermesagent.org.cn/ >&2
echo Or set HERMES_REPO to your hermes-agent directory. >&2
exit /b 1

:run
"%HERMES_BIN%" %*
