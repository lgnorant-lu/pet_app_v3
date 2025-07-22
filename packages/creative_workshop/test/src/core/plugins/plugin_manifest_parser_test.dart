/*
---------------------------------------------------------------
File name:          plugin_manifest_parser_test.dart
Author:             lgnorant-lu
Date created:       2025-07-23
Last modified:      2025-07-23
Dart Version:       3.2+
Description:        插件清单解析器测试
---------------------------------------------------------------
Change History:
    2025-07-23: Phase 5.0.6.2 - 插件清单解析器测试实现;
---------------------------------------------------------------
*/

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:creative_workshop/src/core/plugins/plugin_manifest_parser.dart';
import 'package:creative_workshop/src/core/plugins/plugin_manifest.dart';

void main() {
  group('PluginManifestParser Tests', () {
    late PluginManifestParser parser;

    setUp(() {
      parser = PluginManifestParser.instance;
    });

    group('基础解析测试', () {
      test('应该能够解析有效的最小清单', () {
        const yamlContent = '''
id: "test_plugin"
name: "测试插件"
version: "1.0.0"
description: "这是一个测试插件"
author: "测试作者"
category: "tool"
main: "lib/main.dart"
''';

        final result = parser.parseFromString(yamlContent);
        expect(result.success, isTrue);
        expect(result.manifest, isNotNull);
        expect(result.error, isNull);

        final manifest = result.manifest!;
        expect(manifest.id, 'test_plugin');
        expect(manifest.name, '测试插件');
        expect(manifest.version, '1.0.0');
        expect(manifest.description, '这是一个测试插件');
        expect(manifest.author, '测试作者');
        expect(manifest.category, 'tool');
        expect(manifest.main, 'lib/main.dart');
      });

      test('应该能够解析完整的清单', () {
        const yamlContent = '''
id: "full_test_plugin"
name: "完整测试插件"
version: "2.1.0"
description: "这是一个功能完整的测试插件"
author: "完整测试作者"
category: "ui"
main: "lib/main.dart"

homepage: "https://example.com"
repository: "https://github.com/user/plugin"
license: "MIT"
keywords:
  - "测试"
  - "UI"
icon: "assets/icon.png"
screenshots:
  - "assets/screenshot1.png"
  - "assets/screenshot2.png"

min_app_version: "5.0.0"
max_app_version: "6.0.0"
platforms:
  - "android"
  - "ios"
  - "web"

permissions:
  - "fileSystem"
  - "network"

dependencies:
  - id: "base_utils"
    version: "^1.0.0"
    required: true
    description: "基础工具库"

assets:
  - "assets/"
  - "locales/"

config:
  hot_reload: true
  auto_update: false
  background: true
  max_memory: 256
  network_timeout: 45

locales:
  - "zh_CN"
  - "en_US"
default_locale: "zh_CN"

developer:
  name: "开发者名称"
  email: "dev@example.com"
  website: "https://dev.example.com"

support:
  email: "support@example.com"
  website: "https://support.example.com"
  documentation: "https://docs.example.com"

changelog: "CHANGELOG.md"
''';

        final result = parser.parseFromString(yamlContent);
        expect(result.success, isTrue);
        expect(result.manifest, isNotNull);

        final manifest = result.manifest!;
        expect(manifest.id, 'full_test_plugin');
        expect(manifest.homepage, 'https://example.com');
        expect(manifest.keywords, ['测试', 'UI']);
        expect(manifest.platforms, ['android', 'ios', 'web']);
        expect(manifest.permissions, ['fileSystem', 'network']);
        expect(manifest.dependencies.length, 1);
        expect(manifest.dependencies.first.id, 'base_utils');
        expect(manifest.config, isNotNull);
        expect(manifest.config!.maxMemory, 256);
        expect(manifest.developer, isNotNull);
        expect(manifest.developer!.name, '开发者名称');
        expect(manifest.support, isNotNull);
        expect(manifest.support!.email, 'support@example.com');
      });

      test('应该能够从字节数组解析', () {
        const yamlContent = '''
id: "bytes_test_plugin"
name: "字节测试插件"
version: "1.0.0"
description: "从字节数组解析的测试插件"
author: "字节测试作者"
category: "tool"
main: "lib/main.dart"
''';

        final bytes = Uint8List.fromList(utf8.encode(yamlContent));
        final result = parser.parseFromBytes(bytes);

        if (!result.success) {
          print('解析失败: ${result.error}');
        }

        expect(result.success, isTrue);
        expect(result.manifest, isNotNull);
        expect(result.manifest!.id, 'bytes_test_plugin');
      });
    });

    group('验证测试', () {
      test('缺少必需字段应该失败', () {
        const yamlContent = '''
id: "incomplete_plugin"
name: "不完整插件"
# 缺少 version, description, author, category, main
''';

        final result = parser.parseFromString(yamlContent);
        expect(result.success, isFalse);
        expect(result.error, isNotNull);
        expect(result.error, contains('验证失败'));
      });

      test('无效的插件ID应该失败', () {
        const yamlContent = '''
id: "invalid-plugin-id!"  # 包含非法字符
name: "无效ID插件"
version: "1.0.0"
description: "插件ID包含非法字符"
author: "测试作者"
category: "tool"
main: "lib/main.dart"
''';

        final result = parser.parseFromString(yamlContent);
        expect(result.success, isFalse);
        expect(result.error, contains('ID格式无效'));
      });

      test('无效的版本号应该失败', () {
        const yamlContent = '''
id: "invalid_version_plugin"
name: "无效版本插件"
version: "invalid.version"  # 无效版本格式
description: "版本号格式无效"
author: "测试作者"
category: "tool"
main: "lib/main.dart"
''';

        final result = parser.parseFromString(yamlContent);
        expect(result.success, isFalse);
        expect(result.error, contains('版本号格式无效'));
      });

      test('无效的类别应该失败', () {
        const yamlContent = '''
id: "invalid_category_plugin"
name: "无效类别插件"
version: "1.0.0"
description: "插件类别无效"
author: "测试作者"
category: "invalid_category"  # 无效类别
main: "lib/main.dart"
''';

        final result = parser.parseFromString(yamlContent);
        expect(result.success, isFalse);
        expect(result.error, contains('插件类别无效'));
      });

      test('无效的权限应该失败', () {
        const yamlContent = '''
id: "invalid_permission_plugin"
name: "无效权限插件"
version: "1.0.0"
description: "权限无效"
author: "测试作者"
category: "tool"
main: "lib/main.dart"
permissions:
  - "invalidPermission"  # 无效权限
''';

        final result = parser.parseFromString(yamlContent);
        expect(result.success, isFalse);
        expect(result.error, contains('权限'));
        expect(result.error, contains('无效'));
      });
    });

    group('警告检查测试', () {
      test('缺少推荐字段应该产生警告', () {
        const yamlContent = '''
id: "warning_test_plugin"
name: "警告测试插件"
version: "1.0.0"
description: "用于测试警告的插件"
author: "警告测试作者"
category: "tool"
main: "lib/main.dart"
# 缺少 homepage, license, keywords 等推荐字段
''';

        final result = parser.parseFromString(yamlContent);
        expect(result.success, isTrue);
        expect(result.warnings.isNotEmpty, isTrue);
        expect(result.warnings.any((w) => w.contains('主页')), isTrue);
        expect(result.warnings.any((w) => w.contains('许可证')), isTrue);
        expect(result.warnings.any((w) => w.contains('关键词')), isTrue);
      });

      test('高内存使用应该产生警告', () {
        const yamlContent = '''
id: "high_memory_plugin"
name: "高内存插件"
version: "1.0.0"
description: "使用大量内存的插件"
author: "内存测试作者"
category: "tool"
main: "lib/main.dart"
config:
  max_memory: 1024  # 超过推荐值
''';

        final result = parser.parseFromString(yamlContent);
        expect(result.success, isTrue);
        expect(result.warnings.any((w) => w.contains('内存')), isTrue);
      });
    });

    group('错误处理测试', () {
      test('无效的YAML格式应该失败', () {
        const invalidYaml = '''
id: "test_plugin"
name: "测试插件
# 缺少引号结束
''';

        final result = parser.parseFromString(invalidYaml);
        expect(result.success, isFalse);
        expect(result.error, contains('解析 YAML 失败'));
      });

      test('非对象根节点应该失败', () {
        const invalidYaml = '''
- "这是一个数组，不是对象"
- "应该失败"
''';

        final result = parser.parseFromString(invalidYaml);
        expect(result.success, isFalse);
        expect(result.error, contains('根节点必须是对象'));
      });

      test('空内容应该失败', () {
        const emptyYaml = '';

        final result = parser.parseFromString(emptyYaml);
        expect(result.success, isFalse);
      });
    });

    group('工具方法测试', () {
      test('应该能够验证YAML格式', () {
        const validYaml = '''
id: "test"
name: "测试"
''';
        expect(parser.validateYamlFormat(validYaml), isTrue);

        const invalidYaml = '''
id: "test"
name: "测试
''';
        expect(parser.validateYamlFormat(invalidYaml), isFalse);
      });

      test('应该能够生成默认清单', () {
        final defaultManifest = parser.generateDefaultManifest(
          pluginId: 'my_plugin',
          pluginName: '我的插件',
          version: '2.0.0',
          description: '自定义描述',
          author: '自定义作者',
          category: 'ui',
        );

        expect(defaultManifest, contains('id: "my_plugin"'));
        expect(defaultManifest, contains('name: "我的插件"'));
        expect(defaultManifest, contains('version: "2.0.0"'));
        expect(defaultManifest, contains('description: "自定义描述"'));
        expect(defaultManifest, contains('author: "自定义作者"'));
        expect(defaultManifest, contains('category: "ui"'));

        // 验证生成的清单可以被解析
        final parseResult = parser.parseFromString(defaultManifest);
        expect(parseResult.success, isTrue);
      });
    });
  });
}
