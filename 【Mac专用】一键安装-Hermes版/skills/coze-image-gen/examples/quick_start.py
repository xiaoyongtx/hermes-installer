#!/usr/bin/env python3
"""
Coze Image Generation Quick Start Script

This script provides easy-to-use functions for common image generation tasks.
"""

import json
import subprocess
import sys
from pathlib import Path


class CozeImageGenerator:
    """Easy-to-use interface for Coze image generation workflows."""
    
    def __init__(self, token: str, workflow_id: str):
        """
        Initialize the image generator.
        
        Args:
            token: Coze API access token
            workflow_id: Workflow ID for image generation
        """
        self.token = token
        self.workflow_id = workflow_id
        self.script_path = Path(__file__).parent.parent / "coze-workflow" / "scripts" / "coze_workflow.py"
    
    def _run_workflow(self, parameters: dict, stream: bool = False) -> str:
        """Run the workflow with given parameters."""
        
        # Write parameters to temp file to avoid shell escaping issues
        params_file = Path("temp_params.json")
        with open(params_file, 'w', encoding='utf-8') as f:
            json.dump(parameters, f, ensure_ascii=False)
        
        try:
            # Read parameters
            with open(params_file, 'r', encoding='utf-8') as f:
                params_str = f.read()
            
            # Build command
            cmd = [
                sys.executable,
                str(self.script_path),
                '--token', self.token,
                '--workflow-id', self.workflow_id,
                '--parameters', params_str
            ]
            
            if stream:
                cmd.append('--stream')
            
            # Execute
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                encoding='utf-8'
            )
            
            if result.returncode != 0:
                print(f"Error: {result.stderr}")
                return None
            
            return result.stdout
            
        finally:
            # Clean up
            if params_file.exists():
                params_file.unlink()
    
    def generate_mindmap(self, content: str, style: str = "organic") -> str:
        """
        Generate a mind map from text content.
        
        Args:
            content: Text content to convert to mind map
            style: Layout style (organic, professional, creative)
        
        Returns:
            Result output (usually contains image URL)
        """
        prompt = f"""
        创建一个思维导图海报，要求：
        - 主题内容：{content}
        - 布局风格：{style}
        - 从中心向外扩展
        - 使用颜色编码区分不同类别
        - 添加简单图标增强视觉效果
        - 让整体感觉像思绪正在被整理
        """
        
        return self._run_workflow({"input": prompt})
    
    def generate_annotated_meme(self, scene: str, roast_comments: list = None, 
                                annotation_style: str = "red_handwritten") -> str:
        """
        Generate an image with handwritten annotations and roasting commentary.
        
        Args:
            scene: Description of the scene/image to generate
            roast_comments: List of roasting comments in Chinese internet slang
            annotation_style: Style of annotations (red_handwritten, blue_pen, marker)
        
        Returns:
            Result output with annotated image
        """
        
        if not roast_comments:
            roast_comments = [
                "这也太秀了吧",
                "我直接好家伙",
                "笑死，根本停不下来",
                "就这？",
                "蚌埠住了"
            ]
        
        comments_text = "、".join([f"'{c}'" for c in roast_comments])
        
        prompt = f"""
        生成一张{scene}的图片，然后用{annotation_style}风格加上手写中文批注和涂鸦。
        
        用贴吧老哥的口语疯狂吐槽，包括以下内容：{comments_text}
        
        还要加点小剪贴画和emoji让画面更生动有趣。
        """
        
        return self._run_workflow({"input": prompt})
    
    def generate_professional_poster(self, topic: str, style: str = "modern_minimal",
                                     color_scheme: str = "blue_white") -> str:
        """
        Generate a professional poster or infographic.
        
        Args:
            topic: Topic of the poster
            style: Design style (modern_minimal, corporate, creative, tech)
            color_scheme: Color scheme (blue_white, warm, dark, vibrant)
        
        Returns:
            Result output with poster image
        """
        
        prompt = f"""
        创建一个关于"{topic}"的专业海报，要求：
        - 设计风格：{style}
        - 配色方案：{color_scheme}
        - 现代、清晰的排版
        - 平衡的视觉布局
        - 适合商业或学术展示
        """
        
        return self._run_workflow({"input": prompt})
    
    def generate_artistic_illustration(self, subject: str, art_style: str = "watercolor",
                                       mood: str = "calm") -> str:
        """
        Generate an artistic illustration.
        
        Args:
            subject: Subject matter to illustrate
            art_style: Art style (watercolor, anime, cyberpunk, minimalist, vintage, oil_painting)
            mood: Mood/atmosphere (calm, energetic, mysterious, cheerful)
        
        Returns:
            Result output with illustration
        """
        
        prompt = f"""
        创作一幅"{subject}"的艺术插画，要求：
        - 艺术风格：{art_style}
        - 氛围情绪：{mood}
        - 注重细节和质感
        - 具有艺术表现力
        """
        
        return self._run_workflow({"input": prompt})
    
    def generate_social_media_image(self, platform: str, topic: str, 
                                    aspect_ratio: str = "1:1") -> str:
        """
        Generate social media post image.
        
        Args:
            platform: Target platform (wechat, weibo, xiaohongshu, douyin)
            topic: Topic/content of the post
            aspect_ratio: Image aspect ratio (1:1, 3:4, 9:16, 16:9)
        
        Returns:
            Result output with social media image
        """
        
        platform_specs = {
            "wechat": "微信公众号封面 (900x383)",
            "weibo": "微博配图",
            "xiaohongshu": "小红书笔记 (3:4)",
            "douyin": "抖音封面 (9:16)"
        }
        
        prompt = f"""
        为{platform}平台创建一个关于"{topic}"的社交媒体配图，要求：
        - 平台规格：{platform_specs.get(platform, "通用")}
        - 宽高比：{aspect_ratio}
        - 吸引眼球的视觉设计
        - 适合社交媒体传播的风格
        - 预留文字区域（如需要）
        """
        
        return self._run_workflow({"input": prompt})
    
    def generate_bento_tier_chart(self, topic: str, tiers: dict = None) -> str:
        """
        Generate a Bento Grid tier chart for product/field ranking.
        
        Args:
            topic: The field/topic to rank (e.g., "2024年智能手机", "代码编辑器")
            tiers: Dictionary of tier contents (optional, will use template if not provided)
                   Format: {
                       "tier_1": ["产品1", "产品2"],
                       "tier_2": ["产品3"],
                       "tier_3": ["产品4", "产品5"],
                       "tier_4": ["产品6"],
                       "tier_5": ["产品7"]
                   }
        
        Returns:
            Result output with tier chart image
        
        Tier Structure:
            Tier 1 (夯): 顶流、版本之子 - 爆裂红与辉煌金
            Tier 2 (顶级): 硬核实力派 - 燃烧橙与金属银
            Tier 3 (人上人): 优越之选 - 柠檬黄与冷灰
            Tier 4 (NPC): 大众脸 - 面包色/纸板棕
            Tier 5 (拉完了): 灾难级 - 绝望黑与惨白+Glitch
        """
        
        if tiers:
            # Build custom prompt from provided tiers
            tier_descriptions = {
                "tier_1": "夯（最高层）",
                "tier_2": "顶级",
                "tier_3": "人上人",
                "tier_4": "NPC",
                "tier_5": "拉完了"
            }
            
            tier_parts = []
            for tier_key, tier_name in tier_descriptions.items():
                if tier_key in tiers and tiers[tier_key]:
                    products = "、".join(tiers[tier_key])
                    tier_parts.append(f"第{tier_key[-1]}级（{tier_name}）：{products}")
            
            tier_text = "。".join(tier_parts)
        else:
            tier_text = f"对{topic}进行五级分层评级"
        
        prompt = f"""
        创建一张关于"{topic}"的Bento Grid等级分层信息图。
        
        {tier_text}
        
        整体风格要求：
        - 采用Bento Grid（便当盒网格）布局
        - 背景干净简洁，聚焦内容呈现
        - 视觉上体现从高到低的强烈层级落差感
        
        五级分层视觉定义：
        - 第1级（夯）：占据画面最上方或最大版面，爆裂红与辉煌金色调，带光晕或能量外溢特效，字体最大最粗，展示代表性顶流产品，配极简赞美短语（如"全网吹爆"、"神作"）
        - 第2级（顶级）：位于第二层，燃烧橙与金属银色调，设计扎实富有质感，展示实力派产品
        - 第3级（人上人）：位于中层，柠檬黄与冷灰色调，设计现代清爽，展示优质中产产品
        - 第4级（NPC）：位于中下层，面包色/米色或纸板棕色调，设计普通重复缺乏个性，展示平庸产品（必须写具体产品名）
        - 第5级（拉完了）：挤在画面最底部，绝望黑与惨白色调，带数字故障（Glitch）破碎或腐烂视觉效果，展示翻车产品，配警示短语（如"快逃"、"大冤种"）
        """
        
        return self._run_workflow({"input": prompt})


