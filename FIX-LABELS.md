# Fix: Invalid label + wrong Message ID

## What the error means

`Invalid label: Project-Inquiry` = Gmail API got a **label name**, but this operation needs the label **ID** from the dropdown.

Also your Message ID showed `1a00c17b18d1739e` which is a **threadId**, not the inbox message id — that makes label changes fail.

---

## Fix in n8n (do exactly this)

### 1) Fix Message ID on both label nodes

Open **Remove Project-Inquiry Label**:

1. Message ID → expression mode
2. Replace with:

```text
{{ $('Idempotency + Prepare Email').first().json.messageId }}
```

(Use `.first()`, not `.item`)

Do the same on **Add Lead-Processed Label**.

### 2) Re-select labels from dropdown (important)

On **Remove Project-Inquiry Label**:

1. Clear the red **Label Names or IDs** field
2. Open the dropdown
3. Click **`Project-Inquiry`** from the list (do not type it)

On **Add Lead-Processed Label**:

1. Clear labels
2. Pick **`Lead-Processed`** from the dropdown

### 3) Confirm Prepare Email has the real message id

1. Open **Idempotency + Prepare Email**
2. Run/check output
3. `messageId` must **not** equal `threadId`
4. `messageId` should match the Gmail Trigger message `id`

If they are equal, in Prepare Email code use:

```js
const messageId = item.id || item.messageId;
const threadId = item.threadId;
```

and make sure you don’t assign `threadId` into `messageId`.

### 4) Retest with a NEW email

1. Send a new test email (plain text)
2. Apply `Project-Inquiry`
3. Execute workflow
4. Confirm label is removed and `Lead-Processed` is added

---

## About the Google security emails

Those “password changed / sign-in blocked” alerts are separate from n8n.  
Open them in Gmail and confirm it was you. If not, change your Google password.
