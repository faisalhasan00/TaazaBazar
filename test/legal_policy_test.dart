import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taazabazar/core/constants/app_constants.dart';
import 'package:taazabazar/features/profile/domain/legal_document.dart';
import 'package:taazabazar/features/profile/presentation/about_screen.dart';
import 'package:taazabazar/features/profile/presentation/legal_screen.dart';
import 'package:taazabazar/features/profile/presentation/profile_screen.dart';
import 'package:taazabazar/features/profile/presentation/settings_screen.dart';

void main() {
  group('Legal Documents & Policy Integrity Unit Tests', () {
    test('1. LegalRepository contains all 5 required legal documents', () {
      expect(LegalRepository.privacyPolicy.title, 'Privacy Policy');
      expect(LegalRepository.termsAndConditions.title, 'Terms & Conditions');
      expect(LegalRepository.cancellationAndRefundPolicy.title, 'Cancellation & Refund Policy');
      expect(LegalRepository.deliveryPolicy.title, 'Delivery Policy');
      expect(LegalRepository.dataDeletionGuide.title, 'Account & Data Deletion');
    });

    test('2. Legal documents disclose verified contact constants and NO fake GSTIN/CIN', () {
      final allDocs = [
        LegalRepository.privacyPolicy,
        LegalRepository.termsAndConditions,
        LegalRepository.cancellationAndRefundPolicy,
        LegalRepository.deliveryPolicy,
        LegalRepository.dataDeletionGuide,
      ];

      for (final doc in allDocs) {
        expect(doc.effectiveDate, isNotEmpty);
        expect(doc.lastUpdated, isNotEmpty);
        for (final section in doc.sections) {
          expect(section.title, isNotEmpty);
          expect(section.content, isNotEmpty);
          // Verify no fabricated GSTIN or CIN exists
          expect(section.content.contains('GSTIN:'), isFalse);
          expect(section.content.contains('CIN:'), isFalse);
        }
      }

      // Check support email disclosure
      expect(
        LegalRepository.privacyPolicy.sections.any(
          (s) => s.content.contains(AppConstants.supportEmail),
        ),
        isTrue,
      );
      expect(
        LegalRepository.cancellationAndRefundPolicy.sections.any(
          (s) => s.content.contains(AppConstants.supportEmail),
        ),
        isTrue,
      );
    });

    test('3. Privacy Policy accurately discloses actual app data and location usage', () {
      final privacySections = LegalRepository.privacyPolicy.sections;
      final contentJoined = privacySections.map((s) => s.content).join('\n');

      expect(contentJoined.contains('com.taazabazar.app'), isTrue);
      expect(contentJoined.contains('Firebase Authentication'), isTrue);
      expect(contentJoined.contains('Cloud Firestore'), isTrue);
      expect(contentJoined.contains('Firebase Cloud Messaging'), isTrue);
      expect(contentJoined.contains('Razorpay'), isTrue);
      expect(contentJoined.contains('foreground'), isTrue);
      expect(contentJoined.contains('NOT track location in the background'), isTrue);
    });

    test('4. Cancellation & Refund policy reflects placed stage rule and honest refund timeline', () {
      final refundSections = LegalRepository.cancellationAndRefundPolicy.sections;
      final contentJoined = refundSections.map((s) => s.content).join('\n');

      expect(contentJoined.contains('"Placed" stage'), isTrue);
      expect(contentJoined.contains('Non-Cancellable Stages'), isTrue);
      expect(contentJoined.contains('Gateway Refund ID'), isTrue);
      expect(
        contentJoined.contains(
          'Refund processing time may depend on the payment provider and the customer\'s financial institution',
        ),
        isTrue,
      );
      // No fake 3-5 day promise
      expect(contentJoined.contains('3-5 business days'), isFalse);
      expect(contentJoined.contains('3-5 banking days'), isFalse);
    });

    test('5. Delivery policy accurately reflects ₹199 threshold and ₹25 delivery fee', () {
      final deliverySections = LegalRepository.deliveryPolicy.sections;
      final contentJoined = deliverySections.map((s) => s.content).join('\n');

      expect(contentJoined.contains('₹${AppConstants.freeDeliveryThreshold.toInt()}'), isTrue);
      expect(contentJoined.contains('₹${AppConstants.standardDeliveryFee.toInt()}'), isTrue);
      expect(contentJoined.contains('Tomorrow 6:00 AM – 8:00 AM'), isTrue);
      expect(contentJoined.contains('Sunrise Organic Farm, Shadnagar Hub'), isTrue);
    });
  });

  group('Legal & Policies Widget Navigation Tests', () {
    testWidgets('6. LegalScreen renders without requiring authentication', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LegalScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LegalScreen), findsOneWidget);
      expect(find.text('Legal & Policies'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsAtLeastNWidgets(1));
      expect(find.text('Terms & Conditions'), findsOneWidget);
      expect(find.text('Cancellation & Refund'), findsOneWidget);
      expect(find.text('Delivery Policy'), findsOneWidget);
      expect(find.text('Data Deletion'), findsOneWidget);

      // Verify header card
      expect(find.text('Package: com.taazabazar.app'), findsAtLeastNWidgets(1));
      expect(find.text('1. Overview & Scope'), findsOneWidget);
    });

    testWidgets('7. LegalScreen opens with specified initialTabIndex', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LegalScreen(initialTabIndex: 2),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LegalScreen), findsOneWidget);
      expect(find.text('1. Order Cancellation Policy'), findsOneWidget);
      expect(find.text('2. Cash on Delivery (COD) Cancellations'), findsOneWidget);
    });

    testWidgets('8. ProfileScreen -> Legal & Policies opens LegalScreen and pops back cleanly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final legalMenuItem = find.text('Legal & Policies');
      await tester.scrollUntilVisible(legalMenuItem, 100);
      await tester.pumpAndSettle();

      expect(legalMenuItem, findsOneWidget);
      await tester.tap(legalMenuItem);
      await tester.pumpAndSettle();

      expect(find.byType(LegalScreen), findsOneWidget);
      expect(find.text('Legal & Policies'), findsOneWidget);

      // Pop back
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(LegalScreen), findsNothing);
      expect(find.byType(ProfileScreen), findsOneWidget);
    });

    testWidgets('9. AboutScreen displays direct policy links and navigates to LegalScreen', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AboutScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final privacyTile = find.text('Privacy Policy');
      await tester.scrollUntilVisible(privacyTile, 100);
      await tester.pumpAndSettle();

      expect(privacyTile, findsOneWidget);
      expect(find.text('Terms & Conditions'), findsOneWidget);
      expect(find.text('Cancellation & Refund Policy'), findsOneWidget);
      expect(find.text('Delivery Policy'), findsOneWidget);
      expect(find.text('Account & Data Deletion'), findsOneWidget);

      await tester.tap(privacyTile);
      await tester.pumpAndSettle();

      expect(find.byType(LegalScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(LegalScreen), findsNothing);
      expect(find.byType(AboutScreen), findsOneWidget);
    });

    testWidgets('10. SettingsScreen displays Legal & Policies and navigates correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final legalTile = find.text('Legal & Policies');
      await tester.scrollUntilVisible(legalTile, 100);
      await tester.pumpAndSettle();

      expect(legalTile, findsOneWidget);
      await tester.tap(legalTile);
      await tester.pumpAndSettle();

      expect(find.byType(LegalScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(LegalScreen), findsNothing);
      expect(find.byType(SettingsScreen), findsOneWidget);
    });
  });
}
