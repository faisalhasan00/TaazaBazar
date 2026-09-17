import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/address_repository.dart';
import '../domain/models/delivery_address.dart';
import 'add_edit_address_screen.dart';

/// Screen: Saved Addresses Management Screen
class SavedAddressesScreen extends StatefulWidget {
  final bool isStandalone;
  final List<DeliveryAddress>? initialAddresses;
  final ValueChanged<DeliveryAddress>? onAddressSelected;

  const SavedAddressesScreen({
    super.key,
    this.isStandalone = true,
    this.initialAddresses,
    this.onAddressSelected,
  });

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  final _addressRepo = AddressRepository();
  late List<DeliveryAddress> _addresses;
  StreamSubscription<List<DeliveryAddress>>? _addressSubscription;

  @override
  void initState() {
    super.initState();
    _addresses = List<DeliveryAddress>.from(
      widget.initialAddresses ?? _addressRepo.cachedAddresses,
    );
    if (widget.initialAddresses == null) {
      _addressSubscription = _addressRepo.getAddressesStream().listen((list) {
        if (mounted) {
          setState(() {
            _addresses = List<DeliveryAddress>.from(list);
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _addressSubscription?.cancel();
    super.dispose();
  }

  void _setDefaultAddress(int index) {
    final selected = _addresses[index];
    setState(() {
      for (int i = 0; i < _addresses.length; i++) {
        _addresses[i] = _addresses[i].copyWith(isDefault: i == index);
      }
    });

    if (selected.id != null) {
      _addressRepo.setDefaultAddress(selected.id!);
    }

    if (widget.onAddressSelected != null) {
      widget.onAddressSelected!(selected);
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Default delivery address set to "${selected.label}"'),
        backgroundColor: const Color(0xFF166534),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _navigateToAddAddress() async {
    final newAddress = await Navigator.push<DeliveryAddress>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditAddressScreen(),
      ),
    );

    if (newAddress != null) {
      setState(() {
        if (newAddress.isDefault || _addresses.isEmpty) {
          // Unset other defaults
          _addresses = _addresses.map((a) => a.copyWith(isDefault: false)).toList();
          _addresses.insert(0, newAddress.copyWith(isDefault: true));
        } else {
          _addresses.add(newAddress);
        }
      });

      await _addressRepo.saveAddress(newAddress);

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${newAddress.label}" address added successfully!'),
            backgroundColor: const Color(0xFF166534),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _navigateToEditAddress(int index) async {
    final current = _addresses[index];
    final updatedAddress = await Navigator.push<DeliveryAddress>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditAddressScreen(initialAddress: current),
      ),
    );

    if (updatedAddress != null) {
      setState(() {
        if (updatedAddress.isDefault) {
          _addresses = _addresses.map((a) => a.copyWith(isDefault: false)).toList();
        }
        _addresses[index] = updatedAddress;
      });

      await _addressRepo.saveAddress(updatedAddress);

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${updatedAddress.label}" address updated successfully!'),
            backgroundColor: const Color(0xFF166534),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation(int index) {
    final address = _addresses[index];
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Delete Address',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          content: Text(
            'Are you sure you want to remove this ${address.label} address (${address.flatNo})?',
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
              key: const ValueKey('confirm_delete_address_btn'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                final wasDefault = address.isDefault;
                final addressId = address.id;

                setState(() {
                  _addresses.removeAt(index);
                  if (wasDefault && _addresses.isNotEmpty) {
                    _addresses[0] = _addresses[0].copyWith(isDefault: true);
                  }
                });

                if (addressId != null) {
                  _addressRepo.deleteAddress(addressId);
                }

                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Deleted "${address.label}" address'),
                    backgroundColor: const Color(0xFF0F172A),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Text(
                'Delete',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: widget.isStandalone
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
          'Saved Addresses',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _addresses.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      itemCount: _addresses.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final address = _addresses[index];
                        return _buildAddressCard(address, index);
                      },
                    ),
            ),

            // Sticky Bottom Add New Address Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: const Border(
                  top: BorderSide(color: Color(0xFFE2E8F0)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  key: const ValueKey('add_new_address_btn'),
                  onPressed: _navigateToAddAddress,
                  icon: const Icon(Icons.add_rounded, size: 22),
                  label: Text(
                    'Add New Address',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF166534),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(DeliveryAddress address, int index) {
    final isDefault = address.isDefault;

    IconData labelIcon;
    Color labelColor;
    Color labelBgColor;

    switch (address.label.toLowerCase()) {
      case 'work':
        labelIcon = Icons.work_rounded;
        labelColor = const Color(0xFF2563EB);
        labelBgColor = const Color(0xFFDBEAFE);
        break;
      case 'other':
        labelIcon = Icons.location_on_rounded;
        labelColor = const Color(0xFF7C3AED);
        labelBgColor = const Color(0xFFEDE9FE);
        break;
      case 'home':
      default:
        labelIcon = Icons.home_rounded;
        labelColor = const Color(0xFF166534);
        labelBgColor = const Color(0xFFDCFCE7);
        break;
    }

    return InkWell(
      key: ValueKey('address_card_${address.label.toLowerCase()}_$index'),
      onTap: () => _setDefaultAddress(index),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDefault ? const Color(0xFF166534) : const Color(0xFFE2E8F0),
            width: isDefault ? 1.8 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isDefault
                  ? const Color(0xFF166534).withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Label badge, Default badge, and Radio
            Row(
              children: [
                // Label Badge (Home / Work / Other)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: labelBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(labelIcon, size: 14, color: labelColor),
                      const SizedBox(width: 5),
                      Text(
                        address.label,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: labelColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isDefault) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF166534),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'DEFAULT',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
                if (address.hasCoordinates) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on_rounded, size: 12, color: Color(0xFF166534)),
                        const SizedBox(width: 3),
                        Text(
                          'GPS Pin',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF166534),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const Spacer(),
                // Default / Selected Radio Indicator
                Icon(
                  isDefault
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: isDefault ? const Color(0xFF166534) : const Color(0xFFCBD5E1),
                  size: 22,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // House/Flat, Building & Street
            Text(
              address.building != null && address.building!.isNotEmpty
                  ? '${address.flatNo}, ${address.building}, ${address.street}'
                  : '${address.flatNo}, ${address.street}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),

            // Area, City, State, PIN
            Text(
              '${address.area}, ${address.city}, ${address.state} - ${address.pincode}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
                height: 1.4,
              ),
            ),

            // Optional Delivery Note / Instructions
            if (address.deliveryNote != null && address.deliveryNote!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.note_alt_outlined,
                      size: 14,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        address.deliveryNote!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFF475569),
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 8),

            // Bottom Actions: Edit and Delete buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Edit Button
                TextButton.icon(
                  key: ValueKey('edit_address_btn_$index'),
                  onPressed: () => _navigateToEditAddress(index),
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: Color(0xFF166534),
                  ),
                  label: Text(
                    'Edit',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF166534),
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 12),
                // Delete Button
                TextButton.icon(
                  key: ValueKey('delete_address_btn_$index'),
                  onPressed: () => _showDeleteConfirmation(index),
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 16,
                    color: Color(0xFFDC2626),
                  ),
                  label: Text(
                    'Delete',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFDC2626),
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_off_rounded,
                size: 40,
                color: Color(0xFF166534),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Saved Addresses',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You haven\'t saved any delivery addresses yet. Add your home, work, or other locations for seamless ordering.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                color: const Color(0xFF64748B),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
