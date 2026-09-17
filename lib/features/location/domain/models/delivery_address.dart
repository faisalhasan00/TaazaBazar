class DeliveryAddress {
  final String? id;
  final String label; // 'Home', 'Work', 'Other'
  final String flatNo;
  final String? building; // 'Apartment / Building name'
  final String street;
  final String area;
  final String city;
  final String state;
  final String pincode;
  final String? landmark;
  final String? deliveryNote;
  final bool isDefault;
  final double? latitude;
  final double? longitude;

  const DeliveryAddress({
    this.id,
    this.label = 'Home',
    required this.flatNo,
    this.building,
    required this.street,
    required this.area,
    required this.city,
    required this.state,
    required this.pincode,
    this.landmark,
    this.deliveryNote,
    this.isDefault = false,
    this.latitude,
    this.longitude,
  });

  bool get hasCoordinates => latitude != null && longitude != null;

  String get formattedAddress {
    final parts = <String>[];
    if (flatNo.isNotEmpty) parts.add(flatNo);
    if (building != null && building!.trim().isNotEmpty) parts.add(building!.trim());
    if (street.isNotEmpty) parts.add(street);
    if (landmark != null && landmark!.trim().isNotEmpty) parts.add('Near ${landmark!.trim()}');
    if (area.isNotEmpty) parts.add(area);
    if (city.isNotEmpty) parts.add(city);
    final statePin = (state.isNotEmpty && pincode.isNotEmpty)
        ? '$state - $pincode'
        : (state.isNotEmpty ? state : pincode);
    if (statePin.isNotEmpty) parts.add(statePin);
    return parts.join(', ');
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'flatNo': flatNo,
      'building': building,
      'street': street,
      'area': area,
      'city': city,
      'state': state,
      'pincode': pincode,
      'landmark': landmark,
      'deliveryNote': deliveryNote,
      'isDefault': isDefault,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory DeliveryAddress.fromMap(Map<String, dynamic> map, [String? docId]) {
    double? parseCoord(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    return DeliveryAddress(
      id: docId ?? map['id']?.toString(),
      label: map['label']?.toString() ?? 'Home',
      flatNo: map['flatNo']?.toString() ?? '',
      building: map['building']?.toString(),
      street: map['street']?.toString() ?? '',
      area: map['area']?.toString() ?? '',
      city: map['city']?.toString() ?? '',
      state: map['state']?.toString() ?? '',
      pincode: map['pincode']?.toString() ?? '',
      landmark: map['landmark']?.toString(),
      deliveryNote: map['deliveryNote']?.toString(),
      isDefault: map['isDefault'] == true,
      latitude: parseCoord(map['latitude']),
      longitude: parseCoord(map['longitude']),
    );
  }

  DeliveryAddress copyWith({
    String? id,
    String? label,
    String? flatNo,
    String? building,
    String? street,
    String? area,
    String? city,
    String? state,
    String? pincode,
    String? landmark,
    String? deliveryNote,
    bool? isDefault,
    double? latitude,
    double? longitude,
  }) {
    return DeliveryAddress(
      id: id ?? this.id,
      label: label ?? this.label,
      flatNo: flatNo ?? this.flatNo,
      building: building ?? this.building,
      street: street ?? this.street,
      area: area ?? this.area,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      landmark: landmark ?? this.landmark,
      deliveryNote: deliveryNote ?? this.deliveryNote,
      isDefault: isDefault ?? this.isDefault,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  static const DeliveryAddress mockDefault = DeliveryAddress(
    id: 'addr-1',
    label: 'Home',
    flatNo: 'Flat 402, Oakwood',
    street: 'Plot No. 18, Road No. 2',
    area: 'Hitec City',
    city: 'Hyderabad',
    state: 'Telangana',
    pincode: '500081',
    deliveryNote: 'Leave the order at the security desk.',
    isDefault: true,
  );

  static const List<DeliveryAddress> mockAddresses = [
    DeliveryAddress(
      id: 'addr-1',
      label: 'Home',
      flatNo: 'Flat 402, Oakwood',
      street: 'Plot No. 18, Road No. 2',
      area: 'Hitec City',
      city: 'Hyderabad',
      state: 'Telangana',
      pincode: '500081',
      deliveryNote: 'Leave the order at the security desk.',
      isDefault: true,
    ),
    DeliveryAddress(
      id: 'addr-2',
      label: 'Work',
      flatNo: 'Tower B, 5th Floor',
      street: 'Cyber Gateway, Mindspace',
      area: 'Madhapur',
      city: 'Hyderabad',
      state: 'Telangana',
      pincode: '500081',
      deliveryNote: 'Call on arrival at the front desk reception.',
      isDefault: false,
    ),
    DeliveryAddress(
      id: 'addr-3',
      label: 'Other',
      flatNo: 'Villa 12',
      street: 'Green Meadows, Financial District',
      area: 'Gachibowli',
      city: 'Hyderabad',
      state: 'Telangana',
      pincode: '500032',
      deliveryNote: 'Ring the doorbell twice.',
      isDefault: false,
    ),
  ];
}
