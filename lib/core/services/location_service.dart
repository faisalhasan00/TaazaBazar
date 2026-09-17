import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Structured result model for location operations
class LocationResult {
  final double? latitude;
  final double? longitude;
  final bool isSuccess;
  final String? errorMessage;
  final bool isPermissionDeniedForever;
  final String? flatNo;
  final String? street;
  final String? area;
  final String? city;
  final String? state;
  final String? pincode;
  final String? formattedAddress;

  const LocationResult({
    this.latitude,
    this.longitude,
    required this.isSuccess,
    this.errorMessage,
    this.isPermissionDeniedForever = false,
    this.flatNo,
    this.street,
    this.area,
    this.city,
    this.state,
    this.pincode,
    this.formattedAddress,
  });

  factory LocationResult.success(
    double lat,
    double lng, {
    String? flatNo,
    String? street,
    String? area,
    String? city,
    String? state,
    String? pincode,
    String? formattedAddress,
  }) {
    return LocationResult(
      latitude: lat,
      longitude: lng,
      isSuccess: true,
      flatNo: flatNo,
      street: street,
      area: area,
      city: city,
      state: state,
      pincode: pincode,
      formattedAddress: formattedAddress,
    );
  }

  factory LocationResult.failure(String message, {bool permissionDeniedForever = false}) {
    return LocationResult(
      isSuccess: false,
      errorMessage: message,
      isPermissionDeniedForever: permissionDeniedForever,
    );
  }
}

/// Service for checking permissions and fetching device GPS coordinates for delivery
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Check if location services (GPS) are enabled on the device
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      debugPrint('LocationService: Error checking location service status: $e');
      return false;
    }
  }

  /// Check current permission status
  Future<LocationPermission> checkPermission() async {
    try {
      return await Geolocator.checkPermission();
    } catch (e) {
      debugPrint('LocationService: Error checking permission: $e');
      return LocationPermission.denied;
    }
  }

  /// Request location permission from the customer
  Future<LocationPermission> requestPermission() async {
    try {
      return await Geolocator.requestPermission();
    } catch (e) {
      debugPrint('LocationService: Error requesting permission: $e');
      return LocationPermission.denied;
    }
  }

  /// Optional mock result for headless widget/unit tests
  static LocationResult? testMockResult;

  /// Reverse geocode coordinates into a human-readable address
  Future<Map<String, String>> reverseGeocode(double lat, double lng) async {
    if (!kIsWeb) {
      try {
        final client = HttpClient();
        client.userAgent = 'TaazaBazarCustomerApp/1.0 (support@taazabazar.in)';
        final uri = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1',
        );
        final request = await client.getUrl(uri).timeout(const Duration(seconds: 4));
        final response = await request.close().timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          final responseBody = await response.transform(utf8.decoder).join();
          final data = jsonDecode(responseBody) as Map<String, dynamic>;
          final address = data['address'] as Map<String, dynamic>?;

          if (address != null) {
            final houseNumber = address['house_number'] ?? address['building'] ?? '';
            final road = address['road'] ?? address['street'] ?? address['pedestrian'] ?? address['footway'] ?? '';
            final suburb = address['suburb'] ?? address['neighbourhood'] ?? address['residential'] ?? address['subdistrict'] ?? '';
            final city = address['city'] ?? address['town'] ?? address['city_district'] ?? address['municipality'] ?? address['county'] ?? 'Hyderabad';
            final state = address['state'] ?? 'Telangana';
            final postcode = address['postcode'] ?? '';

            return {
              'flatNo': houseNumber.isNotEmpty ? 'House No. $houseNumber' : (suburb.isNotEmpty ? suburb : 'Current GPS Location'),
              'street': road.isNotEmpty ? road : (suburb.isNotEmpty ? suburb : 'Delivery Location'),
              'area': suburb.isNotEmpty ? suburb : (road.isNotEmpty ? road : 'Local Area'),
              'city': city,
              'state': state,
              'pincode': postcode.isNotEmpty ? postcode : '500001',
              'formatted': data['display_name'] ?? '$road, $suburb, $city, $state',
            };
          }
        }
      } catch (e) {
        debugPrint('LocationService: Reverse geocoding network notice: $e');
      }
    }

    return {
      'flatNo': 'Current Location',
      'street': 'GPS Location (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)})',
      'area': 'Local Area',
      'city': 'Hyderabad',
      'state': 'Telangana',
      'pincode': '500001',
    };
  }

  /// Get current high-accuracy GPS coordinates for delivery address confirmation
  Future<LocationResult> getCurrentCoordinates({
    Duration timeLimit = const Duration(seconds: 10),
  }) async {
    if (testMockResult != null) {
      return testMockResult!;
    }

    try {
      // 1. Verify location services enabled
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationResult.failure(
          'Location services are disabled on your device. Please turn on GPS or enter your address manually.',
        );
      }

      // 2. Check & request permissions
      var permission = await checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationResult.failure(
            'Location permission was denied. Please allow location access to use your current location, or enter your address manually.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationResult.failure(
          'Location permissions are permanently denied in device settings. Please enable them in App Settings or enter address manually.',
          permissionDeniedForever: true,
        );
      }

      // 3. Fetch device GPS position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: timeLimit,
        ),
      );

      debugPrint(
        'LocationService: Successfully obtained GPS position (${position.latitude}, ${position.longitude})',
      );

      // 4. Reverse geocode coordinates to get real location details
      final geo = await reverseGeocode(position.latitude, position.longitude);

      return LocationResult.success(
        position.latitude,
        position.longitude,
        flatNo: geo['flatNo'],
        street: geo['street'],
        area: geo['area'],
        city: geo['city'],
        state: geo['state'],
        pincode: geo['pincode'],
        formattedAddress: geo['formatted'],
      );
    } on TimeoutException {
      debugPrint('LocationService: GPS fetch timed out.');
      return LocationResult.failure(
        'Unable to detect GPS location in time. Please try again or enter your address manually.',
      );
    } catch (e) {
      debugPrint('LocationService: Unexpected error obtaining location: $e');
      return LocationResult.failure(
        'Could not fetch current location ($e). Please enter address manually.',
      );
    }
  }
}
