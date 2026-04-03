-- =============================================================
-- schema.sql
-- Supabase / PostgreSQL — fintech-automation database schema
-- Tables: transactions, audit_log, approval_log, event_queue
-- =============================================================

-- =============================================================
-- transactions
-- Core table storing all financial transactions
-- =============================================================
CREATE TABLE IF NOT EXISTS transactions (
  id               SERIAL PRIMARY KEY,
  user_id          INT            NOT NULL,
  amount           NUMERIC(18,2)  NOT NULL,
  type             VARCHAR(50),                        -- payment | transfer | refund
  status           VARCHAR(50)    DEFAULT 'pending',   -- pending | approved | rejected | processing
  created_at       TIMESTAMP      DEFAULT NOW(),
  approved_by      VARCHAR(100),
  approved_at      TIMESTAMP,
  rejection_reason TEXT,
  updated_at       TIMESTAMPTZ    DEFAULT NOW()
);

-- =============================================================
-- audit_log
-- Complete action history — every operator action is recorded
-- =============================================================
CREATE TABLE IF NOT EXISTS audit_log (
  id             SERIAL PRIMARY KEY,
  action         VARCHAR(100)  NOT NULL,               -- approved | rejected | retried | viewed
  transaction_id INT           REFERENCES transactions(id) ON DELETE SET NULL,
  performed_by   VARCHAR(100),                         -- operator email or system
  details        TEXT,
  created_at     TIMESTAMP     DEFAULT NOW()
);

-- =============================================================
-- approval_log
-- Manager decisions on high-value transactions (amount > 50)
-- =============================================================
CREATE TABLE IF NOT EXISTS approval_log (
  id          SERIAL PRIMARY KEY,
  approval_id VARCHAR(100),                            -- unique approval reference from n8n
  user_id     INT,
  amount      NUMERIC(18,2),
  status      VARCHAR(50),                             -- approved | rejected
  decided_at  TIMESTAMP,
  created_at  TIMESTAMP    DEFAULT NOW()
);

-- =============================================================
-- event_queue
-- Event processing buffer — decouples ingest from processing
-- =============================================================
CREATE TABLE IF NOT EXISTS event_queue (
  id            UUID         DEFAULT gen_random_uuid() PRIMARY KEY,
  event_type    TEXT         NOT NULL,                 -- payment | transfer | refund
  payload       JSONB        NOT NULL,
  status        TEXT         DEFAULT 'pending'
                  CHECK (status IN ('pending', 'processing', 'done', 'failed')),
  priority      INT          DEFAULT 5,                -- 1 = highest, 10 = lowest
  retry_count   INT          DEFAULT 0,
  error_message TEXT,
  received_at   TIMESTAMPTZ  DEFAULT NOW(),
  processed_at  TIMESTAMPTZ,
  created_by    TEXT         DEFAULT 'n8n-webhook'
);
