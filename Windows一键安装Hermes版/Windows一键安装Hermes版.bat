@echo off
chcp 65001 >nul 2>&1
setlocal enabledelayedexpansion

:: ============================================================
:: Hermes + Obsidian + Claudian + CC-Switch 一键安装脚本（Windows版）v1.1
:: 双击 .bat 文件即可运行
:: ============================================================

echo.
echo  ╔═══════════════════════════════════════════════════╗
echo  ║  Hermes + Obsidian + Claudian + CC-Switch 一键安装  ║
echo  ╚═══════════════════════════════════════════════════╝
echo.
echo  本脚本将自动安装以下组件：
echo    [1] Python 3.11（Hermes 运行环境）
echo    [2] Hermes Agent（AI 代理）
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
:: 预检：代理探测
:: ============================================================
echo.
echo  ========================================
echo  [预检] 探测终端代理...
echo  ========================================

set PROXY_SET=0
if not "%HTTPS_PROXY%"=="" (
    echo  [√] HTTPS_PROXY already set: %HTTPS_PROXY%
    set PROXY_SET=1
)

if !PROXY_SET!==0 (
    for %%p in (7890 7897 7898 1080 1087 8080) do (
        netstat -an 2>nul | findstr "127.0.0.1:%%p" >nul 2>&1
        if !ERRORLEVEL!==0 (
            set HTTPS_PROXY=http://127.0.0.1:%%p
            set HTTP_PROXY=http://127.0.0.1:%%p
            echo  [√] found proxy on port %%p, auto-configured.
            set PROXY_SET=1
        )
    )
)

if !PROXY_SET!==0 (
    echo  [*] 未检测到本地代理，使用直连。
    echo  [*] 如果下载失败，请先开启 VPN/代理工具。
)

:: ============================================================
:: 第1步：检查 Python 3.11+
:: ============================================================
echo.
echo  ========================================
echo  [1/5] 检查 Python...
echo  ========================================

set PYTHON_OK=0
set PYTHON_JUST_INSTALLED=0

python --version 2>nul | findstr /R "3\.1[1-9]" >nul
if !ERRORLEVEL!==0 (
    echo  [√] Python 已安装。
    set PYTHON_OK=1
)

if !PYTHON_OK!==0 (
    python3 --version 2>nul | findstr /R "3\.1[1-9]" >nul
    if !ERRORLEVEL!==0 (
        echo  [√] Python 已安装。
        set PYTHON_OK=1
    )
)

if !PYTHON_OK!==0 (
    echo  [*] 未检测到 Python 3.11+，正在安装...
    set LOCAL_PYTHON=!PACK_DIR!installers\python-3.11-amd64.exe
    if exist "!LOCAL_PYTHON!" (
        :: 安装位置选择
        set PYTHON_INSTALL_DIR=%LOCALAPPDATA%\Programs\Python\Python311
        echo.
        echo   默认安装路径：!PYTHON_INSTALL_DIR!
        set /p PYTHON_CUSTOM="   输入新路径或按回车使用默认："
        if not "!PYTHON_CUSTOM!"=="" set PYTHON_INSTALL_DIR=!PYTHON_CUSTOM!
        echo  [*] 安装到：!PYTHON_INSTALL_DIR!
        echo  [*] 正在从本地安装包安装 Python...（可能需要管理员权限）
        "!LOCAL_PYTHON!" /quiet InstallAllUsers=0 PrependPath=1 Include_test=0 TargetDir=!PYTHON_INSTALL_DIR!
        set PYTHON_OK=1
        set PYTHON_JUST_INSTALLED=1
    ) else (
        echo  [!] 未找到本地 Python 安装包。
        echo  [!] 请手动下载安装 Python 3.11+：https://www.python.org/downloads/
        echo  [!] 安装时请勾选 "Add Python to PATH"
        pause
        exit /b 1
    )
)

:: 确定 Python 路径（刚安装的直接用安装路径，不依赖 PATH）
if !PYTHON_JUST_INSTALLED!==1 (
    set PYTHON_BIN=!PYTHON_INSTALL_DIR!\python.exe
    if not exist "!PYTHON_BIN!" (
        :: 尝试其他常见路径
        if exist "%PROGRAMFILES%\Python311\python.exe" (
            set PYTHON_BIN=%PROGRAMFILES%\Python311\python.exe
        ) else if exist "C:\Python311\python.exe" (
            set PYTHON_BIN=C:\Python311\python.exe
        )
    )
) else (
    :: 已有 Python，优先用完整路径，其次用 PATH 中的命令
    for /f "delims=" %%i in ('where python 2^>nul') do set PYTHON_BIN=%%i
    if "!PYTHON_BIN!"=="" (
        for /f "delims=" %%i in ('where python3 2^>nul') do set PYTHON_BIN=%%i
    )
)

if not exist "!PYTHON_BIN!" (
    echo  [!] Python 命令未找到，请检查安装。
    pause
    exit /b 1
)
echo  [*] 使用 Python: !PYTHON_BIN!

:: ============================================================
:: 第2步：安装 Hermes Agent（venv + pip，对齐 Mac 方式）
:: ============================================================
echo.
echo  ========================================
echo  [2/5] 检查 Hermes Agent...
echo  ========================================

