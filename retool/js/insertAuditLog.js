// insertAuditLog.js
// Generic helper - Insert a row into the audit_log table via Supabase REST API
// Called by logAuditAction.js, logRejectAction.js, or any other Retool JS action
//
// Expected scope variables (pass via additionalScope):
//   auditTransactionId - UUID of the transaction
//   auditAction        - string: 'approved' | 'rejected' | 'manual_review' | custom
//   auditPerformedBy   - email of the operator performing the action
//   auditDetails       - object: additional context (optional)

const supabaseUrl = Retool.getEnv('SUPABASE_URL');
const supabaseKey = Retool.getEnv('SUPABASE_ANON_KEY');

// Validate required inputs
if (!auditTransactionId) {
  throw new Error('[insertAuditLog] auditTransactionId is required');
}
if (!auditAction) {
  throw new Error('[insertAuditLog] auditAction is required');
}
if (!auditPerformedBy) {
  throw new Error('[insertAuditLog] auditPerformedBy is required');
}

const payload = {
  transaction_id: auditTransactionId,
  action:         auditAction,
  performed_by:   auditPerformedBy,
  details:        auditDetails || {}
};

const response = await fetch(`${supabaseUrl}/rest/v1/audit_log`, {
  method:  'POST',
  headers: {
    'Content-Type':  'application/json',
    'apikey':        supabaseKey,
    'Authorization': `Bearer ${supabaseKey}`,
    'Prefer':        'return=representation'
  },
  body: JSON.stringify(payload)
});

const data = await response.json();

if (!response.ok) {
  console.error('[insertAuditLog] Supabase error:', data);
  throw new Error(
    data.message || data.error || `Supabase responded with ${response.status}`
  );
}

console.log('[insertAuditLog] Audit entry created:', data);
return data;
