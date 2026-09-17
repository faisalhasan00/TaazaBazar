import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/notification_service.dart';
import '../domain/notification_preferences.dart';
import 'legal_screen.dart';

/// Screen displaying customer application settings, notification preferences, and system info
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  NotificationPreferences _preferences = const NotificationPreferences();

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
          'Settings',
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
            // Section 1: Notification Preferences
            _buildSectionHeader('PUSH NOTIFICATIONS'),
            const SizedBox(height: 8),
            _buildCardContainer([
              _buildSwitchTile(
                icon: Icons.local_shipping_outlined,
                title: 'Order & Delivery Updates',
                subtitle: 'Real-time alerts for confirmation, dispatch, and delivery',
                value: _preferences.orderUpdates,
                isTransactional: true,
                onChanged: (val) {
                  setState(() {
                    _preferences = _preferences.copyWith(orderUpdates: val);
                  });
                },
              ),
              const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
              _buildSwitchTile(
                icon: Icons.eco_outlined,
                title: 'Morning Harvest Alerts',
                subtitle: 'Fresh produce arrival notifications at 6:00 AM',
                value: _preferences.morningHarvestAlerts,
                onChanged: (val) {
                  setState(() {
                    _preferences = _preferences.copyWith(morningHarvestAlerts: val);
                  });
                },
              ),
              const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
              _buildSwitchTile(
                icon: Icons.local_offer_outlined,
                title: 'Offers & Organic Deals',
                subtitle: 'Weekly coupons and seasonal discounts',
                value: _preferences.offersAndPromotions,
                onChanged: (val) {
                  setState(() {
                    _preferences = _preferences.copyWith(offersAndPromotions: val);
                  });
                },
              ),
              const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
              InkWell(
                onTap: () async {
                  final granted = await NotificationService().requestPermission();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          granted
                              ? 'Notifications are enabled for TaazaBazar!'
                              : 'Notification permission was not granted.',
                        ),
                        backgroundColor: granted
                            ? const Color(0xFF166534)
                            : const Color(0xFF64748B),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.notification_add_outlined,
                          color: Color(0xFF166534),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Check Device Notification Permission',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF166534),
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF166534),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 24),

            // Section 2: App Preferences
            _buildSectionHeader('APP PREFERENCES'),
            const SizedBox(height: 8),
            _buildCardContainer([
              _buildSettingTile(
                icon: Icons.palette_outlined,
                title: 'Appearance',
                subtitle: 'System default (Light theme)',
                trailingText: 'Default',
              ),
              const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
              _buildSettingTile(
                icon: Icons.language_rounded,
                title: 'App Language',
                subtitle: 'English (US)',
                trailingText: 'English',
              ),
              const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
              _buildSettingTile(
                icon: Icons.storefront_outlined,
                title: 'Primary Fulfillment Hub',
                subtitle: AppConstants.defaultHubName,
              ),
            ]),
            const SizedBox(height: 24),

            // Section 3: System & Security
            _buildSectionHeader('SYSTEM & SECURITY'),
            const SizedBox(height: 8),
            _buildCardContainer([
              _buildSettingTile(
                icon: Icons.security_rounded,
                title: 'Authentication & Data Security',
                subtitle: 'Secured via Firebase Cloud Infrastructure',
                trailingIcon: Icons.verified_user_rounded,
                trailingColor: const Color(0xFF166534),
              ),
              const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LegalScreen(),
                    ),
                  );
                },
                child: _buildSettingTile(
                  icon: Icons.gavel_rounded,
                  title: 'Legal & Policies',
                  subtitle: 'Privacy Policy, Terms, Cancellation & Delivery',
                  trailingIcon: Icons.chevron_right_rounded,
                  trailingColor: const Color(0xFF94A3B8),
                ),
              ),
              const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
              _buildSettingTile(
                icon: Icons.info_outline_rounded,
                title: 'Application Version',
                subtitle: 'TaazaBazar v1.0.0 (Build 1)',
                trailingText: 'v1.0.0',
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isTransactional = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isTransactional
                  ? const Color(0xFF166534)
                  : const Color(0xFF64748B),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    if (isTransactional) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Essential',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF166534),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: const Color(0xFF166534),
            activeThumbColor: Colors.white,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    String? trailingText,
    IconData? trailingIcon,
    Color? trailingColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF64748B),
              size: 20,
            ),
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
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          if (trailingText != null)
            Text(
              trailingText,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          if (trailingIcon != null)
            Icon(
              trailingIcon,
              size: 18,
              color: trailingColor ?? const Color(0xFF94A3B8),
            ),
        ],
      ),
    );
  }
}