def main():
    """Example usage of the CozeImageGenerator."""
    
    print("=" * 60)
    print("Coze Image Generator - Quick Start Examples")
    print("=" * 60)
    
    # Configuration - Replace with your actual values
    TOKEN = "your_token_here"
    WORKFLOW_ID = "your_workflow_id_here"
    
    # Check if user provided credentials
    if TOKEN == "your_token_here" or WORKFLOW_ID == "your_workflow_id_here":
        print("\n⚠️  Please update TOKEN and WORKFLOW_ID in the script")
        print("\nUsage example:")
        print("""
from coze_image_gen import CozeImageGenerator

# Initialize
generator = CozeImageGenerator("YOUR_TOKEN", "YOUR_WORKFLOW_ID")

# Generate mind map
result = generator.generate_mindmap("人工智能的关键技术")
print(result)

# Generate annotated meme
result = generator.generate_annotated_meme(
    "程序员写代码",
    roast_comments=["这代码能跑？", "兄弟你这缩进是认真的吗"]
)
print(result)
        """)
        return
    
    # Create generator instance
    generator = CozeImageGenerator(TOKEN, WORKFLOW_ID)
    
    # Example 1: Mind Map
    print("\n1. Generating Mind Map...")
    result = generator.generate_mindmap("Python编程的核心概念")
    print(result)
    
    # Example 2: Annotated Meme
    print("\n2. Generating Annotated Meme...")
    result = generator.generate_annotated_meme(
        "办公室加班场景",
        roast_comments=["卷王之王", "咖啡续命", "社畜日常"]
    )
    print(result)
    
    # Example 3: Professional Poster
    print("\n3. Generating Professional Poster...")
    result = generator.generate_professional_poster("AI技术峰会2024")
    print(result)


if __name__ == "__main__":
    main()
