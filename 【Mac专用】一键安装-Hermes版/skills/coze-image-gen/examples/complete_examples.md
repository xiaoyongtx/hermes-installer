# Coze 图像生成完整示例

本文件包含各种实际使用场景的完整代码示例。

## 目录结构

```
.qoder/skills/coze-image-gen/
├── SKILL.md                          # 技能说明文档
├── README_CN.md                      # 中文使用指南
├── scripts/
│   ├── discover_params.py            # 参数发现工具
│   └── coze_workflow.py              # (引用自 coze-workflow skill)
├── templates/
│   └── image_templates.json          # 预设模板
├── examples/
│   ├── quick_start.py                # 快速开始类
│   └── complete_examples.md          # 完整示例（本文件）
└── README.md                         # 英文说明
```

---

## 示例 1: 发现工作流参数

当你有一个新的工作流 ID，但不知道它需要什么参数时：

```python
#!/usr/bin/env python3
"""
示例：自动发现工作流参数
"""

import subprocess
import sys

def discover_workflow_params(token: str, workflow_id: str):
    """Discover what parameters a workflow accepts."""
    
    cmd = [
        sys.executable,
        'scripts/discover_params.py',
        '--token', token,
        '--workflow-id', workflow_id
    ]
    
    result = subprocess.run(cmd, capture_output=True, text=True, encoding='utf-8')
    print(result.stdout)
    
    if result.stderr:
        print("Errors:", result.stderr)

if __name__ == "__main__":
    TOKEN = "your_token_here"
    WORKFLOW_ID = "your_workflow_id_here"
    
    print("Discovering workflow parameters...")
    discover_workflow_params(TOKEN, WORKFLOW_ID)
```

**运行结果示例：**
```
============================================================
Coze Workflow Parameter Discovery Tool
============================================================

Workflow ID: 7614143720858058794

Testing common parameter names...

Testing parameter: 'input'... ✓ SUCCESS
Testing parameter: 'text'... ✗ FAILED
Testing parameter: 'prompt'... ✗ FAILED

============================================================
Discovery Results:
============================================================

Found 1 working parameter(s):

1. Parameter name: 'input'
   Sample output: {"output": ["https://s.coze.cn/t/xxx/"]}
   
Recommendation:
Use the parameter name: 'input'
```

---

## 示例 2: 思维导图海报生成

将结构化文本转化为视觉化的思维导图：

```python
#!/usr/bin/env python3
"""
示例：生成学习主题思维导图
"""

import subprocess
import json

def generate_mindmap(token: str, workflow_id: str, topic: str):
    """Generate a mind map for a learning topic."""
    
    # 准备提示词
    prompt = f"""
    我要做一个关于"{topic}"的宣传海报，将内容转化为一张从中心向外扩展的思维导图。
    
    关键点：
    - 将主旨放在中心
    - 将相关元素排列为分支节点
    - 使用颜色编码区分不同类别
    - 添加简单图标增强视觉效果
    - 采用有机布局，让它感觉像思绪正在被整理
    - 风格：现代、清晰、专业
    """
    
    # 创建参数文件
    params = {"input": prompt}
    with open('mindmap_params.json', 'w', encoding='utf-8') as f:
        json.dump(params, f, ensure_ascii=False, indent=2)
    
    # 读取参数
    with open('mindmap_params.json', 'r', encoding='utf-8') as f:
        params_str = f.read()
    
    # 执行工作流
    cmd = [
        'python',
        '.qoder/skills/coze-workflow/scripts/coze_workflow.py',
        '--token', token,
        '--workflow-id', workflow_id,
        '--parameters', params_str
    ]
    
    result = subprocess.run(cmd, capture_output=True, text=True, encoding='utf-8')
    
    print("=" * 60)
    print("Mind Map Generation Result:")
    print("=" * 60)
    print(result.stdout)
    
    if result.stderr:
        print("\nErrors:", result.stderr)
    
    return result.stdout

if __name__ == "__main__":
    TOKEN = "pat_EkCCkF0yT6afQftEJJgxKUj4dp8k6OU3391vdI5yYnqstY4aAAKNcPvNkGvZ0OgZ"
    WORKFLOW_ID = "7614143720858058794"
    
    # 生成多个主题的思维导图
    topics = [
        "Python编程核心概念",
        "人工智能技术栈",
        "Web开发全流程",
        "数据科学方法论"
    ]
    
    for topic in topics:
        print(f"\n{'='*60}")
        print(f"Generating mind map for: {topic}")
        print('='*60)
        generate_mindmap(TOKEN, WORKFLOW_ID, topic)
```

---

