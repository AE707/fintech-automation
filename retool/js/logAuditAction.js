// logAuditAction.js
// Retool JS - Insert an audit log entry for an APPROVE action
// Called after handleApprove.js confirms the webhook response is successful
// Delegates actual DB insert to insertAuditLog.js via query trigger

const transactionId = selectedRow.data.id;
const performedBy   = current_user.email;
const note          = approvalNoteInput.value?.trim() || 'Approved via Retool dashboard';
const amount        = selectedRow.data.amount;
const currency      = selectedRow.data.currency;
const reference     = selectedRow.data.reference;

// Build rich details object for the audit_log.details JSONB column
const auditDetails = {
  note:        note,
  amount:      amount,
  currency:    currency,
  reference:   reference,
  source:      'retool_dashboard',
  approved_at: new Date().toISOString()
};

try {
  const result = await insertAuditLog.trigger({
    additionalScope: {
      auditTransactionId: transactionId,
      auditAction:        'approved',
      auditPerformedBy:   performedBy,
      auditDetails:       auditDetails
    }
  });

  console.log('[logAuditAction] Approval audit entry created:', result);
  return result;
} catch (err) {
  // Log the error but don't block the UI — approval already succeeded
  console.error('[logAuditAction] Failed to insert audit entry:', err);
  utils.showNotification({
    title: 'Audit Log Warning',
    description: 'Approval succeeded but audit log entry failed. Please check manually.',
    notificationType: 'warning'
  });
}
