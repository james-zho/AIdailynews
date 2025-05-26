#!/bin/bash

# 实际抓取AI新闻的脚本
# 此脚本将被GitHub Actions调用，用于获取最新AI新闻

# 安装必要的依赖
npm install axios cheerio

# 设置日期
YESTERDAY=$(date -d "yesterday" +%Y-%m-%d)
echo "正在获取 $YESTERDAY 的AI新闻..."

# 创建临时目录存放抓取结果
mkdir -p temp_news

# 抓取多个来源的AI新闻
echo "抓取ScienceDaily AI新闻..."
node -e "
const axios = require('axios');
const cheerio = require('cheerio');
const fs = require('fs');

async function scrapeScience() {
  try {
    const response = await axios.get('https://www.sciencedaily.com/news/computers_math/artificial_intelligence/');
    const $ = cheerio.load(response.data);
    const news = [];
    
    $('.latest-head').each((i, element) => {
      const titleElement = $(element).find('a');
      const title = titleElement.text().trim();
      const url = 'https://www.sciencedaily.com' + titleElement.attr('href');
      
      const summaryElement = $(element).next('.latest-summary');
      const summary = summaryElement.text().trim();
      
      const dateElement = $(element).next('.latest-summary').next('.latest-date');
      const dateText = dateElement.text().trim();
      
      // 转换日期格式
      const date = '$YESTERDAY'; // 使用昨天的日期
      
      news.push({
        title,
        summary,
        date,
        source: 'ScienceDaily',
        url
      });
    });
    
    fs.writeFileSync('temp_news/sciencedaily.json', JSON.stringify(news, null, 2));
    console.log(\`成功抓取 \${news.length} 条ScienceDaily新闻\`);
  } catch (error) {
    console.error('抓取ScienceDaily失败:', error);
  }
}

scrapeScience();
"

echo "抓取TechCrunch AI新闻..."
node -e "
const axios = require('axios');
const cheerio = require('cheerio');
const fs = require('fs');

async function scrapeTechCrunch() {
  try {
    const response = await axios.get('https://techcrunch.com/category/artificial-intelligence/');
    const $ = cheerio.load(response.data);
    const news = [];
    
    $('.post-block').each((i, element) => {
      const titleElement = $(element).find('.post-block__title a');
      const title = titleElement.text().trim();
      const url = titleElement.attr('href');
      
      const summaryElement = $(element).find('.post-block__content');
      const summary = summaryElement.text().trim();
      
      // 使用昨天的日期
      const date = '$YESTERDAY';
      
      news.push({
        title,
        summary,
        date,
        source: 'TechCrunch',
        url
      });
    });
    
    fs.writeFileSync('temp_news/techcrunch.json', JSON.stringify(news, null, 2));
    console.log(\`成功抓取 \${news.length} 条TechCrunch新闻\`);
  } catch (error) {
    console.error('抓取TechCrunch失败:', error);
  }
}

scrapeTechCrunch();
"

echo "抓取The Guardian AI新闻..."
node -e "
const axios = require('axios');
const cheerio = require('cheerio');
const fs = require('fs');

async function scrapeGuardian() {
  try {
    const response = await axios.get('https://www.theguardian.com/technology/artificialintelligenceai');
    const $ = cheerio.load(response.data);
    const news = [];
    
    $('.fc-item').each((i, element) => {
      const titleElement = $(element).find('.fc-item__title');
      const title = titleElement.text().trim();
      const url = titleElement.find('a').attr('href');
      
      // Guardian不总是有摘要，所以我们使用标题作为备用
      let summary = $(element).find('.fc-item__standfirst').text().trim();
      if (!summary) {
        summary = title + '。点击阅读更多关于这个AI话题的详细信息。';
      }
      
      // 使用昨天的日期
      const date = '$YESTERDAY';
      
      news.push({
        title,
        summary,
        date,
        source: 'The Guardian',
        url
      });
    });
    
    fs.writeFileSync('temp_news/guardian.json', JSON.stringify(news, null, 2));
    console.log(\`成功抓取 \${news.length} 条Guardian新闻\`);
  } catch (error) {
    console.error('抓取Guardian失败:', error);
  }
}

scrapeGuardian();
"

# 合并所有新闻源
echo "合并所有新闻源..."
node -e "
const fs = require('fs');
const path = require('path');

// 读取现有的新闻数据
let existingData = {};
try {
  const existingContent = fs.readFileSync('news_data.json', 'utf8');
  existingData = JSON.parse(existingContent);
} catch (error) {
  console.log('无法读取现有新闻数据，将创建新的数据结构');
  existingData = {
    last_updated: new Date().toISOString().split('T')[0],
    news: []
  };
}

// 读取所有临时新闻文件
const tempDir = 'temp_news';
const newsFiles = fs.readdirSync(tempDir).filter(file => file.endsWith('.json'));

let allNews = [...existingData.news];
let newArticlesCount = 0;

// 合并所有新闻
for (const file of newsFiles) {
  try {
    const content = fs.readFileSync(path.join(tempDir, file), 'utf8');
    const newsSource = JSON.parse(content);
    newArticlesCount += newsSource.length;
    allNews = [...allNews, ...newsSource];
  } catch (error) {
    console.error(\`处理文件 \${file} 时出错:\`, error);
  }
}

// 去重
const uniqueNews = [];
const seenTitles = new Set();

for (const item of allNews) {
  // 检查数据完整性
  if (!item.title || !item.summary || !item.date || !item.source || !item.url) {
    console.warn('跳过不完整的新闻条目');
    continue;
  }
  
  // 检查唯一性
  if (seenTitles.has(item.title)) {
    console.warn(\`跳过重复的新闻条目: \${item.title}\`);
    continue;
  }
  
  seenTitles.add(item.title);
  uniqueNews.push(item);
}

// 按日期过滤，只保留昨天的新闻
const yesterday = '$YESTERDAY';
const filteredNews = uniqueNews.filter(item => {
  return item.date === yesterday;
});

// 更新新闻数据
const updatedData = {
  last_updated: new Date().toISOString().split('T')[0],
  news: filteredNews
};

// 保存更新后的数据
fs.writeFileSync('news_data.json', JSON.stringify(updatedData, null, 2), 'utf8');
console.log(\`成功合并 \${newArticlesCount} 条新闻，去重和过滤后保留 \${filteredNews.length} 条\`);

// 清理临时文件
fs.rmSync(tempDir, { recursive: true, force: true });
"

echo "AI新闻更新完成！"