## 示例 3: 吐槽表情包批量生成

使用贴吧风格吐槽生成搞笑表情包：

```python
#!/usr/bin/env python3
"""
示例：批量生成吐槽表情包
"""

import subprocess
import json
import time
import random

# 贴吧经典吐槽语录
ROAST_COMMENTS = {
    "programming": [
        "这代码能跑？我赌五毛要bug",
        "兄弟你这缩进是认真的吗",
        "笑死，根本停不下来",
        "就这？我上我也行",
        "绝绝子，这算法复杂度",
        "咱就是说能不能加点注释",
        "我真的会谢，这变量命名"
    ],
    "office": [
        "卷王之王非你莫属",
        "咖啡续命实锤了",
        "社畜的日常写照",
        "这班上的，绝绝子",
        "咱就是说能不能早点下班",
        "摸鱼被抓包现场",
        "KPI杀手就是你"
    ],
    "fitness": [
        "拍照五分钟健身两秒钟",
        "就这肌肉线条？",
        "健身房打卡专业户",
        "蛋白粉喝多了吧",
        "蚌埠住了，这动作标准度",
        "私教钱白花了吧",
        "一整个尴尬住了"
    ],
    "cooking": [
        "这是碳基生物能做出来的？",
        "厨房杀手实锤",
        "外卖不香吗非要自己做",
        "笑死，这卖相",
        "黑暗料理界的新星",
        "咱就是说能不能照着菜谱做",
        "我真的会谢，这火候"
    ]
}

def generate_roast_meme(token: str, workflow_id: str, 
                        scene: str, category: str = "programming"):
    """Generate a meme with roasting annotations."""
    
    # 获取对应类别的吐槽语
    comments = ROAST_COMMENTS.get(category, ROAST_COMMENTS["programming"])
    
    # 随机选择3-5条吐槽
    selected_comments = random.sample(comments, min(5, len(comments)))
    comments_text = "、".join([f"'{c}'" for c in selected_comments])
    
    # 构建提示词
    prompt = f"""
    生成一张{scene}的图片，然后用红墨水加上手写中文批注和涂鸦。
    
    用贴吧老哥的口语疯狂吐槽，包括以下内容：{comments_text}
    
    还要加点小剪贴画和emoji让画面更生动有趣，比如箭头、圈圈、😂、👍、🔥等。
    
    整体风格要幽默搞笑，让人看了会心一笑。
    """
    
    # 执行工作流
    params = {"input": prompt}
    params_str = json.dumps(params, ensure_ascii=False)
    
    cmd = [
        'python',
        '.qoder/skills/coze-workflow/scripts/coze_workflow.py',
        '--token', token,
        '--workflow-id', workflow_id,
        '--parameters', params_str
    ]
    
    result = subprocess.run(cmd, capture_output=True, text=True, encoding='utf-8')
    
    print(f"\n{'='*60}")
    print(f"Scene: {scene}")
    print(f"Category: {category}")
    print(f"Comments used: {', '.join(selected_comments)}")
    print('='*60)
    print(result.stdout)
    
    if result.stderr:
        print("\nErrors:", result.stderr)
    
    return result.stdout

if __name__ == "__main__":
    TOKEN = "your_token_here"
    WORKFLOW_ID = "your_workflow_id_here"
    
    # 定义要生成的场景
    scenes = [
        ("程序员深夜debug", "programming"),
        ("办公室开会打瞌睡", "office"),
        ("健身房自拍秀肌肉", "fitness"),
        ("第一次做饭炸厨房", "cooking"),
        ("周一早高峰挤地铁", "office"),
        ("熬夜赶deadline", "programming"),
    ]
    
    print("Starting batch meme generation...")
    print(f"Total scenes to process: {len(scenes)}\n")
    
    for i, (scene, category) in enumerate(scenes, 1):
        print(f"\n[{i}/{len(scenes)}] Processing...")
        generate_roast_meme(TOKEN, WORKFLOW_ID, scene, category)
        time.sleep(2)  # 避免请求过快
    
    print("\n✅ All memes generated!")
```

---

## 示例 4: 专业海报设计

为活动或产品创建专业海报：

