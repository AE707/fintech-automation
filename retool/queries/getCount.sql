-- getCount.sql
-- Total count of transactions for pagination
-- Retool variables: {{statusFilter}}

SELECT COUNT(*) AS total
FROM transactions
WHERE
  ({{ statusFilter }} = '' OR status = {{ statusFilter }});
