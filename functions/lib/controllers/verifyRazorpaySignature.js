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
exports.verifyRazorpaySignature = void 0;
const https_1 = require("firebase-functions/v2/https");
const logger = __importStar(require("firebase-functions/logger"));
const firebase_1 = require("../config/firebase");
const secrets_1 = require("../config/secrets");
const signatureVerifier_1 = require("../services/signatureVerifier");
const notificationService_1 = require("../services/notificationService");
exports.verifyRazorpaySignature = (0, https_1.onCall)({
    region: 'asia-south1',
    secrets: [secrets_1.razorpayKeySecretSecret],
}, async (request) => {
    // 1. Authenticated user validation
    if (!request.auth || !request.auth.uid) {
        throw new https_1.HttpsError('unauthenticated', 'User must be logged in to verify payment.');
    }
    const userId = request.auth.uid;
    const data = request.data;
    if (!data ||
        !data.orderId ||
        !data.gatewayOrderId ||
        !data.gatewayPaymentId ||
        !data.signature) {
        throw new https_1.HttpsError('invalid-argument', 'Missing required payment verification parameters.');
    }
    const cleanOrderId = data.orderId.replace('#', '').trim();
    logger.info('verifyRazorpaySignature initiated', {
        userId,
        orderId: cleanOrderId,
        gatewayOrderId: data.gatewayOrderId,
        gatewayPaymentId: data.gatewayPaymentId,
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
        // 3. Gateway Order ID validation
        if (orderData?.gatewayOrderId && orderData.gatewayOrderId !== data.gatewayOrderId) {
            logger.warn('Gateway Order ID mismatch during verification', {
                userId,
                orderId: cleanOrderId,
                storedGatewayOrderId: orderData.gatewayOrderId,
                receivedGatewayOrderId: data.gatewayOrderId,
            });
            throw new https_1.HttpsError('invalid-argument', 'Gateway Order ID does not match order record.');
        }
        // 4. Idempotency check: If already marked paid, return success immediately
        if (orderData?.paymentStatus === 'paid' &&
            (orderData?.gatewayPaymentId === data.gatewayPaymentId || !orderData?.gatewayPaymentId)) {
            logger.info('Order already verified and paid (idempotent)', {
                orderId: cleanOrderId,
                gatewayPaymentId: data.gatewayPaymentId,
            });
            return {
                success: true,
                message: 'Payment already verified.',
                orderId: `#${cleanOrderId}`,
                paymentStatus: 'paid',
                paidAt: orderData.paidAt || new Date().toISOString(),
            };
        }
        // 4. Verify Razorpay Signature using Server Secret
        const { keySecret } = (0, secrets_1.getRazorpayCredentials)();
        const isValid = (0, signatureVerifier_1.verifyPaymentSignature)(data.gatewayOrderId, data.gatewayPaymentId, data.signature, keySecret);
        if (!isValid) {
            logger.warn('Razorpay signature verification failed', {
                userId,
                orderId: cleanOrderId,
                gatewayOrderId: data.gatewayOrderId,
                gatewayPaymentId: data.gatewayPaymentId,
            });
            // Record payment failure audit on the order document
            await orderRef.update({
                paymentStatus: 'failed',
                paymentStatusTitle: 'Failed',
                failureReason: 'Payment signature verification mismatch',
                updatedAt: new Date().toISOString(),
            });
            throw new https_1.HttpsError('permission-denied', 'Payment verification failed. Invalid signature.');
        }
        // 5. Atomic Update in Firestore to 'paid' state
        const nowIso = new Date().toISOString();
        await orderRef.update({
            paymentStatus: 'paid',
            paymentStatusTitle: 'Paid',
            paymentGateway: 'razorpay',
            gatewayOrderId: data.gatewayOrderId,
            gatewayPaymentId: data.gatewayPaymentId,
            paidAt: nowIso,
            failureReason: null,
            updatedAt: nowIso,
        });
        logger.info('Payment verified and order updated to paid successfully', {
            userId,
            orderId: cleanOrderId,
            gatewayPaymentId: data.gatewayPaymentId,
            paidAt: nowIso,
        });
        // Send push notification asynchronously
        const payableAmount = orderData?.grandTotal || 0;
        (0, notificationService_1.notifyPaymentSuccess)(userId, `#${cleanOrderId}`, payableAmount).catch((err) => logger.warn('Failed to dispatch payment success push notification', { userId, err }));
        return {
            success: true,
            message: 'Payment verified successfully.',
            orderId: `#${cleanOrderId}`,
            paymentStatus: 'paid',
            paidAt: nowIso,
        };
    }
    catch (error) {
        if (error instanceof https_1.HttpsError) {
            throw error;
        }
        logger.error('Error during signature verification', {
            userId,
            orderId: cleanOrderId,
            error: error?.message || error,
        });
        throw new https_1.HttpsError('internal', 'Payment verification encountered an internal error.');
    }
});
//# sourceMappingURL=verifyRazorpaySignature.js.map