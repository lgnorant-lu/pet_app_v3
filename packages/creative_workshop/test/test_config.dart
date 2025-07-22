/*
---------------------------------------------------------------
File name:          test_config.dart
Author:             lgnorant-lu
Date created:       2025-07-23
Last modified:      2025-07-23
Dart Version:       3.2+
Description:        测试配置文件
---------------------------------------------------------------
Change History:
    2025-07-23: Phase 5.0.6 - 测试配置实现;
---------------------------------------------------------------
*/

/// 测试配置类
class TestConfig {
  /// 测试超时时间（秒）
  static const int testTimeout = 30;
  
  /// 性能测试超时时间（秒）
  static const int performanceTestTimeout = 120;
  
  /// 是否启用详细日志
  static const bool verboseLogging = true;
  
  /// 是否运行性能测试
  static const bool runPerformanceTests = true;
  
  /// 是否运行集成测试
  static const bool runIntegrationTests = false; // 暂时禁用，因为UI组件还未完成
  
  /// 测试数据目录
  static const String testDataDir = 'test/fixtures';
  
  /// 临时文件目录
  static const String tempDir = 'test/temp';
  
  /// 测试插件ID前缀
  static const String testPluginPrefix = 'test_plugin_';
  
  /// 性能测试插件数量
  static const int performanceTestPluginCount = 100;
  
  /// 并发测试数量
  static const int concurrentTestCount = 10;
  
  /// 内存测试循环次数
  static const int memoryTestCycles = 10;
  
  /// 测试覆盖率最低要求（百分比）
  static const double minCoveragePercent = 80.0;
}

/// 测试工具类
class TestUtils {
  /// 生成测试插件ID
  static String generateTestPluginId(String suffix) {
    return '${TestConfig.testPluginPrefix}$suffix';
  }
  
  /// 生成随机字符串
  static String generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(length, (index) => 
      chars[(random + index) % chars.length]).join();
  }
  
  /// 创建测试用的插件元数据
  static Map<String, dynamic> createTestPluginMetadata({
    required String id,
    String? name,
    String? version,
    String? description,
    String? author,
    String? category,
    List<String>? keywords,
  }) {
    return {
      'id': id,
      'name': name ?? 'Test Plugin $id',
      'version': version ?? '1.0.0',
      'description': description ?? 'Test plugin for $id',
      'author': author ?? 'Test Author',
      'category': category ?? 'test',
      'keywords': keywords ?? ['test', 'plugin'],
    };
  }
  
  /// 等待异步操作完成
  static Future<void> waitForAsync([Duration? duration]) async {
    await Future.delayed(duration ?? const Duration(milliseconds: 100));
  }
  
  /// 重试操作
  static Future<T> retry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration delay = const Duration(milliseconds: 500),
  }) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        return await operation();
      } catch (e) {
        if (i == maxRetries - 1) rethrow;
        await Future.delayed(delay);
      }
    }
    throw StateError('Retry failed');
  }
  
  /// 测试性能
  static Future<Duration> measurePerformance(Future<void> Function() operation) async {
    final stopwatch = Stopwatch()..start();
    await operation();
    stopwatch.stop();
    return Duration(milliseconds: stopwatch.elapsedMilliseconds);
  }
  
  /// 验证性能指标
  static void validatePerformance(Duration actual, Duration expected, {
    double tolerancePercent = 20.0,
  }) {
    final tolerance = expected.inMilliseconds * (tolerancePercent / 100);
    final maxAllowed = expected.inMilliseconds + tolerance;
    
    if (actual.inMilliseconds > maxAllowed) {
      throw AssertionError(
        'Performance test failed: ${actual.inMilliseconds}ms > ${maxAllowed}ms'
      );
    }
  }
}

/// 测试数据生成器
class TestDataGenerator {
  /// 生成测试插件列表
  static List<Map<String, dynamic>> generateTestPlugins(int count) {
    return List.generate(count, (index) {
      return TestUtils.createTestPluginMetadata(
        id: TestUtils.generateTestPluginId('generated_$index'),
        name: 'Generated Plugin $index',
        category: _getRandomCategory(index),
        keywords: _getRandomKeywords(index),
      );
    });
  }
  
  /// 生成大量测试数据
  static Map<String, dynamic> generateLargeTestData() {
    return {
      'plugins': generateTestPlugins(TestConfig.performanceTestPluginCount),
      'categories': ['tool', 'game', 'utility', 'theme', 'other'],
      'permissions': ['fileSystem', 'network', 'notifications', 'camera'],
      'dependencies': _generateTestDependencies(),
    };
  }
  
  static String _getRandomCategory(int index) {
    const categories = ['tool', 'game', 'utility', 'theme', 'other'];
    return categories[index % categories.length];
  }
  
  static List<String> _getRandomKeywords(int index) {
    const keywords = [
      ['test', 'plugin'],
      ['tool', 'utility'],
      ['game', 'entertainment'],
      ['theme', 'ui'],
      ['other', 'misc'],
    ];
    return keywords[index % keywords.length];
  }
  
  static List<Map<String, dynamic>> _generateTestDependencies() {
    return [
      {'pluginId': 'base_plugin', 'version': '1.0.0', 'required': true},
      {'pluginId': 'optional_plugin', 'version': '2.0.0', 'required': false},
      {'pluginId': 'utility_plugin', 'version': '1.5.0', 'required': true},
    ];
  }
}

/// 测试断言扩展
class TestAssertions {
  /// 断言操作在指定时间内完成
  static Future<void> assertCompletesWithin(
    Future<void> operation,
    Duration timeout, {
    String? message,
  }) async {
    try {
      await operation.timeout(timeout);
    } catch (e) {
      throw AssertionError(
        message ?? 'Operation did not complete within ${timeout.inMilliseconds}ms'
      );
    }
  }
  
  /// 断言性能满足要求
  static void assertPerformance(
    Duration actual,
    Duration expected, {
    double tolerancePercent = 20.0,
    String? message,
  }) {
    TestUtils.validatePerformance(actual, expected, tolerancePercent: tolerancePercent);
  }
  
  /// 断言内存使用在合理范围内
  static void assertMemoryUsage(int actualBytes, int maxBytes, {
    String? message,
  }) {
    if (actualBytes > maxBytes) {
      throw AssertionError(
        message ?? 'Memory usage $actualBytes bytes exceeds limit $maxBytes bytes'
      );
    }
  }
}
