import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/firebase_auth_service.dart';
import '../../auth/presentation/login_screen.dart';
import '../../location/presentation/saved_addresses_screen.dart';
import '../../subscription/presentation/subscriptions_hub_screen.dart';
import '../data/profile_repository.dart';
import '../domain/user_profile.dart';
import 'about_screen.dart';
import 'edit_profile_screen.dart';
import 'help_support_screen.dart';
import 'legal_screen.dart';
import 'notifications_screen.dart';
import 'settings_screen.dart';
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
          'Profile',
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
            // User Header Card with Avatar, Name, Phone & "Freshly Member" summary
            StreamBuilder<UserProfile?>(
              stream: ProfileRepository().getProfileStream(),
              builder: (context, snapshot) {
                final profile = snapshot.data ?? ProfileRepository().cachedProfile;
                if (profile != null) {
                  return ProfileHeader(
                    userName: profile.name,
                    userPhone: profile.phone,
                    memberStatus: profile.memberStatus,
                    isPassMember: profile.isPassMember,
                    onEdit: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(
                            initialProfile: profile,
                          ),
                        ),
                      );
                    },
                  );
                }
                return ProfileHeader(
                  onEdit: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 20),

            // Section 1: Orders & Membership
            _buildSectionHeader('ORDERS & MEMBERSHIP'),
            const SizedBox(height: 8),
            _buildCardContainer([
              ProfileMenuItem(
                icon: Icons.receipt_long_rounded,
                title: 'My Orders',
                subtitle: 'Active deliveries and past order history',
                onTap: () {
                  if (onNavigateToOrders != null) {
                    onNavigateToOrders!();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Opening My Orders...'),
                        backgroundColor: Color(0xFF166534),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
              const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
              ProfileMenuItem(
                icon: Icons.calendar_month_rounded,
                title: 'My Subscriptions',
                subtitle: 'Daily milk, weekly veggies & recurring baskets',
                iconColor: const Color(0xFF166534),
                iconBgColor: const Color(0xFFDCFCE7),
                onTap: () {
                  if (onNavigateToPass != null) {
                    onNavigateToPass!();
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SubscriptionsHubScreen(),
                      ),
                    );
                  }
                },
              ),
              const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
              ProfileMenuItem(
                icon: Icons.location_on_rounded,
                title: 'Saved Addresses',
                subtitle: 'Home, office & delivery locations',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SavedAddressesScreen(isStandalone: true),
                    ),
                  );
                },
              ),
            ]),
            const SizedBox(height: 20),

            // Section 2: Preferences & Settings
            _buildSectionHeader('PREFERENCES'),
            const SizedBox(height: 8),
            _buildCardContainer([
              ProfileMenuItem(
                icon: Icons.notifications_active_rounded,
                title: 'Notifications',
                subtitle: 'Delivery alerts, offers & order updates',
                iconColor: const Color(0xFF2563EB),
                iconBgColor: const Color(0xFFDBEAFE),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
              ),
              const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
              ProfileMenuItem(
                icon: Icons.settings_rounded,
                title: 'Settings',
                subtitle: 'App preferences, language & privacy',
                iconColor: const Color(0xFF475569),
                iconBgColor: const Color(0xFFF1F5F9),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
            ]),
            const SizedBox(height: 20),

            // Section 3: Support & Information
            _buildSectionHeader('SUPPORT & MORE'),
            const SizedBox(height: 8),
            _buildCardContainer([
              ProfileMenuItem(
                icon: Icons.support_agent_rounded,
                title: 'Help & Support',
                subtitle: '24/7 instant chat & call assistance',
                iconColor: const Color(0xFF0D9488),
                iconBgColor: const Color(0xFFCCFBF1),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HelpSupportScreen(),
                    ),
                  );
                },
              ),
              const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
              ProfileMenuItem(
                icon: Icons.gavel_rounded,
                title: 'Legal & Policies',
                subtitle: 'Privacy Policy, Terms, Cancellation & Delivery',
                iconColor: const Color(0xFF0F766E),
                iconBgColor: const Color(0xFFCCFBF1),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LegalScreen(),
                    ),
                  );
                },
              ),
              const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
              ProfileMenuItem(
                icon: Icons.info_outline_rounded,
                title: 'About TaazaBazar',
                subtitle: 'Version 1.0.0 • Mission & Standards',
                iconColor: const Color(0xFF7C3AED),
                iconBgColor: const Color(0xFFEDE9FE),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AboutScreen(),
                    ),
                  );
                },
              ),
            ]),
            const SizedBox(height: 20),

            // Section 4: Logout Action
            _buildCardContainer([
              ProfileMenuItem(
                icon: Icons.logout_rounded,
                title: 'Logout',
                subtitle: 'Sign out of your account on this device',
                iconColor: const Color(0xFFDC2626),
                iconBgColor: const Color(0xFFFEE2E2),
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Color(0xFFEF4444),
                ),
                onTap: () {
                  _showLogoutDialog(context);
                },
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

  Widget _buildCardContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: children,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Logout',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          content: Text(
            'Are you sure you want to log out of your TaazaBazar account?',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF64748B),
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              onPressed: () async {
                Navigator.of(ctx).pop();
                try {
                  await FirebaseAuthService().signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Logged out of TaazaBazar account'),
                        backgroundColor: Color(0xFF0F172A),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Could not sign out. Please check your connection and try again.'),
                        backgroundColor: Color(0xFFDC2626),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              child: Text(
                'Logout',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
