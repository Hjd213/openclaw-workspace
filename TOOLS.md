# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

## Skills Configuration

### planning-with-files (按需启用)

**位置:** `D:\npm-global\node_modules\openclaw\skills\planning-with-files`

**启用条件:** 当我遇到复杂多步骤任务时，会主动询问是否开启此功能

**不要全局启用** - 仅用于：
- 复杂多步骤任务（5+ 步骤）
- 跨多次会话的研究项目
- 大型代码重构/功能开发

**触发方式:** 我会问"这个任务比较复杂，是否启用 planning-with-files 规划模式？"

---

## 🔑 API 配置（敏感信息）

### Todoist
- **API Token:** `17903c8266ce2084046eb1baf74bf012acc63bd8`
- **状态:** 已认证
- **客户端:** Windows 桌面版 + 鸿蒙 Android 版

### Obsidian
- **仓库路径:** `D:\Obsidian-OpenClaw\OpenClaw`
- **HTTP API:** 已启用 (端口 27123)
- **API Key:** `0661f14ffed0b1df02c42dd6103c977fed2f195583478d1710b116944e9c7a21`

### Gemini API
- **API Key:** `AIzaSyA9oUURaQFuHQNebn98MUWkpWPBfo0OYUI`
- **用途:** Summarize + Nano Banana Pro

---

## 🛠️ 工具路径

### FFmpeg
- **路径:** `C:\Users\bljd5\AppData\Local\Microsoft\WinGet\Links\ffmpeg.exe`
- **版本:** 8.0.1

### Git 配置
- **用户名:** Hjd213
- **邮箱:** 2143751508@qq.com

---

Add whatever helps you do your job. This is your cheat sheet.
