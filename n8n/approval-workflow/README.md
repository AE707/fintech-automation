# Approval Workflow

This n8n workflow handles manual transaction approval for flagged or high-value transactions.

## How It Works

1. **Trigger** — An approval request is inserted into the `approval_requests` table (by Flow B or Retool)
2. **n8n Polling / Webhook** — n8n detects the new pending request
3. **Notification** — An alert is sent to the operations team (email / Slack)
4. **Retool Dashboard** — The reviewer sees the request in the Retool admin panel
5. **Decision** — The reviewer clicks Approve or Reject in Retool
6. **Retool calls n8n webhook** — Sends `{ transaction_id, action, decision_by, note }`
7. **n8n updates Supabase** — Updates `transactions.status` and inserts into `audit_log`

## Workflow Steps (n8n nodes)

```
[Webhook: /approval-decision]
    │
    ▼
[Switch: action == 'approve' | 'reject']
    │                    │
    ▼                    ▼
[HTTP: update      [HTTP: update
 transactions      transactions
 status=approved]  status=rejected]
    │                    │
    └────▼────┘
         │
         ▼
[HTTP: insert audit_log]
```

## Webhook Payload

```json
{
  "transaction_id": "uuid",
  "action": "approve" | "reject",
  "decision_by": "admin@company.com",
  "note": "Verified with customer"
}
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `SUPABASE_URL` | Supabase project URL |
| `SUPABASE_SERVICE_KEY` | Service role key for DB writes |
| `SLACK_WEBHOOK_URL` | (Optional) Slack notification webhook |
