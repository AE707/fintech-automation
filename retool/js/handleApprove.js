// handleApprove.js
// Retool JS handler — Approve button onClick
// Calls the n8n approval webhook with action=approve

const transactionId = selectedRow.data.id;
const performedBy   = current_user.email;

if (!transactionId) {
  utils.showNotification({ title: 'Error', description: 'No transaction selected', notificationType: 'error' });
  return;
}

const response = await utils.triggerQuery('callApprovalWebhook', {
  body: JSON.stringify({
    transaction_id: transactionId,
    action:         'approve',
    decision_by:    performedBy,
    note:           approvalNoteInput.value || ''
  })
});

if (response.status === 200) {
  utils.showNotification({ title: 'Approved', description: `Transaction ${transactionId} approved.`, notificationType: 'success' });
  await logAuditAction.trigger();
  await getTransactions.trigger();
} else {
  utils.showNotification({ title: 'Failed', description: 'Approval request failed.', notificationType: 'error' });
}
