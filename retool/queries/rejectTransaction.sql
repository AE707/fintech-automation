-- rejectTransaction.sql
-- Mark a transaction as rejected and record reason
-- Retool variables: {{transactionId}}, {{rejectedBy}}, {{note}}

UPDATE transactions
SET
  status     = 'rejected',
  updated_at = NOW()
WHERE id = {{ transactionId }}::UUID
RETURNING id, reference, status, updated_at;
