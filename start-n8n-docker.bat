@echo off
REM Start n8n with Docker (no npm install needed)
cd /d "%~dp0"

docker info >nul 2>&1
if errorlevel 1 (
  echo.
  echo Docker Engine is NOT running.
  echo.
  echo 1. Open Docker Desktop and wait until it says "Engine running"
  echo 2. If you see "Virtualization support not detected", fix that first:
  echo    - Enable VT-x / AMD-V in BIOS
  echo    - In Admin PowerShell:
  echo        wsl --install
  echo        wsl --update
  echo    - Docker Desktop Settings -^> General -^> Use the WSL 2 based engine
  echo 3. Run this bat again
  echo.
  pause
  exit /b 1
)

echo Pulling and starting n8n...
docker compose up -d

if errorlevel 1 (
  echo.
  echo Failed. If container name conflicts, run:
  echo   docker rm -f n8n-automation
  echo   docker compose up -d
  echo.
  pause
  exit /b 1
)

echo.
echo n8n is starting at http://localhost:5678
echo Logs: docker compose logs -f
echo Stop:  docker compose down
echo.
start http://localhost:5678
pause
