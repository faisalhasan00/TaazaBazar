import React, { useState, useEffect } from 'react';
import { Layers, Plus, Edit3, Trash2, Check, Sparkles } from 'lucide-react';
import Modal from '../components/Common/Modal';
import { categoryService } from '../services/categoryService';

export default function Categories() {
  const [categories, setCategories] = useState([]);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingCat, setEditingCat] = useState(null);
  const [formData, setFormData] = useState({
    id: '',
    name: '',
    icon: '🥦',
    itemCount: 0,
    sortOrder: 1,
    color: '#22c55e',
  });
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    const unsub = categoryService.subscribeToCategories((data) => setCategories(data));
    return () => unsub();
  }, []);

  const handleOpenCreate = () => {
    setEditingCat(null);
    setFormData({
      id: '',
      name: '',
      icon: '🥦',
      itemCount: 0,
      sortOrder: categories.length + 1,
      color: '#22c55e',
    });
    setIsModalOpen(true);
  };

  const handleOpenEdit = (cat) => {
    setEditingCat(cat);
    setFormData({
      id: cat.id,
      name: cat.name || '',
      icon: cat.icon || '🥦',
      itemCount: cat.itemCount || 0,
      sortOrder: cat.sortOrder || 1,
      color: cat.color || '#22c55e',
    });
    setIsModalOpen(true);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!formData.name.trim()) return;

    setIsSubmitting(true);
    try {
      await categoryService.saveCategory(editingCat ? editingCat.id : null, formData);
      setIsModalOpen(false);
    } catch (err) {
      console.error('Error saving category:', err);
      alert('Failed to save category');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleDelete = async (id, name) => {
    if (window.confirm(`Delete category "${name}"?`)) {
      try {
        await categoryService.deleteCategory(id);
      } catch (err) {
        console.error('Failed to delete category:', err);
      }
    }
  };

  return (
    <div className="p-8 space-y-6 max-w-7xl mx-auto">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-2xl font-bold text-slate-900 font-serif">Store Categories</h2>
          <p className="text-xs text-slate-500">Organize vegetables, fruits, dairy, and staples</p>
        </div>

        <button
          onClick={handleOpenCreate}
          className="px-5 py-2.5 rounded-2xl bg-brand-600 hover:bg-brand-700 text-white text-xs font-bold flex items-center justify-center gap-2 shadow-lg shadow-brand-600/20 transition-all self-start sm:self-auto"
        >
          <Plus className="w-4 h-4" />
          <span>Add New Category</span>
        </button>
      </div>

      {/* Categories Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-5">
        {categories.map((cat) => (
          <div 
            key={cat.id}
            className="bg-white rounded-3xl p-5 border border-slate-200/80 shadow-sm hover:shadow-md transition-all flex flex-col justify-between"
          >
            <div>
              <div className="flex items-start justify-between mb-4">
                <div 
                  className="w-12 h-12 rounded-2xl flex items-center justify-center text-2xl shadow-inner border border-slate-100"
                  style={{ backgroundColor: `${cat.color || '#22c55e'}15` }}
                >
                  {cat.icon || '🥦'}
                </div>
                <div className="flex items-center gap-1">
                  <button
                    onClick={() => handleOpenEdit(cat)}
                    className="p-1.5 text-slate-400 hover:text-brand-600 hover:bg-brand-50 rounded-lg transition-colors"
                  >
                    <Edit3 className="w-4 h-4" />
                  </button>
                  <button
                    onClick={() => handleDelete(cat.id, cat.name)}
                    className="p-1.5 text-slate-400 hover:text-rose-600 hover:bg-rose-50 rounded-lg transition-colors"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>

              <h3 className="font-bold text-slate-900 text-base font-serif">{cat.name}</h3>
              <p className="text-xs text-slate-400 font-mono mt-0.5">ID: {cat.id}</p>
            </div>

            <div className="mt-5 pt-4 border-t border-slate-100 flex items-center justify-between text-xs">
              <span className="text-slate-500 font-medium">Display Priority</span>
              <span className="font-bold text-slate-800 bg-slate-100 px-2 py-0.5 rounded-md">
                Order #{cat.sortOrder || 1}
              </span>
            </div>
          </div>
        ))}
      </div>

      {/* Category Modal */}
      <Modal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        title={editingCat ? 'Edit Category' : 'Create Category'}
        subtitle="Categories group products on the app home screen."
      >
        <form onSubmit={handleSubmit} className="space-y-4 text-xs">
          <div>
            <label className="block font-bold text-slate-700 mb-1">Category Name *</label>
            <input
              type="text"
              required
              placeholder="e.g. Exotic Vegetables, Organic Millets"
              value={formData.name}
              onChange={(e) => setFormData({ ...formData, name: e.target.value })}
              className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-brand-500/20 font-medium"
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block font-bold text-slate-700 mb-1">Emoji / Icon *</label>
              <input
                type="text"
                required
                placeholder="e.g. 🥦, 🍎, 🥛, 🌾"
                value={formData.icon}
                onChange={(e) => setFormData({ ...formData, icon: e.target.value })}
                className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-brand-500/20 font-medium text-lg text-center"
              />
            </div>

            <div>
              <label className="block font-bold text-slate-700 mb-1">Sort Order (Priority)</label>
              <input
                type="number"
                value={formData.sortOrder}
                onChange={(e) => setFormData({ ...formData, sortOrder: e.target.value })}
                className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-brand-500/20 font-medium"
              />
            </div>
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
              disabled={isSubmitting}
              className="px-6 py-2.5 rounded-xl bg-brand-600 hover:bg-brand-700 text-white font-bold shadow-md shadow-brand-600/20"
            >
              {isSubmitting ? 'Saving...' : editingCat ? 'Save Changes' : 'Create Category'}
            </button>
          </div>
        </form>
      </Modal>
    </div>
  );
}
