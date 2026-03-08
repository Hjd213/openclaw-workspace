# PPT 模板替换脚本
# 功能：将目标 PPT 的内容复制到模板 PPT 的版式中

param(
    [string]$templatePath,
    [string]$targetPath,
    [string]$outputPath
)

Write-Host "=== PPT 模板替换工具 ===" -ForegroundColor Cyan
Write-Host ""

# 检查文件是否存在
if (-not (Test-Path $templatePath)) {
    Write-Host "[错误] 模板文件不存在：$templatePath" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $targetPath)) {
    Write-Host "[错误] 目标 PPT 不存在：$targetPath" -ForegroundColor Red
    exit 1
}

Write-Host "[✓] 模板文件：$templatePath" -ForegroundColor Green
Write-Host "[✓] 目标文件：$targetPath" -ForegroundColor Green

# 创建备份
$backupPath = $targetPath + ".backup"
Write-Host ""
Write-Host "[备份] 创建备份..." -ForegroundColor Yellow
Copy-Item $targetPath $backupPath -Force
Write-Host "[✓] 备份完成：$backupPath" -ForegroundColor Green

# 使用 PowerPoint COM 对象
Write-Host ""
Write-Host "[处理] 正在打开 PowerPoint..." -ForegroundColor Yellow

try {
    $powerpoint = New-Object -ComObject PowerPoint.Application
    $powerpoint.Visible = [Microsoft.Office.Core.MsoTriState]::msoTrue
    
    # 打开模板 PPT（获取母版）
    Write-Host "[1/4] 打开模板 PPT..." -ForegroundColor Yellow
    $templatePresentation = $powerpoint.Presentations.Open($templatePath, [Microsoft.Office.Core.MsoTriState]::msoFalse, [Microsoft.Office.Core.MsoTriState]::msoFalse, [Microsoft.Office.Core.MsoTriState]::msoTrue)
    Write-Host "  [✓] 模板已打开，幻灯片数：$($templatePresentation.Slides.Count)" -ForegroundColor Green
    
    # 打开目标 PPT
    Write-Host "[2/4] 打开目标 PPT..." -ForegroundColor Yellow
    $targetPresentation = $powerpoint.Presentations.Open($targetPath, [Microsoft.Office.Core.MsoTriState]::msoFalse, [Microsoft.Office.Core.MsoTriState]::msoFalse, [Microsoft.Office.Core.MsoTriState]::msoTrue)
    Write-Host "  [✓] 目标已打开，幻灯片数：$($targetPresentation.Slides.Count)" -ForegroundColor Green
    
    # 创建新 PPT
    Write-Host "[3/4] 创建新 PPT 并应用模板..." -ForegroundColor Yellow
    $newPresentation = $powerpoint.Presentations.Add([Microsoft.Office.Core.MsoTriState]::msoTrue)
    
    # 复制模板的母版（通过复制所有幻灯片）
    foreach ($slide in $templatePresentation.Slides) {
        $slide.Copy()
        $newPresentation.Slides.Paste($newPresentation.Slides.Count + 1)
    }
    
    # 删除模板幻灯片，保留母版
    for ($i = $newPresentation.Slides.Count; $i -ge 1; $i--) {
        $newPresentation.Slides.Item($i).Delete()
    }
    
    Write-Host "  [✓] 母版已加载" -ForegroundColor Green
    
    # 复制目标 PPT 的每张幻灯片
    $slideCount = $targetPresentation.Slides.Count
    for ($i = 1; $i -le $slideCount; $i++) {
        Write-Host "  处理幻灯片 $i/$slideCount..." -ForegroundColor Gray
        $slide = $targetPresentation.Slides.Item($i)
        $slide.Copy()
        
        # 粘贴到新 PPT，使用模板的母版
        $newSlide = $newPresentation.Slides.Paste($newPresentation.Slides.Count + 1)
        
        # 尝试应用模板母版（使用第一个母版）
        try {
            if ($newPresentation.SlideMaster.Count -gt 0) {
                $newSlide.Layout = 1  # 使用标题幻灯片布局
            }
        } catch {
            Write-Host "    [警告] 无法应用母版：$_" -ForegroundColor Yellow
        }
    }
    
    Write-Host "  [✓] 所有幻灯片已复制" -ForegroundColor Green
    
    # 保存新 PPT
    Write-Host "[4/4] 保存新 PPT..." -ForegroundColor Yellow
    $newPresentation.SaveAs($outputPath)
    Write-Host "[✓] 保存成功：$outputPath" -ForegroundColor Green
    
    # 关闭所有 PPT
    $newPresentation.Close()
    $targetPresentation.Close()
    $templatePresentation.Close()
    $powerpoint.Quit()
    
    Write-Host ""
    Write-Host "=== 完成！===" -ForegroundColor Green
    Write-Host "输出文件：$outputPath" -ForegroundColor Cyan
    Write-Host "备份文件：$backupPath" -ForegroundColor Cyan
    
} catch {
    Write-Host "[错误] 处理失败：$_" -ForegroundColor Red
    if ($powerpoint) {
        try {
            $powerpoint.Quit()
        } catch {}
    }
    exit 1
}
