import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/pass_plan_card.dart';

/// Standalone micro-feature screen for Taaza Pass membership & subscription
class TaazaPassScreen extends StatefulWidget {
  final bool isStandalone;

  const TaazaPassScreen({
    super.key,
    this.isStandalone = false,
  });

  @override
  State<TaazaPassScreen> createState() => _TaazaPassScreenState();
}

class _TaazaPassScreenState extends State<TaazaPassScreen> {
  int _selectedPassPlan = 1; // Default to Monthly

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: widget.isStandalone
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: Color(0xFF0F172A),
                ),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: Text(
          'Taaza Pass',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF166534), Color(0xFF15803D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF166534).withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'MEMBER PASS',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.stars_rounded,
                        color: Color(0xFFFDE047),
                        size: 28,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Unlimited Free Delivery\n& Extra 10% Off',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Save up to ₹1,200/month on your farm produce',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFBBF7D0),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Pass Benefits
            Text(
              'Pass Benefits',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildBenefitRow(
                    icon: Icons.delivery_dining_rounded,
                    title: 'Unlimited Free Deliveries',
                    subtitle: 'On all orders above ₹99 (Save ₹25/drop)',
                  ),
                  const Divider(height: 20, color: Color(0xFFF1F5F9)),
                  _buildBenefitRow(
                    icon: Icons.percent_rounded,
                    title: 'Flat 10% Extra Discount',
                    subtitle: 'Valid on all organic vegetables & milk',
                  ),
                  const Divider(height: 20, color: Color(0xFFF1F5F9)),
                  _buildBenefitRow(
                    icon: Icons.alarm_on_rounded,
                    title: 'Priority 6 AM Slot Guarantee',
                    subtitle: 'Never miss early morning harvest slots',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Select Plan
            Text(
              'Select Membership Plan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),

            PassPlanCard(
              title: 'Weekly Pass',
              duration: '7 Days Access • Free trial available',
              price: '₹49',
              originalPrice: '₹99',
              savings: 'Save ₹50',
              tag: 'TRIAL',
              isSelected: _selectedPassPlan == 0,
              onTap: () => setState(() => _selectedPassPlan = 0),
            ),
            PassPlanCard(
              title: 'Monthly Pass',
              duration: '30 Days Access • Most Popular',
              price: '₹149',
              originalPrice: '₹299',
              savings: 'Save ₹150',
              tag: 'POPULAR',
              isSelected: _selectedPassPlan == 1,
              onTap: () => setState(() => _selectedPassPlan = 1),
            ),
            PassPlanCard(
              title: 'Quarterly Pass',
              duration: '90 Days Access • Maximum Value',
              price: '₹349',
              originalPrice: '₹799',
              savings: 'Save ₹450',
              tag: 'BEST VALUE',
              isSelected: _selectedPassPlan == 2,
              onTap: () => setState(() => _selectedPassPlan = 2),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFFD97706),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Taaza Pass memberships are currently in preview. Subscription activation will launch soon!',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF92400E),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: const Color(0xFFE2E8F0))),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Taaza Pass subscriptions will be available soon.'),
                    backgroundColor: Color(0xFF0F172A),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF166534),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Taaza Pass Available Soon',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF166534), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Backwards compatibility alias
typedef FreshlyPassScreen = TaazaPassScreen;
