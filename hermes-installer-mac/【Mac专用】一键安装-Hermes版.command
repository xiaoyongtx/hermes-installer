#!/bin/bash
# ============================================================
# Hermes + Obsidian + Claudian 一键安装脚本（Mac版）v1.0
# 双击 .command 文件即可运行
# ============================================================

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

ok() { echo -e "  ${GREEN}[√]${NC} $1"; }
info() { echo -e "  ${YELLOW}[*]${NC} $1"; }
fail() { echo -e "  ${RED}[!]${NC} $1"; }
ask() { echo -e "  ${CYAN}[?]${NC} $1"; }

# 脚本所在目录
PACK_DIR="$(cd "$(dirname "$0")" && pwd)"

echo ""
echo "  ╔═══════════════════════════════════════════════════╗"
echo "  ║  Hermes + Obsidian + Claudian + CC-Switch 一键安装  ║"
echo "  ╚═══════════════════════════════════════════════════╝"
echo ""
echo "  本脚本将自动安装以下组件："
echo "    [1] Homebrew（包管理器，已有则跳过）"
echo "    [2] Python 3.11+（Hermes 运行环境）"
echo "    [3] Hermes Agent（AI 编码代理）"
echo "    [4] CC-Switch（模型切换工具）"
echo "    [5] Obsidian（知识库主程序）"
echo "    [6] Claudian 插件（含 Hermes 集成）"
echo ""
echo "  整个过程大约 5-15 分钟。"
echo ""
read -p "  按回车开始安装..." _

# ============================================================
# 预检：代理探测
# ============================================================
echo ""
echo "  ========================================"
echo "  [预检] 探测终端代理..."
echo "  ========================================"

PROXY_SET=0
if [[ -n "$HTTPS_PROXY" ]]; then
    ok "HTTPS_PROXY already set: $HTTPS_PROXY"
    PROXY_SET=1
fi

if [[ "$PROXY_SET" == "0" ]]; then
    for port in 7890 7897 7898 1080 1087 8080; do
        if nc -z -w1 127.0.0.1 $port 2>/dev/null; then
            export HTTPS_PROXY="http://127.0.0.1:$port"
            export HTTP_PROXY="http://127.0.0.1:$port"
            export ALL_PROXY="http://127.0.0.1:$port"
            ok "found proxy on port $port, auto-configured."
            PROXY_SET=1
            break
        fi
    done
fi

if [[ "$PROXY_SET" == "0" ]]; then
    info "未检测到本地代理，使用直连。"
    info "如果下载失败，请先开启 VPN/代理工具。"
fi

# 跳过 brew 自动更新（用镜像源时更新反而慢）
export HOMEBREW_NO_AUTO_UPDATE=1

# ============================================================
# 第1步：安装 Homebrew
# ============================================================
echo ""
echo "  ========================================"
echo "  [1/5] 检查 Homebrew..."
echo "  ========================================"

if command -v brew &>/dev/null; then
    ok "Homebrew 已安装，跳过。"
else
    info "正在安装 Homebrew...（可能需要输入电脑密码，输入时不会显示，输完回车即可）"
    export HOMEBREW_INSTALL_FROM_API=1
    export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
    export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
    export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
    export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
    /bin/bash -c "$(curl -fsSL https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/install/HEAD/install.sh)" || \
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    fi
    ok "Homebrew 安装完成。"
fi

# ============================================================
# 第2步：检查 Python 3.11+
# ============================================================
echo ""
echo "  ========================================"
echo "  [2/5] 检查 Python..."
echo "  ========================================"

PYTHON_OK=0
if command -v python3 &>/dev/null; then
    PY_VER=$(python3 --version 2>&1 | grep -oE '[0-9]+\.[0-9]+')
    PY_MAJOR=$(echo "$PY_VER" | cut -d. -f1)
    PY_MINOR=$(echo "$PY_VER" | cut -d. -f2)
    if [[ "$PY_MAJOR" -ge 3 && "$PY_MINOR" -ge 11 ]]; then
        ok "Python 已安装（$PY_VER），满足要求。"
        PYTHON_OK=1
    else
        info "Python 版本过低（$PY_VER），需要 3.11+，正在升级..."
    fi
else
    info "未检测到 Python 3，正在安装..."
fi

