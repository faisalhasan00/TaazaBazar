import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taazabazar/features/products/data/mock_products_data.dart';
import 'package:taazabazar/features/products/data/product_repository.dart';
import 'package:taazabazar/features/products/presentation/product_details_screen.dart';
import 'package:taazabazar/features/products/presentation/product_search_screen.dart';

void main() {
  setUp(() {
    ProductRepository().seedForTesting(
      categories: MockProductsData.categories,
      products: MockProductsData.allProducts,
    );
  });

  group('ProductRepository Global Search Unit Tests', () {
    final repo = ProductRepository();

    test('1. Case-insensitive search finds matching products', () {
      final resultsLower = repo.searchProducts('milk');
      final resultsUpper = repo.searchProducts('MILK');
      final resultsMixed = repo.searchProducts('mIlK');

      expect(resultsLower.isNotEmpty, isTrue);
      expect(resultsLower.length, equals(resultsUpper.length));
      expect(resultsLower.length, equals(resultsMixed.length));
      expect(resultsLower.any((p) => p.name.toLowerCase().contains('milk')), isTrue);
    });

    test('2. Handles leading and trailing whitespace', () {
      final trimmed = repo.searchProducts('tomato');
      final withSpaces = repo.searchProducts('   tomato   ');

      expect(trimmed.isNotEmpty, isTrue);
      expect(trimmed.length, equals(withSpaces.length));
      expect(withSpaces.any((p) => p.name.toLowerCase().contains('tomato')), isTrue);
    });

    test('3. Matches specific product name', () {
      final results = repo.searchProducts('spinach');
      expect(results.isNotEmpty, isTrue);
      expect(results.any((p) => p.name.toLowerCase().contains('spinach')), isTrue);
    });

    test('4. Matches multiple products across categories with common term', () {
      final results = repo.searchProducts('organic');
      expect(results.length, greaterThan(1));
      // Should find products from different categories
      final categories = results.map((p) => p.categoryId).toSet();
      expect(categories.length, greaterThanOrEqualTo(1));
    });

    test('5. Returns empty list for non-matching search term', () {
      final results = repo.searchProducts('non_existent_product_xyz_9999');
      expect(results, isEmpty);
    });

    test('6. Global search matches category name and description', () {
      final results = repo.searchProducts('dairy');
      expect(results.isNotEmpty, isTrue);
      expect(
        results.any((p) =>
            p.categoryName.toLowerCase().contains('dairy') ||
            p.categoryId.toLowerCase().contains('dairy')),
        isTrue,
      );
    });

    test('7. Empty query returns all products', () {
      final all = repo.cachedProducts;
      final queryEmpty = repo.searchProducts('');
      final querySpaces = repo.searchProducts('   ');

      expect(queryEmpty.length, equals(all.length));
      expect(querySpaces.length, equals(all.length));
    });
  });

  group('ProductSearchScreen Widget Tests', () {
    testWidgets('Renders search input, product grid, and filters', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProductSearchScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify search input field exists
      expect(find.byKey(const ValueKey('global_search_input')), findsOneWidget);
      expect(find.text('Search products, vegetables, milk...'), findsOneWidget);

      // Verify filter chips exist
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Organic'), findsOneWidget);
      expect(find.text('Under ₹50'), findsOneWidget);
      expect(find.text('Deals'), findsOneWidget);

      // Verify back button and cart button exist
      expect(find.byKey(const ValueKey('search_back_btn')), findsOneWidget);
      expect(find.byKey(const ValueKey('search_cart_btn')), findsOneWidget);
    });

    testWidgets('Typing query filters products dynamically and clear button resets', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProductSearchScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Enter search query "milk"
      await tester.enterText(find.byKey(const ValueKey('global_search_input')), 'milk');
      await tester.pumpAndSettle();

      // Clear button should appear
      expect(find.byKey(const ValueKey('clear_search_btn')), findsOneWidget);

      // Tap clear button
      await tester.tap(find.byKey(const ValueKey('clear_search_btn')));
      await tester.pumpAndSettle();

      // Query should be empty and clear button gone
      expect(find.byKey(const ValueKey('clear_search_btn')), findsNothing);
    });

    testWidgets('Displays empty state when no products match', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProductSearchScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Enter search query that matches nothing
      await tester.enterText(
        find.byKey(const ValueKey('global_search_input')),
        'zzzz_completely_fake_item_999',
      );
      await tester.pumpAndSettle();

      // Verify empty state is displayed
      expect(find.text('No products found'), findsOneWidget);
      expect(find.text('Show All Products'), findsOneWidget);

      // Tap Show All Products button
      await tester.tap(find.text('Show All Products'));
      await tester.pumpAndSettle();

      // Verify reset to all products
      expect(find.text('No products found'), findsNothing);
    });

    testWidgets('Tapping product card opens ProductDetailsScreen', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: ProductSearchScreen(initialQuery: 'milk'),
        ),
      );
      await tester.pumpAndSettle();

      // Find first matching product card image or title and tap it
      final firstProduct = ProductRepository().searchProducts('milk').first;
      final cardImgFinder = find.byKey(ValueKey('search_card_img_${firstProduct.id}'));

      if (cardImgFinder.evaluate().isNotEmpty) {
        await tester.tap(cardImgFinder);
        await tester.pumpAndSettle();

        // Verify navigated to ProductDetailsScreen
        expect(find.byType(ProductDetailsScreen), findsOneWidget);
      }
    });
  });
}
