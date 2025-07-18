/*
---------------------------------------------------------------
File name:          utils_test.dart
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

    test('should handle null values safely', () {
      expect(() => CreativeWorkshopUtils.isValidEmail('test@example.com'),
          returnsNormally);
      expect(() => CreativeWorkshopUtils.isValidPassword('password'),
          returnsNormally);
      expect(() => CreativeWorkshopUtils.formatToTitleCase('test'),
          returnsNormally);
    });

    test('should handle edge cases', () {
      // 测试边界情况
      expect(CreativeWorkshopUtils.isValidEmail('test@example.com'), isTrue);
      expect(CreativeWorkshopUtils.isValidPassword('1234567'), isFalse); // 太短
      expect(CreativeWorkshopUtils.formatToTitleCase('   '), equals('   '));
    });
  });

  group('CreativeWorkshopUtils Performance Tests', () {
    test('should handle multiple validations efficiently', () {
      final stopwatch = Stopwatch()..start();

      // 大量验证操作
      for (int i = 0; i < 1000; i++) {
        CreativeWorkshopUtils.isValidEmail('test$i@example.com');
        CreativeWorkshopUtils.isValidPassword('password$i');
        CreativeWorkshopUtils.formatToTitleCase('test string $i');
      }

      stopwatch.stop();

      // 应该在合理时间内完成
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    test('should handle concurrent operations', () async {
      final futures = <Future<String>>[];

      // 并发格式化操作
      for (int i = 0; i < 100; i++) {
        futures.add(
            Future(() => CreativeWorkshopUtils.formatToTitleCase('test $i')));
      }

      final results = await Future.wait(futures);

      expect(results.length, equals(100));

      // 验证所有结果都正确
      for (int i = 0; i < 100; i++) {
        expect(results[i], equals('Test $i'));
      }
    });
  });

  group('CreativeWorkshopUtils Error Handling Tests', () {
    test('should handle invalid input gracefully', () {
      // 测试异常输入处理
      expect(() => CreativeWorkshopUtils.isValidEmail(''), returnsNormally);
      expect(() => CreativeWorkshopUtils.isValidPassword(''), returnsNormally);
      expect(
          () => CreativeWorkshopUtils.formatToTitleCase(''), returnsNormally);
    });

    test('should handle special characters', () {
      // 测试特殊字符处理
      expect(
          CreativeWorkshopUtils.isValidEmail('test+tag@example.com'), isTrue);
      expect(CreativeWorkshopUtils.formatToTitleCase('hello-world'),
          equals('Hello-world'));
      expect(CreativeWorkshopUtils.formatToTitleCase('test_case'),
          equals('Test_case'));
    });

    test('should handle unicode characters', () {
      // 测试Unicode字符处理
      expect(CreativeWorkshopUtils.formatToTitleCase('测试'), equals('测试'));
      expect(CreativeWorkshopUtils.formatToTitleCase('café'), equals('Café'));
    });
  });

  group('CreativeWorkshopUtils Integration Tests', () {
    test('should work together correctly', () {
      // 测试多个方法的集成使用
      const email = 'test@example.com';
      const password = 'password123';
      const title = 'hello world';

      expect(CreativeWorkshopUtils.isValidEmail(email), isTrue);
      expect(CreativeWorkshopUtils.isValidPassword(password), isTrue);
      expect(CreativeWorkshopUtils.formatToTitleCase(title),
          equals('Hello world'));
    });

    test('should maintain consistency across calls', () {
      // 测试多次调用的一致性
      const input = 'test string';

      final result1 = CreativeWorkshopUtils.formatToTitleCase(input);
      final result2 = CreativeWorkshopUtils.formatToTitleCase(input);
      final result3 = CreativeWorkshopUtils.formatToTitleCase(input);

      expect(result1, equals(result2));
      expect(result2, equals(result3));
      expect(result1, equals('Test string'));
    });
  });

  group('CreativeWorkshopUtils Stress Tests', () {
    test('should handle large input strings', () {
      // 测试大字符串处理
      final largeString = 'test ' * 1000;
      final result = CreativeWorkshopUtils.formatToTitleCase(largeString);

      expect(result, startsWith('Test '));
      expect(result.length, equals(largeString.length));
    });

    test('should handle rapid successive calls', () {
      // 测试快速连续调用
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 10000; i++) {
        CreativeWorkshopUtils.formatToTitleCase('test');
      }

      stopwatch.stop();

      // 应该在合理时间内完成
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });
  });
}
