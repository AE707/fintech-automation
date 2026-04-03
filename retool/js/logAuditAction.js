// logAuditAction.js
// Retool JS — Insert audit log entry for an APPROVE action
// Called after handleApprove succeeds

const transactionId = selectedRow.data.id;
const performedBy   = current_user.email;
const note          = approvalNoteInput.value || 'Approved via Retool dashboard';

await insertAuditLog.trigger({
  additionalScope: {
    auditTransactionId: transactionId,
    auditAction:        'approved',
    auditPerformedBy:   performedBy,
    auditNote:          note
  }
});
