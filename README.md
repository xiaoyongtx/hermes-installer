# Hermes 一键安装包

Mac 和 Windows 版的一键安装包，包含 Hermes Agent、Obsidian、Claudian 插件和 CC-Switch。

## 功能特性

- ✅ 一键安装，无需手动配置
- ✅ 离线安装包，无需联网下载（Python 依赖除外）
- ✅ 预置 7 个实用技能
- ✅ 支持 Mac 和 Windows 系统

## 安装说明

### Mac 版

1. 进入 `【Mac专用】一键安装-Hermes版` 文件夹
2. 双击 `【Mac专用】一键安装-Hermes版.command`
3. 按照提示完成安装
4. 打开 CC-Switch 配置 API Key
5. 打开 Obsidian 选择知识库路径

### Windows 版

1. 进入 `【Windows专用】一键安装-Hermes版` 文件夹
2. 双击 `【Windows双击我】一键安装-Hermes版.bat`
3. 按照提示完成安装
4. 打开 CC-Switch 配置 API Key
5. 打开 Obsidian 选择知识库路径

## 目录结构

```
hermes-installer/
├── README.md
├── 【Mac专用】一键安装-Hermes版/
│   ├── installers/              # 离线安装包
│   │   ├── hermes-agent.tar.gz  # Hermes Agent 源码
│   │   ├── Obsidian-mac.dmg     # Obsidian 安装包
│   │   ├── CC-Switch.dmg        # CC-Switch 安装包
│   │   └── python-packages/     # Python 依赖包
│   ├── plugins/                 # Obsidian 插件
│   │   └── realclaudian/        # Claudian 插件
│   ├── skills/                  # 预置技能
│   │   ├── ai-board-advisory/
│   │   ├── coze-image-gen/
│   │   ├── coze-workflow/
│   │   ├── news-aggregator-skill/
│   │   ├── obsidian-skills-main/
│   │   ├── personal-ip-materials-generator/
│   │   └── safe-svg-cjk/
│   ├── vault/                   # 知识库模板
│   ├── 【Mac专用】一键安装-Hermes版.command
│   └── 【必读】安装说明.md
└── 【Windows专用】一键安装-Hermes版/
    ├── installers/              # 离线安装包
    ├── plugins/                 # Obsidian 插件
    ├── vault/                   # 知识库模板
    ├── 【Windows双击我】一键安装-Hermes版.bat
    └── 【必读】安装说明.md
```

## 预置技能

安装包包含以下 7 个预置技能：

| 技能 | 说明 |
|------|------|
| `ai-board-advisory` | AI 私董会 |
| `coze-image-gen` | Coze 图像生成 |
| `coze-workflow` | Coze 工作流 |
| `news-aggregator-skill` | 新闻聚合 |
| `obsidian-skills-main` | Obsidian 技能集 |
| `personal-ip-materials-generator` | 个人 IP 素材生成 |
| `safe-svg-cjk` | SVG CJK 安全处理 |

技能安装路径：`~/.hermes/skills/`

## 安装组件

| 组件 | 说明 |
|------|------|
| Homebrew | macOS 包管理器（已有则跳过） |
| Python 3.11+ | Hermes 运行环境 |
| Hermes Agent | AI agent |
| CC-Switch | 模型切换工具 |
| Obsidian | 知识库主程序 |
| Claudian 插件 | Obsidian 中的 AI 对话窗口 |

## 常见问题

### Q: DeepSeek 模型 401 错误？

如果使用 DeepSeek 模型，需要将配置文件中的 `name` 改为不与内置冲突的名称：

```yaml
# ~/.hermes/config.yaml
custom_providers:
- name: deepseek-custom  # 避免与内置 deepseek 冲突
  base_url: https://api.deepseek.com/
  api_key: your-api-key
  api_mode: anthropic_messages
```

## 技术支持

微信找 小勇同学（751825267）

---

*版本：v1.0 | 2026年6月*
