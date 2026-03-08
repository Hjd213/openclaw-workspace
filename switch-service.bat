@echo off
echo ========================================
echo   OpenClaw Service Switch
echo ========================================
echo.

echo [1/4] Stopping old process...
taskkill /F /PID 33924 2>nul
taskkill /F /IM node.exe /FI "WINDOWTITLE eq *openclaw*" 2>nul
timeout /t 3 /nobreak >nul

echo [2/4] Deleting scheduled task...
schtasks /Delete /TN "OpenClaw Gateway" /F 2>nul

echo [3/4] Starting Windows Service...
sc.exe start OpenClaw

echo [4/4] Waiting for service...
timeout /t 5 /nobreak >nul

echo.
echo ========================================
echo   Status:
echo ========================================
sc.exe query OpenClaw
echo.
netstat -ano | findstr ":18789"
echo.
pause
