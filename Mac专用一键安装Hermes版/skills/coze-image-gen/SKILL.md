---
name: coze-image-gen
description: Generate images using Coze workflows with creative templates. Use when the user wants to create posters, mind maps, annotated images, or any visual content through Coze image generation workflows.
---

# Coze Image Generation Skill

## When to use

Use this skill when the user wants to:
- Generate images, posters, or visual content via Coze workflows
- Create mind maps from text content
- Add annotations, doodles, or hand-drawn effects to images
- Use pre-built image generation templates
- Create meme-style images with Chinese internet slang commentary

## Prerequisites

- Coze API access token with `run` permission
- Workflow ID for image generation (must be published)
- Python 3.7+ with `requests` library
- Understanding of the workflow's expected input parameters

## Quick Start

### Basic Image Generation

```bash
python scripts/coze_workflow.py --token "TOKEN" --workflow-id "WF_ID" --parameters "{\"input\": \"Your prompt here\"}"
```

### Using Templates

See the [Templates](#templates) section below for ready-to-use examples.

## Parameter Discovery

**IMPORTANT**: Before running a workflow, you need to know what parameters it expects.

### How to Discover Parameters

1. **Check the workflow documentation** - Ask the user for workflow details
2. **Common parameter names**:
   - `input` - General text input (most common)
   - `text` - Text content to process
   - `prompt` - Image generation prompt
   - `content` - Content to visualize
   
3. **Ask the user**: If unsure, ask the user what parameters their workflow expects

### Parameter Format

Parameters must be valid JSON. Use a file to avoid shell escaping issues:

```python
# Create params.json
{
  "input": "Your content here"
}

# Run with file
python scripts/coze_workflow.py --token "TOKEN" --workflow-id "WF_ID" --parameters "$(cat params.json)"
```

## Templates

### Template 1: Mind Map Poster

Generate a mind map from text content with organic layout and color coding.

**Use case**: Convert structured text into visual mind maps

**Parameters**:
```json
{
  "input": "Create a mind map about [TOPIC]. Main points: - Point 1 - Point 2 - Point 3"
}
```

**Example**:
```bash
python scripts/coze_workflow.py \
  --token "YOUR_TOKEN" \
  --workflow-id "YOUR_WORKFLOW_ID" \
  --parameters "{\"input\": \"我要做一个宣传海报 将这段文字转化为一张从中心向外扩展的思维导图。关键点：- 将主旨放在中心 - 将相关元素排列为分支节点 - 使用颜色编码区分不同类别 - 添加简单图标 - 采用有机布局\"}"
```

### Template 2: Annotated Meme Image

Generate an image and add handwritten Chinese annotations, doodles, and roasting commentary in internet slang style.

**Use case**: Create humorous annotated images with贴吧-style commentary

**Parameters**:
```json
{
  "input": "Generate an image about [SUBJECT], then add handwritten red ink annotations with funny roasting commentary in Chinese internet slang style, add some clipart stickers",
  "style": "meme_with_annotations",
  "annotation_style": "red_handwritten_chinese",
  "commentary_tone": "humorous_roast"
}
```

**Example**:
```bash
python scripts/coze_workflow.py \
  --token "YOUR_TOKEN" \
  --workflow-id "YOUR_WORKFLOW_ID" \
  --parameters "{\"input\": \"生成一张程序员写代码的图片，然后用红墨水加上手写中文批注和涂鸦，用贴吧老哥的口语疯狂吐槽，比如'这代码能跑？我赌五毛要bug'、'兄弟你这缩进是认真的吗'，加点小剪贴画\"}"
```

### Template 3: Professional Poster

Create a clean, professional poster or infographic.

**Parameters**:
```json
{
  "input": "Create a professional poster about [TOPIC] with modern design, clear typography, and balanced layout",
  "style": "professional",
  "color_scheme": "modern_minimal"
}
```

### Template 4: Artistic Illustration

Generate artistic illustrations with specific styles.

**Parameters**:
```json
{
  "input": "Create an artistic illustration of [SUBJECT] in [STYLE] style",
  "style": "watercolor|anime|cyberpunk|minimalist|vintage",
  "mood": "calm|energetic|mysterious|cheerful"
}
```

### Template 5: Social Media Post

Generate images optimized for different social media platforms.

**Parameters**:
```json
{
  "input": "Create a [platform] post image about [topic]",
  "platform": "wechat|weibo|xiaohongshu|douyin",
  "aspect_ratio": "1:1|3:4|9:16|16:9"
}
```

### Template 6: Bento Grid Tier Chart ⭐ NEW

Create modern tier charts with "Bento Grid" layout for product/field rankings.

**Use case**: Visualize rankings with clear visual hierarchy

**Parameters**:
```json
{
  "input": "Create a Bento Grid tier chart for [topic]. Tier 1 (夯): [top products]. Tier 2: [great]. Tier 3: [good]. Tier 4 (NPC): [mediocre]. Tier 5 (拉完了): [failed]."
}
```

**Five-Tier Structure**:

| Tier | Name | Meaning | Visual Style |
|------|------|---------|--------------|
| 1 | 夯 (Hāng) | 版本之子、统治级 | 爆裂红与辉煌金、光晕 |
| 2 | 顶级 | 硬核实力派 | 燃烧橙与金属银 |
| 3 | 人上人 | 优越之选 | 柠檬黄与冷灰 |
| 4 | NPC | 大众脸、平庸 | 面包色/纸板棕 |
| 5 | 拉完了 | 灾难级、避雷针 | 绝望黑+Glitch |

**Example**:
```bash
python scripts/coze_workflow.py \
  --token "YOUR_TOKEN" \
  --workflow-id "YOUR_WORKFLOW_ID" \
  --parameters '{"input": "创建程序员代码编辑器等级图。第1级（夯）：VS Code。第2级：JetBrains。第3级：Sublime Text。第4级（NPC）：Atom。第5级（拉完了）：记事本写代码。Bento Grid布局。"}'
```

**Tips**:
- Always specify concrete product names
- Tier 1 should occupy the largest space
- Tier 5 should have Glitch effects

## Annotation Styles

For templates that support annotations, you can specify:

### Commentary Tones
- **humorous_roast** - Funny teasing in internet slang (贴吧风格)
- **sarcastic** - Sarcastic commentary
- **encouraging** - Positive and supportive notes
- **critical** - Constructive criticism

### Visual Styles
- **red_handwritten_chinese** - Red ink handwritten Chinese (红墨水手写)
- **blue_pen_notes** - Blue pen annotations
- **marker_highlights** - Marker pen highlights
- **pencil_sketch** - Pencil sketch style

### Common 贴吧 Slang for Annotations
- "这也太秀了吧" (This is too extra)
- "我直接好家伙" (Well well well)
- "笑死，根本停不下来" (LOL, can't stop)
- "就这？" (Is that all?)
- "蚌埠住了" (Can't hold it in)
- "绝绝子" (Absolutely amazing/terrible)
- "咱就是说" (Let's just say)
- "一整个爱住了" (Totally love it)

## Best Practices

1. **Always verify workflow parameters** - Ask user or check documentation
2. **Use JSON files for complex parameters** - Avoid shell escaping issues
3. **Test with simple prompts first** - Then refine
4. **Save successful configurations** - Reuse working parameter sets
5. **Handle output appropriately** - Check if result is URL, base64, or file path

## Troubleshooting

### Issue: "unrecognized arguments" error
**Solution**: Use a JSON file instead of inline parameters to avoid shell escaping

### Issue: Output is null
**Solution**: Check if you're using the correct parameter name (e.g., `input` vs `text`)

### Issue: Workflow not found
**Solution**: Verify workflow ID and ensure it's published

### Issue: Permission denied
**Solution**: Check your token has `run` permission

## Example Workflow

Here's a complete example of generating an annotated meme image:

```python
import subprocess
import json

# Create parameter file
params = {
    "input": "生成一张办公室场景的图片，然后用红墨水加上手写中文批注，用贴吧老哥的语气吐槽：'这工位也太卷了吧'、'摸鱼被抓包现场'、'咖啡续命实锤'，加点搞笑剪贴画"
}

with open('image_params.json', 'w', encoding='utf-8') as f:
    json.dump(params, f, ensure_ascii=False, indent=2)

# Read parameters
with open('image_params.json', 'r', encoding='utf-8') as f:
    params_str = f.read()

# Execute workflow
result = subprocess.run([
    'python', 'scripts/coze_workflow.py',
    '--token', 'YOUR_TOKEN',
    '--workflow-id', 'YOUR_WORKFLOW_ID',
    '--parameters', params_str
], capture_output=True, text=True, encoding='utf-8')

print(result.stdout)
if result.stderr:
    print("Errors:", result.stderr)
```

## Related Skills

- **coze-workflow** - General Coze workflow execution
- **coze-chat** - Chat with Coze bots

## Resources

- [Coze API Documentation](https://www.coze.cn/docs/developer_guides/api_overview)
- [Workflow API Reference](https://www.coze.cn/docs/developer_guides/workflow_api)
