# Simple PPT Template Application
$pptFiles = Get-ChildItem "$env:USERPROFILE\Desktop" -Filter "*.pptx" | Sort-Object LastWriteTime
$templatePath = $pptFiles[0].FullName
$targetPath = $pptFiles[1].FullName
$outputPath = "$env:USERPROFILE\Desktop\八爪智能 - 清华模板.pptx"

Write-Host "=== PPT Template Change ===" -ForegroundColor Cyan
Write-Host "Template: $($pptFiles[0].Name)"
Write-Host "Target: $($pptFiles[1].Name)"
Write-Host ""

# Close PowerPoint
Stop-Process -Name "POWERPNT" -Force -ErrorAction SilentlyContinue
Start-Sleep 1

try {
    $pp = New-Object -ComObject PowerPoint.Application
    $pp.Visible = 1  # Visible
    
    Write-Host "[1/4] Opening template..." -ForegroundColor Yellow
    $template = $pp.Presentations.Open($templatePath, 0, 0, 1)  # ReadOnly
    Write-Host "  OK - $($template.Slides.Count) slides" -ForegroundColor Green
    
    Write-Host "[2/4] Opening target..." -ForegroundColor Yellow
    $target = $pp.Presentations.Open($targetPath, 0, 0, 1)  # ReadOnly
    Write-Host "  OK - $($target.Slides.Count) slides" -ForegroundColor Green
    
    Write-Host "[3/4] Creating new presentation with template..." -ForegroundColor Yellow
    
    # Create new from template
    $new = $pp.Presentations.Add(1)  # msoTrue
    
    # Apply template design to new presentation
    foreach ($design in $template.Designs) {
        try {
            $design.Apply($new)
            Write-Host "  Design applied" -ForegroundColor Green
            break
        } catch {
            Write-Host "  Skip: $_" -ForegroundColor Gray
        }
    }
    
    # Copy all slides from target
    $count = $target.Slides.Count
    for ($i = $count; $i -ge 1; $i--) {
        Write-Host "  Copying slide $i/$count..." -ForegroundColor Gray
        $target.Slides.Item($i).Copy()
        $new.Slides.Paste(1)
    }
    
    Write-Host "[4/4] Saving..." -ForegroundColor Yellow
    $new.SaveAs($outputPath)
    Write-Host "  OK - $outputPath" -ForegroundColor Green
    
    # Cleanup
    $new.Close()
    $target.Close()
    $template.Close()
    $pp.Quit()
    
    Write-Host ""
    Write-Host "=== DONE ===" -ForegroundColor Green
    
    # Verify
    if (Test-Path $outputPath) {
        $file = Get-Item $outputPath
        Write-Host "File: $($file.Name)" -ForegroundColor Cyan
        Write-Host "Size: $([math]::Round($file.Length/1MB, 2)) MB" -ForegroundColor Cyan
    }
    
} catch {
    Write-Host ""
    Write-Host "=== ERROR ===" -ForegroundColor Red
    Write-Host $_ -ForegroundColor Red
    if ($pp) { $pp.Quit() }
}
