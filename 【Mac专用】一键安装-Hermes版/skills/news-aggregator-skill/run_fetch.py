#!/usr/bin/env python3
import sys
import os
import json
from pathlib import Path

# 设置路径
script_dir = Path(__file__).parent
scripts_dir = script_dir / 'scripts'

# 添加scripts到路径
sys.path.insert(0, str(scripts_dir))
os.chdir(scripts_dir)

# 加载依赖
exec(compile(open('rss_parser.py').read(), 'rss_parser.py', 'exec'))

# 获取函数
ns = {}
exec(compile(open('fetch_news.py').read(), 'fetch_news.py', 'exec'), ns)

# 定义获取数据的函数
def get_news(source, keywords, limit=10):
    try:
        if source == 'hackernews':
            result = ns['fetch_hackernews'](limit=limit, keyword=keywords)
        elif source == 'github':
            result = ns['fetch_github'](limit=limit, keyword=keywords)
        elif source == 'huggingface':
            result = ns['fetch_huggingface_papers'](limit=limit, keyword=keywords)
        elif source == 'ai_newsletters':
            result = ns['fetch_ai_newsletters'](limit=limit, keyword=keywords)
        return result
    except Exception as e:
        print(f"Error fetching {source}: {e}")
        import traceback
        traceback.print_exc()
        return []

keywords = "AI,LLM,Agent,OpenClaw,Claude,GPT"

print("正在获取 Hacker News...")
hn_news = get_news('hackernews', keywords, 10)
print(f"Hacker News: {len(hn_news)} 条")

print("正在获取 GitHub Trending...")
gh_news = get_news('github', keywords, 10)
print(f"GitHub: {len(gh_news)} 条")

print("正在获取 HuggingFace Papers...")
hf_news = get_news('huggingface', keywords, 10)
print(f"HuggingFace: {len(hf_news)} 条")

print("正在获取 AI Newsletters...")
nl_news = get_news('ai_newsletters', keywords, 10)
print(f"AI Newsletters: {len(nl_news)} 条")

# 合并所有结果
all_news = hn_news + gh_news + hf_news + nl_news

# 保存为JSON
output = {
    "fetch_time": "2026-04-30",
    "total": len(all_news),
    "news": all_news
}

os.chdir(script_dir)
with open('data/today_news.json', 'w', encoding='utf-8') as f:
    json.dump(output, f, ensure_ascii=False, indent=2)

print(f"\n总共获取 {len(all_news)} 条新闻，已保存到 data/today_news.json")
