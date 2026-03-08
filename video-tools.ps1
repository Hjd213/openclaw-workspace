# Video Processing Tools
param($action,$input,$output,$start,$duration,$fps)

$FFMPEG = "C:\Users\bljd5\AppData\Local\Microsoft\WinGet\Links\ffmpeg.exe"

if ($action -eq "info") {
    Write-Host "=== Video Info ===" -ForegroundColor Cyan
    & $FFMPEG -i $input 2>&1 | Select-String "Duration|Stream|Video|Audio"
}
elseif ($action -eq "frames") {
    if (-not (Test-Path $output)) { New-Item -ItemType Directory -Path $output | Out-Null }
    Write-Host "Extracting frames to $output..." -ForegroundColor Yellow
    & $FFMPEG -i $input -vf "fps=1" "$output\frame_%04d.png"
    Write-Host "[OK] Frames extracted" -ForegroundColor Green
}
elseif ($action -eq "trim") {
    Write-Host "Trimming video..." -ForegroundColor Yellow
    & $FFMPEG -i $input -ss $start -t $duration -c copy $output
    Write-Host "[OK] Video trimmed: $output" -ForegroundColor Green
}
elseif ($action -eq "gif") {
    Write-Host "Creating GIF..." -ForegroundColor Yellow
    & $FFMPEG -i $input -ss $start -t $duration -vf "fps=10,scale=640:-1" $output
    Write-Host "[OK] GIF created: $output" -ForegroundColor Green
}
elseif ($action -eq "convert") {
    Write-Host "Converting video..." -ForegroundColor Yellow
    & $FFMPEG -i $input -c:v libx264 -crf 23 -c:a aac $output
    Write-Host "[OK] Converted: $output" -ForegroundColor Green
}
else {
    Write-Host "Video Tools - Usage:" -ForegroundColor Cyan
    Write-Host "  info   <video>                    - Show video info"
    Write-Host "  frames <video> <outputDir>        - Extract frames (1fps)"
    Write-Host "  trim   <video> <output> <start> <duration> - Trim video"
    Write-Host "  gif    <video> <output> <start> <duration> - Create GIF"
    Write-Host "  convert <video> <output>          - Convert to MP4"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\video-tools.ps1 info video.mp4"
    Write-Host "  .\video-tools.ps1 frames video.mp4 frames"
    Write-Host "  .\video-tools.ps1 trim video.mp4 out.mp4 00:00:10 00:00:30"
    Write-Host "  .\video-tools.ps1 gif video.mp4 out.gif 00:00:10 5"
}
