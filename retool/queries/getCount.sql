-- getCount.sql
-- Total count of transactions for pagination (matches getTransactions.sql filters)
-- Retool variables: {{statusFilter}}, {{currencyFilter}}, {{searchTerm}}, {{dateFrom}}, {{dateTo}}

SELECT COUNT(*) AS total
FROM transactions
WHERE
  ({{ statusFilter }} = '' OR status = {{ statusFilter }})
  AND ({{ currencyFilter }} = '' OR currency = {{ currencyFilter }})
  AND (
    {{ searchTerm }} = ''
    OR reference ILIKE '%' || {{ searchTerm }} || '%'
    OR metadata::text ILIKE '%' || {{ searchTerm }} || '%'
  )
  AND ({{ dateFrom }} = '' OR created_at >= {{ dateFrom }}::timestamptz)
  AND ({{ dateTo }} = '' OR created_at <= {{ dateTo }}::timestamptz);
