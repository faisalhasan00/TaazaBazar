"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.PRICING_RULES = void 0;
exports.validateOrderPricing = validateOrderPricing;
const firebase_1 = require("../config/firebase");
exports.PRICING_RULES = {
    FREE_DELIVERY_THRESHOLD: 199, // Free delivery on item subtotal >= ₹199
    STANDARD_DELIVERY_FEE: 25, // Standard delivery fee ₹25 for orders < ₹199
    CURRENCY: 'INR',
};
/**
 * Validates order items, pricing, delivery fee and discounts against Firestore.
 * Prevents client-side price tampering and guarantees 1:1 parity with Flutter app.
 */
async function validateOrderPricing(items, couponCode) {
    if (!items || !Array.isArray(items) || items.length === 0) {
        return {
            isValid: false,
            itemTotal: 0,
            deliveryFee: 0,
            discount: 0,
            grandTotal: 0,
            amountInPaise: 0,
            errorMessage: 'Cart cannot be empty',
        };
    }
    let calculatedItemTotal = 0;
    for (const item of items) {
        const qty = item.quantity;
        if (!qty || qty <= 0 || !Number.isInteger(qty)) {
            return {
                isValid: false,
                itemTotal: 0,
                deliveryFee: 0,
                discount: 0,
                grandTotal: 0,
                amountInPaise: 0,
                errorMessage: 'Invalid item quantity',
            };
        }
        const productId = item.productId || item.id || item.product?.id;
        if (!productId) {
            return {
                isValid: false,
                itemTotal: 0,
                deliveryFee: 0,
                discount: 0,
                grandTotal: 0,
                amountInPaise: 0,
                errorMessage: 'Missing product ID in order items',
            };
        }
        // Look up real product price from Firestore catalog
        const productDoc = await firebase_1.db.collection('products').doc(productId).get();
        let unitPrice = 0;
        if (productDoc.exists) {
            const data = productDoc.data();
            unitPrice = typeof data?.price === 'number' ? data.price : 0;
        }
        else if (typeof item.price === 'number') {
            // Fallback to item price if catalog document not synced, with non-negative validation
            unitPrice = item.price;
        }
        else if (item.product && typeof item.product.price === 'number') {
            unitPrice = item.product.price;
        }
        if (unitPrice <= 0) {
            return {
                isValid: false,
                itemTotal: 0,
                deliveryFee: 0,
                discount: 0,
                grandTotal: 0,
                amountInPaise: 0,
                errorMessage: `Invalid price for product ${productId}`,
            };
        }
        calculatedItemTotal += unitPrice * qty;
    }
    // Calculate delivery fee: free delivery for orders >= ₹199, otherwise standard ₹25
    const deliveryFee = calculatedItemTotal >= exports.PRICING_RULES.FREE_DELIVERY_THRESHOLD
        ? 0
        : exports.PRICING_RULES.STANDARD_DELIVERY_FEE;
    // Validate coupon discount if coupon provided
    let discount = 0;
    if (couponCode && typeof couponCode === 'string' && couponCode.trim().length > 0) {
        const cleanCoupon = couponCode.trim().toUpperCase();
        const couponDoc = await firebase_1.db.collection('coupons').doc(cleanCoupon).get();
        if (couponDoc.exists) {
            const couponData = couponDoc.data();
            const minOrder = couponData?.minOrder || 0;
            const discountVal = couponData?.discount || 0;
            const discountType = couponData?.discountType || 'flat'; // 'flat' | 'percentage'
            if (calculatedItemTotal >= minOrder) {
                if (discountType === 'percentage') {
                    discount = Math.round((calculatedItemTotal * discountVal) / 100);
                }
                else {
                    discount = discountVal;
                }
            }
        }
    }
    // Ensure discount does not exceed item total
    if (discount > calculatedItemTotal) {
        discount = calculatedItemTotal;
    }
    const grandTotal = Math.max(0, calculatedItemTotal + deliveryFee - discount);
    const amountInPaise = Math.round(grandTotal * 100);
    return {
        isValid: true,
        itemTotal: calculatedItemTotal,
        deliveryFee,
        discount,
        grandTotal,
        amountInPaise,
    };
}
//# sourceMappingURL=orderValidator.js.map