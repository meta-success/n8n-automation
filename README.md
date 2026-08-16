# n8n-automation

Self-hosted n8n for **AI-powered lead qualification** (Gmail → OpenAI → Google Sheets → Gmail drafts).

| Item | Value |
|------|--------|
| UI | http://localhost:5678 |
| Timezone | America/Toronto |
| Workflow | `workflows/ai-lead-qualification.json` |
| Full setup (Gmail / Sheets / OpenAI) | [SETUP.md](./SETUP.md) |

---

## Prerequisites

- **Node.js 20+** (required for the no-Docker method below)
- **Docker Desktop** (optional — only if you prefer containers)
- OpenAI API key, Gmail, and Google Sheets (for the lead workflow)

> **Docker Desktop shows “Virtualization support not detected”?**  
> Use **Option A (npm)** below to run n8n immediately, then fix Docker using [Fix Docker virtualization](#fix-docker-virtualization-windows).

---

## Option A — Run with npm / global n8n (recommended if Docker fails)

On Windows, **do not** rely on a local `node_modules` install of n8n on the `F:` drive — it often fails with `ENOTEMPTY`. Install n8n **once globally**, then start from this folder.

### 1. Fix PowerShell blocking `npm` (optional)

Either always use `npm.cmd`, or allow scripts for your user:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

### 2. Clean a broken install (if you hit `ENOTEMPTY`)

Close any running Node/npm windows, then in **Command Prompt** (`cmd.exe`, not PowerShell):

```bat
cd /d F:\AI-automation\n8n-automation
rmdir /s /q node_modules
```

If `rmdir` fails, reboot and delete `node_modules` again (antivirus/OneDrive can lock files).

### 3. Install n8n globally (once)

```bat
npm.cmd install -g n8n@1.123.71
```

Peer-dependency warnings are normal — wait until it finishes with no `npm error`.

### 4. Start n8n

Double-click `start-n8n-local.bat`, or:

```bat
cd /d F:\AI-automation\n8n-automation
start-n8n-local.bat
```

Then open: **http://localhost:5678**

Stop with `Ctrl+C`.

Data is stored under `./.n8n` in this project (persistent across restarts).

> **PowerShell tip:** If `npm` fails with “running scripts is disabled”, use `npm.cmd` (as above).
---

## Option B — Run with Docker Compose

Only when Docker Desktop shows **Engine running** (green).

```powershell
cd F:\AI-automation\n8n-automation
docker compose up -d
```

Open http://localhost:5678  
Stop: `docker compose down`

### Or plain `docker run`

```powershell
docker run -d --name n8n-automation -p 5678:5678 -e GENERIC_TIMEZONE="America/Toronto" -e TZ="America/Toronto" -e N8N_HOST="localhost" -e N8N_PORT=5678 -e N8N_PROTOCOL="http" -e WEBHOOK_URL="http://localhost:5678/" -e N8N_ENCRYPTION_KEY="change-me-to-a-long-random-string-32chars" -v n8n_data:/home/node/.n8n n8nio/n8n:latest
```

Windows helper: `start-n8n.bat`

---

## After n8n is running

1. Create your owner account in the UI (first visit)
2. **Workflows → Import from File** → select `workflows/ai-lead-qualification.json`
3. Connect credentials (OpenAI, Gmail OAuth2, Google Sheets OAuth2)
4. Set your Google Sheet ID and re-select Gmail labels
5. Follow [SETUP.md](./SETUP.md) for Sheets headers, Gmail labels, prompts, and testing

---

## Fix Docker virtualization (Windows)

Docker Desktop needs **CPU virtualization + WSL 2**. Your PC may already have a hypervisor running even when Docker still fails — finish these steps:

### 1. Enable virtualization in BIOS/UEFI

1. Reboot → enter BIOS/UEFI (`F2`, `Del`, `Esc`, or vendor key)
2. Enable **Intel VT-x** / **AMD-V** / **SVM Mode**
3. Save & exit

### 2. Turn on Windows features (Admin PowerShell)

```powershell
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
```

Reboot, then:

```powershell
wsl --install
wsl --set-default-version 2
wsl --update
```

### 3. Docker Desktop settings

1. Open Docker Desktop → **Settings → General**
2. Enable **Use the WSL 2 based engine**
3. **Settings → Resources → WSL Integration** → enable your distro
4. Apply & Restart

### 4. If it still fails

- Install/update [WSL2](https://aka.ms/wsl2kernel) and reboot
- In Windows Features, enable **Virtual Machine Platform**
- Run Docker Desktop **as Administrator** once
- Corporate PC: IT may block virtualization — use **Option A (npm)** instead

---

## Project layout

```text
n8n-automation/
├── README.md                 ← you are here
├── SETUP.md                  ← Gmail / Sheets / OpenAI / testing
├── package.json              ← npm start (no Docker)
├── docker-compose.yml
├── start-n8n.bat
├── .env / .env.example
└── workflows/
    └── ai-lead-qualification.json
```

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Port 5678 in use | Stop other n8n/Docker, or set `"start": "n8n start --port 5679"` |
| Docker “Engine stopped” | Fix virtualization (above) or use `npm start` |
| Lost workflows after restart | npm: check `./.n8n`; Docker: keep volume `n8n_data` |
| Import / credential errors | See [SETUP.md](./SETUP.md) § Troubleshooting |
