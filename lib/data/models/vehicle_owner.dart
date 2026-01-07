class VehicleOwner {
  final String plateNumber;
  final String fullName;
  final String phoneNumber;
  final String gender;
  final int age;
  final String address;
  final String building;
  final String apartment;
  final String vehicleType;
  final String vehicleBrand;
  final String vehicleColor;

  VehicleOwner({
    required this.plateNumber,
    required this.fullName,
    required this.phoneNumber,
    required this.gender,
    required this.age,
    required this.address,
    required this.building,
    required this.apartment,
    required this.vehicleType,
    required this.vehicleBrand,
    required this.vehicleColor,
  });

  String get displayAddress => '$building - $apartment, $address';

  factory VehicleOwner.fromJson(Map<String, dynamic> json) {
    return VehicleOwner(
      plateNumber: json['plate_number'] ?? '',
      fullName: json['full_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      gender: json['gender'] ?? '',
      age: json['age'] ?? 0,
      address: json['address'] ?? '',
      building: json['building'] ?? '',
      apartment: json['apartment'] ?? '',
      vehicleType: json['vehicle_type'] ?? '',
      vehicleBrand: json['vehicle_brand'] ?? '',
      vehicleColor: json['vehicle_color'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plate_number': plateNumber,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'gender': gender,
      'age': age,
      'address': address,
      'building': building,
      'apartment': apartment,
      'vehicle_type': vehicleType,
      'vehicle_brand': vehicleBrand,
      'vehicle_color': vehicleColor,
    };
  }
}
