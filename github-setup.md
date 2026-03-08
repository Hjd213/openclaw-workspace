# GitHub 配置指南

> 📅 创建时间：2026-03-04  
> ✅ GitHub CLI v2.87.3 已安装

---

## 🎯 登录 GitHub

### 方式 A：浏览器登录（推荐）

**在 PowerShell 中运行：**

```powershell
gh auth login
```

**然后按提示操作：**

1. 选择 `GitHub.com`
2. 选择 `HTTPS`
3. 选择 `Login with a web browser`
4. 会打开浏览器，登录你的 GitHub 账号
5. 授权 GitHub CLI
6. 复制浏览器显示的代码
7. 粘贴回 PowerShell

**或者直接运行这个命令（自动打开浏览器）：**

```powershell
gh auth login --web
```

---

### 方式 B：Token 登录（适合无法打开浏览器）

1. **获取 Token：**
   - 访问：https://github.com/settings/tokens/new
   - 勾选 scopes：`repo`, `read:user`, `user:email`, `workflow`
   - 点击 "Generate token"
   - 复制 Token（只显示一次！）

2. **使用 Token 登录：**
   ```powershell
   gh auth login --with-token
   ```
   粘贴你的 Token

---

## ✅ 验证登录

```powershell
# 查看登录状态
gh auth status

# 查看你的信息
gh api user | ConvertFrom-Json | Select-Object login,name,company,location
```

---

## 🛠️ 常用 GitHub 命令

### 查看信息

```powershell
# 查看当前用户
gh api user | ConvertFrom-Json | Select-Object login,name

# 查看我的仓库
gh repo list --limit 10

# 查看我的 Issues
gh issue list --limit 10

# 查看我的 PRs
gh pr list --limit 10
```

### 仓库操作

```powershell
# 克隆仓库
gh repo clone 用户名/仓库名

# 创建新仓库
gh repo create 新仓库名 --public --source=. --remote=origin

# 查看仓库信息
gh repo view 用户名/仓库名
```

### Issue 管理

```powershell
# 创建 Issue
gh issue create --title "标题" --body "内容"

# 查看 Issue
gh issue view 123  # 123 是 Issue 编号

# 评论 Issue
gh issue comment 123 --body "评论内容"

# 关闭 Issue
gh issue close 123
```

### PR 管理

```powershell
# 创建 PR
gh pr create --title "标题" --body "内容"

# 查看 PR
gh pr view 456  # 456 是 PR 编号

# 评论 PR
gh pr comment 456 --body "评论内容"

# 合并 PR
gh pr merge 456 --merge

# 查看 CI 状态
gh run list --limit 10
```

---

## 🤖 让我帮你管理 GitHub

配置完成后，你可以直接对我说：

```
"查看我的 GitHub 仓库"
"帮我创建一个新的 Issue"
"看看这个 PR 的状态"
"检查一下 CI 通过了吗"
"帮我合并这个 PR"
```

---

## 📋 下一步

1. **完成登录**
   ```powershell
   gh auth login --web
   ```

2. **验证登录**
   ```powershell
   gh auth status
   ```

3. **测试功能**
   ```powershell
   gh repo list
   ```

4. **开始使用**
   - 告诉我你的 GitHub 用户名
   - 我可以帮你管理仓库、Issues、PRs

---

## ⚠️ 常见问题

### Q: 无法打开浏览器怎么办？
A: 使用 Token 登录方式（见上方）

### Q: Token 有哪些权限？
A: 推荐勾选：`repo`, `read:user`, `user:email`, `workflow`

### Q: 如何退出登录？
A: `gh auth logout`

### Q: 如何切换账号？
A: 先 logout，再重新 login

---

**配置完成后告诉我，我会帮你测试功能！** 🐾
