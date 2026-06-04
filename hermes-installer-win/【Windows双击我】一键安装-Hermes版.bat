@echo off
chcp 65001 >nul 2>&1
setlocal enabledelayedexpansion

:: ============================================================
:: Hermes + Obsidian + Claudian + CC-Switch 一键安装脚本（Windows版）v1.0
:: 双击 .bat 文件即可运行
:: ============================================================

echo.
echo  ╔═══════════════════════════════════════════════════╗
echo  ║  Hermes + Obsidian + Claudian + CC-Switch 一键安装  ║
echo  ╚═══════════════════════════════════════════════════╝
echo.
echo  本脚本将自动安装以下组件：
echo    [1] Python 3.11（Hermes 运行环境）
echo    [2] Hermes Agent（AI 编码代理）
echo    [3] CC Switch（模型切换工具）
echo    [4] Obsidian（知识库主程序）
echo    [5] Claudian 插件（含 Hermes 集成）
echo.
echo  整个过程大约 5-15 分钟。
echo.
pause

:: 脚本所在目录
set PACK_DIR=%~dp0

:: ============================================================
:: 第1步：检查 Python 3.11+
:: ============================================================
echo.
echo  ========================================
echo  [1/5] 检查 Python...
echo  ========================================

set PYTHON_OK=0
python --version 2>nul | findstr /R "3\.1[1-9]" >nul
if %ERRORLEVEL%==0 (
    echo  [√] Python 已安装。
    set PYTHON_OK=1
)

if %PYTHON_OK%==0 (
    python3 --version 2>nul | findstr /R "3\.1[1-9]" >nul
    if !ERRORLEVEL!==0 (
        echo  [√] Python 已安装。
        set PYTHON_OK=1
    )
)

if %PYTHON_OK%==0 (
    echo  [*] 未检测到 Python 3.11+，正在安装...
    set LOCAL_PYTHON=%PACK_DIR%installers\python-3.11-amd64.exe
    if exist "!LOCAL_PYTHON!" (
        echo  [*] 正在从本地安装包安装 Python...（可能需要管理员权限）
        "!LOCAL_PYTHON!" /quiet InstallAllUsers=0 PrependPath=1 Include_test=0
        set PYTHON_OK=1
    ) else (
        echo  [!] 未找到本地 Python 安装包。
        echo  [!] 请手动下载安装 Python 3.11+：https://www.python.org/downloads/
        echo  [!] 安装时请勾选 "Add Python to PATH"
        pause
        exit /b 1
    )
)

:: 刷新 PATH
set PATH=%LOCALAPPDATA%\Programs\Python\Python311;%LOCALAPPDATA%\Programs\Python\Python311\Scripts;%PATH%

:: ============================================================
:: 第2步：安装 Hermes Agent
:: ============================================================
echo.
echo  ========================================
echo  [2/5] 检查 Hermes Agent...
echo  ========================================

set HERMES_HOME=%USERPROFILE%\.hermes
set HERMES_REPO=%HERMES_HOME%\hermes-agent

if exist "%HERMES_REPO%\venv\Scripts\hermes.exe" (
    echo  [√] Hermes Agent 已安装，跳过。
    goto :hermes_done
)

echo  [*] 正在安装 Hermes Agent...

:: 解压 hermes-agent
if not exist "%HERMES_HOME%" mkdir "%HERMES_HOME%"
set LOCAL_HERMES=%PACK_DIR%installers\hermes-agent.tar.gz
if exist "%LOCAL_HERMES%" (
    echo  [*] 正在从本地离线包解压 hermes-agent...
    :: Windows 需要 tar 命令（Win10+ 自带）
    tar -xzf "%LOCAL_HERMES%" -C "%HERMES_HOME%\"
    echo  [√] hermes-agent 离线解压完成。
) else (
    echo  [!] 未找到 hermes-agent 离线包。
    echo  [*] 正在从 GitHub 克隆...
    git clone https://github.com/NousResearch/hermes-agent.git "%HERMES_REPO%"
)

