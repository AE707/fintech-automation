# fintech-automation

This repository contains the full automation stack for a fintech transaction management system.

## Stack Overview

| Layer | Tool | Purpose |
|-------|------|---------|
| Database | Supabase (PostgreSQL) | Transaction storage, audit logs, queue |
| Workflow Automation | n8n | Approval flows, queue buffering, error handling |
| Internal Dashboard | Retool | Admin UI, stats, manual controls |
| API Testing | Postman | Load testing and queue simulation |

## Repository Structure

```
fintech-automation/
├── supabase/          ← Database schema, indexes, triggers
├── n8n/               ← Workflow automation flows
├── retool/            ← Dashboard queries and JS logic
└── postman/           ← API test collections
```

## Modules

- **[Supabase](./supabase/)** — Schema definitions, performance indexes, and auto-update triggers
- **[n8n](./n8n/)** — Approval workflow, queue buffer (ingest + processor), and error handler
- **[Retool](./retool/)** — SQL queries and JavaScript handlers for the admin dashboard
- **[Postman](./postman/)** — Queue load-test collection

## Getting Started

1. Run `supabase/schema.sql` to set up tables
2. Apply `supabase/indexes.sql` for performance
3. Apply `supabase/triggers.sql` for auto-timestamps
4. Import n8n workflows from the `n8n/` folders
5. Connect Retool queries from `retool/queries/`
6. Import Postman collection from `postman/queue-load-test.json`