set HERMES_HOME=%HERMES_HOME%
if "%HERMES_HOME%"=="" set HERMES_HOME=%USERPROFILE%\.hermes
set HERMES_REPO=%HERMES_HOME%\hermes-agent

if exist "%HERMES_REPO%\venv\Scripts\hermes.exe" (
    echo  [√] Hermes Agent 已安装，跳过。
    "%HERMES_REPO%\venv\Scripts\hermes.exe" --version 2>nul
    goto :hermes_done
)

echo  [*] 正在安装 Hermes Agent...

:: 确保 git 可用
where git >nul 2>&1
if !ERRORLEVEL! neq 0 (
    echo  [!] 未检测到 git，请先安装 Git for Windows。
    echo  [*] 下载地址: https://git-scm.com/download/win
    pause
    exit /b 1
)

:: 确保目录存在
if not exist "%HERMES_HOME%" mkdir "%HERMES_HOME%"

set HERMES_EXTRACT_OK=0

:: 使用预解压目录
set LOCAL_HERMES_DIR=%PACK_DIR%installers\hermes-agent
if exist "!LOCAL_HERMES_DIR!\pyproject.toml" (
    echo  [*] 正在复制 hermes-agent...
    xcopy /E /I /Y "!LOCAL_HERMES_DIR!" "%HERMES_REPO%" >nul
    if exist "%HERMES_REPO%\pyproject.toml" (
        set HERMES_EXTRACT_OK=1
        echo  [√] hermes-agent 复制完成。
    )
)

if !HERMES_EXTRACT_OK!==0 (
    echo  [!] hermes-agent 包不可用。
    echo  [!] 请确保 installers\hermes-agent\ 目录存在。
    pause
    exit /b 1
)

:: 初始化 git 仓库（pip install -e 需要）
(cd /d "%HERMES_REPO%" && git init -q && git add -A && git commit -q -m "init") 2>nul

:: 创建 venv
echo  [*] 正在创建 Python 虚拟环境（!PYTHON_BIN!）...
"!PYTHON_BIN!" -m venv "%HERMES_REPO%\venv"
if !ERRORLEVEL! neq 0 (
    echo  [!] Python 虚拟环境创建失败，请检查 Python 安装。
    pause
    exit /b 1
)

:: 升级 pip
echo  [*] 正在升级 pip...
"%HERMES_REPO%\venv\Scripts\pip.exe" install --upgrade pip -q 2>nul

:: 安装依赖（优先使用本地离线 wheels）
set LOCAL_WHEELS=%PACK_DIR%installers\python-packages
if exist "%LOCAL_WHEELS%\requirements.txt" (
    echo  [*] 正在从本地离线包安装 Python 依赖...
    "%HERMES_REPO%\venv\Scripts\pip.exe" install --no-index --find-links "%LOCAL_WHEELS%" -r "%LOCAL_WHEELS%\requirements.txt" -q
    "%HERMES_REPO%\venv\Scripts\pip.exe" install --no-index --find-links "%LOCAL_WHEELS%" -e "%HERMES_REPO%" -q
    if exist "%HERMES_REPO%\venv\Scripts\hermes.exe" (
        echo  [√] Python 依赖离线安装完成。
    ) else (
        echo  [!] hermes 命令不可用，尝试修复...
        "%HERMES_REPO%\venv\Scripts\pip.exe" install --no-index --find-links "%LOCAL_WHEELS%" "%HERMES_REPO%" -q
    )
) else (
    :: 在线安装（兜底）
    echo  [*] 正在在线安装 Hermes 依赖（可能需要几分钟）...
    "%HERMES_REPO%\venv\Scripts\pip.exe" install -i https://mirrors.ustc.edu.cn/pypi/web/simple -e "%HERMES_REPO%"
)

:: 创建包装脚本
if not exist "%USERPROFILE%\.local\bin" mkdir "%USERPROFILE%\.local\bin"
(
echo @echo off
echo set HERMES_HOME=%%USERPROFILE%%\.hermes
echo "%%HERMES_HOME%%\hermes-agent\venv\Scripts\hermes.exe" %%*
) > "%USERPROFILE%\.local\bin\hermes.bat"

:: 将 .local\bin 加入 PATH
set LOCAL_BIN=%USERPROFILE%\.local\bin
echo ;!PATH!; | findstr /C:";%LOCAL_BIN%;" >nul
if !ERRORLEVEL! neq 0 (
    set PATH=%LOCAL_BIN%;%PATH%
    :: 持久化到注册表
    for /f "skip=2 tokens=3*" %%a in ('reg query HKCU\Environment /v PATH 2^>nul') do set USER_PATH=%%b
    echo !USER_PATH! | findstr /C:"%LOCAL_BIN%" >nul
    if !ERRORLEVEL! neq 0 (
        if "!USER_PATH!"=="" (
            setx PATH "%LOCAL_BIN%" >nul
        ) else (
            setx PATH "!USER_PATH!;%LOCAL_BIN%" >nul
        )
        echo  [√] 已将 .local\bin 加入用户 PATH。
    )
)

