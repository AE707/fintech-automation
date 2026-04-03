-- retryFailedEvent.sql
-- Reset a failed/dead queue event back to queued for retry
-- Retool variables: {{eventId}}

UPDATE queue_events
SET
  status        = 'queued',
  attempts      = 0,
  error_message = NULL,
  updated_at    = NOW()
WHERE id = {{ eventId }}::UUID
RETURNING id, status, attempts, updated_at;
