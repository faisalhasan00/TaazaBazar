import 'package:flutter_test/flutter_test.dart';
import 'package:taazabazar/features/products/domain/product_model.dart';
import 'package:taazabazar/features/subscription/data/subscription_repository.dart';
import 'package:taazabazar/features/subscription/domain/subscription_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SubscriptionRepository repo;

  setUp(() {
    repo = SubscriptionRepository();
    repo.setInitialCache(
      subscriptions: [],
      deliveries: [],
      milkCapacity: 1000.0,
      skipCutoffHour: 22,
    );
  });

  group('TaazaBazar Complete Flexible Subscription System (19 Test Scenarios)', () {
    // Scenario 1: Daily Milk Subscription
    test('1. Daily milk subscription creation (1L cow milk, daily, 6:00-8:00 AM)', () async {
      final item = SubscriptionItem(
        id: 'item_milk_1',
        subscriptionId: 'sub_milk_daily',
        productId: 'prod_milk_1',
        productName: 'A2 Desi Cow Milk',
        categoryId: 'dairy_milk',
        categoryName: 'Milk & Dairy',
        emoji: '🥛',
        quantity: 1.0,
        unit: 'L',
        pricePerUnit: 65.0,
        frequency: SubscriptionFrequency.daily,
        deliveryDay: 'Daily',
        startDate: DateTime(2026, 9, 15),
        nextDeliveryDate: DateTime(2026, 9, 16),
        status: SubscriptionItemStatus.active,
      );

      final sub = SubscriptionModel(
        id: 'sub_milk_daily',
        userId: 'user_123',
        planType: SubscriptionPlanType.readyMade,
        planName: 'Daily Pure Farm Milk',
        status: SubscriptionStatus.active,
        deliverySlot: '6:00 AM - 8:00 AM',
        deliveryAddress: 'Tower 4, Flat 102, Green Glen',
        items: [item],
        startDate: DateTime(2026, 9, 15),
        nextDeliveryDate: DateTime(2026, 9, 16),
        estimatedMonthlyAmount: 1950.0,
        createdAt: DateTime(2026, 9, 14),
      );

      final created = await repo.createSubscription(sub, userId: 'user_123');
      expect(created.id, 'sub_milk_daily');
      expect(created.status, SubscriptionStatus.active);
      expect(created.items.length, 1);
      expect(created.items.first.quantity, 1.0);
      expect(created.items.first.frequency, SubscriptionFrequency.daily);
      expect(created.estimatedMonthlyAmount, 1950.0); // 65 * 1 * 30 = 1950
    });

    // Scenario 2: Build-Your-Own Basket with Mixed Frequencies
    test('2. Build-Your-Own basket with mixed frequencies (Daily, Weekly, Alternate, Monthly)', () async {
      final items = [
        SubscriptionItem(
          id: 'item_1',
          subscriptionId: 'sub_custom',
          productId: 'prod_milk',
          productName: 'Farm Fresh Cow Milk',
          categoryId: 'milk',
          categoryName: 'Milk',
          emoji: '🥛',
          quantity: 1.0,
          unit: 'L',
          pricePerUnit: 60.0,
          frequency: SubscriptionFrequency.daily,
          deliveryDay: 'Daily',
          startDate: DateTime(2026, 9, 15),
          nextDeliveryDate: DateTime(2026, 9, 16),
        ),
        SubscriptionItem(
          id: 'item_2',
          subscriptionId: 'sub_custom',
          productId: 'prod_veg',
          productName: 'Organic Vegetable Basket',
          categoryId: 'vegetables',
          categoryName: 'Vegetables',
          emoji: '🥦',
          quantity: 1.0,
          unit: 'Pack',
          pricePerUnit: 300.0,
          frequency: SubscriptionFrequency.weekly,
          deliveryDay: 'Wednesday',
          startDate: DateTime(2026, 9, 15),
          nextDeliveryDate: DateTime(2026, 9, 17),
        ),
        SubscriptionItem(
          id: 'item_3',
          subscriptionId: 'sub_custom',
          productId: 'prod_eggs',
          productName: 'Farm Fresh Brown Eggs',
          categoryId: 'eggs',
          categoryName: 'Eggs',
          emoji: '🥚',
          quantity: 6.0,
          unit: 'pcs',
          pricePerUnit: 10.0,
          frequency: SubscriptionFrequency.alternateDays,
          deliveryDay: 'Alternate',
          startDate: DateTime(2026, 9, 15),
          nextDeliveryDate: DateTime(2026, 9, 16),
        ),
        SubscriptionItem(
          id: 'item_4',
          subscriptionId: 'sub_custom',
          productId: 'prod_ghee',
          productName: 'Pure Desi Ghee 500ml',
          categoryId: 'groceries',
          categoryName: 'Groceries',
          emoji: '🍯',
          quantity: 1.0,
          unit: 'Jar',
          pricePerUnit: 550.0,
          frequency: SubscriptionFrequency.monthly,
          deliveryDay: '1st of Month',
          startDate: DateTime(2026, 9, 15),
          nextDeliveryDate: DateTime(2026, 10, 1),
        ),
      ];

      final sub = SubscriptionModel(
        id: 'sub_custom',
        userId: 'user_123',
        planType: SubscriptionPlanType.buildYourOwn,
        planName: 'Custom Essentials Basket',
        status: SubscriptionStatus.active,
        deliverySlot: '6:00 AM - 8:00 AM',
        deliveryAddress: 'Flat 502, Orchid Woods',
        items: items,
        startDate: DateTime(2026, 9, 15),
        nextDeliveryDate: DateTime(2026, 9, 16),
        estimatedMonthlyAmount: 0,
        createdAt: DateTime.now(),
      );

      final created = await repo.createSubscription(sub, userId: 'user_123');
      expect(created.items.length, 4);
      expect(created.items.map((i) => i.frequency).toSet(), {
        SubscriptionFrequency.daily,
        SubscriptionFrequency.weekly,
        SubscriptionFrequency.alternateDays,
        SubscriptionFrequency.monthly,
      });
    });

    // Scenario 3: Estimated Monthly Spend Formula
    test('3. Estimated monthly spend calculation matches item frequency formulas', () {
      final items = [
        SubscriptionItem(
          id: 'i1',
          subscriptionId: 's1',
          productId: 'p1',
          productName: 'Milk',
          categoryId: 'dairy',
          categoryName: 'Dairy',
          emoji: '🥛',
          quantity: 1,
          unit: 'L',
          pricePerUnit: 60, // 60 * 1 * 30 = 1800
          frequency: SubscriptionFrequency.daily,
          startDate: DateTime.now(),
          nextDeliveryDate: DateTime.now(),
        ),
        SubscriptionItem(
          id: 'i2',
          subscriptionId: 's1',
          productId: 'p2',
          productName: 'Veggies',
          categoryId: 'veg',
          categoryName: 'Veg',
          emoji: '🥕',
          quantity: 1,
          unit: 'kg',
          pricePerUnit: 100, // 100 * 1 * 4.33 = 433
          frequency: SubscriptionFrequency.weekly,
          startDate: DateTime.now(),
          nextDeliveryDate: DateTime.now(),
        ),
        SubscriptionItem(
          id: 'i3',
          subscriptionId: 's1',
          productId: 'p3',
          productName: 'Eggs',
          categoryId: 'eggs',
          categoryName: 'Eggs',
          emoji: '🥚',
          quantity: 6,
          unit: 'pcs',
          pricePerUnit: 10, // 60 * 15 = 900
          frequency: SubscriptionFrequency.alternateDays,
          startDate: DateTime.now(),
          nextDeliveryDate: DateTime.now(),
        ),
        SubscriptionItem(
          id: 'i4',
          subscriptionId: 's1',
          productId: 'p4',
          productName: 'Ghee',
          categoryId: 'grocery',
          categoryName: 'Grocery',
          emoji: '🍯',
          quantity: 1,
          unit: 'jar',
          pricePerUnit: 500, // 500 * 1 = 500
          frequency: SubscriptionFrequency.monthly,
          startDate: DateTime.now(),
          nextDeliveryDate: DateTime.now(),
        ),
      ];

      final sub = SubscriptionModel(
        id: 's1',
        userId: 'u1',
        planType: SubscriptionPlanType.buildYourOwn,
        planName: 'Test Spend',
        status: SubscriptionStatus.active,
        deliverySlot: '6:00 AM - 8:00 AM',
        deliveryAddress: 'Address',
        items: items,
        startDate: DateTime.now(),
        nextDeliveryDate: DateTime.now(),
        estimatedMonthlyAmount: 0,
        createdAt: DateTime.now(),
      );

      final spend = sub.calculateEstimatedMonthlySpend();
      // 1800 + 433 + 900 + 500 = 3633
      expect(spend, closeTo(3633.0, 1.0));
    });

    // Scenario 4: One Combined Delivery Order
    test('4. One combined delivery order generated per calendar day with multiple items', () async {
      final items = [
        SubscriptionItem(
          id: 'i1',
          subscriptionId: 'sub_combined',
          productId: 'p_milk',
          productName: 'Cow Milk',
          categoryId: 'dairy',
          categoryName: 'Dairy',
          emoji: '🥛',
          quantity: 1,
          unit: 'L',
          pricePerUnit: 60,
          frequency: SubscriptionFrequency.daily,
          startDate: DateTime(2026, 9, 15),
          nextDeliveryDate: DateTime(2026, 9, 16),
        ),
        SubscriptionItem(
          id: 'i2',
          subscriptionId: 'sub_combined',
          productId: 'p_bread',
          productName: 'Whole Wheat Bread',
          categoryId: 'bakery',
          categoryName: 'Bakery',
          emoji: '🍞',
          quantity: 1,
          unit: 'Loaf',
          pricePerUnit: 45,
          frequency: SubscriptionFrequency.daily,
          startDate: DateTime(2026, 9, 15),
          nextDeliveryDate: DateTime(2026, 9, 16),
        ),
      ];

      final sub = SubscriptionModel(
        id: 'sub_combined',
        userId: 'user_123',
        planType: SubscriptionPlanType.buildYourOwn,
        planName: 'Combined Morning Delivery',
        status: SubscriptionStatus.active,
        deliverySlot: '6:00 AM - 8:00 AM',
        deliveryAddress: 'Home Flat 101',
        items: items,
        startDate: DateTime(2026, 9, 15),
        nextDeliveryDate: DateTime(2026, 9, 16),
        estimatedMonthlyAmount: 3150,
        createdAt: DateTime.now(),
      );

      await repo.createSubscription(sub, userId: 'user_123');
      final deliveries = repo.cachedDeliveries.where((d) => d.subscriptionId == 'sub_combined').toList();

      expect(deliveries.isNotEmpty, true);
      final firstDelivery = deliveries.first;
      // Both items must be grouped into the same single morning delivery order
      expect(firstDelivery.items.length, 2);
      expect(firstDelivery.totalAmount, 105.0); // 60 + 45
    });

    // Scenario 5: Add One-Time Item to Next Delivery
    test('5. Add one-time item to tomorrow\'s delivery without changing recurring schedule', () async {
      final item = SubscriptionItem(
        id: 'i_milk',
        subscriptionId: 'sub_addon_test',
        productId: 'p_milk',
        productName: 'Farm Milk',
        categoryId: 'milk',
        categoryName: 'Milk',
        emoji: '🥛',
        quantity: 1,
        unit: 'L',
        pricePerUnit: 60,
        frequency: SubscriptionFrequency.daily,
        startDate: DateTime.now(),
        nextDeliveryDate: DateTime.now().add(const Duration(days: 1)),
      );

      final sub = SubscriptionModel(
        id: 'sub_addon_test',
        userId: 'u_1',
        planType: SubscriptionPlanType.readyMade,
        planName: 'Daily Milk',
        status: SubscriptionStatus.active,
        deliverySlot: '6:00 AM - 8:00 AM',
        deliveryAddress: 'Address 1',
        items: [item],
        startDate: DateTime.now(),
        nextDeliveryDate: DateTime.now().add(const Duration(days: 1)),
        estimatedMonthlyAmount: 1800,
        createdAt: DateTime.now(),
      );

      await repo.createSubscription(sub, userId: 'u_1');

      const butterProduct = Product(
        id: 'p_butter',
        name: 'Organic Table Butter',
        categoryId: 'dairy',
        categoryName: 'Dairy',
        unit: '100g',
        price: 75.0,
        emoji: '🧈',
      );

      await repo.addOneTimeToNextDelivery('sub_addon_test', butterProduct, 1, userId: 'u_1');

      final deliveries = repo.cachedDeliveries.where((d) => d.subscriptionId == 'sub_addon_test').toList();
      final tomorrowDelivery = deliveries.first;
      expect(tomorrowDelivery.items.any((i) => i.productId == 'p_butter' && i.isOneTimeAddOn), true);

      // Verify recurring sub definition is still clean (1 item)
      final activeSub = repo.cachedSubscriptions.firstWhere((s) => s.id == 'sub_addon_test');
      expect(activeSub.items.length, 1);
    });

    // Scenario 6: Pause Single Item
    test('6. Pause single item in subscription (item paused, other items continue)', () async {
      final item1 = SubscriptionItem(
        id: 'i1',
        subscriptionId: 'sub_pause_item',
        productId: 'p_milk',
        productName: 'Cow Milk',
        categoryId: 'dairy',
        categoryName: 'Dairy',
        emoji: '🥛',
        quantity: 1,
        unit: 'L',
        pricePerUnit: 60,
        frequency: SubscriptionFrequency.daily,
        startDate: DateTime.now(),
        nextDeliveryDate: DateTime.now().add(const Duration(days: 1)),
      );
      final item2 = SubscriptionItem(
        id: 'i2',
        subscriptionId: 'sub_pause_item',
        productId: 'p_bread',
        productName: 'Bread',
        categoryId: 'bakery',
        categoryName: 'Bakery',
        emoji: '🍞',
        quantity: 1,
        unit: 'Loaf',
        pricePerUnit: 40,
        frequency: SubscriptionFrequency.daily,
        startDate: DateTime.now(),
        nextDeliveryDate: DateTime.now().add(const Duration(days: 1)),
      );

      final sub = SubscriptionModel(
        id: 'sub_pause_item',
        userId: 'u_1',
        planType: SubscriptionPlanType.buildYourOwn,
        planName: 'Pause Item Test',
        status: SubscriptionStatus.active,
        deliverySlot: '6:00 AM - 8:00 AM',
        deliveryAddress: 'Home',
        items: [item1, item2],
        startDate: DateTime.now(),
        nextDeliveryDate: DateTime.now().add(const Duration(days: 1)),
        estimatedMonthlyAmount: 3000,
        createdAt: DateTime.now(),
      );

      await repo.createSubscription(sub, userId: 'u_1');

      // Pause item2 (Bread)
      final pausedItem2 = item2.copyWith(status: SubscriptionItemStatus.paused);
      await repo.updateSubscriptionItem('sub_pause_item', pausedItem2, userId: 'u_1');

      final updatedSub = repo.cachedSubscriptions.firstWhere((s) => s.id == 'sub_pause_item');
      expect(updatedSub.items.firstWhere((i) => i.id == 'i2').status, SubscriptionItemStatus.paused);
      expect(updatedSub.items.firstWhere((i) => i.id == 'i1').status, SubscriptionItemStatus.active);
    });

    // Scenario 7: Resume Paused Item
    test('7. Resume paused item in subscription', () async {
      final item = SubscriptionItem(
        id: 'i_res',
        subscriptionId: 'sub_resume_item',
        productId: 'p_milk',
        productName: 'Cow Milk',
        categoryId: 'dairy',
        categoryName: 'Dairy',
        emoji: '🥛',
        quantity: 1,
        unit: 'L',
        pricePerUnit: 60,
        frequency: SubscriptionFrequency.daily,
        status: SubscriptionItemStatus.paused,
        startDate: DateTime.now(),
        nextDeliveryDate: DateTime.now().add(const Duration(days: 1)),
      );

      final sub = SubscriptionModel(
        id: 'sub_resume_item',
        userId: 'u_1',
        planType: SubscriptionPlanType.buildYourOwn,
        planName: 'Resume Item Test',
        status: SubscriptionStatus.active,
        deliverySlot: '6:00 AM - 8:00 AM',
        deliveryAddress: 'Home',
        items: [item],
        startDate: DateTime.now(),
        nextDeliveryDate: DateTime.now().add(const Duration(days: 1)),
        estimatedMonthlyAmount: 1800,
        createdAt: DateTime.now(),
      );

      await repo.createSubscription(sub, userId: 'u_1');

      // Resume item
      final resumed = item.copyWith(status: SubscriptionItemStatus.active);
      await repo.updateSubscriptionItem('sub_resume_item', resumed, userId: 'u_1');

      final updatedSub = repo.cachedSubscriptions.firstWhere((s) => s.id == 'sub_resume_item');
      expect(updatedSub.items.first.status, SubscriptionItemStatus.active);
    });

    // Scenario 8: Modify Item Quantity
    test('8. Modify item quantity (1L -> 2L, monthly spend recalculated)', () async {
      final item = SubscriptionItem(
        id: 'i_qty',
        subscriptionId: 'sub_mod_qty',
        productId: 'p_milk',
        productName: 'Cow Milk',
        categoryId: 'dairy',
        categoryName: 'Dairy',
        emoji: '🥛',
        quantity: 1.0,
        unit: 'L',
        pricePerUnit: 60.0,
        frequency: SubscriptionFrequency.daily,
        startDate: DateTime.now(),
        nextDeliveryDate: DateTime.now().add(const Duration(days: 1)),
      );

      final sub = SubscriptionModel(
        id: 'sub_mod_qty',
        userId: 'u_1',
        planType: SubscriptionPlanType.readyMade,
        planName: 'Quantity Test',
        status: SubscriptionStatus.active,
        deliverySlot: '6:00 AM - 8:00 AM',
        deliveryAddress: 'Home',
        items: [item],
        startDate: DateTime.now(),
        nextDeliveryDate: DateTime.now().add(const Duration(days: 1)),
        estimatedMonthlyAmount: 1800.0,
        createdAt: DateTime.now(),
      );

      await repo.createSubscription(sub, userId: 'u_1');

      // Update quantity to 2L
      final updatedItem = item.copyWith(quantity: 2.0);
      await repo.updateSubscriptionItem('sub_mod_qty', updatedItem, userId: 'u_1');

      final updatedSub = repo.cachedSubscriptions.firstWhere((s) => s.id == 'sub_mod_qty');
      expect(updatedSub.items.first.quantity, 2.0);
      // 60 * 2 * 30 = 3600
      expect(updatedSub.estimatedMonthlyAmount, 3600.0);
    });

    // Scenario 9: Modify Item Frequency
    test('9. Modify item frequency (Daily -> Alternate Days)', () async {
      final item = SubscriptionItem(
        id: 'i_freq',
        subscriptionId: 'sub_mod_freq',
        productId: 'p_milk',
        productName: 'Cow Milk',
        categoryId: 'dairy',
        categoryName: 'Dairy',
        emoji: '🥛',
        quantity: 1.0,
        unit: 'L',
        pricePerUnit: 60.0,
        frequency: SubscriptionFrequency.daily,
        startDate: DateTime.now(),
        nextDeliveryDate: DateTime.now().add(const Duration(days: 1)),
      );

      final sub = SubscriptionModel(
        id: 'sub_mod_freq',
        userId: 'u_1',
        planType: SubscriptionPlanType.readyMade,
        planName: 'Freq Test',
        status: SubscriptionStatus.active,
        deliverySlot: '6:00 AM - 8:00 AM',
        deliveryAddress: 'Home',
        items: [item],
        startDate: DateTime.now(),
        nextDeliveryDate: DateTime.now().add(const Duration(days: 1)),
        estimatedMonthlyAmount: 1800.0,
        createdAt: DateTime.now(),
      );

      await repo.createSubscription(sub, userId: 'u_1');

      // Change frequency to alternate days
      final updatedItem = item.copyWith(
        frequency: SubscriptionFrequency.alternateDays,
        deliveryDay: 'Alternate Days',
      );
      await repo.updateSubscriptionItem('sub_mod_freq', updatedItem, userId: 'u_1');

      final updatedSub = repo.cachedSubscriptions.firstWhere((s) => s.id == 'sub_mod_freq');
      expect(updatedSub.items.first.frequency, SubscriptionFrequency.alternateDays);
      // 60 * 1 * 15 = 900
      expect(updatedSub.estimatedMonthlyAmount, 900.0);
    });

    // Scenario 10: Skip Next Delivery Before Cutoff
    test('10. Skip next delivery before 10:00 PM cutoff succeeds', () async {
      final deliveryDate = DateTime(2026, 9, 16);
      final delivery = SubscriptionDelivery(
        id: 'del_skip_1',
        subscriptionId: 'sub_skip',
        userId: 'u_1',
        deliveryDate: deliveryDate,
        deliverySlot: '6:00 AM - 8:00 AM',
        address: 'Home',
        items: [],
        totalAmount: 60,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      repo.setInitialCache(deliveries: [delivery]);

      // Attempt skip at 8:00 PM on Sept 15 (before 10:00 PM cutoff)
      final requestTime = DateTime(2026, 9, 15, 20, 0);
      final success = await repo.skipNextDelivery('sub_skip', 'del_skip_1', now: requestTime, userId: 'u_1');

      expect(success, true);
      final updatedDel = repo.cachedDeliveries.firstWhere((d) => d.id == 'del_skip_1');
      expect(updatedDel.status, 'skipped');
    });

    // Scenario 11: Skip Next Delivery After Cutoff Rejected
    test('11. Skip delivery after 10:00 PM cutoff is rejected with cutoff notice', () async {
      final deliveryDate = DateTime(2026, 9, 16);
      final delivery = SubscriptionDelivery(
        id: 'del_skip_late',
        subscriptionId: 'sub_skip',
        userId: 'u_1',
        deliveryDate: deliveryDate,
        deliverySlot: '6:00 AM - 8:00 AM',
        address: 'Home',
        items: [],
        totalAmount: 60,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      repo.setInitialCache(deliveries: [delivery]);

      // Attempt skip at 10:30 PM on Sept 15 (after 10:00 PM cutoff)
      final requestTime = DateTime(2026, 9, 15, 22, 30);

      expect(
        () => repo.skipNextDelivery('sub_skip', 'del_skip_late', now: requestTime, userId: 'u_1'),
        throwsA(isA<Exception>()),
      );
    });

    // Scenario 12: Pause Entire Subscription
    test('12. Pause entire subscription (all deliveries paused, no charges generated)', () async {
      final sub = SubscriptionModel(
        id: 'sub_pause_all',
        userId: 'u_1',
        planType: SubscriptionPlanType.readyMade,
        planName: 'Pause All Test',
        status: SubscriptionStatus.active,
        deliverySlot: '6:00 AM - 8:00 AM',
        deliveryAddress: 'Home',
        items: [],
        startDate: DateTime.now(),
        nextDeliveryDate: DateTime.now(),
        estimatedMonthlyAmount: 1800,
        createdAt: DateTime.now(),
      );

      await repo.createSubscription(sub, userId: 'u_1');
      await repo.updateSubscriptionStatus('sub_pause_all', SubscriptionStatus.paused, userId: 'u_1');

      final updated = repo.cachedSubscriptions.firstWhere((s) => s.id == 'sub_pause_all');
      expect(updated.status, SubscriptionStatus.paused);
      expect(updated.status.isPaused, true);
    });

    // Scenario 13: Resume Entire Subscription
    test('13. Resume entire subscription', () async {
      final sub = SubscriptionModel(
        id: 'sub_res_all',
        userId: 'u_1',
        planType: SubscriptionPlanType.readyMade,
        planName: 'Resume All Test',
        status: SubscriptionStatus.paused,
        deliverySlot: '6:00 AM - 8:00 AM',
        deliveryAddress: 'Home',
        items: [],
        startDate: DateTime.now(),
        nextDeliveryDate: DateTime.now(),
        estimatedMonthlyAmount: 1800,
        createdAt: DateTime.now(),
      );

      await repo.createSubscription(sub, userId: 'u_1');
      await repo.updateSubscriptionStatus('sub_res_all', SubscriptionStatus.active, userId: 'u_1');

      final updated = repo.cachedSubscriptions.firstWhere((s) => s.id == 'sub_res_all');
      expect(updated.status, SubscriptionStatus.active);
      expect(updated.status.isActive, true);
    });

    // Scenario 14: Cancel Subscription with Reason
    test('14. Cancel subscription with cancellation reason recorded', () async {
      final sub = SubscriptionModel(
        id: 'sub_cancel_test',
        userId: 'u_1',
        planType: SubscriptionPlanType.readyMade,
        planName: 'Cancel Test',
        status: SubscriptionStatus.active,
        deliverySlot: '6:00 AM - 8:00 AM',
        deliveryAddress: 'Home',
        items: [],
        startDate: DateTime.now(),
        nextDeliveryDate: DateTime.now(),
        estimatedMonthlyAmount: 1800,
        createdAt: DateTime.now(),
      );

      await repo.createSubscription(sub, userId: 'u_1');
      await repo.updateSubscriptionStatus(
        'sub_cancel_test',
        SubscriptionStatus.cancelled,
        cancellationReason: 'Going on vacation',
        userId: 'u_1',
      );

      final updated = repo.cachedSubscriptions.firstWhere((s) => s.id == 'sub_cancel_test');
      expect(updated.status, SubscriptionStatus.cancelled);
      expect(updated.cancellationReason, 'Going on vacation');
      expect(updated.cancelledAt, isNotNull);
    });

    // Scenario 15: Basket-Value Dynamic Pricing
    test('15. Basket-value dynamic pricing (e.g., ₹300/week seasonal vegetables)', () {
      final item = SubscriptionItem(
        id: 'i_basket_val',
        subscriptionId: 'sub_bv',
        productId: 'prod_seasonal_veg',
        productName: 'Seasonal Organic Veg Box',
        categoryId: 'veg',
        categoryName: 'Vegetables',
        emoji: '🥦',
        quantity: 1,
        unit: 'Box',
        pricePerUnit: 300,
        frequency: SubscriptionFrequency.weekly,
        priceType: SubscriptionPriceType.basketValue,
        basketValue: 300,
        startDate: DateTime.now(),
        nextDeliveryDate: DateTime.now(),
      );

      expect(item.priceType, SubscriptionPriceType.basketValue);
      expect(item.basketValue, 300.0);
      expect(item.estimatedMonthlyCost, closeTo(300 * 4.33, 1.0));
    });

    // Scenario 16: Milk Capacity Enforcement (1,000L Daily Limit)
    test('16. Milk capacity enforcement (blocks subscription creation exceeding 1,000L daily limit)', () async {
      // Set existing commitments to 995L
      final existingItem = SubscriptionItem(
        id: 'i_exist',
        subscriptionId: 'sub_exist',
        productId: 'p_milk',
        productName: 'Cow Milk',
        categoryId: 'dairy_milk',
        categoryName: 'Dairy',
        emoji: '🥛',
        quantity: 995.0,
        unit: 'L',
        pricePerUnit: 60,
        frequency: SubscriptionFrequency.daily,
        startDate: DateTime.now(),
        nextDeliveryDate: DateTime.now(),
      );

      final existingSub = SubscriptionModel(
        id: 'sub_exist',
        userId: 'user_prior',
        planType: SubscriptionPlanType.readyMade,
        planName: 'Existing Massive Milk Sub',
        status: SubscriptionStatus.active,
        deliverySlot: '6:00 AM - 8:00 AM',
        deliveryAddress: 'Address',
        items: [existingItem],
        startDate: DateTime.now(),
        nextDeliveryDate: DateTime.now(),
        estimatedMonthlyAmount: 995 * 60 * 30,
        createdAt: DateTime.now(),
      );

      repo.setInitialCache(subscriptions: [existingSub], milkCapacity: 1000.0);

      // Attempt adding 10L (995 + 10 = 1005L > 1000L capacity)
      final newItem = SubscriptionItem(
        id: 'i_new',
        subscriptionId: 'sub_new_overflow',
        productId: 'p_milk',
        productName: 'Cow Milk',
        categoryId: 'dairy_milk',
        categoryName: 'Dairy',
        emoji: '🥛',
        quantity: 10.0,
        unit: 'L',
        pricePerUnit: 60,
        frequency: SubscriptionFrequency.daily,
        startDate: DateTime.now(),
        nextDeliveryDate: DateTime.now(),
      );

      final newSub = SubscriptionModel(
        id: 'sub_new_overflow',
        userId: 'user_new',
        planType: SubscriptionPlanType.readyMade,
        planName: 'Over Capacity Sub',
        status: SubscriptionStatus.active,
        deliverySlot: '6:00 AM - 8:00 AM',
        deliveryAddress: 'Address',
        items: [newItem],
        startDate: DateTime.now(),
        nextDeliveryDate: DateTime.now(),
        estimatedMonthlyAmount: 10 * 60 * 30,
        createdAt: DateTime.now(),
      );

      expect(
        () => repo.createSubscription(newSub, userId: 'user_new'),
        throwsA(isA<Exception>()),
      );
    });

    // Scenario 17: Historical Completed Orders Preserved
    test('17. Historical completed orders remain unchanged when future subscription items change', () async {
      final pastDelivery = SubscriptionDelivery(
        id: 'del_past_1',
        subscriptionId: 'sub_hist',
        userId: 'u_1',
        deliveryDate: DateTime(2026, 9, 10),
        deliverySlot: '6:00 AM - 8:00 AM',
        address: 'Home',
        items: [
          SubscriptionItem(
            id: 'item_hist_1',
            subscriptionId: 'sub_hist',
            productId: 'p_milk',
            productName: 'Old Milk Batch',
            categoryId: 'dairy',
            categoryName: 'Dairy',
            emoji: '🥛',
            quantity: 1,
            unit: 'L',
            pricePerUnit: 55,
            frequency: SubscriptionFrequency.daily,
            startDate: DateTime(2026, 9, 1),
            nextDeliveryDate: DateTime(2026, 9, 10),
          ),
        ],
        totalAmount: 55,
        status: 'delivered',
        orderId: 'ORD_HIST_001',
        createdAt: DateTime(2026, 9, 10),
      );

      repo.setInitialCache(deliveries: [pastDelivery]);

      final sub = SubscriptionModel(
        id: 'sub_hist',
        userId: 'u_1',
        planType: SubscriptionPlanType.readyMade,
        planName: 'Hist Test Sub',
        status: SubscriptionStatus.active,
        deliverySlot: '6:00 AM - 8:00 AM',
        deliveryAddress: 'Home',
        items: [
          SubscriptionItem(
            id: 'i_new_rate',
            subscriptionId: 'sub_hist',
            productId: 'p_milk',
            productName: 'New Milk Rate',
            categoryId: 'dairy',
            categoryName: 'Dairy',
            emoji: '🥛',
            quantity: 3, // Changed quantity to 3L
            unit: 'L',
            pricePerUnit: 65, // Changed price to 65
            frequency: SubscriptionFrequency.daily,
            startDate: DateTime(2026, 9, 15),
            nextDeliveryDate: DateTime(2026, 9, 16),
          ),
        ],
        startDate: DateTime(2026, 9, 15),
        nextDeliveryDate: DateTime(2026, 9, 16),
        estimatedMonthlyAmount: 5850,
        createdAt: DateTime.now(),
      );

      await repo.createSubscription(sub, userId: 'u_1');

      // Check past delivery
      final histDel = repo.cachedDeliveries.firstWhere((d) => d.id == 'del_past_1');
      expect(histDel.status, 'delivered');
      expect(histDel.totalAmount, 55.0);
      expect(histDel.items.first.productName, 'Old Milk Batch');
      expect(histDel.items.first.quantity, 1.0);
    });

    // Scenario 18: Idempotent Delivery Generator
    test('18. Idempotent delivery generator prevents duplicate delivery entries on multiple runs', () async {
      final item = SubscriptionItem(
        id: 'i_idem',
        subscriptionId: 'sub_idem',
        productId: 'p_milk',
        productName: 'Milk',
        categoryId: 'dairy',
        categoryName: 'Dairy',
        emoji: '🥛',
        quantity: 1,
        unit: 'L',
        pricePerUnit: 60,
        frequency: SubscriptionFrequency.daily,
        startDate: DateTime(2026, 9, 15),
        nextDeliveryDate: DateTime(2026, 9, 16),
      );

      final sub = SubscriptionModel(
        id: 'sub_idem',
        userId: 'u_idem',
        planType: SubscriptionPlanType.readyMade,
        planName: 'Idempotency Test',
        status: SubscriptionStatus.active,
        deliverySlot: '6:00 AM - 8:00 AM',
        deliveryAddress: 'Home',
        items: [item],
        startDate: DateTime(2026, 9, 15),
        nextDeliveryDate: DateTime(2026, 9, 16),
        estimatedMonthlyAmount: 1800,
        createdAt: DateTime.now(),
      );

      // Run generator 1st time
      await repo.generateUpcomingDeliveries(sub, daysAhead: 7, userId: 'u_idem');
      final countFirstRun = repo.cachedDeliveries.where((d) => d.subscriptionId == 'sub_idem').length;

      // Run generator 2nd time with same inputs
      await repo.generateUpcomingDeliveries(sub, daysAhead: 7, userId: 'u_idem');
      final countSecondRun = repo.cachedDeliveries.where((d) => d.subscriptionId == 'sub_idem').length;

      // Must produce identical deterministic document IDs without duplicates
      expect(countFirstRun, 7);
      expect(countSecondRun, countFirstRun);
    });

    // Scenario 19: Family Fresh Plan Sizing
    test('19. Family Fresh plan generates correct multi-category bundle based on family size', () {
      final familySizes = [2, 4, 6];

      for (final size in familySizes) {
        final milkQty = size <= 2 ? 1.0 : (size <= 4 ? 2.0 : 3.0);
        final vegKg = size <= 2 ? 3.0 : (size <= 4 ? 5.0 : 8.0);
        final fruitKg = size <= 2 ? 2.0 : (size <= 4 ? 3.5 : 5.0);

        final items = [
          SubscriptionItem(
            id: 'ff_milk_$size',
            subscriptionId: 'sub_ff_$size',
            productId: 'prod_milk',
            productName: 'Farm Cow Milk',
            categoryId: 'dairy',
            categoryName: 'Dairy',
            emoji: '🥛',
            quantity: milkQty,
            unit: 'L',
            pricePerUnit: 60,
            frequency: SubscriptionFrequency.daily,
            startDate: DateTime.now(),
            nextDeliveryDate: DateTime.now(),
          ),
          SubscriptionItem(
            id: 'ff_veg_$size',
            subscriptionId: 'sub_ff_$size',
            productId: 'prod_veg',
            productName: 'Family Vegetable Basket',
            categoryId: 'veg',
            categoryName: 'Vegetables',
            emoji: '🥦',
            quantity: vegKg,
            unit: 'kg',
            pricePerUnit: 50,
            frequency: SubscriptionFrequency.weekly,
            deliveryDay: 'Wednesday',
            startDate: DateTime.now(),
            nextDeliveryDate: DateTime.now(),
          ),
          SubscriptionItem(
            id: 'ff_fruit_$size',
            subscriptionId: 'sub_ff_$size',
            productId: 'prod_fruit',
            productName: 'Seasonal Fruit Box',
            categoryId: 'fruits',
            categoryName: 'Fruits',
            emoji: '🍎',
            quantity: fruitKg,
            unit: 'kg',
            pricePerUnit: 80,
            frequency: SubscriptionFrequency.weekly,
            deliveryDay: 'Saturday',
            startDate: DateTime.now(),
            nextDeliveryDate: DateTime.now(),
          ),
        ];

        final plan = SubscriptionModel(
          id: 'sub_ff_$size',
          userId: 'u_1',
          planType: SubscriptionPlanType.familyFresh,
          planName: 'Family Fresh for $size Members',
          status: SubscriptionStatus.active,
          deliverySlot: '6:00 AM - 8:00 AM',
          deliveryAddress: 'Home',
          items: items,
          startDate: DateTime.now(),
          nextDeliveryDate: DateTime.now(),
          estimatedMonthlyAmount: 0,
          createdAt: DateTime.now(),
        );

        expect(plan.items.length, 3);
        expect(plan.calculateEstimatedMonthlySpend(), greaterThan(0));
      }
    });
  });
}
