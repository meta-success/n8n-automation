# AI Lead Qualification — Complete Setup Guide

Workflow file: `workflows/ai-lead-qualification.json`

---

## 1. Docker command (persistent + America/Toronto)

### Option A — `docker run` (exact command)

```bash
docker run -d \
  --name n8n-automation \
  -p 5678:5678 \
  -e GENERIC_TIMEZONE="America/Toronto" \
  -e TZ="America/Toronto" \
  -e N8N_HOST="localhost" \
  -e N8N_PORT=5678 \
  -e N8N_PROTOCOL="http" \
  -e WEBHOOK_URL="http://localhost:5678/" \
  -e N8N_ENCRYPTION_KEY="change-me-to-a-long-random-string-32chars" \
  -v n8n_data:/home/node/.n8n \
  n8nio/n8n:latest
```

Windows PowerShell (one line):

```powershell
docker run -d --name n8n-automation -p 5678:5678 -e GENERIC_TIMEZONE="America/Toronto" -e TZ="America/Toronto" -e N8N_HOST="localhost" -e N8N_PORT=5678 -e N8N_PROTOCOL="http" -e WEBHOOK_URL="http://localhost:5678/" -e N8N_ENCRYPTION_KEY="change-me-to-a-long-random-string-32chars" -v n8n_data:/home/node/.n8n n8nio/n8n:latest
```

Or double-click / run: `start-n8n.bat`

### Option B — Docker Compose (recommended)

```powershell
cd F:\AI-automation\n8n-automation
docker compose up -d
```

Open: http://localhost:5678

If a container named `n8n-automation` already exists:

```powershell
docker rm -f n8n-automation
```

Then run the command again.

---

## 2. Import the workflow JSON

1. Open http://localhost:5678
2. **Workflows** → **Add workflow** (or menu **…**) → **Import from File**
3. Select: `F:\AI-automation\n8n-automation\workflows\ai-lead-qualification.json`
4. Save the workflow (do **not** activate yet)

### Post-import checklist (required)

| Node | Action |
|------|--------|
| **OpenAI - Qualify Lead** | Create/select OpenAI credential (API key) |
| **Append to Google Sheets** | Set Document to your sheet; replace `YOUR_GOOGLE_SHEET_ID` |
| **All Gmail nodes + Trigger** | Create/select the same Gmail OAuth2 credential |
| **Remove Project-Inquiry Label** | Re-select label `Project-Inquiry` from dropdown |
| **Add Lead-Processed Label** | Re-select label `Lead-Processed` from dropdown |

---

## 3. Google Sheets setup

### Create the spreadsheet

