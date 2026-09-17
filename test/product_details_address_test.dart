import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taazabazar/features/location/data/address_repository.dart';
import 'package:taazabazar/features/location/domain/models/delivery_address.dart';
import 'package:taazabazar/features/location/presentation/saved_addresses_screen.dart';
import 'package:taazabazar/features/products/data/mock_products_data.dart';
import 'package:taazabazar/features/products/presentation/product_details_screen.dart';

void main() {
  final sampleProduct = MockProductsData.allProducts.first;

  group('ProductDetailsScreen Address Display Tests', () {
    testWidgets('Displays real saved default address when present', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Seed repository with a test default address
      final testAddr = DeliveryAddress(
        id: 'addr_real_1',
        label: 'Home',
        flatNo: 'Villa 12',
        building: 'Palm Meadows',
        street: 'Main Road',
        area: 'Jubilee Hills',
        city: 'Hyderabad',
        state: 'Telangana',
        pincode: '500033',
        isDefault: true,
        latitude: 17.432,
        longitude: 78.407,
      );
      AddressRepository().setInitialCache([testAddr]);

      await tester.pumpWidget(
        MaterialApp(
          home: ProductDetailsScreen(product: sampleProduct),
        ),
      );
      await tester.pumpAndSettle();

      // Verify formatted address is displayed
      expect(find.byKey(const ValueKey('product_details_address_text')), findsOneWidget);
      expect(find.textContaining('Villa 12, Palm Meadows'), findsOneWidget);
      expect(find.textContaining('Jubilee Hills, Hyderabad'), findsOneWidget);

      // Verify old hardcoded string does NOT appear
      expect(find.text('Deliver to: Flat 402, Oakwood, Shadnagar'), findsNothing);
    });

    testWidgets('Displays neutral "Add delivery address" state when no saved address exists', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Clear cached addresses
      AddressRepository().setInitialCache([]);

      await tester.pumpWidget(
        MaterialApp(
          home: ProductDetailsScreen(product: sampleProduct),
        ),
      );
      await tester.pumpAndSettle();

      // Verify neutral fallback is displayed
      expect(find.byKey(const ValueKey('product_details_address_text')), findsOneWidget);
      expect(find.text('Deliver to: Add delivery address'), findsOneWidget);

      // Verify old hardcoded address is NOT displayed
      expect(find.text('Deliver to: Flat 402, Oakwood, Shadnagar'), findsNothing);
    });

    testWidgets('Tapping address row navigates to SavedAddressesScreen', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      AddressRepository().setInitialCache([]);

      await tester.pumpWidget(
        MaterialApp(
          home: ProductDetailsScreen(product: sampleProduct),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on address row
      await tester.ensureVisible(find.byKey(const ValueKey('product_details_address_row')));
      await tester.tap(find.byKey(const ValueKey('product_details_address_row')));
      await tester.pumpAndSettle();

      // Verify SavedAddressesScreen is opened
      expect(find.byType(SavedAddressesScreen), findsOneWidget);
    });
  });
}
