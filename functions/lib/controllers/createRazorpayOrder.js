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
exports.createRazorpayOrder = void 0;
const https_1 = require("firebase-functions/v2/https");
const logger = __importStar(require("firebase-functions/logger"));
const firebase_1 = require("../config/firebase");
const razorpay_1 = require("../config/razorpay");
const secrets_1 = require("../config/secrets");
const orderValidator_1 = require("../services/orderValidator");
exports.createRazorpayOrder = (0, https_1.onCall)({
    region: 'asia-south1',
    secrets: [secrets_1.razorpayKeyIdSecret, secrets_1.razorpayKeySecretSecret],
}, async (request) => {
    // 1. Authenticated user validation
    if (!request.auth || !request.auth.uid) {
        throw new https_1.HttpsError('unauthenticated', 'User must be logged in to create a payment order.');
    }
    const userId = request.auth.uid;
    const data = request.data;
    if (!data || !data.orderId || !data.items || !Array.isArray(data.items)) {
        throw new https_1.HttpsError('invalid-argument', 'Missing required parameters: orderId and items list.');
    }
    const cleanOrderId = data.orderId.replace('#', '').trim();
    logger.info('createRazorpayOrder initiated', {
        userId,
        orderId: cleanOrderId,
        itemsCount: data.items.length,
    });
    try {
        // 2. Anti-tampering pricing verification
        const pricing = await (0, orderValidator_1.validateOrderPricing)(data.items, data.couponCode);
        if (!pricing.isValid || pricing.amountInPaise <= 0) {
            throw new https_1.HttpsError('invalid-argument', pricing.errorMessage || 'Invalid order items or zero payable amount.');
        }
        // 3. Check for existing order / idempotency
        const orderRef = firebase_1.db
            .collection('users')
            .doc(userId)
            .collection('orders')
            .doc(cleanOrderId);
        const existingDoc = await orderRef.get();
        if (existingDoc.exists) {
            const existingData = existingDoc.data();
            if (existingData?.paymentStatus === 'paid') {
                throw new https_1.HttpsError('already-exists', 'This order has already been paid for.');
            }
            // If a Razorpay order already exists for this pending order and amounts match, reuse it
            if (existingData?.gatewayOrderId &&
                existingData?.paymentStatus === 'pending' &&
                existingData?.grandTotal === pricing.grandTotal) {
                logger.info('Reusing existing pending Razorpay order', {
                    orderId: cleanOrderId,
                    gatewayOrderId: existingData.gatewayOrderId,
                });
                const { keyId } = (0, secrets_1.getRazorpayCredentials)();
                return {
                    success: true,
                    orderId: `#${cleanOrderId}`,
                    gatewayOrderId: existingData.gatewayOrderId,
                    amount: pricing.grandTotal,
                    amountInPaise: pricing.amountInPaise,
                    currency: 'INR',
                    keyId: keyId,
                };
            }
        }
        // 4. Create Razorpay Order via Razorpay API
        const razorpay = (0, razorpay_1.getRazorpayClient)();
        const options = {
            amount: pricing.amountInPaise,
            currency: 'INR',
            receipt: `rcpt_${cleanOrderId.substring(0, 30)}`,
            notes: {
                userId: userId,
                orderId: cleanOrderId,
                app: 'TaazaBazar',
            },
        };
        const razorpayOrder = await razorpay.orders.create(options);
        const gatewayOrderId = razorpayOrder.id;
        logger.info('Razorpay Order created successfully', {
            userId,
            orderId: cleanOrderId,
            gatewayOrderId,
            amountInPaise: pricing.amountInPaise,
        });
        // 5. Store/merge pending order in Firestore with trusted gatewayOrderId
        const pendingOrderData = {
            orderId: `#${cleanOrderId}`,
            orderDate: new Date().toISOString(),
            slotDate: data.slotDate || 'Today',
            timeSlot: data.timeSlot || '6:00 AM – 8:00 AM',
            status: 'placed',
            statusTitle: 'Order Placed',
            items: data.items,
            itemTotal: pricing.itemTotal,
            deliveryFee: pricing.deliveryFee,
            discount: pricing.discount,
            grandTotal: pricing.grandTotal,
            paymentMethod: 'upi',
            paymentMethodTitle: 'Online Payment',
            paymentStatus: 'pending',
            paymentStatusTitle: 'Pending',
            paymentGateway: 'razorpay',
            gatewayOrderId: gatewayOrderId,
            deliveryAddress: data.deliveryAddress || '',
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
        };
        if (typeof data.deliveryLatitude === 'number') {
            pendingOrderData.deliveryLatitude = data.deliveryLatitude;
        }
        if (typeof data.deliveryLongitude === 'number') {
            pendingOrderData.deliveryLongitude = data.deliveryLongitude;
        }
        await orderRef.set(pendingOrderData, { merge: true });
        const { keyId } = (0, secrets_1.getRazorpayCredentials)();
        return {
            success: true,
            orderId: `#${cleanOrderId}`,
            gatewayOrderId: gatewayOrderId,
            amount: pricing.grandTotal,
            amountInPaise: pricing.amountInPaise,
            currency: 'INR',
            keyId: keyId,
        };
    }
    catch (error) {
        if (error instanceof https_1.HttpsError) {
            throw error;
        }
        logger.error('Error creating Razorpay order', {
            userId,
            orderId: cleanOrderId,
            error: error?.message || error,
        });
        throw new https_1.HttpsError('internal', 'Unable to initialize payment. Please try again later.');
    }
});
//# sourceMappingURL=createRazorpayOrder.js.map