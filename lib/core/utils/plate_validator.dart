class PlateValidator {
  PlateValidator._();

  // Pattern for Vietnam plates
  // Car: 51G-12345 or 51G-1234
  // Motorbike: 59X1-12345 or 59X1-1234
  // Special: 51LD-12345
  static const String _vietnamPlatePattern =
      r'^[0-9]{2}[A-Z]{1,2}[0-9]?-[0-9]{4,5}$';

  /// Check if the plate number matches Vietnam plate format
  static bool isValid(String plate) {
    return RegExp(_vietnamPlatePattern).hasMatch(plate);
  }

  /// Get vehicle type based on plate pattern
  /// Returns 'car', 'motorbike', or null if unknown
  static String? getVehicleType(String plate) {
    // Car pattern: 2 digits + 1 letter + dash + 4-5 digits
    // Example: 51G-12345
    if (RegExp(r'^[0-9]{2}[A-Z]-[0-9]{4,5}$').hasMatch(plate)) {
      return 'car';
    }

    // Motorbike pattern: 2 digits + 1 letter + 1 digit + dash + 4-5 digits
    // Example: 59X1-12345
    if (RegExp(r'^[0-9]{2}[A-Z][0-9]-[0-9]{4,5}$').hasMatch(plate)) {
      return 'motorbike';
    }

    // Special plates: 2 digits + 2 letters + dash + 4-5 digits
    // Example: 51LD-12345
    if (RegExp(r'^[0-9]{2}[A-Z]{2}-[0-9]{4,5}$').hasMatch(plate)) {
      return 'car'; // Special plates are usually for cars
    }

    return null;
  }

  /// Check if province code is valid (01-99)
  static bool isValidProvinceCode(String code) {
    if (code.length != 2) return false;
    final numCode = int.tryParse(code);
    if (numCode == null) return false;
    return numCode >= 11 && numCode <= 99;
  }

  /// Extract province code from plate
  static String? getProvinceCode(String plate) {
    if (plate.length < 2) return null;
    final code = plate.substring(0, 2);
    if (isValidProvinceCode(code)) {
      return code;
    }
    return null;
  }

  /// Check if the series letter is valid
  static bool isValidSeriesLetter(String letter) {
    // Vietnam uses A-Z except I, O, Q (can be confused with numbers)
    const validLetters = 'ABCDEFGHJKLMNPRSTUVWXYZ';
    return validLetters.contains(letter.toUpperCase());
  }

  /// Validate plate with confidence score
  /// Returns a score from 0.0 to 1.0
  static double getValidationScore(String plate) {
    double score = 0.0;

    // Check basic format
    if (isValid(plate)) {
      score += 0.5;
    }

    // Check province code
    final provinceCode = getProvinceCode(plate);
    if (provinceCode != null && isValidProvinceCode(provinceCode)) {
      score += 0.2;
    }

    // Check vehicle type is recognized
    if (getVehicleType(plate) != null) {
      score += 0.2;
    }

    // Check length is reasonable (8-10 characters with dash)
    if (plate.length >= 8 && plate.length <= 11) {
      score += 0.1;
    }

    return score.clamp(0.0, 1.0);
  }
}
