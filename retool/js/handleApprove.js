// handleApprove.js
// Retool JS handler - Approve button onClick
// Triggered from the transaction detail panel in Retool dashboard
// Calls the n8n approval webhook with action=approve

const transactionId = selectedRow.data.id;
const transactionRef = selectedRow.data.reference;
const amount = selectedRow.data.amount;
const currency = selectedRow.data.currency;
const performedBy = current_user.email;
const note = approvalNoteInput.value || '';

// Guard: require a row to be selected
if (!transactionId) {
  utils.showNotification({
    title: 'Error',
    description: 'No transaction selected. Please select a row first.',
    notificationType: 'error'
  });
  return;
}

// Guard: prevent approving already-terminal transactions
if (['approved', 'rejected'].includes(selectedRow.data.status)) {
  utils.showNotification({
    title: 'Invalid Action',
    description: `Transaction is already ${selectedRow.data.status}. Cannot re-approve.`,
    notificationType: 'warning'
  });
  return;
}

// Confirm before proceeding
const confirmed = await utils.confirm(
  `Approve transaction ${transactionRef} for ${amount} ${currency}?`
);
if (!confirmed) return;

try {
  // Call n8n approval webhook
  const response = await utils.triggerQuery('callApprovalWebhook', {
    body: JSON.stringify({
      transaction_id: transactionId,
      action:         'approve',
      decision_by:    performedBy,
      note:           note,
      timestamp:      new Date().toISOString()
    })
  });

  if (response.status === 200 || response.status === 201) {
    utils.showNotification({
      title: 'Approved',
      description: `Transaction ${transactionRef} has been approved successfully.`,
      notificationType: 'success'
    });
    // Refresh the transactions table and stats
    await getTransactions.trigger();
    await getStats.trigger();
  } else {
    throw new Error(response.data?.message || `Unexpected status: ${response.status}`);
  }
} catch (err) {
  utils.showNotification({
    title: 'Approval Failed',
    description: err.message || 'An unexpected error occurred. Check n8n logs.',
    notificationType: 'error'
  });
  console.error('[handleApprove] Error:', err);
}
