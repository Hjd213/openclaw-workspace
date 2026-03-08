# 模型用量统计工具
param(
    [string]$action,
    [string]$period,
    [switch]$json
)

$OpenClawDir = "$env:USERPROFILE\.openclaw"
$SessionsDir = "$OpenClawDir\agents\main\sessions"
$StatsFile = "$OpenClawDir\usage-stats.json"

function Get-SessionStats {
    $totalInput = 0
    $totalOutput = 0
    $modelStats = @{}
    $sessionCount = 0
    
    if (Test-Path $SessionsDir) {
        $sessions = Get-ChildItem "$SessionsDir\*.json" -Recurse -ErrorAction SilentlyContinue
        foreach ($session in $sessions) {
            try {
                $data = Get-Content $session.FullName -Raw | ConvertFrom-Json
                if ($data.stats) {
                    $sessionCount++
                    $inputTokens = [int]$data.stats.inputTokens
                    $outputTokens = [int]$data.stats.outputTokens
                    $model = $data.stats.model -replace '.*/', ''
                    
                    $totalInput += $inputTokens
                    $totalOutput += $outputTokens
                    
                    if (-not $modelStats.ContainsKey($model)) {
                        $modelStats[$model] = @{input=0; output=0; sessions=0}
                    }
                    $modelStats[$model].input += $inputTokens
                    $modelStats[$model].output += $outputTokens
                    $modelStats[$model].sessions++
                }
            } catch {
                # Skip invalid files
            }
        }
    }
    
    return @{
        totalInput = $totalInput
        totalOutput = $totalOutput
        totalTokens = $totalInput + $totalOutput
        sessions = $sessionCount
        models = $modelStats
        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
}

function Show-Usage {
    param($period="all")
    
    Write-Host "`n=== OpenClaw 模型用量统计 ===" -ForegroundColor Cyan
    Write-Host "统计时间：$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
    Write-Host ""
    
    $stats = Get-SessionStats
    
    # 总体统计
    Write-Host "[总体统计]" -ForegroundColor Yellow
    Write-Host "  会话数：$($stats.sessions)" -ForegroundColor White
    Write-Host "  输入 Token: $([math]::Round($stats.totalInput/1000, 1))K ($($stats.totalInput))" -ForegroundColor Green
    Write-Host "  输出 Token: $([math]::Round($stats.totalOutput/1000, 1))K ($($stats.totalOutput))" -ForegroundColor Blue
    Write-Host "  总计 Token: $([math]::Round($stats.totalTokens/1000000, 2))M ($($stats.totalTokens))" -ForegroundColor Cyan
    Write-Host ""
    
    # 按模型统计
    Write-Host "[按模型统计]" -ForegroundColor Yellow
    if ($stats.models.Count -eq 0) {
        Write-Host "  暂无数据" -ForegroundColor Gray
    } else {
        foreach ($model in $stats.models.Keys) {
            $data = $stats.models[$model]
            $total = $data.input + $data.output
            Write-Host "  $model" -ForegroundColor White
            Write-Host "    会话：$($data.sessions) | 输入：$([math]::Round($data.input/1000, 1))K | 输出：$([math]::Round($data.output/1000, 1))K | 总计：$([math]::Round($total/1000, 1))K" -ForegroundColor Gray
        }
    }
    Write-Host ""
    
    # 估算费用（阿里云 Coding Plan 价格）
    Write-Host "[费用估算（阿里云 Coding Plan）]" -ForegroundColor Yellow
    # qwen3.5-plus: 输入￥0.004/1K, 输出￥0.012/1K
    $estimatedCost = ($stats.totalInput / 1000 * 0.004) + ($stats.totalOutput / 1000 * 0.012)
    Write-Host "  估算费用：¥$([math]::Round($estimatedCost, 2))" -ForegroundColor Green
    Write-Host "  注：按 qwen3.5-plus 价格估算，实际价格可能不同" -ForegroundColor Gray
    Write-Host ""
}

function Export-Usage {
    $stats = Get-SessionStats
    $stats | ConvertTo-Json -Depth 10 | Out-File $StatsFile -Encoding UTF8
    Write-Host "[OK] Usage exported to: $StatsFile" -ForegroundColor Green
    Write-Host $StatsFile
}

function Clear-Usage {
    if (Test-Path $StatsFile) {
        Remove-Item $StatsFile -Force
        Write-Host "[OK] Usage stats cleared" -ForegroundColor Green
    } else {
        Write-Host "[INFO] No stats to clear" -ForegroundColor Yellow
    }
}

# Main
switch ($action.ToLower()) {
    "stats" { Show-Usage $period }
    "export" { Export-Usage }
    "clear" { Clear-Usage }
    default {
        Write-Host "`nModel Usage Tool - Usage:" -ForegroundColor Cyan
        Write-Host "  .\model-usage.ps1 stats   - Show usage statistics"
        Write-Host "  .\model-usage.ps1 export  - Export to JSON file"
        Write-Host "  .\model-usage.ps1 clear   - Clear usage stats"
        Write-Host ""
        Write-Host "Example:"
        Write-Host "  .\model-usage.ps1 stats"
        Write-Host "  .\model-usage.ps1 export"
    }
}
