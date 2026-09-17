import 'package:flutter_test/flutter_test.dart';
import 'package:taazabazar/core/services/location_service.dart';
import 'package:taazabazar/features/checkout/domain/order_model.dart';
import 'package:taazabazar/features/location/domain/models/delivery_address.dart';
import 'package:taazabazar/features/orders/domain/customer_order.dart';

void main() {
  group('DeliveryAddress Model & Coordinate Tests', () {
    test('DeliveryAddress with GPS coordinates serializes toMap correctly', () {
      const address = DeliveryAddress(
        id: 'addr-test-1',
        label: 'Home',
        flatNo: 'Flat 402',
        building: 'Oakwood Apartments',
        street: 'Road No. 2',
        area: 'Hitec City',
        city: 'Hyderabad',
        state: 'Telangana',
        pincode: '500081',
        landmark: 'Near Cyber Gateway',
        deliveryNote: 'Ring bell once',
        isDefault: true,
        latitude: 17.448293,
        longitude: 78.381489,
      );

      final map = address.toMap();
      expect(map['id'], 'addr-test-1');
      expect(map['label'], 'Home');
      expect(map['flatNo'], 'Flat 402');
      expect(map['building'], 'Oakwood Apartments');
      expect(map['landmark'], 'Near Cyber Gateway');
      expect(map['latitude'], 17.448293);
      expect(map['longitude'], 78.381489);
      expect(address.hasCoordinates, isTrue);
      expect(address.formattedAddress, contains('Oakwood Apartments'));
      expect(address.formattedAddress, contains('Near Cyber Gateway'));
    });

    test('DeliveryAddress without coordinates (backward compatibility) deserializes seamlessly', () {
      final legacyMap = {
        'id': 'legacy-addr-1',
        'label': 'Work',
        'flatNo': 'Tower B, 5th Floor',
        'street': 'Mindspace',
        'area': 'Madhapur',
        'city': 'Hyderabad',
        'state': 'Telangana',
        'pincode': '500081',
        'isDefault': false,
      };

      final address = DeliveryAddress.fromMap(legacyMap);
      expect(address.id, 'legacy-addr-1');
      expect(address.label, 'Work');
      expect(address.flatNo, 'Tower B, 5th Floor');
      expect(address.latitude, isNull);
      expect(address.longitude, isNull);
      expect(address.building, isNull);
      expect(address.landmark, isNull);
      expect(address.hasCoordinates, isFalse);
    });

    test('DeliveryAddress handles string and numeric coordinate formats in fromMap', () {
      final mapWithNumbers = {
        'flatNo': '101',
        'street': 'Street 1',
        'area': 'Area',
        'city': 'Hyd',
        'state': 'TS',
        'pincode': '500001',
        'latitude': 17.45,
        'longitude': 78.38,
      };
      final addrNum = DeliveryAddress.fromMap(mapWithNumbers);
      expect(addrNum.latitude, 17.45);
      expect(addrNum.longitude, 78.38);

      final mapWithStrings = {
        'flatNo': '101',
        'street': 'Street 1',
        'area': 'Area',
        'city': 'Hyd',
        'state': 'TS',
        'pincode': '500001',
        'latitude': '17.45123',
        'longitude': '78.38456',
      };
      final addrStr = DeliveryAddress.fromMap(mapWithStrings);
      expect(addrStr.latitude, 17.45123);
      expect(addrStr.longitude, 78.38456);
    });

    test('copyWith preserves existing coordinates and full address fields', () {
      const address = DeliveryAddress(
        id: 'addr-1',
        flatNo: '301',
        building: 'Green Palms',
        street: 'Main Road',
        area: 'Gachibowli',
        city: 'Hyderabad',
        state: 'Telangana',
        pincode: '500032',
        landmark: 'Opp Metro',
        latitude: 17.4401,
        longitude: 78.3489,
        isDefault: false,
      );

      final updated = address.copyWith(isDefault: true);
      expect(updated.isDefault, isTrue);
      expect(updated.building, 'Green Palms');
      expect(updated.landmark, 'Opp Metro');
      expect(updated.latitude, 17.4401);
      expect(updated.longitude, 78.3489);
    });
  });

  group('CustomerOrder & Order Schema Coordinate Tests', () {
    test('CustomerOrder serializes delivery coordinates into toMap', () {
      final order = CustomerOrder(
        orderId: '#FRSH-99001',
        orderDate: DateTime.now(),
        slotDate: 'Tomorrow',
        timeSlot: '6:00 AM – 8:00 AM',
        status: OrderStatus.placed,
        items: const [],
        itemTotal: 100.0,
        deliveryFee: 25.0,
        discount: 0.0,
        grandTotal: 125.0,
        paymentMethod: PaymentMethod.cashOnDelivery,
        deliveryAddress: 'Flat 402, Oakwood, Hitec City, Hyderabad - 500081',
        deliveryLatitude: 17.448293,
        deliveryLongitude: 78.381489,
        timeline: const [],
      );

      final map = order.toMap();
      expect(map['orderId'], '#FRSH-99001');
      expect(map['deliveryAddress'], contains('Flat 402'));
      expect(map['deliveryLatitude'], 17.448293);
      expect(map['deliveryLongitude'], 78.381489);
    });

    test('CustomerOrder deserializes legacy orders without coordinates seamlessly', () {
      final legacyOrderMap = {
        'orderId': '#FRSH-88002',
        'orderDate': '2026-09-14T10:00:00.000Z',
        'slotDate': 'Tomorrow',
        'timeSlot': '6:00 AM – 8:00 AM',
        'status': 'placed',
        'items': [],
        'itemTotal': 200.0,
        'deliveryFee': 0.0,
        'discount': 0.0,
        'grandTotal': 200.0,
        'paymentMethod': 'cashOnDelivery',
        'deliveryAddress': 'Flat 101, Madhapur, Hyderabad',
      };

      final order = CustomerOrder.fromMap(legacyOrderMap);
      expect(order.orderId, '#FRSH-88002');
      expect(order.deliveryAddress, 'Flat 101, Madhapur, Hyderabad');
      expect(order.deliveryLatitude, isNull);
      expect(order.deliveryLongitude, isNull);
    });
  });

  group('LocationResult & LocationService Model Tests', () {
    test('LocationResult success factory initializes coordinates and status', () {
      final result = LocationResult.success(17.44, 78.38);
      expect(result.isSuccess, isTrue);
      expect(result.latitude, 17.44);
      expect(result.longitude, 78.38);
      expect(result.errorMessage, isNull);
    });

    test('LocationResult failure factory handles error message and permission flags', () {
      final failure = LocationResult.failure('Permission denied', permissionDeniedForever: true);
      expect(failure.isSuccess, isFalse);
      expect(failure.errorMessage, 'Permission denied');
      expect(failure.isPermissionDeniedForever, isTrue);
      expect(failure.latitude, isNull);
      expect(failure.longitude, isNull);
    });
  });
}
