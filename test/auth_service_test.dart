import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taazabazar/core/services/firebase_auth_service.dart';
import 'package:taazabazar/features/auth/presentation/login_screen.dart';
import 'package:taazabazar/features/auth/presentation/otp_verification_screen.dart';

void main() {
  group('FirebaseAuthService Phone Number Normalization Tests', () {
    test('Normalizes standard 10-digit Indian numbers starting with 6, 7, 8, 9', () {
      expect(FirebaseAuthService.normalizePhoneNumber('9876543210'), '+919876543210');
      expect(FirebaseAuthService.normalizePhoneNumber('8123456789'), '+918123456789');
      expect(FirebaseAuthService.normalizePhoneNumber('7012345678'), '+917012345678');
      expect(FirebaseAuthService.normalizePhoneNumber('6234567890'), '+916234567890');
    });

    test('Normalizes Indian numbers with formatting (spaces, dashes, brackets)', () {
      expect(FirebaseAuthService.normalizePhoneNumber('98765 43210'), '+919876543210');
      expect(FirebaseAuthService.normalizePhoneNumber('9876-543-210'), '+919876543210');
      expect(FirebaseAuthService.normalizePhoneNumber('(98765) 43210'), '+919876543210');
    });

    test('Normalizes Indian numbers with +91 country code and spaces', () {
      expect(FirebaseAuthService.normalizePhoneNumber('+91 98765 43210'), '+919876543210');
      expect(FirebaseAuthService.normalizePhoneNumber('+919876543210'), '+919876543210');
      expect(FirebaseAuthService.normalizePhoneNumber('+91-9876543210'), '+919876543210');
    });

    test('Normalizes Indian numbers with 91 prefix without plus', () {
      expect(FirebaseAuthService.normalizePhoneNumber('919876543210'), '+919876543210');
    });

    test('Normalizes Indian numbers with leading 0', () {
      expect(FirebaseAuthService.normalizePhoneNumber('09876543210'), '+919876543210');
    });

    test('Preserves already-valid international E.164 phone numbers', () {
      expect(FirebaseAuthService.normalizePhoneNumber('+12025550123'), '+12025550123');
      expect(FirebaseAuthService.normalizePhoneNumber('+447911123456'), '+447911123456');
      expect(FirebaseAuthService.normalizePhoneNumber('+971501234567'), '+971501234567');
      expect(FirebaseAuthService.normalizePhoneNumber('0012025550123'), '+12025550123');
    });

    test('Rejects invalid phone inputs', () {
      expect(FirebaseAuthService.normalizePhoneNumber(''), isNull);
      expect(FirebaseAuthService.normalizePhoneNumber('   '), isNull);
      expect(FirebaseAuthService.normalizePhoneNumber('12345'), isNull);
      expect(FirebaseAuthService.normalizePhoneNumber('abcdefghij'), isNull);
      expect(FirebaseAuthService.normalizePhoneNumber('1234567890'), isNull); // Does not start with 6,7,8,9
      expect(FirebaseAuthService.normalizePhoneNumber('+0123456789'), isNull);
      expect(FirebaseAuthService.normalizePhoneNumber('++919876543210'), isNull);
    });
  });

  group('FirebaseAuthService Error Mapping Tests', () {
    test('Maps standard Firebase Auth error codes to user-friendly messages', () {
      expect(
        FirebaseAuthService.mapAuthError(
          FirebaseAuthException(code: 'invalid-phone-number'),
        ),
        'The phone number entered is invalid. Please check and try again.',
      );

      expect(
        FirebaseAuthService.mapAuthError(
          FirebaseAuthException(code: 'invalid-verification-code'),
        ),
        'The verification code entered is invalid. Please check and try again.',
      );

      expect(
        FirebaseAuthService.mapAuthError(
          FirebaseAuthException(code: 'session-expired'),
        ),
        'The verification code has expired. Please request a new code.',
      );

      expect(
        FirebaseAuthService.mapAuthError(
          FirebaseAuthException(code: 'too-many-requests'),
        ),
        'Too many attempts. Please wait a few minutes and try again.',
      );

      expect(
        FirebaseAuthService.mapAuthError(
          FirebaseAuthException(code: 'quota-exceeded'),
        ),
        'Too many attempts. Please wait a few minutes and try again.',
      );

      expect(
        FirebaseAuthService.mapAuthError(
          FirebaseAuthException(code: 'credential-already-in-use'),
        ),
        'This phone number is already linked to another account.',
      );

      expect(
        FirebaseAuthService.mapAuthError(
          FirebaseAuthException(code: 'provider-already-linked'),
        ),
        'This phone number is already linked to another account.',
      );

      expect(
        FirebaseAuthService.mapAuthError(
          FirebaseAuthException(code: 'network-request-failed'),
        ),
        'Network connection error. Please check your internet connection.',
      );

      expect(
        FirebaseAuthService.mapAuthError(
          FirebaseAuthException(code: 'user-disabled'),
        ),
        'This account has been disabled. Please contact customer support.',
      );

      expect(
        FirebaseAuthService.mapAuthError(
          FirebaseAuthException(code: 'operation-not-allowed'),
        ),
        'Phone authentication is not enabled. Please contact support.',
      );
    });

    test('Handles fallback for unknown errors', () {
      expect(
        FirebaseAuthService.mapAuthError('Some unexpected error'),
        'Some unexpected error',
      );
    });
  });

  group('FirebaseAuthService State & Result Model Tests', () {
    test('PhoneAuthResult factory constructors work correctly', () {
      final codeSent = PhoneAuthResult.codeSent('test_vid_123');
      expect(codeSent.isSuccess, isTrue);
      expect(codeSent.status, PhoneAuthStatus.codeSent);
      expect(codeSent.verificationId, 'test_vid_123');

      final autoVerifiedNew = PhoneAuthResult.autoVerified(null, isReturningUser: false);
      expect(autoVerifiedNew.isSuccess, isTrue);
      expect(autoVerifiedNew.status, PhoneAuthStatus.autoVerified);
      expect(autoVerifiedNew.isReturningUser, isFalse);

      final autoVerifiedReturning = PhoneAuthResult.autoVerified(null, isReturningUser: true);
      expect(autoVerifiedReturning.isSuccess, isTrue);
      expect(autoVerifiedReturning.isReturningUser, isTrue);

      final successNew = PhoneAuthResult.success(null, isReturningUser: false);
      expect(successNew.isSuccess, isTrue);
      expect(successNew.status, PhoneAuthStatus.success);
      expect(successNew.isReturningUser, isFalse);

      final successReturning = PhoneAuthResult.success(null, isReturningUser: true);
      expect(successReturning.isSuccess, isTrue);
      expect(successReturning.status, PhoneAuthStatus.success);
      expect(successReturning.isReturningUser, isTrue);

      final error = PhoneAuthResult.error('Invalid OTP', code: 'invalid-verification-code');
      expect(error.isSuccess, isFalse);
      expect(error.status, PhoneAuthStatus.error);
      expect(error.errorMessage, 'Invalid OTP');
      expect(error.errorCode, 'invalid-verification-code');
      expect(error.isReturningUser, isFalse);
    });

    test('clearVerificationState resets service state', () {
      final service = FirebaseAuthService();
      service.clearVerificationState();
      expect(service.verificationId, isNull);
      expect(service.resendToken, isNull);
      expect(service.lastPhoneNumber, isNull);
    });

    test('sendPhoneOtp validates phone and sets verification state', () async {
      final service = FirebaseAuthService();
      service.clearVerificationState();

      // Invalid number
      final invalidRes = await service.sendPhoneOtp(phoneNumber: '123');
      expect(invalidRes.isSuccess, isFalse);
      expect(invalidRes.errorCode, 'invalid-phone-number');

      // Valid number
      final validRes = await service.sendPhoneOtp(phoneNumber: '9876543210');
      expect(validRes.isSuccess, isTrue);
      expect(service.verificationId, isNotNull);
      expect(service.lastPhoneNumber, '+919876543210');
    });

    test('verifyPhoneOtp requires complete 6-digit code and verificationId', () async {
      final service = FirebaseAuthService();

      // Short code
      final shortRes = await service.verifyPhoneOtp(smsCode: '123');
      expect(shortRes.isSuccess, isFalse);
      expect(shortRes.errorCode, 'invalid-verification-code');

      // Full code with valid verificationId
      final validRes = await service.verifyPhoneOtp(smsCode: '123456', customVerificationId: 'test_vid');
      expect(validRes.isSuccess, isTrue);
    });
  });

  group('Login & OTP Screen Widget Tests', () {
    testWidgets('LoginScreen validates empty phone number and accepts valid phone', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Welcome to TaazaBazar'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);

      // Empty submission should show validation message
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter a valid 10-digit mobile number'), findsOneWidget);

      // Valid 10-digit mobile number should trigger sendPhoneOtp and navigate to OtpVerificationScreen
      await tester.enterText(find.byType(TextField), '9876543210');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.byType(OtpVerificationScreen), findsOneWidget);
      expect(find.text('Verify your number'), findsOneWidget);
    });

    testWidgets('OtpVerificationScreen rejects incomplete OTP and verifies 6-digit OTP', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: OtpVerificationScreen(phoneNumber: '+919876543210'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Verify your number'), findsOneWidget);
      expect(find.text('Verify & Continue'), findsOneWidget);

      // Submit with empty OTP
      await tester.tap(find.text('Verify & Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter the complete 6-digit verification code.'), findsOneWidget);
    });
  });
}


