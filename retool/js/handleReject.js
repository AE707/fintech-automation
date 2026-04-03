// handleReject.js
// Retool JS handler — Reject button onClick
// Calls the n8n approval webhook with action=reject

const transactionId = selectedRow.data.id;
const performedBy   = current_user.email;
const rejectNote    = rejectNoteInput.value;

if (!transactionId) {
  utils.showNotification({ title: 'Error', description: 'No transaction selected', notificationType: 'error' });
  return;
}

if (!rejectNote) {
  utils.showNotification({ title: 'Required', description: 'Please provide a rejection reason.', notificationType: 'warning' });
  return;
}

const response = await utils.triggerQuery('callApprovalWebhook', {
  body: JSON.stringify({
    transaction_id: transactionId,
    action:         'reject',
    decision_by:    performedBy,
    note:           rejectNote
  })
});

if (response.status === 200) {
  utils.showNotification({ title: 'Rejected', description: `Transaction ${transactionId} rejected.`, notificationType: 'warning' });
  await logRejectAction.trigger();
  await getTransactions.trigger();
} else {
  utils.showNotification({ title: 'Failed', description: 'Rejection request failed.', notificationType: 'error' });
}
