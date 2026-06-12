# Claudian 插件（installer 分发版）

本目录包含 Claudian 插件的预构建文件，供 Hermes 一键安装包使用。

## 文件说明

| 文件 | 说明 |
|------|------|
| `main.js` | 插件主入口（编译后） |
| `manifest.json` | 插件元数据（id、版本、兼容性） |
| `styles.css` | 插件样式 |

## 插件信息

- **名称**: Claudian
- **版本**: 2.0.19
- **作者**: Yishen Tu
- **仓库**: [github.com/YishenTu/claudian](https://github.com/YishenTu/claudian)
- **许可证**: MIT

## 功能简介

Claudian 是一个 Obsidian 插件，将 AI 编程助手（Claude Code、Codex、Opencode、Pi 等）嵌入到你的知识库中。知识库即工作目录——文件读写、搜索、命令行和多步骤工作流开箱即用。

主要特性：
- **侧边栏对话** — 与 AI agent 实时对话
- **行内编辑** — 选中文本 + 快捷键直接编辑，支持词级 diff 预览
- **斜杠命令 & 技能** — 可复用的提示模板
- **`@mention`** — 引用文件、子代理、MCP 服务器
- **计划模式** — `Shift+Tab` 切换，先探索再实施

## 安装说明

此目录由安装脚本自动复制到 Obsidian 插件目录：

```
{vault}/.obsidian/plugins/claudian/
```

无需手动操作。

## 更新方式

1. 从 [GitHub Releases](https://github.com/YishenTu/claudian/releases/latest) 下载最新版本的 `main.js`、`manifest.json`、`styles.css`
2. 替换本目录中的对应文件
3. 重新运行安装脚本，或手动复制到 Obsidian 插件目录

## 相关链接

- [Claudian 完整文档](https://github.com/YishenTu/claudian#readme)
- [问题反馈](https://github.com/YishenTu/claudian/issues)
