extension StringExtensions on String {
  /// Check if string is a valid Vietnam plate number
  bool get isValidPlate {
    final pattern = RegExp(r'^[0-9]{2}[A-Z]{1,2}[0-9]?-[0-9]{4,5}$');
    return pattern.hasMatch(this);
  }

  /// Capitalize first letter of each word
  String get titleCase {
    if (isEmpty) return this;
    return split(' ')
        .map((word) => word.isEmpty
            ? ''
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }

  /// Remove all whitespace
  String get removeWhitespace => replaceAll(RegExp(r'\s+'), '');

  /// Keep only alphanumeric characters
  String get alphanumericOnly => replaceAll(RegExp(r'[^A-Za-z0-9]'), '');

  /// Truncate string with ellipsis
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - suffix.length)}$suffix';
  }

  /// Check if string contains only digits
  bool get isDigitsOnly => RegExp(r'^[0-9]+$').hasMatch(this);

  /// Check if string contains only letters
  bool get isLettersOnly => RegExp(r'^[A-Za-z]+$').hasMatch(this);

  /// Convert to plate display format with spaces
  String get toPlateDisplay {
    if (contains('-')) {
      return replaceAll('-', ' - ');
    }
    return this;
  }
}
