import React from 'react';
import { NavLink } from 'react-router-dom';
import { 
  LayoutDashboard, 
  ShoppingBag, 
  Package, 
  Layers, 
  Users,
  CalendarClock, 
  TicketPercent, 
  Image as ImageIcon,
  Store,
  ExternalLink,
  Sparkles
} from 'lucide-react';

const navigation = [
  { name: 'Dashboard', href: '/', icon: LayoutDashboard },
  { name: 'Live Orders', href: '/orders', icon: ShoppingBag, badge: 'Live' },
  { name: 'Members & Users', href: '/members', icon: Users },
  { name: 'Products & Stock', href: '/products', icon: Package },
  { name: 'Categories', href: '/categories', icon: Layers },
  { name: 'Daily Subscriptions', href: '/subscriptions', icon: CalendarClock },
  { name: 'Discount Coupons', href: '/coupons', icon: TicketPercent },
  { name: 'App Banners', href: '/banners', icon: ImageIcon },
];

export default function Sidebar({ orderCount = 0 }) {
  return (
    <aside className="w-64 bg-slate-900 text-white flex flex-col shrink-0 min-h-screen border-r border-slate-800 select-none">
      {/* Brand Header */}
      <div className="h-16 flex items-center gap-3 px-6 border-b border-slate-800 bg-slate-950/50">
        <div className="h-10 w-10 rounded-xl bg-gradient-to-tr from-brand-600 to-brand-400 flex items-center justify-center shadow-lg shadow-brand-500/20">
          <Store className="w-5 h-5 text-white" />
        </div>
        <div>
          <div className="flex items-center gap-1.5">
            <span className="font-bold text-lg tracking-tight font-serif text-white">TaazaBazar</span>
            <span className="text-[10px] uppercase font-bold tracking-wider px-1.5 py-0.5 rounded bg-brand-500/20 text-brand-400 border border-brand-500/30">CMS</span>
          </div>
          <p className="text-[11px] text-slate-400">Store Management Hub</p>
        </div>
      </div>

      {/* Navigation Links */}
      <nav className="flex-1 px-3 py-6 space-y-1.5 overflow-y-auto">
        <div className="px-3 pb-2 text-[11px] font-semibold uppercase tracking-wider text-slate-400">
          Store Operations
        </div>
        {navigation.map((item) => {
          const Icon = item.icon;
          return (
            <NavLink
              key={item.name}
              to={item.href}
              className={({ isActive }) => `
                flex items-center justify-between px-3.5 py-2.5 rounded-xl text-sm font-medium transition-all duration-150
                ${isActive 
                  ? 'bg-brand-600 text-white shadow-md shadow-brand-600/30' 
                  : 'text-slate-300 hover:text-white hover:bg-slate-800/70'}
              `}
            >
              <div className="flex items-center gap-3">
                <Icon className="w-4 h-4 shrink-0" />
                <span>{item.name}</span>
              </div>
              {item.badge && orderCount > 0 && (
                <span className="px-2 py-0.5 text-xs font-bold rounded-full bg-emerald-400 text-slate-950 animate-pulse">
                  {orderCount}
                </span>
              )}
            </NavLink>
          );
        })}
      </nav>

      {/* Footer Info Box */}
      <div className="p-4 m-3 rounded-2xl bg-gradient-to-b from-slate-800/80 to-slate-900 border border-slate-700/60">
        <div className="flex items-center gap-2 text-brand-400 font-semibold text-xs mb-1">
          <Sparkles className="w-3.5 h-3.5" />
          <span>Realtime Cloud Sync</span>
        </div>
        <p className="text-xs text-slate-400 leading-relaxed">
          Connected to <code className="text-slate-200">taazabazar-2a448</code>. Changes reflect instantly in the mobile app.
        </p>
      </div>
    </aside>
  );
}
