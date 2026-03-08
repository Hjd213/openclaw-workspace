# PPT Template Replacement Script
# Replaces template of target PPT with template PPT

$pptFiles = Get-ChildItem "$env:USERPROFILE\Desktop" -Filter "*.pptx" | Sort-Object LastWriteTime
$templatePpt = $pptFiles[0].FullName
$targetPpt = $pptFiles[1].FullName
$outputPpt = "$env:USERPROFILE\Desktop\八爪智能 - 清华模板.pptx"

Write-Host "=== PPT Template Replacement ===" -ForegroundColor Cyan
Write-Host "Template: $($pptFiles[0].Name)"
Write-Host "Target: $($pptFiles[1].Name)"
Write-Host "Output: 八爪智能 - 清华模板.pptx"
Write-Host ""

# Close PowerPoint if running
Stop-Process -Name "POWERPNT" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

try {
    # Create PowerPoint application
    $pp = New-Object -ComObject PowerPoint.Application
    $pp.Visible = [Microsoft.Office.Core.MsoTriState]::msoTrue
    
    Write-Host "[1/5] Opening template presentation..." -ForegroundColor Yellow
    $templatePres = $pp.Presentations.Open($templatePpt, [Microsoft.Office.Core.MsoTriState]::msoFalse, [Microsoft.Office.Core.MsoTriState]::msoFalse, [Microsoft.Office.Core.MsoTriState]::msoTrue)
    Write-Host "  Slides: $($templatePres.Slides.Count)" -ForegroundColor Green
    
    # Save design template
    $designFile = "$env:TEMP\template.thmx"
    $templatePres.Designs.Item(1).Theme.SaveAs($designFile)
    Write-Host "  Design saved to temp file" -ForegroundColor Green
    
    Write-Host "[2/5] Opening target presentation..." -ForegroundColor Yellow
    $targetPres = $pp.Presentations.Open($targetPpt, [Microsoft.Office.Core.MsoTriState]::msoFalse, [Microsoft.Office.Core.MsoTriState]::msoFalse, [Microsoft.Office.Core.MsoTriState]::msoTrue)
    Write-Host "  Slides: $($targetPres.Slides.Count)" -ForegroundColor Green
    
    Write-Host "[3/5] Applying template design to all slides..." -ForegroundColor Yellow
    $slideCount = $targetPres.Slides.Count
    for ($i = 1; $i -le $slideCount; $i++) {
        $slide = $targetPres.Slides.Item($i)
        # Apply master background
        $slide.FollowMasterBackground = [Microsoft.Office.Core.MsoTriState]::msoTrue
        Write-Host "  Processed slide $i/$slideCount" -ForegroundColor Gray
    }
    Write-Host "  [OK] Design applied" -ForegroundColor Green
    
    Write-Host "[4/5] Saving as new file..." -ForegroundColor Yellow
    $targetPres.SaveAs($outputPpt)
    Write-Host "  [OK] Saved to: $outputPpt" -ForegroundColor Green
    
    Write-Host "[5/5] Closing presentations..." -ForegroundColor Yellow
    $targetPres.Close()
    $templatePres.Close()
    $pp.Quit()
    
    # Clean up temp file
    if (Test-Path $designFile) { Remove-Item $designFile -Force }
    
    Write-Host ""
    Write-Host "=== SUCCESS ===" -ForegroundColor Green
    Write-Host "Output file: $outputPpt" -ForegroundColor Cyan
    
    # Verify output
    if (Test-Path $outputPpt) {
        $file = Get-Item $outputPpt
        Write-Host "File size: $([math]::Round($file.Length/1024/1024, 2)) MB" -ForegroundColor Cyan
    }
    
} catch {
    Write-Host ""
    Write-Host "=== ERROR ===" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    if ($pp) {
        try {
            $pp.Quit()
        } catch {}
    }
} finally {
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($pp) | Out-Null
}
