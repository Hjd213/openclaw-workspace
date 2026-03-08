$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut("C:\Users\bljd5\Desktop\Windows Terminal.lnk")
$Shortcut.TargetPath = "C:\Users\bljd5\AppData\Local\Microsoft\WindowsApps\wt.exe"
$Shortcut.WorkingDirectory = "C:\Users\bljd5"
$Shortcut.Description = "Windows Terminal - 现代化终端模拟器"
$Shortcut.Save()
Write-Host "快捷方式已创建：C:\Users\bljd5\Desktop\Windows Terminal.lnk" -ForegroundColor Green
