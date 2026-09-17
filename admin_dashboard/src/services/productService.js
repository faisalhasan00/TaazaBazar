import { 
  collection, 
  doc, 
  onSnapshot, 
  getDocs, 
  addDoc, 
  updateDoc, 
  deleteDoc, 
  serverTimestamp,
  query,
  orderBy
} from 'firebase/firestore';
import { db } from '../config/firebase';

const COLLECTION_NAME = 'products';

export const productService = {
  // Realtime subscription to products
  subscribeToProducts(callback) {
    const q = query(collection(db, COLLECTION_NAME));
    return onSnapshot(q, (snapshot) => {
      const products = snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
      callback(products);
    }, (error) => {
      console.error('Error fetching realtime products:', error);
      callback([]);
    });
  },

  // Add a new product
  async addProduct(productData) {
    const docRef = await addDoc(collection(db, COLLECTION_NAME), {
      ...productData,
      price: Number(productData.price) || 0,
      originalPrice: productData.originalPrice ? Number(productData.originalPrice) : null,
      rating: Number(productData.rating) || 4.8,
      reviewCount: Number(productData.reviewCount) || 12,
      discountPercent: productData.originalPrice && productData.price
        ? Math.round(((Number(productData.originalPrice) - Number(productData.price)) / Number(productData.originalPrice)) * 100)
        : 0,
      inStock: productData.inStock !== false,
      isPopular: !!productData.isPopular,
      tags: Array.isArray(productData.tags) ? productData.tags : [],
      createdAt: serverTimestamp(),
      updatedAt: serverTimestamp(),
    });
    return docRef.id;
  },

  // Update existing product
  async updateProduct(id, productData) {
    const docRef = doc(db, COLLECTION_NAME, id);
    const updatePayload = {
      ...productData,
      price: Number(productData.price) || 0,
      originalPrice: productData.originalPrice ? Number(productData.originalPrice) : null,
      inStock: productData.inStock !== false,
      isPopular: !!productData.isPopular,
      discountPercent: productData.originalPrice && productData.price
        ? Math.round(((Number(productData.originalPrice) - Number(productData.price)) / Number(productData.originalPrice)) * 100)
        : 0,
      updatedAt: serverTimestamp(),
    };
    await updateDoc(docRef, updatePayload);
  },

  // Quick toggle in-stock status
  async toggleStock(id, currentStatus) {
    const docRef = doc(db, COLLECTION_NAME, id);
    await updateDoc(docRef, {
      inStock: !currentStatus,
      updatedAt: serverTimestamp(),
    });
  },

  // Quick toggle popular badge
  async togglePopular(id, currentStatus) {
    const docRef = doc(db, COLLECTION_NAME, id);
    await updateDoc(docRef, {
      isPopular: !currentStatus,
      updatedAt: serverTimestamp(),
    });
  },

  // Delete product
  async deleteProduct(id) {
    const docRef = doc(db, COLLECTION_NAME, id);
    await deleteDoc(docRef);
  },

  // Seed default items if collection is empty
  async seedInitialProducts(categories) {
    const snapshot = await getDocs(collection(db, COLLECTION_NAME));
    if (!snapshot.empty) return false;

    const initial = [
      {
        name: 'Fresh Farm Spinach (Palak)',
        categoryId: 'vegetables',
        categoryName: 'Vegetables',
        price: 25,
        originalPrice: 35,
        unit: '250 g',
        imageUrl: 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=500&q=80',
        inStock: true,
        isPopular: true,
        rating: 4.9,
        reviewCount: 42,
        farmOrigin: 'Nashik Organic Valley',
        description: 'Crisp, pesticide-free green leaves packed with iron and vitamins. Harvested fresh every morning.'
      },
      {
        name: 'Organic Red Tomatoes',
        categoryId: 'vegetables',
        categoryName: 'Vegetables',
        price: 32,
        originalPrice: 45,
        unit: '1 kg',
        imageUrl: 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500&q=80',
        inStock: true,
        isPopular: true,
        rating: 4.8,
        reviewCount: 88,
        farmOrigin: 'Pune Fresh Farms',
        description: 'Vine-ripened, juicy red tomatoes perfect for gravies, salads, and curries.'
      },
      {
        name: 'Pure Desi Cow Milk (A2)',
        categoryId: 'dairy',
        categoryName: 'Milk & Dairy',
        price: 75,
        originalPrice: 85,
        unit: '1 Litre',
        imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=500&q=80',
        inStock: true,
        isPopular: true,
        rating: 5.0,
        reviewCount: 156,
        farmOrigin: 'Vedic Cow Gaushala',
        description: 'Raw, unadulterated Gir Cow A2 milk chilled within 1 hour of milking.'
      },
      {
        name: 'Shimla Royal Delicious Apples',
        categoryId: 'fruits',
        categoryName: 'Fresh Fruits',
        price: 180,
        originalPrice: 220,
        unit: '1 kg (4-5 pcs)',
        imageUrl: 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=500&q=80',
        inStock: true,
        isPopular: true,
        rating: 4.9,
        reviewCount: 65,
        farmOrigin: 'Himachal Orchards',
        description: 'Crisp, aromatic, natural sweet mountain apples rich in fiber and antioxidants.'
      },
      {
        name: 'Farm Fresh Paneer (Cottage Cheese)',
        categoryId: 'dairy',
        categoryName: 'Milk & Dairy',
        price: 95,
        originalPrice: 110,
        unit: '200 g',
        imageUrl: 'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=500&q=80',
        inStock: true,
        isPopular: false,
        rating: 4.8,
        reviewCount: 34,
        farmOrigin: 'Taaza Dairy Center',
        description: 'Melt-in-the-mouth soft and fresh malai paneer made from pure whole milk.'
      }
    ];

    for (const item of initial) {
      await this.addProduct(item);
    }
    return true;
  }
};
