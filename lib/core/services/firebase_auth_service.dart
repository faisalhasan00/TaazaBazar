import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

/// Enum representing the state of phone authentication
enum PhoneAuthStatus {
  idle,
  codeSent,
  autoVerified,
  success,
  error,
}

/// Typed result object for Phone Authentication operations
class PhoneAuthResult {
  final bool isSuccess;
  final PhoneAuthStatus status;
  final String? verificationId;
  final String? errorMessage;
  final String? errorCode;
  final User? user;
  final bool isReturningUser;

  const PhoneAuthResult({
    required this.isSuccess,
    required this.status,
    this.verificationId,
    this.errorMessage,
    this.errorCode,
    this.user,
    this.isReturningUser = false,
  });

  factory PhoneAuthResult.codeSent(String verificationId) => PhoneAuthResult(
        isSuccess: true,
        status: PhoneAuthStatus.codeSent,
        verificationId: verificationId,
      );

  factory PhoneAuthResult.autoVerified(User? user, {bool isReturningUser = false}) => PhoneAuthResult(
        isSuccess: true,
        status: PhoneAuthStatus.autoVerified,
        user: user,
        isReturningUser: isReturningUser,
      );

  factory PhoneAuthResult.success(User? user, {bool isReturningUser = false}) => PhoneAuthResult(
        isSuccess: true,
        status: PhoneAuthStatus.success,
        user: user,
        isReturningUser: isReturningUser,
      );

  factory PhoneAuthResult.error(String message, {String? code}) => PhoneAuthResult(
        isSuccess: false,
        status: PhoneAuthStatus.error,
        errorMessage: message,
        errorCode: code,
      );
}

