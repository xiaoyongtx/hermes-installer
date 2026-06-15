#!/bin/bash
# ============================================================
# Hermes + Obsidian + Claudian 一键安装脚本(Mac版)v2.0.19
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

# 检测系统架构
ARCH="$(uname -m)"
if [[ "$ARCH" == "arm64" ]]; then
    HOMEBREW_PREFIX="/opt/homebrew"
    ARCH_NAME="arm64"
else
    HOMEBREW_PREFIX="/usr/local"
    ARCH_NAME="x86_64"
fi
info "检测到架构: $ARCH_NAME"

echo ""
echo "  ╔═══════════════════════════════════════════════════╗"
echo "  ║  Hermes + Obsidian + Claudian + CC-Switch 一键安装  ║"
echo "  ╚═══════════════════════════════════════════════════╝"
echo ""
echo "  本脚本将自动安装以下组件："
echo "    [1] Homebrew(包管理器，已有则跳过)"
echo "    [2] Python 3.11+(Hermes 运行环境)"
echo "    [3] Hermes Agent(AI 代理)"
echo "    [4] CC-Switch(模型切换工具)"
echo "    [5] Obsidian(知识库主程序)"
echo "    [6] Claudian 插件(含 Hermes 集成)"
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

# 跳过 brew 自动更新(用镜像源时更新反而慢)
export HOMEBREW_NO_AUTO_UPDATE=1

# ============================================================
# 第1步：安装 Homebrew
# ============================================================
echo ""
echo "  ========================================"
echo "  [1/6] 检查 Homebrew..."
echo "  ========================================"

if command -v brew &>/dev/null; then
    ok "Homebrew 已安装，跳过。"
else
    info "正在安装 Homebrew...(可能需要输入电脑密码，输入时不会显示，输完回车即可)"
    # 中科大镜像源
    export HOMEBREW_INSTALL_FROM_API=1
    export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.ustc.edu.cn/brew.git"
    export HOMEBREW_API_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles/api"
    export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles"
    BREW_INSTALL_OK=0

    # 策略1：本地离线脚本 + 镜像环境变量
    LOCAL_BREW_INSTALL="$PACK_DIR/installers/homebrew-install.sh"
    if [[ -f "$LOCAL_BREW_INSTALL" ]]; then
        info "使用本地离线安装脚本..."
        /bin/bash "$LOCAL_BREW_INSTALL" && BREW_INSTALL_OK=1
    fi

    # 策略2：通过 Gitee 镜像下载安装脚本(仅拉脚本，brew 本体仍走镜像环境变量)
    if [[ "$BREW_INSTALL_OK" == "0" ]]; then
        info "通过 Gitee 镜像下载安装脚本..."
        /bin/bash -c "$(curl -fsSL https://gitee.com/ineo6/homebrew-install/raw/master/install.sh)" && BREW_INSTALL_OK=1
    fi

    # 策略3：直连 GitHub(最后尝试)
    if [[ "$BREW_INSTALL_OK" == "0" ]]; then
        info "尝试直连 GitHub..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && BREW_INSTALL_OK=1
    fi

    if [[ -f "$HOMEBREW_PREFIX/bin/brew" ]]; then
        eval "$("$HOMEBREW_PREFIX/bin/brew" shellenv)"
        echo "eval \"\$($HOMEBREW_PREFIX/bin/brew shellenv)\"" >> ~/.zprofile
        # 持久化中科大镜像配置
        cat >> ~/.zprofile << 'BREW_MIRROR_EOF'

# Homebrew 中科大镜像
export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.ustc.edu.cn/brew.git"
export HOMEBREW_API_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles/api"
export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles"
BREW_MIRROR_EOF
    fi
    if [[ "$BREW_INSTALL_OK" == "1" ]] || command -v brew &>/dev/null; then
        ok "Homebrew 安装完成。"
    else
        fail "Homebrew 安装失败，请先手动安装 Homebrew："
        fail "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        fail "  或访问官方文档: https://brew.sh/zh-cn/"
        exit 1
    fi
fi

# ============================================================
# 第2步：检查 Python 3.11+
# ============================================================
echo ""
echo "  ========================================"
echo "  [2/6] 检查 Python..."
echo "  ========================================"

