import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/customer_order.dart';

/// Clean horizontal / compact 4-stage active order status timeline:
/// Order Placed → Preparing → Out for Delivery → Delivered
class OrderStatusTimeline extends StatelessWidget {
  final OrderStatus currentStatus;
  final bool isCompact;

  const OrderStatusTimeline({
    super.key,
    required this.currentStatus,
    this.isCompact = false,
  });

  static const List<_TimelineStepConfig> _steps = [
    _TimelineStepConfig(
      status: OrderStatus.placed,
      label: 'Order\nPlaced',
      shortLabel: 'Placed',
      icon: Icons.receipt_long_rounded,
    ),
    _TimelineStepConfig(
      status: OrderStatus.preparing,
      label: 'Preparing\nHarvest',
      shortLabel: 'Preparing',
      icon: Icons.eco_rounded,
    ),
    _TimelineStepConfig(
      status: OrderStatus.outForDelivery,
      label: 'Out for\nDelivery',
      shortLabel: 'On the Way',
      icon: Icons.delivery_dining_rounded,
    ),
    _TimelineStepConfig(
      status: OrderStatus.delivered,
      label: 'Delivered\nDoorstep',
      shortLabel: 'Delivered',
      icon: Icons.check_circle_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentStepIdx = currentStatus.stepIndex;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 12 : 16,
        vertical: isCompact ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2EBE2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: currentStatus == OrderStatus.delivered
                          ? const Color(0xFF166534)
                          : const Color(0xFF22C55E),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF22C55E).withValues(alpha: 0.4),
                          blurRadius: 6,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'LIVE STATUS',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF166534),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: currentStatus == OrderStatus.delivered
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  currentStatus.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: currentStatus == OrderStatus.delivered
                        ? const Color(0xFF166534)
                        : const Color(0xFF92400E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Horizontal Stepper
          Row(
            children: List.generate(_steps.length * 2 - 1, (index) {
              if (index.isOdd) {
                // Connecting line
                final lineStepIdx = index ~/ 2;
                final isPassed = lineStepIdx < currentStepIdx;
                final isCurrent = lineStepIdx == currentStepIdx;

                return Expanded(
                  child: Container(
                    height: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: isPassed
                          ? const Color(0xFF166534)
                          : (isCurrent
                              ? const Color(0xFF22C55E)
                              : const Color(0xFFCBD5E1)),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }

              // Node
              final nodeIdx = index ~/ 2;
              final config = _steps[nodeIdx];
              final isCompleted = nodeIdx < currentStepIdx;
              final isCurrent = nodeIdx == currentStepIdx;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: isCompact ? 32 : 36,
                    height: isCompact ? 32 : 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? const Color(0xFF166534)
                          : (isCurrent
                              ? const Color(0xFF22C55E)
                              : const Color(0xFFF1F5F9)),
                      border: Border.all(
                        color: isCompleted || isCurrent
                            ? Colors.transparent
                            : const Color(0xFFCBD5E1),
                        width: 1.5,
                      ),
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: const Color(0xFF22C55E).withValues(alpha: 0.35),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 18,
                            )
                          : Icon(
                              config.icon,
                              color: isCurrent
                                  ? Colors.white
                                  : const Color(0xFF94A3B8),
                              size: isCompact ? 16 : 18,
                            ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isCompact ? config.shortLabel : config.label,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: isCurrent
                          ? FontWeight.w800
                          : (isCompleted ? FontWeight.w700 : FontWeight.w500),
                      color: isCurrent
                          ? const Color(0xFF166534)
                          : (isCompleted
                              ? const Color(0xFF334155)
                              : const Color(0xFF94A3B8)),
                      height: 1.15,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _TimelineStepConfig {
  final OrderStatus status;
  final String label;
  final String shortLabel;
  final IconData icon;

  const _TimelineStepConfig({
    required this.status,
    required this.label,
    required this.shortLabel,
    required this.icon,
  });
}
