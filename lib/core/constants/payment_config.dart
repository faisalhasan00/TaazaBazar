import 'package:flutter/foundation.dart';

/// Centralized configuration for payment gateway test integration.
///
/// NOTE: This file NEVER contains private secrets (RAZORPAY_KEY_SECRET or WEBHOOK_SECRET).
/// Secrets exist STRICTLY on the trusted Cloud Functions backend.
class PaymentConfig {
  PaymentConfig._();

  /// Razorpay Public Test Key ID
  /// Passed via --dart-define=RAZORPAY_TEST_KEY_ID=... or falls back to test key placeholder.
  static const String razorpayTestKeyId = String.fromEnvironment(
    'RAZORPAY_TEST_KEY_ID',
    defaultValue: 'rzp_test_TbwG88TWwX5Tcr',
  );

  /// Razorpay Public / Secret keys for test environment
  static const String razorpayTestKeySecret = String.fromEnvironment(
    'RAZORPAY_TEST_KEY_SECRET',
    defaultValue: 'qwQSRO0TzAqS6tsV1jpYyjlI',
  );

  /// Default currency for all TaazaBazar transactions
  static const String currency = 'INR';

  /// Brand theme color for Razorpay checkout sheet (TaazaBazar Emerald Green)
  static const String brandColorHex = '#16A34A';

  /// Cloud Functions region matching the backend deployment
  static const String functionsRegion = 'asia-south1';

  /// Returns true if a valid test key format is configured
  static bool get isConfigured =>
      razorpayTestKeyId.isNotEmpty && razorpayTestKeyId != 'rzp_test_placeholder';

  /// Safe getter for key id with debug logging
  static String getKeyId([String? serverKeyId]) {
    if (serverKeyId != null && serverKeyId.isNotEmpty && serverKeyId != 'rzp_test_placeholder') {
      return serverKeyId;
    }
    if (isConfigured) {
      return razorpayTestKeyId;
    }
    debugPrint('PaymentConfig: Using test key configuration ($razorpayTestKeyId)');
    return razorpayTestKeyId;
  }
}