```python
#!/usr/bin/env python3
"""
示例：创建活动宣传海报
"""

import subprocess
import json

def create_event_poster(token: str, workflow_id: str, event_info: dict):
    """Create a professional event poster."""
    
    prompt = f"""
    创建一个专业的活动宣传海报，详细信息如下：
    
    活动名称：{event_info['name']}
    活动时间：{event_info.get('date', '待定')}
    活动地点：{event_info.get('location', '待定')}
    活动主题：{event_info.get('theme', '')}
    
    设计要求：
    - 风格：{event_info.get('style', 'modern_minimal')}
    - 配色：{event_info.get('color_scheme', 'blue_white')}
    - 突出显示活动名称和关键信息
    - 现代、专业、吸引眼球
    - 适合在社交媒体和网站传播
    - 预留二维码位置（如需要）
    """
    
    params = {"input": prompt}
    params_str = json.dumps(params, ensure_ascii=False)
    
    cmd = [
        'python',
        '.qoder/skills/coze-workflow/scripts/coze_workflow.py',
        '--token', token,
        '--workflow-id', workflow_id,
        '--parameters', params_str
    ]
    
    result = subprocess.run(cmd, capture_output=True, text=True, encoding='utf-8')
    
    print(f"\nPoster generated for: {event_info['name']}")
    print(result.stdout)
    
    return result.stdout

if __name__ == "__main__":
    TOKEN = "your_token_here"
    WORKFLOW_ID = "your_workflow_id_here"
    
    # 定义多个活动
    events = [
        {
            "name": "AI技术峰会 2024",
            "date": "2024年6月15-16日",
            "location": "北京国际会议中心",
            "theme": "探索人工智能的未来",
            "style": "tech",
            "color_scheme": "dark_blue_neon"
        },
        {
            "name": "Python开发者大会",
            "date": "2024年7月20日",
            "location": "上海世博中心",
            "theme": "Python生态与创新应用",
            "style": "modern_minimal",
            "color_scheme": "blue_yellow"
        },
        {
            "name": "创业路演日",
            "date": "2024年8月5日",
            "location": "深圳湾创业广场",
            "theme": "连接创业者与投资人",
            "style": "corporate",
            "color_scheme": "red_white"
        }
    ]
    
    for event in events:
        create_event_poster(TOKEN, WORKFLOW_ID, event)
```

---

## 示例 5: 艺术插画创作

创作不同风格的艺术作品：

```python
#!/usr/bin/env python3
"""
示例：创作艺术插画系列
"""

import subprocess
import json

def create_artwork(token: str, workflow_id: str, artwork_config: dict):
    """Create an artistic illustration."""
    
    prompt = f"""
    创作一幅"{artwork_config['subject']}"的艺术插画。
    
    艺术风格：{artwork_config['style']}
    氛围情绪：{artwork_config.get('mood', 'balanced')}
    色彩偏好：{artwork_config.get('colors', '自然色调')}
    
    要求：
    - 注重细节和质感表现
    - 具有强烈的艺术表现力
    - 构图精美，视觉冲击力强
    - 适合用作装饰画或壁纸
    """
    
    params = {"input": prompt}
    params_str = json.dumps(params, ensure_ascii=False)
    
    cmd = [
        'python',
        '.qoder/skills/coze-workflow/scripts/coze_workflow.py',
        '--token', token,
        '--workflow-id', workflow_id,
        '--parameters', params_str
    ]
    
    result = subprocess.run(cmd, capture_output=True, text=True, encoding='utf-8')
    
    print(f"\nArtwork created: {artwork_config['subject']} ({artwork_config['style']})")
    print(result.stdout)
    
    return result.stdout

if __name__ == "__main__":
    TOKEN = "your_token_here"
    WORKFLOW_ID = "your_workflow_id_here"
    
    # 定义艺术作品配置
    artworks = [
        {
            "subject": "雨中的东京街头",
            "style": "cyberpunk",
            "mood": "mysterious",
            "colors": "霓虹蓝紫调"
        },
        {
            "subject": "春日樱花庭院",
            "style": "watercolor",
            "mood": "calm",
            "colors": "粉色和绿色"
        },
        {
            "subject": "未来太空站",
            "style": "sci_fi",
            "mood": "energetic",
            "colors": "银白和蓝色"
        },
        {
            "subject": "古老图书馆",
            "style": "vintage",
            "mood": "mysterious",
            "colors": "暖棕色和金色"
        },
        {
            "subject": "抽象几何图案",
            "style": "minimalist",
            "mood": "calm",
            "colors": "黑白灰"
        }
    ]
    
    print("Creating art collection...\n")
    
    for artwork in artworks:
        create_artwork(TOKEN, WORKFLOW_ID, artwork)
    
    print("\n🎨 Art collection complete!")
```

---

## 示例 6: 使用 CozeImageGenerator 类

最简洁的使用方式：

