import { 
  collection, 
  doc, 
  onSnapshot, 
  getDocs, 
  addDoc, 
  updateDoc, 
  deleteDoc, 
  serverTimestamp 
} from 'firebase/firestore';
import { db } from '../config/firebase';

const BANNER_COLLECTION = 'banners';
const COUPON_COLLECTION = 'coupons';
const SUBSCRIPTION_COLLECTION = 'subscriptions';

export const bannerService = {
  subscribeToBanners(callback) {
    return onSnapshot(collection(db, BANNER_COLLECTION), (snapshot) => {
      callback(snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() })));
    }, () => callback([]));
  },

  async addBanner(data) {
    return await addDoc(collection(db, BANNER_COLLECTION), {
      ...data,
      isActive: data.isActive !== false,
      createdAt: serverTimestamp()
    });
  },

  async updateBanner(id, data) {
    await updateDoc(doc(db, BANNER_COLLECTION, id), {
      ...data,
      updatedAt: serverTimestamp()
    });
  },

  async deleteBanner(id) {
    await deleteDoc(doc(db, BANNER_COLLECTION, id));
  }
};

export const couponService = {
  subscribeToCoupons(callback) {
    return onSnapshot(collection(db, COUPON_COLLECTION), (snapshot) => {
      callback(snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() })));
    }, () => callback([]));
  },

  async addCoupon(data) {
    return await addDoc(collection(db, COUPON_COLLECTION), {
      ...data,
      code: data.code.toUpperCase().trim(),
      discountAmount: Number(data.discountAmount) || 0,
      minOrder: Number(data.minOrder) || 0,
      isActive: data.isActive !== false,
      createdAt: serverTimestamp()
    });
  },

  async updateCoupon(id, data) {
    await updateDoc(doc(db, COUPON_COLLECTION, id), {
      ...data,
      code: data.code.toUpperCase().trim(),
      discountAmount: Number(data.discountAmount) || 0,
      minOrder: Number(data.minOrder) || 0,
      updatedAt: serverTimestamp()
    });
  },

  async deleteCoupon(id) {
    await deleteDoc(doc(db, COUPON_COLLECTION, id));
  }
};

export const subscriptionService = {
  subscribeToSubscriptions(callback) {
    return onSnapshot(collection(db, SUBSCRIPTION_COLLECTION), (snapshot) => {
      callback(snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() })));
    }, () => callback([]));
  },

  async updateStatus(id, status) {
    await updateDoc(doc(db, SUBSCRIPTION_COLLECTION, id), {
      status,
      updatedAt: serverTimestamp()
    });
  }
};
