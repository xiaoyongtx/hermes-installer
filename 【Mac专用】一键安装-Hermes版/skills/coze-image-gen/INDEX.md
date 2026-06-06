# 📚 Coze Image Generation Skill - 文档导航

欢迎使用 Coze Image Generation Skill！本索引帮助你快速找到需要的信息。

---

## 🎯 我想...

### 快速开始（5分钟上手）
👉 [快速参考卡](QUICK_REFERENCE.md) - 打印版速查表
👉 [README_CN.md](README_CN.md) - 完整中文指南

### 了解这是什么
👉 [SKILL.md](SKILL.md) - 技能详细说明
👉 [UPDATE_SUMMARY.md](UPDATE_SUMMARY.md) - 更新内容和功能介绍

### 发现工作流参数
👉 [scripts/discover_params.py](scripts/discover_params.py) - 参数发现工具

**使用方法：**
```bash
python scripts/discover_params.py --token "TOKEN" --workflow-id "WF_ID"
```

### 使用预设模板
👉 [templates/image_templates.json](templates/image_templates.json) - 6大模板库

**包含模板：**
1. 思维导图海报
2. 吐槽批注表情包 ⭐
3. 专业海报设计
4. 艺术插画
5. 信息图表
6. 社交媒体配图

### 查看代码示例
👉 [examples/quick_start.py](examples/quick_start.py) - CozeImageGenerator 快捷类
👉 [examples/complete_examples.md](examples/complete_examples.md) - 6个完整实战案例

### 学习特定功能

