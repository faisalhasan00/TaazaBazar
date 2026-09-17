import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/payment_config.dart';
import '../../../core/services/firebase_auth_service.dart';
import '../../cart/domain/cart_item.dart';

/// Result from createRazorpayOrder Cloud Function call
class RazorpayOrderResult {
  final bool success;
  final String orderId;
  final String? gatewayOrderId;
  final double amount;
  final int amountInPaise;
  final String currency;
  final String? keyId;
  final String? errorMessage;

  const RazorpayOrderResult({
    required this.success,
    required this.orderId,
    this.gatewayOrderId,
    this.amount = 0.0,
    this.amountInPaise = 0,
    this.currency = 'INR',
    this.keyId,
    this.errorMessage,
  });

  factory RazorpayOrderResult.fromMap(Map<dynamic, dynamic> map) {
    return RazorpayOrderResult(
      success: map['success'] == true,
      orderId: map['orderId']?.toString() ?? '',
      gatewayOrderId: map['gatewayOrderId']?.toString(),
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      amountInPaise: (map['amountInPaise'] as num?)?.toInt() ?? 0,
      currency: map['currency']?.toString() ?? 'INR',
      keyId: map['keyId']?.toString(),
      errorMessage: map['errorMessage']?.toString(),
    );
  }

  factory RazorpayOrderResult.error(String message, [String orderId = '']) {
    return RazorpayOrderResult(
      success: false,
      orderId: orderId,
      errorMessage: message,
    );
  }
}

/// Result from verifyRazorpaySignature Cloud Function call
class RazorpayVerificationResult {
  final bool success;
  final String orderId;
  final String paymentStatus;
  final String? message;
  final String? errorMessage;
  final DateTime? paidAt;

  const RazorpayVerificationResult({
    required this.success,
    required this.orderId,
    this.paymentStatus = 'pending',
    this.message,
    this.errorMessage,
    this.paidAt,
  });

  factory RazorpayVerificationResult.fromMap(Map<dynamic, dynamic> map) {
    return RazorpayVerificationResult(
      success: map['success'] == true,
      orderId: map['orderId']?.toString() ?? '',
      paymentStatus: map['paymentStatus']?.toString() ??
          (map['success'] == true ? 'paid' : 'pending'),
      message: map['message']?.toString(),
      errorMessage: map['errorMessage']?.toString(),
      paidAt: map['paidAt'] != null
          ? DateTime.tryParse(map['paidAt'].toString())
          : null,
    );
  }

  factory RazorpayVerificationResult.error(String message, [String orderId = '']) {
    return RazorpayVerificationResult(
      success: false,
      orderId: orderId,
      errorMessage: message,
    );
  }
}

/// Result from cancelAndRefundOrder Cloud Function call
class CancelOrderResult {
  final bool success;
  final String orderId;
  final String status;
  final String paymentStatus;
  final String? refundStatus;
  final String? refundId;
  final double? refundAmount;
  final String? message;
  final String? errorMessage;
  final DateTime? refundedAt;
  final DateTime? cancelledAt;

  const CancelOrderResult({
    required this.success,
    required this.orderId,
    this.status = 'placed',
    this.paymentStatus = 'pending',
    this.refundStatus,
    this.refundId,
    this.refundAmount,
    this.message,
    this.errorMessage,
    this.refundedAt,
    this.cancelledAt,
  });

  factory CancelOrderResult.fromMap(Map<dynamic, dynamic> map) {
    return CancelOrderResult(
      success: map['success'] == true,
      orderId: map['orderId']?.toString() ?? '',
      status: map['status']?.toString() ?? 'cancelled',
      paymentStatus: map['paymentStatus']?.toString() ?? 'cancelled',
      refundStatus: map['refundStatus']?.toString(),
      refundId: map['refundId']?.toString(),
      refundAmount: (map['refundAmount'] as num?)?.toDouble(),
      message: map['message']?.toString(),
      errorMessage: map['errorMessage']?.toString(),
      refundedAt: map['refundedAt'] != null
          ? DateTime.tryParse(map['refundedAt'].toString())
          : null,
      cancelledAt: map['cancelledAt'] != null
          ? DateTime.tryParse(map['cancelledAt'].toString())
          : null,
    );
  }

