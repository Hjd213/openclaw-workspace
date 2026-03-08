# OpenClaw 进阶配置指南

> 🔥 让你的 AI 助手更强大  
> 📅 最后更新：2026-03-04  
> ⏱️ 预计配置时间：30-60 分钟

---

## 📖 目录

1. [技能系统](#技能系统) - 让 AI 能执行具体任务
2. [记忆系统](#记忆系统) - 让 AI 记住你的偏好
3. [消息渠道](#消息渠道) - 随时随地聊天
4. [定时任务](#定时任务) - 自动化执行
5. [子代理系统](#子代理系统) - 多任务处理
6. [浏览器自动化](#浏览器自动化) - 网页操作
7. [文件系统](#文件系统) - 文件管理
8. [API 服务](#api-服务) - 对外提供服务
9. [完整配置模板](#完整配置模板)

---

## 🛠️ 技能系统

### 什么是技能？

技能是 OpenClaw 的"App"，让 AI 能执行具体任务（查天气、安全检查、文件处理等）。

### 可用技能列表

| 技能名 | 功能 | 使用场景 | 推荐度 |
|--------|------|----------|--------|
| `weather` | 天气预报 | 问天气自动回复 | ⭐⭐⭐⭐⭐ |
| `healthcheck` | 系统安全巡检 | 定期检查服务器 | ⭐⭐⭐⭐⭐ |
| `skill-creator` | 创建技能 | 开发自定义功能 | ⭐⭐⭐⭐ |
| `web-search` | 网络搜索 | 查资料、搜信息 | ⭐⭐⭐⭐⭐ |
| `calendar` | 日历管理 | 会议提醒、日程 | ⭐⭐⭐⭐ |
| `email` | 邮件处理 | 收发邮件 | ⭐⭐⭐ |
| `file-manager` | 文件管理 | 整理、搜索文件 | ⭐⭐⭐⭐ |
| `code-runner` | 代码执行 | 运行 Python/JS | ⭐⭐⭐⭐ |
| `image-gen` | 图片生成 | AI 绘画 | ⭐⭐⭐ |
| `voice-chat` | 语音对话 | 语音输入输出 | ⭐⭐⭐ |

> 💡 技能会持续更新，查看最新技能：https://clawhub.com

### 查看已安装技能

```bash
openclaw skills list
```

### 启用技能

```bash
# 启用天气技能
openclaw skills enable weather

# 启用健康检查
openclaw skills enable healthcheck

# 启用多个技能
openclaw skills enable weather healthcheck web-search
```

### 禁用技能

```bash
openclaw skills disable weather
```

### 技能配置示例

编辑 `~/.openclaw/openclaw.json`：

```json
{
  "skills": {
    "enabled": true,
    "autoEnable": ["weather", "healthcheck"],
    "configs": {
      "weather": {
        "defaultLocation": "北京",
        "unit": "celsius"
      },
      "healthcheck": {
        "schedule": "weekly",
        "notifyChannel": "telegram"
      }
    }
  }
}
```

### 使用示例

```
用户：今天北京天气怎么样？
AI: [自动调用 weather 技能] 北京今天晴，最高 25°C...

用户：检查一下系统安全
AI: [自动调用 healthcheck 技能] 正在扫描...发现 1 个警告...
```

---

## 🧠 记忆系统

### 作用

让 AI 记住：
- 你的名字、喜好、习惯
- 之前讨论过的事情
- 项目进度、待办事项
- 重要决策和上下文

### 配置方法

编辑 `~/.openclaw/openclaw.json`：

```json
{
  "memory": {
    "enabled": true,
    "type": "local",
    "path": "~/.openclaw/memory",
    "maxSize": 1000,
    "retention": {
      "shortTerm": 7,
      "longTerm": 90
    },
    "autoSave": true,
    "autoLoad": true
  }
}
```

### 配置项说明

| 参数 | 说明 | 推荐值 |
|------|------|--------|
| `enabled` | 是否启用 | true |
| `type` | 存储类型 | local（本地）/ redis |
| `path` | 存储路径 | ~/.openclaw/memory |
| `maxSize` | 最大记忆数 | 1000 |
| `retention.shortTerm` | 短期记忆天数 | 7 |
| `retention.longTerm` | 长期记忆天数 | 90 |
| `autoSave` | 自动保存 | true |
| `autoLoad` | 自动加载 | true |

### 使用示例

```
用户：我叫黄先生，喜欢随意的聊天风格
AI: 好的，我记住了！

[几天后...]

用户：你还记得我叫什么吗？
AI: 当然，你是黄先生，喜欢随意的聊天风格 🐾
```

### 管理记忆

```bash
# 查看记忆
openclaw memory list

# 搜索记忆
openclaw memory search "项目名称"

# 清除记忆
openclaw memory clear

# 导出记忆
openclaw memory export > backup.json
```

---

## 📱 消息渠道

### 支持的渠道

| 渠道 | 难度 | 适用场景 | 费用 |
|------|------|----------|------|
| 企业微信 | ⭐⭐ | 工作、团队 | 免费 |
| Telegram | ⭐⭐ | 个人使用 | 免费 |
| Discord | ⭐⭐ | 社区、团队 | 免费 |
| 微信个人号 | ⭐⭐⭐ | 最方便 | 免费 |
| 微信公众号 | ⭐⭐⭐⭐ | 对外服务 | 免费 |
| Slack | ⭐⭐ | 外企、团队 | 免费 |
| WhatsApp | ⭐⭐⭐ | 国际用户 | 免费 |
| 钉钉 | ⭐⭐ | 国内企业 | 免费 |

---

### 方案一：Telegram（推荐个人使用）

#### 1. 创建 Bot

1. 打开 Telegram，搜索 `@BotFather`
2. 发送 `/newbot`
3. 按提示输入 Bot 名称和用户名
4. 获取 Token（格式：`123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11`）

#### 2. 获取 Chat ID

1. 搜索 `@userinfobot`
2. 发送任意消息
3. 获取你的 Chat ID

#### 3. 配置 OpenClaw

编辑 `~/.openclaw/openclaw.json`：

```json
{
  "channels": {
    "telegram": {
      "enabled": true,
      "botToken": "你的 Bot Token",
      "allowedUsers": ["你的 Chat ID"],
      "replyToGroup": false,
      "prefix": ""
    }
  }
}
```

#### 4. 重启并测试

```bash
openclaw gateway restart
```

给 Bot 发消息测试。

---

### 方案二：企业微信（推荐工作使用）

#### 1. 注册企业微信

- 访问 https://work.weixin.qq.com
- 免费注册（个人也可以）

#### 2. 创建应用

1. 登录管理后台
2. 应用管理 → 创建应用
3. 记录 `CorpID`、`AgentId`、`Secret`

#### 3. 配置回调

1. 应用 → 接收消息服务器配置
2. URL: `http://你的 IP:端口/wecom`
3. Token: 自定义
4. EncodingAESKey: 点击生成

#### 4. 配置 OpenClaw

```json
{
  "channels": {
    "wecom": {
      "enabled": true,
      "corpId": "你的 CorpID",
      "agentId": "应用 ID",
      "secret": "你的 Secret",
      "token": "上面设置的 Token",
      "encodingAesKey": "上面生成的 Key"
    }
  }
}
```

#### 5. 重启测试

```bash
openclaw gateway restart
```

---

### 方案三：Discord（推荐团队使用）

#### 1. 创建 Discord 应用

1. 访问 https://discord.com/developers/applications
2. 创建新应用
3. Bot → 添加 Bot
4. 复制 Bot Token

#### 2. 邀请 Bot 到服务器

1. OAuth2 → URL Generator
2. 选择 scopes: `bot`
3. 选择权限：`Send Messages`, `Read Messages`
4. 复制生成的链接，在浏览器打开

#### 3. 配置 OpenClaw

```json
{
  "channels": {
    "discord": {
      "enabled": true,
      "botToken": "你的 Bot Token",
      "guildId": "服务器 ID",
      "channelId": "频道 ID（可选）"
    }
  }
}
```

---

### 方案四：微信个人号（最方便，有风险）

> ⚠️ 警告：微信个人号自动化有封号风险，建议用小号

#### 使用 WeChatFerry

1. **下载 WeChatFerry**
   - GitHub: https://github.com/lich0821/WeChatFerry

2. **安装指定版本微信**
   - 需要微信 3.9.x 版本

3. **启动服务**
   ```bash
   python wcferry.py
   ```

4. **配置 OpenClaw**
   ```json
   {
     "channels": {
       "wcferry": {
         "enabled": true,
         "host": "127.0.0.1",
         "port": 10086
       }
     }
   }
   ```

---

## ⏰ 定时任务

### 作用

让 AI 自动执行周期性任务（每日天气、周报生成、安全巡检等）。

### 配置方法

编辑 `~/.openclaw/openclaw.json`：

```json
{
  "scheduler": {
    "enabled": true,
    "timezone": "Asia/Shanghai",
    "jobs": [
      {
        "name": "每日天气",
        "cron": "0 8 * * *",
        "enabled": true,
        "action": "send_message",
        "params": {
          "channel": "telegram",
          "message": "早上好！今天天气如何？"
        }
      },
      {
        "name": "周一安全巡检",
        "cron": "0 9 * * 1",
        "enabled": true,
        "action": "run_skill",
        "params": {
          "skill": "healthcheck",
          "notifyChannel": "telegram"
        }
      },
      {
        "name": "每日摘要",
        "cron": "0 20 * * *",
        "enabled": true,
        "action": "run_task",
        "params": {
          "task": "总结今天的重要消息"
        }
      }
    ]
  }
}
```

### Cron 表达式说明

```
* * * * *
│ │ │ │ │
│ │ │ │ └─ 星期 (0-6, 0=周日)
│ │ │ └─── 月份 (1-12)
│ │ └───── 日期 (1-31)
│ └─────── 小时 (0-23)
└───────── 分钟 (0-59)
```

### 常用示例

| 描述 | Cron 表达式 |
|------|------------|
| 每天早上 8 点 | `0 8 * * *` |
| 每周一 9 点 | `0 9 * * 1` |
| 每小时整点 | `0 * * * *` |
| 每 30 分钟 | `*/30 * * * *` |
| 工作日 9-18 点每小时 | `0 9-18 * * 1-5` |
| 每天中午 12 点和晚上 8 点 | `0 12,20 * * *` |

### 管理定时任务

```bash
# 查看任务列表
openclaw scheduler list

# 启用/禁用任务
openclaw scheduler toggle "每日天气"

# 立即执行任务
openclaw scheduler run "每日天气"

# 查看任务日志
openclaw scheduler logs "每日天气"
```

---

## 🤖 子代理系统

### 作用

创建多个专门的 AI 代理，每个代理有不同的职责和配置。

### 使用场景

| 代理类型 | 用途 | 推荐模型 |
|----------|------|----------|
| 主代理 | 日常对话 | qwen3.5-plus |
| 代码代理 | 编程、调试 | qwen3-coder-plus |
| 写作代理 | 写文章、文档 | qwen3.5-plus |
| 研究代理 | 查资料、分析 | qwen3-max |
| 翻译代理 | 多语言翻译 | qwen3.5-plus |

### 创建子代理

```bash
# 创建代码代理
openclaw agent spawn --label coder --model bailian/qwen3-coder-plus

# 创建写作代理
openclaw agent spawn --label writer --model bailian/qwen3.5-plus

# 创建研究代理
openclaw agent spawn --label researcher --model bailian/qwen3-max
```

### 使用子代理

```bash
# 切换到代码代理
openclaw agent use coder

# 切换到写作代理
openclaw agent use writer

# 查看代理列表
openclaw agent list

# 删除代理
openclaw agent kill coder
```

### 配置子代理

编辑 `~/.openclaw/openclaw.json`：

```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "bailian/qwen3.5-plus"
      }
    },
    "custom": {
      "coder": {
        "model": "bailian/qwen3-coder-plus",
        "systemPrompt": "你是一个专业的程序员助手，擅长编程、调试和代码审查。",
        "temperature": 0.3
      },
      "writer": {
        "model": "bailian/qwen3.5-plus",
        "systemPrompt": "你是一个专业的写作助手，擅长文章、报告和文档写作。",
        "temperature": 0.7
      }
    }
  }
}
```

---

## 🌐 浏览器自动化

### 作用

让 AI 能：
- 访问网页、获取信息
- 操作浏览器（点击、输入、截图）
- 网页自动化任务

### 配置方法

编辑 `~/.openclaw/openclaw.json`：

```json
{
  "browser": {
    "enabled": true,
    "type": "playwright",
    "headless": false,
    "timeout": 30000,
    "userAgent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
    "proxy": null
  }
}
```

### 配置项说明

| 参数 | 说明 | 推荐值 |
|------|------|--------|
| `enabled` | 是否启用 | true |
| `type` | 浏览器类型 | playwright |
| `headless` | 无头模式 | false（可见窗口） |
| `timeout` | 超时时间 | 30000ms |
| `proxy` | 代理设置 | null |

### 使用示例

```
用户：帮我查一下今天 GitHub 热榜
AI: [打开浏览器访问 GitHub] 今天的热榜第一名是...

用户：打开阿里云看看我的余额
AI: [访问阿里云控制台] 您的账户余额是...

用户：把这个网页转成 PDF
AI: [截图并生成 PDF] 已保存为 page.pdf
```

### 浏览器命令

```bash
# 打开浏览器
openclaw browser open

# 访问网页
openclaw browser navigate https://example.com

# 截图
openclaw browser screenshot

# 关闭浏览器
openclaw browser close
```

---

## 📁 文件系统

### 作用

让 AI 能帮你：
- 读取文件内容
- 创建/编辑文件
- 整理文件夹
- 搜索文件

### 配置方法

编辑 `~/.openclaw/openclaw.json`：

```json
{
  "filesystem": {
    "enabled": true,
    "workspace": "C:/Users/bljd5/.openclaw/workspace",
    "allowRead": true,
    "allowWrite": true,
    "allowDelete": false,
    "allowedPaths": [
      "C:/Users/bljd5/.openclaw/workspace",
      "C:/Users/bljd5/Documents",
      "C:/Users/bljd5/Projects"
    ],
    "blockedPaths": [
      "C:/Windows",
      "C:/Program Files"
    ],
    "maxFileSize": 10485760
  }
}
```

### 配置项说明

| 参数 | 说明 | 推荐值 |
|------|------|--------|
| `enabled` | 是否启用 | true |
| `workspace` | 工作目录 | 你的工作文件夹 |
| `allowRead` | 允许读取 | true |
| `allowWrite` | 允许写入 | true |
| `allowDelete` | 允许删除 | false（安全） |
| `allowedPaths` | 允许访问的路径 | 根据需要配置 |
| `blockedPaths` | 禁止访问的路径 | 系统目录 |
| `maxFileSize` | 最大文件大小 | 10MB |

### 使用示例

```
用户：帮我把这个文件夹整理一下
AI: [扫描文件夹并按类型分类] 已整理完成...

用户：把所有 PDF 文件移动到 Documents 目录
AI: [找到 15 个 PDF 文件并移动] 已完成...

用户：检查一下最近修改的文件
AI: [列出最近 7 天修改的文件] ...
```

---

## 🌍 API 服务

### 作用

把你的 AI 能力开放给：
- 公司同事
- 其他程序
- 第三方服务

### 配置方法

编辑 `~/.openclaw/openclaw.json`：

```json
{
  "gateway": {
    "mode": "public",
    "bind": "0.0.0.0:8080",
    "cors": {
      "enabled": true,
      "origins": ["*"]
    },
    "auth": {
      "type": "apikey",
      "keys": ["your-secret-api-key"]
    },
    "rateLimit": {
      "enabled": true,
      "requests": 100,
      "window": 60
    }
  }
}
```

### 配置项说明

| 参数 | 说明 | 推荐值 |
|------|------|--------|
| `mode` | 网关模式 | local/public |
| `bind` | 监听地址 | 0.0.0.0:8080 |
| `cors.enabled` | 允许跨域 | true |
| `auth.type` | 认证类型 | apikey |
| `rateLimit.requests` | 每分钟请求数 | 100 |

### 使用示例

```bash
# 调用 API
curl -X POST http://localhost:8080/chat \
  -H "Authorization: Bearer your-secret-api-key" \
  -H "Content-Type: application/json" \
  -d '{"message": "你好"}'
```

---

## 📦 完整配置模板

### 个人使用推荐配置

```json
{
  "models": {
    "providers": {
      "bailian": {
        "baseUrl": "https://coding.dashscope.aliyuncs.com/v1",
        "apiKey": "YOUR_API_KEY",
        "api": "openai-completions",
        "models": [
          {"id": "qwen3.5-plus", "name": "Qwen3.5 Plus", "contextWindow": 1000000},
          {"id": "qwen3-coder-next", "name": "Qwen3 Coder", "contextWindow": 262144}
        ]
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {"primary": "bailian/qwen3.5-plus"}
    }
  },
  "memory": {
    "enabled": true,
    "type": "local",
    "path": "~/.openclaw/memory",
    "maxSize": 1000,
    "autoSave": true,
    "autoLoad": true
  },
  "skills": {
    "enabled": true,
    "autoEnable": ["weather", "healthcheck", "web-search"]
  },
  "scheduler": {
    "enabled": true,
    "timezone": "Asia/Shanghai",
    "jobs": [
      {
        "name": "每日天气",
        "cron": "0 8 * * *",
        "action": "send_message",
        "params": {"channel": "telegram", "message": "早上好！"}
      }
    ]
  },
  "filesystem": {
    "enabled": true,
    "workspace": "C:/Users/bljd5/.openclaw/workspace",
    "allowRead": true,
    "allowWrite": true,
    "allowDelete": false
  },
  "browser": {
    "enabled": true,
    "headless": false
  }
}
```

### 团队使用推荐配置

```json
{
  "models": {
    "providers": {
      "bailian": {
        "baseUrl": "https://coding.dashscope.aliyuncs.com/v1",
        "apiKey": "YOUR_API_KEY",
        "api": "openai-completions"
      }
    }
  },
  "gateway": {
    "mode": "public",
    "bind": "0.0.0.0:8080",
    "auth": {
      "type": "apikey",
      "keys": ["team-api-key"]
    }
  },
  "channels": {
    "wecom": {
      "enabled": true,
      "corpId": "YOUR_CORP_ID",
      "agentId": "YOUR_AGENT_ID",
      "secret": "YOUR_SECRET"
    }
  },
  "agents": {
    "custom": {
      "coder": {"model": "bailian/qwen3-coder-plus"},
      "writer": {"model": "bailian/qwen3.5-plus"}
    }
  },
  "memory": {
    "enabled": true,
    "type": "local",
    "shared": true
  }
}
```

---

## ✅ 配置检查清单

配置完成后，按以下清单检查：

### 基础配置
- [ ] 模型配置正确
- [ ] API Key 有效
- [ ] `openclaw status` 显示正常

### 技能系统
- [ ] 技能已启用
- [ ] `openclaw skills list` 显示已启用技能
- [ ] 测试技能调用正常

### 记忆系统
- [ ] 记忆目录已创建
- [ ] 记忆功能正常

### 消息渠道
- [ ] 渠道已配置
- [ ] 能收到消息
- [ ] 能发送回复

### 定时任务
- [ ] 调度器已启用
- [ ] 任务已创建
- [ ] 任务按时执行

### 其他功能
- [ ] 浏览器能打开
- [ ] 文件读写正常
- [ ] 子代理能切换

---

## 🔧 常用命令速查

```bash
# 技能管理
openclaw skills list
openclaw skills enable <skill>
openclaw skills disable <skill>

# 记忆管理
openclaw memory list
openclaw memory search <query>
openclaw memory clear

# 代理管理
openclaw agent list
openclaw agent spawn --label <name>
openclaw agent use <name>
openclaw agent kill <name>

# 定时任务
openclaw scheduler list
openclaw scheduler run <job>
openclaw scheduler toggle <job>

# 浏览器
openclaw browser open
openclaw browser navigate <url>
openclaw browser screenshot

# 系统
openclaw status
openclaw logs --follow
openclaw gateway restart
```

---

## 📚 资源链接

| 资源 | 链接 |
|------|------|
| 官方文档 | https://docs.openclaw.ai |
| 技能市场 | https://clawhub.com |
| GitHub | https://github.com/openclaw/openclaw |
| 社区 Discord | https://discord.com/invite/clawd |
| 常见问题 | https://docs.openclaw.ai/faq |

---

**文档版本：** v1.0  
**适用版本：** OpenClaw 最新版  
**最后更新：** 2026-03-04  
**维护者：** Claw 🐾
