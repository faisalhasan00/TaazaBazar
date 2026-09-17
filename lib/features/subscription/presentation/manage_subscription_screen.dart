import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/subscription_repository.dart';
import '../domain/subscription_model.dart';
import 'widgets/add_to_delivery_modal.dart';

/// Screen for managing an existing subscription at both subscription and item levels
class ManageSubscriptionScreen extends StatefulWidget {
  final SubscriptionModel subscription;

  const ManageSubscriptionScreen({
    super.key,
    required this.subscription,
  });

  @override
  State<ManageSubscriptionScreen> createState() => _ManageSubscriptionScreenState();
}

class _ManageSubscriptionScreenState extends State<ManageSubscriptionScreen> {
  final SubscriptionRepository _subRepo = SubscriptionRepository();
  late SubscriptionModel _subscription;
  bool _isLoading = false;

  static const _primaryColor = Color(0xFF166534);
  static const _textDark = Color(0xFF0F172A);
  static const _textMuted = Color(0xFF64748B);
  static const _errorColor = Color(0xFFDC2626);
  static const _bgLight = Color(0xFFFAFAF7);

  @override
  void initState() {
    super.initState();
    _subscription = widget.subscription;
  }

  Future<void> _toggleSubscriptionPause() async {
    final isPaused = _subscription.status == SubscriptionStatus.paused;
    final targetStatus = isPaused ? SubscriptionStatus.active : SubscriptionStatus.paused;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isPaused ? 'Resume Subscription?' : 'Pause Subscription?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: Text(
          isPaused
              ? 'Your recurring deliveries will resume immediately.'
              : 'All recurring morning deliveries will be paused until you resume. No charges will be incurred.',
          style: GoogleFonts.plusJakartaSans(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isPaused ? _primaryColor : Colors.amber.shade700,
              foregroundColor: Colors.white,
            ),
            child: Text(isPaused ? 'Resume' : 'Pause', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await _subRepo.updateSubscriptionStatus(_subscription.id, targetStatus);
      setState(() {
        _subscription = _subscription.copyWith(
          status: targetStatus,
          updatedAt: DateTime.now(),
        );
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              targetStatus == SubscriptionStatus.active
                  ? 'Subscription resumed!'
                  : 'Subscription paused.',
              style: GoogleFonts.plusJakartaSans(),
            ),
            backgroundColor: targetStatus == SubscriptionStatus.active ? _primaryColor : Colors.amber.shade800,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: _errorColor),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelSubscription() async {
    String? selectedReason;
    final reasons = [
      'Going on vacation / Moving away',
      'Need to adjust delivery quantity or frequency',
      'Prices / Budget reasons',
      'Prefer one-time shopping',
      'Other reason',
    ];

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Cancel Subscription',
            style: GoogleFonts.plusJakartaSans(color: _errorColor, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to cancel? You can also pause instead to keep your preferences.',
                style: GoogleFonts.plusJakartaSans(fontSize: 13, color: _textMuted),
              ),
              const SizedBox(height: 12),
              Text(
                'Please select a reason:',
                style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              ...reasons.map(
                (r) => RadioListTile<String>(
                  title: Text(r, style: GoogleFonts.plusJakartaSans(fontSize: 12)),
                  value: r,
                  groupValue: selectedReason,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) => setDialogState(() => selectedReason = val),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Keep Active', style: GoogleFonts.plusJakartaSans()),
            ),
            ElevatedButton(
              onPressed: selectedReason == null ? null : () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: _errorColor,
                foregroundColor: Colors.white,
              ),
              child: Text('Cancel Subscription', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      await _subRepo.updateSubscriptionStatus(
        _subscription.id,
        SubscriptionStatus.cancelled,
        cancellationReason: selectedReason,
      );
      setState(() {
        _subscription = _subscription.copyWith(
          status: SubscriptionStatus.cancelled,
          cancelledAt: DateTime.now(),
          cancellationReason: selectedReason,
        );
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Subscription has been cancelled.', style: GoogleFonts.plusJakartaSans()),
            backgroundColor: _errorColor,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cancel: $e'), backgroundColor: _errorColor),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _editItem(SubscriptionItem item) async {
    double qty = item.quantity;
    SubscriptionFrequency freq = item.frequency;
    String day = item.deliveryDay;
    final isPaused = item.status == SubscriptionItemStatus.paused;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(item.emoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '₹${item.pricePerUnit.toStringAsFixed(0)} / ${item.unit}',
                          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: _textMuted),
                        ),
                      ],
                    ),
                  ),
                  // Pause / Resume Item Toggle
                  TextButton.icon(
                    onPressed: () {
                      final newStatus = isPaused
                          ? SubscriptionItemStatus.active
                          : SubscriptionItemStatus.paused;
                      final updatedItem = item.copyWith(status: newStatus);
                      _updateItemInRepo(updatedItem);
                      Navigator.pop(ctx);
                    },
                    icon: Icon(
                      isPaused ? Icons.play_arrow : Icons.pause,
                      size: 18,
                      color: isPaused ? _primaryColor : Colors.amber.shade800,
                    ),
                    label: Text(
                      isPaused ? 'Resume' : 'Pause Item',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isPaused ? _primaryColor : Colors.amber.shade800,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Quantity Selector
              Text('Quantity per Delivery', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 18),
                          onPressed: qty > 1 ? () => setSheetState(() => qty -= 1) : null,
                        ),
                        Text(
                          '${qty.toInt()} ${item.unit}',
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 18),
                          onPressed: () => setSheetState(() => qty += 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '₹${(qty * item.pricePerUnit).toStringAsFixed(0)} / delivery',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: _primaryColor),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Frequency
              Text('Frequency', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: SubscriptionFrequency.values.map((f) {
                  final isSel = freq == f;
                  return ChoiceChip(
                    label: Text(f.label),
                    selected: isSel,
                    selectedColor: _primaryColor,
                    labelStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSel ? Colors.white : _textDark,
                    ),
                    onSelected: (_) => setSheetState(() => freq = f),
                  );
                }).toList(),
              ),

              if (freq == SubscriptionFrequency.weekly) ...[
                const SizedBox(height: 12),
                Text('Delivery Day', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: ['Daily', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'].map((d) {
                    final isSel = day == d;
                    return ChoiceChip(
                      label: Text(d, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: isSel ? Colors.white : _textMuted)),
                      selected: isSel,
                      selectedColor: _primaryColor,
                      onSelected: (_) => setSheetState(() => day = d),
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 20),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final updatedItem = item.copyWith(
                      quantity: qty,
                      frequency: freq,
                      deliveryDay: day,
                    );
                    _updateItemInRepo(updatedItem);
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Save Changes', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateItemInRepo(SubscriptionItem item) async {
    setState(() => _isLoading = true);
    try {
      await _subRepo.updateSubscriptionItem(_subscription.id, item);
      final idx = _subscription.items.indexWhere((i) => i.id == item.id);
      if (idx >= 0) {
        final newItems = List<SubscriptionItem>.from(_subscription.items);
        newItems[idx] = item;
        setState(() {
          _subscription = _subscription.copyWith(
            items: newItems,
            estimatedMonthlyAmount: _subscription.calculateEstimatedMonthlySpend(),
            updatedAt: DateTime.now(),
          );
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Item schedule updated successfully!', style: GoogleFonts.plusJakartaSans()),
            backgroundColor: _primaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e'), backgroundColor: _errorColor),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCancelled = _subscription.status == SubscriptionStatus.cancelled;
    final isPaused = _subscription.status == SubscriptionStatus.paused;

    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        title: Text(
          _subscription.planName,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: _textDark,
        elevation: 0.5,
        actions: [
          if (!isCancelled)
            IconButton(
              icon: Icon(
                isPaused ? Icons.play_circle_fill : Icons.pause_circle_filled,
                color: isPaused ? _primaryColor : Colors.amber.shade800,
              ),
              tooltip: isPaused ? 'Resume Subscription' : 'Pause Subscription',
              onPressed: _isLoading ? null : _toggleSubscriptionPause,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status & Plan Summary Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _subscription.status.bgColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _subscription.status.label,
                                style: TextStyle(
                                  color: _subscription.status.textColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '₹${_subscription.estimatedMonthlyAmount.toStringAsFixed(0)} / mo',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 16, color: _textMuted),
                            const SizedBox(width: 6),
                            Text(
                              'Delivery Slot: ${_subscription.deliverySlot}',
                              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: _textMuted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on_outlined, size: 16, color: _textMuted),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _subscription.deliveryAddress,
                                style: GoogleFonts.plusJakartaSans(fontSize: 13, color: _textMuted),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Items Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subscription Items',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _textDark,
                        ),
                      ),
                      if (!isCancelled)
                        TextButton.icon(
                          onPressed: () => AddToDeliveryModal.show(
                            context,
                            subscriptionId: _subscription.id,
                            onItemAdded: () => setState(() {}),
                          ),
                          icon: const Icon(Icons.add, size: 18, color: _primaryColor),
                          label: Text(
                            'Add Item',
                            style: GoogleFonts.plusJakartaSans(
                              color: _primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Item Cards List
                  ..._subscription.items.map((item) {
                    final itemPaused = item.status == SubscriptionItemStatus.paused;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: itemPaused ? Colors.amber.shade200 : Colors.grey.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: itemPaused ? Colors.grey.shade100 : const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(item.emoji, style: const TextStyle(fontSize: 22)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.productName,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: itemPaused ? Colors.grey : _textDark,
                                        ),
                                      ),
                                    ),
                                    if (itemPaused)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.shade50,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'Paused',
                                          style: GoogleFonts.plusJakartaSans(
                                            color: Colors.amber.shade800,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${item.quantity.toInt()} ${item.unit} • ${item.frequency.label} (${item.deliveryDay})',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '₹${(item.quantity * item.pricePerUnit).toStringAsFixed(0)} / delivery (~₹${item.estimatedMonthlyCost.toStringAsFixed(0)}/mo)',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isCancelled)
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20, color: _primaryColor),
                              onPressed: () => _editItem(item),
                            ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 24),

                  // Actions Section
                  if (!isCancelled) ...[
                    // Pause/Resume Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _toggleSubscriptionPause,
                        icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
                        label: Text(
                          isPaused ? 'Resume All Deliveries' : 'Pause All Deliveries',
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isPaused ? _primaryColor : Colors.amber.shade800,
                          side: BorderSide(
                            color: isPaused ? _primaryColor : Colors.amber.shade600,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Cancel Subscription Button
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: _isLoading ? null : _cancelSubscription,
                        child: Text(
                          'Cancel Subscription',
                          style: GoogleFonts.plusJakartaSans(
                            color: _errorColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