PYTHON_OK=0
if command -v python3 &>/dev/null; then
    PY_VER=$(python3 --version 2>&1 | grep -oE '[0-9]+\.[0-9]+')
    PY_MAJOR=$(echo "$PY_VER" | cut -d. -f1)
    PY_MINOR=$(echo "$PY_VER" | cut -d. -f2)
    if [[ "$PY_MAJOR" -gt 3 ]] || [[ "$PY_MAJOR" -eq 3 && "$PY_MINOR" -ge 11 ]]; then
        ok "Python 已安装($PY_VER)，满足要求。"
        PYTHON_OK=1
    else
        info "Python 版本过低($PY_VER)，需要 3.11+，正在升级..."
    fi
else
    info "未检测到 Python 3，正在安装..."
fi

if [[ "$PYTHON_OK" == "0" ]]; then
    if command -v brew &>/dev/null; then
        info "通过 brew 安装 Python 3.11..."
        brew install python@3.11 2>&1 | tail -3
        if [[ -f "$HOMEBREW_PREFIX/bin/python3.11" ]]; then
            export PATH="$HOMEBREW_PREFIX/bin:$PATH"
        fi
        # 验证安装结果
        if python3 --version &>/dev/null; then
            PY_VER=$(python3 --version 2>&1 | grep -oE '[0-9]+\.[0-9]+')
            ok "Python 安装完成($PY_VER)。"
        else
            fail "Python 安装失败，请手动安装："
            fail "  brew install python@3.11"
            exit 1
        fi
    else
        fail "brew 不可用，无法安装 Python。"
        fail "请先安装 Homebrew，再运行 brew install python@3.11"
        exit 1
    fi
fi

# 保存验证过的 Python 路径，供后续步骤复用
PYTHON_BIN="$(command -v python3)"
info "使用 Python: $PYTHON_BIN"

# ============================================================
# 第3步：安装 Hermes Agent
# ============================================================
echo ""
echo "  ========================================"
echo "  [3/6] 检查 Hermes Agent..."
echo "  ========================================"

HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
HERMES_REPO="$HERMES_HOME/hermes-agent"

if [[ -d "$HERMES_REPO" && -f "$HERMES_REPO/venv/bin/hermes" ]]; then
    ok "Hermes Agent 已安装。"
    HERMES_VER=$("$HERMES_REPO/venv/bin/hermes" --version 2>&1 | head -1)
    ok "版本: $HERMES_VER"

    # 检测并升级 [acp] extras(新版 Claudian 插件依赖 acp 模块)
    PIP_MIRROR="https://mirrors.ustc.edu.cn/pypi/web/simple"
    REQUIRES=$("$HERMES_REPO/venv/bin/pip" show hermes-agent 2>/dev/null | grep -i "^Requires:" || true)
    if [[ "$REQUIRES" != *"acp"* ]]; then
        info "正在升级 Hermes [acp] 依赖..."
        if "$HERMES_REPO/venv/bin/pip" install -i "$PIP_MIRROR" -e "$HERMES_REPO[acp]" -q; then
            ok "Hermes [acp] 依赖已升级。"
        else
            fail "升级 [acp] 依赖失败，可稍后手动执行：pip install -e $HERMES_REPO[acp]"
        fi
    fi

    # 确保 ~/.local/bin/hermes 包装脚本存在且指向正确
    HERMES_WRAPPER="$HOME/.local/bin/hermes"
    if [[ ! -f "$HERMES_WRAPPER" ]] || ! grep -q "hermes-agent/venv/bin/hermes" "$HERMES_WRAPPER" 2>/dev/null; then
        info "正在更新 hermes 包装脚本..."
        mkdir -p "$HOME/.local/bin"
        cat > "$HERMES_WRAPPER" << EOF
#!/usr/bin/env bash
unset PYTHONPATH
unset PYTHONHOME
HERMES_HOME="\${HERMES_HOME:-\$HOME/.hermes}"
exec "\$HERMES_HOME/hermes-agent/venv/bin/hermes" "\$@"
EOF
        chmod +x "$HERMES_WRAPPER"
        ok "hermes 包装脚本已更新。"
    fi
