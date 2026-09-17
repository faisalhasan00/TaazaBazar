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
exports.verifyPaymentSignature = verifyPaymentSignature;
exports.verifyWebhookSignature = verifyWebhookSignature;
const crypto = __importStar(require("crypto"));
/**
 * Validates Razorpay Checkout payment signature using HMAC-SHA256
 */
function verifyPaymentSignature(orderId, paymentId, signature, keySecret) {
    if (!orderId || !paymentId || !signature || !keySecret) {
        return false;
    }
    const generatedSignature = crypto
        .createHmac('sha256', keySecret)
        .update(`${orderId}|${paymentId}`)
        .digest('hex');
    try {
        const signatureBuffer = Buffer.from(signature, 'utf8');
        const generatedBuffer = Buffer.from(generatedSignature, 'utf8');
        if (signatureBuffer.length !== generatedBuffer.length) {
            return false;
        }
        return crypto.timingSafeEqual(signatureBuffer, generatedBuffer);
    }
    catch {
        return false;
    }
}
/**
 * Validates Razorpay Webhook signature using HMAC-SHA256
 */
function verifyWebhookSignature(rawBody, signature, webhookSecret) {
    if (!rawBody || !signature || !webhookSecret) {
        return false;
    }
    const generatedSignature = crypto
        .createHmac('sha256', webhookSecret)
        .update(rawBody)
        .digest('hex');
    try {
        const signatureBuffer = Buffer.from(signature, 'utf8');
        const generatedBuffer = Buffer.from(generatedSignature, 'utf8');
        if (signatureBuffer.length !== generatedBuffer.length) {
            return false;
        }
        return crypto.timingSafeEqual(signatureBuffer, generatedBuffer);
    }
    catch {
        return false;
    }
}
//# sourceMappingURL=signatureVerifier.js.map