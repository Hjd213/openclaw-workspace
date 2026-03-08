# 模型用量统计 - 简化版
$SessionsDir = "$env:USERPROFILE\.openclaw\agents\main\sessions"

Write-Host "`n=== OpenClaw 模型用量 ===" -ForegroundColor Cyan
Write-Host "时间：$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
Write-Host ""

$totalInput = 0
$totalOutput = 0
$modelStats = @{}

if (Test-Path $SessionsDir) {
    $sessions = Get-ChildItem "$SessionsDir\*.json" -Recurse -ErrorAction SilentlyContinue
    foreach ($s in $sessions) {
        try {
            $data = Get-Content $s.FullName -Raw | ConvertFrom-Json
            if ($data.stats) {
                $in = [int]$data.stats.inputTokens
                $out = [int]$data.stats.outputTokens
                $model = $data.stats.model -replace '.*/', ''
                $totalInput += $in
                $totalOutput += $out
                if (-not $modelStats[$model]) { $modelStats[$model] = @{input=0;output=0} }
                $modelStats[$model].input += $in
                $modelStats[$model].output += $out
            }
        } catch {}
    }
}

Write-Host "[总计]" -ForegroundColor Yellow
Write-Host "  输入：$([math]::Round($totalInput/1000,1))K tokens" -ForegroundColor Green
Write-Host "  输出：$([math]::Round($totalOutput/1000,1))K tokens" -ForegroundColor Blue
Write-Host "  总计：$([math]::Round(($totalInput+$totalOutput)/1000000,2))M tokens" -ForegroundColor Cyan
Write-Host ""

Write-Host "[按模型]" -ForegroundColor Yellow
foreach ($m in $modelStats.Keys) {
    $t = $modelStats[$m].input + $modelStats[$m].output
    Write-Host "  $m : $([math]::Round($t/1000,1))K tokens" -ForegroundColor White
}
Write-Host ""

$cost = ($totalInput/1000*0.004) + ($totalOutput/1000*0.012)
Write-Host "[估算费用]" -ForegroundColor Yellow
Write-Host "  约：$([math]::Round($cost,2)) 元 (按 qwen3.5-plus)" -ForegroundColor Green