else
    info "正在安装 Hermes Agent..."

    # 确保 git 可用(pip install -e 需要 .git)
    if ! command -v git &>/dev/null; then
        info "正在安装 git..."
        brew install git
    fi

    mkdir -p "$HERMES_HOME"

    # 优先使用本地离线包
    LOCAL_HERMES_TAR="$PACK_DIR/installers/hermes-agent.tar.gz"
    if [[ -f "$LOCAL_HERMES_TAR" ]]; then
        info "正在从本地离线包解压 hermes-agent..."
        if tar -xzf "$LOCAL_HERMES_TAR" -C "$HERMES_HOME/"; then
            # 初始化 git 仓库(pip install -e 需要)
            (cd "$HERMES_REPO" && git init -q && git add -A && git commit -q -m "init") 2>/dev/null
            ok "hermes-agent 离线解压完成。"
        else
            fail "hermes-agent 解压失败，请检查安装包是否完整。"
            exit 1
        fi
    else
        # 兜底：在线克隆
        if [[ -d "$HERMES_REPO/.git" ]]; then
            info "hermes-agent 目录已存在但未安装，继续..."
        else
            info "正在克隆 hermes-agent 仓库..."
            if ! git clone https://github.com/NousResearch/hermes-agent.git "$HERMES_REPO"; then
                fail "hermes-agent 克隆失败，请检查网络连接。"
                exit 1
            fi
        fi
    fi

    # 创建 venv 并安装(必须用 Python 3.11+)
    PYTHON311=""
    for p in "$HOMEBREW_PREFIX/bin/python3.11" "$HOMEBREW_PREFIX/bin/python3.12" "$(command -v python3.11 2>/dev/null)" "$(command -v python3.12 2>/dev/null)"; do
        if [[ -n "$p" && -x "$p" ]]; then
            PYTHON311="$p"
            break
        fi
    done
    if [[ -z "$PYTHON311" ]]; then
        PYTHON311="$(command -v python3)"
        info "未找到 Python 3.11，使用系统 python3: $PYTHON311"
    fi
    info "正在创建 Python 虚拟环境($PYTHON311)..."
    "$PYTHON311" -m venv "$HERMES_REPO/venv"

    # 升级 pip 并配置中科大镜像源(仅影响本脚本环境，不修改全局配置)
    info "正在升级 pip..."
    "$HERMES_REPO/venv/bin/pip" install --upgrade pip -q 2>/dev/null
    PIP_MIRROR="https://mirrors.ustc.edu.cn/pypi/web/simple"

    # arm64 使用离线包，x86_64 走在线安装
    LOCAL_PYTHON_PKGS="$PACK_DIR/installers/python-packages-arm64"
    if [[ "$ARCH_NAME" == "arm64" && -d "$LOCAL_PYTHON_PKGS" && -f "$LOCAL_PYTHON_PKGS/requirements.txt" ]]; then
        info "正在从本地离线包安装 Python 依赖..."
        # 第一步：从本地 wheels 安装所有依赖
        "$HERMES_REPO/venv/bin/pip" install --no-index --find-links "$LOCAL_PYTHON_PKGS" -r "$LOCAL_PYTHON_PKGS/requirements.txt" -q
        # 第二步：安装 hermes-agent(editable 模式)
        "$HERMES_REPO/venv/bin/pip" install --no-index --find-links "$LOCAL_PYTHON_PKGS" -e "$HERMES_REPO" -q
        # 第三步：验证 hermes 命令可用
        if "$HERMES_REPO/venv/bin/hermes" --version &>/dev/null; then
            ok "Python 依赖离线安装完成。"
        else
            fail "hermes 命令不可用，尝试修复..."
            "$HERMES_REPO/venv/bin/pip" install --no-index --find-links "$LOCAL_PYTHON_PKGS" "$HERMES_REPO" -q
        fi
    else
        info "正在在线安装 Hermes 依赖(可能需要几分钟)..."
        "$HERMES_REPO/venv/bin/pip" install -i "$PIP_MIRROR" -e "$HERMES_REPO[acp]"
    fi

    # 创建 ~/.local/bin/hermes 包装脚本
    mkdir -p "$HOME/.local/bin"
    cat > "$HOME/.local/bin/hermes" << EOF
