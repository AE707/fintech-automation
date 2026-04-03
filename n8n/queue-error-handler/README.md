# Queue Error Handler

This n8n workflow monitors for dead-letter events in the `queue_events` table and alerts the operations team.

## Purpose

Handle events that have exceeded their maximum retry attempts (`status = 'dead'`) by notifying the team and optionally allowing manual retry via Retool.

## How It Works

1. **Schedule Trigger** — Runs every 5 minutes
2. **Query** — Fetches all events with `status = 'dead'` created in the last 24 hours
3. **Check** — If dead events exist, send alert
4. **Notify** — Sends Slack/email with event IDs and error messages
5. **Log** — Inserts notification record into audit_log

## n8n Nodes

```
[Schedule: every 5 minutes]
    │
    ▼
[HTTP: GET dead events from Supabase]
    │  (status=dead, created_at > now-24h)
    ▼
[IF: items.length > 0]
    │
    ▼
[Slack/Email: Alert with dead event list]
    │
    ▼
[HTTP: POST audit_log - error_alert]
```

## Alert Content

```
Subject: [ALERT] Dead queue events detected
Body:
  - Count: N events stuck in dead status
  - IDs: [uuid1, uuid2, ...]
  - Errors: [error messages]
  - Action: Visit Retool dashboard to retry or reject
```

## Manual Retry

Operators can retry dead events from the Retool dashboard using the `retryFailedEvent.sql` query which:
1. Resets `status` to `queued`
2. Resets `attempts` to 0
3. Clears `error_message`

## Configuration

| Variable | Description |
|----------|-------------|
| `SLACK_WEBHOOK_URL` | Slack incoming webhook URL |
| `ALERT_EMAIL` | Email address for error alerts |
| `SUPABASE_URL` | Supabase project URL |
| `SUPABASE_SERVICE_KEY` | Service role key |
