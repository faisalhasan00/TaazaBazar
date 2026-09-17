import * as admin from 'firebase-admin';

export interface CustomerNotificationPayload {
  uid: string;
  title: string;
  body: string;
  type: string;
  orderId?: string;
  data?: Record<string, string>;
}

export interface NotificationSendResult {
  success: boolean;
  tokensCount: number;
  successCount: number;
  failureCount: number;
  historyId?: string;
}

/**
 * Sends a push notification to all active devices of a customer and records
 * a trusted notification history entry in Firestore.
 */
export async function sendCustomerNotification(
  payload: CustomerNotificationPayload
): Promise<NotificationSendResult> {
  const { uid, title, body, type, orderId, data } = payload;
  const db = admin.firestore();

  let historyId: string | undefined;

  // 1. Record trusted server notification history item
  try {
    const historyRef = db.collection('users').doc(uid).collection('notifications').doc();
    historyId = historyRef.id;
    await historyRef.set({
      title,
      body,
      type,
      orderId: orderId || null,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      read: false,
      data: data || {},
    });
  } catch (err) {
    console.error(`Failed to write notification history for user ${uid}:`, err);
  }

  // 2. Fetch enabled device tokens
  const devicesSnap = await db
    .collection('users')
    .doc(uid)
    .collection('devices')
    .where('enabled', '==', true)
    .get();

  if (devicesSnap.empty) {
    console.log(`No active push notification devices found for user ${uid}`);
    return {
      success: true,
      tokensCount: 0,
      successCount: 0,
      failureCount: 0,
      historyId,
    };
  }

  const tokensWithDocId: { docId: string; token: string }[] = [];
  devicesSnap.forEach((doc) => {
    const token = doc.data().token;
    if (token && typeof token === 'string') {
      tokensWithDocId.push({ docId: doc.id, token });
    }
  });

  if (tokensWithDocId.length === 0) {
    return {
      success: true,
      tokensCount: 0,
      successCount: 0,
      failureCount: 0,
      historyId,
    };
  }

  const registrationTokens = tokensWithDocId.map((t) => t.token);

  // 3. Construct multicast message
  const message: admin.messaging.MulticastMessage = {
    tokens: registrationTokens,
    notification: {
      title,
      body,
    },
    data: {
      type,
      ...(orderId ? { orderId } : {}),
      ...(data || {}),
      click_action: 'FLUTTER_NOTIFICATION_CLICK',
    },
    android: {
      priority: 'high',
      notification: {
        channelId: 'taazabazar_orders',
        color: '#166534',
        sound: 'default',
      },
    },
  };

  try {
    const response = await admin.messaging().sendEachForMulticast(message);
    console.log(
      `Push notification sent to user ${uid}: ${response.successCount} succeeded, ${response.failureCount} failed.`
    );

    // 4. Cleanup stale / invalid tokens
    if (response.failureCount > 0) {
      const batch = db.batch();
      response.responses.forEach((resp, idx) => {
        if (!resp.success && resp.error) {
          const errorCode = resp.error.code;
          if (
            errorCode === 'messaging/registration-token-not-registered' ||
            errorCode === 'messaging/invalid-registration-token'
          ) {
            const staleDocId = tokensWithDocId[idx].docId;
            const staleRef = db
              .collection('users')
              .doc(uid)
              .collection('devices')
              .doc(staleDocId);
            batch.update(staleRef, {
              enabled: false,
              disabledReason: errorCode,
              disabledAt: admin.firestore.FieldValue.serverTimestamp(),
            });
          }
        }
      });
      await batch.commit();
    }

    return {
      success: true,
      tokensCount: registrationTokens.length,
      successCount: response.successCount,
      failureCount: response.failureCount,
      historyId,
    };
  } catch (sendError) {
    console.error(`FCM multicast dispatch failed for user ${uid}:`, sendError);
    return {
      success: false,
      tokensCount: registrationTokens.length,
      successCount: 0,
      failureCount: registrationTokens.length,
      historyId,
    };
  }
}

/**
 * Triggered upon successful order placement
 */
export async function notifyOrderPlaced(
  uid: string,
  orderId: string,
  grandTotal: number
): Promise<NotificationSendResult> {
  return sendCustomerNotification({
    uid,
    title: 'Order Confirmed! 🥦',
    body: `Your TaazaBazar order ${orderId} (₹${grandTotal.toFixed(0)}) has been confirmed & sent to farm harvest.`,
    type: 'order_placed',
    orderId,
  });
}

/**
 * Triggered upon verified online payment success
 */
export async function notifyPaymentSuccess(
  uid: string,
  orderId: string,
  amount: number
): Promise<NotificationSendResult> {
  return sendCustomerNotification({
    uid,
    title: 'Payment Successful! ⚡',
    body: `Payment of ₹${amount.toFixed(0)} for order ${orderId} has been verified and processed successfully.`,
    type: 'payment_success',
    orderId,
  });
}

/**
 * Triggered upon online payment failure
 */
export async function notifyPaymentFailed(
  uid: string,
  orderId: string,
  reason?: string
): Promise<NotificationSendResult> {
  return sendCustomerNotification({
    uid,
    title: 'Payment Issue ⚠️',
    body: `Payment for order ${orderId} could not be completed${reason ? `: ${reason}` : '. Please retry checkout.'}`,
    type: 'payment_failed',
    orderId,
  });
}

/**
 * Triggered upon order cancellation
 */
export async function notifyOrderCancelled(
  uid: string,
  orderId: string,
  refundInitiated: boolean,
  refundAmount?: number
): Promise<NotificationSendResult> {
  const body = refundInitiated && refundAmount
    ? `Order ${orderId} was cancelled. A refund of ₹${refundAmount.toFixed(0)} has been initiated to your original payment method.`
    : `Order ${orderId} has been cancelled successfully.`;

  return sendCustomerNotification({
    uid,
    title: 'Order Cancelled',
    body,
    type: 'order_cancelled',
    orderId,
  });
}

/**
 * Triggered upon refund completion
 */
export async function notifyRefundProcessed(
  uid: string,
  orderId: string,
  refundId: string,
  refundAmount: number
): Promise<NotificationSendResult> {
  return sendCustomerNotification({
    uid,
    title: 'Refund Issued! 💰',
    body: `Refund of ₹${refundAmount.toFixed(0)} for order ${orderId} (Ref: ${refundId}) has been processed successfully.`,
    type: 'refund_processed',
    orderId,
  });
}
