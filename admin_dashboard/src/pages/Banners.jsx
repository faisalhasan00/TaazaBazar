import React, { useState, useEffect } from 'react';
import { Image as ImageIcon, Plus, Trash2, ExternalLink } from 'lucide-react';
import Modal from '../components/Common/Modal';
import { bannerService } from '../services/extraServices';

export default function Banners() {
  const [banners, setBanners] = useState([]);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [formData, setFormData] = useState({
    title: '',
    subtitle: '',
    imageUrl: '',
    linkTo: 'categories',
    isActive: true,
  });

  useEffect(() => {
    const unsub = bannerService.subscribeToBanners((data) => setBanners(data));
    return () => unsub();
  }, []);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!formData.imageUrl.trim()) return;

    try {
      await bannerService.addBanner(formData);
      setIsModalOpen(false);
      setFormData({
        title: '',
        subtitle: '',
        imageUrl: '',
        linkTo: 'categories',
        isActive: true,
      });
    } catch (err) {
      console.error(err);
      alert('Failed to add banner');
    }
  };

  const handleDelete = async (id) => {
    if (window.confirm('Remove this promotional banner?')) {
      await bannerService.deleteBanner(id);
    }
  };

  return (
    <div className="p-8 space-y-6 max-w-7xl mx-auto">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-2xl font-bold text-slate-900 font-serif">Home Screen Carousel Banners</h2>
          <p className="text-xs text-slate-500">Feature promotions, discounts, and seasonal harvests</p>
        </div>

        <button
          onClick={() => setIsModalOpen(true)}
          className="px-5 py-2.5 rounded-2xl bg-brand-600 hover:bg-brand-700 text-white text-xs font-bold flex items-center justify-center gap-2 shadow-lg shadow-brand-600/20 transition-all self-start sm:self-auto"
        >
          <Plus className="w-4 h-4" />
          <span>Upload Banner</span>
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {banners.map((b) => (
          <div key={b.id} className="bg-white rounded-3xl border border-slate-200/80 shadow-sm overflow-hidden flex flex-col justify-between">
            <div className="h-44 bg-slate-100 relative overflow-hidden">
              {b.imageUrl ? (
                <img src={b.imageUrl} alt={b.title} className="w-full h-full object-cover" />
              ) : (
                <div className="flex items-center justify-center h-full text-slate-400">
                  <ImageIcon className="w-8 h-8" />
                </div>
              )}
              <button
                onClick={() => handleDelete(b.id)}
                className="absolute top-3 right-3 p-2 bg-black/60 text-white hover:bg-rose-600 rounded-xl backdrop-blur-sm transition-colors"
              >
                <Trash2 className="w-4 h-4" />
              </button>
            </div>

            <div className="p-5">
              <h3 className="font-bold text-slate-900 text-base font-serif">{b.title || 'Promotional Banner'}</h3>
              <p className="text-xs text-slate-500 mt-1">{b.subtitle || 'Active in home carousel'}</p>
            </div>
          </div>
        ))}
      </div>

      {/* Banner Modal */}
      <Modal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        title="Add Promotional Banner"
        subtitle="This image will display in the top banner slider on the mobile home screen."
      >
        <form onSubmit={handleSubmit} className="space-y-4 text-xs">
          <div>
            <label className="block font-bold text-slate-700 mb-1">Banner Title *</label>
            <input
              type="text"
              required
              placeholder="e.g. 50% OFF on Morning Fresh Harvest"
              value={formData.title}
              onChange={(e) => setFormData({ ...formData, title: e.target.value })}
              className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-brand-500/20 font-medium"
            />
          </div>

          <div>
            <label className="block font-bold text-slate-700 mb-1">Subtitle / Call to Action</label>
            <input
              type="text"
              placeholder="e.g. Use code TAAZA50 at checkout"
              value={formData.subtitle}
              onChange={(e) => setFormData({ ...formData, subtitle: e.target.value })}
              className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-brand-500/20 font-medium"
            />
          </div>

          <div>
            <label className="block font-bold text-slate-700 mb-1">Image URL (High Quality) *</label>
            <input
              type="url"
              required
              placeholder="https://images.unsplash.com/..."
              value={formData.imageUrl}
              onChange={(e) => setFormData({ ...formData, imageUrl: e.target.value })}
              className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-brand-500/20 font-medium"
            />
            {formData.imageUrl && (
              <div className="mt-2 h-32 rounded-xl overflow-hidden border border-slate-200">
                <img src={formData.imageUrl} alt="Preview" className="w-full h-full object-cover" />
              </div>
            )}
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
              Publish Banner
            </button>
          </div>
        </form>
      </Modal>
    </div>
  );
}
