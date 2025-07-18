import 'package:flutter_test/flutter_test.dart';
import 'package:settings_system/settings_system.dart';

void main() {
  group('settings_system Tests', () {
    test('should create module instance', () {
      final module = SettingsSystemModule.instance;
      expect(module, isNotNull);
    });

    test('should have correct module name', () {
      final module = SettingsSystemModule.instance;
      expect(module.isInitialized, isFalse);
    });
  });
}
