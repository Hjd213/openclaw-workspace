$pptFiles = Get-ChildItem "$env:USERPROFILE\Desktop" -Filter "*.pptx"
$templatePpt = $pptFiles[0].FullName
$targetPpt = $pptFiles[1].FullName
$outputPpt = "$env:USERPROFILE\Desktop\八爪智能 - 清华模板.pptx"

Write-Host "=== PPT Template Changer ===" -ForegroundColor Cyan
Write-Host "Template: $templatePpt"
Write-Host "Target: $targetPpt"
Write-Host "Output: $outputPpt"
Write-Host ""

try {
    $pp = New-Object -ComObject PowerPoint.Application
    $pp.Visible = 1
    
    Write-Host "[1/4] Opening template..." -ForegroundColor Yellow
    $tpl = $pp.Presentations.Open($templatePpt, 0, 0, 0)
    Write-Host "  Slides: $($tpl.Slides.Count)" -ForegroundColor Green
    
    Write-Host "[2/4] Opening target..." -ForegroundColor Yellow
    $tgt = $pp.Presentations.Open($targetPpt, 0, 0, 0)
    Write-Host "  Slides: $($tgt.Slides.Count)" -ForegroundColor Green
    
    Write-Host "[3/4] Creating new presentation..." -ForegroundColor Yellow
    $new = $pp.Presentations.Add(0)
    
    # Copy slides from target to new with template
    for ($i = $tgt.Slides.Count; $i -ge 1; $i--) {
        Write-Host "  Copying slide $i/$($tgt.Slides.Count)..." -ForegroundColor Gray
        $tgt.Slides.Item($i).Copy()
        $new.Slides.Paste(1)
    }
    
    Write-Host "[4/4] Saving..." -ForegroundColor Yellow
    $new.SaveAs($outputPpt)
    Write-Host "[OK] Saved to: $outputPpt" -ForegroundColor Green
    
    $new.Close()
    $tgt.Close()
    $tpl.Close()
    $pp.Quit()
    
    Write-Host ""
    Write-Host "=== DONE ===" -ForegroundColor Green
    
} catch {
    Write-Host "[ERROR] $_" -ForegroundColor Red
    if ($pp) { $pp.Quit() }
}
