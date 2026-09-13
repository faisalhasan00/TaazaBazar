import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable primary and outlined action button conforming to TaazaBazar design system
class TaazaButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isOutlined;
  final bool isLoading;
  final double height;
  final double? width;
  final Color backgroundColor;
  final Color foregroundColor;
  final double borderRadius;
  final double fontSize;

  const TaazaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isOutlined = false,
    this.isLoading = false,
    this.height = 52,
    this.width,
    this.backgroundColor = const Color(0xFF166534),
    this.foregroundColor = Colors.white,
    this.borderRadius = 16,
    this.fontSize = 15,
  });

  const TaazaButton.outlined({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.height = 52,
    this.width,
    this.backgroundColor = Colors.transparent,
    this.foregroundColor = const Color(0xFF0F172A),
    this.borderRadius = 16,
    this.fontSize = 15,
  }) : isOutlined = true;

  @override
  Widget build(BuildContext context) {
    final effectiveChild = isLoading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOutlined ? const Color(0xFF166534) : Colors.white,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: isOutlined ? foregroundColor : Colors.white),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w800,
                  color: isOutlined ? foregroundColor : Colors.white,
                ),
              ),
            ],
          );

    return SizedBox(
      height: height,
      width: width ?? double.infinity,
      child: isOutlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: foregroundColor,
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
              child: effectiveChild,
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
              child: effectiveChild,
            ),
    );
  }
}

/// Alias for backwards-compatibility
typedef FreshlyButton = TaazaButton;