if [[ "$PYTHON_OK" == "0" ]]; then
    PYTHON_INSTALLED=0
    # 方式1：brew 安装
    if command -v brew &>/dev/null; then
        info "通过 brew 安装 Python 3.11..."
        export HOMEBREW_NO_AUTO_UPDATE=1
        brew install python@3.11 2>&1 | tail -3
        if [[ -f "/opt/homebrew/bin/python3.11" ]]; then
            export PATH="/opt/homebrew/bin:$PATH"
            PYTHON_INSTALLED=1
        fi
    fi
    # 方式2：本地 .pkg 安装
    if [[ "$PYTHON_INSTALLED" == "0" ]]; then
        LOCAL_PYTHON_PKG="$PACK_DIR/installers/python-3.11-macos.pkg"
        if [[ -f "$LOCAL_PYTHON_PKG" ]]; then
            info "brew 安装失败，使用本地安装包...（可能需要输入电脑密码）"
            sudo installer -pkg "$LOCAL_PYTHON_PKG" -target / 2>/dev/null
            # Python 安装后路径
            if [[ -f "/Library/Frameworks/Python.framework/Versions/3.11/bin/python3.11" ]]; then
                export PATH="/Library/Frameworks/Python.framework/Versions/3.11/bin:$PATH"
                PYTHON_INSTALLED=1
            elif [[ -f "/usr/local/bin/python3.11" ]]; then
                export PATH="/usr/local/bin:$PATH"
                PYTHON_INSTALLED=1
            fi
        fi
    fi
    if [[ "$PYTHON_INSTALLED" == "1" ]]; then
        PY_VER=$(python3 --version 2>&1 | grep -oE '[0-9]+\.[0-9]+')
        ok "Python 安装完成（$PY_VER）。"
    else
        fail "Python 安装失败，请手动安装 Python 3.11+。"
        fail "下载地址: https://www.python.org/downloads/"
        exit 1
    fi
fi

# ============================================================
# 第3步：安装 Hermes Agent
# ============================================================
echo ""
echo "  ========================================"
echo "  [3/5] 检查 Hermes Agent..."
echo "  ========================================"

HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
HERMES_REPO="$HERMES_HOME/hermes-agent"

if [[ -d "$HERMES_REPO" && -f "$HERMES_REPO/venv/bin/hermes" ]]; then
    ok "Hermes Agent 已安装，跳过。"
    HERMES_VER=$("$HERMES_REPO/venv/bin/hermes" --version 2>&1 | head -1)
    ok "版本: $HERMES_VER"
else
    info "正在安装 Hermes Agent..."

    # 确保 git 可用（pip install -e 需要 .git）
    if ! command -v git &>/dev/null; then
        info "正在安装 git..."
        brew install git
    fi

    mkdir -p "$HERMES_HOME"

    # 优先使用本地离线包
    LOCAL_HERMES_TAR="$PACK_DIR/installers/hermes-agent.tar.gz"
    if [[ -f "$LOCAL_HERMES_TAR" ]]; then
        info "正在从本地离线包解压 hermes-agent..."
        tar -xzf "$LOCAL_HERMES_TAR" -C "$HERMES_HOME/"
        # 初始化 git 仓库（pip install -e 需要）
        cd "$HERMES_REPO" && git init -q && git add -A && git commit -q -m "init" 2>/dev/null; cd -
        ok "hermes-agent 离线解压完成。"
    else
        # 兜底：在线克隆
        if [[ -d "$HERMES_REPO/.git" ]]; then
            info "hermes-agent 目录已存在但未安装，继续..."
        else
            info "正在克隆 hermes-agent 仓库..."
            git clone https://github.com/NousResearch/hermes-agent.git "$HERMES_REPO"
        fi
    fi

    # 创建 venv 并安装（必须用 Python 3.11+）
    PYTHON311=""
    for p in /opt/homebrew/bin/python3.11 /usr/local/bin/python3.11 /opt/homebrew/bin/python3.12 /usr/local/bin/python3.12 "$(command -v python3.11 2>/dev/null)" "$(command -v python3.12 2>/dev/null)"; do
        if [[ -n "$p" && -x "$p" ]]; then
            PYTHON311="$p"
            break
        fi
    done
    if [[ -z "$PYTHON311" ]]; then
        PYTHON311="$(command -v python3)"
        info "未找到 Python 3.11，使用系统 python3: $PYTHON311"
    fi
    info "正在创建 Python 虚拟环境（$PYTHON311）..."
    "$PYTHON311" -m venv "$HERMES_REPO/venv"

    # 升级 pip
    "$HERMES_REPO/venv/bin/pip" install --upgrade pip -q 2>/dev/null

    # 优先使用本地离线包安装依赖
    LOCAL_PYTHON_PKGS="$PACK_DIR/installers/python-packages"
    if [[ -d "$LOCAL_PYTHON_PKGS" && -f "$LOCAL_PYTHON_PKGS/requirements.txt" ]]; then
        info "正在从本地离线包安装 Python 依赖..."
        # 第一步：从本地 wheels 安装所有依赖
        "$HERMES_REPO/venv/bin/pip" install --no-index --find-links "$LOCAL_PYTHON_PKGS" -r "$LOCAL_PYTHON_PKGS/requirements.txt" -q 2>&1 | tail -3
        # 第二步：安装 hermes-agent（editable 模式，--no-index 阻止联网，--find-links 提供本地包）
        "$HERMES_REPO/venv/bin/pip" install --no-index --find-links "$LOCAL_PYTHON_PKGS" -e "$HERMES_REPO" -q 2>&1 | tail -3
        # 第三步：验证 hermes 命令可用
        if "$HERMES_REPO/venv/bin/hermes" --version &>/dev/null; then
            ok "Python 依赖离线安装完成。"
        else
            fail "hermes 命令不可用，尝试修复..."
            # 用非 editable 模式重试（更可靠的 entry point 创建）
            "$HERMES_REPO/venv/bin/pip" install --no-index --find-links "$LOCAL_PYTHON_PKGS" "$HERMES_REPO" -q 2>&1 | tail -3
        fi
    else
        info "正在在线安装 Hermes 依赖（可能需要几分钟）..."
        "$HERMES_REPO/venv/bin/pip" install -e "$HERMES_REPO" 2>&1 | tail -3
    fi

    # 创建 ~/.local/bin/hermes 包装脚本
    mkdir -p "$HOME/.local/bin"
    cat > "$HOME/.local/bin/hermes" << 'HERMES_WRAPPER'
