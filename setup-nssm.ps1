# 下载 NSSM 可执行文件
$nssmUrl = "https://nssm.cc/release/nssm-2.24.zip"
$nssmZip = "$env:TEMP\nssm.zip"
$nssmDir = "$env:TEMP\nssm"

Write-Host "正在下载 NSSM..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $nssmUrl -OutFile $nssmZip

Write-Host "正在解压..." -ForegroundColor Cyan
Expand-Archive $nssmZip -DestinationPath $nssmDir -Force

# 找到 nssm.exe
$nssmExe = Get-ChildItem $nssmDir -Filter "nssm.exe" -Recurse | Where-Object { $_.FullName -like "*win64*" } | Select-Object -First 1

if ($nssmExe) {
    Write-Host "NSSM 已下载：$($nssmExe.FullName)" -ForegroundColor Green
    
    # 复制到系统路径
    $systemNssm = "C:\Windows\System32\nssm.exe"
    Copy-Item $nssmExe.FullName $systemNssm -Force
    Write-Host "已复制到：$systemNssm" -ForegroundColor Green
} else {
    Write-Host "未找到 nssm.exe" -ForegroundColor Red
}
