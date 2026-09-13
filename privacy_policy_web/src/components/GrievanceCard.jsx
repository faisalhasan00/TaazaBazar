import React from 'react';
import { Mail, MapPin, Clock, ShieldCheck, PhoneCall, AlertCircle } from 'lucide-react';

export default function GrievanceCard() {
  return (
    <div className="article-container">
      <div className="policy-card">
        <div className="card-header">
          <ShieldCheck size={24} color="#166534" />
          <h2 className="card-title">Grievance Redressal Mechanism & Officer</h2>
        </div>

        <p style={{ color: '#475569', fontSize: '14.5px', marginBottom: '16px' }}>
          In accordance with the Information Technology Act 2000 and the Consumer Protection (E-Commerce) Rules, 2020, the name and contact details of our designated Grievance Officer are published below:
        </p>

        <div className="contact-grid">
          <div className="contact-tile">
            <div className="contact-icon">
              <Mail size={20} />
            </div>
            <div>
              <div style={{ fontSize: '12px', fontWeight: 800, color: '#94a3b8', textTransform: 'uppercase' }}>Grievance Email</div>
              <div style={{ fontSize: '15px', fontWeight: 700, color: '#0f172a', marginTop: '2px' }}>
                <a href="mailto:grievance@taazabazar.in">grievance@taazabazar.in</a>
              </div>
              <div style={{ fontSize: '12.5px', color: '#64748b', marginTop: '4px' }}>Acknowledgment within 48 hours</div>
            </div>
          </div>

          <div className="contact-tile">
            <div className="contact-icon">
              <PhoneCall size={20} />
            </div>
            <div>
              <div style={{ fontSize: '12px', fontWeight: 800, color: '#94a3b8', textTransform: 'uppercase' }}>Customer Care</div>
              <div style={{ fontSize: '15px', fontWeight: 700, color: '#0f172a', marginTop: '2px' }}>
                <a href="mailto:care@taazabazar.in">care@taazabazar.in</a>
              </div>
              <div style={{ fontSize: '12.5px', color: '#64748b', marginTop: '4px' }}>24x7 In-App Helpdesk & Live Chat</div>
            </div>
          </div>

          <div className="contact-tile">
            <div className="contact-icon">
              <MapPin size={20} />
            </div>
            <div>
              <div style={{ fontSize: '12px', fontWeight: 800, color: '#94a3b8', textTransform: 'uppercase' }}>Operational Office</div>
              <div style={{ fontSize: '14px', fontWeight: 700, color: '#0f172a', marginTop: '2px' }}>
                TaazaBazar Grocery Private Limited
              </div>
              <div style={{ fontSize: '12.5px', color: '#64748b', marginTop: '4px' }}>
                100 Feet Road, Indiranagar, Bengaluru, KA - 560038
              </div>
            </div>
          </div>

          <div className="contact-tile">
            <div className="contact-icon">
              <Clock size={20} />
            </div>
            <div>
              <div style={{ fontSize: '12px', fontWeight: 800, color: '#94a3b8', textTransform: 'uppercase' }}>Redressal Timeline</div>
              <div style={{ fontSize: '14px', fontWeight: 700, color: '#0f172a', marginTop: '2px' }}>
                Resolution in 15 Days
              </div>
              <div style={{ fontSize: '12.5px', color: '#64748b', marginTop: '4px' }}>
                All user grievances resolved per statutory timelines
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