#!/usr/bin/env bash
unset PYTHONPATH
unset PYTHONHOME
HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
exec "$HERMES_HOME/hermes-agent/venv/bin/hermes" "$@"
HERMES_WRAPPER
    chmod +x "$HOME/.local/bin/hermes"

    # 确保 ~/.local/bin 在 PATH 中
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        export PATH="$HOME/.local/bin:$PATH"
        # 写入 shell profile
        for profile in ~/.zshrc ~/.bash_profile ~/.bashrc; do
            if [[ -f "$profile" ]]; then
                if ! grep -q '.local/bin' "$profile" 2>/dev/null; then
                    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$profile"
                fi
                break
            fi
        done
    fi

    if "$HOME/.local/bin/hermes" --version &>/dev/null; then
        ok "Hermes Agent 安装完成。"
    else
        fail "Hermes 安装可能有问题，请检查输出。"
    fi
fi

# ============================================================
# 第4步：安装 CC-Switch（模型切换工具）
# ============================================================
echo ""
echo "  ========================================"
echo "  [4/6] 检查 CC-Switch..."
echo "  ========================================"

if [[ -d "/Applications/CC Switch.app" ]]; then
    ok "CC Switch 已安装，跳过。"
else
    CC_INSTALLED=0
    LOCAL_CC_DMG="$PACK_DIR/installers/CC-Switch.dmg"
    if [[ -f "$LOCAL_CC_DMG" ]]; then
        info "正在从本地安装包安装 CC Switch..."
        hdiutil attach "$LOCAL_CC_DMG" -quiet -nobrowse 2>/dev/null
        CC_MOUNT=$(ls -d "/Volumes/CC Switch"* /Volumes/CC-Switch* 2>/dev/null | head -1)
        if [[ -n "$CC_MOUNT" && -d "$CC_MOUNT/CC Switch.app" ]]; then
            cp -R "$CC_MOUNT/CC Switch.app" /Applications/ 2>/dev/null
            hdiutil detach "$CC_MOUNT" -quiet 2>/dev/null
        elif [[ -n "$CC_MOUNT" && -d "$CC_MOUNT/CC-Switch.app" ]]; then
            cp -R "$CC_MOUNT/CC-Switch.app" /Applications/ 2>/dev/null
            hdiutil detach "$CC_MOUNT" -quiet 2>/dev/null
        fi
        if [[ -d "/Applications/CC Switch.app" ]]; then
            ok "CC Switch 安装完成。"
            CC_INSTALLED=1
        else
            fail "CC Switch 安装失败，请手动安装。"
            hdiutil detach "/Volumes/CC Switch"* /Volumes/CC-Switch* -quiet 2>/dev/null
        fi
    else
        info "未找到 CC Switch 离线包，跳过。"
        info "请手动下载: https://github.com/farion1231/cc-switch/releases"
    fi
