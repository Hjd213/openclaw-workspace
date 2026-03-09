# MEMORY.md - 长期记忆

> 📅 创建时间：2026-03-09  
> 🔄 最后更新：2026-03-09  
> 📝 说明：这是 curated 长期记忆，包含重要决定、偏好、经验。每日记忆在 `memory/YYYY-MM-DD.md`

---

## 👤 用户信息

**姓名**：黄健东 (Huang Jiandong)  
**称呼**：黄先生 / hjd / 任意称呼  
**时区**：Asia/Shanghai (中国)  
**身份**：计算机专业（网络空间安全）大学生  
**设备**：Windows 11 + 华为鸿蒙系统  

**兴趣方向**：
- 对 AI 非常感兴趣
- 专业兴趣一般（网络空间安全）
- 喜欢做桌面自动化实验

**使用场景**：
- 学习 AI 相关知识
- 待办事项管理
- AI 画图、文本润色
- 自动化脚本实验

---

## 💬 交流偏好

**说话风格**：
- ✅ 随意、直接、不废话
- ❌ 不要"您好，请问有什么可以帮助您的吗"这种客套话
- ✅ 可以开玩笑，但别过度
- ✅ 专业问题时认真，闲聊时随意

**称呼 AI**：Claw、小助手、任意称呼都可以

**群聊行为准则**：
- 被@或问问题时再回复
- 不要每条消息都插话
- 可以用表情反应代替文字回复

---

## 🛠️ 已配置服务

### ✅ 正常工作的服务

| 服务 | 状态 | 用途 |
|------|------|------|
| **GitHub** | ✅ 已认证 | 账号 Hjd213，自动备份 workspace |
| **Obsidian** | ✅ 已配置 | 笔记库 `D:\Obsidian-OpenClaw\OpenClaw` |
| **Todoist** | ✅ 已配置 | 待办事项管理 |
| **Gemini API** | ✅ 已配置 | Summarize + AI 画图 |
| **FFmpeg** | ✅ 已安装 | 视频帧提取 |
| **Whisper** | ✅ 已安装 | 本地语音转文字 |

### ⚠️ 注意事项

- **消息渠道**：目前只用 WebChat（浏览器界面）
- **Discord**：曾尝试配置，后放弃
- **Telegram**：需要 ¥7.25/周 Premium 才能收验证码，暂时不用
- **WhatsApp**：无海外手机号，无法使用

---

## 📁 重要文件位置

```
C:\Users\bljd5\.openclaw\workspace\    # OpenClaw 工作区
├── SOUL.md                            # AI 性格定义
├── USER.md                            # 用户信息
├── AGENTS.md                          # 行为准则
├── HEARTBEAT.md                       # 定时任务清单
├── memory/                            # 每日记忆
└── OpenClaw 使用指南 - 黄健东版.md    # 使用指南（可分享）

D:\Obsidian-OpenClaw\OpenClaw\         # Obsidian 笔记库
```

---

## 📋 已安装技能

**核心技能**：
- `summarize` - 总结文章/视频/播客
- `video-frames` - 视频提取帧/片段
- `openai-whisper` - 本地语音转文字
- `nano-pdf` - PDF 编辑
- `github` - GitHub 操作
- `weather` - 天气查询
- `healthcheck` - 安全审计

**待安装/探索**：
- 桌面自动化（pyautogui 已装）
- AI 画图（Gemini 可用）
- 文本润色（Humanizer 技能）

---

## 🎯 重要决定

### 2026-03-08
- **GitHub 备份**：将所有配置和"躯体"备份到 GitHub，防止设备更换或丢失
- **仓库**：https://github.com/Hjd213/openclaw-workspace
- **Discord 放弃**：决定不用 Discord 了，继续用 WebChat

### 2026-03-07
- **浏览器集成**：使用 Chrome + OpenClaw Browser Relay 扩展
- **渠道选择**：暂时只用 WebChat，不配置其他消息渠道

### 2026-03-04
- **CS2 自瞄脚本**：开发了基于模板匹配的自动打靶程序
- **脚本位置**：`C:\Users\bljd5\.openclaw\workspace\cs-aimbot-v2.py`

---

## 📌 使用原则

**安全第一**：
- 私人信息不发群里（MEMORY.md 只在私聊时读取）
- 敏感配置（API Key）放在 TOOLS.md
- 外部操作（邮件、推文）需要先确认
- 删除文件用 `trash` 而非 `rm`

**记忆管理**：
- 📝 写下来 > 记在脑子里
- 每日记录自动创建在 `memory/YYYY-MM-DD.md`
- 重要信息提炼到 MEMORY.md
- 定期回顾整理（每天自动执行）

**主动性**：
- 每天 2-3 次心跳检查
- 有重要事情主动提醒
- 但不要在群聊里刷存在感

---

## 🔧 自动化任务

### 心跳检查（每天 2-3 次）
- ✅ 检查 workspace 更改
- ✅ 自动 git commit + push
- ✅ 推送成功/失败都通知

### Cron 定时任务
- ✅ AI 资讯晨报（每天 8:00）
- ✅ 记忆整理（每天 20:30）← 刚添加

---

## 📞 资源链接

- **GitHub 仓库**：https://github.com/Hjd213/openclaw-workspace
- **Obsidian 笔记库**：`D:\Obsidian-OpenClaw\OpenClaw`
- **官方文档**：https://docs.openclaw.ai
- **Discord 社区**：https://discord.com/invite/clawd
- **技能市场**：https://clawhub.com

---

## 🚧 待办/探索

- [ ] 尝试更多自动化场景
- [ ] 探索 AI 画图功能
- [ ] 可能需要配置 Perplexity API Key（用于更全面的资讯搜索）
- [ ] 考虑是否需要连接更多服务（日历、邮件等）

---

*此文件由 AI 每天自动整理更新，保留重要信息，删除过时内容。*
*有问题随时问，我会根据你的反馈调整。*
