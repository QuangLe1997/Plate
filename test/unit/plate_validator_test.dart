import 'package:flutter_test/flutter_test.dart';
import 'package:platesnap/core/utils/plate_validator.dart';

void main() {
  group('PlateValidator', () {
    group('isValid', () {
      test('should return true for valid car plates', () {
        expect(PlateValidator.isValid('51G-12345'), isTrue);
        expect(PlateValidator.isValid('30A-99999'), isTrue);
        expect(PlateValidator.isValid('43B-1234'), isTrue);
      });

      test('should return true for valid motorbike plates', () {
        expect(PlateValidator.isValid('59X1-12345'), isTrue);
        expect(PlateValidator.isValid('29B1-67890'), isTrue);
      });

      test('should return true for valid special plates', () {
        expect(PlateValidator.isValid('51LD-12345'), isTrue);
      });

      test('should return false for invalid plates', () {
        expect(PlateValidator.isValid('ABC-12345'), isFalse);
        expect(PlateValidator.isValid('12345'), isFalse);
        expect(PlateValidator.isValid('51G12345'), isFalse); // Missing dash
        expect(PlateValidator.isValid(''), isFalse);
      });
    });

    group('getVehicleType', () {
      test('should return car for car plates', () {
        expect(PlateValidator.getVehicleType('51G-12345'), equals('car'));
        expect(PlateValidator.getVehicleType('30A-99999'), equals('car'));
      });

      test('should return motorbike for motorbike plates', () {
        expect(PlateValidator.getVehicleType('59X1-12345'), equals('motorbike'));
        expect(PlateValidator.getVehicleType('29B1-67890'), equals('motorbike'));
      });

      test('should return car for special plates', () {
        expect(PlateValidator.getVehicleType('51LD-12345'), equals('car'));
      });

      test('should return null for unknown formats', () {
        expect(PlateValidator.getVehicleType('ABC-12345'), isNull);
      });
    });

    group('isValidProvinceCode', () {
      test('should return true for valid province codes', () {
        expect(PlateValidator.isValidProvinceCode('29'), isTrue);
        expect(PlateValidator.isValidProvinceCode('59'), isTrue);
        expect(PlateValidator.isValidProvinceCode('43'), isTrue);
      });

      test('should return false for invalid province codes', () {
        expect(PlateValidator.isValidProvinceCode('00'), isFalse);
        expect(PlateValidator.isValidProvinceCode('10'), isFalse);
        expect(PlateValidator.isValidProvinceCode('AB'), isFalse);
        expect(PlateValidator.isValidProvinceCode('1'), isFalse);
      });
    });

    group('getProvinceCode', () {
      test('should extract province code correctly', () {
        expect(PlateValidator.getProvinceCode('59A-12345'), equals('59'));
        expect(PlateValidator.getProvinceCode('29B1-67890'), equals('29'));
      });

      test('should return null for invalid plates', () {
        expect(PlateValidator.getProvinceCode('A'), isNull);
      });
    });

    group('getValidationScore', () {
      test('should return high score for valid plates', () {
        final score = PlateValidator.getValidationScore('51G-12345');
        expect(score, greaterThan(0.8));
      });

      test('should return lower score for partial matches', () {
        final validScore = PlateValidator.getValidationScore('51G-12345');
        final invalidScore = PlateValidator.getValidationScore('ABC-12345');
        expect(validScore, greaterThan(invalidScore));
      });

      test('should return score between 0 and 1', () {
        final score = PlateValidator.getValidationScore('51G-12345');
        expect(score, greaterThanOrEqualTo(0.0));
        expect(score, lessThanOrEqualTo(1.0));
      });
    });
  });
}
