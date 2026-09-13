import React, { useState, useEffect } from 'react';
import Header from './components/Header';
import Footer from './components/Footer';
import TableOfContents from './components/TableOfContents';
import PrivacyContent from './components/PrivacyContent';
import TermsContent from './components/TermsContent';
import DataDeletionForm from './components/DataDeletionForm';
import GrievanceCard from './components/GrievanceCard';
import { privacySections } from './data/privacyData';
import { termsSections } from './data/termsData';
import { Shield, FileText, Trash2, PhoneCall, Search, Calendar, CheckCircle2 } from 'lucide-react';
import './App.css';

// Helper to determine tab from pathname and hash
function getTabFromUrl() {
  const path = window.location.pathname.toLowerCase();
  const hash = window.location.hash.toLowerCase().replace('#', '');
  
  if (path.includes('terms') || hash.includes('terms')) {
    return 'terms';
  }
  if (path.includes('deletion') || path.includes('delete') || hash.includes('deletion') || hash.includes('data-deletion')) {
    return 'deletion';
  }
  if (path.includes('contact') || path.includes('grievance') || hash.includes('contact') || hash.includes('grievance')) {
    return 'contact';
  }
  return 'privacy';
}

function getPathForTab(tab) {
  switch (tab) {
    case 'terms':
      return '/terms&Compliance';
    case 'deletion':
      return '/data-deletion';
    case 'contact':
      return '/grievance';
    case 'privacy':
    default:
      return '/privacy-policy';
  }
}

export default function App() {
  const [activeTab, setActiveTab] = useState(getTabFromUrl);
  const [searchQuery, setSearchQuery] = useState('');
  const [activeSection, setActiveSection] = useState('overview');

  // Listen to popstate (browser back / forward buttons) and hash changes
  useEffect(() => {
    const handleLocationChange = () => {
      const tab = getTabFromUrl();
      setActiveTab(tab);
      const hash = window.location.hash.replace('#', '');
      if (hash && hash !== 'terms' && hash !== 'deletion' && hash !== 'contact') {
        setActiveSection(hash);
      }
    };

    window.addEventListener('popstate', handleLocationChange);
    window.addEventListener('hashchange', handleLocationChange);
    return () => {
      window.removeEventListener('popstate', handleLocationChange);
      window.removeEventListener('hashchange', handleLocationChange);
    };
  }, []);

  // Update URL path and title when tab changes
  const handleTabChange = (tab) => {
    setActiveTab(tab);
    setSearchQuery('');
    
    const newPath = getPathForTab(tab);
    if (window.location.pathname !== newPath) {
      window.history.pushState({ tab }, '', newPath);
    }
    
    // Update document title dynamically
    if (tab === 'terms') {
      document.title = 'TaazaBazar — Terms & Conditions and Compliance';
    } else if (tab === 'deletion') {
      document.title = 'TaazaBazar — Request Account & Data Deletion';
    } else if (tab === 'contact') {
      document.title = 'TaazaBazar — Grievance Redressal & Support';
    } else {
      document.title = 'TaazaBazar — Privacy Policy & Data Safety';
    }

    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  return (
    <div className="app-wrapper">
      <Header activeTab={activeTab} setActiveTab={handleTabChange} />

      {/* Hero Banner */}
      <section className="hero-section">
        <div className="container">
          <div className="hero-content">
            <div className="hero-pill">
              <Shield size={14} />
              <span>Official Privacy & Compliance Portal</span>
            </div>
            
            <h1 className="hero-title">
              {activeTab === 'privacy' && 'Privacy Policy & Data Safety'}
              {activeTab === 'terms' && 'Terms & Conditions of Service'}
              {activeTab === 'deletion' && 'Account & Data Deletion Request'}
              {activeTab === 'contact' && 'Grievance Officer & Support'}
            </h1>

            <p className="hero-subtitle">
              {activeTab === 'privacy' && 'Learn how TaazaBazar collects, uses, protects, and stores your personal information in accordance with Google Play Policies and Indian Data Protection regulations.'}
              {activeTab === 'terms' && 'Clear guidelines, order policies, cancellation procedures, and membership terms governing your use of TaazaBazar.'}
              {activeTab === 'deletion' && 'Submit an automated self-service request to permanently purge your user profile, addresses, and account credentials.'}
              {activeTab === 'contact' && 'Get in touch with our statutory Grievance Officer or 24x7 Customer Care team.'}
            </p>

            <div className="meta-badges">
              <div className="meta-item">
                <Calendar size={15} color="#166534" />
                <span>Effective Date: <strong>September 13, 2026</strong></span>
              </div>
              <div className="meta-item">
                <CheckCircle2 size={15} color="#166534" />
                <span>Package: <strong>com.taazabazar.app</strong></span>
              </div>
              <div className="meta-item">
                <Shield size={15} color="#166534" />
                <span>Status: <strong>Active & Verified</strong></span>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Navigation Tabs */}
      <nav className="tabs-nav-bar no-print">
        <div className="container">
          <div className="tabs-inner">
            <div className="tab-btn-group">
              <button
                className={`tab-btn ${activeTab === 'privacy' ? 'active' : ''}`}
                onClick={() => handleTabChange('privacy')}
              >
                <Shield size={16} />
                <span>Privacy Policy</span>
              </button>

              <button
                className={`tab-btn ${activeTab === 'terms' ? 'active' : ''}`}
                onClick={() => handleTabChange('terms')}
              >
                <FileText size={16} />
                <span>Terms & Conditions</span>
              </button>

              <button
                className={`tab-btn ${activeTab === 'deletion' ? 'active' : ''}`}
                onClick={() => handleTabChange('deletion')}
              >
                <Trash2 size={16} />
                <span>Request Data Deletion</span>
              </button>

              <button
                className={`tab-btn ${activeTab === 'contact' ? 'active' : ''}`}
                onClick={() => handleTabChange('contact')}
              >
                <PhoneCall size={16} />
                <span>Grievance Desk</span>
              </button>
            </div>
          </div>
        </div>
      </nav>

      {/* Main Content Body */}
      <main className="main-layout">
        <div className="container">
          {(activeTab === 'privacy' || activeTab === 'terms') && (
            <div className="search-wrapper no-print">
              <Search className="search-icon" size={18} />
              <input
                type="text"
                className="search-input"
                placeholder={`Search ${activeTab === 'privacy' ? 'Privacy Policy' : 'Terms'} (e.g. location, refund, delete, permissions)...`}
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
              />
            </div>
          )}

          <div className="content-grid">
            {activeTab === 'privacy' && (
              <>
                <TableOfContents sections={privacySections} activeSection={activeSection} />
                <PrivacyContent sections={privacySections} searchQuery={searchQuery} />
              </>
            )}

            {activeTab === 'terms' && (
              <>
                <TableOfContents sections={termsSections} activeSection={activeSection} />
                <TermsContent sections={termsSections} searchQuery={searchQuery} />
              </>
            )}

            {activeTab === 'deletion' && (
              <div style={{ gridColumn: '1 / -1', maxWidth: '840px', margin: '0 auto', width: '100%' }}>
                <DataDeletionForm />
              </div>
            )}

            {activeTab === 'contact' && (
              <div style={{ gridColumn: '1 / -1', maxWidth: '840px', margin: '0 auto', width: '100%' }}>
                <GrievanceCard />
              </div>
            )}
          </div>
        </div>
      </main>

      <Footer setActiveTab={handleTabChange} />
    </div>
  );
}
