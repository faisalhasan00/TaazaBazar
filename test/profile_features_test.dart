import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taazabazar/features/pass/presentation/freshly_pass_screen.dart';
import 'package:taazabazar/features/profile/presentation/about_screen.dart';
import 'package:taazabazar/features/profile/presentation/edit_profile_screen.dart';
import 'package:taazabazar/features/profile/presentation/help_support_screen.dart';
import 'package:taazabazar/features/profile/presentation/notifications_screen.dart';
import 'package:taazabazar/features/profile/presentation/profile_screen.dart';
import 'package:taazabazar/features/profile/presentation/settings_screen.dart';

void main() {
  group('Profile Features & Sub-screens Navigation Tests', () {
    testWidgets('Profile -> Notifications opens NotificationsScreen and displays honest empty state', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final notificationsFinder = find.text('Notifications');
      expect(notificationsFinder, findsOneWidget);
      await tester.tap(notificationsFinder);
      await tester.pumpAndSettle();

      expect(find.byType(NotificationsScreen), findsOneWidget);
      expect(find.text('No Notifications Yet'), findsOneWidget);
      expect(find.textContaining('Notifications will appear here'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(NotificationsScreen), findsNothing);
      expect(find.byType(ProfileScreen), findsOneWidget);
    });

    testWidgets('Profile -> Settings opens SettingsScreen with appearance and version info', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final settingsFinder = find.text('Settings');
      expect(settingsFinder, findsOneWidget);
      await tester.tap(settingsFinder);
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Application Version'), findsOneWidget);
      expect(find.text('TaazaBazar v1.0.0 (Build 1)'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsNothing);
      expect(find.byType(ProfileScreen), findsOneWidget);
    });

    testWidgets('Profile -> Help & Support opens HelpSupportScreen with contact info and FAQs', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final helpFinder = find.text('Help & Support');
      await tester.scrollUntilVisible(helpFinder, 100);
      await tester.pumpAndSettle();

      expect(helpFinder, findsOneWidget);
      await tester.tap(helpFinder);
      await tester.pumpAndSettle();

      expect(find.byType(HelpSupportScreen), findsOneWidget);
      expect(find.text('TaazaBazar Customer Care'), findsOneWidget);
      expect(find.text('In-app helpline coming soon'), findsOneWidget);
      expect(find.text('+91 98765 12340'), findsNothing);
      expect(find.text('care@taazabazar.in'), findsOneWidget);
      expect(find.text('When will my order be delivered?'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(HelpSupportScreen), findsNothing);
      expect(find.byType(ProfileScreen), findsOneWidget);
    });

    testWidgets('Profile -> About TaazaBazar opens AboutScreen with app details', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final aboutFinder = find.text('About TaazaBazar');
      await tester.scrollUntilVisible(aboutFinder, 100);
      await tester.pumpAndSettle();

      expect(aboutFinder, findsOneWidget);
      await tester.tap(aboutFinder);
      await tester.pumpAndSettle();

      expect(find.byType(AboutScreen), findsOneWidget);
      expect(find.text('TaazaBazar'), findsWidgets);
      expect(find.text('Pure Food. Better Life.'), findsOneWidget);
      expect(find.text('Version 1.0.0 (Build 1)'), findsOneWidget);
      expect(find.text('Our Mission'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(AboutScreen), findsNothing);
      expect(find.byType(ProfileScreen), findsOneWidget);
    });

    testWidgets('Profile -> Taaza Pass opens TaazaPassScreen and does NOT falsely activate membership', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final passFinder = find.text('Taaza Pass');
      expect(passFinder, findsOneWidget);
      await tester.tap(passFinder);
      await tester.pumpAndSettle();

      expect(find.byType(TaazaPassScreen), findsOneWidget);
      expect(find.text('Unlimited Free Deliveries'), findsOneWidget);
      expect(find.text('Taaza Pass Available Soon'), findsOneWidget);

      // Tap the button
      await tester.tap(find.text('Taaza Pass Available Soon'));
      await tester.pumpAndSettle();

      // Check that NO false success snackbar is displayed
      expect(find.text('🎉 Taaza Pass activated successfully!'), findsNothing);
      expect(find.text('Taaza Pass subscriptions will be available soon.'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(TaazaPassScreen), findsNothing);
      expect(find.byType(ProfileScreen), findsOneWidget);
    });

    testWidgets('Existing Edit Profile navigation still works from ProfileScreen header', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final editIconFinder = find.byIcon(Icons.edit_outlined);
      expect(editIconFinder, findsOneWidget);
      await tester.tap(editIconFinder);
      await tester.pumpAndSettle();

      expect(find.byType(EditProfileScreen), findsOneWidget);
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
    });

    testWidgets('Existing Logout dialog opens and cancels safely', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final logoutFinder = find.text('Logout');
      await tester.scrollUntilVisible(logoutFinder, 100);
      await tester.pumpAndSettle();

      expect(logoutFinder, findsOneWidget);
      await tester.tap(logoutFinder);
      await tester.pumpAndSettle();

      expect(find.text('Are you sure you want to log out of your TaazaBazar account?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Are you sure you want to log out of your TaazaBazar account?'), findsNothing);
      expect(find.byType(ProfileScreen), findsOneWidget);
    });
  });
}
