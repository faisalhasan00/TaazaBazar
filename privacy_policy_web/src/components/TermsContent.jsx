import React from 'react';
import { FileText, CheckCircle2 } from 'lucide-react';

export default function TermsContent({ sections, searchQuery }) {
  const filteredSections = sections.filter(sec => {
    if (!searchQuery) return true;
    const query = searchQuery.toLowerCase();
    return sec.title.toLowerCase().includes(query) || sec.content.toLowerCase().includes(query);
  });

  return (
    <div className="article-container">
      <div className="compliance-callout">
        <FileText className="callout-icon" size={24} />
        <div className="callout-text">
          <strong>Terms of Service Notice:</strong> By accessing and ordering through TaazaBazar (<code>com.taazabazar.app</code>), you agree to these commercial terms, quality replacement guarantees, and standard operating procedures.
        </div>
      </div>

      {filteredSections.map((section, idx) => (
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
      ))}
    </div>
  );
}
