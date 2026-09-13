import React from 'react';
import { ShieldCheck, Printer, Mail, ExternalLink, Leaf } from 'lucide-react';

export default function Header({ activeTab, setActiveTab }) {
  const handlePrint = () => {
    window.print();
  };

  return (
    <header className="top-navbar no-print">
      <div className="container">
        <div className="nav-inner">
          <a href="#" className="brand-logo" onClick={(e) => { e.preventDefault(); setActiveTab('privacy'); }}>
            <div className="brand-icon">
              <Leaf size={24} />
            </div>
            <div>
              <span className="brand-title">TaazaBazar</span>
              <span className="brand-badge">Legal & Trust</span>
            </div>
          </a>

          <div className="nav-actions">
            <button className="btn-secondary" onClick={handlePrint} title="Print or save as PDF">
              <Printer size={15} />
              <span>Print / PDF</span>
            </button>
            <a href="mailto:care@taazabazar.in" className="btn-primary">
              <Mail size={15} />
              <span>Contact Support</span>
            </a>
          </div>
        </div>
      </div>
    </header>
  );
}
