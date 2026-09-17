import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { 
  ShoppingBag, 
  IndianRupee, 
  Package, 
  CalendarClock, 
  AlertTriangle,
  ArrowRight,
  TrendingUp,
  Sparkles,
  CheckCircle2,
  Clock,
  Truck,
  Users
} from 'lucide-react';
import { 
  AreaChart, 
  Area, 
  XAxis, 
  YAxis, 
  CartesianGrid, 
  Tooltip, 
  ResponsiveContainer,
  BarChart,
  Bar
} from 'recharts';
import StatCard from '../components/Common/StatCard';
import { StatusBadge } from '../components/Common/Badge';
import { orderService } from '../services/orderService';
import { productService } from '../services/productService';
import { categoryService } from '../services/categoryService';
import { userService } from '../services/userService';

export default function Dashboard() {
  const [orders, setOrders] = useState([]);
  const [products, setProducts] = useState([]);
  const [categories, setCategories] = useState([]);
  const [members, setMembers] = useState([]);
  const [isSeeding, setIsSeeding] = useState(false);

  useEffect(() => {
    const unsubOrders = orderService.subscribeToOrders((data) => setOrders(data));
    const unsubProducts = productService.subscribeToProducts((data) => setProducts(data));
    const unsubCategories = categoryService.subscribeToCategories((data) => setCategories(data));
    const unsubMembers = userService.subscribeToMembers((data) => setMembers(data));

    return () => {
      unsubOrders();
      unsubProducts();
      unsubCategories();
      unsubMembers();
    };
  }, []);

  // Compute live statistics
  const totalRevenue = orders.reduce((sum, order) => {
    if (order.status !== 'cancelled') {
      return sum + (Number(order.totalAmount) || 0);
    }
    return sum;
  }, 0);

  const activeOrders = orders.filter(o => ['placed', 'confirmed', 'packed', 'out_for_delivery'].includes(o.status));
  const outOfStockProducts = products.filter(p => p.inStock === false);
  const activeSubscribersCount = members.filter(m => 
    m.subscriptions && m.subscriptions.some(s => !s.status || String(s.status).toLowerCase() === 'active')
  ).length;

  // Seed sample database if completely empty
  const handleSeedDatabase = async () => {
    setIsSeeding(true);
    try {
      await categoryService.seedDefaultCategories();
      await productService.seedInitialProducts();
    } catch (err) {
      console.error(err);
    } finally {
      setIsSeeding(false);
    }
  };

  // Mock weekly revenue trend chart data
  const chartData = [
    { day: 'Mon', revenue: totalRevenue > 0 ? Math.round(totalRevenue * 0.12) : 1200, orders: 14 },
    { day: 'Tue', revenue: totalRevenue > 0 ? Math.round(totalRevenue * 0.15) : 1850, orders: 22 },
    { day: 'Wed', revenue: totalRevenue > 0 ? Math.round(totalRevenue * 0.10) : 1420, orders: 18 },
    { day: 'Thu', revenue: totalRevenue > 0 ? Math.round(totalRevenue * 0.18) : 2300, orders: 28 },
    { day: 'Fri', revenue: totalRevenue > 0 ? Math.round(totalRevenue * 0.22) : 2900, orders: 35 },
    { day: 'Sat', revenue: totalRevenue > 0 ? Math.round(totalRevenue * 0.28) : 3800, orders: 48 },
    { day: 'Sun', revenue: totalRevenue > 0 ? Math.round(totalRevenue * 0.25) : 3400, orders: 42 },
  ];

  return (
    <div className="p-8 space-y-8 max-w-7xl mx-auto">
      {/* Welcome Banner */}
      <div className="rounded-3xl bg-gradient-to-r from-brand-900 via-brand-800 to-emerald-900 text-white p-8 relative overflow-hidden shadow-xl shadow-brand-950/10">
        <div className="absolute right-0 top-0 w-96 h-96 bg-brand-500/10 rounded-full blur-3xl pointer-events-none" />
        <div className="relative z-10 flex flex-col md:flex-row md:items-center justify-between gap-6">
          <div>
            <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-brand-500/20 text-brand-300 text-xs font-semibold mb-3 border border-brand-400/20">
              <Sparkles className="w-3.5 h-3.5" />
              <span>TaazaBazar Live Store Engine</span>
            </div>
            <h2 className="text-3xl font-extrabold tracking-tight font-serif">Welcome back, Store Admin</h2>
            <p className="text-slate-300 text-sm mt-1 max-w-xl">
              Real-time synchronization active. You have <strong className="text-emerald-300">{members.length} registered members</strong> and <strong className="text-emerald-300">{activeOrders.length} active orders</strong> waiting for dispatch today.
            </p>
          </div>

          <div className="flex items-center gap-3">
            {products.length === 0 && (
              <button
                onClick={handleSeedDatabase}
                disabled={isSeeding}
                className="px-4 py-2.5 rounded-xl bg-amber-500 hover:bg-amber-600 text-slate-950 font-bold text-xs flex items-center gap-2 shadow-lg transition-all"
              >
                <Sparkles className="w-4 h-4" />
                {isSeeding ? 'Seeding Catalog...' : 'Seed Sample Catalog'}
              </button>
            )}
            <Link
              to="/members"
              className="px-4 py-2.5 rounded-xl bg-slate-800 hover:bg-slate-700 text-white font-bold text-xs flex items-center gap-2 shadow-lg transition-all border border-slate-700"
            >
              <Users className="w-4 h-4 text-brand-400" />
              <span>Members ({members.length})</span>
            </Link>
            <Link
              to="/orders"
              className="px-5 py-2.5 rounded-xl bg-white hover:bg-slate-100 text-slate-900 font-bold text-xs flex items-center gap-2 shadow-lg transition-all"
            >
              <ShoppingBag className="w-4 h-4 text-brand-600" />
              <span>Orders ({activeOrders.length})</span>
            </Link>
          </div>
        </div>
      </div>

      {/* KPI Stats Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
        <StatCard
          title="Total Store Revenue"
          value={`₹${totalRevenue.toLocaleString('en-IN')}`}
          subtitle="Processed via Razorpay & COD"
          trend="+18.4%"
          icon={IndianRupee}
          color="brand"
        />
        <StatCard
          title="Active Live Orders"
          value={activeOrders.length}
          subtitle={`${orders.length} total lifetime orders`}
          trend="+8 today"
          icon={ShoppingBag}
          color="blue"
        />
        <StatCard
          title="Registered Members"
          value={members.length}
          subtitle={`${activeSubscribersCount} active subscribers`}
          trend="+New"
          icon={Users}
          color="purple"
        />
        <StatCard
          title="Daily Subscriptions"
          value={activeSubscribersCount}
          subtitle="Recurring daily milk & veggies"
          icon={CalendarClock}
          color="amber"
        />
      </div>

      {/* Analytics Graph & Quick Action Section */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Revenue Performance Chart */}
        <div className="lg:col-span-2 bg-white rounded-3xl p-6 border border-slate-200/80 shadow-sm">
          <div className="flex items-center justify-between mb-6">
            <div>
              <h3 className="text-lg font-bold text-slate-900 font-serif">Weekly Revenue Trend</h3>
              <p className="text-xs text-slate-500">Live order sales breakdown across days</p>
            </div>
            <div className="flex items-center gap-2 text-xs font-semibold text-brand-700 bg-brand-50 px-3 py-1.5 rounded-full border border-brand-200">
              <TrendingUp className="w-3.5 h-3.5" />
              <span>Real-time Sync</span>
            </div>
          </div>

          <div className="h-72 w-full">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={chartData} margin={{ top: 10, right: 10, left: -10, bottom: 0 }}>
                <defs>
                  <linearGradient id="revenueGradient" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#16a34a" stopOpacity={0.3}/>
                    <stop offset="95%" stopColor="#16a34a" stopOpacity={0}/>
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                <XAxis dataKey="day" axisLine={false} tickLine={false} tick={{ fill: '#64748b', fontSize: 12 }} />
                <YAxis axisLine={false} tickLine={false} tick={{ fill: '#64748b', fontSize: 12 }} tickFormatter={(v) => `₹${v}`} />
                <Tooltip 
                  formatter={(value) => [`₹${value.toLocaleString('en-IN')}`, 'Revenue']}
                  contentStyle={{ borderRadius: '12px', border: '1px solid #e2e8f0', boxShadow: '0 4px 12px rgba(0,0,0,0.05)' }}
                />
                <Area type="monotone" dataKey="revenue" stroke="#16a34a" strokeWidth={3} fillOpacity={1} fill="url(#revenueGradient)" />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Quick Stock & Catalog Health */}
        <div className="bg-white rounded-3xl p-6 border border-slate-200/80 shadow-sm flex flex-col justify-between">
          <div>
            <h3 className="text-lg font-bold text-slate-900 font-serif mb-1">Catalog Health</h3>
            <p className="text-xs text-slate-500 mb-6">Inventory status summary</p>

            <div className="space-y-4">
              <div className="flex items-center justify-between p-3.5 rounded-2xl bg-slate-50 border border-slate-100">
                <div className="flex items-center gap-3">
                  <div className="w-8 h-8 rounded-xl bg-emerald-100 text-emerald-700 flex items-center justify-center font-bold text-sm">
                    ✓
                  </div>
                  <div>
                    <div className="text-xs font-bold text-slate-800">In-Stock Produce</div>
                    <div className="text-[11px] text-slate-400">Available to customers</div>
                  </div>
                </div>
                <span className="text-sm font-bold text-slate-900">
                  {products.length - outOfStockProducts.length} items
                </span>
              </div>

              <div className="flex items-center justify-between p-3.5 rounded-2xl bg-slate-50 border border-slate-100">
                <div className="flex items-center gap-3">
                  <div className="w-8 h-8 rounded-xl bg-rose-100 text-rose-700 flex items-center justify-center font-bold text-sm">
                    !
                  </div>
                  <div>
                    <div className="text-xs font-bold text-slate-800">Out of Stock</div>
                    <div className="text-[11px] text-slate-400">Needs restock toggle</div>
                  </div>
                </div>
                <span className={`text-sm font-bold ${outOfStockProducts.length > 0 ? 'text-rose-600' : 'text-slate-400'}`}>
                  {outOfStockProducts.length} items
                </span>
              </div>

              <div className="flex items-center justify-between p-3.5 rounded-2xl bg-slate-50 border border-slate-100">
                <div className="flex items-center gap-3">
                  <div className="w-8 h-8 rounded-xl bg-amber-100 text-amber-700 flex items-center justify-center font-bold text-sm">
                    ★
                  </div>
                  <div>
                    <div className="text-xs font-bold text-slate-800">Popular / Featured</div>
                    <div className="text-[11px] text-slate-400">Highlighted on home feed</div>
                  </div>
                </div>
                <span className="text-sm font-bold text-slate-900">
                  {products.filter(p => p.isPopular).length} items
                </span>
              </div>
            </div>
          </div>

          <Link
            to="/products"
            className="mt-6 w-full py-3 rounded-2xl bg-slate-900 hover:bg-slate-800 text-white text-xs font-bold flex items-center justify-center gap-2 transition-all shadow-md"
          >
            <span>Manage Product Catalog</span>
            <ArrowRight className="w-4 h-4" />
          </Link>
        </div>
      </div>

      {/* Members & Subscriptions Table Section */}
      <div className="bg-white rounded-3xl border border-slate-200/80 shadow-sm overflow-hidden">
        <div className="p-6 border-b border-slate-100 flex flex-col sm:flex-row sm:items-center justify-between gap-3">
          <div>
            <div className="flex items-center gap-2">
              <h3 className="text-lg font-bold text-slate-900 font-serif">Registered Members & Subscriptions</h3>
              <span className="px-2.5 py-0.5 rounded-full text-[11px] font-bold bg-purple-50 text-purple-700 border border-purple-200">
                {members.length} Users
              </span>
            </div>
            <p className="text-xs text-slate-500 mt-0.5">Live registered mobile app accounts and recurring delivery plans</p>
          </div>
          <Link
            to="/members"
            className="text-xs font-bold text-brand-600 hover:text-brand-700 flex items-center gap-1 self-start sm:self-auto"
          >
            <span>Manage All Members</span>
            <ArrowRight className="w-3.5 h-3.5" />
          </Link>
        </div>

        {members.length === 0 ? (
          <div className="py-16 text-center text-slate-400">
            <Users className="w-12 h-12 mx-auto text-slate-300 mb-3" />
            <p className="text-sm font-medium">No registered members yet</p>
            <p className="text-xs text-slate-400 mt-1">Users registering from the mobile app will sync here automatically.</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-sm text-slate-600">
              <thead className="bg-slate-50 text-[11px] font-bold uppercase tracking-wider text-slate-400 border-b border-slate-100">
                <tr>
                  <th className="px-6 py-4">Member</th>
                  <th className="px-6 py-4">Mobile</th>
                  <th className="px-6 py-4">Active Subscription(s)</th>
                  <th className="px-6 py-4">Orders</th>
                  <th className="px-6 py-4">Total Spent</th>
                  <th className="px-6 py-4">Joined Date</th>
                  <th className="px-6 py-4 text-right">Action</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {members.slice(0, 6).map((member) => (
                  <tr key={member.id} className="hover:bg-slate-50/70 transition-colors">
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-3">
                        <div className="w-8 h-8 rounded-xl bg-gradient-to-tr from-brand-600 to-brand-400 text-white font-bold text-xs flex items-center justify-center shadow-sm">
                          {(member.name || 'M').charAt(0).toUpperCase()}
                        </div>
                        <div>
                          <div className="font-bold text-slate-900 text-xs">{member.name || 'Customer'}</div>
                          <div className="text-[10px] text-slate-400 font-mono">UID: {member.uid.slice(0, 8)}</div>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 text-xs font-semibold text-slate-800">
                      {member.phone || '-'}
                    </td>
                    <td className="px-6 py-4">
                      {(() => {
                        const subs = member.subscriptions || [];
                        const activeSubs = subs.filter(s => !s.status || String(s.status).toLowerCase() === 'active');
                        const pausedSubs = subs.filter(s => String(s.status).toLowerCase() === 'paused');
                        const cancelledSubs = subs.filter(s => String(s.status).toLowerCase() === 'cancelled');

                        if (activeSubs.length > 0) {
                          return (
                            <div className="flex flex-col gap-1.5 items-start">
                              <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-bold bg-emerald-50 text-emerald-700 border border-emerald-200">
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
                                <span>Paused</span>
                              </span>
                            </div>
                          );
                        }

                        if (cancelledSubs.length > 0) {
                          const lastCancelled = cancelledSubs[0];
                          let dateStr = '';
                          if (lastCancelled.cancelledAt) {
                            const d = new Date(lastCancelled.cancelledAt);
                            if (!isNaN(d.getTime())) {
                              dateStr = d.toLocaleDateString('en-IN', { day: 'numeric', month: 'short' });
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
                    <td className="px-6 py-4">
                      <span className="font-bold text-slate-800 text-xs px-2 py-0.5 rounded bg-slate-100">
                        {member.orderCount || 0} order(s)
                      </span>
                    </td>
                    <td className="px-6 py-4 font-bold text-slate-900 text-xs">
                      ₹{(member.totalSpent || 0).toLocaleString('en-IN')}
                    </td>
                    <td className="px-6 py-4 text-xs text-slate-400">
                      {member.joinedDate}
                    </td>
                    <td className="px-6 py-4 text-right">
                      <Link
                        to="/members"
                        className="px-3 py-1.5 rounded-xl bg-slate-100 hover:bg-brand-50 text-slate-700 hover:text-brand-700 font-bold text-xs transition-colors inline-block"
                      >
                        View Full Details
                      </Link>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Recent Orders Table Feed */}
      <div className="bg-white rounded-3xl border border-slate-200/80 shadow-sm overflow-hidden">
        <div className="p-6 border-b border-slate-100 flex items-center justify-between">
          <div>
            <h3 className="text-lg font-bold text-slate-900 font-serif">Recent Live Orders</h3>
            <p className="text-xs text-slate-500">Real-time incoming customer deliveries</p>
          </div>
          <Link
            to="/orders"
            className="text-xs font-bold text-brand-600 hover:text-brand-700 flex items-center gap-1"
          >
            <span>View All Orders</span>
            <ArrowRight className="w-3.5 h-3.5" />
          </Link>
        </div>

        {orders.length === 0 ? (
          <div className="py-16 text-center text-slate-400">
            <ShoppingBag className="w-12 h-12 mx-auto text-slate-300 mb-3" />
            <p className="text-sm font-medium">No customer orders yet</p>
            <p className="text-xs text-slate-400 mt-1">Orders placed from the mobile app will automatically appear here in real time.</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-sm text-slate-600">
              <thead className="bg-slate-50 text-[11px] font-bold uppercase tracking-wider text-slate-400 border-b border-slate-100">
                <tr>
                  <th className="px-6 py-4">Order ID</th>
                  <th className="px-6 py-4">Customer</th>
                  <th className="px-6 py-4">Items</th>
                  <th className="px-6 py-4">Amount</th>
                  <th className="px-6 py-4">Payment</th>
                  <th className="px-6 py-4">Status</th>
                  <th className="px-6 py-4">Date</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {orders.slice(0, 6).map((order) => (
                  <tr key={order.id} className="hover:bg-slate-50/70 transition-colors">
                    <td className="px-6 py-4 font-mono font-bold text-xs text-slate-900">
                      #{order.id.slice(0, 8).toUpperCase()}
                    </td>
                    <td className="px-6 py-4">
                      <div className="font-semibold text-slate-900 text-xs">
                        {order.customerName || order.userName || 'Customer'}
                      </div>
                      <div className="text-[11px] text-slate-400">
                        {order.customerPhone || order.phone || '-'}
                      </div>
                    </td>
                    <td className="px-6 py-4 text-xs font-medium max-w-xs truncate text-slate-800">
                      {Array.isArray(order.items) && order.items.length > 0
                        ? order.items.map(i => i.name || i.product?.name || 'Item').join(', ')
                        : 'Fresh Produce'}
                    </td>
                    <td className="px-6 py-4 font-bold text-slate-900 text-xs">
                      ₹{order.totalAmount || 0}
                    </td>
                    <td className="px-6 py-4 text-xs">
                      <span className="uppercase font-semibold text-[11px] px-2 py-0.5 rounded bg-slate-100 text-slate-700">
                        {order.paymentMethod || 'Razorpay'}
                      </span>
                    </td>
                    <td className="px-6 py-4">
                      <StatusBadge status={order.status} />
                    </td>
                    <td className="px-6 py-4 text-xs text-slate-400">
                      {order.createdAtFormatted}
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