#!/usr/bin/env bash
unset PYTHONPATH
unset PYTHONHOME
HERMES_HOME="\${HERMES_HOME:-\$HOME/.hermes}"
exec "\$HERMES_HOME/hermes-agent/venv/bin/hermes" "\$@"
EOF
    chmod +x "$HOME/.local/bin/hermes"

    # 确保 ~/.local/bin 在 PATH 中
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        export PATH="$HOME/.local/bin:$PATH"
        # 写入 shell profile：优先当前 shell 的配置文件
        case "$(basename "$SHELL")" in
            zsh)  PROFILE_TARGET="$HOME/.zshrc" ;;
            bash) PROFILE_TARGET="$([[ -f "$HOME/.bash_profile" ]] && echo "$HOME/.bash_profile" || echo "$HOME/.bashrc")" ;;
            fish) PROFILE_TARGET="$HOME/.config/fish/config.fish" ;;
            *)    PROFILE_TARGET="$HOME/.profile" ;;
        esac
        # 确保父目录存在
        mkdir -p "$(dirname "$PROFILE_TARGET")" 2>/dev/null
        if ! grep -q '.local/bin' "$PROFILE_TARGET" 2>/dev/null; then
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$PROFILE_TARGET"
            info "已将 PATH 写入: $PROFILE_TARGET"
        fi
    fi

    if "$HOME/.local/bin/hermes" --version &>/dev/null; then
        ok "Hermes Agent 安装完成。"
    else
        fail "Hermes 安装可能有问题，请检查输出。"
    fi
fi

# ============================================================
# 第3.5步：安装预置技能
# ============================================================
echo ""
echo "  ========================================"
echo "  [3.5/6] 安装预置技能..."
echo "  ========================================"

HERMES_SKILLS_DIR="${HERMES_HOME:-$HOME/.hermes}/skills"
SRC_SKILLS="$PACK_DIR/skills"

