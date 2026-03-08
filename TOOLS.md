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

Add whatever helps you do your job. This is your cheat sheet.
