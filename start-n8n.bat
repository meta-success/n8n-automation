@echo off
REM Start n8n with persistent storage and America/Toronto timezone
docker run -d ^
  --name n8n-automation ^
  -p 5678:5678 ^
  -e GENERIC_TIMEZONE=America/Toronto ^
  -e TZ=America/Toronto ^
  -e N8N_HOST=localhost ^
  -e N8N_PORT=5678 ^
  -e N8N_PROTOCOL=http ^
  -e WEBHOOK_URL=http://localhost:5678/ ^
  -e N8N_ENCRYPTION_KEY=change-me-to-a-long-random-string-32chars ^
  -v n8n_data:/home/node/.n8n ^
  n8nio/n8n:latest

echo.
echo n8n started at http://localhost:5678
echo Data persists in Docker volume: n8n_data