:: 创建 venv 并安装
echo  [*] 正在创建 Python 虚拟环境...
python -m venv "%HERMES_REPO%\venv"

:: 升级 pip
"%HERMES_REPO%\venv\Scripts\python.exe" -m pip install --upgrade pip -q 2>nul

:: 安装依赖
set LOCAL_PYTHON_PKGS=%PACK_DIR%installers\python-packages
if exist "%LOCAL_PYTHON_PKGS%\requirements.txt" (
    echo  [*] 正在从本地离线包安装 Python 依赖...
    "%HERMES_REPO%\venv\Scripts\pip.exe" install --no-index --find-links "%LOCAL_PYTHON_PKGS%" -r "%LOCAL_PYTHON_PKGS%\requirements.txt" -q 2>nul
    "%HERMES_REPO%\venv\Scripts\pip.exe" install --no-index --find-links "%LOCAL_PYTHON_PKGS%" -e "%HERMES_REPO%" -q 2>nul
    echo  [√] Python 依赖离线安装完成。
) else (
    echo  [*] 正在在线安装 Hermes 依赖...
    "%HERMES_REPO%\venv\Scripts\pip.exe" install -e "%HERMES_REPO%" 2>nul
)

:hermes_done

:: ============================================================
:: 第3步：安装 CC Switch
:: ============================================================
echo.
echo  ========================================
echo  [3/5] 检查 CC Switch...
echo  ========================================

:: 检查是否已安装（通过注册表或常见安装路径）
if exist "%LOCALAPPDATA%\CC Switch\CC Switch.exe" (
    echo  [√] CC Switch 已安装，跳过。
    goto :cc_done
)
if exist "%PROGRAMFILES%\CC Switch\CC Switch.exe" (
    echo  [√] CC Switch 已安装，跳过。
    goto :cc_done
)

set LOCAL_CC=%PACK_DIR%installers\CC-Switch.msi
if exist "%LOCAL_CC%" (
    echo  [*] 正在从本地安装包安装 CC Switch...
    msiexec /i "%LOCAL_CC%" /quiet /norestart
    echo  [√] CC Switch 安装完成。
) else (
    echo  [!] 未找到 CC Switch 离线包。
    echo  [*] 请手动下载: https://github.com/farion1231/cc-switch/releases
)

:cc_done

:: ============================================================
:: 第4步：安装 Obsidian
:: ============================================================
echo.
echo  ========================================
echo  [4/5] 检查 Obsidian...
echo  ========================================

if exist "%LOCALAPPDATA%\Obsidian\Obsidian.exe" (
    echo  [√] Obsidian 已安装，跳过。
    goto :obsidian_done
)
if exist "%PROGRAMFILES%\Obsidian\Obsidian.exe" (
    echo  [√] Obsidian 已安装，跳过。
    goto :obsidian_done
)

set LOCAL_OBSIDIAN=%PACK_DIR%installers\Obsidian-Setup.exe
if exist "%LOCAL_OBSIDIAN%" (
    echo  [*] 正在从本地安装包安装 Obsidian...
    "%LOCAL_OBSIDIAN%" /S
    echo  [√] Obsidian 安装完成。
) else (
    echo  [!] 未找到 Obsidian 离线包。
    echo  [*] 请手动下载: https://obsidian.md
)

:obsidian_done

:: ============================================================
:: 第5步：安装 Claudian 插件
:: ============================================================
echo.
echo  ========================================
echo  [5/5] 安装 Claudian 插件...
echo  ========================================

:: 选择知识库路径
echo.
echo  请选择知识库安装位置：
echo    [1] %USERPROFILE%\ObsidianVaults\我的知识库（推荐）
echo    [2] 自定义路径
echo.
set /p VAULT_CHOICE="  输入数字（默认1）："

if "%VAULT_CHOICE%"=="2" (
    set /p VAULT_DIR="  请输入完整路径："
) else (
    set VAULT_DIR=%USERPROFILE%\ObsidianVaults\我的知识库
)

echo.
echo  [*] 知识库位置：%VAULT_DIR%

