-- getAuditLog.sql
-- Audit log entries for a specific transaction
-- Retool variables: {{transactionId}}

SELECT
  al.id,
  al.action,
  al.performed_by,
  al.note,
  al.created_at
FROM audit_log al
WHERE al.transaction_id = {{ transactionId }}::UUID
ORDER BY al.created_at ASC;
