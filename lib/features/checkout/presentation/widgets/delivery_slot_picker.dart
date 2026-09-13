import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Delivery slot picker for CheckoutScreen
class DeliverySlotPicker extends StatelessWidget {
  final List<String> slots;
  final String selectedSlot;
  final Function(String slot) onSelectSlot;

  const DeliverySlotPicker({
    super.key,
    required this.slots,
    required this.selectedSlot,
    required this.onSelectSlot,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 18,
                color: Color(0xFF166534),
              ),
              const SizedBox(width: 8),
              Text(
                'Delivery Schedule',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: slots.map((slot) {
              final isSelected = selectedSlot == slot;
              return GestureDetector(
                onTap: () => onSelectSlot(slot),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF166534) : const Color(0xFFE2E8F0),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                        size: 16,
                        color: isSelected ? const Color(0xFF166534) : const Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        slot,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? const Color(0xFF166534) : const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