1. Go to [Google Sheets](https://sheets.google.com) → **Blank spreadsheet**
2. Name it: `AI Lead Qualification`
3. Rename Sheet1 tab to: **`Leads`**
4. Put this exact header row in **A1:G1**:

| A | B | C | D | E | F | G |
|---|---|---|---|---|---|---|
| Timestamp | Project Type | Budget | Fit Score | Lead Quality | Email Subject | Summary |

5. Copy the Spreadsheet ID from the URL:

```text
https://docs.google.com/spreadsheets/d/THIS_IS_THE_SHEET_ID/edit
```

Paste that ID into the **Append to Google Sheets** node (`YOUR_GOOGLE_SHEET_ID`).

### Google Sheets OAuth in n8n (self-hosted)

1. Open [Google Cloud Console](https://console.cloud.google.com/)
2. Create (or select) a project
3. **APIs & Services** → **Enable APIs**:
   - Google Sheets API
   - Google Drive API
   - Gmail API (needed for Gmail nodes too — enable once)
4. **Credentials** → **Create Credentials** → **OAuth client ID**
5. If prompted, configure **OAuth consent screen**:
   - User type: **External** (or Internal if Workspace)
   - App name: `n8n local`
   - Add your Gmail as a test user
6. Application type: **Web application**
7. Authorized redirect URIs — add **exactly**:

```text
http://localhost:5678/rest/oauth2-credential/callback
```

8. Copy **Client ID** and **Client Secret**
9. In n8n → **Credentials** → **Add credential** → **Google Sheets OAuth2 API**
10. Paste Client ID / Secret → **Sign in with Google** → allow Sheets + Drive access
11. Assign this credential on the **Append to Google Sheets** node

---

## 4. Gmail setup

### Create labels

In Gmail → left sidebar → **Create new label**:

1. `Project-Inquiry` — apply this to inbound project emails (manually or via Gmail filter)
2. `Lead-Processed` — applied automatically by the workflow after processing

Optional Gmail filter:

- **Matches**: `to:you@gmail.com subject:(project OR AI OR automation OR RAG)`
- **Action**: Apply label `Project-Inquiry`

### Gmail OAuth in n8n

You can reuse the same Google Cloud OAuth client if Gmail API is enabled.

1. n8n → **Credentials** → **Gmail OAuth2 API**
2. Same Client ID / Secret as above
3. Redirect URI must remain:

```text
http://localhost:5678/rest/oauth2-credential/callback
```

4. **Connect my account** → grant Gmail permissions (read, modify labels, create drafts)
5. Assign this credential to:
   - Gmail Trigger - Project Inquiry
   - Gmail Draft - High Fit
   - Gmail Draft - Holding Reply
   - Remove Project-Inquiry Label
   - Add Lead-Processed Label

### Test the Gmail connection

1. Open **Gmail Trigger - Project Inquiry**
2. Click **Fetch Test Event** / **Listen for test event** (wording varies by n8n version)
3. In Gmail, send yourself a short email and apply label **`Project-Inquiry`**
4. Within ~1 minute the trigger should show the message
5. Confirm fields include `id`, `threadId`, `subject`, and body (`text` or `html`)

---

## 5. OpenAI node configuration

### Credential

1. n8n → **Credentials** → **OpenAI API**
2. Paste your API key → Save
3. Select it on **OpenAI - Qualify Lead**

### Model

- Default in workflow: **`gpt-4o-mini`**
- You can switch to `gpt-3.5-turbo` in the node if preferred

### System prompt (already in the workflow)

```text
You are an expert lead qualification assistant for a senior AI Engineer specializing in: ML, LLM Applications, AI Agents, RAG Systems, Automation (n8n/Zapier/Make), and Full-Stack Development.

Analyze inbound project-inquiry emails and return ONLY valid JSON (no markdown fences, no commentary) with exactly these keys:
{
  "projectType": "string — e.g. AI Agent, Automation, RAG System, Web App, Other",
  "budgetRange": "string — e.g. $1000-$3000, Unknown if not stated",
  "timeline": "string — e.g. 1 month, Unknown if not stated",
  "keyRequirements": "string — concise summary of requirements",
  "fitScore": 1,
  "leadQuality": "High"
}

Scoring rules for fitScore (integer 1-10):
- 9-10: Clear AI/LLM/Agent/RAG/automation project with budget and timeline
- 7-8: Strong AI/automation fit; some details missing
- 4-6: Partial fit or vague inquiry
- 1-3: Poor fit (unrelated, spam, non-technical)

leadQuality mapping:
- High if fitScore >= 7
- Medium if fitScore is 4, 5, or 6
- Low if fitScore <= 3

If budget/timeline are missing, use "Unknown". Always fill every field.
```

### User prompt template (already in the workflow)

```text
Analyze this project inquiry email and return JSON only.

From: {{ $json.from }}
Subject: {{ $json.subject }}

Email body:
{{ $json.emailBody }}
```

### Expected AI JSON shape

```json
{
  "projectType": "RAG System",
  "budgetRange": "$3000-$5000",
  "timeline": "6 weeks",
  "keyRequirements": "Build a document Q&A system over company PDFs with citations.",
  "fitScore": 9,
  "leadQuality": "High"
}
```

`jsonOutput: true` is enabled on the OpenAI node. The **Parse AI JSON** code node normalizes several response shapes for robustness.

---

## 6. Testing guide

### A. High-fit test email

Send to yourself (or use a second account), then apply label **`Project-Inquiry`**:

```text
Subject: Need RAG chatbot for internal docs

Hi,

We're looking for an AI engineer to build a RAG system over our Notion + PDF knowledge base,
with an agent that can answer employee questions and cite sources.

Budget: $4000-$6000
Timeline: 1 month

Thanks
```

Expected:

- Sheet row with Fit Score **≥ 7**, Lead Quality **High**
- Gmail **Drafts** folder: positive interest reply in the same thread
- Label `Project-Inquiry` removed; `Lead-Processed` added

### B. Low-fit test email

```text
Subject: Looking for a logo designer

Hi, we need someone to redesign our logo and brand kit. Budget $200, needed tomorrow.
```

Expected:

- Fit Score **< 7**, Lead Quality Medium/Low
- Holding-reply draft created

### C. Manual trigger / debug

1. Keep workflow **inactive** first
2. Pin a test Gmail item on the trigger (or use **Execute workflow** after a fetched test event)
3. Click **Execute workflow** / run from the trigger node
4. Inspect each node output in the execution view

### D. Verify Google Sheet

Open the `Leads` tab — newest row should match Timestamp / Subject / Fit Score / Summary.

### E. Verify Gmail draft

Gmail → **Drafts** — open the draft, confirm subject `Re: …` and thread linkage.

### F. Activate for production

Toggle **Active** on the workflow. It polls about every minute.

---

## 7. Troubleshooting

| Issue | Fix |
|-------|-----|
| **OAuth redirect mismatch** | Redirect URI must be exactly `http://localhost:5678/rest/oauth2-credential/callback` |
| **Google: access blocked / app in testing** | Add your Gmail as a **Test user** on the OAuth consent screen |
| **Gmail Trigger returns no body** | Ensure **Simplify = false** (already set in JSON) |
| **Label remove/add fails** | Re-select labels from the dropdown (API needs label **IDs**, not only names) |
| **Sheet append 404 / not found** | Wrong spreadsheet ID, or tab name is not exactly `Leads` |
| **Sheet header mismatch** | Headers must match exactly: Timestamp, Project Type, Budget, Fit Score, Lead Quality, Email Subject, Summary |
| **OpenAI 401** | Invalid/expired API key; recreate OpenAI credential |
| **OpenAI quota / 429** | Billing/limits on OpenAI account; wait or switch model |
| **Parse AI JSON empty fields** | Check OpenAI raw output; ensure `jsonOutput` is on; re-run Parse node |
| **Duplicate processing** | Confirm `Lead-Processed` is added and `Project-Inquiry` removed; static data also tracks message IDs |
| **Workflow never fires** | Workflow must be **Active**; email must have `Project-Inquiry` and must **not** have `Lead-Processed` |
| **Docker volume lost credentials** | Always use named volume `n8n_data`; do not omit `-v n8n_data:/home/node/.n8n` |
| **Timezone wrong** | Set both `GENERIC_TIMEZONE` and `TZ` to `America/Toronto` (already in compose/run) |
| **n8n OpenAI node missing / import warning** | Update image: `docker pull n8nio/n8n:latest` and recreate container |
| **Draft `sendTo` looks wrong** | `from` may include `"Name" <email@x.com>` — Gmail usually accepts this; if not, adjust Prepare Email code to extract the address only |

### Error handling behavior

- OpenAI node uses **continue on error** (error output branch)
- Failures write a sheet row with `Lead Quality = Error` and `Fit Score = 0`
- Holding draft is created; labels are still updated so the email is not reprocessed forever

### Idempotency layers

1. Gmail search: `label:Project-Inquiry -label:Lead-Processed`
2. Workflow static data: last 500 processed message IDs
3. Remove `Project-Inquiry` + add `Lead-Processed` after success/error completion

---

## Workflow logic (summary)

```text
Gmail Trigger (Project-Inquiry, not Lead-Processed)
  → Idempotency + Prepare Email
  → OpenAI Qualify Lead
       ├─ success → Parse AI JSON
       └─ error   → Log AI Failure
  → Append Google Sheets
  → IF Fit Score >= 7
       ├─ true  → High-fit draft
       └─ false → Holding draft
  → Remove Project-Inquiry
  → Add Lead-Processed
```

All nodes used are built-in n8n nodes (Gmail, OpenAI, Google Sheets, Code, IF).
