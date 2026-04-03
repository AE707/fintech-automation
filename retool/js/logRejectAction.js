// logRejectAction.js
// Retool JS — Insert audit log entry for a REJECT action
// Called after handleReject succeeds

const transactionId = selectedRow.data.id;
const performedBy   = current_user.email;
const note          = rejectNoteInput.value || 'Rejected via Retool dashboard';

await insertAuditLog.trigger({
  additionalScope: {
    auditTransactionId: transactionId,
    auditAction:        'rejected',
    auditPerformedBy:   performedBy,
    auditNote:          note
  }
});
