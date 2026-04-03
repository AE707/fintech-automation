-- =============================================================
-- indexes.sql
-- Performance indexes for fintech-automation
-- =============================================================

-- transactions: most common query patterns
CREATE INDEX IF NOT EXISTS idx_transactions_status
  ON transactions (status);

CREATE INDEX IF NOT EXISTS idx_transactions_user_id
  ON transactions (user_id);

CREATE INDEX IF NOT EXISTS idx_transactions_type
  ON transactions (type);

CREATE INDEX IF NOT EXISTS idx_transactions_created_at
  ON transactions (created_at DESC);

CREATE INDEX IF NOT EXISTS idx_transactions_amount
  ON transactions (amount);

-- audit_log
CREATE INDEX IF NOT EXISTS idx_audit_log_transaction_id
  ON audit_log (transaction_id);

CREATE INDEX IF NOT EXISTS idx_audit_log_created_at
  ON audit_log (created_at DESC);

CREATE INDEX IF NOT EXISTS idx_audit_log_performed_by
  ON audit_log (performed_by);

-- approval_log
CREATE INDEX IF NOT EXISTS idx_approval_log_approval_id
  ON approval_log (approval_id);

CREATE INDEX IF NOT EXISTS idx_approval_log_user_id
  ON approval_log (user_id);

CREATE INDEX IF NOT EXISTS idx_approval_log_status
  ON approval_log (status);

-- event_queue: critical for processor performance
CREATE INDEX IF NOT EXISTS idx_event_queue_status
  ON event_queue (status);

CREATE INDEX IF NOT EXISTS idx_event_queue_priority_received
  ON event_queue (priority ASC, received_at ASC)
  WHERE status = 'pending';  -- partial index: only pending events

CREATE INDEX IF NOT EXISTS idx_event_queue_event_type
  ON event_queue (event_type);

CREATE INDEX IF NOT EXISTS idx_event_queue_received_at
  ON event_queue (received_at ASC);