```python
#!/usr/bin/env python3
"""
示例：使用 CozeImageGenerator 快捷类
"""

import sys
sys.path.append('examples')

from quick_start import CozeImageGenerator

def main():
    # 初始化
    TOKEN = "your_token_here"
    WORKFLOW_ID = "your_workflow_id_here"
    
    generator = CozeImageGenerator(TOKEN, WORKFLOW_ID)
    
    # 1. 生成思维导图
    print("1. Generating Mind Map...")
    result = generator.generate_mindmap(
        content="机器学习的三大支柱：数据、算法、算力",
        style="professional"
    )
    print(result)
    
    # 2. 生成吐槽表情包
    print("\n2. Generating Roast Meme...")
    result = generator.generate_annotated_meme(
        scene="产品经理改需求",
        roast_comments=[
            "又改？第8版了大哥",
            "这需求文档是用脚写的？",
            "笑死，明天就要？",
            "绝绝子，这逻辑",
            "咱就是说能不能想清楚再提"
        ],
        annotation_style="red_handwritten"
    )
    print(result)
    
    # 3. 生成专业海报
    print("\n3. Generating Professional Poster...")
    result = generator.generate_professional_poster(
        topic="2024年度技术分享会",
        style="tech",
        color_scheme="dark_theme"
    )
    print(result)
    
    # 4. 生成艺术插画
    print("\n4. Generating Artistic Illustration...")
    result = generator.generate_artistic_illustration(
        subject="山海经神兽",
        art_style="traditional_chinese",
        mood="mysterious"
    )
    print(result)
    
    # 5. 生成社交媒体配图
    print("\n5. Generating Social Media Image...")
    result = generator.generate_social_media_image(
        platform="xiaohongshu",
        topic="程序员的日常穿搭",
        aspect_ratio="3:4"
    )
    print(result)

if __name__ == "__main__":
    main()
```

---

## 提示词优化技巧

### 好的提示词 vs 差的提示词

❌ **差**：
```
生成一张思维导图
```

✅ **好**：
```
生成一张关于"深度学习基础"的思维导图海报，要求：
- 中心主题明确
- 分支层次清晰（神经网络、CNN、RNN、Transformer等）
- 使用不同颜色区分类别
- 添加相关图标（大脑、网络节点等）
- 采用有机树状布局
- 风格现代专业，适合教学使用
```

### 批注类图片的提示词公式

```
生成一张[场景描述]的图片 + 
用[颜色/风格]加上手写批注 + 
用[语气/风格]吐槽：[具体吐槽内容1]、[具体吐槽内容2]... + 
添加[装饰元素：emoji/剪贴画/箭头等] + 
整体风格[幽默/讽刺/温馨等]
```

### 迭代优化流程

1. **第一版**：基础提示词，测试工作流
2. **第二版**：根据结果调整风格和细节
3. **第三版**：微调颜色、布局、元素
4. **最终版**：保存成功配置，建立模板

---

## 批量处理最佳实践

### 1. 错误处理

```python
import time

def batch_generate_with_retry(tasks, max_retries=3):
    """Batch generate with retry logic."""
    
    results = []
    
    for i, task in enumerate(tasks):
        success = False
        
        for attempt in range(max_retries):
            try:
                print(f"[{i+1}/{len(tasks)}] Attempt {attempt+1}...")
                result = generate_image(task)
                
                if result and "error" not in result.lower():
                    results.append({"task": task, "result": result, "status": "success"})
                    success = True
                    break
                    
            except Exception as e:
                print(f"Error: {e}")
            
            if not success and attempt < max_retries - 1:
                print(f"Retrying in 5 seconds...")
                time.sleep(5)
        
        if not success:
            results.append({"task": task, "status": "failed"})
        
        # Rate limiting
        time.sleep(2)
    
    return results
```

### 2. 结果保存

```python
import json
from datetime import datetime

def save_results(results, filename=None):
    """Save generation results to file."""
    
    if not filename:
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"generation_results_{timestamp}.json"
    
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(results, f, ensure_ascii=False, indent=2)
    
    print(f"Results saved to: {filename}")
```

### 3. 进度跟踪

```python
from tqdm import tqdm

def batch_generate_with_progress(tasks):
    """Generate with progress bar."""
    
    results = []
    
    for task in tqdm(tasks, desc="Generating images"):
        result = generate_image(task)
        results.append(result)
    
    return results
```

---

## 总结

通过这些示例，你可以：

1. ✅ 自动发现工作流参数
2. ✅ 生成各种类型的图像（思维导图、表情包、海报、插画等）
3. ✅ 批量处理多个任务
4. ✅ 使用快捷类简化代码
5. ✅ 优化提示词获得更好结果
6. ✅ 处理错误和重试
7. ✅ 保存和管理结果

祝你创作愉快！🎨✨
