import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as logger from 'firebase-functions/logger';
import { db } from '../config/firebase';
import { getRazorpayClient } from '../config/razorpay';
import { razorpayKeyIdSecret, razorpayKeySecretSecret } from '../config/secrets';
import { notifyOrderCancelled, notifyRefundProcessed } from '../services/notificationService';

interface CancelOrderRequest {
  orderId: string;
  reason?: string;
}

export const cancelAndRefundOrder = onCall(
  {
    region: 'asia-south1',
    secrets: [razorpayKeyIdSecret, razorpayKeySecretSecret],
  },
  async (request) => {
    // 1. Authenticated user validation
    if (!request.auth || !request.auth.uid) {
      throw new HttpsError(
        'unauthenticated',
        'User must be logged in to cancel an order.'
      );
    }

    const userId = request.auth.uid;
    const data = request.data as CancelOrderRequest;

    if (!data || !data.orderId) {
      throw new HttpsError(
        'invalid-argument',
        'Missing required parameter: orderId.'
      );
    }

    const cleanOrderId = data.orderId.replace('#', '').trim();
    logger.info('cancelAndRefundOrder initiated', {
      userId,
      orderId: cleanOrderId,
      reason: data.reason,
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
      if (!orderData) {
        throw new HttpsError('not-found', 'Order data is empty.');
      }

      // 3. Idempotency check: If already cancelled
      if (orderData.status === 'cancelled') {
        logger.info('Order is already cancelled (idempotent)', {
          orderId: cleanOrderId,
          refundStatus: orderData.refundStatus,
        });
        return {
          success: true,
          message: 'Order is already cancelled.',
          orderId: `#${cleanOrderId}`,
          status: 'cancelled',
          paymentStatus: orderData.paymentStatus,
          refundStatus: orderData.refundStatus || null,
          refundId: orderData.refundId || null,
        };
      }

      // 4. Safe cancellation state policy: Only allow cancellation in 'placed' status
      if (orderData.status !== 'placed') {
        logger.warn('Cancellation rejected due to order lifecycle stage', {
          orderId: cleanOrderId,
          currentStatus: orderData.status,
        });
        throw new HttpsError(
          'failed-precondition',
          `Cannot cancel order in '${orderData.statusTitle || orderData.status}' stage. Orders can only be cancelled while in 'Order Placed' status before harvesting starts.`
        );
      }

      const nowIso = new Date().toISOString();
      const cancellationReason = data.reason || 'Cancelled by customer';

      // 5. COD Order Cancellation (No Razorpay refund)
      const isCod =
        orderData.paymentGateway === 'cod' ||
        orderData.paymentMethod === 'cashOnDelivery' ||
        orderData.paymentMethod === 'cod';

      if (isCod) {
        await orderRef.update({
          status: 'cancelled',
          statusTitle: 'Cancelled',
          paymentStatus: 'cancelled',
          paymentStatusTitle: 'Cancelled',
          cancelledAt: nowIso,
          cancellationReason: cancellationReason,
          isCompleted: true,
          updatedAt: nowIso,
        });

        logger.info('COD order cancelled successfully', {
          userId,
          orderId: cleanOrderId,
        });

        // Send push notification asynchronously
        notifyOrderCancelled(userId, `#${cleanOrderId}`, false).catch((err) =>
          logger.warn('Failed to dispatch COD cancellation notification', { userId, err })
        );

        return {
          success: true,
          message: 'Your COD order has been cancelled.',
          orderId: `#${cleanOrderId}`,
          status: 'cancelled',
          paymentStatus: 'cancelled',
          refundStatus: null,
          cancelledAt: nowIso,
        };
      }

      // 6. Online / Razorpay Order Cancellation
      // If payment was not completed/verified yet (pending/failed), cancel without refund
      if (orderData.paymentStatus !== 'paid') {
        await orderRef.update({
          status: 'cancelled',
          statusTitle: 'Cancelled',
          paymentStatus: 'cancelled',
          paymentStatusTitle: 'Cancelled',
          cancelledAt: nowIso,
          cancellationReason: cancellationReason,
          isCompleted: true,
          updatedAt: nowIso,
        });

        logger.info('Unpaid online order cancelled successfully', {
          userId,
          orderId: cleanOrderId,
        });

        // Send push notification asynchronously
        notifyOrderCancelled(userId, `#${cleanOrderId}`, false).catch((err) =>
          logger.warn('Failed to dispatch unpaid order cancellation notification', { userId, err })
        );

        return {
          success: true,
          message: 'Order cancelled successfully.',
          orderId: `#${cleanOrderId}`,
          status: 'cancelled',
          paymentStatus: 'cancelled',
          refundStatus: null,
          cancelledAt: nowIso,
        };
      }

      // 7. Paid Razorpay Order Refund Lifecycle
      const gatewayPaymentId = orderData.gatewayPaymentId;
      if (!gatewayPaymentId) {
        throw new HttpsError(
          'failed-precondition',
          'Cannot process refund: No gateway payment ID recorded for this order.'
        );
      }

      const grandTotal = Number(orderData.grandTotal) || 0;
      const amountInPaise = Math.round(grandTotal * 100);

      if (amountInPaise <= 0) {
        throw new HttpsError(
          'invalid-argument',
          'Invalid payable order amount for refund.'
        );
      }

      logger.info('Initiating Razorpay refund', {
        userId,
        orderId: cleanOrderId,
        gatewayPaymentId,
        amountInPaise,
      });

      const razorpay = getRazorpayClient();
      let refundResponse: any;

      try {
        refundResponse = await razorpay.payments.refund(gatewayPaymentId, {
          amount: amountInPaise,
          notes: {
            orderId: cleanOrderId,
            userId: userId,
            reason: cancellationReason,
          },
        });
      } catch (refundError: any) {
        logger.error('Razorpay refund API call failed', {
          userId,
          orderId: cleanOrderId,
          gatewayPaymentId,
          error: refundError?.message || refundError,
        });

        await orderRef.update({
          status: 'cancelled',
          statusTitle: 'Cancelled',
          refundStatus: 'failed',
          refundFailureReason:
            refundError?.error?.description ||
            refundError?.message ||
            'Refund gateway communication error',
          cancelledAt: nowIso,
          cancellationReason: cancellationReason,
          updatedAt: nowIso,
        });

        throw new HttpsError(
          'internal',
          'Order was cancelled, but the refund gateway encountered an issue. Our support team will verify and process your refund.'
        );
      }

      // 8. Update Firestore record to refunded state
      const isProcessed = refundResponse.status === 'processed';
      const finalRefundStatus = isProcessed ? 'refunded' : 'pending';

      await orderRef.update({
        status: 'cancelled',
        statusTitle: 'Cancelled',
        paymentStatus: finalRefundStatus === 'refunded' ? 'refunded' : 'paid',
        paymentStatusTitle: finalRefundStatus === 'refunded' ? 'Refunded' : 'Paid',
        refundStatus: finalRefundStatus,
        refundId: refundResponse.id,
        refundAmount: grandTotal,
        refundedAt: nowIso,
        cancelledAt: nowIso,
        cancellationReason: cancellationReason,
        isCompleted: true,
        updatedAt: nowIso,
      });

      logger.info('Order cancelled and refund recorded in Firestore', {
        userId,
        orderId: cleanOrderId,
        refundId: refundResponse.id,
        finalRefundStatus,
      });

      // Send push notifications asynchronously
      notifyOrderCancelled(userId, `#${cleanOrderId}`, true, grandTotal).catch((err) =>
        logger.warn('Failed to dispatch order cancelled notification', { userId, err })
      );
      if (finalRefundStatus === 'refunded') {
        notifyRefundProcessed(userId, `#${cleanOrderId}`, refundResponse.id, grandTotal).catch((err) =>
          logger.warn('Failed to dispatch refund processed notification', { userId, err })
        );
      }

      return {
        success: true,
        message: 'Order cancelled and refund processed to original payment method.',
        orderId: `#${cleanOrderId}`,
        status: 'cancelled',
        paymentStatus: finalRefundStatus === 'refunded' ? 'refunded' : 'paid',
        refundStatus: finalRefundStatus,
        refundId: refundResponse.id,
        refundAmount: grandTotal,
        refundedAt: nowIso,
        cancelledAt: nowIso,
      };
    } catch (error: any) {
      if (error instanceof HttpsError) {
        throw error;
      }
      logger.error('Unexpected error in cancelAndRefundOrder', {
        userId,
        orderId: cleanOrderId,
        error: error?.message || error,
      });
      throw new HttpsError(
        'internal',
        'Unable to process order cancellation at this time. Please try again.'
      );
    }
  }
);
