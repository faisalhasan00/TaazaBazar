import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../pass/presentation/freshly_pass_screen.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_menu_item.dart';

/// Standalone micro-feature screen for User Profile and Account Management
class ProfileScreen extends StatelessWidget {
  final bool isStandalone;
  final VoidCallback? onNavigateToOrders;
  final VoidCallback? onNavigateToPass;

  const ProfileScreen({
    super.key,
    this.isStandalone = false,
    this.onNavigateToOrders,
    this.onNavigateToPass,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: isStandalone
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: Color(0xFF0F172A),
                ),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: Text(
          'My Profile',
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
            // User Header Card
            const ProfileHeader(),
            const SizedBox(height: 20),

            // Orders & Subscriptions Section
            Text(
              'My Account',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            Material(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ProfileMenuItem(
                    icon: Icons.receipt_long_rounded,
                    title: 'My Orders',
                    subtitle: 'Active deliveries and order history',
                    onTap: () {
                      if (onNavigateToOrders != null) {
                        onNavigateToOrders!();
                      }
                    },
                  ),
                  const Divider(height: 1, indent: 60),
                  ProfileMenuItem(
                    icon: Icons.card_membership_rounded,
                    title: 'Taaza Pass',
                    subtitle: 'Unlimited free delivery & 10% discount',
                    iconColor: const Color(0xFFD97706),
                    iconBgColor: const Color(0xFFFEF3C7),
                    onTap: () {
                      if (onNavigateToPass != null) {
                        onNavigateToPass!();
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FreshlyPassScreen(isStandalone: true),
                          ),
                        );
                      }
                    },
                  ),
                  const Divider(height: 1, indent: 60),
                  ProfileMenuItem(
                    icon: Icons.location_on_rounded,
                    title: 'Saved Addresses',
                    subtitle: 'Flat 402, Oakwood, Indiranagar',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Viewing saved delivery addresses'),
                          backgroundColor: Color(0xFF166534),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 60),
                  ProfileMenuItem(
                    icon: Icons.account_balance_wallet_rounded,
                    title: 'TaazaBazar Wallet & Refunds',
                    subtitle: 'Available Balance: ₹0',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('TaazaBazar Wallet balance: ₹0.00'),
                          backgroundColor: Color(0xFF166534),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Preferences & Support
            Text(
              'Support & Preferences',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            Material(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ProfileMenuItem(
                    icon: Icons.support_agent_rounded,
                    title: 'Customer Support',
                    subtitle: '24/7 instant chat & call assistance',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Opening 24x7 TaazaBazar Support...'),
                          backgroundColor: Color(0xFF166534),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 60),
                  ProfileMenuItem(
                    icon: Icons.verified_user_outlined,
                    title: 'Privacy Policy & Terms',
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 60),
                  ProfileMenuItem(
                    icon: Icons.logout_rounded,
                    title: 'Log Out',
                    iconColor: const Color(0xFFDC2626),
                    iconBgColor: const Color(0xFFFEE2E2),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Logged out of TaazaBazar account'),
                          backgroundColor: Color(0xFF0F172A),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
