-- getAuditLog.sql
-- Full audit trail for a specific transaction with user and event context
-- Retool variables: {{transactionId}}, {{actionFilter}}, {{pageSize}}, {{offset}}

SELECT
  al.id,
  al.action,
  al.performed_by,
  al.details,
  al.created_at,
  -- Transaction summary
  t.reference        AS transaction_reference,
  t.amount           AS transaction_amount,
  t.currency         AS transaction_currency,
  t.status           AS transaction_status,
  -- Time since previous action
  al.created_at - LAG(al.created_at) OVER (
    PARTITION BY al.transaction_id ORDER BY al.created_at
  ) AS time_since_previous_action
FROM audit_log al
JOIN transactions t ON t.id = al.transaction_id
WHERE
  al.transaction_id = {{ transactionId }}::uuid
  AND ({{ actionFilter }} = '' OR al.action = {{ actionFilter }})
ORDER BY al.created_at ASC
LIMIT {{ pageSize }}
OFFSET {{ offset }};
