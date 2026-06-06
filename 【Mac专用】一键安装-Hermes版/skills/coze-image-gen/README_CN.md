# Coze 图像生成技能使用指南

## 📋 目录

- [快速开始](#快速开始)
- [参数发现](#参数发现)
- [模板使用](#模板使用)
- [案例示例](#案例示例)
- [常见问题](#常见问题)

---

## 🚀 快速开始

### 1. 准备工作

确保你已经具备：
- ✅ Coze API 访问令牌（需要有 `run` 权限）
- ✅ 已发布的工作流 ID
- ✅ Python 3.7+ 和 `requests` 库

安装依赖：
```bash
pip install requests
```

### 2. 基础用法

```bash
python scripts/coze_workflow.py \
  --token "YOUR_TOKEN" \
  --workflow-id "YOUR_WORKFLOW_ID" \
  --parameters "{\"input\": \"你的提示词\"}"
```

### 3. 使用 Python 脚本（推荐）

为避免命令行转义问题，建议使用 Python 脚本：

```python
import subprocess
import json

# 准备参数
params = {"input": "生成一张思维导图海报"}

# 写入临时文件
with open('params.json', 'w', encoding='utf-8') as f:
    json.dump(params, f, ensure_ascii=False)

# 读取参数
with open('params.json', 'r', encoding='utf-8') as f:
    params_str = f.read()

# 执行工作流
result = subprocess.run([
    'python', 'scripts/coze_workflow.py',
    '--token', 'YOUR_TOKEN',
    '--workflow-id', 'YOUR_WORKFLOW_ID',
    '--parameters', params_str
], capture_output=True, text=True, encoding='utf-8')

print(result.stdout)
```

或者使用快捷类：

```python
from examples.quick_start import CozeImageGenerator

generator = CozeImageGenerator("YOUR_TOKEN", "YOUR_WORKFLOW_ID")

# 生成思维导图
result = generator.generate_mindmap("人工智能的核心技术")
print(result)
```

---

## 🔍 参数发现

如果你不确定工作流需要什么参数，可以使用参数发现工具：

### 自动发现

```bash
python scripts/discover_params.py \
  --token "YOUR_TOKEN" \
  --workflow-id "YOUR_WORKFLOW_ID"
```

这会测试常见的参数名称（input, text, prompt, content 等）并告诉你哪个有效。

### 测试特定参数

```bash
python scripts/discover_params.py \
  --token "YOUR_TOKEN" \
  --workflow-id "YOUR_WORKFLOW_ID" \
  --param-name "input" \
  --test-value "test content"
```

### 创建参数模板

```bash
python scripts/discover_params.py \
  --token "YOUR_TOKEN" \
  --workflow-id "YOUR_WORKFLOW_ID" \
  --param-name "input" \
  --create-template
```

这会生成一个 JSON 模板文件，方便后续使用。

---

## 📝 模板使用

我们提供了多种预设模板，位于 `templates/image_templates.json`。

### 可用模板

1. **mindmap_poster** - 思维导图海报
2. **annotated_meme** - 吐槽批注表情包
3. **professional_poster** - 专业海报设计
4. **artistic_illustration** - 艺术插画
5. **infographic** - 信息图表
6. **social_media_post** - 社交媒体配图

### 使用模板

查看模板文件了解每个模板的详细参数和示例。

#### 示例：思维导图

```python
params = {
    "input": "我要做一个宣传海报 将这段文字转化为一张从中心向外扩展的思维导图。关键点：- 将主旨放在中心 - 将相关元素排列为分支节点 - 使用颜色编码区分不同类别 - 添加简单图标 - 采用有机布局"
}
```

#### 示例：吐槽表情包

```python
params = {
    "input": "生成一张程序员写代码的图片，然后用红墨水加上手写中文批注和涂鸦，用贴吧老哥的口语疯狂吐槽，比如'这代码能跑？我赌五毛要bug'、'兄弟你这缩进是认真的吗'、'笑死，根本停不下来'，加点小剪贴画"
}
```

---

## 💡 案例示例

### 案例 1：学习笔记思维导图

**场景**：将 Python 学习笔记转化为可视化思维导图

```python
content = """
Python编程核心概念：
- 数据结构
  - 列表、元组、字典
  - 集合、字符串
- 控制流程
  - 条件语句
  - 循环结构
- 函数
  - 定义和调用
  - 参数传递
  - 返回值
- 面向对象
  - 类和对象
  - 继承和多态
"""

generator.generate_mindmap(content, style="organic")
```

### 案例 2：办公室吐槽表情包

**场景**：制作搞笑办公室场景表情包

```python
generator.generate_annotated_meme(
    scene="办公室加班到深夜",
    roast_comments=[
        "卷王之王非你莫属",
        "咖啡续命实锤了",
        "社畜的日常写照",
        "这班上的，绝绝子",
        "咱就是说能不能早点下班"
    ],
    annotation_style="red_handwritten"
)
```

### 案例 3：产品发布会海报

**场景**：设计专业的科技产品发布会海报

```python
generator.generate_professional_poster(
    topic="AI助手产品发布会 2024",
    style="tech",
    color_scheme="blue_white"
)
```

### 案例 4：赛博朋克风格插画

**场景**：创作未来城市夜景插画

```python
generator.generate_artistic_illustration(
    subject="未来城市的霓虹夜景",
    art_style="cyberpunk",
    mood="mysterious"
)
```

### 案例 5：小红书美妆封面

**场景**：制作小红书美妆教程封面图

```python
generator.generate_social_media_image(
    platform="xiaohongshu",
    topic="春季妆容教程",
    aspect_ratio="3:4"
)
```

---

## 🎨 批注风格指南

### 吐槽语气

使用贴吧老哥的经典语录：

- **惊讶类**：
  - "这也太秀了吧"
  - "我直接好家伙"
  - "蚌埠住了"

- **嘲讽类**：
  - "就这？"
  - "笑死，根本停不下来"
  - "栓Q"

- **赞叹类**：
  - "绝绝子"
  - "一整个爱住了"
  - "YYDS"

- **无奈类**：
  - "咱就是说"
  - "我真的会谢"
  - "属实给我整不会了"

### 视觉风格

- **red_handwritten** - 红墨水手写（最常用，醒目）
- **blue_pen** - 蓝色圆珠笔（自然、日常）
- **marker** - 荧光笔标记（突出重点）
- **pencil** - 铅笔素描（柔和、文艺）

### 装饰元素

- emoji 表情：😂 👍 🔥 💯 😅
- 箭头和圈圈：指向重点
- 小剪贴画：增加趣味性
- 涂鸦线条：表达情绪

---

## ❓ 常见问题

### Q1: 输出结果为 null

**原因**：参数名称不正确

**解决**：
1. 使用参数发现工具确认正确的参数名
2. 常见参数名：`input`, `text`, `prompt`, `content`
3. 检查工作流文档或询问创建者

### Q2: 图片质量不理想

**原因**：提示词不够详细

**解决**：
- 提供更多细节描述
- 指定具体的风格和元素
- 参考成功案例的提示词格式
- 多次迭代优化

### Q3: 命令行参数转义错误

**原因**：PowerShell/命令行的 JSON 转义问题

**解决**：
- 使用 Python 脚本而非直接命令行
- 将参数写入 JSON 文件后读取
- 参考 `examples/quick_start.py`

### Q4: 工作流执行超时

**原因**：复杂图像生成需要较长时间

**解决**：
- 使用异步模式：添加 `--async-run` 参数
- 简化提示词
- 检查工作流是否有性能问题

### Q5: 如何复用成功配置

**建议**：
1. 保存成功的参数到 JSON 文件
2. 创建自己的模板库
3. 记录工作流 ID 和参数名的对应关系
4. 使用 `CozeImageGenerator` 类封装常用功能

---

## 🔗 相关资源

- [Coze 官方文档](https://www.coze.cn/docs/)
- [工作流 API 参考](https://www.coze.cn/docs/developer_guides/workflow_api)
- coze-workflow Skill - 通用工作流执行
- coze-chat Skill - 与 Coze Bot 对话

---

## 📞 获取帮助

如果遇到问题：

1. 查看调试 URL（在输出中提供）
2. 检查工作流是否在 Coze 平台正确发布
3. 确认 token 权限是否足够
4. 查阅本文档的常见问题部分
5. 联系工作流创建者获取参数说明

---

## 🎯 最佳实践

1. **先测试后批量** - 先用简单提示词测试，确认工作正常后再复杂化
2. **保存成功配置** - 记录有效的参数组合
3. **迭代优化** - 根据结果调整提示词
4. **使用模板** - 基于现有模板修改，提高效率
5. **参数文件化** - 复杂参数使用 JSON 文件管理
6. **错误处理** - 检查返回结果，处理可能的错误

---

祝你使用愉快！🎉