if exist "%HERMES_REPO%\venv\Scripts\hermes.exe" (
    echo  [√] Hermes Agent 安装完成。
) else (
    echo  [!] Hermes 安装可能有问题，请检查输出。
)

:hermes_done

:: ============================================================
:: 第2.5步：安装预置技能
:: ============================================================
echo.
echo  ========================================
echo  [2.5/5] 安装预置技能...
echo  ========================================

set HERMES_SKILLS_DIR=%HERMES_HOME%\skills
set SRC_SKILLS=%PACK_DIR%skills

if exist "%SRC_SKILLS%" (
    if not exist "%HERMES_SKILLS_DIR%" mkdir "%HERMES_SKILLS_DIR%"
    echo  [*] 正在安装预置技能到 %HERMES_SKILLS_DIR% ...

    for /d %%d in ("%SRC_SKILLS%\*") do (
        set SKILL_NAME=%%~nxd
        if not "!SKILL_NAME:~0,1!"=="." (
            xcopy /E /I /Y "%%d" "%HERMES_SKILLS_DIR%\!SKILL_NAME!" >nul 2>&1
            echo  [√] 技能已安装: !SKILL_NAME!
        )
    )

    echo  [√] 预置技能安装完成。
) else (
    echo  [*] 未找到预置技能文件夹，跳过。
)

:: ============================================================
:: 第3步：安装 CC Switch
:: ============================================================
echo.
echo  ========================================
echo  [3/5] 检查 CC Switch...
echo  ========================================

:: 检查是否已安装
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
    :: 安装位置选择
    set CC_INSTALL_DIR=%LOCALAPPDATA%\CC Switch
    echo.
    echo   默认安装路径：!CC_INSTALL_DIR!
    set /p CC_CUSTOM="   输入新路径或按回车使用默认："
    if not "!CC_CUSTOM!"=="" set CC_INSTALL_DIR=!CC_CUSTOM!
    echo  [*] 安装到：!CC_INSTALL_DIR!
    echo  [*] 正在从本地安装包安装 CC Switch...
    msiexec /i "%LOCAL_CC%" /quiet /norestart INSTALLDIR="!CC_INSTALL_DIR!"
    echo  [√] CC Switch 安装完成。
) else (
    echo  [!] 未找到 CC Switch 离线包。
    echo  [*] 请手动下载: https://github.com/farion1231/cc-switch/releases
)

:cc_done

echo  [*] 安装完成后，请打开 CC-Switch 配置你的 API Key 和模型。

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
    :: 安装位置选择
    set OBSIDIAN_INSTALL_DIR=%LOCALAPPDATA%\Obsidian
    echo.
    echo   默认安装路径：!OBSIDIAN_INSTALL_DIR!
    set /p OBSIDIAN_CUSTOM="   输入新路径或按回车使用默认："
    if not "!OBSIDIAN_CUSTOM!"=="" set OBSIDIAN_INSTALL_DIR=!OBSIDIAN_CUSTOM!
    echo  [*] 安装到：!OBSIDIAN_INSTALL_DIR!
    echo  [*] 正在从本地安装包安装 Obsidian...
    "%LOCAL_OBSIDIAN%" /S /DIR="!OBSIDIAN_INSTALL_DIR!"
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
!PYTHON_BIN! -c "import json,os;f=r'%CLAUDIAN_SETTINGS%';s=json.load(open(f)) if os.path.exists(f) else {};s['settingsProvider']='hermes';s['model']='hermes';pc=s.setdefault('providerConfigs',{});pc['hermes']={'cliPath':r'%RUN_HERMES_PATH%','cliPathsByHost':{},'enabled':True,'environmentHash':'','environmentVariables':r'HERMES_HOME=%HERMES_HOME%'};s.setdefault('savedProviderModel',{})['hermes']='hermes';json.dump(s,open(f,'w'),indent=2,ensure_ascii=False)" 2>nul
echo  [√] Claudian 配置已写入。

:: 写入 data.json
set DATA_JSON=%PLUGINS_DIR%\realclaudian\data.json
!PYTHON_BIN! -c "import json,os;d=json.load(open(r'%DATA_JSON%')) if os.path.exists(r'%DATA_JSON%') else {};d['environmentVariables']=[{'name':'HERMES_HOME','value':r'%HERMES_HOME%'}];json.dump(d,open(r'%DATA_JSON%','w'),indent=2,ensure_ascii=False)" 2>nul
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
if exist "!CC_INSTALL_DIR!\CC Switch.exe" (
    echo  [*] 正在打开 CC Switch...
    start "" "!CC_INSTALL_DIR!\CC Switch.exe"
) else if exist "%LOCALAPPDATA%\CC Switch\CC Switch.exe" (
    echo  [*] 正在打开 CC Switch...
    start "" "%LOCALAPPDATA%\CC Switch\CC Switch.exe"
) else if exist "%PROGRAMFILES%\CC Switch\CC Switch.exe" (
    echo  [*] 正在打开 CC Switch...
    start "" "%PROGRAMFILES%\CC Switch\CC Switch.exe"
)

pause
