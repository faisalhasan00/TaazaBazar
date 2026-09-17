import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/location_service.dart';
import '../domain/models/delivery_address.dart';

/// Screen: Add or Edit a Delivery Address with GPS and complete building fields
class AddEditAddressScreen extends StatefulWidget {
  final DeliveryAddress? initialAddress;

  const AddEditAddressScreen({
    super.key,
    this.initialAddress,
  });

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _selectedLabel;
  late TextEditingController _flatController;
  late TextEditingController _buildingController;
  late TextEditingController _streetController;
  late TextEditingController _areaController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pinController;
  late TextEditingController _landmarkController;
  late TextEditingController _noteController;
  late bool _isDefault;
  double? _latitude;
  double? _longitude;
  bool _isFetchingGps = false;

  bool get isEditing => widget.initialAddress != null;

  @override
  void initState() {
    super.initState();
    final addr = widget.initialAddress;
    _selectedLabel = addr?.label ?? 'Home';
    _flatController = TextEditingController(text: addr?.flatNo ?? '');
    _buildingController = TextEditingController(text: addr?.building ?? '');
    _streetController = TextEditingController(text: addr?.street ?? '');
    _areaController = TextEditingController(text: addr?.area ?? '');
    _cityController = TextEditingController(text: addr?.city ?? 'Hyderabad');
    _stateController = TextEditingController(text: addr?.state ?? 'Telangana');
    _pinController = TextEditingController(text: addr?.pincode ?? '');
    _landmarkController = TextEditingController(text: addr?.landmark ?? '');
    _noteController = TextEditingController(text: addr?.deliveryNote ?? '');
    _isDefault = addr?.isDefault ?? false;
    _latitude = addr?.latitude;
    _longitude = addr?.longitude;
  }

