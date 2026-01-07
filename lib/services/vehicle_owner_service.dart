import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/models/vehicle_owner.dart';

/// Service to fetch vehicle owner information
/// Currently uses fake data, will be replaced with API calls later
class VehicleOwnerService {
  static final _random = Random();

  // Fake names
  static const _maleNames = [
    'Nguyen Van An',
    'Tran Minh Duc',
    'Le Hoang Nam',
    'Pham Quoc Hung',
    'Vo Thanh Tung',
    'Dang Minh Tri',
    'Bui Xuan Truong',
    'Ho Chi Minh',
    'Ngo Dinh Cuong',
    'Ly Thai Son',
  ];

  static const _femaleNames = [
    'Nguyen Thi Lan',
    'Tran Thu Huong',
    'Le Mai Anh',
    'Pham Ngoc Linh',
    'Vo Thuy Tien',
    'Dang Bich Ngoc',
    'Bui Thu Ha',
    'Ho Thanh Thao',
    'Ngo Kim Chi',
    'Ly Hoai An',
  ];

  // Fake addresses
  static const _districts = [
    'Quan 1',
    'Quan 2',
    'Quan 3',
    'Quan 7',
    'Binh Thanh',
    'Phu Nhuan',
    'Thu Duc',
    'Go Vap',
    'Tan Binh',
    'Binh Tan',
  ];

  // Fake buildings
  static const _buildings = [
    'Vinhomes Central Park',
    'Landmark 81',
    'Sunwah Pearl',
    'The Manor',
    'Saigon Pearl',
    'Masteri Thao Dien',
    'Gateway Thao Dien',
    'Estella Heights',
    'Diamond Island',
    'Sala Sarimi',
  ];

  // Vehicle brands
  static const _carBrands = ['Toyota', 'Honda', 'Mazda', 'Hyundai', 'Kia', 'Mercedes', 'BMW', 'VinFast'];
  static const _bikeBrands = ['Honda', 'Yamaha', 'Suzuki', 'SYM', 'Piaggio', 'VinFast'];

  // Vehicle colors
  static const _colors = ['Trang', 'Den', 'Bac', 'Do', 'Xanh duong', 'Xanh la', 'Vang', 'Xam'];

  // Phone prefixes
  static const _phonePrefixes = ['090', '091', '093', '094', '096', '097', '098', '032', '033', '034', '035', '036'];

  /// Fetch vehicle owner information by plate number
  /// This is a mock implementation - will be replaced with API call later
  static Future<VehicleOwner?> fetchOwnerByPlate(String plateNumber) async {
    debugPrint('=== [VehicleOwnerService] Fetching owner for plate: $plateNumber');

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Always return fake data for demo
    final owner = _generateFakeOwner(plateNumber);
    debugPrint('=== [VehicleOwnerService] Generated owner: ${owner.fullName}, phone: ${owner.phoneNumber}');

    return owner;
  }

  static VehicleOwner _generateFakeOwner(String plateNumber) {
    final isMale = _random.nextBool();
    final names = isMale ? _maleNames : _femaleNames;
    final name = names[_random.nextInt(names.length)];
    final gender = isMale ? 'Nam' : 'Nu';
    final age = 25 + _random.nextInt(40);

    // Determine vehicle type from plate
    final isMotorbike = _isMotorbikePlate(plateNumber);
    final brands = isMotorbike ? _bikeBrands : _carBrands;
    final vehicleType = isMotorbike ? 'Xe may' : 'O to';

    return VehicleOwner(
      plateNumber: plateNumber,
      fullName: name,
      phoneNumber: _generatePhoneNumber(),
      gender: gender,
      age: age,
      address: _districts[_random.nextInt(_districts.length)],
      building: _buildings[_random.nextInt(_buildings.length)],
      apartment: 'P.${_random.nextInt(30) + 1}${String.fromCharCode(65 + _random.nextInt(6))}',
      vehicleType: vehicleType,
      vehicleBrand: brands[_random.nextInt(brands.length)],
      vehicleColor: _colors[_random.nextInt(_colors.length)],
    );
  }

  static String _generatePhoneNumber() {
    final prefix = _phonePrefixes[_random.nextInt(_phonePrefixes.length)];
    final suffix = List.generate(7, (_) => _random.nextInt(10)).join();
    return '$prefix$suffix';
  }

  static bool _isMotorbikePlate(String plate) {
    // Vietnamese motorbike plates typically have format like 59X1-12345
    // Car plates are like 51G-12345
    // Simplified check: if contains a digit after the letter, likely motorbike
    final regex = RegExp(r'[A-Z]\d');
    return regex.hasMatch(plate);
  }
}
