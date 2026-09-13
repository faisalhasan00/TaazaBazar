import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

enum OnboardingType {
  welcome,
  farmFresh,
  easyDelivery,
}

class OnboardingItem {
  final OnboardingType type;
  final String title;
  final String description;
  final String badgeText;
  final IconData badgeIcon;
  final Color accentColor;

  const OnboardingItem({
    required this.type,
    required this.title,
    required this.description,
    required this.badgeText,
    required this.badgeIcon,
    this.accentColor = AppColors.freshGreen,
  });

  static const List<OnboardingItem> items = [
    OnboardingItem(
      type: OnboardingType.welcome,
      title: 'TaazaBazar',
      description: 'Pure Food\nBetter Life',
      badgeText: 'Pure & Organic',
      badgeIcon: Icons.eco_rounded,
      accentColor: AppColors.primary,
    ),
    OnboardingItem(
      type: OnboardingType.farmFresh,
      title: 'Farm Fresh\nto Your Home',
      description:
          'Get fresh vegetables, dairy and organic products delivered to your doorstep.',
      badgeText: '100% Certified',
      badgeIcon: Icons.eco_rounded,
      accentColor: AppColors.primary,
    ),
  ];
}
