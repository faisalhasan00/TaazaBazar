import React from 'react';
import { Bell, Search, RefreshCw, ShieldCheck, User } from 'lucide-react';

export default function Header({ title, subtitle, onRefresh, isRefreshing = false }) {
  return (
    <header className="h-16 bg-white border-b border-slate-200/80 px-8 flex items-center justify-between sticky top-0 z-30 shadow-sm/50">
      <div>
        <h1 className="text-xl font-bold text-slate-900 tracking-tight">{title}</h1>
        {subtitle && <p className="text-xs text-slate-500">{subtitle}</p>}
      </div>

      <div className="flex items-center gap-3">
        {onRefresh && (
          <button
            onClick={onRefresh}
            disabled={isRefreshing}
            className="p-2 text-slate-500 hover:text-slate-900 hover:bg-slate-100 rounded-xl transition-all"
            title="Refresh Data"
          >
            <RefreshCw className={`w-4 h-4 ${isRefreshing ? 'animate-spin text-brand-600' : ''}`} />
          </button>
        )}

        <div className="h-6 w-px bg-slate-200 mx-1" />

        {/* Live status badge */}
        <div className="flex items-center gap-2 px-3 py-1.5 rounded-full bg-emerald-50 border border-emerald-200 text-emerald-700 text-xs font-semibold">
          <span className="w-2 h-2 rounded-full bg-emerald-500 animate-ping" />
          <span>Live Sync Active</span>
        </div>

        {/* Admin Profile */}
        <div className="flex items-center gap-2 pl-2">
          <div className="w-8 h-8 rounded-full bg-brand-100 text-brand-700 font-bold text-xs flex items-center justify-center border border-brand-200">
            TB
          </div>
          <div className="text-left hidden sm:block">
            <div className="text-xs font-semibold text-slate-800">TaazaBazar Admin</div>
            <div className="text-[10px] text-slate-400">Master Console</div>
          </div>
        </div>
      </div>
    </header>
  );
}
