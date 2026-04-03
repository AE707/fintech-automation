-- retryFailedEvent.sql
-- Manually reset a failed/dead queue event back to 'queued' for re-processing
-- Retool variables: {{eventId}}, {{performedBy}}
-- Use this from the Retool ops panel for dead-letter event recovery

WITH reset_event AS (
  UPDATE event_queue
  SET
    status        = 'queued',
    retry_count   = 0,
    error_message = NULL,
    processed_at  = NULL,
    updated_at    = NOW()
  WHERE
    id = {{ eventId }}::uuid
    AND status IN ('failed', 'dead')  -- only allow retry of terminal-failed events
  RETURNING
    id,
    event_type,
    payload,
    status,
    retry_count,
    updated_at
),
audit_entry AS (
  INSERT INTO audit_log (transaction_id, action, performed_by, details)
  SELECT
    (e.payload->>'transaction_id')::uuid,
    'manual_retry',
    {{ performedBy }},
    jsonb_build_object(
      'event_id',    e.id,
      'event_type',  e.event_type,
      'retried_at',  NOW(),
      'source',      'retool_ops_panel'
    )
  FROM reset_event e
  RETURNING id
)
SELECT
  r.id           AS event_id,
  r.event_type,
  r.status       AS new_status,
  r.retry_count,
  r.updated_at,
  a.id           AS audit_log_id
FROM reset_event r
CROSS JOIN audit_entry a;
