import React, { useState, useEffect } from 'react';
import { CalendarClock, CheckCircle, PauseCircle, Phone, User, Sparkles } from 'lucide-react';
import { StatusBadge } from '../components/Common/Badge';
import { subscriptionService } from '../services/extraServices';

export default function Subscriptions() {
  const [subscriptions, setSubscriptions] = useState([]);
  const [filter, setFilter] = useState('all');

  useEffect(() => {
    const unsub = subscriptionService.subscribeToSubscriptions((data) => setSubscriptions(data));
    return () => unsub();
  }, []);

  const filtered = subscriptions.filter(s => filter === 'all' || s.status === filter);

  return (
    <div className="p-8 space-y-6 max-w-7xl mx-auto">
      <div>
        <h2 className="text-2xl font-bold text-slate-900 font-serif">Daily Recurring Subscriptions</h2>
        <p className="text-xs text-slate-500">Manage daily morning/evening milk and produce rosters</p>
      </div>

      <div className="flex items-center gap-2">
        {['all', 'active', 'paused'].map((st) => (
          <button
            key={st}
            onClick={() => setFilter(st)}
            className={`px-4 py-2 rounded-xl text-xs font-bold uppercase tracking-wider transition-all ${
              filter === st ? 'bg-slate-900 text-white shadow-md' : 'bg-white text-slate-600 border border-slate-200 hover:bg-slate-50'
            }`}
          >
            {st} ({subscriptions.filter(s => st === 'all' || s.status === st).length})
          </button>
        ))}
      </div>

      <div className="bg-white rounded-3xl border border-slate-200/80 shadow-sm overflow-hidden">
        {filtered.length === 0 ? (
          <div className="py-20 text-center text-slate-400">
            <CalendarClock className="w-12 h-12 mx-auto text-slate-300 mb-3" />
            <p className="text-sm font-semibold text-slate-600">No active subscriptions</p>
            <p className="text-xs text-slate-400 mt-1">When customers subscribe to daily milk or vegetable plans, they appear here.</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-sm text-slate-600">
              <thead className="bg-slate-50 text-[11px] font-bold uppercase tracking-wider text-slate-400 border-b border-slate-100">
                <tr>
                  <th className="px-6 py-4">Plan Name</th>
                  <th className="px-6 py-4">Customer</th>
                  <th className="px-6 py-4">Delivery Slot</th>
                  <th className="px-6 py-4">Frequency</th>
                  <th className="px-6 py-4">Price (₹)</th>
                  <th className="px-6 py-4">Status</th>
                  <th className="px-6 py-4 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {filtered.map((sub) => (
                  <tr key={sub.id} className="hover:bg-slate-50/70 transition-colors">
                    <td className="px-6 py-4 font-bold text-slate-900 text-xs">
                      {sub.planName || 'Daily Fresh Basket'}
                    </td>
                    <td className="px-6 py-4 text-xs">
                      <div className="font-semibold text-slate-900">{sub.customerName || 'Subscriber'}</div>
                      <div className="text-slate-400">{sub.phone || '-'}</div>
                    </td>
                    <td className="px-6 py-4 text-xs">
                      <span className="px-2 py-0.5 rounded bg-amber-50 text-amber-700 font-semibold text-[11px] border border-amber-200">
                        {sub.slot || 'Morning 6:00 - 8:00 AM'}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-xs capitalize font-medium text-slate-700">
                      {sub.frequency || 'Daily'}
                    </td>
                    <td className="px-6 py-4 font-bold text-slate-900 text-xs">
                      ₹{sub.price || 0}/mo
                    </td>
                    <td className="px-6 py-4">
                      <StatusBadge status={sub.status || 'active'} />
                    </td>
                    <td className="px-6 py-4 text-right">
                      {sub.status === 'active' ? (
                        <button
                          onClick={() => subscriptionService.updateStatus(sub.id, 'paused')}
                          className="px-3 py-1.5 rounded-lg bg-amber-50 text-amber-700 font-bold text-xs hover:bg-amber-100 transition-colors"
                        >
                          Pause
                        </button>
                      ) : (
                        <button
                          onClick={() => subscriptionService.updateStatus(sub.id, 'active')}
                          className="px-3 py-1.5 rounded-lg bg-emerald-50 text-emerald-700 font-bold text-xs hover:bg-emerald-100 transition-colors"
                        >
                          Activate
                        </button>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}
