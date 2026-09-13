import React from 'react';
import { ShieldCheck, Mail, MapPin, Phone, Heart } from 'lucide-react';

export default function Footer({ setActiveTab }) {
  return (
    <footer className="site-footer no-print">
      <div className="container">
        <div className="footer-grid">
          <div className="footer-brand">
            <div className="footer-title">TaazaBazar</div>
            <p className="footer-desc">
              Direct-from-farm grocery delivery bringing pure, chemical-free vegetables, dairy, and fruits straight to your kitchen table.
            </p>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '13px', color: '#86efac', marginTop: '6px' }}>
              <ShieldCheck size={16} />
              <span>Google Play Certified & DPDPA Compliant</span>
            </div>
          </div>

          <div className="footer-links-col">
            <h4>Legal & Policies</h4>
            <ul className="footer-links">
              <li>
                <a href="#privacy" onClick={(e) => { e.preventDefault(); setActiveTab('privacy'); window.scrollTo({ top: 0, behavior: 'smooth' }); }}>
                  Privacy Policy
                </a>
              </li>
              <li>
                <a href="#terms" onClick={(e) => { e.preventDefault(); setActiveTab('terms'); window.scrollTo({ top: 0, behavior: 'smooth' }); }}>
                  Terms & Conditions
                </a>
              </li>
              <li>
                <a href="#deletion" onClick={(e) => { e.preventDefault(); setActiveTab('deletion'); window.scrollTo({ top: 0, behavior: 'smooth' }); }}>
                  Request Data Deletion
                </a>
              </li>
              <li>
                <a href="#contact" onClick={(e) => { e.preventDefault(); setActiveTab('contact'); window.scrollTo({ top: 0, behavior: 'smooth' }); }}>
                  Grievance Officer
                </a>
              </li>
            </ul>
          </div>

          <div className="footer-links-col">
            <h4>Support & Contact</h4>
            <ul className="footer-links">
              <li style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                <Mail size={14} />
                <a href="mailto:care@taazabazar.in">care@taazabazar.in</a>
              </li>
              <li style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                <Mail size={14} />
                <a href="mailto:grievance@taazabazar.in">grievance@taazabazar.in</a>
              </li>
              <li style={{ display: 'flex', alignItems: 'flex-start', gap: '8px', marginTop: '4px' }}>
                <MapPin size={14} style={{ marginTop: '3px', flexShrink: 0 }} />
                <span>Indiranagar, Bengaluru, KA 560038</span>
              </li>
            </ul>
          </div>
        </div>

        <div className="footer-bottom">
          <div>
            © {new Date().getFullYear()} TaazaBazar (com.taazabazar.app). All rights reserved.
          </div>
          <div>
            Crafted for farm purity & fast delivery
          </div>
        </div>
      </div>
    </footer>
  );
}
