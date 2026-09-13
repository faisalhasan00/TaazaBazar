import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freshly/features/auth/presentation/login_screen.dart';
import 'package:freshly/features/cart/domain/cart_item.dart';
import 'package:freshly/features/cart/presentation/cart_screen.dart';
import 'package:freshly/features/checkout/presentation/checkout_screen.dart';
import 'package:freshly/features/home/presentation/home_screen.dart';
import 'package:freshly/features/location/presentation/address_confirmation_screen.dart';
import 'package:freshly/features/location/presentation/location_setup_screen.dart';
import 'package:freshly/features/location/presentation/manual_address_screen.dart';
import 'package:freshly/features/onboarding/presentation/onboarding_screen.dart';
import 'package:freshly/features/orders/presentation/order_tracking_screen.dart';
import 'package:freshly/features/orders/presentation/orders_screen.dart';
import 'package:freshly/features/products/data/mock_products_data.dart';
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

  testWidgets('Freshly Cart Screen renders items, quantity controls, coupons, and checkout flow',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: CartScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. App Bar: My Cart and items count
    expect(find.text('My Cart'), findsOneWidget);
    expect(find.byKey(const ValueKey('cart_back_button')), findsOneWidget);
    expect(find.byKey(const ValueKey('clear_cart_btn')), findsOneWidget);

    // 2. Delivery Address Card
    expect(find.text('Delivering to Home'), findsOneWidget);
    expect(find.byKey(const ValueKey('change_address_btn')), findsOneWidget);
    expect(find.textContaining('Morning Slot:'), findsOneWidget);

    // 3. Cart Items List
    expect(find.text('Items in Cart'), findsOneWidget);
    expect(find.text('Fresh Tomato'), findsOneWidget);
    expect(find.text('A2 Cow Milk'), findsOneWidget);
    expect(find.text('Organic Eggs'), findsOneWidget);

    // 4. Quantity Stepper
    expect(find.byKey(const ValueKey('cart_increment_v_tomato')), findsOneWidget);
    expect(find.byKey(const ValueKey('cart_decrement_v_tomato')), findsOneWidget);

    // Tap increment on tomato (starts at 2, goes to 3)
    await tester.tap(find.byKey(const ValueKey('cart_increment_v_tomato')));
    await tester.pumpAndSettle();
    expect(find.text('3'), findsWidgets);

    // 5. Add More Items Button
    await tester.ensureVisible(find.byKey(const ValueKey('add_more_items_btn')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('add_more_items_btn')), findsOneWidget);

    // 6. Promo Code / Coupons
    await tester.ensureVisible(find.byKey(const ValueKey('coupon_text_field')));
    await tester.pumpAndSettle();
    expect(find.text('Coupons & Offers'), findsOneWidget);
    expect(find.byKey(const ValueKey('coupon_text_field')), findsOneWidget);
    expect(find.byKey(const ValueKey('apply_coupon_btn')), findsOneWidget);

    // Apply FRESH50 coupon
    await tester.enterText(find.byKey(const ValueKey('coupon_text_field')), 'FRESH50');
    await tester.tap(find.byKey(const ValueKey('apply_coupon_btn')));
    await tester.pumpAndSettle();

    expect(find.text('Code "FRESH50" Applied'), findsOneWidget);
    expect(find.byKey(const ValueKey('remove_coupon_btn')), findsOneWidget);

    // 7. Bill Details / Summary
    await tester.ensureVisible(find.text('Bill Details'));
    await tester.pumpAndSettle();
    expect(find.text('Bill Details'), findsOneWidget);
    expect(find.text('Item Total'), findsOneWidget);
    expect(find.text('Delivery Partner Fee'), findsOneWidget);
    expect(find.text('Grand Total'), findsOneWidget);

    // 8. Sticky Proceed to Checkout button
    expect(find.byKey(const ValueKey('proceed_to_checkout_btn')), findsOneWidget);
    expect(find.text('TOTAL TO PAY'), findsOneWidget);

    // Tap Proceed to Checkout to go to CheckoutScreen
    await tester.tap(find.byKey(const ValueKey('proceed_to_checkout_btn')));
    await tester.pumpAndSettle();

    // Verify CheckoutScreen is opened
    expect(find.text('Checkout'), findsOneWidget);
    expect(find.text('Delivery Address'), findsOneWidget);
    expect(find.text('Delivery Schedule'), findsOneWidget);
    expect(find.text('Payment Method'), findsOneWidget);
    expect(find.text('Bill Summary'), findsOneWidget);
    expect(find.byKey(const ValueKey('place_order_btn')), findsOneWidget);

    // Tap Place Order
    await tester.tap(find.byKey(const ValueKey('place_order_btn')));
    await tester.pumpAndSettle();

    // Verify OrderSuccessScreen is opened with mock Order ID and delivery info
    expect(find.text('Order Placed Successfully!'), findsOneWidget);
    expect(find.text('Order ID'), findsOneWidget);
    expect(find.byKey(const ValueKey('order_id_text')), findsOneWidget);
    expect(find.textContaining('FRSH-'), findsOneWidget);
    expect(find.byKey(const ValueKey('estimated_delivery_text')), findsOneWidget);
    expect(find.byKey(const ValueKey('order_success_home_btn')), findsOneWidget);

    // Tap Back to Home
    await tester.tap(find.byKey(const ValueKey('order_success_home_btn')));
    await tester.pumpAndSettle();
    expect(find.text('Fresh Deals'), findsOneWidget);
  });

  testWidgets('Freshly Empty Cart state displays illustration, message, and start shopping button',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CartScreen(initialItems: []),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('My Cart'), findsOneWidget);
    expect(find.text('Your cart is empty'), findsOneWidget);
    expect(
      find.text(
        'Looks like you haven’t added anything to your cart yet. Explore fresh produce, milk & daily essentials from local organic farms.',
      ),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('start_shopping_btn')), findsOneWidget);
    expect(find.text('Daily Fresh Essentials'), findsOneWidget);
  });

  testWidgets('Freshly Checkout Screen allows slot selection, payment choice and place order',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final mockItems = [
      CartItem(
        product: MockProductsData.allProducts[0],
        quantity: 2,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: CheckoutScreen(
          items: mockItems,
          appliedCoupon: 'FRESH50',
          couponDiscount: 50,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Checkout Header & Address
    expect(find.text('Checkout'), findsOneWidget);
    expect(find.text('Delivery Address'), findsOneWidget);
    expect(find.byKey(const ValueKey('checkout_change_address_btn')), findsOneWidget);

    // Verify Schedule & Slots
    expect(find.text('Delivery Schedule'), findsOneWidget);
    expect(find.text('6:00 AM – 8:00 AM'), findsOneWidget);
    expect(find.text('8:00 AM – 10:00 AM'), findsOneWidget);

    // Select evening slot
    await tester.tap(find.text('5:00 PM – 7:00 PM'));
    await tester.pumpAndSettle();

    // Verify Payment Method selection
    expect(find.text('Payment Method'), findsOneWidget);
    expect(find.byKey(const ValueKey('payment_method_upi')), findsOneWidget);
    expect(find.byKey(const ValueKey('payment_method_card')), findsOneWidget);

    // Select UPI
    await tester.tap(find.byKey(const ValueKey('payment_method_upi')));
    await tester.pumpAndSettle();

    // Verify Bill Summary
    expect(find.text('Bill Summary'), findsOneWidget);
    expect(find.text('Item Total'), findsOneWidget);
    expect(find.text('Coupon Discount (FRESH50)'), findsOneWidget);

    // Tap Place Order
    expect(find.byKey(const ValueKey('place_order_btn')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('place_order_btn')));
    await tester.pumpAndSettle();

    // Order Success Screen rendered
    expect(find.text('Order Placed Successfully!'), findsOneWidget);
    expect(find.byKey(const ValueKey('order_id_text')), findsOneWidget);
    expect(find.text('Instant UPI'), findsOneWidget);
    expect(find.text('Mock Paid'), findsOneWidget);
  });

  testWidgets('Freshly Orders Screen displays active tabs, timeline, track order and details',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: OrdersScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify App Bar & Tabs
    expect(find.text('My Orders'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Previous'), findsOneWidget);

    // Verify Active Order Card
    expect(find.text('#FRSH-89421'), findsOneWidget);
    expect(find.text('Out for Delivery'), findsWidgets);
    expect(find.text('LIVE STATUS'), findsWidgets);
    expect(find.text('Track Order'), findsWidgets);
    expect(find.text('View Details'), findsWidgets);

    // Open Track Order Screen
    await tester.tap(find.text('Track Order').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Track Order'), findsOneWidget);
    expect(find.text('LIVE TRACKING'), findsOneWidget);
    expect(find.text('Your Fresh Produce is on the Way! 🚴'), findsOneWidget);
    expect(find.text('Sunrise Organic Farm'), findsOneWidget);
    expect(find.text('Indiranagar Home'), findsOneWidget);
    expect(find.text('Ramesh Kumar'), findsOneWidget);
    expect(find.text('Delivery Safety PIN: 4821'), findsOneWidget);
    expect(find.text('Milestone Details'), findsOneWidget);
    expect(find.text('Call Partner'), findsOneWidget);

    // Open Need Help Modal
    expect(find.text('Need Help?'), findsOneWidget);
    await tester.tap(find.text('Need Help?'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Chat with Freshly Support'), findsOneWidget);
    expect(find.text('Change Delivery Instructions'), findsOneWidget);

    // Close help modal
    await tester.tap(find.text('Change Delivery Instructions'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Pop back to Orders Screen
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    // Open Order Details Sheet
    await tester.tap(find.text('View Details').first);
    await tester.pumpAndSettle();

    expect(find.text('Order Details'), findsOneWidget);
    expect(find.text('Bill Summary'), findsOneWidget);
    expect(find.text('Grand Total'), findsOneWidget);
    expect(find.text('Invoice'), findsOneWidget);

    // Close Details Sheet
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    // Switch to Previous Orders Tab
    await tester.tap(find.text('Previous'));
    await tester.pumpAndSettle();

    // Verify Previous Orders
    expect(find.text('#FRSH-74109'), findsOneWidget);
    expect(find.text('DELIVERED'), findsWidgets);
    expect(find.text('Reorder'), findsWidgets);
    expect(find.text('Produce Freshness:'), findsWidgets);

    // Tap Reorder
    await tester.ensureVisible(find.text('Reorder').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reorder').first);
    await tester.pumpAndSettle();
    expect(find.text('Added 4 items from #FRSH-74109 back to your cart! 🛒'), findsOneWidget);
  });

  testWidgets('Freshly Order Tracking Screen renders map, rider card, timeline, address and items',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: OrderTrackingScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify App bar & Hero
    expect(find.text('Track Order'), findsOneWidget);
    expect(find.text('#FRSH-89421'), findsOneWidget);
    expect(find.text('Your Fresh Produce is on the Way! 🚴'), findsOneWidget);
    expect(find.text('100% Insulated Cold-Chain & Chemical Free'), findsOneWidget);

    // Verify Mock Vector Map
    expect(find.text('Sunrise Organic Farm'), findsOneWidget);
    expect(find.text('Indiranagar Home'), findsOneWidget);
    expect(find.text('2.4 km away • ETA 15 mins'), findsOneWidget);

    // Verify Status Timeline
    expect(find.text('Order Status Timeline'), findsOneWidget);
    expect(find.text('LIVE STATUS'), findsOneWidget);

    // Verify Delivery Partner Card
    expect(find.text('Delivery Partner'), findsOneWidget);
    expect(find.text('Ramesh Kumar'), findsOneWidget);
    expect(find.text('Freshly Super Rider • 4.9 ★ (1,240 drops)'), findsOneWidget);
    expect(find.text('Delivery Safety PIN: 4821'), findsOneWidget);

    // Verify Delivery Address & Ordered Items
    expect(find.text('Delivery Address'), findsOneWidget);
    expect(find.text('Ordered Items (3)'), findsOneWidget);
    expect(find.text('Total Amount Paid'), findsOneWidget);
    expect(find.text('₹240'), findsOneWidget);
  });
}


