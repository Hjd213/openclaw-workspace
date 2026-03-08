# 密码管理工具 - 简化版
param(
    [string]$action,
    [string]$service,
    [string]$username,
    [string]$password
)

$PasswordDir = "$PSScriptRoot\passwords"
if (-not (Test-Path $PasswordDir)) { New-Item -ItemType Directory -Path $PasswordDir | Out-Null }

function Save-Pass {
    $file = "$PasswordDir\$service.txt"
    $secure = ConvertTo-SecureString $password -AsPlainText -Force
    $encrypted = ConvertFrom-SecureString $secure
    $data = @{username=$username;password=$encrypted;time=(Get-Date)} | ConvertTo-Json
    $data | Out-File $file -Encoding UTF8
    Write-Host "[OK] Password saved: $service" -ForegroundColor Green
}

function Get-Pass {
    $file = "$PasswordDir\$service.txt"
    if (-not (Test-Path $file)) { Write-Host "[ERROR] Not found: $service" -ForegroundColor Red; return }
    $data = Get-Content $file -Raw | ConvertFrom-Json
    $secure = ConvertTo-SecureString $data.password
    $plain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure))
    Write-Host "[OK] Service: $service" -ForegroundColor Green
    Write-Host "Username: $($data.username)"
    Write-Host "Password: $plain"
    Write-Host "Updated: $($data.time)"
}

function List-Pass {
    $files = Get-ChildItem "$PasswordDir\*.txt" -ErrorAction SilentlyContinue
    if (-not $files) { Write-Host "[INFO] No passwords saved"; return }
    Write-Host "[INFO] Saved passwords:" -ForegroundColor Cyan
    $files | ForEach-Object { 
        $name = $_.BaseName
        $data = Get-Content $_.FullName | ConvertFrom-Json
        Write-Host "  - $name (User: $($data.username), Updated: $($data.time))"
    }
}

function Delete-Pass {
    $file = "$PasswordDir\$service.txt"
    if (Test-Path $file) { Remove-Item $file -Force; Write-Host "[OK] Deleted: $service" -ForegroundColor Green }
    else { Write-Host "[ERROR] Not found: $service" -ForegroundColor Red }
}

# Main
switch ($action.ToLower()) {
    "save" { Save-Pass }
    "get" { Get-Pass }
    "list" { List-Pass }
    "delete" { Delete-Pass }
    default {
        Write-Host "Password Manager - Usage:" -ForegroundColor Cyan
        Write-Host "  save   <service> <username> <password>  - Save password"
        Write-Host "  get    <service>                       - Get password"
        Write-Host "  list                                   - List all passwords"
        Write-Host "  delete <service>                       - Delete password"
        Write-Host ""
        Write-Host "Example:"
        Write-Host "  .\password-manager.ps1 save github myuser mypass123"
        Write-Host "  .\password-manager.ps1 get github"
        Write-Host "  .\password-manager.ps1 list"
    }
}
