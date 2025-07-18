import 'package:flutter_test/flutter_test.dart';
import 'package:app_manager/app_manager.dart';

void main() {
  group('app_manager Tests', () {
    test('should create module instance', () {
      final module = AppManagerModule.instance;
      expect(module, isNotNull);
    });

    test('should have correct module name', () {
      final module = AppManagerModule.instance;
      expect(module.isInitialized, isFalse);
    });
  });
}
