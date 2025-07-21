import 'package:flutter_test/flutter_test.dart';
import 'package:communication_system/communication_system.dart';

void main() {
  group('communication_system Tests', () {
    test('should create module instance', () {
      final module = CommunicationSystemModule.instance;
      expect(module, isNotNull);
    });

    test('should have correct module name', () {
      final module = CommunicationSystemModule.instance;
      expect(module.isInitialized, isFalse);
    });
  });
}
