import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';

/// Screen displaying Help & Support, FAQs, and official contact information
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Color(0xFF0F172A),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Help & Support',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact Support Hero Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCCFBF1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.support_agent_rounded,
                          color: Color(0xFF0D9488),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TaazaBazar Customer Care',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Mon – Sun: 6:00 AM – 9:00 PM IST',
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
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 14),

                  // Phone Contact Row
                  _buildContactRow(
                    icon: Icons.phone_in_talk_rounded,
                    label: 'Phone Helpline',
                    value: AppConstants.supportPhone,
                    iconBgColor: const Color(0xFFDCFCE7),
                    iconColor: const Color(0xFF166534),
                  ),
                  const SizedBox(height: 12),

                  // Email Contact Row
                  _buildContactRow(
                    icon: Icons.mail_outline_rounded,
                    label: 'Email Assistance',
                    value: AppConstants.supportEmail,
                    iconBgColor: const Color(0xFFDBEAFE),
                    iconColor: const Color(0xFF2563EB),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section: Frequently Asked Questions
            _buildSectionHeader('FREQUENTLY ASKED QUESTIONS'),
            const SizedBox(height: 8),

            _buildFaqCard([
              _buildFaqItem(
                question: 'When will my order be delivered?',
                answer:
                    'Orders placed before 10:00 PM are harvested fresh from local farms overnight and delivered directly to your doorstep next morning between 6:00 AM and 8:00 AM.',
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              _buildFaqItem(
                question: 'How does TaazaBazar source fresh produce?',
                answer:
                    'We source 100% directly from certified farmers in the Shadnagar Organic Belt. Produce is packed and dispatched within 12 hours of harvesting to guarantee peak nutrition and freshness.',
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              _buildFaqItem(
                question: 'What is the free delivery threshold?',
                answer:
                    'Orders above ₹${AppConstants.freeDeliveryThreshold.toInt()} qualify for free delivery. For orders below this amount, a standard delivery fee of ₹${AppConstants.standardDeliveryFee.toInt()} is applied.',
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              _buildFaqItem(
                question: 'How do I request a refund or replacement for damaged items?',
                answer:
                    'If any delivered item does not meet your quality expectations, contact our customer support team at ${AppConstants.supportEmail} or ${AppConstants.supportPhone} with your Order ID for a prompt refund or replacement.',
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              _buildFaqItem(
                question: 'How can I update my delivery address or instructions?',
                answer:
                    'You can manage your saved addresses anytime from Profile → Saved Addresses, or choose your preferred delivery location before placing your order on the Checkout screen.',
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF94A3B8),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconBgColor,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF94A3B8),
              ),
            ),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFaqCard(List<Widget> children) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildFaqItem({
    required String question,
    required String answer,
  }) {
    return Theme(
      data: ThemeData(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        iconColor: const Color(0xFF166534),
        collapsedIconColor: const Color(0xFF64748B),
        title: Text(
          question,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        children: [
          Text(
            answer,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
