# n8n-automation

Self-hosted n8n for **AI-powered lead qualification** (Gmail → OpenAI → Google Sheets → Gmail drafts).

| Item | Value |
|------|--------|
| UI | http://localhost:5678 |
| Timezone | America/Toronto |
| Workflow | `workflows/ai-lead-qualification.json` |
| Full setup (Gmail / Sheets / OpenAI) | [SETUP.md](./SETUP.md) |

**Recommended on Windows: use Docker** (skip the multi-hour `npm install`).

---

## Run with Docker (recommended)

No Node/`npm` install required. Docker pulls a ready-made n8n image.

### 1. Start Docker Desktop

1. Open **Docker Desktop**
2. Wait until bottom-left says **Engine running** (green)

If you see **Virtualization support not detected** / **Engine stopped**:

1. Reboot → BIOS → enable **Intel VT-x** / **AMD-V** / **SVM** → save
2. Admin PowerShell:

```powershell
wsl --install
wsl --update
wsl --set-default-version 2
```

3. Reboot if asked  
4. Docker Desktop → **Settings → General** → enable **Use the WSL 2 based engine** → Apply & Restart  
5. Confirm `wsl -l -v` shows `docker-desktop` as **Running** when Desktop is open

### 2. Start n8n

```powershell
cd F:\AI-automation\n8n-automation
.\start-n8n-docker.bat
```

Or:

```powershell
cd F:\AI-automation\n8n-automation
docker compose up -d
```

Open **http://localhost:5678**

| Command | Purpose |
|---------|---------|
| `docker compose logs -f` | View logs |
| `docker compose down` | Stop |
| `docker compose pull && docker compose up -d` | Update n8n |

One-liner alternative:

```powershell
docker run -d --name n8n-automation -p 5678:5678 -e GENERIC_TIMEZONE="America/Toronto" -e TZ="America/Toronto" -e WEBHOOK_URL="http://localhost:5678/" -v n8n_data:/home/node/.n8n n8nio/n8n:latest
```

If the name already exists: `docker rm -f n8n-automation` then run again.

### 3. Import the workflow

1. Create owner account in the UI  
2. **Workflows → Import from File** → `workflows\ai-lead-qualification.json`  
3. Follow [SETUP.md](./SETUP.md) for Gmail / Sheets / OpenAI  

---

## After n8n is running

1. Create your owner account (first visit)
2. Import `workflows/ai-lead-qualification.json`
3. Connect OpenAI, Gmail OAuth2, Google Sheets OAuth2
4. Set your Google Sheet ID and re-select Gmail labels
5. See [SETUP.md](./SETUP.md) for testing

---

## Fix Docker virtualization (Windows)

Docker Desktop needs **CPU virtualization + WSL 2**.

### 1. BIOS/UEFI

Enable **Intel VT-x** / **AMD-V** / **SVM Mode**, save, reboot.

### 2. Admin PowerShell

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

1. **Settings → General** → **Use the WSL 2 based engine**
2. **Settings → Resources → WSL Integration** → enable your distro
3. Apply & Restart

### 4. Still failing?

- Update WSL and reboot
- Run Docker Desktop as Administrator once
- Corporate PC: IT may block virtualization — then you cannot use Docker until that is unlocked

---

## npm method (not recommended — can take hours)

Only if Docker cannot run. Prefer Docker.

```powershell
cd F:\AI-automation\n8n-automation
.\start-n8n-local.bat
```

That requires a completed global install: `npm.cmd install -g n8n@1.123.71`  
In PowerShell, run bats as `.\start-n8n-local.bat` (not `start-n8n-local.bat`).

---

## Project layout

```text
n8n-automation/
├── README.md
├── SETUP.md
├── docker-compose.yml
├── start-n8n-docker.bat      ← use this
├── start-n8n-local.bat       ← npm fallback
├── start-n8n.bat             ← docker run helper
└── workflows/
    └── ai-lead-qualification.json
```

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Engine stopped / virtualization | Fix section above, then reopen Docker Desktop |
| Port 5678 in use | `docker rm -f n8n-automation` or change port in `.env` |
| Lost data after recreate | Keep volume `n8n_data` (`docker volume ls`) |
| Import / credential errors | See [SETUP.md](./SETUP.md) |
| PowerShell won’t run `.bat` | Use `.\start-n8n-docker.bat` |
