-- =============================================================
-- triggers.sql
-- Auto-update updated_at + set processed_at for event_queue
-- =============================================================

-- Shared trigger function: sets updated_at on every UPDATE
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

-- event_queue: also set processed_at when status changes to done/failed
CREATE OR REPLACE FUNCTION set_event_queue_processed_at()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status IN ('done', 'failed') AND OLD.status NOT IN ('done', 'failed') THEN
    NEW.processed_at = NOW();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_event_queue_processed_at ON event_queue;
CREATE TRIGGER trg_event_queue_processed_at
  BEFORE UPDATE ON event_queue
  FOR EACH ROW
  EXECUTE FUNCTION set_event_queue_processed_at();
