-- getQueueStats.sql
-- Queue health summary for the monitoring panel

SELECT
  COUNT(*) FILTER (WHERE status = 'queued')       AS queued,
  COUNT(*) FILTER (WHERE status = 'processing')   AS processing,
  COUNT(*) FILTER (WHERE status = 'done')         AS done,
  COUNT(*) FILTER (WHERE status = 'failed')       AS failed,
  COUNT(*) FILTER (WHERE status = 'dead')         AS dead,
  COUNT(*)                                         AS total
FROM queue_events;
