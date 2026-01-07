class PlateFormatter {
  PlateFormatter._();

  /// Format raw OCR text to standard Vietnam plate format
  /// Input: "59A12345" or "59A 12345" or "59 A 123.45"
  /// Output: "59A-12345"
  static String format(String raw) {
    // Remove all non-alphanumeric characters
    String cleaned = raw.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();

    // Try to match Vietnam plate patterns
    // Car: 51G12345 -> 51G-12345
    final carPattern = RegExp(r'^(\d{2})([A-Z])(\d{5})$');
    if (carPattern.hasMatch(cleaned)) {
      final match = carPattern.firstMatch(cleaned)!;
      return '${match.group(1)}${match.group(2)}-${match.group(3)}';
    }

    // Motorbike: 59X112345 -> 59X1-12345
    final motorbikePattern = RegExp(r'^(\d{2})([A-Z]\d)(\d{5})$');
    if (motorbikePattern.hasMatch(cleaned)) {
      final match = motorbikePattern.firstMatch(cleaned)!;
      return '${match.group(1)}${match.group(2)}-${match.group(3)}';
    }

    // Car with 4 digits: 51G1234 -> 51G-1234
    final carPattern4 = RegExp(r'^(\d{2})([A-Z])(\d{4})$');
    if (carPattern4.hasMatch(cleaned)) {
      final match = carPattern4.firstMatch(cleaned)!;
      return '${match.group(1)}${match.group(2)}-${match.group(3)}';
    }

    // Motorbike with 4 digits: 59X11234 -> 59X1-1234
    final motorbikePattern4 = RegExp(r'^(\d{2})([A-Z]\d)(\d{4})$');
    if (motorbikePattern4.hasMatch(cleaned)) {
      final match = motorbikePattern4.firstMatch(cleaned)!;
      return '${match.group(1)}${match.group(2)}-${match.group(3)}';
    }

    // Special plates with 2 letters: 51LD12345 -> 51LD-12345
    final specialPattern = RegExp(r'^(\d{2})([A-Z]{2})(\d{4,5})$');
    if (specialPattern.hasMatch(cleaned)) {
      final match = specialPattern.firstMatch(cleaned)!;
      return '${match.group(1)}${match.group(2)}-${match.group(3)}';
    }

    // Return as-is if no pattern match
    return cleaned;
  }

  /// Combine two lines of plate text (for 2-line motorbike plates)
  /// Input: "59X1", "12345" -> "59X1-12345"
  static String formatTwoLines(String line1, String line2) {
    String cleaned1 = line1.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
    String cleaned2 = line2.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();

    // Remove dots from line2 (e.g., "123.45" -> "12345")
    cleaned2 = cleaned2.replaceAll('.', '');

    return '$cleaned1-$cleaned2';
  }

  /// Add spaces for display: "59A-12345" -> "59A - 12345"
  static String formatForDisplay(String plate) {
    if (plate.contains('-')) {
      return plate.replaceAll('-', ' - ');
    }
    return plate;
  }

  /// Get province name from plate code
  static String? getProvinceName(String plate) {
    if (plate.length < 2) return null;

    final code = plate.substring(0, 2);
    return _provinceCodes[code];
  }

  static const Map<String, String> _provinceCodes = {
    '11': 'Cao Bang',
    '12': 'Lang Son',
    '14': 'Quang Ninh',
    '15': 'Hai Phong',
    '16': 'Hai Phong',
    '17': 'Thai Binh',
    '18': 'Nam Dinh',
    '19': 'Phu Tho',
    '20': 'Thai Nguyen',
    '21': 'Yen Bai',
    '22': 'Tuyen Quang',
    '23': 'Ha Giang',
    '24': 'Lao Cai',
    '25': 'Lai Chau',
    '26': 'Son La',
    '27': 'Dien Bien',
    '28': 'Hoa Binh',
    '29': 'Ha Noi',
    '30': 'Ha Noi',
    '31': 'Ha Noi',
    '32': 'Ha Noi',
    '33': 'Ha Noi',
    '34': 'Hai Duong',
    '35': 'Ninh Binh',
    '36': 'Thanh Hoa',
    '37': 'Nghe An',
    '38': 'Ha Tinh',
    '39': 'Dong Nai',
    '40': 'Ha Noi',
    '41': 'Ho Chi Minh',
    '43': 'Da Nang',
    '47': 'Dak Lak',
    '48': 'Dak Nong',
    '49': 'Lam Dong',
    '50': 'Ho Chi Minh',
    '51': 'Ho Chi Minh',
    '52': 'Ho Chi Minh',
    '53': 'Ho Chi Minh',
    '54': 'Ho Chi Minh',
    '55': 'Ho Chi Minh',
    '56': 'Ho Chi Minh',
    '57': 'Ho Chi Minh',
    '58': 'Ho Chi Minh',
    '59': 'Ho Chi Minh',
    '60': 'Dong Nai',
    '61': 'Binh Duong',
    '62': 'Long An',
    '63': 'Tien Giang',
    '64': 'Vinh Long',
    '65': 'Can Tho',
    '66': 'Dong Thap',
    '67': 'An Giang',
    '68': 'Kien Giang',
    '69': 'Ca Mau',
    '70': 'Tay Ninh',
    '71': 'Ben Tre',
    '72': 'Ba Ria - Vung Tau',
    '73': 'Quang Binh',
    '74': 'Quang Tri',
    '75': 'Thua Thien Hue',
    '76': 'Quang Ngai',
    '77': 'Binh Dinh',
    '78': 'Phu Yen',
    '79': 'Khanh Hoa',
    '81': 'Gia Lai',
    '82': 'Kon Tum',
    '83': 'Soc Trang',
    '84': 'Tra Vinh',
    '85': 'Ninh Thuan',
    '86': 'Binh Thuan',
    '88': 'Vinh Phuc',
    '89': 'Hung Yen',
    '90': 'Ha Nam',
    '92': 'Quang Nam',
    '93': 'Binh Phuoc',
    '94': 'Bac Lieu',
    '95': 'Hau Giang',
    '97': 'Bac Kan',
    '98': 'Bac Giang',
    '99': 'Bac Ninh',
  };
}
