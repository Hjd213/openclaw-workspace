@echo off
REM OpenClaw Windows Service Setup
REM Run as Administrator

set NSSM_URL=https://deponie.slayer.at/nssm/nssm-2.24.zip
set TEMP_DIR=%TEMP%\nssm
set NSSM_ZIP=%TEMP_DIR%\nssm.zip

echo Downloading NSSM...
mkdir %TEMP_DIR% 2>nul
curl -L -o %NSSM_ZIP% %NSSM_URL%

if not exist %NSSM_ZIP% (
    echo Download failed!
    exit /b 1
)

echo Extracting...
powershell -Command "Expand-Archive '%NSSM_ZIP%' -DestinationPath '%TEMP_DIR%' -Force"

echo Copying nssm.exe to system path...
copy /Y "%TEMP_DIR%\nssm-2.24\win64\nssm.exe" "C:\Windows\System32\nssm.exe"

echo Installing OpenClaw service...
nssm install OpenClaw "D:\nodejs\node.exe" "D:\npm-global\node_modules\openclaw\openclaw.mjs" "gateway" "run"

echo Configuring service...
nssm set OpenClaw DisplayName "OpenClaw Gateway"
nssm set OpenClaw Description "OpenClaw AI Assistant Gateway Service"
nssm set OpenClaw Start SERVICE_AUTO_START
nssm set OpenClaw ObjectName "LocalSystem"

echo Starting service...
nssm start OpenClaw

echo.
echo ========================================
echo OpenClaw Windows Service Setup Complete!
echo ========================================
echo.
echo Service name: OpenClaw
echo Status: Running
echo.
echo Commands:
echo   nssm start OpenClaw    - Start service
echo   nssm stop OpenClaw     - Stop service
echo   nssm restart OpenClaw  - Restart service
echo   nssm status OpenClaw   - Check status
echo.
pause
