#!/usr/bin/env node

/**
 * AI新闻自动更新脚本
 * 用于GitHub Actions自动化工作流
 * 功能：抓取最新AI新闻，验证、去重、过滤，并更新news_data.json
 */

const fs = require('fs');
const path = require('path');
const https = require('https');
const { execSync } = require('child_process');

// 配置
const NEWS_DATA_PATH = path.join(__dirname, '..', 'news_data.json');
const SOURCES = [
  { name: 'ScienceDaily AI', url: 'https://www.sciencedaily.com/news/computers_math/artificial_intelligence/' },
  { name: 'The Guardian AI', url: 'https://www.theguardian.com/technology/artificialintelligenceai' },
  { name: 'TechCrunch AI', url: 'https://techcrunch.com/category/artificial-intelligence/' },
  { name: '新浪AI', url: 'https://news.sina.com.cn/zt_d/intelligence' }
];

// 主函数
async function main() {
  try {
    console.log('开始AI新闻自动更新流程...');
    
    // 1. 获取昨天的日期
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    const yesterdayStr = yesterday.toISOString().split('T')[0]; // 格式：YYYY-MM-DD
    console.log(`目标日期: ${yesterdayStr}`);
    
    // 2. 读取现有新闻数据
    let newsData;
    try {
      const rawData = fs.readFileSync(NEWS_DATA_PATH, 'utf8');
      newsData = JSON.parse(rawData);
      console.log(`成功读取现有新闻数据，共 ${newsData.news.length} 条新闻`);
    } catch (error) {
      console.log('无法读取现有新闻数据，将创建新的数据结构');
      newsData = {
        last_updated: new Date().toISOString().split('T')[0],
        news: []
      };
    }
    
    // 3. 抓取新闻
    console.log('开始抓取新闻...');
    const newArticles = await fetchLatestNews(yesterdayStr);
    console.log(`抓取到 ${newArticles.length} 条新闻`);
    
    // 4. 合并新闻并去重
    const mergedNews = mergeAndDeduplicate(newsData.news, newArticles);
    console.log(`合并后共有 ${mergedNews.length} 条新闻`);
    
    // 5. 过滤并保留昨天的新闻
    const filteredNews = filterByDate(mergedNews, yesterdayStr);
    console.log(`过滤后保留 ${filteredNews.length} 条昨天的新闻`);
    
    // 6. 更新新闻数据
    newsData.last_updated = new Date().toISOString().split('T')[0];
    newsData.news = filteredNews;
    
    // 7. 保存更新后的数据
    fs.writeFileSync(NEWS_DATA_PATH, JSON.stringify(newsData, null, 2), 'utf8');
    console.log('新闻数据已成功更新');
    
    // 8. 复制到前端目录
    const frontendDataPath = path.join(__dirname, '..', 'dist', 'news_data.json');
    fs.writeFileSync(frontendDataPath, JSON.stringify(newsData, null, 2), 'utf8');
    console.log('新闻数据已复制到前端目录');
    
    console.log('AI新闻自动更新流程完成');
    return true;
  } catch (error) {
    console.error('自动更新过程中发生错误:', error);
    process.exit(1);
  }
}

// 抓取最新新闻
async function fetchLatestNews(targetDate) {
  // 这里使用模拟数据，实际部署时应替换为真实的网络请求和解析逻辑
  console.log('注意: 当前使用模拟数据，实际部署时需替换为真实抓取逻辑');
  
  // 模拟抓取延迟
  await new Promise(resolve => setTimeout(resolve, 2000));
  
  // 返回模拟的新闻数据
  return [
    {
      title: "最新AI大模型突破性能基准测试",
      summary: "研究人员发布了新一代AI大模型，在多项基准测试中超越了现有模型。该模型在自然语言理解、多模态任务和推理能力方面都取得了显著进步。",
      date: targetDate,
      source: "AI研究前沿",
      url: "https://example.com/ai-model-breakthrough"
    },
    {
      title: "AI辅助药物研发取得新进展",
      summary: "科学家利用人工智能技术成功预测了一种新型抗生素的分子结构，有望解决细菌耐药性问题。这一突破展示了AI在加速药物发现过程中的巨大潜力。",
      date: targetDate,
      source: "医药科技报道",
      url: "https://example.com/ai-drug-discovery"
    },
    {
      title: "全球AI伦理委员会发布新指南",
      summary: "国际AI伦理委员会发布了最新版人工智能发展伦理指南，强调透明度、公平性和隐私保护。该指南将为各国制定AI监管政策提供重要参考。",
      date: targetDate,
      source: "科技政策观察",
      url: "https://example.com/ai-ethics-guidelines"
    }
  ];
}

// 合并新闻并去重
function mergeAndDeduplicate(existingNews, newNews) {
  const allNews = [...existingNews, ...newNews];
  const uniqueNews = [];
  const seenTitles = new Set();
  
  for (const item of allNews) {
    // 检查数据完整性
    if (!item.title || !item.summary || !item.date || !item.source || !item.url) {
      console.warn('跳过不完整的新闻条目:', item);
      continue;
    }
    
    // 检查唯一性
    if (seenTitles.has(item.title)) {
      console.warn('跳过重复的新闻条目:', item.title);
      continue;
    }
    
    seenTitles.add(item.title);
    uniqueNews.push(item);
  }
  
  return uniqueNews;
}

// 按日期过滤新闻
function filterByDate(news, targetDate) {
  return news.filter(item => {
    const itemDate = new Date(item.date);
    const itemDateStr = itemDate.toISOString().split('T')[0];
    return itemDateStr === targetDate;
  });
}

// 执行主函数
main().catch(error => {
  console.error('程序执行失败:', error);
  process.exit(1);
});
