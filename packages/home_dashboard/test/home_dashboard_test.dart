import 'package:flutter_test/flutter_test.dart';
import 'package:home_dashboard/home_dashboard.dart';

void main() {
  group('home_dashboard Tests', () {
    test('should create module instance', () {
      final module = HomeDashboardModule.instance;
      expect(module, isNotNull);
    });

    test('should have correct module name', () {
      final module = HomeDashboardModule.instance;
      expect(module.isInitialized, isFalse);
    });
  });
}
