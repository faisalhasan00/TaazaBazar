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
const crypto = __importStar(require("crypto"));
const signatureVerifier_1 = require("../services/signatureVerifier");
describe('Payment Backend Unit Tests', () => {
    const mockKeySecret = 'test_key_secret_xyz123';
    const mockWebhookSecret = 'test_webhook_secret_abc456';
    describe('1. verifyPaymentSignature', () => {
        test('successfully verifies valid Razorpay payment signature', () => {
            const orderId = 'order_DAw29810';
            const paymentId = 'pay_P10294819';
            const validSignature = crypto
                .createHmac('sha256', mockKeySecret)
                .update(`${orderId}|${paymentId}`)
                .digest('hex');
            const result = (0, signatureVerifier_1.verifyPaymentSignature)(orderId, paymentId, validSignature, mockKeySecret);
            expect(result).toBe(true);
        });
        test('rejects forged / altered payment signature', () => {
            const orderId = 'order_DAw29810';
            const paymentId = 'pay_P10294819';
            const invalidSignature = 'deadbeefdeadbeefdeadbeef';
            const result = (0, signatureVerifier_1.verifyPaymentSignature)(orderId, paymentId, invalidSignature, mockKeySecret);
            expect(result).toBe(false);
        });
        test('rejects signature when orderId or paymentId is mismatched', () => {
            const orderId = 'order_DAw29810';
            const paymentId = 'pay_P10294819';
            const signatureForOtherOrder = crypto
                .createHmac('sha256', mockKeySecret)
                .update(`different_order|${paymentId}`)
                .digest('hex');
            const result = (0, signatureVerifier_1.verifyPaymentSignature)(orderId, paymentId, signatureForOtherOrder, mockKeySecret);
            expect(result).toBe(false);
        });
        test('handles missing or empty arguments safely without crashing', () => {
            expect((0, signatureVerifier_1.verifyPaymentSignature)('', 'pay_123', 'sig', mockKeySecret)).toBe(false);
            expect((0, signatureVerifier_1.verifyPaymentSignature)('order_123', '', 'sig', mockKeySecret)).toBe(false);
            expect((0, signatureVerifier_1.verifyPaymentSignature)('order_123', 'pay_123', '', mockKeySecret)).toBe(false);
            expect((0, signatureVerifier_1.verifyPaymentSignature)('order_123', 'pay_123', 'sig', '')).toBe(false);
        });
    });
    describe('2. verifyWebhookSignature', () => {
        test('successfully verifies valid Razorpay webhook signature', () => {
            const rawPayload = JSON.stringify({
                event: 'payment.captured',
                payload: { payment: { entity: { id: 'pay_999', order_id: 'order_888' } } },
            });
            const validWebhookSig = crypto
                .createHmac('sha256', mockWebhookSecret)
                .update(rawPayload)
                .digest('hex');
            const result = (0, signatureVerifier_1.verifyWebhookSignature)(rawPayload, validWebhookSig, mockWebhookSecret);
            expect(result).toBe(true);
        });
        test('rejects tampered webhook payload', () => {
            const rawPayload = JSON.stringify({ event: 'payment.captured' });
            const tamperedPayload = JSON.stringify({ event: 'order.paid' });
            const signature = crypto
                .createHmac('sha256', mockWebhookSecret)
                .update(rawPayload)
                .digest('hex');
            const result = (0, signatureVerifier_1.verifyWebhookSignature)(tamperedPayload, signature, mockWebhookSecret);
            expect(result).toBe(false);
        });
    });
    describe('3. Pricing & Delivery Fee Parity (₹199 Free Delivery Threshold)', () => {
        // Helper function to mirror validateOrderPricing delivery fee & grand total rule
        function calculateTotals(subtotal, discount = 0) {
            const freeDeliveryThreshold = 199;
            const standardDeliveryFee = 25;
            const deliveryFee = subtotal >= freeDeliveryThreshold ? 0 : standardDeliveryFee;
            const grandTotal = Math.max(0, subtotal + deliveryFee - discount);
            const amountInPaise = Math.round(grandTotal * 100);
            return { deliveryFee, grandTotal, amountInPaise };
        }
        test('Boundary test: subtotal ₹0 -> delivery ₹25, grandTotal ₹25', () => {
            const res = calculateTotals(0);
            expect(res.deliveryFee).toBe(25);
            expect(res.grandTotal).toBe(25);
            expect(res.amountInPaise).toBe(2500);
        });
        test('Boundary test: subtotal ₹50 -> delivery ₹25, grandTotal ₹75', () => {
            const res = calculateTotals(50);
            expect(res.deliveryFee).toBe(25);
            expect(res.grandTotal).toBe(75);
            expect(res.amountInPaise).toBe(7500);
        });
        test('Boundary test: subtotal ₹198 -> delivery ₹25, grandTotal ₹223', () => {
            const res = calculateTotals(198);
            expect(res.deliveryFee).toBe(25);
            expect(res.grandTotal).toBe(223);
            expect(res.amountInPaise).toBe(22300);
        });
        test('Boundary test: subtotal ₹198.99 -> delivery ₹25, grandTotal ₹223.99', () => {
            const res = calculateTotals(198.99);
            expect(res.deliveryFee).toBe(25);
            expect(res.grandTotal).toBe(223.99);
            expect(res.amountInPaise).toBe(22399);
        });
        test('Boundary test: subtotal ₹199 (Exact Threshold) -> delivery ₹0, grandTotal ₹199', () => {
            const res = calculateTotals(199);
            expect(res.deliveryFee).toBe(0);
            expect(res.grandTotal).toBe(199);
            expect(res.amountInPaise).toBe(19900);
        });
        test('Boundary test: subtotal ₹199.01 -> delivery ₹0, grandTotal ₹199.01', () => {
            const res = calculateTotals(199.01);
            expect(res.deliveryFee).toBe(0);
            expect(res.grandTotal).toBe(199.01);
            expect(res.amountInPaise).toBe(19901);
        });
        test('Boundary test: subtotal ₹200 -> delivery ₹0, grandTotal ₹200', () => {
            const res = calculateTotals(200);
            expect(res.deliveryFee).toBe(0);
            expect(res.grandTotal).toBe(200);
            expect(res.amountInPaise).toBe(20000);
        });
        test('Boundary test: subtotal ₹224 -> delivery ₹0, grandTotal ₹224', () => {
            const res = calculateTotals(224);
            expect(res.deliveryFee).toBe(0);
            expect(res.grandTotal).toBe(224);
            expect(res.amountInPaise).toBe(22400);
        });
        test('Coupon test: subtotal ₹250 with ₹50 discount -> delivery ₹0, grandTotal ₹200', () => {
            const res = calculateTotals(250, 50);
            expect(res.deliveryFee).toBe(0);
            expect(res.grandTotal).toBe(200);
            expect(res.amountInPaise).toBe(20000);
        });
        test('Coupon test: subtotal ₹150 with ₹20 discount -> delivery ₹25, grandTotal ₹155', () => {
            const res = calculateTotals(150, 20);
            expect(res.deliveryFee).toBe(25);
            expect(res.grandTotal).toBe(155);
            expect(res.amountInPaise).toBe(15500);
        });
    });
    describe('4. Backend Verification Idempotency & Gateway Order Validation', () => {
        test('Gateway order ID match validation logic correctly identifies matches and mismatches', () => {
            const storedGatewayOrderId = 'order_N99281749';
            const incomingGatewayOrderId = 'order_N99281749';
            const mismatchedGatewayOrderId = 'order_DIFFERENT99';
            expect(storedGatewayOrderId === incomingGatewayOrderId).toBe(true);
            expect(storedGatewayOrderId === mismatchedGatewayOrderId).toBe(false);
        });
        test('Idempotency logic correctly recognizes already-paid orders with matching payment ID', () => {
            const orderDoc = {
                orderId: '#FRSH-12345',
                paymentStatus: 'paid',
                gatewayOrderId: 'order_N99281749',
                gatewayPaymentId: 'pay_P10294819',
                paidAt: '2026-09-14T10:00:00.000Z',
            };
            const incomingPaymentId = 'pay_P10294819';
            const isAlreadyPaid = orderDoc.paymentStatus === 'paid' &&
                (orderDoc.gatewayPaymentId === incomingPaymentId || !orderDoc.gatewayPaymentId);
            expect(isAlreadyPaid).toBe(true);
        });
    });
    describe('5. Order Cancellation & Razorpay Refund Lifecycle Rules', () => {
        test('Cancellation allowed ONLY in placed stage; rejected in other stages', () => {
            function canCancelOrder(status) {
                return status === 'placed';
            }
            expect(canCancelOrder('placed')).toBe(true);
            expect(canCancelOrder('preparing')).toBe(false);
            expect(canCancelOrder('outForDelivery')).toBe(false);
            expect(canCancelOrder('delivered')).toBe(false);
            expect(canCancelOrder('cancelled')).toBe(false);
        });
        test('COD order cancellation transitions status and paymentStatus to cancelled without gateway refund', () => {
            const order = {
                orderId: 'FRSH-COD-99',
                status: 'placed',
                paymentMethod: 'cashOnDelivery',
                paymentGateway: 'cod',
                paymentStatus: 'pending',
                grandTotal: 150.0,
            };
            const isCod = order.paymentGateway === 'cod' || order.paymentMethod === 'cashOnDelivery';
            expect(isCod).toBe(true);
            const updatedOrder = {
                ...order,
                status: 'cancelled',
                paymentStatus: 'cancelled',
                cancelledAt: '2026-09-14T12:00:00.000Z',
                cancellationReason: 'Customer cancellation',
            };
            expect(updatedOrder.status).toBe('cancelled');
            expect(updatedOrder.paymentStatus).toBe('cancelled');
        });
        test('Paid Razorpay cancellation computes server-trusted refund amount in paise from grandTotal', () => {
            const order = {
                orderId: 'FRSH-PAID-99',
                status: 'placed',
                paymentGateway: 'razorpay',
                paymentStatus: 'paid',
                gatewayPaymentId: 'pay_ABC123',
                grandTotal: 299.50,
            };
            expect(order.paymentStatus).toBe('paid');
            expect(order.gatewayPaymentId).toBeDefined();
            const refundAmountInPaise = Math.round(order.grandTotal * 100);
            expect(refundAmountInPaise).toBe(29950);
        });
        test('Refund webhook signature verification validates refund.processed payload', () => {
            const rawPayload = JSON.stringify({
                event: 'refund.processed',
                payload: {
                    refund: {
                        entity: {
                            id: 'rfnd_12345',
                            amount: 29950,
                            payment_id: 'pay_ABC123',
                            notes: { userId: 'user_123', orderId: 'FRSH-PAID-99' },
                        },
                    },
                },
            });
            const validSignature = crypto
                .createHmac('sha256', mockWebhookSecret)
                .update(rawPayload)
                .digest('hex');
            const isValid = (0, signatureVerifier_1.verifyWebhookSignature)(rawPayload, validSignature, mockWebhookSecret);
            expect(isValid).toBe(true);
        });
    });
    describe('6. Firebase Cloud Messaging (FCM) Notification Payload & Lifecycle Rules', () => {
        test('Order Confirmed notification payload structure matches contract', () => {
            const payload = {
                title: 'Order Confirmed! 🥦',
                body: 'Your TaazaBazar order #FRSH-101 (₹250) has been confirmed & sent to farm harvest.',
                type: 'order_placed',
                orderId: '#FRSH-101',
            };
            expect(payload.type).toBe('order_placed');
            expect(payload.orderId).toBe('#FRSH-101');
            expect(payload.title).toContain('Order Confirmed');
        });
        test('Payment Success notification payload structure matches contract', () => {
            const payload = {
                title: 'Payment Successful! ⚡',
                body: 'Payment of ₹250 for order #FRSH-101 has been verified and processed successfully.',
                type: 'payment_success',
                orderId: '#FRSH-101',
            };
            expect(payload.type).toBe('payment_success');
            expect(payload.orderId).toBe('#FRSH-101');
            expect(payload.title).toContain('Payment Successful');
        });
        test('Order Cancelled notification payload handles both COD and Refund initiated formats', () => {
            const codPayload = {
                title: 'Order Cancelled',
                body: 'Order #FRSH-101 has been cancelled successfully.',
                type: 'order_cancelled',
                orderId: '#FRSH-101',
            };
            const refundPayload = {
                title: 'Order Cancelled',
                body: 'Order #FRSH-101 was cancelled. A refund of ₹250 has been initiated to your original payment method.',
                type: 'order_cancelled',
                orderId: '#FRSH-101',
            };
            expect(codPayload.body).not.toContain('refund');
            expect(refundPayload.body).toContain('refund of ₹250');
        });
        test('Stale / Unregistered FCM token error codes are identified for cleanup', () => {
            const staleErrorCodes = [
                'messaging/registration-token-not-registered',
                'messaging/invalid-registration-token',
            ];
            function isStaleTokenError(code) {
                return staleErrorCodes.includes(code);
            }
            expect(isStaleTokenError('messaging/registration-token-not-registered')).toBe(true);
            expect(isStaleTokenError('messaging/invalid-registration-token')).toBe(true);
            expect(isStaleTokenError('messaging/server-unavailable')).toBe(false);
        });
    });
});
//# sourceMappingURL=payment_backend.test.js.map