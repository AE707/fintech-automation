# fintech-automation

> A production-grade fintech automation portfolio built with **Retool**, **n8n**, and **Supabase** — demonstrating real-world transaction monitoring, multi-tier approval workflows, and event queue processing.

---

## System Architecture

```
+------------------------------------------------------------------+
|                  RETOOL - Transaction Dashboard                  |
|  +------------------+  +------------+  +---------------------+  |
|  | Stats / KPI Cards|  | Chart View |  | Queue Monitor Panel |  |
|  +------------------+  +------------+  +---------------------+  |
|  +----------------------------------------------------------+    |
|  |              Transactions Table (paginated)              |    |
|  |  [Approve] --> triggers n8n Approval Webhook             |    |
|  |  [Reject]  --> calls rejectTransaction SQL directly      |    |
|  +----------------------------------------------------------+    |
|  +----------------------------------------------------------+    |
|  |                    Audit Log Panel                       |    |
|  +----------------------------------------------------------+    |
+------------------------------------------------------------------+
                               |
                               | Webhook / Supabase REST
                               v
+------------------------------------------------------------------+
|                     n8n Workflow Engine                          |
|                                                                  |
|  [queue-buffer]        --> INSERT into event_queue (queued)     |
|  [transaction-processor] <-- POLL event_queue every 30s        |
|      |-- validate --> approve/reject --> update transactions     |
|      |-- create audit_log entry                                  |
|  [approval-workflow]   --> manual decision via Retool           |
|  [queue-error-handler] --> retry failed events, Slack alert     |
+------------------------------------------------------------------+
                               |
                               | PostgreSQL (Supabase)
                               v
+------------------------------------------------------------------+
|                        Supabase Database                         |
|                                                                  |
|  accounts       - User/company account registry                  |
|  transactions   - Core ledger with status tracking              |
|  event_queue    - Decoupled async processing queue              |
|  audit_log      - Immutable compliance trail                     |
+------------------------------------------------------------------+
```

---

## Tech Stack

| Layer | Tool | Purpose |
|-------|------|---------|
| **Dashboard** | Retool | Ops UI: transactions, approvals, KPIs |
| **Automation** | n8n | Workflow engine: queue processing, webhooks |
| **Database** | Supabase (PostgreSQL) | Data persistence, RLS, triggers |
| **API Testing** | Postman | Webhook and REST endpoint testing |

---

## Repository Structure

```
fintech-automation/
├── supabase/
│   ├── schema.sql            # 4-table schema with RLS policies
│   ├── indexes.sql           # Performance indexes
│   └── triggers.sql          # Auto-audit and timestamp triggers
├── n8n/
│   ├── README.md             # n8n workflow overview
│   ├── approval-workflow/
│   │   └── workflow.json     # Manual approval via Retool + n8n
│   ├── queue-buffer/
│   │   └── workflow.json     # High-throughput webhook ingestion
│   ├── transaction-processor/
│   │   └── README.md         # Core queue-polling processor docs
│   └── queue-error-handler/
│       └── README.md         # Dead-letter retry and alerting docs
├── retool/
│   ├── queries/
│   │   ├── getTransactions.sql      # Paginated transaction list
│   │   ├── getAuditLog.sql          # Audit trail for a transaction
│   │   ├── getStats.sql             # Dashboard KPI summary
│   │   ├── getQueueItems.sql        # Event queue with overdue detection
│   │   ├── getQueueStats.sql        # Queue health metrics
│   │   ├── getChartData.sql         # Daily volume chart data
│   │   ├── getCount.sql             # Total count for pagination
│   │   ├── getCurrentMonthStats.sql # Current month KPIs
│   │   ├── getLastMonthStats.sql    # Previous month KPIs (MoM)
│   │   ├── rejectTransaction.sql    # Atomic rejection with audit
│   │   └── retryFailedEvent.sql     # Dead-letter event reset
│   └── js/
│       ├── handleApprove.js         # Approve button handler
│       ├── handleReject.js          # Reject button handler
│       ├── insertAuditLog.js        # Supabase REST audit insert
│       ├── logAuditAction.js        # Approval audit entry
│       └── logRejectAction.js       # Rejection audit entry
├── postman/
│   ├── collection.json              # Full API test suite
│   └── queue-load-test.json         # Load test collection
└── README.md
```

---

## Database Schema

### `accounts`
User and company account registry with balance tracking.

### `transactions`
Core transaction ledger with status lifecycle:
`pending` → `processing` → `approved` | `rejected` | `failed`

### `event_queue`
Decoupled async processing queue with retry logic:
`queued` → `processing` → `done` | `failed` → `dead`

### `audit_log`
Immutable compliance trail — every status change creates an entry.

---

## Quick Start

### 1. Supabase Setup
```sql
-- Run in Supabase SQL editor (in order):
\i supabase/schema.sql
\i supabase/indexes.sql
\i supabase/triggers.sql
```

### 2. n8n Setup
```bash
# Import workflows in this order:
1. n8n/queue-buffer/workflow.json
2. n8n/transaction-processor/  (see README)
3. n8n/approval-workflow/workflow.json
4. n8n/queue-error-handler/    (see README)
```

### 3. Environment Variables
```env
SUPABASE_URL=https://<your-project>.supabase.co
SUPABASE_SERVICE_KEY=<service_role_key>
SUPABASE_ANON_KEY=<anon_key>
RETOOL_WEBHOOK_SECRET=<shared_secret>
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/...
N8N_BASE_URL=https://<your-n8n-instance>
```

### 4. Retool Setup
- Connect Retool to Supabase using the credentials above
- Import the SQL queries from `retool/queries/`
- Add the JS handlers from `retool/js/`

### 5. API Testing
- Import `postman/collection.json` into Postman
- Set the collection variables (`BASE_URL`, `N8N_URL`, `SUPABASE_KEY`, `SERVICE_KEY`)
- Run the webhook and REST endpoint tests

---

## Key Features

- **Event-driven architecture** — transactions never block; processed asynchronously via queue
- **Multi-tier approval** — Retool UI triggers n8n approval workflow or rejects directly
- **Dead-letter handling** — failed events retried up to 3x with Slack alerting
- **Immutable audit trail** — every action logged with operator identity and timestamp
- **Row-Level Security** — Supabase RLS enforces data access control
- **Performance-optimized** — composite indexes on all hot query paths
- **Month-over-month analytics** — current vs previous month KPI comparison in dashboard

---

## Author

Built by [@AE707](https://github.com/AE707) as a production-ready fintech automation portfolio project.
