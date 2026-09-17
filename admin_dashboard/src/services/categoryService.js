import { 
  collection, 
  doc, 
  onSnapshot, 
  getDocs, 
  setDoc,
  updateDoc, 
  deleteDoc, 
  serverTimestamp 
} from 'firebase/firestore';
import { db } from '../config/firebase';

const COLLECTION_NAME = 'categories';

export const categoryService = {
  subscribeToCategories(callback) {
    return onSnapshot(collection(db, COLLECTION_NAME), (snapshot) => {
      const list = snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
      callback(list);
    }, (error) => {
      console.error('Error fetching categories:', error);
      callback([]);
    });
  },

  async saveCategory(id, data) {
    const docId = id || data.name.toLowerCase().replace(/[^a-z0-9]/g, '_');
    const docRef = doc(db, COLLECTION_NAME, docId);
    await setDoc(docRef, {
      ...data,
      id: docId,
      itemCount: Number(data.itemCount) || 0,
      sortOrder: Number(data.sortOrder) || 1,
      updatedAt: serverTimestamp(),
    }, { merge: true });
    return docId;
  },

  async deleteCategory(id) {
    await deleteDoc(doc(db, COLLECTION_NAME, id));
  },

  async seedDefaultCategories() {
    const snapshot = await getDocs(collection(db, COLLECTION_NAME));
    if (!snapshot.empty) return false;

    const defaults = [
      { id: 'vegetables', name: 'Vegetables', icon: '🥦', itemCount: 18, sortOrder: 1, color: '#22c55e' },
      { id: 'fruits', name: 'Fresh Fruits', icon: '🍎', itemCount: 12, sortOrder: 2, color: '#ef4444' },
      { id: 'dairy', name: 'Milk & Dairy', icon: '🥛', itemCount: 9, sortOrder: 3, color: '#3b82f6' },
      { id: 'staples', name: 'Atta, Rice & Dal', icon: '🌾', itemCount: 15, sortOrder: 4, color: '#f59e0b' },
      { id: 'organic', name: 'Hydroponic & Organic', icon: '🌿', itemCount: 8, sortOrder: 5, color: '#10b981' },
      { id: 'bakery', name: 'Bakery & Eggs', icon: '🍞', itemCount: 6, sortOrder: 6, color: '#d97706' },
    ];

    for (const cat of defaults) {
      await this.saveCategory(cat.id, cat);
    }
    return true;
  }
};
