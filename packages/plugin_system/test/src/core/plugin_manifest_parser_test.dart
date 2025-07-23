/*
---------------------------------------------------------------
File name:          plugin_manifest_parser_test.dart
Author:             lgnorant-lu
Date created:       2025-07-23
Last modified:      2025-07-23
Dart Version:       3.2+
Description:        插件清单解析器测试 - 集成Creative Workshop测试
---------------------------------------------------------------
Change History:
    2025-07-23: Task 1.1.3 - 统一插件清单解析测试;
---------------------------------------------------------------
*/

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:plugin_system/src/core/plugin_manifest_parser.dart';

void main() {
  group('PluginManifestParser Tests', () {
    late PluginManifestParser parser;

    setUp(() {
      parser = PluginManifestParser.instance;
    });

    group('基础解析测试', () {
      test('应该能够解析有效的最小清单', () {
        const String yamlContent = '''
id: "test_plugin"
name: "测试插件"
version: "1.0.0"
description: "这是一个测试插件"
author: "测试作者"
category: "tool"
main: "lib/main.dart"
''';

        final PluginManifestParseResult result =
            parser.parseFromString(yamlContent);
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
        const String yamlContent = '''
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
  name: "开发者"
  email: "dev@example.com"
  website: "https://dev.example.com"

support:
  email: "support@example.com"
  website: "https://support.example.com"
  documentation: "https://docs.example.com"
  issues: "https://github.com/user/plugin/issues"

changelog: "CHANGELOG.md"
''';

        final PluginManifestParseResult result =
            parser.parseFromString(yamlContent);
        expect(result.success, isTrue);
        expect(result.manifest, isNotNull);

        final manifest = result.manifest!;
        expect(manifest.id, 'full_test_plugin');
        expect(manifest.name, '完整测试插件');
        expect(manifest.version, '2.1.0');
        expect(manifest.homepage, 'https://example.com');
        expect(manifest.repository, 'https://github.com/user/plugin');
        expect(manifest.license, 'MIT');
        expect(manifest.keywords, contains('测试'));
        expect(manifest.keywords, contains('UI'));
        expect(manifest.icon, 'assets/icon.png');
        expect(manifest.screenshots, hasLength(2));
        expect(manifest.minAppVersion, '5.0.0');
        expect(manifest.maxAppVersion, '6.0.0');
        expect(manifest.platforms, contains('android'));
        expect(manifest.platforms, contains('ios'));
        expect(manifest.platforms, contains('web'));
        expect(manifest.permissions, contains('fileSystem'));
        expect(manifest.permissions, contains('network'));
        expect(manifest.dependencies, hasLength(1));
        expect(manifest.dependencies.first.id, 'base_utils');
        expect(manifest.dependencies.first.version, '^1.0.0');
        expect(manifest.dependencies.first.required, isTrue);
        expect(manifest.assets, contains('assets/'));
        expect(manifest.assets, contains('locales/'));
        expect(manifest.config, isNotNull);
        expect(manifest.config!.hotReload, isTrue);
        expect(manifest.config!.autoUpdate, isFalse);
        expect(manifest.config!.background, isTrue);
        expect(manifest.config!.maxMemory, 256);
        expect(manifest.config!.networkTimeout, 45);
        expect(manifest.locales, contains('zh_CN'));
        expect(manifest.locales, contains('en_US'));
        expect(manifest.defaultLocale, 'zh_CN');
        expect(manifest.developer, isNotNull);
        expect(manifest.developer!.name, '开发者');
        expect(manifest.developer!.email, 'dev@example.com');
        expect(manifest.developer!.website, 'https://dev.example.com');
        expect(manifest.support, isNotNull);
        expect(manifest.support!.email, 'support@example.com');
        expect(manifest.support!.website, 'https://support.example.com');
        expect(manifest.support!.documentation, 'https://docs.example.com');
        expect(
          manifest.support!.issues,
          'https://github.com/user/plugin/issues',
        );
        expect(manifest.changelog, 'CHANGELOG.md');
      });

      test('应该能够从字节数组解析', () {
        const String yamlContent = '''
id: "bytes_test_plugin"
name: "字节测试插件"
version: "1.0.0"
description: "从字节数组解析的测试插件"
author: "字节测试作者"
category: "tool"
main: "lib/main.dart"
''';

        final Uint8List bytes = Uint8List.fromList(utf8.encode(yamlContent));
        final PluginManifestParseResult result = parser.parseFromBytes(bytes);

        expect(result.success, isTrue);
        expect(result.manifest, isNotNull);
        expect(result.manifest!.id, 'bytes_test_plugin');
        expect(result.manifest!.name, '字节测试插件');
      });
    });

    group('验证测试', () {
      test('缺少必需字段应该失败', () {
        const String yamlContent = '''
id: "incomplete_plugin"
name: "不完整插件"
# 缺少 version, description, author, category, main
''';

        final PluginManifestParseResult result =
            parser.parseFromString(yamlContent);
        expect(result.success, isFalse);
        expect(result.error, isNotNull);
        expect(result.error, contains('验证失败'));
      });

      test('无效的插件ID应该失败', () {
        const String yamlContent = '''
id: "invalid-plugin-id!"  # 包含非法字符
name: "无效ID插件"
version: "1.0.0"
description: "插件ID包含非法字符"
author: "测试作者"
category: "tool"
main: "lib/main.dart"
''';

        final PluginManifestParseResult result =
            parser.parseFromString(yamlContent);
        expect(result.success, isFalse);
        expect(result.error, contains('ID格式无效'));
      });

      test('无效的版本格式应该失败', () {
        const String yamlContent = '''
id: "invalid_version_plugin"
name: "无效版本插件"
version: "invalid.version"  # 无效版本格式
description: "版本格式无效的插件"
author: "测试作者"
category: "tool"
main: "lib/main.dart"
''';

        final PluginManifestParseResult result =
            parser.parseFromString(yamlContent);
        expect(result.success, isFalse);
        expect(result.error, contains('版本格式无效'));
      });

      test('空内容应该失败', () {
        const String yamlContent = '';

        final PluginManifestParseResult result =
            parser.parseFromString(yamlContent);
        expect(result.success, isFalse);
        expect(result.error, isNotNull);
      });

      test('无效YAML格式应该失败', () {
        const String yamlContent = '''
id: "test_plugin"
name: "测试插件
# 缺少引号结束
''';

        final PluginManifestParseResult result =
            parser.parseFromString(yamlContent);
        expect(result.success, isFalse);
        expect(result.error, contains('解析 YAML 失败'));
      });

      test('空字节数组应该失败', () {
        final Uint8List emptyBytes = Uint8List(0);
        final PluginManifestParseResult result =
            parser.parseFromBytes(emptyBytes);

        expect(result.success, isFalse);
        expect(result.error, contains('文件内容为空'));
      });
    });

    group('YAML格式验证测试', () {
      test('有效YAML格式应该返回true', () {
        const String validYaml = '''
id: "test_plugin"
name: "测试插件"
version: "1.0.0"
''';

        final bool isValid = parser.validateYamlFormat(validYaml);
        expect(isValid, isTrue);
      });

      test('无效YAML格式应该返回false', () {
        const String invalidYaml = '''
id: "test_plugin"
name: "测试插件
# 缺少引号结束
''';

        final bool isValid = parser.validateYamlFormat(invalidYaml);
        expect(isValid, isFalse);
      });

      test('非对象根节点应该返回false', () {
        const String invalidYaml = '''
- item1
- item2
''';

        final bool isValid = parser.validateYamlFormat(invalidYaml);
        expect(isValid, isFalse);
      });
    });

    group('默认清单生成测试', () {
      test('应该能够生成默认清单', () {
        final String defaultManifest = parser.generateDefaultManifest(
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
        final PluginManifestParseResult parseResult =
            parser.parseFromString(defaultManifest);
        expect(parseResult.success, isTrue);
      });

      test('默认参数应该生成有效清单', () {
        final String defaultManifest = parser.generateDefaultManifest(
          pluginId: 'default_plugin',
          pluginName: '默认插件',
        );

        final PluginManifestParseResult parseResult =
            parser.parseFromString(defaultManifest);
        expect(parseResult.success, isTrue);
        expect(parseResult.manifest!.id, 'default_plugin');
        expect(parseResult.manifest!.name, '默认插件');
        expect(parseResult.manifest!.version, '1.0.0');
        expect(parseResult.manifest!.category, 'tool');
      });
    });

    group('警告检查测试', () {
      test('缺少推荐字段应该产生警告', () {
        const String yamlContent = '''
id: "minimal_plugin"
name: "最小插件"
version: "1.0.0"
description: "最小插件描述"
author: "最小作者"
category: "tool"
main: "lib/main.dart"
''';

        final PluginManifestParseResult result =
            parser.parseFromString(yamlContent);
        expect(result.success, isTrue);
        expect(result.warnings, isNotEmpty);
        expect(result.warnings.any((String w) => w.contains('主页')), isTrue);
        expect(result.warnings.any((String w) => w.contains('许可证')), isTrue);
        expect(result.warnings.any((String w) => w.contains('关键词')), isTrue);
      });

      test('完整插件应该产生较少警告', () {
        const String yamlContent = '''
id: "complete_plugin"
name: "完整插件"
version: "1.0.0"
description: "完整插件描述"
author: "完整作者"
category: "tool"
main: "lib/main.dart"
homepage: "https://example.com"
license: "MIT"
keywords:
  - "测试"
icon: "assets/icon.png"
platforms:
  - "android"
min_app_version: "5.0.0"
''';

        final PluginManifestParseResult result =
            parser.parseFromString(yamlContent);
        expect(result.success, isTrue);
        expect(result.warnings.length, lessThan(3)); // 应该有较少警告
      });
    });
  });
}
