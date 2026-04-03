-- ============================================================
-- indexes.sql
-- Performance indexes for fintech-automation tables
-- ============================================================

-- transactions
CREATE INDEX IF NOT EXISTS idx_transactions_status
  ON transactions (status);

CREATE INDEX IF NOT EXISTS idx_transactions_sender
  ON transactions (sender_id);

CREATE INDEX IF NOT EXISTS idx_transactions_receiver
  ON transactions (receiver_id);

CREATE INDEX IF NOT EXISTS idx_transactions_created_at
  ON transactions (created_at DESC);

CREATE INDEX IF NOT EXISTS idx_transactions_reference
  ON transactions (reference);

-- audit_log
CREATE INDEX IF NOT EXISTS idx_audit_log_transaction_id
  ON audit_log (transaction_id);

CREATE INDEX IF NOT EXISTS idx_audit_log_created_at
  ON audit_log (created_at DESC);

CREATE INDEX IF NOT EXISTS idx_audit_log_performed_by
  ON audit_log (performed_by);

-- queue_events
CREATE INDEX IF NOT EXISTS idx_queue_events_status
  ON queue_events (status);

CREATE INDEX IF NOT EXISTS idx_queue_events_event_type
  ON queue_events (event_type);

CREATE INDEX IF NOT EXISTS idx_queue_events_created_at
  ON queue_events (created_at ASC);

-- approval_requests
CREATE INDEX IF NOT EXISTS idx_approval_requests_transaction_id
  ON approval_requests (transaction_id);

CREATE INDEX IF NOT EXISTS idx_approval_requests_status
  ON approval_requests (status);
