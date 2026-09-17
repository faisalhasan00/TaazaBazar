import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as logger from 'firebase-functions/logger';
import { db } from '../config/firebase';
import { getRazorpayCredentials, razorpayKeySecretSecret } from '../config/secrets';
import { verifyPaymentSignature } from '../services/signatureVerifier';
import { notifyPaymentSuccess } from '../services/notificationService';

interface VerifySignatureRequest {
  orderId: string;
  gatewayOrderId: string;
  gatewayPaymentId: string;
  signature: string;
}

export const verifyRazorpaySignature = onCall(
  {
    region: 'asia-south1',
    secrets: [razorpayKeySecretSecret],
  },
  async (request) => {
    // 1. Authenticated user validation
    if (!request.auth || !request.auth.uid) {
      throw new HttpsError(
        'unauthenticated',
        'User must be logged in to verify payment.'
      );
    }

    const userId = request.auth.uid;
    const data = request.data as VerifySignatureRequest;

    if (
      !data ||
      !data.orderId ||
      !data.gatewayOrderId ||
      !data.gatewayPaymentId ||
      !data.signature
    ) {
      throw new HttpsError(
        'invalid-argument',
        'Missing required payment verification parameters.'
      );
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
      const orderRef = db
        .collection('users')
        .doc(userId)
        .collection('orders')
        .doc(cleanOrderId);

      const orderDoc = await orderRef.get();
      if (!orderDoc.exists) {
        throw new HttpsError('not-found', 'Order not found in customer records.');
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
        throw new HttpsError(
          'invalid-argument',
          'Gateway Order ID does not match order record.'
        );
      }

      // 4. Idempotency check: If already marked paid, return success immediately
      if (
        orderData?.paymentStatus === 'paid' &&
        (orderData?.gatewayPaymentId === data.gatewayPaymentId || !orderData?.gatewayPaymentId)
      ) {
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
      const { keySecret } = getRazorpayCredentials();
      const isValid = verifyPaymentSignature(
        data.gatewayOrderId,
        data.gatewayPaymentId,
        data.signature,
        keySecret
      );

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

        throw new HttpsError(
          'permission-denied',
          'Payment verification failed. Invalid signature.'
        );
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
      notifyPaymentSuccess(userId, `#${cleanOrderId}`, payableAmount).catch((err) =>
        logger.warn('Failed to dispatch payment success push notification', { userId, err })
      );

      return {
        success: true,
        message: 'Payment verified successfully.',
        orderId: `#${cleanOrderId}`,
        paymentStatus: 'paid',
        paidAt: nowIso,
      };
    } catch (error: any) {
      if (error instanceof HttpsError) {
        throw error;
      }
      logger.error('Error during signature verification', {
        userId,
        orderId: cleanOrderId,
        error: error?.message || error,
      });
      throw new HttpsError(
        'internal',
        'Payment verification encountered an internal error.'
      );
    }
  }
);
