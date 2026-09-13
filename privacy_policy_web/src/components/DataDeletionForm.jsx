import React, { useState } from 'react';
import { Trash2, AlertTriangle, CheckCircle, Send } from 'lucide-react';

export default function DataDeletionForm() {
  const [formData, setFormData] = useState({
    name: '',
    phone: '',
    email: '',
    reason: '',
    confirm: false
  });
  const [submitted, setSubmitted] = useState(false);

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!formData.confirm) {
      alert('Please check the confirmation box to proceed with your data deletion request.');
      return;
    }
    // Simulate submission handling
    setSubmitted(true);
  };

  return (
    <div className="article-container">
      <div className="policy-card">
        <div className="card-header">
          <Trash2 size={24} color="#dc2626" />
          <h2 className="card-title">User Account & Data Deletion Request</h2>
        </div>

        <p style={{ color: '#475569', fontSize: '14.5px', marginBottom: '20px' }}>
          Under Google Play Developer Policy and Indian Data Protection regulations, you have the right to request the complete deletion of your TaazaBazar account, personal details, addresses, and transaction records.
        </p>

        <div className="compliance-callout" style={{ background: '#fffbeb', borderLeftColor: '#f59e0b', marginBottom: '24px' }}>
          <AlertTriangle className="callout-icon" size={22} color="#d97706" />
          <div className="callout-text" style={{ color: '#92400e' }}>
            <strong>Important Notice:</strong> Deletion of your account will cancel any active <strong>Taaza Pass</strong> memberships and erase all wallet balances. This action is irreversible once processed.
          </div>
        </div>

        {submitted ? (
          <div style={{
            background: '#f0fdf4',
            border: '1px solid #bbf7d0',
            borderRadius: '16px',
            padding: '32px',
            textAlign: 'center'
          }}>
            <CheckCircle size={48} color="#16a34a" style={{ margin: '0 auto 16px' }} />
            <h3 style={{ fontSize: '20px', fontWeight: 800, color: '#166534', marginBottom: '8px' }}>
              Deletion Request Received
            </h3>
            <p style={{ fontSize: '14px', color: '#15803d', maxWidth: '480px', margin: '0 auto 16px' }}>
              We have logged your request for <strong>{formData.phone || formData.email}</strong>. Our Data Protection Team will verify your account and complete permanent deletion within <strong>7 business days</strong>. A confirmation SMS will be sent.
            </p>
            <button 
              className="btn-secondary" 
              onClick={() => { setSubmitted(false); setFormData({ name: '', phone: '', email: '', reason: '', confirm: false }); }}
            >
              Submit Another Request
            </button>
          </div>
        ) : (
          <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
            <div className="form-group">
              <label className="form-label">Full Name *</label>
              <input
                type="text"
                required
                className="form-control"
                placeholder="e.g. Faisal Khan"
                value={formData.name}
                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
              />
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
              <div className="form-group">
                <label className="form-label">Registered Mobile Number *</label>
                <input
                  type="tel"
                  required
                  className="form-control"
                  placeholder="+91 98765 43210"
                  value={formData.phone}
                  onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                />
              </div>
              <div className="form-group">
                <label className="form-label">Registered Email (Optional)</label>
                <input
                  type="email"
                  className="form-control"
                  placeholder="faisal@example.com"
                  value={formData.email}
                  onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                />
              </div>
            </div>

            <div className="form-group">
              <label className="form-label">Reason for Deletion (Optional)</label>
              <select
                className="form-control"
                value={formData.reason}
                onChange={(e) => setFormData({ ...formData, reason: e.target.value })}
              >
                <option value="">Select a reason</option>
                <option value="relocated">Relocated to non-serviceable area</option>
                <option value="privacy">Privacy concerns</option>
                <option value="duplicate">Created multiple accounts</option>
                <option value="other">Other reason</option>
              </select>
            </div>

            <div style={{ display: 'flex', alignItems: 'flex-start', gap: '10px', marginTop: '8px' }}>
              <input
                type="checkbox"
                id="confirm-check"
                checked={formData.confirm}
                onChange={(e) => setFormData({ ...formData, confirm: e.target.checked })}
                style={{ marginTop: '4px', cursor: 'pointer', width: '16px', height: '16px', accentColor: '#166534' }}
              />
              <label htmlFor="confirm-check" style={{ fontSize: '13px', color: '#475569', cursor: 'pointer' }}>
                I confirm that I want to permanently delete my TaazaBazar account, profile information, and saved delivery addresses.
              </label>
            </div>

            <div style={{ marginTop: '16px' }}>
              <button type="submit" className="btn-primary" style={{ padding: '12px 24px', fontSize: '14px', background: '#dc2626' }}>
                <Trash2 size={16} />
                <span>Submit Deletion Request</span>
              </button>
            </div>
          </form>
        )}
      </div>

      {/* Alternate Deletion Method */}
      <div className="policy-card">
        <h3 style={{ fontSize: '16px', fontWeight: 700, color: '#0f172a', marginBottom: '8px' }}>
          Manual Email Request Method
        </h3>
        <p style={{ fontSize: '13.5px', color: '#64748b', lineHeight: 1.6 }}>
          You can also request data deletion by emailing our support desk directly at <a href="mailto:care@taazabazar.in" style={{ fontWeight: 700 }}>care@taazabazar.in</a> with the subject line <code>Account Deletion Request</code> and including your registered phone number.
        </p>
      </div>
    </div>
  );
}
