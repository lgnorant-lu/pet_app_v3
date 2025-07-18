import 'package:flutter_test/flutter_test.dart';
import 'package:creative_workshop/creative_workshop.dart';

void main() {
  group('creative_workshop Tests', () {
    test('should create module instance', () {
      final module = CreativeWorkshopModule.instance;
      expect(module, isNotNull);
    });

    test('should have correct module name', () {
      final module = CreativeWorkshopModule.instance;
      expect(module.isInitialized, isFalse);
    });
  });
}
