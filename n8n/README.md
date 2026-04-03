# n8n Workflows

This folder contains all n8n automation workflows for the fintech-automation stack.

## Workflow Modules

| Folder | Purpose |
|--------|---------|
| `approval-workflow/` | Manual transaction approval flow via Retool + n8n |
| `queue-buffer/` | High-throughput webhook ingestion and processing queue |
| `queue-error-handler/` | Dead-letter queue and retry error handling |

## Architecture Overview

```
Webhook (POST)
    │
    ▼
[Flow A: Ingest] ──► queue_events table (status: queued)
                           │
                           ▼
                   [Flow B: Processor]
                           │
               ┌───────────┴───────────┐
               ▼                       ▼
         [Approved]              [Needs Review]
               │                       │
               ▼                       ▼
    transactions (approved)   approval_requests
                                       │
                               [Approval Workflow]
                                       │
                               Retool Dashboard
```

## Environment Variables Required

```
SUPABASE_URL=https://<project>.supabase.co
SUPABASE_SERVICE_KEY=<service-role-key>
N8N_WEBHOOK_SECRET=<webhook-secret>
```

## Deployment

1. Import each workflow JSON into your n8n instance
2. Set the environment variables in n8n settings
3. Activate the workflows in order: Flow A → Flow B → Approval → Error Handler