fi

info "安装完成后，请打开 CC-Switch 配置你的 API Key 和模型。"

# ============================================================
# 第5步：安装 Obsidian
# ============================================================
echo ""
echo "  ========================================"
echo "  [5/6] 检查 Obsidian..."
echo "  ========================================"

if [[ -d "/Applications/Obsidian.app" ]]; then
    ok "Obsidian 已安装，跳过。"
else
    OBSIDIAN_INSTALLED=0
    LOCAL_DMG=""
    if [[ -f "$PACK_DIR/installers/Obsidian-mac.dmg" ]]; then
        LOCAL_DMG="$PACK_DIR/installers/Obsidian-mac.dmg"
    elif [[ -f "$PACK_DIR/installers/Obsidian.dmg" ]]; then
        LOCAL_DMG="$PACK_DIR/installers/Obsidian.dmg"
    fi
    if [[ -n "$LOCAL_DMG" ]]; then
        info "正在从本地安装包安装 Obsidian..."
        hdiutil attach "$LOCAL_DMG" -quiet -nobrowse 2>/dev/null
        MOUNT_VOL=$(ls -d /Volumes/Obsidian* 2>/dev/null | head -1)
        if [[ -n "$MOUNT_VOL" && -d "$MOUNT_VOL/Obsidian.app" ]]; then
            cp -R "$MOUNT_VOL/Obsidian.app" /Applications/ 2>/dev/null
            hdiutil detach "$MOUNT_VOL" -quiet 2>/dev/null
        fi
        if [[ -d "/Applications/Obsidian.app" ]]; then
            ok "Obsidian 安装完成（本地安装包）。"
            OBSIDIAN_INSTALLED=1
        else
            fail "本地 .dmg 安装失败，尝试在线安装..."
            hdiutil detach /Volumes/Obsidian* -quiet 2>/dev/null
        fi
    fi
    if [[ "$OBSIDIAN_INSTALLED" == "0" ]]; then
        if command -v brew &>/dev/null; then
            info "正在通过 brew 在线安装 Obsidian..."
            brew install --cask obsidian
            if [[ -d "/Applications/Obsidian.app" ]]; then
                ok "Obsidian 安装完成（在线安装）。"
            else
                fail "Obsidian 安装失败，请手动下载: https://obsidian.md"
            fi
        else
            fail "Obsidian 安装失败（无本地包且 brew 不可用），请手动下载: https://obsidian.md"
        fi
    fi
fi

# ============================================================
# 第5步：安装 Claudian 插件 + 配置
# ============================================================
echo ""
echo "  ========================================"
echo "  [6/6] 安装 Claudian 插件..."
echo "  ========================================"

# 选择知识库路径
echo ""
echo "  请选择知识库安装位置："
echo "    [1] ~/ObsidianVaults/我的知识库（推荐）"
echo "    [2] 自定义路径"
echo ""
read -p "  输入数字（默认1）：" VAULT_CHOICE
VAULT_CHOICE=${VAULT_CHOICE:-1}

if [[ "$VAULT_CHOICE" == "1" ]]; then
    VAULT_DIR="$HOME/ObsidianVaults/我的知识库"
else
    read -p "  请输入完整路径：" VAULT_DIR
fi
VAULT_DIR=${VAULT_DIR:-"$HOME/ObsidianVaults/我的知识库"}

echo ""
info "知识库位置：$VAULT_DIR"

# 创建目录
mkdir -p "$VAULT_DIR/.obsidian/plugins"
PLUGINS_DIR="$VAULT_DIR/.obsidian/plugins"
SRC_PLUGINS="$PACK_DIR/plugins"

if [[ ! -d "$SRC_PLUGINS/realclaudian" ]]; then
    fail "找不到插件文件夹：$SRC_PLUGINS/realclaudian"
    fail "请确保 plugins 文件夹和本脚本在同一目录下。"
    exit 1
fi

# 复制插件
info "安装插件：realclaudian"
cp -R "$SRC_PLUGINS/realclaudian" "$PLUGINS_DIR/"
ok "realclaudian 已安装。"

