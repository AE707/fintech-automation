# Queue Buffer System

The queue buffer is a two-flow system that decouples event ingestion from processing, enabling high-throughput and fault-tolerant transaction handling.

## Why a Queue Buffer?

- Prevents data loss under high webhook load
- Allows independent scaling of ingest and processing
- Provides built-in retry logic for failed events
- Creates a complete audit trail of all incoming events

## Flows

| File | Flow | Trigger | Description |
|------|------|---------|-------------|
| `flow-a-ingest.md` | Flow A | HTTP Webhook | Receives events and writes to `queue_events` |
| `flow-b-processor.md` | Flow B | Schedule (30s) | Reads queued events and processes them |

## Database Table: `queue_events`

```sql
status: queued | processing | done | failed | dead
attempts: int (increments on each failure)
max_attempts: int (default 3)
```

## Event Lifecycle

```
POST /webhook/ingest
    │
    ▼
 queue_events (status=queued)
    │
    ▼  [every 30s]
 Flow B picks up batch
    │
    ├─► success ─► status=done
    └─► failure ─► attempts++ ─► re-queue or dead
```

## Configuration

| Setting | Value |
|---------|-------|
| Batch size | 10 events per run |
| Processor interval | 30 seconds |
| Max retry attempts | 3 |
| Auto-approve threshold | < $10,000 |
