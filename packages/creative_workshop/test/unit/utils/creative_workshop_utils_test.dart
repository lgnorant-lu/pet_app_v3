/*
---------------------------------------------------------------
File name:          creative_workshop_utils_test.dart
Author:             lgnorant-lu
Date created:       2025-07-19
Last modified:      2025-07-19
Dart Version:       3.2+
Description:        creative_workshop工具类和辅助函数单元测试
---------------------------------------------------------------
Change History:
    2025-07-19: Initial creation - creative_workshop工具类和辅助函数单元测试;
---------------------------------------------------------------
*/

import 'package:test/test.dart';
import 'package:creative_workshop/src/utils/creative_workshop_utils.dart';

void main() {
  group('CreativeWorkshopUtils Tests', () {
    test('should validate email correctly', () {
      expect(CreativeWorkshopUtils.isValidEmail('test@example.com'), isTrue);
      expect(CreativeWorkshopUtils.isValidEmail('invalid-email'), isFalse);
      expect(CreativeWorkshopUtils.isValidEmail(''), isFalse);
      expect(CreativeWorkshopUtils.isValidEmail('test@'), isFalse);
      expect(CreativeWorkshopUtils.isValidEmail('@example.com'), isFalse);
    });

    test('should validate password correctly', () {
      expect(CreativeWorkshopUtils.isValidPassword('password123'), isTrue);
      expect(CreativeWorkshopUtils.isValidPassword('short'), isFalse);
      expect(CreativeWorkshopUtils.isValidPassword(''), isFalse);
      expect(CreativeWorkshopUtils.isValidPassword('12345678'), isTrue);
    });

    test('should format to title case correctly', () {
      expect(CreativeWorkshopUtils.formatToTitleCase('hello world'),
          equals('Hello world'));
      expect(CreativeWorkshopUtils.formatToTitleCase('HELLO'), equals('Hello'));
      expect(CreativeWorkshopUtils.formatToTitleCase(''), equals(''));
      expect(CreativeWorkshopUtils.formatToTitleCase('test'), equals('Test'));
    });

    test('should format date time correctly', () {
      final dateTime = DateTime(2025, 7, 18, 14, 30, 45);
      final formatted = CreativeWorkshopUtils.formatDateTime(dateTime);

      expect(formatted, equals('2025-07-18'));
    });
  });

  group('CreativeWorkshopValidator Tests', () {
    test('should validate email correctly', () {
      expect(
          CreativeWorkshopValidator.isValidEmail('test@example.com'), isTrue);
      expect(CreativeWorkshopValidator.isValidEmail('invalid-email'), isFalse);
      expect(CreativeWorkshopValidator.isValidEmail(''), isFalse);
      expect(CreativeWorkshopValidator.isValidEmail('test@'), isFalse);
      expect(CreativeWorkshopValidator.isValidEmail('@example.com'), isFalse);
    });

    test('should validate URL correctly', () {
      expect(
          CreativeWorkshopValidator.isValidUrl('https://example.com'), isTrue);
      expect(
          CreativeWorkshopValidator.isValidUrl('http://example.com'), isTrue);
      expect(CreativeWorkshopValidator.isValidUrl('ftp://example.com'), isTrue);
      expect(CreativeWorkshopValidator.isValidUrl('invalid-url'), isFalse);
      expect(CreativeWorkshopValidator.isValidUrl(''), isFalse);
    });

    test('should validate phone number correctly', () {
      expect(
          CreativeWorkshopValidator.isValidPhoneNumber('13812345678'), isTrue);
      expect(
          CreativeWorkshopValidator.isValidPhoneNumber('15987654321'), isTrue);
      expect(
          CreativeWorkshopValidator.isValidPhoneNumber('18666666666'), isTrue);
      expect(
          CreativeWorkshopValidator.isValidPhoneNumber('1234567890'), isFalse);
      expect(CreativeWorkshopValidator.isValidPhoneNumber('invalid'), isFalse);
      expect(CreativeWorkshopValidator.isValidPhoneNumber(''), isFalse);
    });

    test('should validate password strength', () {
      expect(CreativeWorkshopValidator.isValidPassword('Password123!'), isTrue);
      expect(CreativeWorkshopValidator.isValidPassword('password'), isFalse);
      expect(CreativeWorkshopValidator.isValidPassword('PASSWORD'), isFalse);
      expect(CreativeWorkshopValidator.isValidPassword('123456'), isFalse);
      expect(CreativeWorkshopValidator.isValidPassword(''), isFalse);
    });

    test('should validate required fields', () {
      expect(
          CreativeWorkshopValidator.validateRequired('test', 'field'), isNull);
      expect(
          CreativeWorkshopValidator.validateRequired('', 'field'), isNotNull);
      expect(CreativeWorkshopValidator.validateRequired('   ', 'field'),
          isNotNull);
    });

    test('should validate length constraints', () {
      expect(
          CreativeWorkshopValidator.validateLength('test', 'field',
              minLength: 1, maxLength: 10),
          isNull);
      expect(
          CreativeWorkshopValidator.validateLength('test', 'field',
              minLength: 5, maxLength: 10),
          isNotNull);
      expect(
          CreativeWorkshopValidator.validateLength('test', 'field',
              minLength: 1, maxLength: 3),
          isNotNull);
      expect(
          CreativeWorkshopValidator.validateLength('', 'field',
              minLength: 0, maxLength: 10),
          isNull);
    });
  });

  group('CreativeWorkshopFormatter Tests', () {
    test('should format file size correctly', () {
      expect(CreativeWorkshopFormatter.formatFileSize(1024), equals('1.0 KB'));
      expect(
          CreativeWorkshopFormatter.formatFileSize(1048576), equals('1.0 MB'));
      expect(CreativeWorkshopFormatter.formatFileSize(1073741824),
          equals('1.0 GB'));
      expect(CreativeWorkshopFormatter.formatFileSize(500), equals('500 B'));
    });

    test('should format date correctly', () {
      final date = DateTime(2005, 12, 25, 10, 30, 45);
      expect(CreativeWorkshopFormatter.formatDate(date), equals('2005-12-25'));
      expect(
          CreativeWorkshopFormatter.formatDate(date,
              pattern: 'yyyy-MM-dd HH:mm:ss'),
          equals('2005-12-25 10:30:45'));
      expect(CreativeWorkshopFormatter.formatDate(date, pattern: 'MM/dd/yyyy'),
          equals('12/25/2005'));
    });

    test('should format currency correctly', () {
      expect(CreativeWorkshopFormatter.formatCurrency(99.99), equals('¥99.99'));
      expect(CreativeWorkshopFormatter.formatCurrency(99.99, symbol: r'$'),
          equals(r'$99.99'));
      expect(CreativeWorkshopFormatter.formatCurrency(0), equals('¥0.00'));
    });

    test('should format relative time correctly', () {
      final now = DateTime.now();
      final oneHourAgo = now.subtract(const Duration(hours: 1));
      final oneDayAgo = now.subtract(const Duration(days: 1));

      final relativeTime =
          CreativeWorkshopFormatter.formatRelativeTime(oneHourAgo);
      expect(relativeTime, contains('小时前'));

      final relativeDayTime =
          CreativeWorkshopFormatter.formatRelativeTime(oneDayAgo);
      expect(relativeDayTime, contains('天前'));
    });
  });
}
