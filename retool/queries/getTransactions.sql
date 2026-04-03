-- getTransactions.sql
-- Paginated list of transactions with optional status filter
-- Retool variables: {{statusFilter}}, {{pageSize}}, {{offset}}

SELECT
  id,
  reference,
  amount,
  currency,
  sender_id,
  receiver_id,
  status,
  metadata,
  created_at,
  updated_at
FROM transactions
WHERE
  ({{ statusFilter }} = '' OR status = {{ statusFilter }})
ORDER BY created_at DESC
LIMIT  {{ pageSize }}
OFFSET {{ offset }};
