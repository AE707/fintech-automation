-- rejectTransaction.sql
-- Manually reject a transaction from Retool with reason, audit trail and queue update
-- Retool variables: {{transactionId}}, {{rejectionReason}}, {{performedBy}}
-- NOTE: Run inside a Retool query with "Run as transaction" enabled

WITH rejected_tx AS (
  UPDATE transactions
  SET
    status   = 'rejected',
    metadata = metadata || jsonb_build_object(
      'rejection_reason',  {{ rejectionReason }},
      'rejected_by',       {{ performedBy }},
      'rejected_at',       NOW()
    ),
    updated_at = NOW()
  WHERE
    id = {{ transactionId }}::uuid
    AND status NOT IN ('approved', 'rejected')  -- guard: cannot reject already-terminal tx
  RETURNING id, reference, amount, currency, status
),
audit_entry AS (
  INSERT INTO audit_log (transaction_id, action, performed_by, details)
  SELECT
    r.id,
    'manual_rejection',
    {{ performedBy }},
    jsonb_build_object(
      'reason',      {{ rejectionReason }},
      'rejected_at', NOW(),
      'source',      'retool_dashboard'
    )
  FROM rejected_tx r
  RETURNING id
),
queue_update AS (
  UPDATE event_queue
  SET
    status       = 'done',
    processed_at = NOW()
  WHERE
    (payload->>'transaction_id')::uuid = {{ transactionId }}::uuid
    AND status = 'queued'
)
SELECT
  r.id                AS transaction_id,
  r.reference,
  r.amount,
  r.currency,
  r.status            AS new_status,
  a.id                AS audit_log_id,
  NOW()               AS processed_at
FROM rejected_tx r
CROSS JOIN audit_entry a;
