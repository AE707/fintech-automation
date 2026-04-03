-- getQueueItems.sql
-- Paginated event queue items with joined transaction data and retry info
-- Retool variables: {{statusFilter}}, {{eventTypeFilter}}, {{pageSize}}, {{offset}}

SELECT
  eq.id,
  eq.event_type,
  eq.payload,
  eq.status,
  eq.retry_count,
  eq.error_message,
  eq.created_at,
  eq.processed_at,
  eq.updated_at,
  -- Linked transaction info
  t.id          AS transaction_id,
  t.reference   AS transaction_reference,
  t.amount      AS transaction_amount,
  t.currency    AS transaction_currency,
  t.status      AS transaction_status,
  -- Time in queue
  EXTRACT(EPOCH FROM (NOW() - eq.created_at)) / 60  AS minutes_in_queue,
  -- Is this overdue? (queued for more than 10 minutes)
  CASE
    WHEN eq.status = 'queued' AND eq.created_at < NOW() - INTERVAL '10 minutes'
    THEN true ELSE false
  END AS is_overdue
FROM event_queue eq
LEFT JOIN transactions t
  ON t.id = (eq.payload->>'transaction_id')::uuid
WHERE
  ({{ statusFilter }} = '' OR eq.status = {{ statusFilter }})
  AND ({{ eventTypeFilter }} = '' OR eq.event_type = {{ eventTypeFilter }})
ORDER BY eq.created_at DESC
LIMIT {{ pageSize }}
OFFSET {{ offset }};