if [[ -d "$SRC_SKILLS" ]]; then
    mkdir -p "$HERMES_SKILLS_DIR"
    info "正在安装预置技能到 $HERMES_SKILLS_DIR ..."

    # 遍历 skills 目录下的每个技能文件夹
    for skill_dir in "$SRC_SKILLS"/*/; do
        if [[ -d "$skill_dir" ]]; then
            skill_name=$(basename "$skill_dir")
            # 跳过隐藏文件(如 .DS_Store)
            if [[ "$skill_name" == .* ]]; then
                continue
            fi
            # 复制技能(-rn 不覆盖已存在的文件)
            cp -rn "${skill_dir%/}" "$HERMES_SKILLS_DIR/" 2>/dev/null || true
            ok "技能已安装: $skill_name"
        fi
    done

    ok "预置技能安装完成。"
else
    info "未找到预置技能文件夹，跳过。"
fi

# ============================================================
# 第4步：安装 CC-Switch(模型切换工具)
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
        # 通过 hdiutil attach 输出解析实际挂载点，避免通配符匹配缺陷
        CC_MOUNT=$(hdiutil attach "$LOCAL_CC_DMG" -nobrowse 2>/dev/null | tail -1 | awk -F'\t' '{print $NF}')
        if [[ -n "$CC_MOUNT" && -d "$CC_MOUNT" ]]; then
            # 在挂载卷中查找 .app(兼容不同的 .app 命名)
            CC_APP=$(find "$CC_MOUNT" -maxdepth 2 -name "*.app" -type d 2>/dev/null | head -1)
            if [[ -n "$CC_APP" ]]; then
                if cp -R "$CC_APP" /Applications/ 2>/dev/null; then
                    ok "CC Switch 安装完成。"
                    CC_INSTALLED=1
                else
                    fail "CC Switch 复制失败，可能需要管理员权限。"
                fi
            else
                fail "在 DMG 中未找到 CC Switch .app。"
            fi
            hdiutil detach "$CC_MOUNT" -quiet 2>/dev/null
        else
            fail "DMG 挂载失败，请手动安装。"
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
        # 通过 hdiutil attach 输出解析实际挂载点
        MOUNT_VOL=$(hdiutil attach "$LOCAL_DMG" -nobrowse 2>/dev/null | tail -1 | awk -F'\t' '{print $NF}')
        if [[ -n "$MOUNT_VOL" && -d "$MOUNT_VOL" ]]; then
            OBS_APP=$(find "$MOUNT_VOL" -maxdepth 2 -name "Obsidian.app" -type d 2>/dev/null | head -1)
            if [[ -n "$OBS_APP" ]]; then
                cp -R "$OBS_APP" /Applications/ 2>/dev/null
            fi
            hdiutil detach "$MOUNT_VOL" -quiet 2>/dev/null
        fi
        if [[ -d "/Applications/Obsidian.app" ]]; then
            ok "Obsidian 安装完成(本地安装包)。"
            OBSIDIAN_INSTALLED=1
        else
            fail "本地 .dmg 安装失败，尝试在线安装..."
        fi
    fi
    if [[ "$OBSIDIAN_INSTALLED" == "0" ]]; then
        if command -v brew &>/dev/null; then
            info "正在通过 brew 在线安装 Obsidian..."
            brew install --cask obsidian
            if [[ -d "/Applications/Obsidian.app" ]]; then
                ok "Obsidian 安装完成(在线安装)。"
            else
                fail "Obsidian 安装失败，请手动下载: https://obsidian.md"
            fi
        else
            fail "Obsidian 安装失败(无本地包且 brew 不可用)，请手动下载: https://obsidian.md"
        fi
    fi
fi

# ============================================================
# 第6步：安装 Claudian 插件 + 配置
# ============================================================
echo ""
echo "  ========================================"
echo "  [6/6] 安装 Claudian 插件..."
echo "  ========================================"

# 选择知识库路径
echo ""
echo "  请选择知识库安装位置："
echo "    [1] ~/ObsidianVaults/我的知识库(推荐)"
echo "    [2] 自定义路径"
echo ""
read -p "  输入数字(默认1)：" VAULT_CHOICE
VAULT_CHOICE=${VAULT_CHOICE:-1}

if [[ "$VAULT_CHOICE" == "2" ]]; then
    while true; do
        read -p "  请输入完整路径：" VAULT_DIR
        # 展开路径中的 ~ 符号(read 不会自动展开)
        VAULT_DIR="${VAULT_DIR/#\~/$HOME}"
        if [[ "$VAULT_DIR" =~ ^/ ]]; then
            break
        fi
        fail "路径无效：$VAULT_DIR(必须以 / 或 ~ 开头)，请重新输入(Ctrl+C 退出)。"
    done
else
    VAULT_DIR="$HOME/ObsidianVaults/我的知识库"
fi

echo ""
info "知识库位置：$VAULT_DIR"

# 创建目录
mkdir -p "$VAULT_DIR/.obsidian/plugins"
PLUGINS_DIR="$VAULT_DIR/.obsidian/plugins"
SRC_PLUGINS="$PACK_DIR/plugins"

if [[ ! -d "$SRC_PLUGINS/claudian" ]]; then
    fail "找不到插件文件夹：$SRC_PLUGINS/claudian"
    fail "请确保 plugins 文件夹和本脚本在同一目录下。"
    exit 1
fi

# 复制插件(Obsidian 通过 manifest.json 中的 id 识别插件，目录名不影响)
info "安装插件：claudian (v2.0.19)"
cp -R "$SRC_PLUGINS/claudian" "$PLUGINS_DIR/realclaudian"
ok "claudian 已安装。"

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

# 配置 Claudian 插件
echo ""
info "自动配置 Claudian 插件..."

# 确保 .claudian 目录存在
mkdir -p "$VAULT_DIR/.claudian"

CLAUDIAN_SETTINGS="$VAULT_DIR/.claudian/claudian-settings.json"
HERMES_BIN_PATH="$HERMES_HOME/hermes-agent/venv/bin/hermes"

# 写入 claudian-settings.json
info "写入 Claudian 配置..."
"$PYTHON_BIN" << PYEOF
import json, os

settings_path = '$CLAUDIAN_SETTINGS'
hermes_bin = '$HERMES_BIN_PATH'
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

# Hermes provider 配置(直接指向 hermes 二进制，无需 run-hermes 包装脚本)
settings['providerConfigs']['hermes'] = {
    'cliPath': hermes_bin,
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
echo "  接下来只需 3 步(手动)："
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
