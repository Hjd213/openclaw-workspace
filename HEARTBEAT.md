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

