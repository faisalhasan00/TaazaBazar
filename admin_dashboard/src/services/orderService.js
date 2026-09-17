import { 
  collection, 
  collectionGroup,
  doc, 
  onSnapshot, 
  updateDoc, 
  setDoc,
  serverTimestamp,
  query,
  getDoc
} from 'firebase/firestore';
import { db } from '../config/firebase';

const COLLECTION_NAME = 'orders';

export const orderService = {
  // Realtime subscription to live orders (combines top-level orders and user orders)
  subscribeToOrders(callback) {
    // Map to hold unique orders by ID
    const ordersMap = new Map();

    const updateAndEmit = () => {
      const orders = Array.from(ordersMap.values());
      // Sort newest first
      orders.sort((a, b) => {
        const timeA = a.rawTimestamp || 0;
        const timeB = b.rawTimestamp || 0;
        return timeB - timeA;
      });
      callback(orders);
    };

    const processDoc = (docSnap) => {
      const data = docSnap.data();
      const id = docSnap.id;
      
      // Extract clean timestamp
      let dateFormatted = new Date().toLocaleString('en-IN');
      let rawTimestamp = Date.now();

      if (data.createdAt?.toDate) {
        dateFormatted = data.createdAt.toDate().toLocaleString('en-IN');
        rawTimestamp = data.createdAt.toDate().getTime();
      } else if (data.orderDate) {
        const parsed = new Date(data.orderDate);
        if (!isNaN(parsed.getTime())) {
          dateFormatted = parsed.toLocaleString('en-IN');
          rawTimestamp = parsed.getTime();
        }
      }

      // Normalize status
      let status = (data.status || 'placed').toLowerCase();
      if (status === 'outfordelivery') status = 'out_for_delivery';
      if (status === 'preparing') status = 'packed';

      // Parse items safely so product names and quantities are never undefined
      let items = data.items || [];
      if (Array.isArray(items)) {
        items = items.map(item => ({
          ...item,
          name: item.name || item.product?.name || item.productName || item.title || 'Fresh Produce Item',
          quantity: Number(item.quantity) || 1,
          price: Number(item.price || item.product?.price) || 0,
        }));
      }

      // Extract customer name & phone
      let customerName = data.customerName || data.userName || data.name || '';
      let customerPhone = data.customerPhone || data.phone || data.userPhone || '';

      if (!customerName || customerName === 'Customer') {
        if (customerPhone) {
          customerName = `Customer (${customerPhone})`;
        } else {
          customerName = 'Store Customer';
        }
      }

      return {
        id: data.orderId || id,
        docId: id,
        path: docSnap.ref.path,
        userId: data.userId || '',
        ...data,
        items,
        status,
        totalAmount: Number(data.totalAmount) || Number(data.grandTotal) || 0,
        subtotal: Number(data.subtotal) || Number(data.itemTotal) || 0,
        deliveryFee: Number(data.deliveryFee) || 0,
        discount: Number(data.discount) || Number(data.couponDiscount) || 0,
        customerName,
        customerPhone,
        createdAtFormatted: dateFormatted,
        rawTimestamp,
      };
    };

    // User metadata cache for cross-referencing order customer details
    const usersMap = new Map();

    const enrichOrdersWithUsers = () => {
      ordersMap.forEach((order) => {
        const uid = order.userId;
        const phone = order.customerPhone || order.phone;
        const cleanPhone = phone ? phone.replace(/\D/g, '') : '';

        const matchedUser = usersMap.get(uid) || (cleanPhone ? usersMap.get(cleanPhone) : null);
        if (matchedUser) {
          if (!order.customerName || order.customerName === 'Store Customer' || order.customerName.startsWith('Customer (')) {
            order.customerName = matchedUser.name || order.customerName;
          }
          if (!order.customerPhone || order.customerPhone === '-') {
            order.customerPhone = matchedUser.phone || order.customerPhone;
          }
        }
      });
      updateAndEmit();
    };

    // 1. Listen to 'users' collection to resolve customer profiles
    const unsubUsers = onSnapshot(collection(db, 'users'), (snapshot) => {
      snapshot.docs.forEach((d) => {
        const data = d.data();
        const phoneKey = (data.phone || data.phoneNumber || '').replace(/\D/g, '');
        const info = { name: data.name || data.displayName, phone: data.phone || data.phoneNumber };
        usersMap.set(d.id, info);
        if (phoneKey) usersMap.set(phoneKey, info);
      });
      enrichOrdersWithUsers();
    }, () => {});

    // 2. Listen to 'phone_users' collection to resolve customer profiles
    const unsubPhoneUsers = onSnapshot(collection(db, 'phone_users'), (snapshot) => {
      snapshot.docs.forEach((d) => {
        const data = d.data();
        const phoneKey = (data.phone || d.id).replace(/\D/g, '');
        const info = { name: data.name, phone: data.phone || d.id };
        usersMap.set(d.id, info);
        if (data.uid) usersMap.set(data.uid, info);
        if (phoneKey) usersMap.set(phoneKey, info);
      });
      enrichOrdersWithUsers();
    }, () => {});

    // 3. Listen to top-level orders
    const unsubTop = onSnapshot(collection(db, COLLECTION_NAME), (snapshot) => {
      snapshot.docs.forEach((docSnap) => {
        const parsed = processDoc(docSnap);
        ordersMap.set(parsed.id, parsed);
      });
      enrichOrdersWithUsers();
    }, (error) => {
      console.warn('Top-level orders stream notice:', error);
    });

    // 2. Listen to collectionGroup('orders') for subcollection orders
    let unsubGroup = () => {};
    try {
      unsubGroup = onSnapshot(collectionGroup(db, 'orders'), (snapshot) => {
        snapshot.docs.forEach((docSnap) => {
          const parsed = processDoc(docSnap);
          // If not already present or more recent
          ordersMap.set(parsed.id, {
            ...(ordersMap.get(parsed.id) || {}),
            ...parsed
          });
        });
        updateAndEmit();
      }, (error) => {
        console.warn('CollectionGroup orders notice:', error);
      });
    } catch (e) {
      console.warn('CollectionGroup initialization notice:', e);
    }

    return () => {
      unsubUsers();
      unsubPhoneUsers();
      unsubTop();
      unsubGroup();
    };
  },

  // Update order status and sync across both top-level and user subcollection
  async updateOrderStatus(orderId, newStatus, trackingNotes = '') {
    const cleanId = orderId.replace('#', '');
    
    // Normalize status to Flutter app standard
    let flutterStatus = newStatus;
    if (newStatus === 'packed') flutterStatus = 'preparing';
    if (newStatus === 'out_for_delivery') flutterStatus = 'outForDelivery';

    const updatePayload = {
      status: newStatus,
      statusTitle: newStatus.replace(/_/g, ' ').toUpperCase(),
      statusUpdatedAt: serverTimestamp(),
      ...(trackingNotes ? { trackingNotes } : {})
    };

    // 1. Update top-level collection 'orders/{cleanId}'
    try {
      const topRef = doc(db, COLLECTION_NAME, cleanId);
      await setDoc(topRef, updatePayload, { merge: true });
    } catch (e) {
      console.error('Error updating top-level order doc:', e);
    }

    // 2. Update user subcollection if order has userId
    try {
      const topSnap = await getDoc(doc(db, COLLECTION_NAME, cleanId));
      if (topSnap.exists() && topSnap.data().userId) {
        const userUid = topSnap.data().userId;
        const userOrderRef = doc(db, 'users', userUid, 'orders', cleanId);
        await setDoc(userOrderRef, updatePayload, { merge: true });
      }
    } catch (e) {
      console.warn('Notice updating user order doc:', e);
    }
  },

  // Assign delivery partner
  async assignDelivery(orderId, partnerInfo) {
    const cleanId = orderId.replace('#', '');
    const docRef = doc(db, COLLECTION_NAME, cleanId);
    await updateDoc(docRef, {
      deliveryPartner: partnerInfo,
      status: 'out_for_delivery',
      dispatchedAt: serverTimestamp()
    });
  }
};
