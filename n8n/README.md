# n8n Workflows

This directory contains all n8n automation workflows powering the fintech-automation stack. Each sub-workflow is modular and communicates via Supabase's `event_queue` table.

---

## Workflow Modules

| Folder | Purpose | Trigger |
|--------|---------|--------|
| `approval-workflow/` | Manual transaction approval via Retool + n8n | Webhook (POST) |
| `queue-buffer/` | High-throughput webhook ingestion and queue buffering | Webhook (POST) |
| `queue-error-handler/` | Dead-letter queue retry and error alerting | Scheduled (every 5 min) |

---

## Architecture Overview

```
Incoming Webhook (POST /webhook/transaction)
        |
        v
[queue-buffer] --> Inserts row into event_queue (status: queued)
        |
        v
[transaction-processor] -- polls event_queue WHERE status='queued'
        |               |
        v               v
   [approved]      [rejected]
        |               |
        v               v
  Update txn       Update txn
  status='approved' status='rejected'
        |
        v
[queue-error-handler] -- retries failed rows, alerts on repeated failures
```

---

## Environment Variables

All workflows require the following n8n credentials and env vars:

```env
SUPABASE_URL=https://<your-project>.supabase.co
SUPABASE_SERVICE_KEY=<service_role_key>
RETOOL_WEBHOOK_SECRET=<shared_secret>
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/...
N8N_BASE_URL=https://<your-n8n-instance>
```

---

## Setup Instructions

1. Import each workflow JSON from the respective subfolder into your n8n instance
2. Configure credentials (Supabase, Slack, HTTP Basic Auth)
3. Set all required environment variables
4. Activate workflows in the following order:
   - `queue-buffer` first (ingestion layer)
   - `transaction-processor` second (processing layer)
   - `approval-workflow` third (manual review layer)
   - `queue-error-handler` last (error recovery layer)

---

## Data Flow

```
Webhook Payload
  --> event_queue (queued)
    --> processor picks up
      --> transactions table updated
        --> audit_log entry created
          --> Retool dashboard reflects changes
```

---

## Error Handling Strategy

- **Retry**: Failed events are retried up to 3 times with exponential backoff
- **Dead-letter**: After 3 failures, event is marked `status='dead'`
- **Alert**: Slack notification sent for dead-letter events
- **Manual Review**: Dead-letter events visible in Retool for manual intervention

---

## Dependencies

- n8n >= 1.0.0
- Supabase project with schema from `../supabase/schema.sql`
- Slack workspace (for alerts)
- Retool application (for manual approval UI)
