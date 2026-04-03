-- getQueueItems.sql
-- List of queue events with optional status filter
-- Retool variables: {{statusFilter}}, {{pageSize}}, {{offset}}

SELECT
  id,
  event_type,
  payload,
  status,
  attempts,
  max_attempts,
  error_message,
  created_at,
  updated_at
FROM queue_events
WHERE
  ({{ statusFilter }} = '' OR status = {{ statusFilter }})
ORDER BY created_at DESC
LIMIT  {{ pageSize }}
OFFSET {{ offset }};