:: 创建目录
if not exist "%VAULT_DIR%\.obsidian\plugins" mkdir "%VAULT_DIR%\.obsidian\plugins"

set PLUGINS_DIR=%VAULT_DIR%\.obsidian\plugins
set SRC_PLUGINS=%PACK_DIR%plugins

if not exist "%SRC_PLUGINS%\realclaudian" (
    echo  [!] 找不到插件文件夹：%SRC_PLUGINS%\realclaudian
    pause
    exit /b 1
)

:: 复制插件
echo  [*] 安装插件：realclaudian
xcopy /E /I /Y "%SRC_PLUGINS%\realclaudian" "%PLUGINS_DIR%\realclaudian" >nul
echo  [√] realclaudian 已安装。

:: 导入 vault 模板
set SRC_VAULT=%PACK_DIR%vault
if exist "%SRC_VAULT%" (
    echo  [*] 正在导入知识库模板...
    xcopy /E /I /Y "%SRC_VAULT%\*" "%VAULT_DIR%\" >nul 2>&1
    echo  [√] 知识库模板导入完成。
)

:: ============================================================
:: 配置 Claudian 插件
:: ============================================================
echo.
echo  ========================================
echo  [5.5] 自动配置 Claudian 插件...
echo  ========================================

if not exist "%VAULT_DIR%\.claudian" mkdir "%VAULT_DIR%\.claudian"

set CLAUDIAN_SETTINGS=%VAULT_DIR%\.claudian\claudian-settings.json
set RUN_HERMES_PATH=%PLUGINS_DIR%\realclaudian\run-hermes.bat

:: 写入 claudian-settings.json
echo  [*] 写入 Claudian 配置...
python -c "import json,os;f='%CLAUDIAN_SETTINGS%';s=json.load(open(f)) if os.path.exists(f) else {};s['settingsProvider']='hermes';s['model']='hermes';pc=s.setdefault('providerConfigs',{});pc['hermes']={'cliPath':'%RUN_HERMES_PATH%','cliPathsByHost':{},'enabled':True,'environmentHash':'','environmentVariables':'HERMES_HOME=%HERMES_HOME%'};s.setdefault('savedProviderModel',{})['hermes']='hermes';json.dump(s,open(f,'w'),indent=2,ensure_ascii=False)" 2>nul
echo  [√] Claudian 配置已写入。

:: 写入 data.json
set DATA_JSON=%PLUGINS_DIR%\realclaudian\data.json
python -c "import json,os;d=json.load(open('%DATA_JSON%')) if os.path.exists('%DATA_JSON%') else {};d['environmentVariables']=[{'name':'HERMES_HOME','value':'%HERMES_HOME%'}];json.dump(d,open('%DATA_JSON%','w'),indent=2,ensure_ascii=False)" 2>nul
echo  [√] 插件环境变量已配置。

:: ============================================================
:: 完成
:: ============================================================
echo.
echo  ╔═══════════════════════════════════════════════════╗
echo  ║              √ 安装全部完成！                     ║
echo  ╚═══════════════════════════════════════════════════╝
echo.
echo  ****************************************************
echo  *  YOUR VAULT PATH:
echo  *  %VAULT_DIR%
echo  *
echo  *  IMPORTANT: Open THIS folder in Obsidian.
echo  ****************************************************
echo.
echo  接下来只需 3 步（手动）：
echo.
echo    1. 打开 CC Switch → 配置 API Key 和模型
echo    2. 打开 Obsidian → 选择上面星号框里的知识库路径
echo    3. 设置 → 第三方插件 → 关闭安全模式 → 启用 Claudian 插件
echo.

:: 自动打开 CC Switch
if exist "%LOCALAPPDATA%\CC Switch\CC Switch.exe" (
    echo  [*] 正在打开 CC Switch...
    start "" "%LOCALAPPDATA%\CC Switch\CC Switch.exe"
) else if exist "%PROGRAMFILES%\CC Switch\CC Switch.exe" (
    echo  [*] 正在打开 CC Switch...
    start "" "%PROGRAMFILES%\CC Switch\CC Switch.exe"
)

pause
