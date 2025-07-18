import 'package:flutter_test/flutter_test.dart';
import 'package:theme_system/theme_system.dart';

void main() {
  group('theme_system Tests', () {
    test('should create module instance', () {
      final module = ThemeSystemModule.instance;
      expect(module, isNotNull);
    });

    test('should have correct module name', () {
      final module = ThemeSystemModule.instance;
      expect(module.isInitialized, isFalse);
    });
  });
}
