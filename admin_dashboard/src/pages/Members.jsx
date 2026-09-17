import React, { useState, useEffect } from 'react';
import { 
  Users, 
  Search, 
  Phone, 
  Mail, 
  Calendar, 
  ShoppingBag, 
  CalendarClock, 
  ShieldCheck, 
  Sparkles,
  ExternalLink,
  CheckCircle2,
  PauseCircle,
  IndianRupee
} from 'lucide-react';
import { StatusBadge } from '../components/Common/Badge';
import Modal from '../components/Common/Modal';
import { userService } from '../services/userService';

export default function Members() {
  const [members, setMembers] = useState([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [filter, setFilter] = useState('all'); // all, subscribers, regular
  const [activeMember, setActiveMember] = useState(null);

  useEffect(() => {
    const unsub = userService.subscribeToMembers((data) => setMembers(data));
    return () => unsub();
  }, []);

  const subscribersCount = members.filter(m => 
    m.subscriptions && m.subscriptions.some(s => !s.status || String(s.status).toLowerCase() === 'active')
  ).length;

  const filteredMembers = members.filter((m) => {
    const query = searchQuery.toLowerCase().trim();
    const matchesSearch = 
      (m.name || '').toLowerCase().includes(query) ||
      (m.phone || '').includes(query) ||
      (m.email || '').toLowerCase().includes(query);

    const hasSub = m.subscriptions && m.subscriptions.some(s => !s.status || String(s.status).toLowerCase() === 'active');
    const matchesFilter = 
      filter === 'all' ||
      (filter === 'subscribers' && hasSub) ||
      (filter === 'regular' && !hasSub);

    return matchesSearch && matchesFilter;
  });

  return (
    <div className="p-8 space-y-6 max-w-7xl mx-auto">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-2xl font-bold text-slate-900 font-serif">Registered Members & Customers</h2>
          <p className="text-xs text-slate-500">Track all app user accounts, subscriptions, and lifetime order activity</p>
        </div>

        <div className="flex items-center gap-3">
          <div className="px-3.5 py-1.5 rounded-2xl bg-white border border-slate-200 shadow-sm text-xs font-bold text-slate-700 flex items-center gap-2">
            <Users className="w-4 h-4 text-brand-600" />
            <span>{members.length} Total Registered Members</span>
          </div>
        </div>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-5">
        <div className="bg-white rounded-2xl p-5 border border-slate-200/80 shadow-sm flex items-center justify-between">
          <div>
            <p className="text-xs font-semibold text-slate-400 uppercase tracking-wider">Total Members</p>
            <h3 className="text-2xl font-extrabold text-slate-900 mt-1 font-serif">{members.length}</h3>
            <p className="text-[11px] text-slate-400 mt-0.5">Registered app accounts</p>
          </div>
          <div className="p-3 rounded-2xl bg-emerald-50 text-emerald-600 border border-emerald-100">
            <Users className="w-5 h-5" />
          </div>
        </div>

        <div className="bg-white rounded-2xl p-5 border border-slate-200/80 shadow-sm flex items-center justify-between">
          <div>
            <p className="text-xs font-semibold text-slate-400 uppercase tracking-wider">Active Subscribers</p>
            <h3 className="text-2xl font-extrabold text-slate-900 mt-1 font-serif">{subscribersCount}</h3>
            <p className="text-[11px] text-slate-400 mt-0.5">Daily milk & produce plans</p>
          </div>
          <div className="p-3 rounded-2xl bg-blue-50 text-blue-600 border border-blue-100">
            <CalendarClock className="w-5 h-5" />
          </div>
        </div>

        <div className="bg-white rounded-2xl p-5 border border-slate-200/80 shadow-sm flex items-center justify-between">
          <div>
            <p className="text-xs font-semibold text-slate-400 uppercase tracking-wider">Total Orders Placed</p>
            <h3 className="text-2xl font-extrabold text-slate-900 mt-1 font-serif">
              {members.reduce((sum, m) => sum + (m.orderCount || 0), 0)}
            </h3>
            <p className="text-[11px] text-slate-400 mt-0.5">Lifetime member deliveries</p>
          </div>
          <div className="p-3 rounded-2xl bg-purple-50 text-purple-600 border border-purple-100">
            <ShoppingBag className="w-5 h-5" />
          </div>
        </div>
      </div>

      {/* Filter & Search Bar */}
      <div className="bg-white rounded-2xl p-4 border border-slate-200/80 shadow-sm flex flex-col sm:flex-row items-center gap-3">
        <div className="relative flex-1 w-full">
          <Search className="w-4 h-4 absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400" />
          <input
            type="text"
            placeholder="Search members by name, mobile (+91), or email..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full pl-10 pr-4 py-2 text-xs rounded-xl bg-slate-50 border border-slate-200 focus:bg-white focus:outline-none focus:ring-2 focus:ring-brand-500/20 focus:border-brand-500 transition-all"
          />
        </div>

        <div className="flex items-center gap-2 w-full sm:w-auto">
          {['all', 'subscribers', 'regular'].map((tab) => (
            <button
              key={tab}
              onClick={() => setFilter(tab)}
              className={`px-3.5 py-2 rounded-xl text-xs font-bold capitalize whitespace-nowrap transition-all ${
                filter === tab 
                  ? 'bg-slate-900 text-white' 
                  : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
              }`}
            >
              {tab === 'subscribers' ? `Subscribers (${subscribersCount})` : tab}
            </button>
          ))}
        </div>
      </div>

      {/* Members Table */}
      <div className="bg-white rounded-3xl border border-slate-200/80 shadow-sm overflow-hidden">
        {filteredMembers.length === 0 ? (
          <div className="py-20 text-center text-slate-400">
            <Users className="w-12 h-12 mx-auto text-slate-300 mb-3" />
            <p className="text-sm font-semibold text-slate-600">No members found</p>
            <p className="text-xs text-slate-400 mt-1">When users sign up on the mobile app, their full profile and subscriptions appear here automatically.</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-sm text-slate-600">
              <thead className="bg-slate-50 text-[11px] font-bold uppercase tracking-wider text-slate-400 border-b border-slate-100">
                <tr>
                  <th className="px-6 py-4">Member / Name</th>
                  <th className="px-6 py-4">Mobile Number</th>
                  <th className="px-6 py-4">Email Address</th>
                  <th className="px-6 py-4">Active Subscriptions</th>
                  <th className="px-6 py-4">Orders Placed</th>
                  <th className="px-6 py-4">Total Spent</th>
                  <th className="px-6 py-4">Joined Date</th>
                  <th className="px-6 py-4 text-right">Details</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {filteredMembers.map((member) => (
                  <tr key={member.id} className="hover:bg-slate-50/70 transition-colors">
                    {/* Name & Avatar */}
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-3">
                        <div className="w-9 h-9 rounded-xl bg-gradient-to-tr from-brand-600 to-brand-400 text-white font-bold text-xs flex items-center justify-center shadow-sm">
                          {(member.name || 'M').charAt(0).toUpperCase()}
                        </div>
                        <div>
                          <div className="font-bold text-slate-900 text-xs">{member.name || 'Taaza Customer'}</div>
                          <div className="text-[10px] text-slate-400 font-mono">UID: {member.uid.slice(0, 8)}...</div>
                        </div>
                      </div>
                    </td>

                    {/* Mobile */}
                    <td className="px-6 py-4">
                      <div className="text-xs font-semibold text-slate-800 flex items-center gap-1.5">
                        <Phone className="w-3.5 h-3.5 text-brand-600" />
                        <span>{member.phone || '-'}</span>
                      </div>
                    </td>

                    {/* Email */}
                    <td className="px-6 py-4 text-xs text-slate-500">
                      {member.email ? (
                        <div className="flex items-center gap-1.5">
                          <Mail className="w-3.5 h-3.5 text-slate-400" />
                          <span className="truncate max-w-[140px]">{member.email}</span>
                        </div>
                      ) : (
                        <span className="text-slate-400 italic text-[11px]">Not provided</span>
                      )}
                    </td>

                    {/* Subscriptions */}
                    <td className="px-6 py-4">
                      {(() => {
                        const subs = member.subscriptions || [];
                        const activeSubs = subs.filter(s => !s.status || String(s.status).toLowerCase() === 'active');
                        const pausedSubs = subs.filter(s => String(s.status).toLowerCase() === 'paused');
                        const cancelledSubs = subs.filter(s => String(s.status).toLowerCase() === 'cancelled');

                        if (activeSubs.length > 0) {
                          return (
                            <div className="flex flex-col gap-1.5 items-start">
                              <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-bold bg-emerald-50 text-emerald-700 border border-emerald-200 shadow-sm">
                                <Sparkles className="w-3.5 h-3.5 fill-emerald-500 text-emerald-500" />
                                <span>Subscribed</span>
                              </span>
                              {activeSubs.map((sub, i) => (
                                <span 
                                  key={i}
                                  className="inline-flex items-center gap-1 text-[10px] font-semibold text-slate-600 bg-slate-100 px-2 py-0.5 rounded-lg"
                                >
                                  <CalendarClock className="w-3 h-3 text-slate-400" />
                                  <span>{sub.planName || 'Daily Fresh Basket'}</span>
                                </span>
                              ))}
                            </div>
                          );
                        }

                        if (pausedSubs.length > 0) {
                          return (
                            <div className="flex flex-col gap-1 items-start">
                              <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-bold bg-amber-50 text-amber-700 border border-amber-200">
                                <PauseCircle className="w-3.5 h-3.5 text-amber-500" />
                                <span>Paused</span>
                              </span>
                              <span className="text-[10px] text-slate-400 font-medium">Temporarily paused</span>
                            </div>
                          );
                        }

                        if (cancelledSubs.length > 0) {
                          const lastCancelled = cancelledSubs[0];
                          let dateStr = '';
                          if (lastCancelled.cancelledAt) {
                            const d = new Date(lastCancelled.cancelledAt);
                            if (!isNaN(d.getTime())) {
                              dateStr = d.toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' });
                            }
                          }
                          return (
                            <div className="flex flex-col gap-1 items-start">
                              <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-bold bg-rose-50 text-rose-700 border border-rose-200">
                                <span>Cancelled</span>
                              </span>
                              {dateStr && (
                                <span className="text-[10px] text-slate-400 font-medium">Ended: {dateStr}</span>
                              )}
                            </div>
                          );
                        }

                        return (
                          <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-medium bg-slate-100 text-slate-500 border border-slate-200">
                            <span>Not Subscribed</span>
                          </span>
                        );
                      })()}
                    </td>

                    {/* Orders count */}
                    <td className="px-6 py-4">
                      <span className="font-bold text-slate-900 text-xs px-2.5 py-1 rounded-lg bg-slate-100">
                        {member.orderCount || 0} order(s)
                      </span>
                    </td>

                    {/* Total Spend */}
                    <td className="px-6 py-4">
                      <div className="font-bold text-slate-900 text-xs">
                        ₹{(member.totalSpent || 0).toLocaleString('en-IN')}
                      </div>
                    </td>

                    {/* Joined */}
                    <td className="px-6 py-4 text-xs text-slate-400">
                      {member.joinedDate}
                    </td>

                    {/* View Details Button */}
                    <td className="px-6 py-4 text-right">
                      <button
                        onClick={() => setActiveMember(member)}
                        className="px-3 py-1.5 rounded-xl bg-slate-100 hover:bg-brand-50 text-slate-700 hover:text-brand-700 font-bold text-xs transition-colors"
                      >
                        View Profile
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Member Details Modal */}
      <Modal
        isOpen={!!activeMember}
        onClose={() => setActiveMember(null)}
        title={activeMember ? activeMember.name : 'Member Profile'}
        subtitle={activeMember ? `Registered Mobile: ${activeMember.phone}` : ''}
        maxWidth="max-w-2xl"
      >
        {activeMember && (
          <div className="space-y-6 text-xs">
            {/* Member Card Header */}
            <div className="p-4 rounded-2xl bg-gradient-to-r from-slate-900 to-slate-800 text-white flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 rounded-2xl bg-brand-500 text-white font-extrabold text-lg flex items-center justify-center">
                  {(activeMember.name || 'M').charAt(0).toUpperCase()}
                </div>
                <div>
                  <h4 className="text-base font-bold font-serif">{activeMember.name}</h4>
                  <p className="text-slate-300 text-xs mt-0.5">{activeMember.phone} {activeMember.email ? `• ${activeMember.email}` : ''}</p>
                </div>
              </div>
              <div className="text-right">
                <div className="text-[10px] uppercase font-semibold text-slate-400">Joined</div>
                <div className="font-bold text-xs text-white">{activeMember.joinedDate}</div>
              </div>
            </div>

            {/* Lifetime metrics */}
            <div className="grid grid-cols-2 gap-4">
              <div className="p-4 rounded-2xl bg-slate-50 border border-slate-100">
                <div className="text-[11px] font-bold text-slate-400 uppercase">Total Grocery Orders</div>
                <div className="text-xl font-extrabold text-slate-900 mt-1">{activeMember.orderCount || 0} Orders</div>
              </div>
              <div className="p-4 rounded-2xl bg-slate-50 border border-slate-100">
                <div className="text-[11px] font-bold text-slate-400 uppercase">Lifetime Store Spending</div>
                <div className="text-xl font-extrabold text-brand-700 mt-1">₹{(activeMember.totalSpent || 0).toLocaleString('en-IN')}</div>
              </div>
            </div>

            {/* Subscriptions Section */}
            <div>
              <div className="font-bold text-slate-900 text-sm mb-3 flex items-center gap-2">
                <CalendarClock className="w-4 h-4 text-brand-600" />
                <span>Subscription Plans & History</span>
              </div>

              {activeMember.subscriptions && activeMember.subscriptions.length > 0 ? (
                <div className="space-y-3">
                  {activeMember.subscriptions.map((sub, i) => {
                    const status = sub.status || 'active';
                    let startDate = sub.startDate ? new Date(sub.startDate).toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' }) : 'Recently';
                    let cancelledDate = sub.cancelledAt ? new Date(sub.cancelledAt).toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' }) : null;

                    return (
                      <div key={i} className={`p-4 rounded-2xl border ${
                        status === 'active' 
                          ? 'bg-emerald-50/50 border-emerald-200' 
                          : status === 'paused' 
                            ? 'bg-amber-50/50 border-amber-200' 
                            : 'bg-rose-50/50 border-rose-200'
                      }`}>
                        <div className="flex items-start justify-between gap-4">
                          <div>
                            <div className="font-bold text-slate-900 text-sm">{sub.planName || 'Daily Fresh Household Basket'}</div>
                            <div className="text-[11px] text-slate-600 mt-1 flex flex-wrap items-center gap-x-3 gap-y-1">
                              <span>Frequency: <strong className="capitalize">{sub.frequency || 'Daily'}</strong></span>
                              <span>•</span>
                              <span>Slot: <strong>{sub.slot || sub.deliverySlot || 'Morning 6:00 - 8:00 AM'}</strong></span>
                            </div>
                          </div>
                          <div className="text-right whitespace-nowrap">
                            <div className="font-extrabold text-slate-900 text-sm">₹{sub.estimatedMonthlyAmount || sub.price || 0}/mo</div>
                            <div className="mt-1">
                              <StatusBadge status={status} />
                            </div>
                          </div>
                        </div>

                        {/* Schedule & Dates info */}
                        <div className="mt-3 pt-3 border-t border-slate-200/60 grid grid-cols-2 gap-3 text-[11px]">
                          <div>
                            <span className="text-slate-400 font-medium">Started On:</span>{' '}
                            <span className="font-bold text-slate-700">{startDate}</span>
                          </div>
                          {cancelledDate ? (
                            <div>
                              <span className="text-rose-500 font-medium">Cancelled On:</span>{' '}
                              <span className="font-bold text-rose-700">{cancelledDate}</span>
                            </div>
                          ) : (
                            <div>
                              <span className="text-slate-400 font-medium">Status:</span>{' '}
                              <span className="font-bold text-emerald-700 capitalize">{status}</span>
                            </div>
                          )}
                        </div>

                        {sub.cancellationReason && (
                          <div className="mt-2 text-[11px] text-rose-700 bg-rose-100/70 p-2 rounded-xl border border-rose-200">
                            <strong>Reason:</strong> {sub.cancellationReason}
                          </div>
                        )}
                      </div>
                    );
                  })}
                </div>
              ) : (
                <div className="p-6 rounded-2xl bg-slate-50 border border-slate-100 text-center text-slate-400">
                  This member does not have any active or past subscriptions yet.
                </div>
              )}
            </div>
          </div>
        )}
      </Modal>
    </div>
  );
}
