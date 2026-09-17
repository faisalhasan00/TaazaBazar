import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taazabazar/core/constants/app_constants.dart';
import 'package:taazabazar/features/cart/presentation/cart_screen.dart';
import 'package:taazabazar/features/location/presentation/add_edit_address_screen.dart';
import 'package:taazabazar/features/location/presentation/saved_addresses_screen.dart';
import 'package:taazabazar/features/orders/presentation/order_tracking_screen.dart';
import 'package:taazabazar/features/orders/presentation/orders_screen.dart';
import 'package:taazabazar/features/products/presentation/product_search_screen.dart';
import 'package:taazabazar/features/profile/presentation/about_screen.dart';
import 'package:taazabazar/features/profile/presentation/help_support_screen.dart';
import 'package:taazabazar/features/profile/presentation/legal_screen.dart';
import 'package:taazabazar/features/splash/presentation/splash_screen.dart';

void main() {
  group('Step 51: Production Polish & UI/UX Audit Tests', () {
    testWidgets('1. Splash screen displays branding and tagline', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 1000));

      expect(find.text('TaazaBazar'), findsOneWidget);
      expect(find.text('Pure Food'), findsOneWidget);
      expect(find.text('Better Life'), findsOneWidget);

      // Advance timer past splash duration to cleanly flush navigation timer
      await tester.pump(const Duration(milliseconds: 4000));
    });

    testWidgets('2. CartScreen empty state is clear and provides recovery action', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CartScreen(initialItems: []),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Your cart is empty'), findsOneWidget);
      expect(find.text('Start Shopping'), findsOneWidget);
    });

    testWidgets('3. OrdersScreen renders tabs and clean empty state without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OrdersScreen(
            isStandalone: true,
            initialActiveOrders: [],
            initialPreviousOrders: [],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(OrdersScreen), findsOneWidget);
      expect(find.text('My Orders'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Previous'), findsOneWidget);
      expect(find.text('No Active Orders'), findsOneWidget);
    });

    testWidgets('4. ProductSearchScreen renders search input and filter chips', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProductSearchScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('global_search_input')), findsOneWidget);
      expect(find.text('Search products, vegetables, milk...'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Organic'), findsOneWidget);
    });

    testWidgets('5. SavedAddressesScreen empty state guides user to add delivery address', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SavedAddressesScreen(isStandalone: true),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SavedAddressesScreen), findsOneWidget);
      expect(find.text('Saved Addresses'), findsOneWidget);
      expect(find.text('Add New Address'), findsOneWidget);
    });

    testWidgets('6. AddEditAddressScreen displays localized generic hints and no hardcoded Indiranagar', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AddEditAddressScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AddEditAddressScreen), findsOneWidget);
      expect(find.text('Add New Address'), findsOneWidget);

      final cityFinder = find.byKey(const ValueKey('address_city_field'));
      await tester.scrollUntilVisible(
        cityFinder,
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(cityFinder, findsOneWidget);
      expect(find.textContaining('Bengaluru'), findsNothing);
      expect(find.textContaining('Indiranagar'), findsNothing);
    });

    testWidgets('7. OrderTrackingScreen uses honest ORDER TRACKING branding and real hub name', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OrderTrackingScreen(),
        ),
      );
      // Pump once instead of pumpAndSettle due to pulse animation in MockDeliveryMap
      await tester.pump();

      expect(find.byType(OrderTrackingScreen), findsOneWidget);
      expect(find.text('ORDER TRACKING'), findsOneWidget);
      expect(find.text('Sunrise Organic Farm'), findsOneWidget);
      expect(find.text('Order Status Timeline'), findsOneWidget);
    });

    testWidgets('8. LegalScreen and sub-policies load cleanly without authentication', (WidgetTester tester) async {
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
    });

    testWidgets('9. HelpSupportScreen contains accurate support phone, email and FAQs', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HelpSupportScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('TaazaBazar Customer Care'), findsOneWidget);
      expect(find.text(AppConstants.supportPhone), findsOneWidget);
      expect(find.text(AppConstants.supportEmail), findsOneWidget);
      expect(find.text('When will my order be delivered?'), findsOneWidget);
    });

    testWidgets('10. AboutScreen renders mission, version, and policy navigation links', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AboutScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('About TaazaBazar'), findsOneWidget);
      expect(find.text('Version 1.0.0 (Build 1)'), findsOneWidget);
      expect(find.text('Our Mission'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('Terms & Conditions'), findsOneWidget);
      expect(find.text('Cancellation & Refund Policy'), findsOneWidget);
    });
  });
}
