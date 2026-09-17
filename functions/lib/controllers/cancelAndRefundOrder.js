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
exports.cancelAndRefundOrder = void 0;
const https_1 = require("firebase-functions/v2/https");
const logger = __importStar(require("firebase-functions/logger"));
const firebase_1 = require("../config/firebase");
const razorpay_1 = require("../config/razorpay");
const secrets_1 = require("../config/secrets");
const notificationService_1 = require("../services/notificationService");
exports.cancelAndRefundOrder = (0, https_1.onCall)({
    region: 'asia-south1',
    secrets: [secrets_1.razorpayKeyIdSecret, secrets_1.razorpayKeySecretSecret],
}, async (request) => {
    // 1. Authenticated user validation
    if (!request.auth || !request.auth.uid) {
        throw new https_1.HttpsError('unauthenticated', 'User must be logged in to cancel an order.');
    }
    const userId = request.auth.uid;
    const data = request.data;
    if (!data || !data.orderId) {
        throw new https_1.HttpsError('invalid-argument', 'Missing required parameter: orderId.');
    }
    const cleanOrderId = data.orderId.replace('#', '').trim();
    logger.info('cancelAndRefundOrder initiated', {
        userId,
        orderId: cleanOrderId,
        reason: data.reason,
    });
    try {
        // 2. Fetch order document & verify ownership
        const orderRef = firebase_1.db
            .collection('users')
            .doc(userId)
            .collection('orders')
            .doc(cleanOrderId);
        const orderDoc = await orderRef.get();
        if (!orderDoc.exists) {
            throw new https_1.HttpsError('not-found', 'Order not found in customer records.');
        }
        const orderData = orderDoc.data();
        if (!orderData) {
            throw new https_1.HttpsError('not-found', 'Order data is empty.');
        }
        // 3. Idempotency check: If already cancelled
        if (orderData.status === 'cancelled') {
            logger.info('Order is already cancelled (idempotent)', {
                orderId: cleanOrderId,
                refundStatus: orderData.refundStatus,
            });
            return {
                success: true,
                message: 'Order is already cancelled.',
                orderId: `#${cleanOrderId}`,
                status: 'cancelled',
                paymentStatus: orderData.paymentStatus,
                refundStatus: orderData.refundStatus || null,
                refundId: orderData.refundId || null,
            };
        }
        // 4. Safe cancellation state policy: Only allow cancellation in 'placed' status
        if (orderData.status !== 'placed') {
            logger.warn('Cancellation rejected due to order lifecycle stage', {
                orderId: cleanOrderId,
                currentStatus: orderData.status,
            });
            throw new https_1.HttpsError('failed-precondition', `Cannot cancel order in '${orderData.statusTitle || orderData.status}' stage. Orders can only be cancelled while in 'Order Placed' status before harvesting starts.`);
        }
        const nowIso = new Date().toISOString();
        const cancellationReason = data.reason || 'Cancelled by customer';
        // 5. COD Order Cancellation (No Razorpay refund)
        const isCod = orderData.paymentGateway === 'cod' ||
            orderData.paymentMethod === 'cashOnDelivery' ||
            orderData.paymentMethod === 'cod';
        if (isCod) {
            await orderRef.update({
                status: 'cancelled',
                statusTitle: 'Cancelled',
                paymentStatus: 'cancelled',
                paymentStatusTitle: 'Cancelled',
                cancelledAt: nowIso,
                cancellationReason: cancellationReason,
                isCompleted: true,
                updatedAt: nowIso,
            });
            logger.info('COD order cancelled successfully', {
                userId,
                orderId: cleanOrderId,
            });
            // Send push notification asynchronously
            (0, notificationService_1.notifyOrderCancelled)(userId, `#${cleanOrderId}`, false).catch((err) => logger.warn('Failed to dispatch COD cancellation notification', { userId, err }));
            return {
                success: true,
                message: 'Your COD order has been cancelled.',
                orderId: `#${cleanOrderId}`,
                status: 'cancelled',
                paymentStatus: 'cancelled',
                refundStatus: null,
                cancelledAt: nowIso,
            };
        }
        // 6. Online / Razorpay Order Cancellation
        // If payment was not completed/verified yet (pending/failed), cancel without refund
        if (orderData.paymentStatus !== 'paid') {
            await orderRef.update({
                status: 'cancelled',
                statusTitle: 'Cancelled',
                paymentStatus: 'cancelled',
                paymentStatusTitle: 'Cancelled',
                cancelledAt: nowIso,
                cancellationReason: cancellationReason,
                isCompleted: true,
                updatedAt: nowIso,
            });
            logger.info('Unpaid online order cancelled successfully', {
                userId,
                orderId: cleanOrderId,
            });
            // Send push notification asynchronously
            (0, notificationService_1.notifyOrderCancelled)(userId, `#${cleanOrderId}`, false).catch((err) => logger.warn('Failed to dispatch unpaid order cancellation notification', { userId, err }));
            return {
                success: true,
                message: 'Order cancelled successfully.',
                orderId: `#${cleanOrderId}`,
                status: 'cancelled',
                paymentStatus: 'cancelled',
                refundStatus: null,
                cancelledAt: nowIso,
            };
        }
        // 7. Paid Razorpay Order Refund Lifecycle
        const gatewayPaymentId = orderData.gatewayPaymentId;
        if (!gatewayPaymentId) {
            throw new https_1.HttpsError('failed-precondition', 'Cannot process refund: No gateway payment ID recorded for this order.');
        }
        const grandTotal = Number(orderData.grandTotal) || 0;
        const amountInPaise = Math.round(grandTotal * 100);
        if (amountInPaise <= 0) {
            throw new https_1.HttpsError('invalid-argument', 'Invalid payable order amount for refund.');
        }
        logger.info('Initiating Razorpay refund', {
            userId,
            orderId: cleanOrderId,
            gatewayPaymentId,
            amountInPaise,
        });
        const razorpay = (0, razorpay_1.getRazorpayClient)();
        let refundResponse;
        try {
            refundResponse = await razorpay.payments.refund(gatewayPaymentId, {
                amount: amountInPaise,
                notes: {
                    orderId: cleanOrderId,
                    userId: userId,
                    reason: cancellationReason,
                },
            });
        }
        catch (refundError) {
            logger.error('Razorpay refund API call failed', {
                userId,
                orderId: cleanOrderId,
                gatewayPaymentId,
                error: refundError?.message || refundError,
            });
            await orderRef.update({
                status: 'cancelled',
                statusTitle: 'Cancelled',
                refundStatus: 'failed',
                refundFailureReason: refundError?.error?.description ||
                    refundError?.message ||
                    'Refund gateway communication error',
                cancelledAt: nowIso,
                cancellationReason: cancellationReason,
                updatedAt: nowIso,
            });
            throw new https_1.HttpsError('internal', 'Order was cancelled, but the refund gateway encountered an issue. Our support team will verify and process your refund.');
        }
        // 8. Update Firestore record to refunded state
        const isProcessed = refundResponse.status === 'processed';
        const finalRefundStatus = isProcessed ? 'refunded' : 'pending';
        await orderRef.update({
            status: 'cancelled',
            statusTitle: 'Cancelled',
            paymentStatus: finalRefundStatus === 'refunded' ? 'refunded' : 'paid',
            paymentStatusTitle: finalRefundStatus === 'refunded' ? 'Refunded' : 'Paid',
            refundStatus: finalRefundStatus,
            refundId: refundResponse.id,
            refundAmount: grandTotal,
            refundedAt: nowIso,
            cancelledAt: nowIso,
            cancellationReason: cancellationReason,
            isCompleted: true,
            updatedAt: nowIso,
        });
        logger.info('Order cancelled and refund recorded in Firestore', {
            userId,
            orderId: cleanOrderId,
            refundId: refundResponse.id,
            finalRefundStatus,
        });
        // Send push notifications asynchronously
        (0, notificationService_1.notifyOrderCancelled)(userId, `#${cleanOrderId}`, true, grandTotal).catch((err) => logger.warn('Failed to dispatch order cancelled notification', { userId, err }));
        if (finalRefundStatus === 'refunded') {
            (0, notificationService_1.notifyRefundProcessed)(userId, `#${cleanOrderId}`, refundResponse.id, grandTotal).catch((err) => logger.warn('Failed to dispatch refund processed notification', { userId, err }));
        }
        return {
            success: true,
            message: 'Order cancelled and refund processed to original payment method.',
            orderId: `#${cleanOrderId}`,
            status: 'cancelled',
            paymentStatus: finalRefundStatus === 'refunded' ? 'refunded' : 'paid',
            refundStatus: finalRefundStatus,
            refundId: refundResponse.id,
            refundAmount: grandTotal,
            refundedAt: nowIso,
            cancelledAt: nowIso,
        };
    }
    catch (error) {
        if (error instanceof https_1.HttpsError) {
            throw error;
        }
        logger.error('Unexpected error in cancelAndRefundOrder', {
            userId,
            orderId: cleanOrderId,
            error: error?.message || error,
        });
        throw new https_1.HttpsError('internal', 'Unable to process order cancellation at this time. Please try again.');
    }
});
//# sourceMappingURL=cancelAndRefundOrder.js.map