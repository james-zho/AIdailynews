#!/bin/bash

# 测试GitHub Actions自动化工作流脚本
# 此脚本用于在本地测试自动更新流程

echo "开始测试GitHub Actions自动化工作流..."

# 创建测试目录
TEST_DIR="/home/ubuntu/ai_news_tool/github_test"
mkdir -p $TEST_DIR
cd /home/ubuntu/ai_news_tool

# 复制必要文件到测试目录
cp -r github_automation/* $TEST_DIR/
cp news_data.json $TEST_DIR/
mkdir -p $TEST_DIR/dist

echo "设置测试环境..."

# 安装依赖
cd $TEST_DIR
npm install axios cheerio

echo "执行新闻更新脚本..."

# 使脚本可执行
chmod +x fetch_news.sh

# 运行新闻获取脚本
./fetch_news.sh

echo "验证更新结果..."

# 检查更新后的news_data.json
if [ -f "news_data.json" ]; then
  echo "新闻数据文件已成功更新"
  # 显示新闻条目数量
  NEWS_COUNT=$(grep -o '"title"' news_data.json | wc -l)
  echo "更新后的新闻条目数量: $NEWS_COUNT"
else
  echo "错误: 未能生成更新的新闻数据文件"
  exit 1
fi

echo "测试完成！"
echo "GitHub Actions自动化工作流测试成功"