  @override
  void dispose() {
    _flatController.dispose();
    _buildingController.dispose();
    _streetController.dispose();
    _areaController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pinController.dispose();
    _landmarkController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrentGps() async {
    if (_isFetchingGps) return;
    setState(() => _isFetchingGps = true);

    final result = await LocationService().getCurrentCoordinates();
    if (!mounted) return;

    setState(() => _isFetchingGps = false);

    if (result.isSuccess && result.latitude != null && result.longitude != null) {
      setState(() {
        _latitude = result.latitude;
        _longitude = result.longitude;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text('📍 Exact delivery location captured!'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF166534),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Could not detect GPS location.'),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      final savedAddress = DeliveryAddress(
        id: widget.initialAddress?.id ?? 'addr-${DateTime.now().millisecondsSinceEpoch}',
        label: _selectedLabel,
        flatNo: _flatController.text.trim(),
        building: _buildingController.text.trim().isNotEmpty
            ? _buildingController.text.trim()
            : null,
        street: _streetController.text.trim(),
        area: _areaController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        pincode: _pinController.text.trim(),
        landmark: _landmarkController.text.trim().isNotEmpty
            ? _landmarkController.text.trim()
            : null,
        deliveryNote: _noteController.text.trim().isNotEmpty
            ? _noteController.text.trim()
            : null,
        isDefault: _isDefault,
        latitude: _latitude,
        longitude: _longitude,
      );

      Navigator.of(context).pop(savedAddress);
    }
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
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Color(0xFF0F172A),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isEditing ? 'Edit Address' : 'Add New Address',
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
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    // GPS Location Banner
                    _buildGpsBanner(),
                    const SizedBox(height: 16),

                    // Address Type / Label Selector
                    _buildLabelSelector(),
                    const SizedBox(height: 16),

                    // Flat / House / Floor
                    _buildInputField(
                      label: 'House / Flat / Door No.',
                      controller: _flatController,
                      hint: 'e.g. Flat 101 / House No. 12',
                      key: const ValueKey('address_flat_field'),
                    ),
                    const SizedBox(height: 14),

                    // Building / Apartment
                    _buildInputField(
                      label: 'Building / Apartment',
                      controller: _buildingController,
                      hint: 'e.g. Green Heights / Society Name (Optional)',
                      key: const ValueKey('address_building_field'),
                      isRequired: false,
                    ),
                    const SizedBox(height: 14),

                    // Building / Street
                    _buildInputField(
                      label: 'Street / Road',
                      controller: _streetController,
                      hint: 'e.g. Plot No. 18, Main Road',
                      key: const ValueKey('address_street_field'),
                    ),
                    const SizedBox(height: 14),

                    // Area
                    _buildInputField(
                      label: 'Area / Colony',
                      controller: _areaController,
                      hint: 'e.g. Madhapur / Hitec City',
                      key: const ValueKey('address_area_field'),
                    ),
                    const SizedBox(height: 14),

                    // Landmark
                    _buildInputField(
                      label: 'Landmark',
                      controller: _landmarkController,
                      hint: 'e.g. Near Community Park (Optional)',
                      key: const ValueKey('address_landmark_field'),
                      isRequired: false,
                    ),
                    const SizedBox(height: 14),

                    // City & State Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputField(
                            label: 'City',
                            controller: _cityController,
                            hint: 'e.g. Hyderabad',
                            key: const ValueKey('address_city_field'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInputField(
                            label: 'State',
                            controller: _stateController,
                            hint: 'e.g. Telangana',
                            key: const ValueKey('address_state_field'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // PIN Code
                    _buildInputField(
                      label: 'PIN Code',
                      controller: _pinController,
                      hint: 'e.g. 500081',
                      keyboardType: TextInputType.number,
                      key: const ValueKey('address_pincode_field'),
                      formatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter PIN code';
                        }
                        if (value.trim().length != 6) {
                          return 'PIN code must be 6 digits';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Delivery Instructions (Optional)
                    _buildDeliveryInstructionsField(),
                    const SizedBox(height: 16),

                    // Set as Default Address Switch
                    _buildDefaultSwitch(),
                  ],
                ),
              ),
            ),

            // Sticky Bottom Save Address Button
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
                child: ElevatedButton(
                  key: const ValueKey('save_address_btn'),
                  onPressed: _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF166534),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Save Address',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
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

  Widget _buildGpsBanner() {
    final hasCoords = _latitude != null && _longitude != null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: hasCoords ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasCoords ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: hasCoords ? const Color(0xFFDCFCE7) : const Color(0xFFE2E8F0),
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasCoords ? Icons.my_location_rounded : Icons.location_searching_rounded,
              color: hasCoords ? const Color(0xFF166534) : const Color(0xFF64748B),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasCoords ? 'Exact Delivery Pin Attached' : 'Delivery Pin (Optional)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasCoords
                      ? 'Rider will navigate directly to this spot'
                      : 'Capture current GPS for accurate drop-off',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _isFetchingGps ? null : _fetchCurrentGps,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF166534),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            child: _isFetchingGps
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF166534),
                    ),
                  )
                : Text(
                    hasCoords ? 'Update' : 'Capture',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabelSelector() {
    final labels = [
      {'label': 'Home', 'icon': Icons.home_rounded},
      {'label': 'Work', 'icon': Icons.work_rounded},
      {'label': 'Other', 'icon': Icons.location_on_rounded},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Save As',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: labels.map((item) {
            final labelText = item['label'] as String;
            final icon = item['icon'] as IconData;
            final isSelected = _selectedLabel == labelText;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedLabel = labelText;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFDCFCE7) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF166534) : const Color(0xFFE2E8F0),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          size: 18,
                          color: isSelected ? const Color(0xFF166534) : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          labelText,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? const Color(0xFF166534) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    Key? key,
    bool isRequired = true,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? formatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF334155),
              ),
            ),
            if (!isRequired) ...[
              const SizedBox(width: 6),
              Text(
                '(Optional)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: TextFormField(
            key: key,
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: formatters,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF94A3B8),
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            validator: validator ??
                (value) {
                  if (isRequired && (value == null || value.trim().isEmpty)) {
                    return 'Please enter $label';
                  }
                  return null;
                },
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryInstructionsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Delivery Instructions',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF334155),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '(Optional)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: TextFormField(
            key: const ValueKey('address_instructions_field'),
            controller: _noteController,
            maxLines: 2,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              hintText: 'e.g. Leave at door, ring doorbell, call on arrival',
              hintStyle: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF94A3B8),
                fontSize: 13,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultSwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                color: Color(0xFF166534),
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'Set as default delivery address',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          Switch.adaptive(
            key: const ValueKey('address_default_switch'),
            value: _isDefault,
            activeTrackColor: const Color(0xFF166534),
            activeThumbColor: Colors.white,
            onChanged: (val) {
              setState(() {
                _isDefault = val;
              });
            },
          ),
        ],
      ),
    );
  }
}
