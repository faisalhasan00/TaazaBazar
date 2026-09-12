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
    expect(find.text('Vegetables'), findsWidgets);
    expect(find.text('Pure.\nFresh.\nOrganic.'), findsOneWidget);
  });

  testWidgets('Freshly Home Screen renders full header, banner, categories, fresh deals, pass and nav',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(
          selectedSociety: 'Shadnagar, Hyderabad',
          deliveryAddress: 'Shadnagar, Hyderabad',
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Header
    expect(find.text('Deliver to'), findsOneWidget);
    expect(find.text('Shadnagar, Hyderabad'), findsOneWidget);
    expect(find.text('Search for vegetables, dairy, etc.'), findsOneWidget);

    // 2. Hero Banner
    expect(find.text('Pure.\nFresh.\nOrganic.'), findsOneWidget);
    expect(find.byKey(const ValueKey('banner_shop_now_btn')), findsOneWidget);

    // 3. 8 Categories
    expect(find.text('Vegetables'), findsWidgets);
    expect(find.text('Fruits'), findsOneWidget);
    expect(find.text('Dairy'), findsOneWidget);
    expect(find.text('Organic'), findsOneWidget);
    expect(find.text('Milk'), findsWidgets);
    expect(find.text('Eggs'), findsWidgets);
    expect(find.text('Grocery'), findsOneWidget);
    expect(find.text('More'), findsOneWidget);

    // 4. Fresh Deals
    expect(find.text('Fresh Deals'), findsOneWidget);
    expect(find.text('Tomato'), findsOneWidget);
    expect(find.text('₹25/kg'), findsOneWidget);
    expect(find.text('₹60/L'), findsOneWidget);
    expect(find.text('Spinach'), findsOneWidget);

    // 5. Freshly Pass mini banner
    expect(find.text('Save More with Freshly Pass'), findsOneWidget);
    expect(find.text('View Plans'), findsOneWidget);

    // 6. Bottom Navigation
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Orders'), findsOneWidget);
    expect(find.text('Pass'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    // 7. Tap Pass tab to verify Freshly Pass Screen
    await tester.tap(find.text('Pass'));
    await tester.pumpAndSettle();

    expect(find.text('Freshly Pass'), findsOneWidget);
    expect(find.text('Select Membership Plan'), findsOneWidget);
    expect(find.text('Weekly Pass'), findsOneWidget);
    expect(find.text('Monthly Pass'), findsOneWidget);
    expect(find.text('Quarterly Pass'), findsOneWidget);
    expect(find.text('Activate Freshly Pass'), findsOneWidget);
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

  testWidgets('Freshly Categories Screen displays "Shop Fresh", search, and 7 categories',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap Categories Tab in bottom navigation
    await tester.tap(find.text('Categories'));
    await tester.pumpAndSettle();

    // Verify Categories Screen
    expect(find.text('Shop Fresh'), findsOneWidget);
    expect(find.text('Search products...'), findsOneWidget);
    expect(find.text('7 CATEGORIES'), findsOneWidget);

    // 7 categories
    expect(find.text('Vegetables'), findsWidgets);
    expect(find.text('Fruits'), findsWidgets);
    expect(find.text('Dairy & Milk'), findsOneWidget);
    expect(find.text('Eggs'), findsWidgets);
    expect(find.text('Organic'), findsWidgets);
    expect(find.text('Natural Products'), findsOneWidget);
    expect(find.text('Grocery'), findsWidgets);
  });

  testWidgets('Freshly Product Listing Screen displays 2-column grid, filters, sorting and cart indicator',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap Categories Tab
    await tester.tap(find.text('Categories'));
    await tester.pumpAndSettle();

    // Tap on Vegetables category card
    await tester.tap(find.byKey(const ValueKey('cat_card_veg')));
    await tester.pumpAndSettle();

    // Verify Product Listing Screen
    expect(find.text('Vegetables'), findsWidgets);
    expect(find.byKey(const ValueKey('product_listing_back_btn')), findsOneWidget);
    expect(find.byKey(const ValueKey('listing_search_icon')), findsOneWidget);

    // Filter & Sort
    expect(find.text('Filter'), findsOneWidget);
    expect(find.text('Sort'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Organic'), findsWidgets);

    // 2-Column Product Grid with sample products
    expect(find.text('Fresh Tomato'), findsOneWidget);
    expect(find.text('1 kg'), findsWidgets);
    expect(find.text('₹40'), findsOneWidget);

    expect(find.text('Farm Spinach (Palak)'), findsOneWidget);
    expect(find.text('₹20'), findsWidgets);

    // Tap ADD button on Fresh Tomato
    await tester.tap(find.byKey(const ValueKey('add_btn_v_tomato')));
    await tester.pumpAndSettle();

    // Verify Cart indicator appears
    expect(find.text('1 item added'), findsOneWidget);
    expect(find.text('View Cart'), findsOneWidget);

    // Back button returns to Categories
    await tester.tap(find.byKey(const ValueKey('product_listing_back_btn')));
    await tester.pumpAndSettle();

    expect(find.text('Shop Fresh'), findsOneWidget);
  });

  testWidgets('Freshly Product Details Screen renders hero image, benefits, delivery, stepper and Add to Cart',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap on Vegetables category
    await tester.tap(find.text('Categories'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('cat_card_veg')));
    await tester.pumpAndSettle();

    // Tap on Fresh Tomato card title/image to open Product Details
    await tester.tap(find.byKey(const ValueKey('product_card_title_v_tomato')));
    await tester.pumpAndSettle();

    // 1. Details Header & Icons
    expect(find.byKey(const ValueKey('product_details_back_btn')), findsOneWidget);
    expect(find.byKey(const ValueKey('product_details_favorite_btn')), findsOneWidget);
    expect(find.byKey(const ValueKey('product_details_share_btn')), findsOneWidget);

    // 2. Product Name, Rating & Unit
    expect(find.text('Fresh Tomato'), findsWidgets);
    expect(find.text('(340 reviews)'), findsOneWidget);
    expect(find.text('Select Pack Size'), findsOneWidget);

    // 3. Stepper (+ / -)
    expect(find.text('Quantity'), findsOneWidget);
    expect(find.byKey(const ValueKey('stepper_increment_btn')), findsOneWidget);
    expect(find.byKey(const ValueKey('stepper_decrement_btn')), findsOneWidget);

    // Tap increment to make quantity 2
    await tester.ensureVisible(find.byKey(const ValueKey('stepper_increment_btn')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('stepper_increment_btn')));
    await tester.pumpAndSettle();
    expect(find.text('2'), findsWidgets);

    // 4. Quality Guarantee Banner & Delivery Info
    expect(find.text('Freshly Farm-Purity Guarantee'), findsOneWidget);
    expect(find.text('Morning Harvest Delivery'), findsOneWidget);

    // 5. Product Description & Key Benefits
    expect(find.text('Product Description'), findsOneWidget);
    expect(find.text('Key Benefits'), findsOneWidget);
    expect(find.text('Farm Origin'), findsOneWidget);

    // 6. Sticky Bottom Bar with Total Price & Add to Cart
    expect(find.text('Total Price'), findsOneWidget);
    expect(find.text('₹80'), findsOneWidget); // 2 * 40
    expect(find.byKey(const ValueKey('details_add_to_cart_btn')), findsOneWidget);

    // Tap Add to Cart
    await tester.tap(find.byKey(const ValueKey('details_add_to_cart_btn')));
    await tester.pumpAndSettle();

    // Returned to Product Listing with 2 items added
    expect(find.text('2 items added'), findsOneWidget);
  });
}