/// Service managing user authentication via Firebase Auth with safe anonymous account linking
class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  FirebaseAuth? get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  // --- Phone Authentication State ---
  String? _verificationId;
  int? _resendToken;
  String? _lastPhoneNumber;

  /// Stored verification ID from Firebase codeSent
  String? get verificationId => _verificationId;

  /// Stored resend token for requesting new OTP
  int? get resendToken => _resendToken;

  /// Last normalized phone number requested
  String? get lastPhoneNumber => _lastPhoneNumber;

  /// Clear any active phone verification state
  void clearVerificationState() {
    _verificationId = null;
    _resendToken = null;
    _lastPhoneNumber = null;
  }

  /// Normalizes phone number to standard E.164 format (+91 for 10-digit Indian numbers)
  static String? normalizePhoneNumber(String phone) {
    final trimmed = phone.trim();
    if (trimmed.isEmpty) return null;

    // Strip whitespace, hyphens, brackets, dots
    final cleaned = trimmed.replaceAll(RegExp(r'[\s\-\(\)\.]'), '');

    // 1. Valid E.164 format starting with '+' (+ followed by 7-15 digits)
    if (cleaned.startsWith('+')) {
      final e164Regex = RegExp(r'^\+[1-9]\d{6,14}$');
      if (e164Regex.hasMatch(cleaned)) {
        return cleaned;
      }
      return null;
    }

    // 2. International prefix 00 (e.g. 00919876543210 -> +919876543210)
    if (cleaned.startsWith('00') && cleaned.length > 8) {
      final withPlus = '+${cleaned.substring(2)}';
      final e164Regex = RegExp(r'^\+[1-9]\d{6,14}$');
      if (e164Regex.hasMatch(withPlus)) {
        return withPlus;
      }
      return null;
    }

    // 3. Indian number with leading 0 (e.g. 09876543210 -> +919876543210)
    if (cleaned.startsWith('0') && cleaned.length == 11) {
      final tenDigits = cleaned.substring(1);
      if (RegExp(r'^[6-9]\d{9}$').hasMatch(tenDigits)) {
        return '+91$tenDigits';
      }
      return null;
    }

    // 4. Standard 10-digit Indian mobile number starting with 6, 7, 8, or 9
    if (RegExp(r'^[6-9]\d{9}$').hasMatch(cleaned)) {
      return '+91$cleaned';
    }

    // 5. 12-digit Indian number with country code without '+' (e.g. 919876543210)
    if (cleaned.startsWith('91') && cleaned.length == 12) {
      final tenDigits = cleaned.substring(2);
      if (RegExp(r'^[6-9]\d{9}$').hasMatch(tenDigits)) {
        return '+$cleaned';
      }
      return null;
    }

    return null;
  }

  /// Maps Firebase Auth exception codes to clean user-friendly error messages
  static String mapAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-phone-number':
          return 'The phone number entered is invalid. Please check and try again.';
        case 'invalid-verification-code':
          return 'The verification code entered is invalid. Please check and try again.';
        case 'session-expired':
          return 'The verification code has expired. Please request a new code.';
        case 'quota-exceeded':
        case 'too-many-requests':
          return 'Too many attempts. Please wait a few minutes and try again.';
        case 'credential-already-in-use':
        case 'provider-already-linked':
          return 'This phone number is already linked to another account.';
        case 'network-request-failed':
          return 'Network connection error. Please check your internet connection.';
        case 'user-disabled':
          return 'This account has been disabled. Please contact customer support.';
        case 'operation-not-allowed':
          return 'Phone authentication is not enabled. Please contact support.';
        default:
          final msg = error.message ?? '';
          if (msg.contains('BILLING_NOT_ENABLED') || error.code.contains('billing')) {
            return 'SMS service requires Firebase Blaze (Pay-as-you-go) plan to send real SMS. You can also add your phone number as a test number in Firebase Console.';
          }
          return error.message ?? 'Authentication failed. Please try again.';
      }
    }
    final errStr = error?.toString() ?? '';
    if (errStr.contains('BILLING_NOT_ENABLED')) {
      return 'SMS service requires Firebase Blaze plan to send real SMS. Please enable billing in Firebase Console or use a test phone number.';
    }
    return error?.toString() ?? 'An unexpected authentication error occurred.';
  }

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges {
    final auth = _auth;
    if (auth != null) {
      return auth.authStateChanges();
    }
    return Stream.value(null);
  }

  /// Current authenticated user
  User? get currentUser {
    try {
      return _auth?.currentUser;
    } catch (_) {
      return null;
    }
  }

  /// Current user UID or null if not authenticated
  String? get currentUserId => currentUser?.uid;

  /// Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  /// Check if active session is an anonymous guest user
  bool get isAnonymous => currentUser?.isAnonymous ?? false;

  /// Current user display name or fallback
  String get displayName => currentUser?.displayName ?? 'User';

  /// Current user phone number or fallback
  String get phoneNumber => currentUser?.phoneNumber ?? '';

  /// Ensure active user session (reuses existing user or signs in anonymously)
  Future<User?> ensureAuthenticated() async {
    try {
      final existing = currentUser;
      if (existing != null) {
        debugPrint('FirebaseAuthService: Active session restored for UID: ${existing.uid} (isAnonymous: ${existing.isAnonymous})');
        NotificationService().registerDeviceToken(existing.uid);
        return existing;
      }
      debugPrint('FirebaseAuthService: Creating anonymous guest session...');
      final credential = await signInAnonymously();
      if (credential?.user != null) {
        debugPrint('FirebaseAuthService: Anonymous session created for UID: ${credential!.user!.uid}');
        NotificationService().registerDeviceToken(credential.user!.uid);
        return credential.user;
      }
    } catch (e) {
      debugPrint('FirebaseAuthService: ensureAuthenticated notice: $e');
    }
    return currentUser;
  }

  /// Sign in anonymously for guest checkout
  Future<UserCredential?> signInAnonymously() async {
    try {
      return await _auth?.signInAnonymously();
    } catch (e) {
      debugPrint('FirebaseAuthService: Guest sign-in error: $e');
      return null;
    }
  }

  /// Send Phone OTP using Firebase Phone Authentication
  Future<PhoneAuthResult> sendPhoneOtp({
    required String phoneNumber,
    void Function(String verificationId)? onCodeSent,
    void Function(String error)? onError,
    void Function(User? user)? onAutoVerified,
  }) async {
    final normalizedPhone = normalizePhoneNumber(phoneNumber);
    if (normalizedPhone == null) {
      const msg = 'Please enter a valid 10-digit mobile number.';
      onError?.call(msg);
      return PhoneAuthResult.error(msg, code: 'invalid-phone-number');
    }

    _lastPhoneNumber = normalizedPhone;
    final auth = _auth;

    // Graceful offline/testing fallback when native Firebase Auth instance is not loaded
    if (auth == null) {
      debugPrint('FirebaseAuthService: Auth instance unavailable (offline/test mode)');
      _verificationId = 'test_verification_id';
      onCodeSent?.call('test_verification_id');
      return PhoneAuthResult.codeSent('test_verification_id');
    }

    final completer = Completer<PhoneAuthResult>();

    try {
      await auth.verifyPhoneNumber(
        phoneNumber: normalizedPhone,
        forceResendingToken: _resendToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint('FirebaseAuthService: Phone auto-verification completed');
          try {
            final user = auth.currentUser;
            if (user != null && user.isAnonymous) {
              debugPrint('FirebaseAuthService: Linking auto-verified credential to anonymous UID: ${user.uid}');
              try {
                final userCred = await user.linkWithCredential(credential);
                onAutoVerified?.call(userCred.user);
                if (!completer.isCompleted) {
                  completer.complete(PhoneAuthResult.autoVerified(userCred.user, isReturningUser: false));
                }
              } on FirebaseAuthException catch (linkError) {
                if (linkError.code == 'credential-already-in-use') {
                  debugPrint('FirebaseAuthService: Auto-verification returning user detected. Signing in with credential...');
                  final userCred = await auth.signInWithCredential(credential);
                  onAutoVerified?.call(userCred.user);
                  if (!completer.isCompleted) {
                    completer.complete(PhoneAuthResult.autoVerified(userCred.user, isReturningUser: true));
                  }
                } else {
                  rethrow;
                }
              }
            } else {
              final userCred = await auth.signInWithCredential(credential);
              onAutoVerified?.call(userCred.user);
              if (!completer.isCompleted) {
                completer.complete(PhoneAuthResult.autoVerified(userCred.user, isReturningUser: true));
              }
            }
          } catch (e) {
            debugPrint('FirebaseAuthService: Auto-verification linking notice: $e');
            final err = mapAuthError(e);
            if (!completer.isCompleted) {
              completer.complete(PhoneAuthResult.error(err, code: e is FirebaseAuthException ? e.code : null));
            }
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('FirebaseAuthService: Phone verification failed: ${e.code} - ${e.message}');
          final err = mapAuthError(e);
          onError?.call(err);
          if (!completer.isCompleted) {
            completer.complete(PhoneAuthResult.error(err, code: e.code));
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          debugPrint('FirebaseAuthService: Verification code sent: $verificationId');
          _verificationId = verificationId;
          _resendToken = resendToken;
          onCodeSent?.call(verificationId);
          if (!completer.isCompleted) {
            completer.complete(PhoneAuthResult.codeSent(verificationId));
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint('FirebaseAuthService: Auto retrieval timeout for: $verificationId');
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      debugPrint('FirebaseAuthService: verifyPhoneNumber exception: $e');
      final err = mapAuthError(e);
      onError?.call(err);
      if (!completer.isCompleted) {
        completer.complete(PhoneAuthResult.error(err, code: e is FirebaseAuthException ? e.code : null));
      }
    }

    return completer.future;
  }

  /// Verify Phone OTP and safely link with anonymous account to preserve UID.
  /// If the phone credential already belongs to an existing account (credential-already-in-use),
  /// safely signs in using the existing account without merging or deleting data.
  Future<PhoneAuthResult> verifyPhoneOtp({
    required String smsCode,
    String? customVerificationId,
  }) async {
    final vid = customVerificationId ?? _verificationId;
    if (vid == null || vid.isEmpty) {
      return PhoneAuthResult.error(
        'Verification session not found. Please request a new code.',
        code: 'session-expired',
      );
    }

    final code = smsCode.trim();
    if (code.length < 6) {
      return PhoneAuthResult.error(
        'Please enter the complete 6-digit verification code.',
        code: 'invalid-verification-code',
      );
    }

    final auth = _auth;
    // Graceful fallback in offline/test environment
    if (auth == null) {
      debugPrint('FirebaseAuthService: Auth instance unavailable (offline/test mode verification)');
      return PhoneAuthResult.success(null);
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: vid,
        smsCode: code,
      );

      final user = auth.currentUser;

      // 1. If anonymous user, first attempt to link credential to preserve the exact same UID!
      if (user != null && user.isAnonymous) {
        final beforeUid = user.uid;
        debugPrint('FirebaseAuthService: Attempting to link phone credential to anonymous UID: $beforeUid');
        try {
          final userCred = await user.linkWithCredential(credential);
          final afterUid = userCred.user?.uid;
          debugPrint('FirebaseAuthService: Successfully linked. UID preserved: ${beforeUid == afterUid} ($afterUid)');
          return PhoneAuthResult.success(userCred.user, isReturningUser: false);
        } on FirebaseAuthException catch (linkError) {
          if (linkError.code == 'credential-already-in-use') {
            debugPrint('FirebaseAuthService: Phone number is already registered to an existing account. Switching to returning-user sign-in path...');
            try {
              final returningCred = await auth.signInWithCredential(credential);
              final returningUid = returningCred.user?.uid;
              debugPrint('FirebaseAuthService: Returning user signed in successfully. Active UID: $returningUid');
              return PhoneAuthResult.success(returningCred.user, isReturningUser: true);
            } on FirebaseAuthException catch (signInError) {
              debugPrint('FirebaseAuthService: Returning user sign-in failed: ${signInError.code} - ${signInError.message}');
              final errorMsg = mapAuthError(signInError);
              return PhoneAuthResult.error(errorMsg, code: signInError.code);
            }
          }
          rethrow;
        }
      } else if (user != null && !user.isAnonymous) {
        debugPrint('FirebaseAuthService: User is already permanent with UID: ${user.uid}');
        return PhoneAuthResult.success(user, isReturningUser: true);
      } else {
        // No active user, sign in directly with phone credential
        debugPrint('FirebaseAuthService: No active user session. Signing in directly with phone credential...');
        try {
          final directCred = await auth.signInWithCredential(credential);
          final directUid = directCred.user?.uid;
          debugPrint('FirebaseAuthService: Direct sign-in successful with UID: $directUid');
          return PhoneAuthResult.success(directCred.user, isReturningUser: true);
        } on FirebaseAuthException catch (e) {
          debugPrint('FirebaseAuthService: Direct sign-in failed: ${e.code} - ${e.message}');
          return PhoneAuthResult.error(mapAuthError(e), code: e.code);
        }
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthService: verifyPhoneOtp FirebaseAuthException: ${e.code} - ${e.message}');
      final errorMsg = mapAuthError(e);
      return PhoneAuthResult.error(errorMsg, code: e.code);
    } catch (e) {
      debugPrint('FirebaseAuthService: verifyPhoneOtp error: $e');
      final errorMsg = mapAuthError(e);
      return PhoneAuthResult.error(errorMsg);
    }
  }

  /// Converts 10-digit / E.164 phone into a unique Firebase Auth email handle
  static String phoneToAuthEmail(String phone) {
    final cleanDigits = phone.replaceAll(RegExp(r'\D'), '');
    return 'phone_$cleanDigits@taazabazar.app';
  }

  /// Register user with Phone Number and Password (preserves UID if anonymous session exists)
  Future<UserCredential?> registerWithPhoneAndPassword({
    required String phone,
    required String password,
    required String name,
    String? email,
  }) async {
    final auth = _auth;
    if (auth == null) return null;

    final cleanDigits = phone.replaceAll(RegExp(r'\D'), '');
    final authEmail = phoneToAuthEmail(phone);
    final user = auth.currentUser;

    UserCredential? userCred;

    try {
      // 1. If anonymous user, try to link with email/password credential to preserve cart & subscriptions!
      if (user != null && user.isAnonymous) {
        try {
          final credential = EmailAuthProvider.credential(
            email: authEmail,
            password: password,
          );
          userCred = await user.linkWithCredential(credential);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'credential-already-in-use' || e.code == 'email-already-in-use') {
            userCred = await auth.signInWithEmailAndPassword(
              email: authEmail,
              password: password,
            );
          } else {
            rethrow;
          }
        }
      } else {
        userCred = await auth.createUserWithEmailAndPassword(
          email: authEmail,
          password: password,
        );
      }

      // Update display name
      await userCred.user?.updateDisplayName(name.trim());
      
      // Also persist to phone_users and top-level users collection for admin dashboard sync
      try {
        final uid = userCred?.user?.uid;
        await FirebaseFirestore.instance.collection('phone_users').doc(cleanDigits).set({
          'phone': phone,
          'password': password,
          'name': name.trim(),
          'email': email?.trim() ?? '',
          'uid': uid,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        if (uid != null) {
          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'name': name.trim(),
            'phone': phone,
            'email': email?.trim() ?? '',
            'uid': uid,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      } catch (e) {
        debugPrint('FirebaseAuthService: Firestore registration save error: $e');
      }

      // Save persistent device session
      await saveUserSession(
        phone: phone,
        name: name.trim(),
        uid: userCred.user?.uid,
        email: email?.trim(),
      );

      return userCred;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw FirebaseAuthException(
          code: 'phone-already-registered',
          message: 'This mobile number is already registered. Please log in with your password.',
        );
      } else if (e.code == 'operation-not-allowed') {
        // Fallback to Cloud Firestore direct authentication if Email/Password provider isn't toggled yet
        debugPrint('FirebaseAuthService: Falling back to Firestore auth for phone registration');
        final activeUser = await ensureAuthenticated();
        final phoneDocRef = FirebaseFirestore.instance.collection('phone_users').doc(cleanDigits);
        final phoneDoc = await phoneDocRef.get();

        if (phoneDoc.exists) {
          throw FirebaseAuthException(
            code: 'phone-already-registered',
            message: 'This mobile number is already registered. Please log in with your password.',
          );
        }

        await phoneDocRef.set({
          'phone': phone,
          'password': password,
          'name': name.trim(),
          'email': email?.trim() ?? '',
          'uid': activeUser?.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });

        await activeUser?.updateDisplayName(name.trim());

        // Save persistent device session
        await saveUserSession(
          phone: phone,
          name: name.trim(),
          uid: activeUser?.uid,
          email: email?.trim(),
        );

        return null;
      }
      rethrow;
    }
  }

  /// Sign in user with Phone Number and Password
  Future<UserCredential?> signInWithPhoneAndPassword({
    required String phone,
    required String password,
  }) async {
    final auth = _auth;
    if (auth == null) return null;

    final cleanDigits = phone.replaceAll(RegExp(r'\D'), '');
    final authEmail = phoneToAuthEmail(phone);

    try {
      final userCred = await auth.signInWithEmailAndPassword(
        email: authEmail,
        password: password,
      );

      // Save persistent device session
      await saveUserSession(
        phone: phone,
        name: userCred.user?.displayName,
        uid: userCred.user?.uid,
        email: userCred.user?.email,
      );

      return userCred;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'operation-not-allowed' || e.code == 'user-not-found' || e.code == 'invalid-credential' || e.code == 'invalid-email') {
        // Check Firestore fallback
        try {
          final phoneDoc = await FirebaseFirestore.instance.collection('phone_users').doc(cleanDigits).get();
          if (phoneDoc.exists) {
            final data = phoneDoc.data();
            if (data != null && data['password'] == password) {
              final activeUser = await ensureAuthenticated();
              final savedName = data['name'] as String?;
              if (savedName != null && savedName.isNotEmpty) {
                await activeUser?.updateDisplayName(savedName);
              }

              // Save persistent device session
              await saveUserSession(
                phone: phone,
                name: savedName,
                uid: activeUser?.uid,
                email: data['email'] as String?,
              );

              return null;
            } else {
              throw FirebaseAuthException(
                code: 'wrong-password',
                message: 'Incorrect password. Please check and try again.',
              );
            }
          }
        } catch (dbErr) {
          if (dbErr is FirebaseAuthException) rethrow;
        }

        if (e.code == 'user-not-found' || e.code == 'invalid-credential' || e.code == 'invalid-email') {
          throw FirebaseAuthException(
            code: 'invalid-credentials',
            message: 'No account found with this mobile number. Please register first.',
          );
        }
      } else if (e.code == 'wrong-password') {
        throw FirebaseAuthException(
          code: 'wrong-password',
          message: 'Incorrect password. Please check and try again.',
        );
      }
      rethrow;
    }
  }

  /// Sign in with Email and Password
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      final cred = await _auth?.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (cred?.user != null) {
        await saveUserSession(
          phone: cred!.user!.phoneNumber ?? '',
          name: cred.user!.displayName,
          uid: cred.user!.uid,
          email: email,
        );
      }
      return cred;
    } catch (e) {
      debugPrint('FirebaseAuthService: Email sign-in error: $e');
      return null;
    }
  }

  /// Register with Email and Password
  Future<UserCredential?> registerWithEmail(
    String email,
    String password, {
    String? name,
    String? phone,
  }) async {
    try {
      final credential = await _auth?.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (name != null && credential?.user != null) {
        await credential!.user!.updateDisplayName(name);
      }
      if (credential?.user != null) {
        await saveUserSession(
          phone: phone ?? '',
          name: name,
          uid: credential!.user!.uid,
          email: email,
        );
      }
      return credential;
    } catch (e) {
      debugPrint('FirebaseAuthService: Registration error: $e');
      return null;
    }
  }

  // --- Session Persistence Keys & Helpers ---
  static const String _keyIsLoggedIn = 'tb_is_logged_in';
  static const String _keyUserPhone = 'tb_user_phone';
  static const String _keyUserName = 'tb_user_name';
  static const String _keyUserUid = 'tb_user_uid';
  static const String _keyUserEmail = 'tb_user_email';

  /// Save persistent user session to local device storage
  Future<void> saveUserSession({
    required String phone,
    String? name,
    String? uid,
    String? email,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, true);
      await prefs.setString(_keyUserPhone, phone);
      if (name != null && name.isNotEmpty) {
        await prefs.setString(_keyUserName, name);
      }
      if (uid != null && uid.isNotEmpty) {
        await prefs.setString(_keyUserUid, uid);
      }
      if (email != null && email.isNotEmpty) {
        await prefs.setString(_keyUserEmail, email);
      }
      debugPrint('FirebaseAuthService: Persistent user session saved for $phone');
    } catch (e) {
      debugPrint('FirebaseAuthService: Save session error: $e');
    }
  }

  /// Check if user has an active persistent login session (remains true until manual logout)
  Future<bool> isUserSessionActive() async {
    try {
      // 1. Check local persistent storage flag
      final prefs = await SharedPreferences.getInstance();
      final isSavedLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
      if (isSavedLoggedIn) return true;

      // 2. Check Firebase Auth non-anonymous user
      final user = _auth?.currentUser;
      if (user != null && !user.isAnonymous) {
        return true;
      }
    } catch (e) {
      debugPrint('FirebaseAuthService: Check session error: $e');
    }
    return false;
  }

  /// Get persistent saved phone number
  Future<String?> getSavedUserPhone() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUserPhone);
    } catch (_) {
      return null;
    }
  }

  /// Get persistent saved user name
  Future<String?> getSavedUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUserName);
    } catch (_) {
      return null;
    }
  }

  /// Clear persistent user session only on manual logout
  Future<void> clearUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyIsLoggedIn);
      await prefs.remove(_keyUserPhone);
      await prefs.remove(_keyUserName);
      await prefs.remove(_keyUserUid);
      await prefs.remove(_keyUserEmail);
      debugPrint('FirebaseAuthService: User session cleared on manual logout');
    } catch (e) {
      debugPrint('FirebaseAuthService: Clear session error: $e');
    }
  }

  /// Sign out (Only invoked when user manually taps Logout)
  Future<void> signOut() async {
    final currentUid = _auth?.currentUser?.uid;
    if (currentUid != null && currentUid.isNotEmpty) {
      try {
        await NotificationService().unregisterCurrentDevice(currentUid);
      } catch (e) {
        debugPrint('FirebaseAuthService: Notice unregistering device on logout: $e');
      }
    }
    clearVerificationState();
    await clearUserSession();
    try {
      await _auth?.signOut();
    } catch (e) {
      debugPrint('FirebaseAuthService: Sign-out error: $e');
    }
  }
}
