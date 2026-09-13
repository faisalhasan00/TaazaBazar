import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/onboarding_item.dart';

/// Large rounded illustration card for Onboarding slides
class OnboardingIllustrationCard extends StatelessWidget {
  final OnboardingItem item;

  const OnboardingIllustrationCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 310,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: AppColors.border,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: item.accentColor.withValues(alpha: 0.10),
            blurRadius: 28,
            offset: const Offset(0, 14),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ambient background gradient circles
            Positioned(
              top: -40,
              right: -40,
              child: _buildGradientOrb(
                size: 200,
                color: item.accentColor.withValues(alpha: 0.16),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -30,
              child: _buildGradientOrb(
                size: 180,
                color: AppColors.freshGreen.withValues(alpha: 0.12),
              ),
            ),

            // Subtle background grid/rings
            Center(
              child: Container(
                width: 230,
                height: 230,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: item.accentColor.withValues(alpha: 0.14),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            Center(
              child: Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.lightGreen.withValues(alpha: 0.5),
                ),
              ),
            ),

            // Slide Specific Rich Visuals
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: _buildVisualContent(item.type),
            ),

            // Top Badge
            Positioned(
              top: 16,
              left: 18,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: item.accentColor.withValues(alpha: 0.35),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.badgeIcon, size: 14, color: item.accentColor),
                    const SizedBox(width: 6),
                    Text(
                      item.badgeText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualContent(OnboardingType type) {
    Widget child;
    switch (type) {
      case OnboardingType.welcome:
      case OnboardingType.farmFresh:
        child = const SizedBox.shrink();
      case OnboardingType.easyDelivery:
        child = const _EasyDeliveryVisual();
    }
    return SizedBox.expand(child: child);
  }

  Widget _buildGradientOrb({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}





/// Screen 3 Visual: Delivery partner, grocery bag & doorstep delivery
class _EasyDeliveryVisual extends StatelessWidget {
  const _EasyDeliveryVisual();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Main Delivery Partner Hub
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0284C7).withValues(alpha: 0.30),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.moped_rounded,
              size: 74,
              color: Colors.white,
            ),
          ),
        ),

        // 1. Doorstep Grocery Bag (Top Left)
        Positioned(
          top: 30,
          left: 36,
          child: _buildFloatingIcon(
            icon: Icons.shopping_bag_rounded,
            color: const Color(0xFF166534),
            bg: const Color(0xFFDCFCE7),
            size: 46,
            iconSize: 26,
          ),
        ),

        // 2. Doorstep Map Pin (Top Right)
        Positioned(
          top: 34,
          right: 36,
          child: _buildFloatingIcon(
            icon: Icons.location_on_rounded,
            color: const Color(0xFFEF4444),
            bg: const Color(0xFFFEE2E2),
            size: 44,
            iconSize: 24,
          ),
        ),

        // 3. Fast Time / 15 Min Delivery (Bottom Right)
        Positioned(
          bottom: 24,
          right: 42,
          child: _buildFloatingIcon(
            icon: Icons.schedule_rounded,
            color: const Color(0xFF0284C7),
            bg: const Color(0xFFE0F2FE),
            size: 46,
            iconSize: 26,
          ),
        ),

        // 4. Contactless Handover Check (Bottom Left)
        Positioned(
          bottom: 26,
          left: 42,
          child: _buildFloatingIcon(
            icon: Icons.check_circle_rounded,
            color: const Color(0xFF22C55E),
            bg: const Color(0xFFF0FDF4),
            size: 44,
            iconSize: 24,
          ),
        ),
      ],
    );
  }
}

Widget _buildFloatingIcon({
  required IconData icon,
  required Color color,
  required Color bg,
  required double size,
  required double iconSize,
}) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: bg,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 2),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: 0.18),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Center(
      child: Icon(
        icon,
        size: iconSize,
        color: color,
      ),
    ),
  );
}
