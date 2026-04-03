// insertAuditLog.js
// Generic helper — Insert a row into the audit_log table via Supabase REST
// Used by logAuditAction.js and logRejectAction.js via additionalScope
//
// Expected scope variables:
//   auditTransactionId  — UUID of the transaction
//   auditAction         — string: 'approved' | 'rejected' | custom
//   auditPerformedBy    — email of the operator
//   auditNote           — optional note string

const payload = {
  transaction_id: auditTransactionId,
  action:         auditAction,
  performed_by:   auditPerformedBy,
  note:           auditNote || null
};

const response = await fetch(`${Retool.getEnv('SUPABASE_URL')}/rest/v1/audit_log`, {
  method:  'POST',
  headers: {
    'Content-Type':  'application/json',
    'apikey':        Retool.getEnv('SUPABASE_ANON_KEY'),
    'Authorization': `Bearer ${Retool.getEnv('SUPABASE_ANON_KEY')}`,
    'Prefer':        'return=minimal'
  },
  body: JSON.stringify(payload)
});

if (!response.ok) {
  const error = await response.text();
  console.error('Audit log insert failed:', error);
  throw new Error(`Audit log insert failed: ${response.status}`);
}

console.log('Audit log entry inserted successfully.');
