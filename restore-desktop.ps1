# 桌面布局恢复脚本
# 运行此脚本将恢复 2026-03-03 备份的桌面布局

$backupDate = "2026-03-03"
$desktopPath = "C:\Users\bljd5\Desktop"
$backupInfoPath = "C:\Users\bljd5\.openclaw\workspace\desktop-backup-$backupDate.json"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  桌面布局恢复工具" -ForegroundColor Cyan
Write-Host "  备份日期：$backupDate" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if (Test-Path $backupInfoPath) {
    Write-Host "[OK] 找到备份信息文件" -ForegroundColor Green
    Write-Host "备份文件位置：$backupInfoPath" -ForegroundColor Gray
} else {
    Write-Host "[ERROR] 未找到备份信息文件！" -ForegroundColor Red
    Write-Host "请确认备份文件存在：$backupInfoPath" -ForegroundColor Gray
    exit 1
}

Write-Host ""
Write-Host "当前桌面上的所有文件和文件夹将保持不变。" -ForegroundColor Yellow
Write-Host "此脚本仅用于参考备份信息，不会自动移动文件。" -ForegroundColor Yellow
Write-Host ""
Write-Host "如需手动恢复，请参考备份 JSON 文件中的内容。" -ForegroundColor Cyan
Write-Host ""
