@echo off
REM Start n8n without Docker (uses globally installed n8n)
REM Avoids PowerShell execution-policy issues and F:\ node_modules ENOTEMPTY errors

set N8N_PORT=5678
set GENERIC_TIMEZONE=America/Toronto
set TZ=America/Toronto
set N8N_USER_FOLDER=%~dp0.n8n

where n8n >nul 2>&1
if errorlevel 1 (
  echo n8n is not installed globally yet.
  echo Run this once in Command Prompt ^(cmd.exe^):
  echo   npm.cmd install -g n8n@1.123.71
  echo.
  pause
  exit /b 1
)

echo Starting n8n on http://localhost:5678
echo Data folder: %N8N_USER_FOLDER%
echo.
n8n start
