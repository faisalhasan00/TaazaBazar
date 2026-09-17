"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getRazorpayClient = getRazorpayClient;
const razorpay_1 = __importDefault(require("razorpay"));
const secrets_1 = require("./secrets");
function getRazorpayClient() {
    const { keyId, keySecret } = (0, secrets_1.getRazorpayCredentials)();
    if (!keyId || !keySecret) {
        throw new Error('Razorpay credentials are not configured. Please set RAZORPAY_KEY_ID and RAZORPAY_KEY_SECRET in Secret Manager or environment variables.');
    }
    return new razorpay_1.default({
        key_id: keyId,
        key_secret: keySecret,
    });
}
//# sourceMappingURL=razorpay.js.map