# Screenshots

This folder contains screenshots of the fintech-automation stack in production.

## Database Schema

![Database Schema](./db-schema.jpg)

*4-table Supabase schema: `transactions`, `audit_log`, `approval_log`, `event_queue`*

---

## n8n Workflows

### Queue Buffer Workflow
![Queue Buffer](./n8n-queue-buffer.jpg)

*Webhook → Edit Fields → Create a row in event_queue → Respond to Webhook*

### Transaction Processor Workflow
![Transaction Processor](./n8n-transaction-processor.jpg)

*Schedule Trigger → Fetch Pending Events → Loop → Switch by type → Mark Done + Insert Transaction*

### Approval Workflow
![Approval Workflow](./n8n-approval-workflow.jpg)

*Webhook → Amount threshold check → Gmail notification → Manager wait → Log decision → Update DB*

### Error Handler Workflow
![Error Handler](./n8n-error-handler.jpg)

*Error Trigger → Mark as Failed (PATCH event_queue)*

---

## Retool Dashboard

### Transaction Dashboard
![Transaction Dashboard](./retool-transaction-dashboard.jpg)

*Paginated table with Approve/Reject per row, KPI cards, CSV export*

### Queue Monitor
![Queue Monitor](./retool-queue-monitor.jpg)

*Real-time queue stats: Pending/Processing/Done/Failed with priority and retry tracking*

### Analytics Chart + Audit Log
![Analytics and Audit Log](./retool-chart-audit.jpg)

*Daily transaction volume chart + immutable audit log with action badges*
