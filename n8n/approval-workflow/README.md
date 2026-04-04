# n8n Approval Workflow

Handles two-tier transaction approval logic. Low-value transactions (< €50) are auto-approved instantly. High-value transactions (> €50) trigger an email to the manager and wait for a manual decision before updating the transaction status.

---

## Flow Diagram

```
POST /webhook/refund-request
{ transaction_id, amount, user_id, decision, decided_by }
        │
        ▼
┌───────────────────┐
│  Amount over €50? │
└───────────────────┘
        │
   YES  │  NO
        │   └──────────────────────────────────────────────────┐
        │                                                       │
        ▼                                                       ▼
Generate Approval ID                               Auto Approve (PATCH)
(APR-{timestamp})                                  status = approved
Build approve/reject URLs                          approved_by = auto
        │                                                       │
        ▼                                                       ▼
Notify Manager (Gmail)                             Auto Approve Log (POST)
HTML email with links                              audit_log entry
        │                                          performed_by = auto
        ▼
Wait for Manager Decision
(webhook callback with ?action=approve|reject)
        │
        ▼
┌───────────────────────┐
│  Approved or Rejected?│
└───────────────────────┘
        │
  APR   │   REJ
        │    └──→ PATCH status = rejected
        │          └──→ Write to approval_log
        │          └──→ Write to audit_log
        ▼
PATCH status = approved
approved_by = manager email
        │
        ▼
Write to approval_log
Write to audit_log
        │
        ▼
Respond 200 to original webhook
```

---

## Node List

| # | Node | Type | Description |
|---|------|------|-------------|
| 1 | Webhook | Webhook | Receives POST from Retool Approve button |
| 2 | Amount over €50? | IF | Routes by amount threshold |
| 3 | Generate Approval ID | Code | Creates `APR-{timestamp}` ID and approve/reject callback URLs |
| 4 | Notify Manager | Gmail | Sends HTML email with transaction details and action links |
| 5 | Wait for Manager Decision | Webhook | Pauses execution until manager clicks link |
| 6 | Approved or Rejected? | IF | Checks `$json.query.action === 'approve'` |
| 7 | Log Approval | HTTP Request | PATCH `transactions` → status: approved |
| 8 | Log Rejection | HTTP Request | PATCH `transactions` → status: rejected |
| 9 | Write to approval_log | HTTP Request | POST to `approval_log` table |
| 10 | Write to audit_log | HTTP Request | POST to `audit_log` table |
| 11 | Auto Approve | HTTP Request | PATCH `transactions` → status: approved, approved_by: auto |
| 12 | Auto Approve Log | HTTP Request | POST to `audit_log` with action: auto_approved |
| 13 | Respond to Webhook | Respond to Webhook | Returns 200 + result to Retool |

---

## Setup Steps

1. In n8n, click **Import Workflow** and upload `workflow.json`
2. Open each HTTP Request node and replace:
   - `YOUR_SUPABASE_URL` → your Supabase project URL (e.g. `https://abc.supabase.co`)
   - `YOUR_SUPABASE_SERVICE_KEY` → your service_role key from Supabase → Settings → API
3. Open the **Notify Manager** Gmail node:
   - Connect your Gmail credential
   - Update the `To` field with your manager's email address
4. Note the **Webhook** node's Production URL — you will paste this into Retool's `approveTransaction` query
5. Note the **Wait for Manager Decision** webhook URL — this is embedded in the email approve/reject links
6. Toggle the workflow to **Active** (top right switch)
7. Test with Postman using the requests below

---

## Example Postman Request — High Value (triggers email)

```
POST https://your-n8n.app.n8n.cloud/webhook/refund-request
Content-Type: application/json

{
  "transaction_id": 42546,
  "amount": 305.00,
  "user_id": 331,
  "decision": "approved",
  "decided_by": "operator@bunq.com"
}
```

## Example Postman Request — Low Value (auto-approved)

```
POST https://your-n8n.app.n8n.cloud/webhook/refund-request
Content-Type: application/json

{
  "transaction_id": 906,
  "amount": 19.99,
  "user_id": 6,
  "decision": "approved",
  "decided_by": "operator@bunq.com"
}
```

---

## Key Design Decisions

**Why a Wait node instead of polling?**
The Wait node suspends the workflow execution until the manager responds. This uses zero compute while waiting and resumes instantly when the callback fires — no polling loop required.

**Why separate approval_log from audit_log?**
`audit_log` captures every system action at any granularity. `approval_log` captures only manager decisions on high-value transactions. This allows compliance teams to query manager accountability separately from general operational logs.

**Why HTML email with embedded links?**
The manager can approve or reject directly from their email client with a single click — no login to any system required. The approve/reject URLs carry the approval_id and action as query parameters which the Wait node reads on callback.
