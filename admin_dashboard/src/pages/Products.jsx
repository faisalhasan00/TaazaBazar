import React, { useState, useEffect } from 'react';
import { 
  Package, 
  Plus, 
  Search, 
  Filter, 
  Edit3, 
  Trash2, 
  Star, 
  Check, 
  X, 
  Sparkles,
  Image as ImageIcon,
  ExternalLink,
  Tag
} from 'lucide-react';
import Modal from '../components/Common/Modal';
import { StockBadge } from '../components/Common/Badge';
import { productService } from '../services/productService';
import { categoryService } from '../services/categoryService';

export default function Products() {
  const [products, setProducts] = useState([]);
  const [categories, setCategories] = useState([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('all');
  const [stockFilter, setStockFilter] = useState('all');

  // Modal State
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingProduct, setEditingProduct] = useState(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  // Form State
  const [formData, setFormData] = useState({
    name: '',
    categoryId: 'vegetables',
    categoryName: 'Vegetables',
    price: '',
    originalPrice: '',
    unit: '1 kg',
    imageUrl: '',
    inStock: true,
    isPopular: false,
    farmOrigin: '',
    description: '',
  });

  useEffect(() => {
    const unsubProducts = productService.subscribeToProducts((data) => setProducts(data));
    const unsubCategories = categoryService.subscribeToCategories((data) => {
      setCategories(data);
      if (data.length > 0 && !formData.categoryId) {
        setFormData(prev => ({
          ...prev,
          categoryId: data[0].id,
          categoryName: data[0].name
        }));
      }
    });

    return () => {
      unsubProducts();
      unsubCategories();
    };
  }, []);

  // Filtered Products
  const filteredProducts = products.filter((p) => {
    const matchesSearch = (p.name || '').toLowerCase().includes(searchQuery.toLowerCase()) ||
                          (p.farmOrigin || '').toLowerCase().includes(searchQuery.toLowerCase());
    const matchesCategory = selectedCategory === 'all' || p.categoryId === selectedCategory;
    const matchesStock = stockFilter === 'all' || 
      (stockFilter === 'in_stock' && p.inStock !== false) ||
      (stockFilter === 'out_of_stock' && p.inStock === false);

    return matchesSearch && matchesCategory && matchesStock;
  });

  // Open modal for Create
  const handleOpenCreateModal = () => {
    setEditingProduct(null);
    setFormData({
      name: '',
      categoryId: categories[0]?.id || 'vegetables',
      categoryName: categories[0]?.name || 'Vegetables',
      price: '',
      originalPrice: '',
      unit: '1 kg',
      imageUrl: '',
      inStock: true,
      isPopular: false,
      farmOrigin: '',
      description: '',
    });
    setIsModalOpen(true);
  };

  // Open modal for Edit
  const handleOpenEditModal = (product) => {
    setEditingProduct(product);
    setFormData({
      name: product.name || '',
      categoryId: product.categoryId || categories[0]?.id || 'vegetables',
      categoryName: product.categoryName || categories[0]?.name || 'Vegetables',
      price: product.price || '',
      originalPrice: product.originalPrice || '',
      unit: product.unit || '1 kg',
      imageUrl: product.imageUrl || '',
      inStock: product.inStock !== false,
      isPopular: !!product.isPopular,
      farmOrigin: product.farmOrigin || '',
      description: product.description || '',
    });
    setIsModalOpen(true);
  };

  // Category select change
  const handleCategorySelect = (e) => {
    const catId = e.target.value;
    const selected = categories.find(c => c.id === catId);
    setFormData(prev => ({
      ...prev,
      categoryId: catId,
      categoryName: selected ? selected.name : catId
    }));
  };

  // Save product
  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!formData.name.trim() || !formData.price) {
      alert('Please fill in Product Name and Selling Price');
      return;
    }

    setIsSubmitting(true);
    try {
      if (editingProduct) {
        await productService.updateProduct(editingProduct.id, formData);
      } else {
        await productService.addProduct(formData);
      }
      setIsModalOpen(false);
    } catch (err) {
      console.error('Error saving product:', err);
      alert('Failed to save product: ' + err.message);
    } finally {
      setIsSubmitting(false);
    }
  };

  // Delete product
  const handleDelete = async (id, name) => {
    if (window.confirm(`Are you sure you want to remove "${name}" from the store catalog?`)) {
      try {
        await productService.deleteProduct(id);
      } catch (err) {
        console.error('Failed to delete product:', err);
        alert('Could not delete product');
      }
    }
  };

  return (
    <div className="p-8 space-y-6 max-w-7xl mx-auto">
      {/* Header & Add Button */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-2xl font-bold text-slate-900 font-serif">Product & Inventory Catalog</h2>
          <p className="text-xs text-slate-500">Manage fresh produce, stock levels, and store prices</p>
        </div>

        <button
          onClick={handleOpenCreateModal}
          className="px-5 py-2.5 rounded-2xl bg-brand-600 hover:bg-brand-700 text-white text-xs font-bold flex items-center justify-center gap-2 shadow-lg shadow-brand-600/20 transition-all self-start sm:self-auto"
        >
          <Plus className="w-4 h-4" />
          <span>Add New Product</span>
        </button>
      </div>

      {/* Filters & Search Toolbar */}
      <div className="bg-white rounded-2xl p-4 border border-slate-200/80 shadow-sm flex flex-col md:flex-row items-center gap-3">
        {/* Search */}
        <div className="relative flex-1 w-full">
          <Search className="w-4 h-4 absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400" />
          <input
            type="text"
            placeholder="Search produce by name, origin, or farm..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full pl-10 pr-4 py-2 text-xs rounded-xl bg-slate-50 border border-slate-200 focus:bg-white focus:outline-none focus:ring-2 focus:ring-brand-500/20 focus:border-brand-500 transition-all"
          />
        </div>

        {/* Category Filter */}
        <div className="flex items-center gap-2 w-full md:w-auto">
          <select
            value={selectedCategory}
            onChange={(e) => setSelectedCategory(e.target.value)}
            className="px-3.5 py-2 text-xs rounded-xl bg-slate-50 border border-slate-200 font-medium text-slate-700 focus:outline-none focus:ring-2 focus:ring-brand-500/20"
          >
            <option value="all">All Categories ({products.length})</option>
            {categories.map((c) => (
              <option key={c.id} value={c.id}>
                {c.name}
              </option>
            ))}
          </select>

          {/* Stock Filter */}
          <select
            value={stockFilter}
            onChange={(e) => setStockFilter(e.target.value)}
            className="px-3.5 py-2 text-xs rounded-xl bg-slate-50 border border-slate-200 font-medium text-slate-700 focus:outline-none focus:ring-2 focus:ring-brand-500/20"
          >
            <option value="all">All Stock Status</option>
            <option value="in_stock">In Stock Only</option>
            <option value="out_of_stock">Out of Stock Only</option>
          </select>
        </div>
      </div>

      {/* Product Table */}
      <div className="bg-white rounded-3xl border border-slate-200/80 shadow-sm overflow-hidden">
        {filteredProducts.length === 0 ? (
          <div className="py-20 text-center text-slate-400">
            <Package className="w-12 h-12 mx-auto text-slate-300 mb-3" />
            <p className="text-sm font-semibold text-slate-600">No products found</p>
            <p className="text-xs text-slate-400 mt-1">Try adjusting your search query or add a new produce item.</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-sm text-slate-600">
              <thead className="bg-slate-50 text-[11px] font-bold uppercase tracking-wider text-slate-400 border-b border-slate-100">
                <tr>
                  <th className="px-6 py-4">Item & Visual</th>
                  <th className="px-6 py-4">Category</th>
                  <th className="px-6 py-4">Unit / Weight</th>
                  <th className="px-6 py-4">Price (₹)</th>
                  <th className="px-6 py-4">Stock Status</th>
                  <th className="px-6 py-4">Featured</th>
                  <th className="px-6 py-4 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {filteredProducts.map((product) => (
                  <tr key={product.id} className="hover:bg-slate-50/70 transition-colors">
                    {/* Item & Image */}
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-3">
                        <div className="w-12 h-12 rounded-xl bg-slate-100 border border-slate-200/80 overflow-hidden shrink-0 flex items-center justify-center">
                          {product.imageUrl ? (
                            <img 
                              src={product.imageUrl} 
                              alt={product.name} 
                              className="w-full h-full object-cover" 
                              onError={(e) => { e.target.style.display = 'none'; }}
                            />
                          ) : (
                            <Package className="w-5 h-5 text-slate-400" />
                          )}
                        </div>
                        <div>
                          <div className="font-bold text-slate-900 text-xs">{product.name}</div>
                          <div className="text-[11px] text-slate-400">
                            {product.farmOrigin || 'Farm Fresh'}
                          </div>
                        </div>
                      </div>
                    </td>

                    {/* Category */}
                    <td className="px-6 py-4">
                      <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-[11px] font-medium bg-slate-100 text-slate-700">
                        {product.categoryName || product.categoryId}
                      </span>
                    </td>

                    {/* Unit */}
                    <td className="px-6 py-4 text-xs font-semibold text-slate-700">
                      {product.unit || '1 kg'}
                    </td>

                    {/* Price */}
                    <td className="px-6 py-4">
                      <div className="font-bold text-slate-900 text-xs">
                        ₹{product.price}
                      </div>
                      {product.originalPrice && product.originalPrice > product.price && (
                        <div className="text-[10px] text-slate-400 line-through">
                          MRP ₹{product.originalPrice}
                        </div>
                      )}
                    </td>

                    {/* Stock Quick Toggle */}
                    <td className="px-6 py-4">
                      <button
                        onClick={() => productService.toggleStock(product.id, product.inStock !== false)}
                        className={`inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold transition-all ${
                          product.inStock !== false 
                            ? 'bg-emerald-50 text-emerald-700 border border-emerald-200 hover:bg-emerald-100' 
                            : 'bg-rose-50 text-rose-700 border border-rose-200 hover:bg-rose-100'
                        }`}
                        title="Click to toggle In-Stock / Out-of-Stock"
                      >
                        <span className={`w-1.5 h-1.5 rounded-full ${product.inStock !== false ? 'bg-emerald-500' : 'bg-rose-500'}`} />
                        <span>{product.inStock !== false ? 'In Stock' : 'Out of Stock'}</span>
                      </button>
                    </td>

                    {/* Popular Quick Toggle */}
                    <td className="px-6 py-4">
                      <button
                        onClick={() => productService.togglePopular(product.id, !!product.isPopular)}
                        className={`p-1.5 rounded-lg border transition-all ${
                          product.isPopular 
                            ? 'bg-amber-50 text-amber-600 border-amber-200 hover:bg-amber-100' 
                            : 'bg-slate-50 text-slate-300 border-slate-200 hover:text-slate-400'
                        }`}
                        title="Toggle Featured / Popular badge on home feed"
                      >
                        <Star className="w-4 h-4 fill-current" />
                      </button>
                    </td>

                    {/* Actions */}
                    <td className="px-6 py-4 text-right">
                      <div className="flex items-center justify-end gap-2">
                        <button
                          onClick={() => handleOpenEditModal(product)}
                          className="p-1.5 text-slate-500 hover:text-brand-600 hover:bg-brand-50 rounded-lg transition-colors"
                          title="Edit Product"
                        >
                          <Edit3 className="w-4 h-4" />
                        </button>
                        <button
                          onClick={() => handleDelete(product.id, product.name)}
                          className="p-1.5 text-slate-500 hover:text-rose-600 hover:bg-rose-50 rounded-lg transition-colors"
                          title="Delete Product"
                        >
                          <Trash2 className="w-4 h-4" />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Add / Edit Product Modal */}
      <Modal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        title={editingProduct ? 'Edit Product Item' : 'Add New Farm Produce'}
        subtitle="This will immediately sync to user phones via Firebase Firestore."
      >
        <form onSubmit={handleSubmit} className="space-y-4 text-xs">
          {/* Produce Name */}
          <div>
            <label className="block font-bold text-slate-700 mb-1">Product Title / Name *</label>
            <input
              type="text"
              required
              placeholder="e.g. Fresh Organic Spinach (Palak)"
              value={formData.name}
              onChange={(e) => setFormData({ ...formData, name: e.target.value })}
              className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-brand-500/20 focus:border-brand-500 font-medium"
            />
          </div>

          {/* Category & Unit */}
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block font-bold text-slate-700 mb-1">Category *</label>
              <select
                value={formData.categoryId}
                onChange={handleCategorySelect}
                className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-brand-500/20 font-medium bg-white"
              >
                {categories.map((cat) => (
                  <option key={cat.id} value={cat.id}>
                    {cat.name}
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label className="block font-bold text-slate-700 mb-1">Unit / Quantity *</label>
              <input
                type="text"
                required
                placeholder="e.g. 1 kg, 500 g, 1 Litre, 1 pc, 1 bunch"
                value={formData.unit}
                onChange={(e) => setFormData({ ...formData, unit: e.target.value })}
                className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-brand-500/20 font-medium"
              />
            </div>
          </div>

          {/* Selling Price & MRP */}
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block font-bold text-slate-700 mb-1">Selling Price (₹) *</label>
              <input
                type="number"
                step="0.01"
                required
                placeholder="e.g. 35"
                value={formData.price}
                onChange={(e) => setFormData({ ...formData, price: e.target.value })}
                className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-brand-500/20 font-medium"
              />
            </div>

            <div>
              <label className="block font-bold text-slate-700 mb-1">Original MRP Price (₹) (Optional)</label>
              <input
                type="number"
                step="0.01"
                placeholder="e.g. 45"
                value={formData.originalPrice}
                onChange={(e) => setFormData({ ...formData, originalPrice: e.target.value })}
                className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-brand-500/20 font-medium"
              />
            </div>
          </div>

          {/* Image URL & Preview */}
          <div>
            <label className="block font-bold text-slate-700 mb-1">Product Photo URL</label>
            <div className="flex gap-3">
              <input
                type="url"
                placeholder="https://images.unsplash.com/..."
                value={formData.imageUrl}
                onChange={(e) => setFormData({ ...formData, imageUrl: e.target.value })}
                className="flex-1 px-3.5 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-brand-500/20 font-medium"
              />
              {formData.imageUrl && (
                <div className="w-11 h-11 rounded-xl bg-slate-100 border border-slate-200 overflow-hidden shrink-0">
                  <img src={formData.imageUrl} alt="Preview" className="w-full h-full object-cover" />
                </div>
              )}
            </div>
          </div>

          {/* Farm Origin & Description */}
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block font-bold text-slate-700 mb-1">Farm Origin / Region</label>
              <input
                type="text"
                placeholder="e.g. Nashik Valley, Pune Farms"
                value={formData.farmOrigin}
                onChange={(e) => setFormData({ ...formData, farmOrigin: e.target.value })}
                className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-brand-500/20 font-medium"
              />
            </div>

            <div>
              <label className="block font-bold text-slate-700 mb-1">Short Freshness Details</label>
              <input
                type="text"
                placeholder="e.g. Harvested daily at 5 AM"
                value={formData.description}
                onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-brand-500/20 font-medium"
              />
            </div>
          </div>

          {/* Toggles */}
          <div className="flex items-center gap-6 pt-2">
            <label className="flex items-center gap-2 cursor-pointer">
              <input
                type="checkbox"
                checked={formData.inStock}
                onChange={(e) => setFormData({ ...formData, inStock: e.target.checked })}
                className="w-4 h-4 rounded text-brand-600 focus:ring-brand-500 border-slate-300"
              />
              <span className="font-semibold text-slate-800">In Stock (Available)</span>
            </label>

            <label className="flex items-center gap-2 cursor-pointer">
              <input
                type="checkbox"
                checked={formData.isPopular}
                onChange={(e) => setFormData({ ...formData, isPopular: e.target.checked })}
                className="w-4 h-4 rounded text-amber-600 focus:ring-amber-500 border-slate-300"
              />
              <span className="font-semibold text-slate-800">Feature as Popular Produce</span>
            </label>
          </div>

          {/* Buttons */}
          <div className="flex justify-end gap-3 pt-4 border-t border-slate-100">
            <button
              type="button"
              onClick={() => setIsModalOpen(false)}
              className="px-4 py-2.5 rounded-xl border border-slate-200 text-slate-600 font-bold hover:bg-slate-50 transition-colors"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={isSubmitting}
              className="px-6 py-2.5 rounded-xl bg-brand-600 hover:bg-brand-700 text-white font-bold shadow-md shadow-brand-600/20 transition-all flex items-center gap-2"
            >
              {isSubmitting ? 'Saving to Database...' : editingProduct ? 'Update Product' : 'Add to Catalog'}
            </button>
          </div>
        </form>
      </Modal>
    </div>
  );
}
