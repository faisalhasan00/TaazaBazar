import 'package:flutter_test/flutter_test.dart';
import 'package:taazabazar/core/utils/delivery_slot_helper.dart';

void main() {
  group('DeliverySlotHelper Unit Tests', () {
    test('Calculates tomorrow correctly when today is Saturday, 12 Sep 2026', () {
      final baseDate = DateTime(2026, 9, 12, 14, 30); // Sat, 12 Sep 2026
      final slotDate = DeliverySlotHelper.getTomorrowSlotDate(baseDate);
      expect(slotDate, equals('Tomorrow (Sun, 13 Sep)'));
    });

    test('Calculates tomorrow correctly when today is Sunday, 13 Sep 2026', () {
      final baseDate = DateTime(2026, 9, 13, 10, 0); // Sun, 13 Sep 2026
      final slotDate = DeliverySlotHelper.getTomorrowSlotDate(baseDate);
      expect(slotDate, equals('Tomorrow (Mon, 14 Sep)'));
    });

    test('Handles month transition on last day of month', () {
      final baseDate = DateTime(2026, 9, 30, 22, 0); // Wed, 30 Sep 2026
      final slotDate = DeliverySlotHelper.getTomorrowSlotDate(baseDate);
      expect(slotDate, equals('Tomorrow (Thu, 1 Oct)'));
    });

    test('Handles year transition on December 31', () {
      final baseDate = DateTime(2026, 12, 31, 23, 59); // Thu, 31 Dec 2026
      final slotDate = DeliverySlotHelper.getTomorrowSlotDate(baseDate);
      expect(slotDate, equals('Tomorrow (Fri, 1 Jan)'));
    });

    test('Correctly maps all 7 weekdays', () {
      // 2026-09-14 is Monday
      expect(DeliverySlotHelper.formatSlotDate(DateTime(2026, 9, 14)), 'Tomorrow (Mon, 14 Sep)');
      expect(DeliverySlotHelper.formatSlotDate(DateTime(2026, 9, 15)), 'Tomorrow (Tue, 15 Sep)');
      expect(DeliverySlotHelper.formatSlotDate(DateTime(2026, 9, 16)), 'Tomorrow (Wed, 16 Sep)');
      expect(DeliverySlotHelper.formatSlotDate(DateTime(2026, 9, 17)), 'Tomorrow (Thu, 17 Sep)');
      expect(DeliverySlotHelper.formatSlotDate(DateTime(2026, 9, 18)), 'Tomorrow (Fri, 18 Sep)');
      expect(DeliverySlotHelper.formatSlotDate(DateTime(2026, 9, 19)), 'Tomorrow (Sat, 19 Sep)');
      expect(DeliverySlotHelper.formatSlotDate(DateTime(2026, 9, 20)), 'Tomorrow (Sun, 20 Sep)');
    });

    test('Correctly maps all 12 months', () {
      expect(DeliverySlotHelper.formatSlotDate(DateTime(2026, 1, 15)), 'Tomorrow (Thu, 15 Jan)');
      expect(DeliverySlotHelper.formatSlotDate(DateTime(2026, 2, 15)), 'Tomorrow (Sun, 15 Feb)');
      expect(DeliverySlotHelper.formatSlotDate(DateTime(2026, 3, 15)), 'Tomorrow (Sun, 15 Mar)');
      expect(DeliverySlotHelper.formatSlotDate(DateTime(2026, 4, 15)), 'Tomorrow (Wed, 15 Apr)');
      expect(DeliverySlotHelper.formatSlotDate(DateTime(2026, 5, 15)), 'Tomorrow (Fri, 15 May)');
      expect(DeliverySlotHelper.formatSlotDate(DateTime(2026, 6, 15)), 'Tomorrow (Mon, 15 Jun)');
      expect(DeliverySlotHelper.formatSlotDate(DateTime(2026, 7, 15)), 'Tomorrow (Wed, 15 Jul)');
      expect(DeliverySlotHelper.formatSlotDate(DateTime(2026, 8, 15)), 'Tomorrow (Sat, 15 Aug)');
      expect(DeliverySlotHelper.formatSlotDate(DateTime(2026, 9, 15)), 'Tomorrow (Tue, 15 Sep)');
      expect(DeliverySlotHelper.formatSlotDate(DateTime(2026, 10, 15)), 'Tomorrow (Thu, 15 Oct)');
      expect(DeliverySlotHelper.formatSlotDate(DateTime(2026, 11, 15)), 'Tomorrow (Sun, 15 Nov)');
      expect(DeliverySlotHelper.formatSlotDate(DateTime(2026, 12, 15)), 'Tomorrow (Tue, 15 Dec)');
    });

    test('Default getTomorrowSlotDate() matches expected format using system clock', () {
      final slot = DeliverySlotHelper.getTomorrowSlotDate();
      final regex = RegExp(r'^Tomorrow \((Mon|Tue|Wed|Thu|Fri|Sat|Sun), \d{1,2} (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\)$');
      expect(regex.hasMatch(slot), isTrue, reason: 'Generated slot: "$slot" should match expected pattern');
    });
  });
}
