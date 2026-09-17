import { defineSecret } from 'firebase-functions/params';

export const razorpayKeyIdSecret = defineSecret('RAZORPAY_KEY_ID');
export const razorpayKeySecretSecret = defineSecret('RAZORPAY_KEY_SECRET');
export const razorpayWebhookSecretSecret = defineSecret('RAZORPAY_WEBHOOK_SECRET');

export function getRazorpayCredentials() {
  const keyId = process.env.RAZORPAY_KEY_ID || razorpayKeyIdSecret.value() || '';
  const keySecret = process.env.RAZORPAY_KEY_SECRET || razorpayKeySecretSecret.value() || '';
  const webhookSecret = process.env.RAZORPAY_WEBHOOK_SECRET || razorpayWebhookSecretSecret.value() || '';

  return {
    keyId,
    keySecret,
    webhookSecret,
  };
}
