# HEARTBEAT.md

# Keep this file empty (or with only comments) to skip heartbeat API calls.

# Add tasks below when you want the agent to check something periodically.

---

## 自动备份任务

**每次心跳时执行：**
1. 检查 workspace 是否有未提交的更改
2. 如果有，执行 `git add .` + `git commit` + `git push`
3. **推送成功** → 立即通知用户
4. **推送失败** → 立即通知用户，并提供手动推送步骤

**备份频率：** 由心跳间隔决定（默认每天 2-3 次）

**通知要求：**
- ✅ 成功：告诉用户提交了什么文件
- ❌ 失败：告诉用户失败原因，并给出手动推送命令

---

## 每日记忆整理（兜底任务）

**触发条件**：
- 如果当前时间 > 20:30 且今天还没整理过记忆

**执行内容**：
1. 读取 memory/ 目录下所有文件
2. 读取当前 MEMORY.md
3. 提炼新的信息到 MEMORY.md
4. 如果有不确定的内容，列出问题让用户确认
5. 完成后 git commit + push
6. 标记今天已整理（避免重复）

**说明**：
- 这是 Cron 任务的兜底方案
- 如果 20:30 时网关没开，下次心跳时会补上
- 每天只执行一次

