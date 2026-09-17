"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.razorpayWebhookSecretSecret = exports.razorpayKeySecretSecret = exports.razorpayKeyIdSecret = void 0;
exports.getRazorpayCredentials = getRazorpayCredentials;
const params_1 = require("firebase-functions/params");
exports.razorpayKeyIdSecret = (0, params_1.defineSecret)('RAZORPAY_KEY_ID');
exports.razorpayKeySecretSecret = (0, params_1.defineSecret)('RAZORPAY_KEY_SECRET');
exports.razorpayWebhookSecretSecret = (0, params_1.defineSecret)('RAZORPAY_WEBHOOK_SECRET');
function getRazorpayCredentials() {
    const keyId = process.env.RAZORPAY_KEY_ID || exports.razorpayKeyIdSecret.value() || '';
    const keySecret = process.env.RAZORPAY_KEY_SECRET || exports.razorpayKeySecretSecret.value() || '';
    const webhookSecret = process.env.RAZORPAY_WEBHOOK_SECRET || exports.razorpayWebhookSecretSecret.value() || '';
    return {
        keyId,
        keySecret,
        webhookSecret,
    };
}
//# sourceMappingURL=secrets.js.map