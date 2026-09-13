import React, { useState, useEffect } from 'react';
import { List, ChevronRight } from 'lucide-react';

export default function TableOfContents({ sections, activeSection }) {
  return (
    <aside className="sidebar-sticky no-print">
      <div className="sidebar-title">
        Table of Contents
      </div>
      <ul className="toc-list">
        {sections.map((section) => (
          <li key={section.id}>
            <a
              href={`#${section.id}`}
              className={`toc-link ${activeSection === section.id ? 'active' : ''}`}
            >
              {section.title}
            </a>
          </li>
        ))}
      </ul>
    </aside>
  );
}
