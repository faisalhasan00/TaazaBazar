import Razorpay from 'razorpay';
import { getRazorpayCredentials } from './secrets';

export function getRazorpayClient(): Razorpay {
  const { keyId, keySecret } = getRazorpayCredentials();

  if (!keyId || !keySecret) {
    throw new Error(
      'Razorpay credentials are not configured. Please set RAZORPAY_KEY_ID and RAZORPAY_KEY_SECRET in Secret Manager or environment variables.'
    );
  }

  return new Razorpay({
    key_id: keyId,
    key_secret: keySecret,
  });
}
