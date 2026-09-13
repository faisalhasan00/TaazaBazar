import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Animated smooth pill page indicator for Onboarding
class PageIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;
  final Color activeColor;

  const PageIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
    this.activeColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? activeColor
                : AppColors.textMuted.withValues(alpha: 0.28),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