  factory CancelOrderResult.error(String message, [String orderId = '']) {
    return CancelOrderResult(
      success: false,
      orderId: orderId,
      errorMessage: message,
    );
  }
}

/// Secure Payment Service managing Razorpay Flutter SDK interactions
class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  Razorpay? _razorpay;

  // Callbacks
  Function(PaymentSuccessResponse response)? _onPaymentSuccess;
  Function(PaymentFailureResponse response)? _onPaymentError;
  Function(ExternalWalletResponse response)? _onExternalWallet;

  FirebaseFunctions get _functions {
    return FirebaseFunctions.instanceFor(region: PaymentConfig.functionsRegion);
  }

  /// Initialize Razorpay instance and register event listeners
  void initialize({
    required Function(PaymentSuccessResponse response) onPaymentSuccess,
    required Function(PaymentFailureResponse response) onPaymentError,
    Function(ExternalWalletResponse response)? onExternalWallet,
  }) {
    _onPaymentSuccess = onPaymentSuccess;
    _onPaymentError = onPaymentError;
    _onExternalWallet = onExternalWallet;

    _razorpay ??= Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint('PaymentService: Razorpay SDK payment success callback received: paymentId=${response.paymentId}');
    _onPaymentSuccess?.call(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('PaymentService: Razorpay SDK payment error callback: code=${response.code}, message=${response.message}');
    _onPaymentError?.call(response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('PaymentService: Razorpay SDK external wallet selected: ${response.walletName}');
    _onExternalWallet?.call(response);
  }

  /// Calls trusted Cloud Function createRazorpayOrder to create a verified Razorpay order
  /// Calls trusted Cloud Function createRazorpayOrder, falling back to direct Razorpay API if Functions are unreachable
  Future<RazorpayOrderResult> createRazorpayOrder({
    required String orderId,
    required List<CartItem> items,
    String? couponCode,
    required String deliveryAddress,
    double? deliveryLatitude,
    double? deliveryLongitude,
    String? slotDate,
    String? timeSlot,
  }) async {
    final uid = FirebaseAuthService().currentUserId;
    if (uid == null || uid.isEmpty) {
      return RazorpayOrderResult.error(
        'User is not authenticated. Please log in to complete checkout.',
        orderId,
      );
    }

    try {
      final callable = _functions.httpsCallable('createRazorpayOrder');

      final payload = {
        'orderId': orderId,
        'items': items.map((i) => i.toMap()).toList(),
        'couponCode': couponCode,
        'deliveryAddress': deliveryAddress,
        'deliveryLatitude': deliveryLatitude,
        'deliveryLongitude': deliveryLongitude,
        'slotDate': slotDate,
        'timeSlot': timeSlot,
      };

      debugPrint('PaymentService: Invoking createRazorpayOrder Cloud Function for order $orderId');
      final result = await callable.call(payload);

      if (result.data is Map) {
        final res = RazorpayOrderResult.fromMap(result.data as Map);
        debugPrint('PaymentService: createRazorpayOrder returned gatewayOrderId=${res.gatewayOrderId}');
        return res;
      }
    } catch (e) {
      debugPrint('PaymentService: Cloud Function createRazorpayOrder failed/offline: $e. Falling back to direct Razorpay API...');
    }

    // Direct Razorpay REST API fallback
    return _createDirectRazorpayOrder(
      orderId: orderId,
      items: items,
      couponCode: couponCode,
      deliveryAddress: deliveryAddress,
    );
  }

  /// Direct REST call to create Razorpay order in test/live mode
  Future<RazorpayOrderResult> _createDirectRazorpayOrder({
    required String orderId,
    required List<CartItem> items,
    String? couponCode,
    required String deliveryAddress,
  }) async {
    try {
      final itemTotal = items.fold(0.0, (sum, i) => sum + i.subtotal);
      final deliveryFee = itemTotal >= AppConstants.freeDeliveryThreshold
          ? 0.0
          : AppConstants.standardDeliveryFee;
      final grandTotal = (itemTotal + deliveryFee).clamp(0.0, double.infinity);
      final amountInPaise = (grandTotal * 100).round();
      final keyId = PaymentConfig.getKeyId();
      final keySecret = PaymentConfig.razorpayTestKeySecret;

      final cleanOrderId = orderId.replaceAll('#', '').trim();
      final basicAuth = 'Basic ${base64Encode(utf8.encode('$keyId:$keySecret'))}';
      final url = Uri.parse('https://api.razorpay.com/v1/orders');

      final response = await http.post(
        url,
        headers: {
          'Authorization': basicAuth,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': amountInPaise,
          'currency': PaymentConfig.currency,
          'receipt': 'rcpt_${cleanOrderId.length > 25 ? cleanOrderId.substring(0, 25) : cleanOrderId}',
          'notes': {
            'orderId': cleanOrderId,
            'app': AppConstants.appName,
          },
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final gatewayOrderId = data['id']?.toString() ?? '';
        debugPrint('PaymentService: Direct Razorpay Order created successfully: gatewayOrderId=$gatewayOrderId');
        return RazorpayOrderResult(
          success: true,
          orderId: orderId,
          gatewayOrderId: gatewayOrderId,
          amount: grandTotal,
          amountInPaise: amountInPaise,
          currency: PaymentConfig.currency,
          keyId: keyId,
        );
      } else {
        debugPrint('PaymentService: Direct Razorpay API error (${response.statusCode}): ${response.body}');
        return RazorpayOrderResult.error(
          'Unable to initialize payment: ${response.body}',
          orderId,
        );
      }
    } catch (e) {
      debugPrint('PaymentService: Direct Razorpay API exception: $e');
      return RazorpayOrderResult.error(
        'Unable to connect to payment gateway. Please check your network.',
        orderId,
      );
    }
  }

  /// Calls Cloud Function verifyRazorpaySignature or falls back to client-side HMAC verification
  Future<RazorpayVerificationResult> verifyPaymentSignature({
    required String orderId,
    required String gatewayOrderId,
    required String gatewayPaymentId,
    required String signature,
  }) async {
    final uid = FirebaseAuthService().currentUserId;
    if (uid == null || uid.isEmpty) {
      return RazorpayVerificationResult.error(
        'User is not authenticated. Please log in to complete verification.',
        orderId,
      );
    }

    try {
      final callable = _functions.httpsCallable('verifyRazorpaySignature');

      final payload = {
        'orderId': orderId,
        'gatewayOrderId': gatewayOrderId,
        'gatewayPaymentId': gatewayPaymentId,
        'signature': signature,
      };

      debugPrint(
        'PaymentService: Invoking verifyRazorpaySignature Cloud Function for order $orderId '
        '(gatewayOrderId=$gatewayOrderId, gatewayPaymentId=$gatewayPaymentId)',
      );
      final result = await callable.call(payload);

      if (result.data is Map) {
        final res = RazorpayVerificationResult.fromMap(result.data as Map);
        debugPrint(
          'PaymentService: verifyRazorpaySignature returned success=${res.success}, '
          'status=${res.paymentStatus}',
        );
        return res;
      }
    } catch (e) {
      debugPrint('PaymentService: Cloud Function verifyRazorpaySignature failed/offline: $e. Falling back to local cryptographic HMAC-SHA256 verification...');
    }

    // Direct HMAC-SHA256 verification
    return _verifyDirectSignature(
      orderId: orderId,
      gatewayOrderId: gatewayOrderId,
      gatewayPaymentId: gatewayPaymentId,
      signature: signature,
    );
  }

  /// Direct HMAC-SHA256 signature verification using the secret
  RazorpayVerificationResult _verifyDirectSignature({
    required String orderId,
    required String gatewayOrderId,
    required String gatewayPaymentId,
    required String signature,
  }) {
    try {
      final keySecret = PaymentConfig.razorpayTestKeySecret;
      final payload = '$gatewayOrderId|$gatewayPaymentId';
      final hmacSha256 = Hmac(sha256, utf8.encode(keySecret));
      final digest = hmacSha256.convert(utf8.encode(payload));
      final generatedSignature = digest.toString();

      final isValid = generatedSignature.toLowerCase() == signature.toLowerCase();
      debugPrint('PaymentService: HMAC-SHA256 verification result: $isValid');

      if (isValid) {
        return RazorpayVerificationResult(
          success: true,
          orderId: orderId,
          paymentStatus: 'paid',
          message: 'Payment verified successfully',
          paidAt: DateTime.now(),
        );
      } else {
        return RazorpayVerificationResult(
          success: false,
          orderId: orderId,
          paymentStatus: 'failed',
          errorMessage: 'Cryptographic signature mismatch.',
        );
      }
    } catch (e) {
      debugPrint('PaymentService: HMAC verification error: $e');
      return RazorpayVerificationResult.error(
        'Payment verification failed: $e',
        orderId,
      );
    }
  }

  /// Calls trusted Cloud Function cancelAndRefundOrder to cancel order & trigger refund
  Future<CancelOrderResult> cancelOrder({
    required String orderId,
    String? reason,
  }) async {
    final uid = FirebaseAuthService().currentUserId;
    if (uid == null || uid.isEmpty) {
      return CancelOrderResult.error(
        'User is not authenticated. Please log in to cancel order.',
        orderId,
      );
    }

    try {
      final callable = _functions.httpsCallable('cancelAndRefundOrder');
      final payload = {
        'orderId': orderId,
        'reason': reason ?? 'Customer requested cancellation',
      };

      debugPrint('PaymentService: Invoking cancelAndRefundOrder Cloud Function for order $orderId');
      final result = await callable.call(payload);

      if (result.data is Map) {
        final res = CancelOrderResult.fromMap(result.data as Map);
        debugPrint('PaymentService: cancelAndRefundOrder returned status=${res.status}, refundStatus=${res.refundStatus}');
        return res;
      } else {
        return CancelOrderResult.error('Malformed response from cancellation server.', orderId);
      }
    } catch (e) {
      debugPrint('PaymentService: cancelOrder error: $e');
      final errStr = e.toString();
      final msg = errStr.contains('Cannot cancel order')
          ? errStr.replaceAll(RegExp(r'\[.*?\]'), '').trim()
          : 'Unable to process order cancellation at this time. Please try again.';
      return CancelOrderResult.error(msg, orderId);
    }
  }

  /// Opens the Razorpay Checkout sheet in Test Mode
  void openCheckout({
    required String orderId,
    required String gatewayOrderId,
    required int amountInPaise,
    String? keyId,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
  }) {
    if (_razorpay == null) {
      throw StateError('PaymentService must be initialized before calling openCheckout()');
    }

    final effectiveKeyId = PaymentConfig.getKeyId(keyId);

    final options = {
      'key': effectiveKeyId,
      'amount': amountInPaise,
      'name': AppConstants.appName,
      'description': 'Order $orderId',
      'order_id': gatewayOrderId,
      'currency': PaymentConfig.currency,
      'prefill': {
        'contact': customerPhone ?? '',
        'email': customerEmail ?? '',
        'name': customerName ?? 'Customer',
      },
      'theme': {
        'color': PaymentConfig.brandColorHex,
      },
      'retry': {
        'enabled': true,
        'max_count': 1,
      },
      'send_sms_hash': false,
    };

    debugPrint('PaymentService: Opening Razorpay Test Checkout with order_id=$gatewayOrderId, key=$effectiveKeyId');
    _razorpay!.open(options);
  }

  /// Cleans up listeners
  void dispose() {
    _razorpay?.clear();
    _razorpay = null;
    _onPaymentSuccess = null;
    _onPaymentError = null;
    _onExternalWallet = null;
  }
}
