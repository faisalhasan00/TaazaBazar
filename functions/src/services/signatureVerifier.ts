import * as crypto from 'crypto';

/**
 * Validates Razorpay Checkout payment signature using HMAC-SHA256
 */
export function verifyPaymentSignature(
  orderId: string,
  paymentId: string,
  signature: string,
  keySecret: string
): boolean {
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
  } catch {
    return false;
  }
}

/**
 * Validates Razorpay Webhook signature using HMAC-SHA256
 */
export function verifyWebhookSignature(
  rawBody: string | Buffer,
  signature: string,
  webhookSecret: string
): boolean {
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
  } catch {
    return false;
  }
}
