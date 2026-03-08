@echo off
echo ========================================
echo   OpenClaw Service Installation
echo ========================================
echo.

echo [1/4] Creating service...
sc.exe create OpenClaw binPath= "\"D:\nodejs\node.exe\" \"D:\npm-global\node_modules\openclaw\openclaw.mjs\" gateway run" start= auto DisplayName= "OpenClaw Gateway"
if errorlevel 1 (
    echo Failed to create service!
    pause
    exit /b 1
)

echo [2/4] Setting description...
sc.exe description OpenClaw "OpenClaw AI Assistant Gateway Service"

echo [3/4] Configuring recovery...
sc.exe failure OpenClaw reset= 86400 actions= restart/60000/restart/60000/restart/60000

echo [4/4] Starting service...
sc.exe start OpenClaw

echo.
echo ========================================
echo   Installation Complete!
echo ========================================
echo.
sc.exe query OpenClaw
echo.
echo Press any key to exit...
pause >nul
