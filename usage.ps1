# Model Usage Stats
$sessionFile = "$env:USERPROFILE\.openclaw\agents\main\sessions\sessions.json"

Write-Host "`n=== OpenClaw Usage Stats ===" -ForegroundColor Cyan
Write-Host "Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
Write-Host ""

if (Test-Path $sessionFile) {
    $data = Get-Content $sessionFile -Raw | ConvertFrom-Json
    
    foreach ($session in $data.PSObject.Properties.Value) {
        $model = $session.model
        $input = $session.inputTokens
        $output = $session.outputTokens
        $total = $session.totalTokens
        $updated = [DateTimeOffset]::FromUnixTimeMilliseconds($session.updatedAt).DateTime
        
        Write-Host "[Session]" -ForegroundColor Yellow
        Write-Host "  Model: $model" -ForegroundColor White
        Write-Host "  Input:  $([math]::Round($input/1000,1))K tokens" -ForegroundColor Green
        Write-Host "  Output: $([math]::Round($output/1000,1))K tokens" -ForegroundColor Blue
        Write-Host "  Total:  $([math]::Round($total/1000,1))K tokens" -ForegroundColor Cyan
        Write-Host "  Updated: $updated" -ForegroundColor Gray
        Write-Host ""
        
        # Cost estimate (Aliyun pricing)
        $cost = ($input/1000*0.004) + ($output/1000*0.012)
        Write-Host "[Est. Cost]" -ForegroundColor Yellow
        Write-Host "  ~$([math]::Round($cost,2)) CNY (qwen3.5-plus rate)" -ForegroundColor Green
    }
} else {
    Write-Host "No session data found" -ForegroundColor Yellow
}
Write-Host ""
