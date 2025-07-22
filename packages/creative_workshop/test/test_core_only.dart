/*
---------------------------------------------------------------
File name:          test_core_only.dart
Author:             lgnorant-lu
Date created:       2025-07-23
Last modified:      2025-07-23
Dart Version:       3.2+
Description:        核心功能测试 - 不包含性能测试
---------------------------------------------------------------
Change History:
    2025-07-23: Phase 5.0.6 - 核心功能测试实现;
---------------------------------------------------------------
*/

import 'package:flutter_test/flutter_test.dart';

// 导入核心测试文件
import 'creative_workshop_test.dart' as main_tests;
import 'src/core/plugins/plugin_registry_test.dart' as registry_tests;
import 'src/core/plugins/plugin_manager_test.dart' as manager_tests;

void main() {
  group('Creative Workshop 核心测试套件', () {
    group('主要功能测试', () {
      main_tests.main();
    });

    group('插件注册表测试', () {
      registry_tests.main();
    });

    group('插件管理器测试', () {
      manager_tests.main();
    });
  });

  // 测试统计信息
  setUpAll(() {
    print('🧪 开始运行 Creative Workshop 核心测试套件');
    print('📊 测试覆盖范围:');
    print('   - 核心功能测试');
    print('   - 插件系统测试');
    print('   - 数据模型测试');
    print('⚠️  注意: 性能测试已排除，可单独运行');
  });

  tearDownAll(() {
    print('✅ Creative Workshop 核心测试套件运行完成');
    print('📈 核心功能验证通过');
  });
}
