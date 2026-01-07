import 'package:flutter_test/flutter_test.dart';
import 'package:platesnap/core/utils/plate_formatter.dart';

void main() {
  group('PlateFormatter', () {
    group('format', () {
      test('should format car plate correctly', () {
        expect(PlateFormatter.format('51G12345'), equals('51G-12345'));
        expect(PlateFormatter.format('30A99999'), equals('30A-99999'));
      });

      test('should format motorbike plate correctly', () {
        expect(PlateFormatter.format('59X112345'), equals('59X1-12345'));
        expect(PlateFormatter.format('29B167890'), equals('29B1-67890'));
      });

      test('should handle plates with spaces', () {
        expect(PlateFormatter.format('51G 12345'), equals('51G-12345'));
        expect(PlateFormatter.format('59 X1 12345'), equals('59X1-12345'));
      });

      test('should handle plates with dots', () {
        expect(PlateFormatter.format('51G-123.45'), equals('51G-12345'));
      });

      test('should convert to uppercase', () {
        expect(PlateFormatter.format('51g12345'), equals('51G-12345'));
        expect(PlateFormatter.format('59x112345'), equals('59X1-12345'));
      });

      test('should handle special plates with 2 letters', () {
        expect(PlateFormatter.format('51LD12345'), equals('51LD-12345'));
      });

      test('should handle 4-digit plates', () {
        expect(PlateFormatter.format('51G1234'), equals('51G-1234'));
        expect(PlateFormatter.format('59X11234'), equals('59X1-1234'));
      });
    });

    group('formatTwoLines', () {
      test('should combine two lines correctly', () {
        expect(PlateFormatter.formatTwoLines('59X1', '12345'), equals('59X1-12345'));
        expect(PlateFormatter.formatTwoLines('59-X1', '123.45'), equals('59X1-12345'));
      });
    });

    group('formatForDisplay', () {
      test('should add spaces around dash', () {
        expect(PlateFormatter.formatForDisplay('59A-12345'), equals('59A - 12345'));
      });

      test('should return unchanged if no dash', () {
        expect(PlateFormatter.formatForDisplay('59A12345'), equals('59A12345'));
      });
    });

    group('getProvinceName', () {
      test('should return province name for Ho Chi Minh codes', () {
        expect(PlateFormatter.getProvinceName('59A-12345'), equals('Ho Chi Minh'));
        expect(PlateFormatter.getProvinceName('51G-12345'), equals('Ho Chi Minh'));
      });

      test('should return province name for Ha Noi codes', () {
        expect(PlateFormatter.getProvinceName('29A-12345'), equals('Ha Noi'));
        expect(PlateFormatter.getProvinceName('30A-12345'), equals('Ha Noi'));
      });

      test('should return null for invalid codes', () {
        expect(PlateFormatter.getProvinceName('A'), isNull);
      });
    });
  });
}
