# fintech-automation

> A production-grade fintech automation portfolio built with **Retool**, **n8n**, and **Supabase** — demonstrating real-world transaction monitoring, multi-tier approval workflows, and event queue processing.

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                  RETOOL — Transaction Dashboard              │
│  ┌──────────┬──────────┬──────────┬────────────────────┐    │
│  │  Stats   │  Chart   │ Filters  │     Export CSV     │    │
│  ├──────────┴──────────┴──────────┴────────────────────┤    │
│  │              Transactions Table                      │    │
│  │   [Approve] → triggers n8n Approval Workflow        │    │
│  │   [Reject]  → direct Supabase update               │    │
│  ├──────────────────────────────────────────────────────┤    │
│  │              Audit Log Panel                         │    │
│  ├──────────────────────────────────────────────────────┤    │
│  │              Queue Monitor Panel                     │    │
│  │   Pending │ Processing │ Done │ Failed               │    │
│  └──────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
              ↓                            ↓
┌─────────────────────┐      ┌─────────────────────────────┐
│  n8n Approval        │      │  n8n Queue Buffer           │
│  Workflow            │      │                             │
│                      │      │  Flow A — Ingest            │
│  Amount < €50        │      │  Webhook → Normalize        │
│  → Auto approve      │      │  → Store in event_queue     │
│  → audit_log update  │      │  → Return 202               │
│                      │      │                             │
│  Amount > €50        │      │  Flow B — Processor         │
│  → Email manager     │      │  Schedule (30s)             │
│  → Wait for decision │      │  → Fetch pending (limit 5)  │
│  → approval_log      │      │  → Route by event_type      │
│  → audit_log update  │      │  → Mark done/failed         │
│  → status update     │      │  → Insert to transactions   │
└─────────────────────┘      └─────────────────────────────┘
              ↓                            ↓
┌─────────────────────────────────────────────────────────────┐
│                 SUPABASE — Single Database                    │
│                                                              │
│  transactions │ audit_log │ approval_log │ event_queue       │
└─────────────────────────────────────────────────────────────┘
```

---

## Projects Overview

### Project 1 — Retool Transaction Dashboard
A real-time transaction monitoring interface for banking operators.

**Features:**
- Live transaction table with server-side pagination
- Filter by User ID, transaction type, and status
- Stats panel with total count, volume, and monthly comparisons
- Interactive chart showing transaction trends
- Export to CSV
- Approve/Reject buttons with two-tier logic
- Audit log panel showing all operator actions
- Queue Monitor panel for real-time event processing visibility

**Two-Tier Approval Logic:**

| Amount | Behavior |
|--------|----------|
| Below €50 | Auto-approved instantly, status updated directly |
| Above €50 | Flagged for manager review, email sent via n8n |

---

### Project 2 — n8n Approval Workflow
An automated approval engine that enforces financial controls.

```
Retool Approve button
        ↓
Webhook receives transaction data
        ↓
IF amount > €50
   ↓ YES                    ↓ NO
Send manager email      Auto-approve
Wait for decision       Update status
        ↓               Update audit_log
Manager approves/rejects
        ↓
Update transaction status
Log to approval_log
Log to audit_log
```

**Key nodes:** Webhook → Amount IF → Generate Approval ID → Build URLs → Notify Manager → Wait → Approve/Reject branch → Log → Update status

---

### Project 3 — n8n Queue Buffer System
A resilient event processing queue that decouples ingestion from processing.

**Flow A — Ingest:**
```
External event → Webhook → Normalize → INSERT event_queue → Return 202
```

**Flow B — Processor (every 30 seconds):**
```
Schedule → Fetch 5 pending → Loop (batch: 1)
  → Switch by event_type
    ├── payment  → Mark Done → Insert Transaction
    ├── transfer → Mark Done → Insert Transaction
    ├── refund   → Mark Done → Insert Transaction
    └── fallback → Mark Failed
  → Error Handler → Mark Failed + increment retry_count
```

---

## Tech Stack

| Layer | Technology | Why |
|-------|-----------|-----|
| Dashboard | Retool | Rapid internal tool development, SQL + REST support |
| Automation | n8n | Visual workflow builder, webhook + schedule triggers |
| Database | Supabase (PostgreSQL) | REST API out of the box, real-time capable |
| Email | Gmail via n8n | Manager notifications for high-value approvals |
| Testing | Postman | Webhook simulation and load testing |

---

## Repository Structure

```
fintech-automation/
├── supabase/
│   ├── schema.sql          ← 4 tables: transactions, audit_log, approval_log, event_queue
│   ├── indexes.sql         ← Performance indexes
│   └── triggers.sql        ← Auto-updated_at triggers
├── n8n/
│   ├── approval-workflow/  ← Two-tier approval flow docs
│   ├── queue-buffer/       ← Flow A (ingest) + Flow B (processor)
│   └── queue-error-handler/← Dead-letter monitoring
├── retool/
│   ├── queries/            ← 11 SQL queries for the dashboard
│   └── js/                 ← 5 JavaScript event handlers
└── postman/
    └── queue-load-test.json← Load test collection
```

---

## Setup Guide

### Prerequisites
- Retool account (cloud or self-hosted)
- n8n account (cloud or self-hosted)
- Supabase project
- Gmail account for manager notifications

### Step 1 — Supabase
1. Create a new Supabase project
2. Open SQL Editor → run `supabase/schema.sql`
3. Run `supabase/indexes.sql` and `supabase/triggers.sql`
4. Copy your **Project URL** and **service_role key** from Settings → API

### Step 2 — n8n Queue Buffer
See [`n8n/queue-buffer/README.md`](./n8n/queue-buffer/README.md) for full setup.

### Step 3 — n8n Approval Workflow
See [`n8n/approval-workflow/README.md`](./n8n/approval-workflow/README.md) for full setup.

### Step 4 — Retool Dashboard
See [`retool/README.md`](./retool/README.md) for query and JS handler setup.

### Step 5 — Test the Full Flow
```bash
POST https://your-n8n.app.n8n.cloud/webhook/queue/ingest
{
  "event_type": "payment",
  "priority": 1,
  "amount": 750.00,
  "currency": "EUR",
  "sender_id": 652,
  "receiver_id": 273,
  "description": "Client payment"
}
```

---

## Live Demo Flow

1. Open Retool dashboard
2. Send test event via Postman to queue webhook
3. Watch Queue Monitor: `pending → processing → done`
4. New transaction appears in transactions table
5. Click **Approve** on transaction above €50
6. Manager receives email notification
7. Manager clicks **Approve** in email
8. Transaction status → `approved`
9. Audit log records full action chain

---

## Key Design Decisions

**Why a queue buffer?** Direct processing creates tight coupling — if Supabase is slow, the caller waits. The queue decouples ingestion from processing, gives rate control, and provides a retry mechanism.

**Why two-tier approval?** Low-value transactions don't need human review. High-value ones have a clear audit trail with manager accountability — critical for financial compliance.

**Why a single Supabase database?** One source of truth. Retool, n8n, and the queue all read/write the same tables — any change is immediately visible everywhere.

**Why separate `audit_log` and `approval_log`?** `audit_log` captures every system action. `approval_log` captures only manager decisions on high-value transactions — two different compliance granularities.

---

## Author

**Alaa (AE7)** — Computer Engineer and Automation & Retool Engineering Lead
