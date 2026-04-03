-- getQueueStats.sql
-- Queue health summary with throughput, avg processing time and error rates
-- Retool variables: none

SELECT
  -- Status counts
  COUNT(*) FILTER (WHERE status = 'queued')      AS queued,
  COUNT(*) FILTER (WHERE status = 'processing')  AS processing,
  COUNT(*) FILTER (WHERE status = 'done')        AS done,
  COUNT(*) FILTER (WHERE status = 'failed')      AS failed,
  COUNT(*) FILTER (WHERE status = 'dead')        AS dead,
  COUNT(*)                                       AS total,

  -- Error rate
  ROUND(
    100.0 * COUNT(*) FILTER (WHERE status IN ('failed', 'dead')) / NULLIF(COUNT(*), 0),
    2
  ) AS error_rate_pct,

  -- Average processing time (for done events)
  ROUND(
    AVG(
      EXTRACT(EPOCH FROM (processed_at - created_at))
    ) FILTER (WHERE status = 'done' AND processed_at IS NOT NULL),
    2
  ) AS avg_processing_seconds,

  -- Overdue events (queued > 10 min)
  COUNT(*) FILTER (
    WHERE status = 'queued'
    AND created_at < NOW() - INTERVAL '10 minutes'
  ) AS overdue_queued,

  -- Today's throughput
  COUNT(*) FILTER (
    WHERE status = 'done'
    AND processed_at >= CURRENT_DATE
  ) AS processed_today,

  -- Max retry count among failed
  MAX(retry_count) FILTER (WHERE status IN ('failed', 'dead')) AS max_retry_count

FROM event_queue;
