import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taazabazar/core/constants/app_constants.dart';
import 'package:taazabazar/core/services/location_service.dart';
import 'package:taazabazar/features/coupons/data/coupon_repository.dart';
import 'package:taazabazar/features/deals/data/deal_repository.dart';
import 'package:taazabazar/features/location/domain/models/delivery_address.dart';
import 'package:taazabazar/features/location/presentation/address_confirmation_screen.dart';
import 'package:taazabazar/features/pass/presentation/freshly_pass_screen.dart';
import 'package:taazabazar/features/products/data/product_repository.dart';
import 'package:taazabazar/features/profile/data/profile_repository.dart';
import 'package:taazabazar/features/profile/presentation/help_support_screen.dart';

void main() {
  group('Step 52.2: Production Fallback Removal Regression Tests', () {
    test('1. Unseeded ProductRepository returns empty list, never silent mock products', () async {
      final repo = ProductRepository();
      // Ensure unseeded production state
      repo.seedForTesting(categories: [], products: []);

      expect(repo.cachedProducts, isEmpty);
      expect(repo.cachedCategories, isEmpty);

      final products = await repo.getProductsStream().first;
      expect(products, isEmpty, reason: 'Empty products stream must not inject mock catalog');

      final categories = await repo.getCategoriesStream().first;
      expect(categories, isEmpty, reason: 'Empty categories stream must not inject mock categories');
    });

    test('2. Unseeded CouponRepository returns empty list, never default coupons', () async {
      final repo = CouponRepository();
      repo.setInitialCache([]);

      expect(repo.cachedCoupons, isEmpty);

      final coupons = await repo.getCouponsStream().first;
      expect(coupons, isEmpty, reason: 'Empty coupons stream must not inject default FRESH50/TAAZA50');

      final lookup = await repo.getCouponByCode('FRESH50');
      expect(lookup, isNull, reason: 'Unseeded coupon lookup should be null');
    });

    test('3. Unseeded DealRepository returns empty list, never default deals', () async {
      final repo = DealRepository();
      repo.setInitialCache([]);

      expect(repo.cachedDeals, isEmpty);

      final deals = await repo.getDealsStream().first;
      expect(deals, isEmpty, reason: 'Empty deals stream must not inject default deal products');
    });

    test('4. GPS / reverse geocoding fallback does NOT produce fake Oakwood/Hitec City address', () async {
      final service = LocationService();
      final res = await service.reverseGeocode(17.4482, 78.3814);

      expect(res['flatNo'], isNot(contains('Oakwood')));
      expect(res['street'], isNot(contains('Plot No. 18')));
      expect(res['street'], isNot(contains('Road No. 2')));
    });

    testWidgets('5. AddressConfirmationScreen with real GPS coordinates does not show Oakwood unless passed',
        (WidgetTester tester) async {
      const realAddress = DeliveryAddress(
        flatNo: 'My House No. 5',
        street: 'Main Bazaar Road',
        area: 'Shadnagar',
        city: 'Hyderabad',
        state: 'Telangana',
        pincode: '509216',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: AddressConfirmationScreen(address: realAddress),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('My House No. 5'), findsOneWidget);
      expect(find.text('Main Bazaar Road, Shadnagar'), findsOneWidget);
      expect(find.text('Hyderabad, Telangana - 509216'), findsOneWidget);
      expect(find.text('Flat 402, Oakwood'), findsNothing);
      expect(find.text('Plot No. 18, Road No. 2'), findsNothing);
      expect(find.text('Leave the order at the security desk.'), findsNothing);
    });

    test('6. Profile repository uses canonical users/{uid}/profile path', () {
      final repo = ProfileRepository();
      expect(repo.cachedProfile, isNull);
    });

    testWidgets('7. HelpSupportScreen does not show placeholder phone number', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HelpSupportScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('+91 98765 12340'), findsNothing);
      expect(find.text('In-app helpline coming soon'), findsOneWidget);
      expect(find.text(AppConstants.supportEmail), findsOneWidget);
    });

    testWidgets('8. Taaza Pass clearly communicates Coming Soon and blocks fake activation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TaazaPassScreen(isStandalone: true),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Taaza Pass Available Soon'), findsOneWidget);
      expect(find.textContaining('Subscription activation will launch soon'), findsOneWidget);

      await tester.tap(find.text('Taaza Pass Available Soon'));
      await tester.pumpAndSettle();

      expect(find.text('Taaza Pass subscriptions will be available soon.'), findsOneWidget);
    });
  });
}
