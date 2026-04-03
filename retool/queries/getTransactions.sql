-- getTransactions.sql
-- Paginated list of transactions with rich filtering and joined data
-- Retool variables: {{statusFilter}}, {{currencyFilter}}, {{searchTerm}}, {{pageSize}}, {{offset}}, {{dateFrom}}, {{dateTo}}

SELECT
  t.id,
  t.reference,
  t.amount,
  t.currency,
  t.status,
  t.sender_id,
  t.receiver_id,
  t.metadata,
  t.created_at,
  t.updated_at,
  -- Sender account info
  sa.account_number  AS sender_account_number,
  sa.account_type    AS sender_account_type,
  -- Receiver account info
  ra.account_number  AS receiver_account_number,
  ra.account_type    AS receiver_account_type,
  -- Latest audit action
  (
    SELECT al.action
    FROM audit_log al
    WHERE al.transaction_id = t.id
    ORDER BY al.created_at DESC
    LIMIT 1
  ) AS last_audit_action,
  -- Event queue status
  (
    SELECT eq.status
    FROM event_queue eq
    WHERE (eq.payload->>'transaction_id')::uuid = t.id
    ORDER BY eq.created_at DESC
    LIMIT 1
  ) AS queue_status
FROM transactions t
LEFT JOIN accounts sa ON sa.id = t.sender_id
LEFT JOIN accounts ra ON ra.id = t.receiver_id
WHERE
  -- Status filter
  ({{ statusFilter }} = '' OR t.status = {{ statusFilter }})
  -- Currency filter
  AND ({{ currencyFilter }} = '' OR t.currency = {{ currencyFilter }})
  -- Search by reference or metadata
  AND (
    {{ searchTerm }} = ''
    OR t.reference ILIKE '%' || {{ searchTerm }} || '%'
    OR t.metadata::text ILIKE '%' || {{ searchTerm }} || '%'
  )
  -- Date range filter
  AND ({{ dateFrom }} = '' OR t.created_at >= {{ dateFrom }}::timestamptz)
  AND ({{ dateTo }} = '' OR t.created_at <= {{ dateTo }}::timestamptz)
ORDER BY t.created_at DESC
LIMIT {{ pageSize }}
OFFSET {{ offset }};
