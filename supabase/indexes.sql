-- ============================================================
-- indexes.sql
-- Performance indexes for fintech-automation
-- Covers: transactions, audit_log, approval_log, event_queue
-- ============================================================

-- ============================================================
-- transactions: common query patterns
-- ============================================================
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

-- Composite: dashboard default view (status + created_at)
CREATE INDEX IF NOT EXISTS idx_transactions_status_created
  ON transactions (status, created_at DESC);

-- Composite: filter by user + status (user transaction history)
CREATE INDEX IF NOT EXISTS idx_transactions_user_status
  ON transactions (user_id, status);

-- Composite: filter by type + status (e.g. pending payments)
CREATE INDEX IF NOT EXISTS idx_transactions_type_status
  ON transactions (type, status);

-- ============================================================
-- audit_log: compliance queries
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_audit_log_transaction_id
  ON audit_log (transaction_id);

CREATE INDEX IF NOT EXISTS idx_audit_log_performed_by
  ON audit_log (performed_by);

CREATE INDEX IF NOT EXISTS idx_audit_log_action
  ON audit_log (action);

CREATE INDEX IF NOT EXISTS idx_audit_log_created_at
  ON audit_log (created_at DESC);

-- Composite: transaction audit trail (most common query)
CREATE INDEX IF NOT EXISTS idx_audit_log_txn_created
  ON audit_log (transaction_id, created_at ASC);

-- ============================================================
-- approval_log: manager approval workflow queries
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_approval_log_approval_id
  ON approval_log (approval_id);

CREATE INDEX IF NOT EXISTS idx_approval_log_status
  ON approval_log (status);

CREATE INDEX IF NOT EXISTS idx_approval_log_user_id
  ON approval_log (user_id);

CREATE INDEX IF NOT EXISTS idx_approval_log_created_at
  ON approval_log (created_at DESC);

-- ============================================================
-- event_queue: n8n polling and priority processing
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_event_queue_status
  ON event_queue (status);

CREATE INDEX IF NOT EXISTS idx_event_queue_event_type
  ON event_queue (event_type);

CREATE INDEX IF NOT EXISTS idx_event_queue_received_at
  ON event_queue (received_at DESC);

CREATE INDEX IF NOT EXISTS idx_event_queue_retry_count
  ON event_queue (retry_count);

-- Composite: the primary n8n poll query (pending events by priority)
-- SELECT * FROM event_queue WHERE status='pending' ORDER BY priority DESC, received_at ASC
CREATE INDEX IF NOT EXISTS idx_event_queue_status_priority
  ON event_queue (status, priority DESC, received_at ASC);

-- Composite: error handler query (failed events for retry)
CREATE INDEX IF NOT EXISTS idx_event_queue_failed_retry
  ON event_queue (status, retry_count)
  WHERE status = 'failed';

-- Index on JSONB payload for transaction_id lookups
CREATE INDEX IF NOT EXISTS idx_event_queue_payload_gin
  ON event_queue USING GIN (payload);
