# Flow A — Webhook Ingest

This flow receives incoming transaction events via webhook and writes them to the `queue_events` buffer table.

## Purpose

Decouple the webhook receiver from processing logic. All events land in the queue table immediately, ensuring no events are lost even under high load.

## n8n Nodes

```
[Webhook: POST /webhook/ingest]
    │
    ▼
[Validate: Check required fields]
    │
    ▼
[HTTP Request: POST Supabase /rest/v1/queue_events]
    │
    ▼
[Respond: 202 Accepted]
```

## Webhook Setup

- **Method:** POST
- **Path:** `/webhook/ingest`
- **Authentication:** Header Auth (`x-webhook-secret`)
- **Response mode:** Respond immediately with 202

## Request Payload

```json
{
  "event_type": "transaction.created",
  "payload": {
    "reference": "TXN-001",
    "amount": 5000.00,
    "currency": "USD",
    "sender_id": "uuid",
    "receiver_id": "uuid",
    "metadata": {}
  }
}
```

## Supabase Insert

The flow inserts into `queue_events` with:
- `event_type` from the payload
- `payload` as the full JSON body
- `status` = `queued` (default)
- `attempts` = 0 (default)

## Error Handling

- Missing fields → Respond with 400 Bad Request
- Supabase insert failure → Respond with 503, log error
