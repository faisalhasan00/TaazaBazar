import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/subscription_repository.dart';
import '../domain/subscription_model.dart';
import 'manage_subscription_screen.dart';
import 'widgets/add_to_delivery_modal.dart';
import 'widgets/build_your_own_sheet.dart';
import 'widgets/daily_basket_card.dart';
import 'widgets/family_fresh_sheet.dart';
import 'widgets/subscription_card.dart';

/// Central Hub for Subscriptions in TaazaBazar
class SubscriptionsHubScreen extends StatefulWidget {
  const SubscriptionsHubScreen({super.key});

  @override
  State<SubscriptionsHubScreen> createState() => _SubscriptionsHubScreenState();
}

class _SubscriptionsHubScreenState extends State<SubscriptionsHubScreen> {
  final SubscriptionRepository _subRepo = SubscriptionRepository();

  static const _primaryColor = Color(0xFF166534);
  static const _textDark = Color(0xFF0F172A);
  static const _textMuted = Color(0xFF64748B);
  static const _bgLight = Color(0xFFFAFAF7);

  void _openBuildYourOwn() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const BuildYourOwnSheet(),
    );
  }

  void _openFamilyFresh() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FamilyFreshSheet(),
    );
  }

  void _openReadyMadePlan(String planType) {
    if (planType.contains('Family')) {
      _openFamilyFresh();
    } else {
      _openBuildYourOwn();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.calendar_month_rounded, color: _primaryColor, size: 22),
            const SizedBox(width: 8),
            Text(
              'Subscriptions',
              style: GoogleFonts.plusJakartaSans(
                color: _textDark,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: _primaryColor),
            tooltip: 'Create New Subscription',
            onPressed: _openBuildYourOwn,
          ),
        ],
      ),
      body: StreamBuilder<List<SubscriptionModel>>(
        stream: _subRepo.getSubscriptionsStream(),
        builder: (context, subSnapshot) {
          final subscriptions = subSnapshot.data ?? _subRepo.cachedSubscriptions;
          final activeSubs = subscriptions.where((s) => s.status != SubscriptionStatus.cancelled).toList();

          return StreamBuilder<List<SubscriptionDelivery>>(
            stream: _subRepo.getUpcomingDeliveriesStream(),
            builder: (context, delSnapshot) {
              final deliveries = delSnapshot.data ?? _subRepo.cachedDeliveries;
              final pendingDeliveries = deliveries.where((d) => d.status == 'pending').toList();
              final nextDelivery = pendingDeliveries.isNotEmpty ? pendingDeliveries.first : null;

              return RefreshIndicator(
                onRefresh: () async {
                  setState(() {});
                },
                color: _primaryColor,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                  children: [
                    // Top Hero Banner
                    _buildHeroBanner(),

                    const SizedBox(height: 16),

                    // Next Combined Morning Delivery (Daily Basket)
                    if (nextDelivery != null && activeSubs.isNotEmpty) ...[
                      DailyBasketCard(
                        delivery: nextDelivery,
                        onAddProductTap: () {
                          AddToDeliveryModal.show(
                            context,
                            subscriptionId: nextDelivery.subscriptionId,
                            onItemAdded: () => setState(() {}),
                          );
                        },
                        onSkipTap: () async {
                          try {
                            await _subRepo.skipNextDelivery(
                              nextDelivery.subscriptionId,
                              nextDelivery.id,
                            );
                            setState(() {});
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Could not skip: $e')),
                              );
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Active Subscriptions Section
                    if (activeSubs.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'My Subscriptions (${activeSubs.length})',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _textDark,
                            ),
                          ),
                          TextButton(
                            onPressed: _openBuildYourOwn,
                            child: Text(
                              '+ New Plan',
                              style: GoogleFonts.plusJakartaSans(
                                color: _primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...activeSubs.map((sub) => SubscriptionCard(
                            subscription: sub,
                            onManageTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ManageSubscriptionScreen(subscription: sub),
                                ),
                              ).then((_) => setState(() {}));
                            },
                            onPauseResumeTap: () async {
                              final newStatus = sub.status.isPaused
                                  ? SubscriptionStatus.active
                                  : SubscriptionStatus.paused;
                              await _subRepo.updateSubscriptionStatus(sub.id, newStatus);
                              setState(() {});
                            },
                            onCancelTap: () async {
                              await _subRepo.updateSubscriptionStatus(
                                sub.id,
                                SubscriptionStatus.cancelled,
                              );
                              setState(() {});
                            },
                          )),
                      const SizedBox(height: 20),
                    ],

                    // Start a New Subscription Section
                    Text(
                      'Start a Subscription',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Automate fresh milk, farm veggies, fruits & grocery deliveries',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: _textMuted),
                    ),
                    const SizedBox(height: 12),

                    // 1. Build Your Own Basket Card
                    _buildCustomBasketCard(),

                    const SizedBox(height: 12),

                    // 2. Family Fresh Plan Card
                    _buildFamilyFreshCard(),

                    const SizedBox(height: 16),

                    // Ready Made Quick Subscribe Options
                    Text(
                      'Popular Ready-Made Plans',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 10),

                    _buildReadyMadeRow(),

                    const SizedBox(height: 24),

                    // Subscription Perks / Benefits
                    _buildPerksSection(),

                    const SizedBox(height: 20),

                    // FAQ Accordion
                    _buildFAQSection(),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF15803D), Color(0xFF166534)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF166534).withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '⚡ ZERO DELIVERY FEES FOREVER',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Morning Farm Basket\nAt Your Doorstep',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Delivered fresh between 6:00 AM – 8:00 AM',
                  style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Text('🥛', style: TextStyle(fontSize: 36)),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomBasketCard() {
    return InkWell(
      onTap: _openBuildYourOwn,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _primaryColor.withValues(alpha: 0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: _primaryColor.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text('🧺', style: TextStyle(fontSize: 32)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    children: [
                      Text(
                        'Build Your Own Basket',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _textDark,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: _primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'POPULAR',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: _primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pick milk, veggies & fruits with custom daily, weekly or monthly schedules.',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: _textMuted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: _primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilyFreshCard() {
    return InkWell(
      onTap: _openFamilyFresh,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.purple.shade200, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF5FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text('👨‍👩‍👧‍👦', style: TextStyle(fontSize: 32)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Family Fresh Bundle',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Curated complete household plan sized for 2, 4, or 6+ members.',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: _textMuted),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.purple.shade700),
          ],
        ),
      ),
    );
  }

  Widget _buildReadyMadeRow() {
    final plans = [
      {'title': 'Daily Farm Milk', 'emoji': '🥛', 'price': '₹1,950/mo', 'desc': '1L Pure Cow Milk daily', 'type': 'Milk'},
      {'title': 'Weekly Veggies', 'emoji': '🥦', 'price': '₹1,299/mo', 'desc': 'Fresh Farm Vegetable Basket', 'type': 'Veg'},
      {'title': 'Seasonal Fruit Box', 'emoji': '🍎', 'price': '₹1,099/mo', 'desc': 'Weekly 4kg Handpicked Fruits', 'type': 'Fruit'},
      {'title': 'Farm Eggs Pack', 'emoji': '🥚', 'price': '₹480/mo', 'desc': '6 Fresh Eggs alternate days', 'type': 'Eggs'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        mainAxisExtent: 140,
      ),
      itemCount: plans.length,
      itemBuilder: (context, index) {
        final plan = plans[index];
        return InkWell(
          onTap: () => _openReadyMadePlan(plan['title']!),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(plan['emoji']!, style: const TextStyle(fontSize: 24)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        plan['price']!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan['title']!,
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      plan['desc']!,
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey.shade600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPerksSection() {
    final perks = [
      {'icon': Icons.alarm_on, 'title': '6:00 – 8:00 AM Delivery', 'sub': 'Guaranteed morning delivery before breakfast'},
      {'icon': Icons.pause_circle_outline, 'title': 'Pause or Skip Anytime', 'sub': 'Skip by 10 PM night before with 0 penalty'},
      {'icon': Icons.local_shipping_outlined, 'title': 'One Combined Basket', 'sub': 'All items delivered together in a single fresh order'},
      {'icon': Icons.money_off, 'title': 'Free Delivery on Subscriptions', 'sub': 'No delivery charge on any recurring subscription'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TaazaBazar Subscription Promises',
            style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: _textDark),
          ),
          const SizedBox(height: 12),
          ...perks.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(p['icon'] as IconData, size: 18, color: _primaryColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p['title'] as String,
                            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          Text(
                            p['sub'] as String,
                            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: _textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildFAQSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: const ExpansionTile(
          title: Text(
            'Frequently Asked Questions',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _textDark),
          ),
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('How do combined deliveries work?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  SizedBox(height: 2),
                  Text('All your active subscription items scheduled for the same morning arrive together in one single eco-friendly bag.', style: TextStyle(fontSize: 11, color: _textMuted)),
                  SizedBox(height: 10),
                  Text('Can I add extra items for tomorrow?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  SizedBox(height: 2),
                  Text('Yes! Tap "+ Add Item to Tomorrow\'s Delivery" on your Daily Basket card to add any fruit, veggie, or grocery item before 10:00 PM.', style: TextStyle(fontSize: 11, color: _textMuted)),
                  SizedBox(height: 10),
                  Text('How do I pause my delivery for vacation?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  SizedBox(height: 2),
                  Text('Open your subscription and tap "Pause All Deliveries". You can resume anytime with one tap.', style: TextStyle(fontSize: 11, color: _textMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
