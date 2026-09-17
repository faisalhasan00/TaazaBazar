import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Top-level background message handler for Firebase Cloud Messaging.
/// Must be annotated with @pragma('vm:entry-point') so Flutter engine can invoke it in background.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('FCM Background message received: ${message.messageId} | type: ${message.data['type']}');
}

/// Core Notification Service for TaazaBazar customer push notifications.
/// Manages FCM tokens, permission requests, foreground/background lifecycle, and deep linking.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  FirebaseMessaging? _messaging;
  FirebaseFirestore? _firestore;
  FirebaseAuth? _auth;

  bool _isInitialized = false;
  String? _currentToken;

  FirebaseMessaging? get _safeMessaging {
    if (_messaging != null) return _messaging;
    try {
      return FirebaseMessaging.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseFirestore? get _safeFirestore {
    if (_firestore != null) return _firestore;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseAuth? get _safeAuth {
    if (_auth != null) return _auth;
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  /// Global navigator key for routing upon notification taps
  GlobalKey<NavigatorState>? navigatorKey;

  /// Optional custom callback for notification tap handling
  void Function(Map<String, dynamic> data)? onNotificationPayloadTapped;

  /// Optional custom callback for foreground banner display
  void Function(RemoteMessage message)? onForegroundMessageReceived;

  /// Initializes FCM listeners and settings safely.
  Future<void> initialize({
    FirebaseMessaging? messaging,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    GlobalKey<NavigatorState>? navKey,
  }) async {
    if (_isInitialized && messaging == null) return;

    if (messaging != null) _messaging = messaging;
    if (firestore != null) _firestore = firestore;
    if (auth != null) _auth = auth;
    if (navKey != null) navigatorKey = navKey;

    try {
      final msg = _safeMessaging;
      if (msg == null) {
        _isInitialized = true;
        return;
      }

      // Set foreground notification presentation options
      await msg.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Listen for incoming messages while app is in foreground
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Listen for message clicks while app is in background/resumed
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        handleNotificationTap(message.data);
      });

      // Listen for token refreshes
      msg.onTokenRefresh.listen((newToken) {
        _currentToken = newToken;
        final currentUid = _safeAuth?.currentUser?.uid;
        if (currentUid != null && currentUid.isNotEmpty) {
          registerDeviceToken(currentUid, token: newToken);
        }
      });

      // Check if app was opened from a terminated state notification tap
      final initialMessage = await msg.getInitialMessage();
      if (initialMessage != null) {
        Future.delayed(const Duration(milliseconds: 600), () {
          handleNotificationTap(initialMessage.data);
        });
      }

      _isInitialized = true;
      debugPrint('NotificationService initialized successfully.');
    } catch (e) {
      debugPrint('NotificationService initialization notice: $e');
    }
  }

  /// Requests notification permission non-intrusively.
  /// Returns true if permission was granted or provisional.
  Future<bool> requestPermission() async {
    try {
      final msg = _safeMessaging;
      if (msg == null) return false;
      final settings = await msg.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      final isGranted = settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
      debugPrint('FCM Notification permission status: ${settings.authorizationStatus} ($isGranted)');

      if (isGranted) {
        // Retrieve and register token if user is signed in
        final token = await getToken();
        final currentUid = _safeAuth?.currentUser?.uid;
        if (currentUid != null && currentUid.isNotEmpty && token != null) {
          await registerDeviceToken(currentUid, token: token);
        }
      }

      return isGranted;
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
      return false;
    }
  }

  /// Retrieves the current device FCM registration token.
  Future<String?> getToken() async {
    try {
      if (_currentToken != null) return _currentToken;
      final msg = _safeMessaging;
      if (msg == null) return null;
      _currentToken = await msg.getToken();
      return _currentToken;
    } catch (e) {
      debugPrint('Notice: Could not fetch FCM token: $e');
      return null;
    }
  }

  /// Registers or updates the device token under `users/{uid}/devices/{deviceId}`.
  Future<void> registerDeviceToken(String uid, {String? token}) async {
    try {
      final fcmToken = token ?? await getToken();
      if (fcmToken == null || fcmToken.isEmpty) return;
      final store = _safeFirestore;
      if (store == null) return;

      final deviceId = _getDeterministicDeviceId(fcmToken);
      final platform = kIsWeb
          ? 'web'
          : (Platform.isAndroid
              ? 'android'
              : (Platform.isIOS ? 'ios' : 'other'));

      final deviceRef = store
          .collection('users')
          .doc(uid)
          .collection('devices')
          .doc(deviceId);

      await deviceRef.set({
        'token': fcmToken,
        'platform': platform,
        'enabled': true,
        'appVersion': '1.0.0+1',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('Device registered for push notifications: $deviceId (User: $uid)');
    } catch (e) {
      debugPrint('Notice: Could not register device token in Firestore: $e');
    }
  }

  /// Unregisters/disables the device token on user logout to prevent cross-account notification delivery.
  Future<void> unregisterCurrentDevice(String uid) async {
    try {
      final fcmToken = _currentToken ?? await getToken();
      if (fcmToken == null || fcmToken.isEmpty) return;
      final store = _safeFirestore;
      if (store == null) return;

      final deviceId = _getDeterministicDeviceId(fcmToken);
      final deviceRef = store
          .collection('users')
          .doc(uid)
          .collection('devices')
          .doc(deviceId);

      await deviceRef.update({
        'enabled': false,
        'unregisteredAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Device token disabled on logout for user: $uid');
    } catch (e) {
      debugPrint('Notice: Could not unregister device token on logout: $e');
    }
  }

  /// Handles incoming foreground FCM message.
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground notification received: ${message.notification?.title} | ${message.notification?.body}');

    if (onForegroundMessageReceived != null) {
      onForegroundMessageReceived!(message);
      return;
    }

    // Default non-intrusive UI banner
    final context = navigatorKey?.currentContext;
    if (context != null && context.mounted && message.notification != null) {
      final title = message.notification?.title ?? 'TaazaBazar';
      final body = message.notification?.body ?? '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (body.isNotEmpty)
                Text(
                  body,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
          backgroundColor: const Color(0xFF166534),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          action: message.data.containsKey('orderId')
              ? SnackBarAction(
                  label: 'VIEW',
                  textColor: const Color(0xFFDCFCE7),
                  onPressed: () => handleNotificationTap(message.data),
                )
              : null,
        ),
      );
    }
  }

  /// Handles notification click / deep link navigation safely.
  void handleNotificationTap(Map<String, dynamic> data) {
    debugPrint('Notification tapped with payload: $data');

    if (onNotificationPayloadTapped != null) {
      onNotificationPayloadTapped!(data);
      return;
    }

    final orderId = data['orderId']?.toString();
    final context = navigatorKey?.currentContext;

    if (context != null && context.mounted) {
      if (orderId != null && orderId.isNotEmpty) {
        debugPrint('Navigating to order: $orderId from notification tap');
      }
    }
  }

  /// Generates a safe, clean device ID from token hash/substring.
  String _getDeterministicDeviceId(String token) {
    if (token.length <= 32) return token;
    final prefix = token.substring(0, 16);
    final suffix = token.substring(token.length - 16);
    return 'dev_${prefix}_$suffix'.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
  }
}
