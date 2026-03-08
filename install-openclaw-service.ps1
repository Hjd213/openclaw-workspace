# OpenClaw Windows Service Installation Script
# Run as Administrator

$serviceName = "OpenClaw"
$serviceDisplayName = "OpenClaw Gateway"
$serviceDescription = "OpenClaw AI Assistant Gateway Service"
$nodePath = "D:\nodejs\node.exe"
$scriptPath = "D:\npm-global\node_modules\openclaw\openclaw.mjs"
$serviceArgs = @("gateway", "run")

# Check if running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    exit 1
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  OpenClaw Windows Service Installer" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if service already exists
$existingService = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
if ($existingService) {
    Write-Host "Service already exists. Removing..." -ForegroundColor Yellow
    Stop-Service $serviceName -Force -ErrorAction SilentlyContinue
    sc.exe delete $serviceName
    Start-Sleep -Seconds 2
}

# Create the service
Write-Host "Creating service..." -ForegroundColor Cyan
New-Service -Name $serviceName `
    -DisplayName $serviceDisplayName `
    -Description $serviceDescription `
    -BinaryPathName "`"$nodePath`" `"$scriptPath`" gateway run" `
    -StartupType Automatic `
    -ErrorAction Stop

Write-Host "Service created successfully!" -ForegroundColor Green

# Configure service recovery
Write-Host "Configuring service recovery..." -ForegroundColor Cyan
sc.exe failure $serviceName reset= 86400 actions= restart/60000/restart/60000/restart/60000

# Set service to interact with desktop (optional)
# sc.exe config $serviceName type= service-interact

Write-Host "Starting service..." -ForegroundColor Cyan
Start-Service $serviceName

# Verify service status
Start-Sleep -Seconds 3
$serviceStatus = Get-Service -Name $serviceName
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Installation Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Service Name: $serviceName" -ForegroundColor White
Write-Host "Status: $($serviceStatus.Status)" -ForegroundColor $(if($serviceStatus.Status -eq 'Running'){'Green'}else{'Yellow'})
Write-Host "Startup: $($serviceStatus.StartType)" -ForegroundColor White
Write-Host ""
Write-Host "Useful commands:" -ForegroundColor Cyan
Write-Host "  Get-Service $serviceName     - Check status" -ForegroundColor Gray
Write-Host "  Start-Service $serviceName   - Start service" -ForegroundColor Gray
Write-Host "  Stop-Service $serviceName    - Stop service" -ForegroundColor Gray
Write-Host "  Restart-Service $serviceName - Restart service" -ForegroundColor Gray
Write-Host ""
