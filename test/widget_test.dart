import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freshly/features/auth/presentation/login_screen.dart';
import 'package:freshly/features/home/presentation/home_screen.dart';
import 'package:freshly/features/location/presentation/address_confirmation_screen.dart';
import 'package:freshly/features/location/presentation/location_setup_screen.dart';
import 'package:freshly/features/location/presentation/manual_address_screen.dart';
import 'package:freshly/features/onboarding/presentation/onboarding_screen.dart';
import 'package:freshly/features/splash/presentation/widgets/freshly_logo.dart';
import 'package:freshly/main.dart';

void main() {
  testWidgets('Freshly splash screen displays branding, logo and tagline',
      (WidgetTester tester) async {
    await tester.pumpWidget(const FreshlyApp());
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 1000));

    expect(find.byType(FreshlyEmblem), findsOneWidget);
    expect(find.text('Freshly'), findsOneWidget);
    expect(find.text('Pure Food'), findsOneWidget);
    expect(find.text('Better Life'), findsOneWidget);
  });

  testWidgets('Freshly onboarding flow allows paging, Next and Skip to Login',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: OnboardingScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.byType(FreshlyEmblem), findsOneWidget);
    expect(find.text('Freshly'), findsOneWidget);
    expect(find.text('Pure Food'), findsOneWidget);
    expect(find.text('Better Life'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);

    // Tap on Screen 1 to page to Screen 2
    await tester.tap(find.text('Freshly'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Farm Fresh\nto Your Home'), findsOneWidget);
    expect(find.byKey(const ValueKey('farm_fresh_get_started_btn')), findsOneWidget);
    expect(find.byKey(const ValueKey('farm_fresh_skip_btn')), findsOneWidget);

    // Tap Get Started on Screen 2 to navigate directly to LoginScreen
    await tester.tap(find.byKey(const ValueKey('farm_fresh_get_started_btn')));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('Freshly Location -> Address Confirmation -> Home flow',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LocationSetupScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Location Screen contents
    expect(find.text('Where should we deliver?'), findsOneWidget);
    expect(
      find.text(
          'Add your delivery location to see products and delivery options available near you.'),
      findsOneWidget,
    );
    expect(find.text('Use Current Location'), findsOneWidget);
    expect(find.text('Enter Address Manually'), findsOneWidget);

    // Tap Use Current Location -> Navigate to Address Confirmation
    await tester.tap(find.text('Use Current Location'));
    await tester.pumpAndSettle();

    expect(find.byType(AddressConfirmationScreen), findsOneWidget);
    expect(find.text('Your delivery address'), findsOneWidget);
    expect(find.text('Flat 402, Oakwood'), findsOneWidget);
    expect(find.text('Confirm Location'), findsOneWidget);

    // Scroll down to tap Confirm Location cleanly
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -250));
    await tester.pumpAndSettle();

    // Tap Confirm Location -> Navigate to Home Screen
    await tester.tap(find.text('Confirm Location'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Shop by Category'), findsOneWidget);
    expect(find.text('Vegetables'), findsOneWidget);
    expect(find.text('Freshness Delivered Daily'), findsOneWidget);
  });

  testWidgets('Freshly Home Screen renders full header, banner, categories, products, pass and nav',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(
          selectedSociety: 'Prestige High Fields',
          deliveryAddress: 'Flat 402, Oakwood, Prestige High Fields',
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Header
    expect(find.text('Freshly'), findsOneWidget);
    expect(find.text('DELIVER TO'), findsOneWidget);
    expect(find.text('Search vegetables, milk, fruits...'), findsOneWidget);

    // 2. Promo Banner
    expect(find.text('Freshness Delivered Daily'), findsOneWidget);
    expect(
      find.text('Fresh vegetables, dairy & organic products at your doorstep.'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('banner_shop_now_btn')), findsOneWidget);

    // 3. Shop by Category
    expect(find.text('Shop by Category'), findsOneWidget);
    expect(find.text('Vegetables'), findsOneWidget);
    expect(find.text('Fruits'), findsOneWidget);
    expect(find.text('Dairy'), findsOneWidget);
    expect(find.text('Eggs'), findsOneWidget);

    // 4. Freshly Pass
    expect(find.text('Save More with Freshly Pass'), findsOneWidget);
    expect(find.text('Get better value with Weekly & Monthly plans.'), findsOneWidget);
    expect(find.byKey(const ValueKey('view_plans_btn')), findsOneWidget);

    // 5. Popular Near You
    expect(find.text('Popular Near You'), findsOneWidget);
    expect(find.text('Fresh Tomato'), findsOneWidget);
    expect(find.text('Fresh Milk'), findsOneWidget);
    expect(find.text('Organic Eggs'), findsOneWidget);
    expect(find.text('Spinach'), findsOneWidget);

    // 6. Bottom Navigation (5 items)
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Orders'), findsOneWidget);
    expect(find.text('Pass'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    // 7. Interactive ADD button on products
    expect(find.text('ADD'), findsWidgets);
    await tester.tap(find.text('ADD').first);
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('Freshly Manual Address Form -> Save -> Confirm flow',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ManualAddressScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify form fields
    expect(find.text('House / Flat / Door No.'), findsOneWidget);
    expect(find.text('Building / Street'), findsOneWidget);
    expect(find.text('Area'), findsOneWidget);
    expect(find.text('City'), findsOneWidget);
    expect(find.text('State'), findsOneWidget);
    expect(find.text('PIN Code'), findsOneWidget);

    // Scroll to reveal Save Address button
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();

    expect(find.text('Add a delivery note'), findsOneWidget);
    expect(find.text('Save Address'), findsOneWidget);

    // Tap Save Address -> Navigate to Confirmation
    await tester.tap(find.text('Save Address'));
    await tester.pumpAndSettle();

    expect(find.byType(AddressConfirmationScreen), findsOneWidget);
    expect(find.text('Confirm Location'), findsOneWidget);
  });
}
