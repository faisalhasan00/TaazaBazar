import { onRequest } from 'firebase-functions/v2/https';
import * as logger from 'firebase-functions/logger';
import { db } from '../config/firebase';
import { getRazorpayCredentials, razorpayWebhookSecretSecret } from '../config/secrets';
import { verifyWebhookSignature } from '../services/signatureVerifier';

export const razorpayWebhook = onRequest(
  {
    region: 'asia-south1',
    secrets: [razorpayWebhookSecretSecret],
  },
  async (req, res) => {
    if (req.method !== 'POST') {
      res.status(405).send('Method Not Allowed');
      return;
    }

    const signature = req.headers['x-razorpay-signature'] as string;
    if (!signature) {
      logger.warn('Webhook received without x-razorpay-signature header');
      res.status(400).send('Missing webhook signature');
      return;
    }

    const { webhookSecret } = getRazorpayCredentials();
    if (!webhookSecret) {
      logger.error('RAZORPAY_WEBHOOK_SECRET is not configured on server');
      res.status(500).send('Webhook secret not configured');
      return;
    }

    // Verify raw body with signature
    const rawBody = (req as any).rawBody || JSON.stringify(req.body);
    const isValid = verifyWebhookSignature(rawBody, signature, webhookSecret);

    if (!isValid) {
      logger.warn('Invalid webhook signature received from IP', {
        ip: req.ip,
      });
      res.status(400).send('Invalid signature');
      return;
    }

    const event = req.body;
    const eventType = event?.event;
    const payload = event?.payload;

    logger.info('Razorpay webhook event verified', {
      eventType,
      entityId: payload?.payment?.entity?.id || payload?.order?.entity?.id,
    });

    try {
      if (eventType === 'payment.captured' || eventType === 'order.paid') {
        const paymentEntity = payload?.payment?.entity;
        const notes = paymentEntity?.notes || payload?.order?.entity?.notes || {};
        const userId = notes.userId;
        const cleanOrderId = notes.orderId;
        const gatewayOrderId = paymentEntity?.order_id || payload?.order?.entity?.id;
        const gatewayPaymentId = paymentEntity?.id;

        if (userId && cleanOrderId) {
          const orderRef = db
            .collection('users')
            .doc(userId)
            .collection('orders')
            .doc(cleanOrderId);

          const orderDoc = await orderRef.get();
          if (orderDoc.exists) {
            const data = orderDoc.data();
            if (data?.paymentStatus !== 'paid') {
              const nowIso = new Date().toISOString();
              await orderRef.update({
                paymentStatus: 'paid',
                paymentStatusTitle: 'Paid',
                paymentGateway: 'razorpay',
                gatewayOrderId: gatewayOrderId,
                gatewayPaymentId: gatewayPaymentId,
                paidAt: nowIso,
                failureReason: null,
                updatedAt: nowIso,
              });
              logger.info('Webhook updated order to paid', {
                userId,
                orderId: cleanOrderId,
                gatewayPaymentId,
              });
            }
          }
        }
      } else if (eventType === 'payment.failed') {
        const paymentEntity = payload?.payment?.entity;
        const notes = paymentEntity?.notes || {};
        const userId = notes.userId;
        const cleanOrderId = notes.orderId;
        const reason = paymentEntity?.error_description || 'Payment failed';

        if (userId && cleanOrderId) {
          const orderRef = db
            .collection('users')
            .doc(userId)
            .collection('orders')
            .doc(cleanOrderId);

          const orderDoc = await orderRef.get();
          if (orderDoc.exists && orderDoc.data()?.paymentStatus !== 'paid') {
            await orderRef.update({
              paymentStatus: 'failed',
              paymentStatusTitle: 'Failed',
              failureReason: reason,
              updatedAt: new Date().toISOString(),
            });
            logger.info('Webhook recorded payment failure', {
              userId,
              orderId: cleanOrderId,
              reason,
            });
          }
        }
      } else if (eventType === 'refund.processed') {
        const refundEntity = payload?.refund?.entity;
        const notes = refundEntity?.notes || {};
        const userId = notes.userId;
        const cleanOrderId = notes.orderId;
        const refundId = refundEntity?.id;
        const refundAmount =
          typeof refundEntity?.amount === 'number'
            ? refundEntity.amount / 100
            : undefined;

        if (userId && cleanOrderId) {
          const orderRef = db
            .collection('users')
            .doc(userId)
            .collection('orders')
            .doc(cleanOrderId);

          const orderDoc = await orderRef.get();
          if (orderDoc.exists) {
            const nowIso = new Date().toISOString();
            const updateData: Record<string, any> = {
              status: 'cancelled',
              statusTitle: 'Cancelled',
              paymentStatus: 'refunded',
              paymentStatusTitle: 'Refunded',
              refundStatus: 'refunded',
              refundId: refundId,
              refundedAt: nowIso,
              isCompleted: true,
              updatedAt: nowIso,
            };
            if (refundAmount !== undefined) {
              updateData.refundAmount = refundAmount;
            }
            await orderRef.update(updateData);
            logger.info('Webhook updated order to refunded', {
              userId,
              orderId: cleanOrderId,
              refundId,
            });
          }
        }
      } else if (eventType === 'refund.created') {
        const refundEntity = payload?.refund?.entity;
        const notes = refundEntity?.notes || {};
        const userId = notes.userId;
        const cleanOrderId = notes.orderId;
        const refundId = refundEntity?.id;

        if (userId && cleanOrderId) {
          const orderRef = db
            .collection('users')
            .doc(userId)
            .collection('orders')
            .doc(cleanOrderId);

          const orderDoc = await orderRef.get();
          if (orderDoc.exists && orderDoc.data()?.refundStatus !== 'refunded') {
            const nowIso = new Date().toISOString();
            await orderRef.update({
              status: 'cancelled',
              statusTitle: 'Cancelled',
              refundStatus: 'pending',
              refundId: refundId,
              updatedAt: nowIso,
            });
            logger.info('Webhook recorded refund created (pending)', {
              userId,
              orderId: cleanOrderId,
              refundId,
            });
          }
        }
      } else if (eventType === 'refund.failed') {
        const refundEntity = payload?.refund?.entity;
        const notes = refundEntity?.notes || {};
        const userId = notes.userId;
        const cleanOrderId = notes.orderId;
        const reason = refundEntity?.error_description || 'Refund processing failed';

        if (userId && cleanOrderId) {
          const orderRef = db
            .collection('users')
            .doc(userId)
            .collection('orders')
            .doc(cleanOrderId);

          const orderDoc = await orderRef.get();
          if (orderDoc.exists) {
            await orderRef.update({
              refundStatus: 'failed',
              refundFailureReason: reason,
              updatedAt: new Date().toISOString(),
            });
            logger.info('Webhook recorded refund failure', {
              userId,
              orderId: cleanOrderId,
              reason,
            });
          }
        }
      }

      res.status(200).json({ status: 'ok' });
    } catch (err: any) {
      logger.error('Error processing webhook payload', { error: err?.message || err });
      res.status(500).send('Internal Server Error');
    }
  }
);
