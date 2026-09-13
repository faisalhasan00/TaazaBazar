import React from 'react';
import { ShieldCheck, Info, Database, Lock, UserCheck, AlertCircle } from 'lucide-react';

export default function PrivacyContent({ sections, searchQuery }) {
  const filteredSections = sections.filter(sec => {
    if (!searchQuery) return true;
    const query = searchQuery.toLowerCase();
    return sec.title.toLowerCase().includes(query) || sec.content.toLowerCase().includes(query);
  });

  return (
    <div className="article-container">
      {/* Quick Summary Alert for Play Store Reviewers */}
      <div className="compliance-callout">
        <ShieldCheck className="callout-icon" size={24} />
        <div className="callout-text">
          <strong>Google Play Console Compliance Notice:</strong> TaazaBazar (<code>com.taazabazar.app</code>) collects user name, phone number, and delivery address strictly to facilitate grocery delivery fulfillment and authentication. Location access is optional and solely used for delivery pin accuracy. We do not sell user data to third parties.
        </div>
      </div>


      {filteredSections.length === 0 ? (
        <div className="policy-card" style={{ textAlign: 'center', padding: '48px 24px' }}>
          <AlertCircle size={36} color="#94a3b8" style={{ margin: '0 auto 12px' }} />
          <h3 style={{ fontSize: '18px', fontWeight: 700, color: '#0f172a', marginBottom: '8px' }}>No clauses found</h3>
          <p style={{ color: '#64748b', fontSize: '14px' }}>Try searching with another keyword like "location", "delete", "contact", or "permissions".</p>
        </div>
      ) : (
        filteredSections.map((section, idx) => (
          <section id={section.id} key={section.id} className="policy-card">
            <div className="card-header">
              <span style={{ 
                width: '28px', 
                height: '28px', 
                borderRadius: '8px', 
                background: '#dcfce7', 
                color: '#166534', 
                display: 'flex', 
                alignItems: 'center', 
                justifyContent: 'center',
                fontSize: '13px',
                fontWeight: 800
              }}>
                {idx + 1}
              </span>
              <h2 className="card-title">{section.title}</h2>
            </div>
            <div 
              className="card-body" 
              dangerouslySetInnerHTML={{ 
                __html: section.content
                  .replace(/\n\s*-\s*(.+)/g, '<li>$1</li>')
                  .replace(/(<li>.*<\/li>)/gs, '<ul>$1</ul>')
                  .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
                  .replace(/`([^`]+)`/g, '<code>$1</code>')
                  .replace(/\n\n/g, '<p></p>')
              }} 
            />
          </section>
        ))
      )}
    </div>
  );
}
