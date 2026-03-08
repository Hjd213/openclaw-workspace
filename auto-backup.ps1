# OpenClaw 自动备份脚本
# 每天自动将 workspace 更改推送到 GitHub

$workspacePath = "$env:USERPROFILE\.openclaw\workspace"
Set-Location $workspacePath

# 检查是否有更改
$status = git status --porcelain

if ($status) {
    Write-Host "发现更改，开始备份..."
    
    # 添加所有更改
    git add .
    
    # 提交
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
    git commit -m "Auto-backup: $timestamp"
    
    # 推送
    try {
        git push origin master
        Write-Host "✅ 备份成功"
    } catch {
        Write-Host "❌ 推送失败（网络问题），下次心跳再试"
        # 保存状态，避免重复提交
        $state = @{
            lastAttempt = $timestamp
            hasUnpushedCommits = $true
        } | ConvertTo-Json
        $state | Out-File -FilePath "memory/backup-state.json" -Encoding utf8
    }
} else {
    Write-Host "✅ 没有更改，跳过备份"
}