#### 生成思维导图
- 参见：[complete_examples.md - 示例2](examples/complete_examples.md#示例-2-思维导图海报生成)
- 快捷方法：`generator.generate_mindmap(content)`

#### 制作吐槽表情包
- 参见：[complete_examples.md - 示例3](examples/complete_examples.md#示例-3-吐槽表情包批量生成)
- 快捷方法：`generator.generate_annotated_meme(scene, roast_comments)`
- 贴吧语录：[SKILL.md - 批注风格](SKILL.md#annotation-styles)

#### 设计专业海报
- 参见：[complete_examples.md - 示例4](examples/complete_examples.md#示例-4-专业海报设计)
- 快捷方法：`generator.generate_professional_poster(topic, style)`

#### 创作艺术插画
- 参见：[complete_examples.md - 示例5](examples/complete_examples.md#示例-5-艺术插画创作)
- 快捷方法：`generator.generate_artistic_illustration(subject, art_style)`

#### 批量处理任务
- 参见：[complete_examples.md - 批量处理最佳实践](examples/complete_examples.md#批量处理最佳实践)
- 包含：错误处理、结果保存、进度跟踪

### 解决常见问题
👉 [README_CN.md - 常见问题](README_CN.md#常见问题)
👉 [QUICK_REFERENCE.md - 问题速解](QUICK_REFERENCE.md#常见问题速解)

**常见问题：**
- ❓ 输出结果为 null → 检查参数名
- ❓ 命令行转义错误 → 使用 JSON 文件
- ❓ 图片质量不理想 → 优化提示词
- ❓ 工作流超时 → 使用异步模式

### 优化提示词
👉 [complete_examples.md - 提示词优化技巧](examples/complete_examples.md#提示词优化技巧)

**核心公式：**
```
详细场景描述 + 视觉风格要求 + 具体元素说明 + 氛围情绪定位
```

### 了解技术细节
👉 [SKILL.md - API Reference](SKILL.md#api-reference)
👉 [UPDATE_SUMMARY.md - 技术特点](UPDATE_SUMMARY.md#技术特点)

---

## 📖 阅读路径推荐

### 新手路径（从零开始）
1. 📘 阅读 [UPDATE_SUMMARY.md](UPDATE_SUMMARY.md) 了解功能
2. 🏃 跟随 [README_CN.md - 快速开始](README_CN.md#快速开始) 完成第一个示例
3. 🔍 使用 `discover_params.py` 发现你的工作流参数
4. 📝 选择一个 [模板](templates/image_templates.json) 开始创作
5. 💡 参考 [完整示例](examples/complete_examples.md) 深入学习

### 开发者路径（快速集成）
1. 📄 查看 [QUICK_REFERENCE.md](QUICK_REFERENCE.md) 速查 API
2. 🔧 使用 [CozeImageGenerator 类](examples/quick_start.py)
3. 📚 参考 [完整示例代码](examples/complete_examples.md)
4. 🎨 根据需要扩展模板系统

### 设计师路径（专注创作）
1. 🎯 直接查看 [模板库](templates/image_templates.json)
2. 💬 学习 [批注风格指南](SKILL.md#annotation-styles)
3. ✍️ 掌握 [提示词优化技巧](examples/complete_examples.md#提示词优化技巧)
4. 🔄 迭代优化获得理想效果

---

## 🗂️ 文件结构

```
.qoder/skills/coze-image-gen/
│
├── 📄 INDEX.md                          # 本文件 - 文档导航
├── 📄 SKILL.md                          # 技能主文档（英文）
├── 📄 README_CN.md                      # 中文使用指南 ⭐ 推荐新手
├── 📄 QUICK_REFERENCE.md                # 快速参考卡 ⭐ 推荐打印
├── 📄 UPDATE_SUMMARY.md                 # 更新总结和功能介绍
│
├── 📁 scripts/
│   └── 🐍 discover_params.py            # 参数发现工具 ⭐ 必备
│
├── 📁 templates/
│   └── 📋 image_templates.json          # 6大预设模板库 ⭐ 开箱即用
│
└── 📁 examples/
    ├── 🐍 quick_start.py                # CozeImageGenerator 快捷类
    └── 📄 complete_examples.md          # 6个完整实战案例 ⭐ 推荐学习
```

---

## 🎓 学习资源

### 基础概念
- **什么是 Coze Workflow？** → [SKILL.md - When to use](SKILL.md#when-to-use)
- **如何获取 Token？** → [README_CN.md - 准备工作](README_CN.md#1-准备工作)
- **参数是什么？** → [SKILL.md - Parameter Discovery](SKILL.md#parameter-discovery)

### 进阶技巧
- **批量处理** → [complete_examples.md - 批量处理最佳实践](examples/complete_examples.md#批量处理最佳实践)
- **错误处理** → [complete_examples.md - 错误处理](examples/complete_examples.md#1-错误处理)
- **提示词工程** → [complete_examples.md - 提示词优化](examples/complete_examples.md#提示词优化技巧)

### 实战案例
- **学习笔记可视化** → [示例2](examples/complete_examples.md#示例-2-思维导图海报生成)
- **办公室幽默表情包** → [示例3](examples/complete_examples.md#示例-3-吐槽表情包批量生成)
- **产品发布会海报** → [示例4](examples/complete_examples.md#示例-4-专业海报设计)
- **赛博朋克艺术** → [示例5](examples/complete_examples.md#示例-5-艺术插画创作)

---

## 🔥 热门功能

### ⭐ 吐槽表情包生成器
最流行的功能！完美融合贴吧文化：

```python
gen.generate_annotated_meme(
    scene="程序员写bug",
    roast_comments=[
        "这代码能跑？我赌五毛要bug",
        "绝绝子，这算法复杂度",
        "咱就是说能不能加点注释"
    ]
)
```

**了解更多：**
- [SKILL.md - 批注风格](SKILL.md#annotation-styles)
- [贴吧语录库](SKILL.md#common-贴吧-slang-for-annotations)
- [完整示例](examples/complete_examples.md#示例-3-吐槽表情包批量生成)

### ⭐ 参数自动发现
不再需要猜测参数名：

```bash
python scripts/discover_params.py \
  --token "YOUR_TOKEN" \
  --workflow-id "YOUR_WORKFLOW_ID"
```

**了解更多：**
- [README_CN.md - 参数发现](README_CN.md#参数发现)
- [脚本源码](scripts/discover_params.py)

### ⭐ 模板系统
6大类型，开箱即用：

```python
# 从 templates/image_templates.json 复制模板
params = {
    "input": "按照模板格式填写内容"
}
```

**了解更多：**
- [模板库](templates/image_templates.json)
- [SKILL.md - Templates](SKILL.md#templates)

---

## 💡 快速提示

### 第一次使用？
1. 确保有 Token 和 Workflow ID
2. 运行参数发现工具
3. 选择一个模板
4. 修改提示词
5. 执行并查看结果

### 想要更好的结果？
- ✅ 提供详细的场景描述
- ✅ 指定具体的视觉风格
- ✅ 列出明确的元素要求
- ✅ 参考成功案例的格式
- ✅ 多次迭代优化

### 遇到问题？
1. 检查 [常见问题](README_CN.md#常见问题)
2. 查看调试 URL
3. 确认参数名称正确
4. 简化提示词重试
5. 查阅完整示例

---

## 🆘 需要帮助？

### 文档内查找
- 使用 Ctrl+F 搜索关键词
- 查看各文档的目录
- 阅读相关示例

### 诊断问题
```bash
# 1. 测试参数
python scripts/discover_params.py --token "T" --workflow-id "W"

# 2. 简单测试
python scripts/coze_workflow.py \
  --token "T" \
  --workflow-id "W" \
  --parameters "{\"input\": \"test\"}"

# 3. 查看调试链接
# 在输出中找到 debug_url 并访问
```

### 外部资源
- [Coze 官方文档](https://www.coze.cn/docs/)
- [工作流 API 参考](https://www.coze.cn/docs/developer_guides/workflow_api)
- [Coze 社区](https://www.coze.cn/community)

---

## 🎯 下一步行动

### 立即开始
```bash
# 1. 克隆或下载 skill
# 2. 安装依赖
pip install requests

# 3. 发现参数
python scripts/discover_params.py --token "YOUR_TOKEN" --workflow-id "YOUR_WF_ID"

# 4. 运行示例
python examples/quick_start.py
```

### 深入学习
1. 阅读 [README_CN.md](README_CN.md) 完整指南
2. 研究 [完整示例](examples/complete_examples.md)
3. 实验不同的 [模板](templates/image_templates.json)
4. 创建自己的提示词库

### 贡献改进
- 发现 bug？报告问题
- 有新想法？提出建议
- 创建了新模板？分享出来

---

## 📊 文档统计

| 文档 | 页数估算 | 适合人群 |
|------|---------|---------|
| QUICK_REFERENCE.md | 2页 | 所有人（速查） |
| README_CN.md | 8页 | 新手用户 |
| SKILL.md | 7页 | 开发者 |
| UPDATE_SUMMARY.md | 10页 | 想了解全貌的人 |
| complete_examples.md | 15页 | 实战学习者 |

**总阅读量估计：** 约 42 页

---

## ✨ 特色亮点

- 🎯 **6大模板** - 覆盖常见图像生成场景
- 🔍 **参数发现** - 自动化测试，告别猜测
- 💬 **贴吧文化** - 完美融合中国互联网幽默
- 📚 **双语文档** - 中英文完整说明
- 💻 **即拷即用** - 完整的示例代码
- 🛠️ **企业级** - 错误处理、批量处理、结果管理

---

**祝你使用愉快！** 🎉

有任何问题或建议，欢迎反馈！

*最后更新：2024年*
