import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taazabazar/core/services/notification_service.dart';
import 'package:taazabazar/features/profile/domain/customer_notification.dart';
import 'package:taazabazar/features/profile/domain/notification_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FCM Notification & Preferences Unit Tests', () {
    test('1. NotificationType parses all valid strings and falls back to general safely', () {
      expect(NotificationType.fromString('order_placed'), NotificationType.orderPlaced);
      expect(NotificationType.fromString('PAYMENT_SUCCESS'), NotificationType.paymentSuccess);
      expect(NotificationType.fromString('payment_failed'), NotificationType.paymentFailed);
      expect(NotificationType.fromString('order_preparing'), NotificationType.orderPreparing);
      expect(NotificationType.fromString('order_out_for_delivery'), NotificationType.orderOutForDelivery);
      expect(NotificationType.fromString('order_delivered'), NotificationType.orderDelivered);
      expect(NotificationType.fromString('order_cancelled'), NotificationType.orderCancelled);
      expect(NotificationType.fromString('refund_pending'), NotificationType.refundPending);
      expect(NotificationType.fromString('refund_processed'), NotificationType.refundProcessed);
      expect(NotificationType.fromString('refund_failed'), NotificationType.refundFailed);
      expect(NotificationType.fromString('morning_harvest'), NotificationType.morningHarvest);
      expect(NotificationType.fromString('promo'), NotificationType.promo);
      expect(NotificationType.fromString('unknown_event_xyz'), NotificationType.general);
      expect(NotificationType.fromString(null), NotificationType.general);
      expect(NotificationType.fromString(''), NotificationType.general);
    });

    test('2. CustomerNotification entity serializes and deserializes correctly', () {
      final now = DateTime(2026, 9, 14, 12, 0, 0);
      final notification = CustomerNotification(
        id: 'notif_101',
        title: 'Order Delivered! 🎉',
        body: 'Your fresh farm basket has arrived at your doorstep.',
        type: NotificationType.orderDelivered,
        orderId: '#FRSH-9921',
        createdAt: now,
        isRead: false,
        data: {'slot': 'Morning'},
      );

      final map = notification.toMap();
      expect(map['title'], 'Order Delivered! 🎉');
      expect(map['type'], 'order_delivered');
      expect(map['orderId'], '#FRSH-9921');
      expect(map['read'], false);
      expect(map['createdAt'], isA<Timestamp>());

      // Deserialization
      final parsed = CustomerNotification.fromMap('notif_101', map);
      expect(parsed.id, 'notif_101');
      expect(parsed.title, 'Order Delivered! 🎉');
      expect(parsed.type, NotificationType.orderDelivered);
      expect(parsed.orderId, '#FRSH-9921');
      expect(parsed.isRead, false);
    });

    test('3. CustomerNotification copyWith updates read status without mutating other fields', () {
      final notification = CustomerNotification(
        id: 'notif_102',
        title: 'Refund Processed',
        body: 'Refund of ₹250 has been completed.',
        type: NotificationType.refundProcessed,
        orderId: '#FRSH-102',
        createdAt: DateTime(2026, 9, 14),
        isRead: false,
      );

      final readNotification = notification.copyWith(isRead: true);
      expect(readNotification.isRead, true);
      expect(readNotification.id, notification.id);
      expect(readNotification.title, notification.title);
      expect(readNotification.type, notification.type);
      expect(readNotification.orderId, notification.orderId);
    });

    test('4. NotificationPreferences defaults are enabled and serialize cleanly', () {
      const prefs = NotificationPreferences();
      expect(prefs.orderUpdates, true);
      expect(prefs.morningHarvestAlerts, true);
      expect(prefs.offersAndPromotions, true);

      final map = prefs.toMap();
      expect(map['orderUpdates'], true);
      expect(map['morningHarvestAlerts'], true);
      expect(map['offersAndPromotions'], true);

      final parsed = NotificationPreferences.fromMap(map);
      expect(parsed.orderUpdates, true);
      expect(parsed.morningHarvestAlerts, true);
      expect(parsed.offersAndPromotions, true);
    });

    test('5. NotificationPreferences toggles work accurately without mutating other preferences', () {
      const prefs = NotificationPreferences();
      final toggled = prefs.copyWith(offersAndPromotions: false);

      expect(toggled.orderUpdates, true); // Transactional remains enabled
      expect(toggled.morningHarvestAlerts, true);
      expect(toggled.offersAndPromotions, false); // Promotional disabled

      final map = toggled.toMap();
      final parsed = NotificationPreferences.fromMap(map);
      expect(parsed.offersAndPromotions, false);
      expect(parsed.orderUpdates, true);
    });

    test('6. NotificationService singleton instance is resilient and handles null tokens gracefully', () async {
      final service = NotificationService();
      expect(service, isNotNull);

      // Multiple initializations are idempotent and safe
      await service.initialize();
      await service.initialize();

      // Token requests in test mode return null safely without throwing
      final token = await service.getToken();
      expect(token, isNull);

      // Register / Unregister calls with offline state do not throw exceptions
      await service.registerDeviceToken('test_uid_123');
      await service.unregisterCurrentDevice('test_uid_123');
    });

    test('7. Notification payload tap handling handles missing or arbitrary keys safely', () {
      final service = NotificationService();
      bool callbackFired = false;
      Map<String, dynamic>? tappedData;

      service.onNotificationPayloadTapped = (data) {
        callbackFired = true;
        tappedData = data;
      };

      service.handleNotificationTap({
        'type': 'order_placed',
        'orderId': '#FRSH-TEST-001',
      });

      expect(callbackFired, true);
      expect(tappedData?['orderId'], '#FRSH-TEST-001');

      // Empty payload handling
      service.handleNotificationTap({});
      expect(tappedData, isEmpty);
    });
  });
}
