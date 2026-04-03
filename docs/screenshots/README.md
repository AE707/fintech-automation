# Screenshots

This folder contains screenshots of the fintech-automation stack in production.

## Database Schema

![Database Schema](./db-schema.png)

*4-table Supabase schema: `transactions`, `audit_log`, `approval_log`, `event_queue`*

---

## n8n Workflows

### Queue Buffer Workflow
![Queue Buffer](./n8n-queue-buffer.png)

*Webhook → Edit Fields → Create a row in event_queue → Respond to Webhook*

### Transaction Processor Workflow
![Transaction Processor](./n8n-transaction-processor.png)

*Schedule Trigger → Fetch Pending Events → Loop → Switch by type → Mark Done + Insert Transaction*

### Approval Workflow
![Approval Workflow](./n8n-approval-workflow.png)

*Webhook → Amount threshold check → Gmail notification → Manager wait → Log decision → Update DB*

### Error Handler Workflow
![Error Handler](./n8n-error-handler.png)

*Error Trigger → Mark as Failed (PATCH event_queue)*

---

## Retool Dashboard

### Transaction Dashboard
![Transaction Dashboard](./retool-transaction-dashboard.png)

*Paginated table with Approve/Reject per row, KPI cards, CSV export*

### Queue Monitor
![Queue Monitor](./retool-queue-monitor.png)

*Real-time queue stats: Pending/Processing/Done/Failed with priority and retry tracking*

### Analytics Chart + Audit Log
![Analytics and Audit Log](./retool-chart-audit.png)

*Daily transaction volume chart + immutable audit log with action badges*
