# Coze Image Gen - 快速参考卡

## 🚀 30秒快速开始

```python
from examples.quick_start import CozeImageGenerator

# 初始化
gen = CozeImageGenerator("YOUR_TOKEN", "YOUR_WORKFLOW_ID")

# 一行代码生成图像
result = gen.generate_mindmap("Python核心概念")
```

---

## 🔍 参数发现（未知工作流）

```bash
# 自动测试常见参数名
python scripts/discover_params.py \
  --token "TOKEN" \
  --workflow-id "WF_ID"
```

---

## 📝 6大模板速查

### 1️⃣ 思维导图
```python
gen.generate_mindmap(
    content="主题内容",
    style="organic|professional|creative"
)
```

### 2️⃣ 吐槽表情包 ⭐
```python
gen.generate_annotated_meme(
    scene="场景描述",
    roast_comments=["吐槽1", "吐槽2"],
    annotation_style="red_handwritten"
)
```

### 3️⃣ 专业海报
```python
gen.generate_professional_poster(
    topic="活动主题",
    style="modern_minimal|tech|corporate",
    color_scheme="blue_white|dark|warm"
)
```

### 4️⃣ 艺术插画
```python
gen.generate_artistic_illustration(
    subject="创作主题",
    art_style="watercolor|cyberpunk|anime|vintage",
    mood="calm|energetic|mysterious"
)
```

### 5️⃣ 信息图表
```python
# 使用模板
params = {
    "input": "创建[主题]信息图，包含数据可视化"
}
```

### 6️⃣ 社交媒体
```python
gen.generate_social_media_image(
    platform="wechat|weibo|xiaohongshu|douyin",
    topic="内容主题",
    aspect_ratio="1:1|3:4|9:16"
)
```

### 7️⃣ Bento Grid等级分层图 ⭐ NEW
```python
gen.generate_bento_tier_chart(
    topic="领域/产品主题",
    tiers={
        "tier_1": ["顶流产品"],
        "tier_2": ["实力派产品"],
        "tier_3": ["优质中产"],
        "tier_4": ["平庸产品"],
        "tier_5": ["翻车产品"]
    }
)
```

**五级分层定义：**
- 🏆 **夯 (Tier 1)**: 版本之子、统治级 - 爆裂红与辉煌金
- 🥇 **顶级 (Tier 2)**: 硬核实力派 - 燃烧橙与金属银
- 🥈 **人上人 (Tier 3)**: 优越之选 - 柠檬黄与冷灰
- 😐 **NPC (Tier 4)**: 大众脸 - 面包色/纸板棕
- 💀 **拉完了 (Tier 5)**: 灾难级 - 绝望黑与惨白+Glitch

---

## 💬 贴吧吐槽语录库

### 惊讶类
- "这也太秀了吧"
- "我直接好家伙"
- "蚌埠住了"

### 嘲讽类
- "就这？"
- "笑死，根本停不下来"
- "栓Q"

### 赞叹类
- "绝绝子"
- "一整个爱住了"
- "YYDS"

### 无奈类
- "咱就是说"
- "我真的会谢"
- "属实给我整不会了"

---

## 🎨 批注风格

| 风格 | 说明 | 适用场景 |
|------|------|----------|
| `red_handwritten` | 红墨水手写 | 醒目、强调 |
| `blue_pen` | 蓝色圆珠笔 | 自然、日常 |
| `marker` | 荧光笔标记 | 突出重点 |
| `pencil` | 铅笔素描 | 柔和、文艺 |

---

## 🛠️ 常用命令

### 基础执行
```bash
python scripts/coze_workflow.py \
  --token "TOKEN" \
  --workflow-id "WF_ID" \
  --parameters "{\"input\": \"content\"}"
```

### 流式输出
```bash
python scripts/coze_workflow.py \
  --token "TOKEN" \
  --workflow-id "WF_ID" \
  --parameters "{\"input\": \"content\"}" \
  --stream
```

### 异步执行
```bash
python scripts/coze_workflow.py \
  --token "TOKEN" \
  --workflow-id "WF_ID" \
  --parameters "{\"input\": \"content\"}" \
  --async-run
```

---

## 💡 提示词公式

### 思维导图
```
创建[主题]的思维导图 + 
布局要求（有机/专业） + 
视觉元素（颜色/图标） + 
风格定位
```

### 吐槽表情包
```
生成[场景]图片 + 
用[颜色]加手写批注 + 
用[语气]吐槽：[具体内容] + 
添加[装饰元素]
```

### 专业海报
```
创建[主题]海报 + 
风格（现代/商务/科技） + 
配色方案 + 
关键信息突出
```

### 艺术插画
```
创作[主题]插画 + 
艺术风格 + 
氛围情绪 + 
色彩偏好
```

---

## ⚠️ 常见问题速解

### Q: 输出为 null
**A**: 检查参数名（通常是 `input`）
```bash
python scripts/discover_params.py --token "T" --workflow-id "W"
```

### Q: 命令行转义错误
**A**: 使用 Python 脚本而非命令行
```python
import json
params = {"input": "content"}
with open('p.json', 'w') as f:
    json.dump(params, f)
```

### Q: 图片质量差
**A**: 增加提示词细节
```python
# ❌ 差
"生成思维导图"

# ✅ 好
"生成关于X的思维导图，有机布局，颜色编码，添加图标，现代风格"
```

### Q: 批量处理超时
**A**: 添加延时和重试
```python
import time
for task in tasks:
    result = generate(task)
    time.sleep(2)  # 避免过快
```

---

## 📂 文件位置

```
.qoder/skills/coze-image-gen/
├── SKILL.md                    # 完整文档
├── README_CN.md                # 中文指南
├── scripts/
│   └── discover_params.py      # 参数发现
├── templates/
│   └── image_templates.json    # 模板库
└── examples/
    ├── quick_start.py          # 快捷类
    └── complete_examples.md    # 完整示例
```

---

## 🔗 相关链接

- [完整文档](SKILL.md)
- [中文指南](README_CN.md)
- [更新总结](UPDATE_SUMMARY.md)
- [Coze API 文档](https://www.coze.cn/docs/)

---

## 📞 获取帮助

1. 查看 `README_CN.md` 常见问题
2. 使用参数发现工具诊断
3. 检查调试 URL
4. 查阅完整示例代码

---

**提示**: 打印此卡片作为快速参考！📄
