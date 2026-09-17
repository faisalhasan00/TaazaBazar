import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as logger from 'firebase-functions/logger';
import { db } from '../config/firebase';
import { getRazorpayClient } from '../config/razorpay';
import { getRazorpayCredentials, razorpayKeyIdSecret, razorpayKeySecretSecret } from '../config/secrets';
import { validateOrderPricing, CartItemInput } from '../services/orderValidator';

interface CreateOrderRequest {
  orderId: string;
  items: CartItemInput[];
  couponCode?: string | null;
  deliveryAddress: string;
  deliveryLatitude?: number;
  deliveryLongitude?: number;
  slotDate?: string;
  timeSlot?: string;
}

export const createRazorpayOrder = onCall(
  {
    region: 'asia-south1',
    secrets: [razorpayKeyIdSecret, razorpayKeySecretSecret],
  },
  async (request) => {
    // 1. Authenticated user validation
    if (!request.auth || !request.auth.uid) {
      throw new HttpsError(
        'unauthenticated',
        'User must be logged in to create a payment order.'
      );
    }

    const userId = request.auth.uid;
    const data = request.data as CreateOrderRequest;

    if (!data || !data.orderId || !data.items || !Array.isArray(data.items)) {
      throw new HttpsError(
        'invalid-argument',
        'Missing required parameters: orderId and items list.'
      );
    }

    const cleanOrderId = data.orderId.replace('#', '').trim();
    logger.info('createRazorpayOrder initiated', {
      userId,
      orderId: cleanOrderId,
      itemsCount: data.items.length,
    });

    try {
      // 2. Anti-tampering pricing verification
      const pricing = await validateOrderPricing(data.items, data.couponCode);
      if (!pricing.isValid || pricing.amountInPaise <= 0) {
        throw new HttpsError(
          'invalid-argument',
          pricing.errorMessage || 'Invalid order items or zero payable amount.'
        );
      }

      // 3. Check for existing order / idempotency
      const orderRef = db
        .collection('users')
        .doc(userId)
        .collection('orders')
        .doc(cleanOrderId);

      const existingDoc = await orderRef.get();
      if (existingDoc.exists) {
        const existingData = existingDoc.data();
        if (existingData?.paymentStatus === 'paid') {
          throw new HttpsError(
            'already-exists',
            'This order has already been paid for.'
          );
        }

        // If a Razorpay order already exists for this pending order and amounts match, reuse it
        if (
          existingData?.gatewayOrderId &&
          existingData?.paymentStatus === 'pending' &&
          existingData?.grandTotal === pricing.grandTotal
        ) {
          logger.info('Reusing existing pending Razorpay order', {
            orderId: cleanOrderId,
            gatewayOrderId: existingData.gatewayOrderId,
          });

          const { keyId } = getRazorpayCredentials();
          return {
            success: true,
            orderId: `#${cleanOrderId}`,
            gatewayOrderId: existingData.gatewayOrderId,
            amount: pricing.grandTotal,
            amountInPaise: pricing.amountInPaise,
            currency: 'INR',
            keyId: keyId,
          };
        }
      }

      // 4. Create Razorpay Order via Razorpay API
      const razorpay = getRazorpayClient();
      const options = {
        amount: pricing.amountInPaise,
        currency: 'INR',
        receipt: `rcpt_${cleanOrderId.substring(0, 30)}`,
        notes: {
          userId: userId,
          orderId: cleanOrderId,
          app: 'TaazaBazar',
        },
      };

      const razorpayOrder = await razorpay.orders.create(options);
      const gatewayOrderId = razorpayOrder.id;

      logger.info('Razorpay Order created successfully', {
        userId,
        orderId: cleanOrderId,
        gatewayOrderId,
        amountInPaise: pricing.amountInPaise,
      });

      // 5. Store/merge pending order in Firestore with trusted gatewayOrderId
      const pendingOrderData: Record<string, any> = {
        orderId: `#${cleanOrderId}`,
        orderDate: new Date().toISOString(),
        slotDate: data.slotDate || 'Today',
        timeSlot: data.timeSlot || '6:00 AM – 8:00 AM',
        status: 'placed',
        statusTitle: 'Order Placed',
        items: data.items,
        itemTotal: pricing.itemTotal,
        deliveryFee: pricing.deliveryFee,
        discount: pricing.discount,
        grandTotal: pricing.grandTotal,
        paymentMethod: 'upi',
        paymentMethodTitle: 'Online Payment',
        paymentStatus: 'pending',
        paymentStatusTitle: 'Pending',
        paymentGateway: 'razorpay',
        gatewayOrderId: gatewayOrderId,
        deliveryAddress: data.deliveryAddress || '',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      };

      if (typeof data.deliveryLatitude === 'number') {
        pendingOrderData.deliveryLatitude = data.deliveryLatitude;
      }
      if (typeof data.deliveryLongitude === 'number') {
        pendingOrderData.deliveryLongitude = data.deliveryLongitude;
      }

      await orderRef.set(pendingOrderData, { merge: true });

      const { keyId } = getRazorpayCredentials();

      return {
        success: true,
        orderId: `#${cleanOrderId}`,
        gatewayOrderId: gatewayOrderId,
        amount: pricing.grandTotal,
        amountInPaise: pricing.amountInPaise,
        currency: 'INR',
        keyId: keyId,
      };
    } catch (error: any) {
      if (error instanceof HttpsError) {
        throw error;
      }
      logger.error('Error creating Razorpay order', {
        userId,
        orderId: cleanOrderId,
        error: error?.message || error,
      });
      throw new HttpsError(
        'internal',
        'Unable to initialize payment. Please try again later.'
      );
    }
  }
);
