# Retool Dashboard

This folder contains all SQL queries and JavaScript logic used in the Retool admin dashboard for the fintech-automation system.

## Structure

```
retool/
├── queries/     ← SQL queries connected to Supabase resource
└── js/          ← JavaScript event handlers for buttons/actions
```

## SQL Queries (`queries/`)

| File | Purpose |
|------|---------|
| `getTransactions.sql` | Paginated transaction list with filters |
| `getCount.sql` | Total count of transactions (for pagination) |
| `getStats.sql` | Summary stats (total, approved, rejected, pending) |
| `getChartData.sql` | Daily transaction volume for charts |
| `getLastMonthStats.sql` | KPIs for the previous calendar month |
| `getCurrentMonthStats.sql` | KPIs for the current calendar month |
| `getAuditLog.sql` | Audit log entries for a specific transaction |
| `getQueueStats.sql` | Queue health summary (queued, processing, dead) |
| `getQueueItems.sql` | List of queue events with filters |
| `retryFailedEvent.sql` | Reset a dead/failed event back to queued |
| `rejectTransaction.sql` | Mark a transaction as rejected |

## JavaScript Handlers (`js/`)

| File | Purpose |
|------|---------|
| `handleApprove.js` | Approve button click — calls approval webhook |
| `handleReject.js` | Reject button click — calls rejection webhook |
| `logAuditAction.js` | Log an approve action to audit_log |
| `logRejectAction.js` | Log a reject action to audit_log |
| `insertAuditLog.js` | Generic audit log insertion helper |

## Retool Resource Setup

1. Create a **PostgreSQL** resource in Retool pointing to your Supabase connection string
2. Add the SQL queries from `queries/` as Query objects in your Retool app
3. Wire the JS handlers from `js/` to button `onClick` events
4. Set environment variables for webhook URLs in Retool Secrets
