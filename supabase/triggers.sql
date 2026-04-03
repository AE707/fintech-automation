-- ============================================================
-- triggers.sql
-- Auto-update updated_at timestamps for fintech-automation
-- ============================================================

-- Reusable trigger function
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- transactions
DROP TRIGGER IF EXISTS trg_transactions_updated_at ON transactions;
CREATE TRIGGER trg_transactions_updated_at
  BEFORE UPDATE ON transactions
  FOR EACH ROW
  EXECUTE FUNCTION set_updated_at();

-- queue_events
DROP TRIGGER IF EXISTS trg_queue_events_updated_at ON queue_events;
CREATE TRIGGER trg_queue_events_updated_at
  BEFORE UPDATE ON queue_events
  FOR EACH ROW
  EXECUTE FUNCTION set_updated_at();

-- approval_requests
DROP TRIGGER IF EXISTS trg_approval_requests_updated_at ON approval_requests;
CREATE TRIGGER trg_approval_requests_updated_at
  BEFORE UPDATE ON approval_requests
  FOR EACH ROW
  EXECUTE FUNCTION set_updated_at();
