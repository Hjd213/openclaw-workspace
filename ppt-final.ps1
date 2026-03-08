# PPT Template Replacement - Correct Method
# This script properly applies template to all slides

$ErrorActionPreference = "Stop"

# Get PPT files from desktop
$pptFiles = Get-ChildItem "$env:USERPROFILE\Desktop" -Filter "*.pptx" | Sort-Object LastWriteTime
$templateFile = $pptFiles[0].FullName  # Template (government report)
$targetFile = $pptFiles[1].FullName    # Target (eight claw robot)

Write-Host "=== PPT Template Replacement ===" -ForegroundColor Cyan
Write-Host "Template: $($pptFiles[0].Name)"
Write-Host "Target: $($pptFiles[1].Name)"
Write-Host ""

try {
    # Start PowerPoint
    $pp = New-Object -ComObject PowerPoint.Application
    $pp.Visible = 1
    
    # Open template and get design
    Write-Host "[1/6] Opening template..." -ForegroundColor Yellow
    $templatePres = $pp.Presentations.Open($templateFile, 0, 0, 0)  # ReadOnly
    $designTemplate = $templatePres.Designs.Item(1)
    Write-Host "  Design: $($designTemplate.Name)" -ForegroundColor Green
    
    # Open target presentation
    Write-Host "[2/6] Opening target..." -ForegroundColor Yellow
    $targetPres = $pp.Presentations.Open($targetFile, 0, 0, 0)  # ReadOnly
    Write-Host "  Slides: $($targetPres.Slides.Count)" -ForegroundColor Green
    
    # Create new presentation
    Write-Host "[3/6] Creating new presentation..." -ForegroundColor Yellow
    $newPres = $pp.Presentations.Add(1)
    
    # Apply design template to new presentation
    Write-Host "[4/6] Applying design template..." -ForegroundColor Yellow
    $designTemplate.Apply($newPres)
    Write-Host "  Design applied successfully" -ForegroundColor Green
    
    # Copy all slides from target to new
    Write-Host "[5/6] Copying slides..." -ForegroundColor Yellow
    $slideCount = $targetPres.Slides.Count
    for ($i = $slideCount; $i -ge 1; $i--) {
        Write-Host "  Copying slide $i/$slideCount..." -ForegroundColor Gray
        $targetPres.Slides.Item($i).Copy()
        $newPres.Slides.Paste(1)
        # Apply template layout
        try {
            $newPres.Slides.Item(1).Design = $designTemplate
        } catch {}
    }
    Write-Host "  Copied $slideCount slides" -ForegroundColor Green
    
    # Delete the default empty slide
    if ($newPres.Slides.Count -gt $slideCount) {
        $newPres.Slides.Item($newPres.Slides.Count).Delete()
    }
    
    # Save with proper name
    Write-Host "[6/6] Saving..." -ForegroundColor Yellow
    $outputFile = "$env:USERPROFILE\Desktop\EightClaw-TsinghuaTemplate.pptx"
    $newPres.SaveAs($outputFile)
    Write-Host "  Saved: $outputFile" -ForegroundColor Green
    
    # Cleanup
    $newPres.Close()
    $targetPres.Close()
    $templatePres.Close()
    $pp.Quit()
    
    Write-Host ""
    Write-Host "=== SUCCESS ===" -ForegroundColor Green
    Write-Host "Output: $outputFile" -ForegroundColor Cyan
    
    # Verify
    if (Test-Path $outputFile) {
        $file = Get-Item $outputFile
        Write-Host "Size: $([math]::Round($file.Length/1MB, 2)) MB" -ForegroundColor Cyan
        Write-Host "Slides: $($newPres.Slides.Count)" -ForegroundColor Cyan
    }
    
} catch {
    Write-Host ""
    Write-Host "=== ERROR ===" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Yellow
    if ($pp) { try { $pp.Quit() } catch {} }
}
