# Transaction Processor Workflow

This n8n workflow is the core processing engine of the fintech-automation stack. It polls the `event_queue` table in Supabase and processes pending transactions.

---

## Overview

```
[Schedule Trigger: every 30s]
        |
        v
[Supabase: SELECT from event_queue WHERE status='queued' LIMIT 10]
        |
        v
[SplitInBatches: process one by one]
        |
        v
[Switch: route by event_type]
   |           |           |
 [transfer] [payment]  [reversal]
   |           |           |
   v           v           v
[Validate] [Validate] [Validate]
   |           |           |
   v           v           v
[Update transactions table]
   |           |
[approved] [rejected]
   |           |
   v           v
[Update event_queue status]
   |
   v
[Insert audit_log entry]
```

---

## Workflow Steps

### 1. Schedule Trigger
- Fires every 30 seconds
- Configurable via n8n Cron settings

### 2. Fetch Queued Events
```sql
SELECT eq.id, eq.payload, eq.event_type, eq.retry_count,
       t.id AS transaction_id, t.amount, t.currency, t.status
FROM event_queue eq
JOIN transactions t ON t.id = (eq.payload->>'transaction_id')::uuid
WHERE eq.status = 'queued'
  AND eq.retry_count < 3
ORDER BY eq.created_at ASC
LIMIT 10
FOR UPDATE SKIP LOCKED;
```

### 3. Validation Rules

| Check | Rule | Action on Fail |
|-------|------|----------------|
| Amount | > 0 and <= 1,000,000 | Reject with reason |
| Currency | In allowed list (USD, EUR, GBP, MAD) | Reject with reason |
| Account | Sender account active | Reject with reason |
| Duplicate | No duplicate in last 60s | Reject with reason |
| Balance | Sufficient funds | Reject with reason |

### 4. Update Transaction
```sql
UPDATE transactions
SET status = $1,  -- 'approved' or 'rejected'
    metadata = metadata || jsonb_build_object(
      'processed_by', 'n8n-transaction-processor',
      'processed_at', NOW(),
      'rejection_reason', $2
    )
WHERE id = $3;
```

### 5. Update Event Queue
```sql
UPDATE event_queue
SET status = $1,  -- 'done' or 'failed'
    processed_at = NOW()
WHERE id = $2;
```

### 6. Create Audit Log
```sql
INSERT INTO audit_log (transaction_id, action, performed_by, details)
VALUES ($1, $2, 'n8n-processor', $3::jsonb);
```

---

## Error Handling

- On any step failure: increment `retry_count` in `event_queue`
- After 3 retries: mark as `status='failed'`, trigger Slack alert
- All errors logged to n8n execution log

---

## Configuration

| Variable | Description |
|----------|-------------|
| `SUPABASE_URL` | Supabase project URL |
| `SUPABASE_SERVICE_KEY` | Service role key (bypasses RLS) |
| `BATCH_SIZE` | Events per run (default: 10) |
| `MAX_RETRIES` | Max retry attempts (default: 3) |

---

## Workflow File

Import `workflow.json` into your n8n instance to get started.
