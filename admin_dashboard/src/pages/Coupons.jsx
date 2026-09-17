import React, { useState, useEffect } from 'react';
import { TicketPercent, Plus, Trash2, Tag, Sparkles } from 'lucide-react';
import Modal from '../components/Common/Modal';
import { couponService } from '../services/extraServices';

export default function Coupons() {
  const [coupons, setCoupons] = useState([]);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [formData, setFormData] = useState({
    code: '',
    discountAmount: 50,
    minOrder: 199,
    description: 'Flat ₹50 OFF on orders above ₹199',
    isActive: true,
  });

  useEffect(() => {
    const unsub = couponService.subscribeToCoupons((data) => setCoupons(data));
    return () => unsub();
  }, []);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!formData.code.trim()) return;

    try {
      await couponService.addCoupon(formData);
      setIsModalOpen(false);
      setFormData({
        code: '',
        discountAmount: 50,
        minOrder: 199,
        description: '',
        isActive: true,
      });
    } catch (err) {
      console.error(err);
      alert('Failed to add coupon');
    }
  };

  const handleDelete = async (id) => {
    if (window.confirm('Delete this coupon code?')) {
      await couponService.deleteCoupon(id);
    }
  };

  return (
    <div className="p-8 space-y-6 max-w-7xl mx-auto">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-2xl font-bold text-slate-900 font-serif">Discount Coupons & Offers</h2>
          <p className="text-xs text-slate-500">Create promotional discount codes for cart checkout</p>
        </div>

        <button
          onClick={() => setIsModalOpen(true)}
          className="px-5 py-2.5 rounded-2xl bg-brand-600 hover:bg-brand-700 text-white text-xs font-bold flex items-center justify-center gap-2 shadow-lg shadow-brand-600/20 transition-all self-start sm:self-auto"
        >
          <Plus className="w-4 h-4" />
          <span>Create Coupon Code</span>
        </button>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-5">
        {coupons.map((coupon) => (
          <div key={coupon.id} className="bg-white rounded-3xl p-6 border border-slate-200/80 shadow-sm relative overflow-hidden flex flex-col justify-between">
            <div className="absolute top-0 right-0 w-24 h-24 bg-brand-50 rounded-bl-full pointer-events-none" />
            <div>
              <div className="flex items-center justify-between mb-3">
                <span className="font-mono text-base font-extrabold text-brand-700 px-3 py-1 rounded-xl bg-brand-50 border border-brand-200">
                  {coupon.code}
                </span>
                <button
                  onClick={() => handleDelete(coupon.id)}
                  className="p-1.5 text-slate-400 hover:text-rose-600 rounded-lg"
                >
                  <Trash2 className="w-4 h-4" />
                </button>
              </div>

              <div className="text-xl font-extrabold text-slate-900 font-serif">
                ₹{coupon.discountAmount} OFF
              </div>
              <p className="text-xs text-slate-500 mt-1">
                {coupon.description || `Min cart order ₹${coupon.minOrder}`}
              </p>
            </div>

            <div className="mt-6 pt-4 border-t border-slate-100 flex items-center justify-between text-xs">
              <span className="text-slate-400">Min Order: ₹{coupon.minOrder}</span>
              <span className="px-2 py-0.5 rounded-full bg-emerald-50 text-emerald-700 font-bold text-[10px]">
                Active
              </span>
            </div>
          </div>
        ))}
      </div>

      {/* Coupon Modal */}
      <Modal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        title="Create New Coupon Code"
        subtitle="Customers can enter this code in the app cart to receive a discount."
      >
        <form onSubmit={handleSubmit} className="space-y-4 text-xs">
          <div>
            <label className="block font-bold text-slate-700 mb-1">Coupon Code (Uppercase) *</label>
            <input
              type="text"
              required
              placeholder="e.g. TAAZA50, FRESH100, SUMMER20"
              value={formData.code}
              onChange={(e) => setFormData({ ...formData, code: e.target.value.toUpperCase() })}
              className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 font-mono font-bold text-sm focus:outline-none focus:ring-2 focus:ring-brand-500/20"
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block font-bold text-slate-700 mb-1">Discount Amount (₹) *</label>
              <input
                type="number"
                required
                placeholder="50"
                value={formData.discountAmount}
                onChange={(e) => setFormData({ ...formData, discountAmount: e.target.value })}
                className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-brand-500/20 font-medium"
              />
            </div>

            <div>
              <label className="block font-bold text-slate-700 mb-1">Minimum Order Value (₹) *</label>
              <input
                type="number"
                required
                placeholder="199"
                value={formData.minOrder}
                onChange={(e) => setFormData({ ...formData, minOrder: e.target.value })}
                className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-brand-500/20 font-medium"
              />
            </div>
          </div>

          <div>
            <label className="block font-bold text-slate-700 mb-1">Description / Tagline</label>
            <input
              type="text"
              placeholder="e.g. Save ₹50 on your fresh farm order"
              value={formData.description}
              onChange={(e) => setFormData({ ...formData, description: e.target.value })}
              className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-brand-500/20 font-medium"
            />
          </div>

          <div className="flex justify-end gap-3 pt-4 border-t border-slate-100">
            <button
              type="button"
              onClick={() => setIsModalOpen(false)}
              className="px-4 py-2.5 rounded-xl border border-slate-200 text-slate-600 font-bold hover:bg-slate-50"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="px-6 py-2.5 rounded-xl bg-brand-600 hover:bg-brand-700 text-white font-bold shadow-md shadow-brand-600/20"
            >
              Publish Coupon
            </button>
          </div>
        </form>
      </Modal>
    </div>
  );
}
