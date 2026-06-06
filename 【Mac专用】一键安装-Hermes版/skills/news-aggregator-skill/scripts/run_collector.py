#!/usr/bin/env python3
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from fetch_news import fetch_hackernews, fetch_github, fetch_huggingface_papers, fetch_ai_newsletters
import json

# 收集各信源资讯
all_news = []

# 1. Hacker News
print("正在获取 Hacker News...")
hn_news = fetch_hackernews(limit=8, keyword="AI,LLM,Agent,OpenClaw,Claude,GPT")
all_news.extend(hn_news)
print(f"  获取到 {len(hn_news)} 条")

# 2. GitHub Trending
print("正在获取 GitHub Trending...")
gh_news = fetch_github(limit=5, keyword="AI")
all_news.extend(gh_news)
print(f"  获取到 {len(gh_news)} 条")

# 3. HuggingFace Papers
print("正在获取 HuggingFace Papers...")
hf_news = fetch_huggingface_papers(limit=5, keyword="AI,LLM")
all_news.extend(hf_news)
print(f"  获取到 {len(hf_news)} 条")

# 4. AI Newsletters
print("正在获取 AI Newsletters...")
ai_news = fetch_ai_newsletters(limit=5, keyword="AI")
all_news.extend(ai_news)
print(f"  获取到 {len(ai_news)} 条")

print(f"\n总共获取 {len(all_news)} 条资讯")

# 保存到文件
output_file = "/tmp/ai_news.json"
with open(output_file, 'w', encoding='utf-8') as f:
    json.dump(all_news, f, ensure_ascii=False, indent=2)
print(f"\n已保存到 {output_file}")
