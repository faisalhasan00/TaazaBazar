import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable status and category badge for TaazaBazar
class TaazaBadge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;
  final double fontSize;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const TaazaBadge({
    super.key,
    required this.text,
    this.backgroundColor = const Color(0xFFDCFCE7),
    this.textColor = const Color(0xFF166534),
    this.icon,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.borderRadius = 8,
  });

  const TaazaBadge.success({
    super.key,
    required this.text,
    this.icon = Icons.check_circle_rounded,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.borderRadius = 8,
  })  : backgroundColor = const Color(0xFFDCFCE7),
        textColor = const Color(0xFF166534);

  const TaazaBadge.warning({
    super.key,
    required this.text,
    this.icon = Icons.access_time_rounded,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.borderRadius = 8,
  })  : backgroundColor = const Color(0xFFFEF3C7),
        textColor = const Color(0xFF92400E);

  const TaazaBadge.organic({
    super.key,
    this.text = '100% ORGANIC',
    this.icon = Icons.eco_rounded,
    this.fontSize = 10,
    this.padding = const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    this.borderRadius = 6,
  })  : backgroundColor = const Color(0xFFF0FDF4),
        textColor = const Color(0xFF166534);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Alias for backwards-compatibility
typedef FreshlyBadge = TaazaBadge;
