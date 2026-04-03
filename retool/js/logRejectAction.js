// logRejectAction.js
// Retool JS - Insert an audit log entry for a REJECT action
// Called after handleReject.js confirms the rejectTransaction query succeeded
// Delegates actual DB insert to insertAuditLog.js via query trigger

const transactionId   = selectedRow.data.id;
const performedBy     = current_user.email;
const rejectReason    = rejectReasonInput.value?.trim() || 'No reason provided';
const amount          = selectedRow.data.amount;
const currency        = selectedRow.data.currency;
const reference       = selectedRow.data.reference;

// Build rich details object for the audit_log.details JSONB column
const auditDetails = {
  reason:      rejectReason,
  amount:      amount,
  currency:    currency,
  reference:   reference,
  source:      'retool_dashboard',
  rejected_at: new Date().toISOString()
};

try {
  const result = await insertAuditLog.trigger({
    additionalScope: {
      auditTransactionId: transactionId,
      auditAction:        'rejected',
      auditPerformedBy:   performedBy,
      auditDetails:       auditDetails
    }
  });

  console.log('[logRejectAction] Rejection audit entry created:', result);
  return result;
} catch (err) {
  // Log the error but don't block the UI — rejection already succeeded
  console.error('[logRejectAction] Failed to insert audit entry:', err);
  utils.showNotification({
    title: 'Audit Log Warning',
    description: 'Rejection succeeded but audit log entry failed. Please check manually.',
    notificationType: 'warning'
  });
}
