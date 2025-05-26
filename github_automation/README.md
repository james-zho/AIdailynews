# GitHub Actions自动化部署指南

## 项目概述

这个项目是一个AI新闻订阅工具，使用GitHub Actions实现每日自动更新。工具会自动抓取前一天的AI新闻，进行验证、去重和过滤，然后更新网站内容并自动部署。

## 自动化工作流程

1. **定时触发**：每天凌晨3点（UTC时间）自动运行
2. **新闻抓取**：从多个来源获取最新AI新闻
3. **数据处理**：验证、去重、过滤，只保留前一天的新闻
4. **网站构建**：自动构建最新版本的网站
5. **自动部署**：将更新后的网站部署到GitHub Pages

## 设置步骤

### 1. 创建GitHub仓库

1. 登录您的GitHub账户
2. 创建一个新的公开仓库（例如：`ai-news-daily`）
3. 初始化仓库时不要添加README或其他文件

### 2. 上传项目文件

将以下文件和目录上传到您的GitHub仓库：

```
ai-news-app/         # 前端应用目录
dist/                # 构建后的网站文件
github_automation/   # 自动化脚本目录
news_data.json       # 新闻数据文件
README.md            # 项目说明文件
```

### 3. 设置GitHub Actions

1. 在仓库中创建`.github/workflows`目录
2. 将`github_automation/workflow.yml`文件复制到`.github/workflows/daily-update.yml`

### 4. 启用GitHub Pages

1. 进入仓库设置 -> Pages
2. 将部署来源设置为"GitHub Actions"

## 使用说明

### 自动更新

系统会每天自动更新，无需手动干预。

### 手动触发更新

如果需要立即更新：

1. 进入仓库的"Actions"标签页
2. 选择"Daily AI News Update"工作流
3. 点击"Run workflow"按钮
4. 确认运行

### 查看更新日志

1. 进入仓库的"Actions"标签页
2. 点击最近的工作流运行记录
3. 展开任务详情查看日志

## 自定义和维护

### 修改更新频率

编辑`.github/workflows/daily-update.yml`文件中的cron表达式：

```yaml
schedule:
  - cron: '0 3 * * *'  # 每天凌晨3点（UTC）
```

### 添加新的新闻来源

编辑`github_automation/fetch_news.sh`文件，添加新的抓取逻辑。

### 调整过滤规则

编辑`github_automation/update_news.js`文件中的`filterByDate`函数。

## 故障排除

### 工作流失败

1. 检查Actions日志了解具体错误
2. 常见问题：
   - 网络连接问题
   - 新闻源网站结构变化
   - 依赖包版本冲突

### 手动恢复

如果自动更新失败，您可以：

1. 克隆仓库到本地
2. 手动更新`news_data.json`
3. 提交并推送更改

## 注意事项

- GitHub Actions有使用限制，免费账户每月有2000分钟的限额
- 确保仓库保持公开状态，否则会消耗私有仓库的分钟数
- 定期检查工作流运行状态，确保自动化正常工作
