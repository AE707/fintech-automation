# Flow B — Queue Processor

This flow runs on a schedule (cron) and processes queued events from the `queue_events` table one batch at a time.

## Purpose

Consume queued events, apply business logic, route to the correct outcome (approve / flag for manual review), and update status accordingly.

## n8n Nodes

```
[Schedule Trigger: every 30 seconds]
    │
    ▼
[HTTP: GET queued events from Supabase]
    │  (status=queued, limit=10, order=created_at asc)
    ▼
[Loop over items]
    │
    ▼
[HTTP: PATCH queue_events status=processing]
    │
    ▼
[Switch: event_type]
    │
    ├─ transaction.created ─► [Business Logic: Check amount threshold]
    │                               │
    │              ┌─────────────┴─────────────┐
    │              ▼                             ▼
    │         [amount < 10000]           [amount >= 10000]
    │              ▼                             ▼
    │    [Insert transactions           [Insert approval_request]
    │     status=approved]             [Notify approval workflow]
    │
    └─ other ─► [Log and skip]
    │
    ▼
[HTTP: PATCH queue_events status=done]
    │
    ▼
[On Error: increment attempts, set failed/dead]
```

## Schedule Configuration

- **Trigger:** Schedule (Interval)
- **Every:** 30 seconds
- **Batch size:** 10 events per run

## Business Rules

| Condition | Action |
|-----------|--------|
| `amount < 10,000` | Auto-approve: insert to `transactions` with `status=approved` |
| `amount >= 10,000` | Flag: insert to `approval_requests`, notify reviewer |

## Retry Logic

- On processing failure: increment `attempts`
- If `attempts >= max_attempts`: set status to `dead`
- Otherwise: reset to `queued` for retry

## Status Flow

```
queued → processing → done
                  └→ failed → dead (if attempts exhausted)
```
