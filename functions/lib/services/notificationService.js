"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendCustomerNotification = sendCustomerNotification;
exports.notifyOrderPlaced = notifyOrderPlaced;
exports.notifyPaymentSuccess = notifyPaymentSuccess;
exports.notifyPaymentFailed = notifyPaymentFailed;
exports.notifyOrderCancelled = notifyOrderCancelled;
exports.notifyRefundProcessed = notifyRefundProcessed;
const admin = __importStar(require("firebase-admin"));
/**
 * Sends a push notification to all active devices of a customer and records
 * a trusted notification history entry in Firestore.
 */
async function sendCustomerNotification(payload) {
    const { uid, title, body, type, orderId, data } = payload;
    const db = admin.firestore();
    let historyId;
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
    }
    catch (err) {
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
    const tokensWithDocId = [];
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
    const message = {
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
        console.log(`Push notification sent to user ${uid}: ${response.successCount} succeeded, ${response.failureCount} failed.`);
        // 4. Cleanup stale / invalid tokens
        if (response.failureCount > 0) {
            const batch = db.batch();
            response.responses.forEach((resp, idx) => {
                if (!resp.success && resp.error) {
                    const errorCode = resp.error.code;
                    if (errorCode === 'messaging/registration-token-not-registered' ||
                        errorCode === 'messaging/invalid-registration-token') {
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
    }
    catch (sendError) {
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
async function notifyOrderPlaced(uid, orderId, grandTotal) {
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
async function notifyPaymentSuccess(uid, orderId, amount) {
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
async function notifyPaymentFailed(uid, orderId, reason) {
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
async function notifyOrderCancelled(uid, orderId, refundInitiated, refundAmount) {
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
async function notifyRefundProcessed(uid, orderId, refundId, refundAmount) {
    return sendCustomerNotification({
        uid,
        title: 'Refund Issued! 💰',
        body: `Refund of ₹${refundAmount.toFixed(0)} for order ${orderId} (Ref: ${refundId}) has been processed successfully.`,
        type: 'refund_processed',
        orderId,
    });
}
//# sourceMappingURL=notificationService.js.map