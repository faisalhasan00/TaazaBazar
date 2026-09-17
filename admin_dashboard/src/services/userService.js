import { 
  collection, 
  collectionGroup,
  doc, 
  onSnapshot, 
  getDocs,
  query,
  orderBy
} from 'firebase/firestore';
import { db } from '../config/firebase';

export const userService = {
  // Realtime subscription to registered users/members
  subscribeToMembers(callback) {
    const membersMap = new Map();

    const updateAndEmit = () => {
      const members = Array.from(membersMap.values());
      // Sort newest first
      members.sort((a, b) => (b.rawTimestamp || 0) - (a.rawTimestamp || 0));
      callback(members);
    };

    // 1. Listen to 'phone_users' collection
    const unsubPhoneUsers = onSnapshot(collection(db, 'phone_users'), (snapshot) => {
      snapshot.docs.forEach((docSnap) => {
        const data = docSnap.data();
        const phone = data.phone || docSnap.id;
        const key = phone.replace(/\D/g, '');

        let joinedDate = 'Recently';
        let rawTimestamp = Date.now();

        if (data.createdAt?.toDate) {
          joinedDate = data.createdAt.toDate().toLocaleDateString('en-IN', {
            day: 'numeric',
            month: 'short',
            year: 'numeric'
          });
          rawTimestamp = data.createdAt.toDate().getTime();
        }

        membersMap.set(key, {
          id: docSnap.id,
          uid: data.uid || docSnap.id,
          name: data.name || 'Member',
          phone: data.phone || docSnap.id,
          email: data.email || '',
          joinedDate,
          rawTimestamp,
          subscriptions: [],
          orderCount: 0,
          totalSpent: 0,
          ...(membersMap.get(key) || {})
        });
      });
      updateAndEmit();
    }, (err) => console.warn('phone_users stream notice:', err));

    // 2. Listen to 'users' collection or profile subcollections
    const unsubUsers = onSnapshot(collection(db, 'users'), (snapshot) => {
      snapshot.docs.forEach((docSnap) => {
        const data = docSnap.data();
        const uid = docSnap.id;
        const phone = data.phone || data.phoneNumber || '';
        const key = phone ? phone.replace(/\D/g, '') : uid;

        let joinedDate = 'Recently';
        let rawTimestamp = Date.now();
        if (data.createdAt?.toDate) {
          joinedDate = data.createdAt.toDate().toLocaleDateString('en-IN', {
            day: 'numeric',
            month: 'short',
            year: 'numeric'
          });
          rawTimestamp = data.createdAt.toDate().getTime();
        }

        const existing = membersMap.get(key) || {};
        membersMap.set(key, {
          id: uid,
          uid: uid,
          name: data.name || data.displayName || existing.name || 'Customer',
          phone: phone || existing.phone || 'App User',
          email: data.email || existing.email || '',
          joinedDate: existing.joinedDate || joinedDate,
          rawTimestamp: existing.rawTimestamp || rawTimestamp,
          subscriptions: existing.subscriptions || [],
          orderCount: existing.orderCount || 0,
          totalSpent: existing.totalSpent || 0,
          ...existing,
        });
      });
      updateAndEmit();
    }, (err) => console.warn('users stream notice:', err));

    // 3. Listen to top-level and subcollection subscriptions to map them to members
    const subsMap = new Map();
    const processSubscriptions = () => {
      const subs = Array.from(subsMap.values());
      membersMap.forEach((member, key) => {
        const userSubs = subs.filter(s => 
          (s.userId && (s.userId === member.uid || s.userId === member.id)) ||
          (s.phone && s.phone.replace(/\D/g, '') === key) ||
          (s.customerPhone && s.customerPhone.replace(/\D/g, '') === key)
        );
        member.subscriptions = userSubs;
        const hasActiveSub = userSubs.some(s => !s.status || String(s.status).toLowerCase() === 'active');
        member.isPassMember = hasActiveSub;
      });
      updateAndEmit();
    };

    const unsubTopSubs = onSnapshot(collection(db, 'subscriptions'), (snapshot) => {
      snapshot.docs.forEach(d => subsMap.set(d.id, { id: d.id, ...d.data() }));
      processSubscriptions();
    }, () => {});

    let unsubGroupSubs = () => {};
    try {
      unsubGroupSubs = onSnapshot(collectionGroup(db, 'subscriptions'), (snapshot) => {
        snapshot.docs.forEach(d => subsMap.set(d.id, { id: d.id, ...d.data() }));
        processSubscriptions();
      }, () => {});
    } catch (_) {}

    // 4. Listen to orders to compute order count and total spent per member
    const unsubOrders = onSnapshot(collection(db, 'orders'), (snapshot) => {
      const orders = snapshot.docs.map(d => ({ id: d.id, ...d.data() }));
      
      membersMap.forEach((member, key) => {
        const userOrders = orders.filter(o => 
          (o.userId && (o.userId === member.uid || o.userId === member.id)) ||
          (o.phone && o.phone.replace(/\D/g, '') === key) ||
          (o.customerPhone && o.customerPhone.replace(/\D/g, '') === key)
        );
        member.orderCount = userOrders.length;
        member.totalSpent = userOrders.reduce((sum, o) => {
          if (o.status !== 'cancelled') {
            return sum + (Number(o.totalAmount) || Number(o.grandTotal) || 0);
          }
          return sum;
        }, 0);
      });
      updateAndEmit();
    }, () => {});

    return () => {
      unsubPhoneUsers();
      unsubUsers();
      unsubTopSubs();
      unsubGroupSubs();
      unsubOrders();
    };
  }
};