# 修复 run-hermes 权限
chmod +x "$PLUGINS_DIR/realclaudian/run-hermes"
ok "run-hermes 执行权限已设置。"

# 导入 vault 模板
SRC_VAULT="$PACK_DIR/vault"
if [[ -d "$SRC_VAULT" ]]; then
    info "正在导入知识库模板..."
    for item in "$SRC_VAULT"/*; do
        if [[ -e "$item" ]]; then
            basename=$(basename "$item")
            if [[ "$basename" != ".obsidian" ]]; then
                cp -R "$item" "$VAULT_DIR/"
            fi
        fi
    done
    ok "知识库模板导入完成。"
fi

# ============================================================
# 第5.5步：配置 Claudian 插件
# ============================================================
echo ""
echo "  ========================================"
echo "  [5.5] 自动配置 Claudian 插件..."
echo "  ========================================"

# 确保 .claudian 目录存在
mkdir -p "$VAULT_DIR/.claudian"

CLAUDIAN_SETTINGS="$VAULT_DIR/.claudian/claudian-settings.json"
RUN_HERMES_PATH="$PLUGINS_DIR/realclaudian/run-hermes"

# 写入 claudian-settings.json
info "写入 Claudian 配置..."
python3 << PYEOF
import json, os

settings_path = '$CLAUDIAN_SETTINGS'
run_hermes = '$RUN_HERMES_PATH'
hermes_home = '$HERMES_HOME'

# 如果已有配置，合并；否则创建新配置
if os.path.exists(settings_path):
    with open(settings_path, 'r') as f:
        settings = json.load(f)
else:
    settings = {}

# 基础设置
settings.setdefault('userName', '')
settings.setdefault('permissionMode', 'yolo')
settings.setdefault('model', 'hermes')
settings.setdefault('locale', 'zh-CN')
settings['settingsProvider'] = 'hermes'

# providerConfigs
if 'providerConfigs' not in settings:
    settings['providerConfigs'] = {}

# Hermes provider 配置
settings['providerConfigs']['hermes'] = {
    'cliPath': run_hermes,
    'cliPathsByHost': {},
    'enabled': True,
    'environmentHash': '',
    'environmentVariables': f'HERMES_HOME={hermes_home}'
}

# savedProviderModel
if 'savedProviderModel' not in settings:
    settings['savedProviderModel'] = {}
settings['savedProviderModel']['hermes'] = 'hermes'

with open(settings_path, 'w') as f:
    json.dump(settings, f, indent=2, ensure_ascii=False)

print('  done')
PYEOF

ok "Claudian 配置已写入: $CLAUDIAN_SETTINGS"

# 写入 data.json（环境变量）
DATA_JSON="$PLUGINS_DIR/realclaudian/data.json"
python3 << PYEOF
import json, os

data_path = '$DATA_JSON'
hermes_home = '$HERMES_HOME'

data = {}
if os.path.exists(data_path):
    try:
        with open(data_path, 'r') as f:
            data = json.load(f)
    except:
        data = {}

data['environmentVariables'] = [
    {'name': 'HERMES_HOME', 'value': hermes_home}
]

with open(data_path, 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
PYEOF

ok "插件环境变量已配置。"

# ============================================================
# 完成
# ============================================================
echo ""
echo "  ╔═══════════════════════════════════════════════╗"
echo "  ║              ✅ 安装全部完成！                ║"
echo "  ╚═══════════════════════════════════════════════╝"
echo ""
echo "  ****************************************************"
echo "  *  YOUR VAULT PATH:"
echo "  *  $VAULT_DIR"
echo "  *"
echo "  *  IMPORTANT: Open THIS folder in Obsidian."
echo "  ****************************************************"
echo ""
echo "  接下来只需 3 步（手动）："
echo ""
echo "    1. 打开 CC-Switch → 配置 API Key 和模型"
echo "    2. 打开 Obsidian → 选择上面星号框里的知识库路径"
echo "    3. 设置 → 第三方插件 → 关闭安全模式 → 启用 Claudian 插件"
echo ""
echo "  API Key 和模型切换请通过 CC-Switch 管理。"
echo ""

# 自动打开 CC Switch
if [[ -d "/Applications/CC Switch.app" ]]; then
    info "正在打开 CC Switch..."
    open "/Applications/CC Switch.app"
fi
echo "  如果遇到问题，请检查以上文件或联系技术支持。"
echo ""
