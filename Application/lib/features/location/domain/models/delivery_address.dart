class DeliveryAddress {
  final String flatNo;
  final String street;
  final String area;
  final String city;
  final String state;
  final String pincode;
  final String? deliveryNote;

  const DeliveryAddress({
    required this.flatNo,
    required this.street,
    required this.area,
    required this.city,
    required this.state,
    required this.pincode,
    this.deliveryNote,
  });

  static const DeliveryAddress mockDefault = DeliveryAddress(
    flatNo: 'Flat 402, Oakwood',
    street: 'Plot No. 18, Road No. 2',
    area: 'Hitec City',
    city: 'Hyderabad',
    state: 'Telangana',
    pincode: '500081',
    deliveryNote: 'Leave the order at the security desk.',
  );
}
