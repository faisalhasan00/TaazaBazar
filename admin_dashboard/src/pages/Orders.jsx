import React, { useState, useEffect } from 'react';
import { 
  ShoppingBag, 
  Clock, 
  CheckCircle2, 
  Truck, 
  Package, 
  MapPin, 
  Phone, 
  User, 
  AlertCircle,
  IndianRupee,
  ChevronRight,
  Filter,
  Search,
  ExternalLink
} from 'lucide-react';
import { StatusBadge } from '../components/Common/Badge';
import Modal from '../components/Common/Modal';
import { orderService } from '../services/orderService';

export default function Orders() {
  const [orders, setOrders] = useState([]);
  const [selectedStatus, setSelectedStatus] = useState('all');
  const [searchQuery, setSearchQuery] = useState('');
  
  // Order Detail Modal
  const [activeOrder, setActiveOrder] = useState(null);
  const [isUpdating, setIsUpdating] = useState(false);

  useEffect(() => {
    const unsub = orderService.subscribeToOrders((data) => setOrders(data));
    return () => unsub();
  }, []);

  // Filter Orders
  const filteredOrders = orders.filter((o) => {
    const matchesStatus = selectedStatus === 'all' || o.status === selectedStatus;
    const matchesSearch = 
      (o.id || '').toLowerCase().includes(searchQuery.toLowerCase()) ||
      (o.customerName || o.userName || '').toLowerCase().includes(searchQuery.toLowerCase()) ||
      (o.customerPhone || o.phone || '').includes(searchQuery);
    return matchesStatus && matchesSearch;
  });

  // Status Tabs
  const statusTabs = [
    { id: 'all', label: 'All Orders', count: orders.length },
    { id: 'placed', label: 'Placed', count: orders.filter(o => o.status === 'placed').length },
    { id: 'confirmed', label: 'Confirmed', count: orders.filter(o => o.status === 'confirmed').length },
    { id: 'packed', label: 'Packed', count: orders.filter(o => o.status === 'packed').length },
    { id: 'out_for_delivery', label: 'Out for Delivery', count: orders.filter(o => o.status === 'out_for_delivery').length },
    { id: 'delivered', label: 'Delivered', count: orders.filter(o => o.status === 'delivered').length },
    { id: 'cancelled', label: 'Cancelled', count: orders.filter(o => o.status === 'cancelled').length },
  ];

  // Update Status Handler
  const handleStatusChange = async (orderId, newStatus) => {
    setIsUpdating(true);
    try {
      await orderService.updateOrderStatus(orderId, newStatus);
      if (activeOrder && activeOrder.id === orderId) {
        setActiveOrder(prev => ({ ...prev, status: newStatus }));
      }
    } catch (err) {
      console.error('Failed to update order status:', err);
      alert('Could not update status: ' + err.message);
    } finally {
      setIsUpdating(false);
    }
  };

  return (
    <div className="p-8 space-y-6 max-w-7xl mx-auto">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-2xl font-bold text-slate-900 font-serif">Live Order Dispatch & Fulfillment</h2>
          <p className="text-xs text-slate-500">Incoming farm produce orders with instant customer app sync</p>
        </div>

        <div className="flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-emerald-50 border border-emerald-200 text-emerald-700 text-xs font-bold">
          <span className="w-2 h-2 rounded-full bg-emerald-500 animate-ping" />
          <span>Listening for new orders</span>
        </div>
      </div>

      {/* Status Filter Tabs */}
      <div className="flex items-center gap-2 overflow-x-auto pb-2 scrollbar-none">
        {statusTabs.map((tab) => (
          <button
            key={tab.id}
            onClick={() => setSelectedStatus(tab.id)}
            className={`px-4 py-2 rounded-xl text-xs font-bold whitespace-nowrap transition-all flex items-center gap-2 ${
              selectedStatus === tab.id
                ? 'bg-slate-900 text-white shadow-md'
                : 'bg-white text-slate-600 border border-slate-200 hover:bg-slate-50'
            }`}
          >
            <span>{tab.label}</span>
            <span className={`px-1.5 py-0.5 rounded-full text-[10px] ${
              selectedStatus === tab.id ? 'bg-slate-800 text-brand-400' : 'bg-slate-100 text-slate-600'
            }`}>
              {tab.count}
            </span>
          </button>
        ))}
      </div>

      {/* Search toolbar */}
      <div className="bg-white rounded-2xl p-4 border border-slate-200/80 shadow-sm">
        <div className="relative w-full">
          <Search className="w-4 h-4 absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400" />
          <input
            type="text"
            placeholder="Search by Order ID, customer name, or phone number..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full pl-10 pr-4 py-2 text-xs rounded-xl bg-slate-50 border border-slate-200 focus:bg-white focus:outline-none focus:ring-2 focus:ring-brand-500/20 focus:border-brand-500 transition-all"
          />
        </div>
      </div>

      {/* Orders Grid / Table */}
      <div className="bg-white rounded-3xl border border-slate-200/80 shadow-sm overflow-hidden">
        {filteredOrders.length === 0 ? (
          <div className="py-20 text-center text-slate-400">
            <ShoppingBag className="w-12 h-12 mx-auto text-slate-300 mb-3" />
            <p className="text-sm font-semibold text-slate-600">No orders match filter</p>
            <p className="text-xs text-slate-400 mt-1">Orders placed by customers will immediately appear in this list.</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-sm text-slate-600">
              <thead className="bg-slate-50 text-[11px] font-bold uppercase tracking-wider text-slate-400 border-b border-slate-100">
                <tr>
                  <th className="px-6 py-4">Order ID & Date</th>
                  <th className="px-6 py-4">Customer</th>
                  <th className="px-6 py-4">Items Summary</th>
                  <th className="px-6 py-4">Total Amount</th>
                  <th className="px-6 py-4">Payment</th>
                  <th className="px-6 py-4">Status & Dispatch</th>
                  <th className="px-6 py-4 text-right">Details</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {filteredOrders.map((order) => (
                  <tr key={order.id} className="hover:bg-slate-50/70 transition-colors">
                    <td className="px-6 py-4">
                      <div className="font-mono font-bold text-xs text-slate-900">
                        #{order.id.slice(0, 8).toUpperCase()}
                      </div>
                      <div className="text-[11px] text-slate-400 mt-0.5">
                        {order.createdAtFormatted}
                      </div>
                    </td>

                    <td className="px-6 py-4">
                      <div className="font-semibold text-slate-900 text-xs">
                        {order.customerName || order.userName || 'Customer'}
                      </div>
                      <div className="text-[11px] text-slate-400 flex items-center gap-1">
                        <Phone className="w-3 h-3" />
                        <span>{order.customerPhone || order.phone || '-'}</span>
                      </div>
                    </td>

                    <td className="px-6 py-4 text-xs font-medium">
                      {Array.isArray(order.items) && order.items.length > 0 ? (
                        <div className="max-w-xs truncate text-slate-800 font-medium">
                          {order.items.map(i => `${i.name || i.product?.name || i.productName || 'Produce Item'} (${i.quantity || 1})`).join(', ')}
                        </div>
                      ) : (
                        <span className="text-slate-400 italic">Fresh Produce Order</span>
                      )}
                    </td>

                    <td className="px-6 py-4">
                      <div className="font-bold text-slate-900 text-xs">
                        ₹{order.totalAmount || 0}
                      </div>
                      <div className="text-[10px] text-slate-400">
                        {order.paymentStatus === 'paid' ? 'Paid Online' : 'Pay on Delivery'}
                      </div>
                    </td>

                    <td className="px-6 py-4 text-xs">
                      <span className="uppercase font-semibold text-[11px] px-2 py-0.5 rounded bg-slate-100 text-slate-700">
                        {order.paymentMethod || 'Razorpay'}
                      </span>
                    </td>

                    <td className="px-6 py-4">
                      <div className="flex items-center gap-2">
                        <StatusBadge status={order.status} />
                        <select
                          value={order.status || 'placed'}
                          disabled={isUpdating}
                          onChange={(e) => handleStatusChange(order.id, e.target.value)}
                          className="text-[11px] font-bold px-2 py-1 rounded-lg border border-slate-200 bg-white text-slate-700 focus:outline-none focus:ring-2 focus:ring-brand-500/20"
                        >
                          <option value="placed">Placed</option>
                          <option value="confirmed">Confirmed</option>
                          <option value="packed">Packed</option>
                          <option value="out_for_delivery">Out for Delivery</option>
                          <option value="delivered">Delivered</option>
                          <option value="cancelled">Cancelled</option>
                        </select>
                      </div>
                    </td>

                    <td className="px-6 py-4 text-right">
                      <button
                        onClick={() => setActiveOrder(order)}
                        className="px-3 py-1.5 rounded-xl bg-slate-100 hover:bg-brand-50 text-slate-700 hover:text-brand-700 font-bold text-xs transition-colors"
                      >
                        View
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Order Detail Modal */}
      <Modal
        isOpen={!!activeOrder}
        onClose={() => setActiveOrder(null)}
        title={activeOrder ? `Order #${activeOrder.id.slice(0, 8).toUpperCase()}` : ''}
        subtitle={activeOrder ? `Placed on ${activeOrder.createdAtFormatted}` : ''}
        maxWidth="max-w-3xl"
      >
        {activeOrder && (
          <div className="space-y-6 text-xs">
            {/* Customer & Address Card */}
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 p-4 rounded-2xl bg-slate-50 border border-slate-100">
              <div>
                <div className="text-[11px] font-bold uppercase tracking-wider text-slate-400 mb-1 flex items-center gap-1.5">
                  <User className="w-3.5 h-3.5 text-brand-600" />
                  <span>Customer Details</span>
                </div>
                <div className="font-bold text-slate-900 text-sm">{activeOrder.customerName || activeOrder.userName || 'Customer'}</div>
                <div className="text-slate-600 mt-0.5">{activeOrder.customerPhone || activeOrder.phone || 'No phone provided'}</div>
              </div>

              <div>
                <div className="text-[11px] font-bold uppercase tracking-wider text-slate-400 mb-1 flex items-center gap-1.5">
                  <MapPin className="w-3.5 h-3.5 text-brand-600" />
                  <span>Delivery Address</span>
                </div>
                <div className="text-slate-700 font-medium leading-relaxed">
                  {typeof activeOrder.deliveryAddress === 'object' && activeOrder.deliveryAddress !== null
                    ? `${activeOrder.deliveryAddress.houseNumber || ''}, ${activeOrder.deliveryAddress.street || ''}, ${activeOrder.deliveryAddress.city || ''} ${activeOrder.deliveryAddress.pincode || ''}`
                    : (activeOrder.deliveryAddress || 'Standard Delivery Address')}
                </div>
                {activeOrder.deliverySlot && (
                  <div className="mt-1 text-brand-700 font-semibold text-[11px]">
                    Slot: {activeOrder.deliverySlot}
                  </div>
                )}
              </div>
            </div>

            {/* Itemized Products Table */}
            <div>
              <div className="font-bold text-slate-900 text-sm mb-3">Itemized Produce Breakdown</div>
              <div className="rounded-2xl border border-slate-100 overflow-hidden">
                <table className="w-full text-left text-xs">
                  <thead className="bg-slate-50 text-slate-400 font-bold uppercase text-[10px]">
                    <tr>
                      <th className="px-4 py-2.5">Item</th>
                      <th className="px-4 py-2.5">Unit Price</th>
                      <th className="px-4 py-2.5">Qty</th>
                      <th className="px-4 py-2.5 text-right">Total</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100">
                    {Array.isArray(activeOrder.items) && activeOrder.items.length > 0 ? (
                      activeOrder.items.map((item, idx) => (
                        <tr key={idx} className="hover:bg-slate-50/50">
                          <td className="px-4 py-3 font-semibold text-slate-900">
                            {item.name}
                            {item.unit && <span className="text-slate-400 font-normal ml-1">({item.unit})</span>}
                          </td>
                          <td className="px-4 py-3 text-slate-600">₹{item.price}</td>
                          <td className="px-4 py-3 font-bold text-slate-900">{item.quantity || 1}</td>
                          <td className="px-4 py-3 text-right font-bold text-slate-900">
                            ₹{(Number(item.price) || 0) * (Number(item.quantity) || 1)}
                          </td>
                        </tr>
                      ))
                    ) : (
                      <tr>
                        <td colSpan="4" className="px-4 py-4 text-center text-slate-400">No items breakdown available</td>
                      </tr>
                    )}
                  </tbody>
                </table>
              </div>
            </div>

            {/* Bill Summary */}
            <div className="flex justify-end">
              <div className="w-64 space-y-1.5 p-4 rounded-2xl bg-slate-50 border border-slate-100 text-slate-600">
                <div className="flex justify-between">
                  <span>Subtotal</span>
                  <span className="font-semibold text-slate-900">₹{activeOrder.subtotal || activeOrder.totalAmount}</span>
                </div>
                {activeOrder.deliveryFee && (
                  <div className="flex justify-between">
                    <span>Delivery Fee</span>
                    <span className="font-semibold text-slate-900">₹{activeOrder.deliveryFee}</span>
                  </div>
                )}
                {activeOrder.discount && (
                  <div className="flex justify-between text-emerald-600">
                    <span>Discount Coupon</span>
                    <span>-₹{activeOrder.discount}</span>
                  </div>
                )}
                <div className="border-t border-slate-200 pt-2 flex justify-between font-bold text-slate-900 text-sm">
                  <span>Grand Total</span>
                  <span className="text-brand-700">₹{activeOrder.totalAmount}</span>
                </div>
              </div>
            </div>

            {/* Quick Status Dispatch Buttons */}
            <div className="pt-4 border-t border-slate-100 flex flex-wrap items-center justify-between gap-3">
              <div className="flex items-center gap-2">
                <span className="font-bold text-slate-700">Update Status:</span>
                <StatusBadge status={activeOrder.status} />
              </div>

              <div className="flex items-center gap-2">
                {['confirmed', 'packed', 'out_for_delivery', 'delivered'].map((st) => (
                  <button
                    key={st}
                    disabled={isUpdating || activeOrder.status === st}
                    onClick={() => handleStatusChange(activeOrder.id, st)}
                    className={`px-3 py-1.5 rounded-xl font-bold text-xs transition-all ${
                      activeOrder.status === st
                        ? 'bg-brand-600 text-white shadow-sm'
                        : 'bg-slate-100 text-slate-700 hover:bg-slate-200'
                    }`}
                  >
                    Mark {st.replace(/_/g, ' ')}
                  </button>
                ))}
              </div>
            </div>
          </div>
        )}
      </Modal>
    </div>
  );
}
