# Queue Error Handler Workflow

This n8n workflow is the reliability layer of the fintech-automation stack. It monitors the `event_queue` table for failed and dead-letter events, attempts intelligent retries, and alerts the operations team when manual intervention is required.

---

## Overview

```
[Schedule Trigger: every 5 min]
        |
        v
[Supabase: SELECT failed events with retry_count < 3]
        |
      [IF] events exist?
       /         \
     YES          NO
      |            |
      v            v
[Retry each]    [EXIT]
      |
   [IF] retry success?
    /         \
  YES          NO
   |            |
   v            v
[Mark done]  [Increment retry_count]
                  |
               [IF] retry_count >= 3?
                /         \
              YES          NO
               |            |
               v            v
         [Mark 'dead']   [EXIT]
         [Slack Alert]
         [Audit Log]
```

---

## Workflow Steps

### 1. Schedule Trigger
- Fires every 5 minutes
- Can be adjusted in n8n Cron settings

### 2. Fetch Failed Events
```sql
SELECT eq.id, eq.payload, eq.event_type, eq.retry_count,
       eq.error_message, eq.created_at, eq.processed_at
FROM event_queue eq
WHERE eq.status IN ('failed', 'dead')
  AND eq.created_at > NOW() - INTERVAL '24 hours'
ORDER BY eq.retry_count ASC, eq.created_at ASC
LIMIT 50;
```

### 3. Retry Logic

| retry_count | Wait Before Retry | Action |
|------------|-------------------|--------|
| 0 | 0 min | Immediate retry |
| 1 | 5 min | Short backoff |
| 2 | 15 min | Medium backoff |
| 3+ | N/A | Mark dead, alert |

### 4. On Successful Retry
```sql
UPDATE event_queue
SET status = 'done',
    processed_at = NOW(),
    error_message = NULL
WHERE id = $1;
```

### 5. On Max Retries Exceeded
```sql
UPDATE event_queue
SET status = 'dead',
    retry_count = retry_count + 1
WHERE id = $1;

INSERT INTO audit_log (transaction_id, action, performed_by, details)
VALUES (
  (payload->>'transaction_id')::uuid,
  'dead_letter',
  'n8n-error-handler',
  jsonb_build_object('event_id', $1, 'retry_count', retry_count, 'error', error_message)
);
```

### 6. Slack Alert Payload
```json
{
  "text": ":red_circle: Dead-letter event detected",
  "blocks": [
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "*Event ID*: `{{event_id}}`\n*Type*: `{{event_type}}`\n*Error*: `{{error_message}}`\n*Retries*: {{retry_count}}\n*Created*: {{created_at}}"
      }
    },
    {
      "type": "actions",
      "elements": [{
        "type": "button",
        "text": { "type": "plain_text", "text": "View in Retool" },
        "url": "{{RETOOL_DASHBOARD_URL}}/event/{{event_id}}"
      }]
    }
  ]
}
```

---

## Configuration

| Variable | Description |
|----------|-------------|
| `SUPABASE_URL` | Supabase project URL |
| `SUPABASE_SERVICE_KEY` | Service role key |
| `SLACK_WEBHOOK_URL` | Slack incoming webhook URL |
| `RETOOL_DASHBOARD_URL` | Base URL of Retool app |
| `MAX_RETRIES` | Max retry count before dead-letter (default: 3) |
| `LOOKBACK_HOURS` | How far back to scan for failed events (default: 24) |

---

## Dead Letter Strategy

1. **Detect** - Scheduled scan picks up events with `status='failed'` and `retry_count >= 3`
2. **Alert** - Slack notification sent to ops channel with full event context
3. **Log** - Audit entry created for compliance trail
4. **Manual Review** - Ops team reviews in Retool dashboard
5. **Manual Retry** - Retool action can reset `retry_count=0` and `status='queued'` to force re-process

---

## Workflow File

Import `workflow.json` into your n8n instance to get started.
