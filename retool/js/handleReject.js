// handleReject.js
// Retool JS handler - Reject button onClick
// Triggered from the transaction detail panel in Retool dashboard
// Requires a rejection reason (mandatory field) before proceeding

const transactionId  = selectedRow.data.id;
const transactionRef = selectedRow.data.reference;
const amount         = selectedRow.data.amount;
const currency       = selectedRow.data.currency;
const performedBy    = current_user.email;
const rejectReason   = rejectReasonInput.value?.trim();

// Guard: require a row to be selected
if (!transactionId) {
  utils.showNotification({
    title: 'Error',
    description: 'No transaction selected. Please select a row first.',
    notificationType: 'error'
  });
  return;
}

// Guard: prevent rejecting already-terminal transactions
if (['approved', 'rejected'].includes(selectedRow.data.status)) {
  utils.showNotification({
    title: 'Invalid Action',
    description: `Transaction is already ${selectedRow.data.status}. Cannot reject.`,
    notificationType: 'warning'
  });
  return;
}

// Guard: rejection reason is required
if (!rejectReason || rejectReason.length < 5) {
  utils.showNotification({
    title: 'Reason Required',
    description: 'Please provide a rejection reason (minimum 5 characters).',
    notificationType: 'warning'
  });
  return;
}

// Confirm before proceeding
const confirmed = await utils.confirm(
  `Reject transaction ${transactionRef} for ${amount} ${currency}?\nReason: "${rejectReason}"`
);
if (!confirmed) return;

try {
  // Trigger rejectTransaction SQL query
  const result = await rejectTransaction.trigger({
    additionalScope: {
      transactionId,
      rejectionReason: rejectReason,
      performedBy
    }
  });

  if (result && result.length > 0) {
    utils.showNotification({
      title: 'Rejected',
      description: `Transaction ${transactionRef} has been rejected. Reason: ${rejectReason}`,
      notificationType: 'success'
    });
    // Refresh the transactions table and queue
    await getTransactions.trigger();
    await getStats.trigger();
    await getQueueItems.trigger();
  } else {
    throw new Error('Rejection query returned no results. The transaction may already be terminal.');
  }
} catch (err) {
  utils.showNotification({
    title: 'Rejection Failed',
    description: err.message || 'An unexpected error occurred.',
    notificationType: 'error'
  });
  console.error('[handleReject] Error:', err);
}
