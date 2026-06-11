#!/usr/bin/env python3
"""
Bento Grid 等级分层图使用示例

本文件展示如何使用 CozeImageGenerator 创建各种领域的等级分层信息图。
"""

import sys
sys.path.append('..')

from quick_start import CozeImageGenerator


def main():
    """示例：创建各种 Bento Grid 等级分层图"""
    
    # 初始化
    TOKEN = "your_token_here"
    WORKFLOW_ID = "your_workflow_id_here"
    
    gen = CozeImageGenerator(TOKEN, WORKFLOW_ID)
    
    print("=" * 70)
    print("Bento Grid 等级分层图生成示例")
    print("=" * 70)
    
    # ============================================================
    # 示例 1: 简单模式 - 只提供主题
    # ============================================================
    print("\n【示例1】简单模式 - 只提供主题")
    print("-" * 70)
    
    result = gen.generate_bento_tier_chart("2024年热门智能手机")
    print(result)
    
    # ============================================================
    # 示例 2: 完全自定义 - 提供所有层级内容
    # ============================================================
    print("\n【示例2】完全自定义 - 代码编辑器评级")
    print("-" * 70)
    
    tiers = {
        "tier_1": ["VS Code（统治级）"],
        "tier_2": ["JetBrains全家桶", "Neovim"],
        "tier_3": ["Sublime Text", "Vim", "Emacs"],
        "tier_4": ["Atom（已停更）", "Brackets", "记事本++"],
        "tier_5": ["记事本写代码", "Word写代码"]
    }
    
    result = gen.generate_bento_tier_chart("程序员代码编辑器", tiers)
    print(result)
    
    # ============================================================
    # 示例 3: 无糖茶饮料品牌
    # ============================================================
    print("\n【示例3】无糖茶饮料品牌评级")
    print("-" * 70)
    
    tiers = {
        "tier_1": ["东方树叶（统治级）", "三得利乌龙茶"],
        "tier_2": ["元气森林燃茶", "农夫山泉绿茶"],
        "tier_3": ["康师傅无糖冰红茶", "统一无糖绿茶"],
        "tier_4": ["便利店自有品牌", "小众牌子"],
        "tier_5": ["难喝网红品牌", "假无糖"]
    }
    
    result = gen.generate_bento_tier_chart("无糖茶饮料品牌", tiers)
    print(result)
    
    # ============================================================
    # 示例 4: 漫威电影
    # ============================================================
    print("\n【示例4】近十年漫威电影评级")
    print("-" * 70)
    
    tiers = {
        "tier_1": ["《复仇者联盟4：终局之战》", "《蜘蛛侠：平行宇宙》"],
        "tier_2": ["《银河护卫队3》", "《雷神3：诸神黄昏》"],
        "tier_3": ["《美国队长3》", "《奇异博士》"],
        "tier_4": ["《雷神4》", "《蚁人2》"],
        "tier_5": ["《永恒族》", "《惊奇队长2》"]
    }
    
    result = gen.generate_bento_tier_chart("近十年漫威电影", tiers)
    print(result)
    
    # ============================================================
    # 示例 5: 前端框架
    # ============================================================
    print("\n【示例5】前端框架评级")
    print("-" * 70)
    
    tiers = {
        "tier_1": ["React（统治级）"],
        "tier_2": ["Vue 3", "Svelte"],
        "tier_3": ["Angular", "Solid.js"],
        "tier_4": ["jQuery", "Backbone.js"],
        "tier_5": ["原生JS写大项目", "Flash"]
    }
    
    result = gen.generate_bento_tier_chart("前端框架", tiers)
    print(result)
    
    # ============================================================
    # 示例 6: AI编程助手
    # ============================================================
    print("\n【示例6】AI编程助手评级")
    print("-" * 70)
    
    tiers = {
        "tier_1": ["Cursor", "Claude"],
        "tier_2": ["GitHub Copilot", "GPT-4"],
        "tier_3": ["Codeium", "Tabnine"],
        "tier_4": ["Amazon CodeWhisperer", "各种套壳GPT"],
        "tier_5": ["只会说'我建议你谷歌一下'的助手", "过时GPT-3"]
    }
    
    result = gen.generate_bento_tier_chart("AI编程助手", tiers)
    print(result)
    
    # ============================================================
    # 示例 7: 游戏主机
    # ============================================================
    print("\n【示例7】游戏主机评级")
    print("-" * 70)
    
    tiers = {
        "tier_1": ["Steam Deck（版本答案）"],
        "tier_2": ["PS5", "Nintendo Switch OLED"],
        "tier_3": ["Xbox Series X", "ROG Ally"],
        "tier_4": ["PS4（上一代）", "Switch Lite"],
        "tier_5": ["各种山寨掌机", "云游戏盒子"]
    }
    
    result = gen.generate_bento_tier_chart("游戏主机", tiers)
    print(result)
    
    # ============================================================
    # 示例 8: 编程语言
    # ============================================================
    print("\n【示例8】编程语言热度评级")
    print("-" * 70)
    
    tiers = {
        "tier_1": ["Python（统治级）"],
        "tier_2": ["JavaScript/TypeScript", "Rust"],
        "tier_3": ["Go", "Java", "C++"],
        "tier_4": ["PHP", "Ruby", "Objective-C"],
        "tier_5": ["COBOL", "Fortran", "VB6"]
    }
    
    result = gen.generate_bento_tier_chart("编程语言热度", tiers)
    print(result)
    
    print("\n" + "=" * 70)
    print("✅ 所有示例完成！")
    print("=" * 70)


if __name__ == "__main__":
    main()
