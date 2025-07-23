/*
---------------------------------------------------------------
File name:          classification_system_test.dart
Author:             lgnorant-lu
Date created:       2025-07-23
Last modified:      2025-07-23
Dart Version:       3.2+
Description:        插件分类和标签系统集成测试
---------------------------------------------------------------
Change History:
    2025-07-23: Task 2.3 - 创建分类和标签系统集成测试;
---------------------------------------------------------------
*/

import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_system/plugin_system.dart';

void main() {
  group('插件分类和标签系统集成测试', () {
    late PluginCategoryManager categoryManager;
    late PluginTagManager tagManager;

    setUp(() async {
      categoryManager = PluginCategoryManager.instance;
      tagManager = PluginTagManager.instance;

      await categoryManager.initialize();
      await tagManager.initialize();
    });

    tearDown(() {
      categoryManager.clearCache();
      tagManager.clearCache();
    });

    group('分类管理测试', () {
      test('应该正确初始化系统分类', () {
        final categories = categoryManager.getAllCategories();
        expect(categories.isNotEmpty, isTrue);

        // 检查根分类
        final rootCategories = categoryManager.getRootCategories();
        expect(rootCategories.length, greaterThan(3));

        // 检查是否包含预期的分类
        final categoryNames = categories.map((c) => c.name).toList();
        expect(categoryNames, contains('development'));
        expect(categoryNames, contains('productivity'));
        expect(categoryNames, contains('entertainment'));
      });

      test('应该正确获取分类层次结构', () {
        final developmentSubCategories =
            categoryManager.getSubCategories('development');
        expect(developmentSubCategories.isNotEmpty, isTrue);

        // 检查子分类
        final subCategoryNames =
            developmentSubCategories.map((c) => c.name).toList();
        expect(subCategoryNames, contains('ide'));
        expect(subCategoryNames, contains('debugging'));
        expect(subCategoryNames, contains('testing'));
      });

      test('应该正确获取分类路径', () {
        final path = categoryManager.getCategoryPath('development.ide');
        expect(path.length, equals(2));
        expect(path[0].name, equals('development'));
        expect(path[1].name, equals('ide'));
      });

      test('应该正确搜索分类', () {
        final results = categoryManager.searchCategories('dev');
        expect(results.isNotEmpty, isTrue);

        final hasDevCategory = results.any((c) => c.name.contains('dev'));
        expect(hasDevCategory, isTrue);
      });

      test('应该正确建议分类', () async {
        final testPlugin = PluginStoreEntry(
          id: 'test-plugin',
          name: 'Code Editor Plugin',
          version: '1.0.0',
          description: 'A powerful code editor with debugging features',
          author: 'Test Author',
          storeId: 'test-store',
          tags: ['editor', 'code', 'debug'],
        );

        final suggestions = await categoryManager.suggestCategories(testPlugin);
        expect(suggestions.isNotEmpty, isTrue);

        // 应该建议开发相关的分类
        final hasDevelopmentSuggestion = suggestions.any((s) =>
            s.category.name.contains('development') ||
            s.category.name.contains('ide'));
        expect(hasDevelopmentSuggestion, isTrue);
      });
    });

    group('标签管理测试', () {
      test('应该正确初始化系统标签', () {
        final tags = tagManager.getAllTags();
        expect(tags.isNotEmpty, isTrue);

        // 检查是否包含预期的标签
        final tagNames = tags.map((t) => t.name).toList();
        expect(tagNames, contains('development'));
        expect(tagNames, contains('debugging'));
        expect(tagNames, contains('testing'));
        expect(tagNames, contains('productivity'));
      });

      test('应该正确按分类获取标签', () {
        final developmentTags = tagManager.getTagsByCategory('development');
        expect(developmentTags.isNotEmpty, isTrue);

        final tagNames = developmentTags.map((t) => t.name).toList();
        expect(tagNames, contains('development'));
        expect(tagNames, contains('debugging'));
      });

      test('应该正确搜索标签', () {
        final results = tagManager.searchTags('dev');
        expect(results.isNotEmpty, isTrue);

        final hasDevTag = results.any((t) => t.name.contains('dev'));
        expect(hasDevTag, isTrue);
      });

      test('应该正确建议标签', () async {
        final testPlugin = PluginStoreEntry(
          id: 'test-plugin',
          name: 'Game Development Tool',
          version: '1.0.0',
          description: 'A tool for game development and testing',
          author: 'Test Author',
          storeId: 'test-store',
          category: 'development',
          tags: ['game'],
        );

        final suggestions = await tagManager.suggestTags(testPlugin);
        expect(suggestions.isNotEmpty, isTrue);

        // 应该建议相关的标签
        final tagNames = suggestions.map((s) => s.tag.name).toList();
        expect(
            tagNames,
            anyOf([
              contains('development'),
              contains('game'),
              contains('testing'),
              contains('entertainment'),
            ]));
      });

      test('应该正确获取相关标签', () {
        final relatedTags = tagManager.getRelatedTags('development');
        expect(relatedTags.isNotEmpty, isTrue);

        final tagNames = relatedTags.map((t) => t.name).toList();
        expect(
            tagNames,
            anyOf([
              contains('debugging'),
              contains('testing'),
              contains('api'),
              contains('sdk'),
            ]));
      });

      test('应该正确自动生成标签', () {
        final text = 'This is a REST API testing framework for developers';
        final generatedTags = tagManager.generateTagsFromText(text);

        expect(generatedTags.isNotEmpty, isTrue);
        expect(
            generatedTags,
            anyOf([
              contains('api'),
              contains('test'),
              contains('framework'),
              contains('rest'),
            ]));
      });
    });

    group('分类和标签集成测试', () {
      test('应该正确更新分类统计', () {
        final testPlugins = [
          PluginStoreEntry(
            id: 'plugin1',
            name: 'Test Plugin 1',
            version: '1.0.0',
            description: 'Test plugin',
            author: 'Test Author',
            storeId: 'test-store',
            category: 'development',
            rating: 4.5,
            downloadCount: 1000,
          ),
          PluginStoreEntry(
            id: 'plugin2',
            name: 'Test Plugin 2',
            version: '1.0.0',
            description: 'Another test plugin',
            author: 'Test Author',
            storeId: 'test-store',
            category: 'development',
            rating: 4.0,
            downloadCount: 500,
          ),
        ];

        categoryManager.updateCategoryStatistics('development', testPlugins);

        final stats = categoryManager.getCategoryStatistics('development');
        expect(stats, isNotNull);
        expect(stats!.pluginCount, equals(2));
        expect(stats.downloadCount, equals(1500));
        expect(stats.averageRating, equals(4.25));
      });

      test('应该正确更新标签统计', () {
        final testPlugins = [
          PluginStoreEntry(
            id: 'plugin1',
            name: 'Test Plugin 1',
            version: '1.0.0',
            description: 'Test plugin',
            author: 'Test Author',
            storeId: 'test-store',
            tags: ['development', 'testing'],
            rating: 4.5,
            downloadCount: 1000,
          ),
          PluginStoreEntry(
            id: 'plugin2',
            name: 'Test Plugin 2',
            version: '1.0.0',
            description: 'Another test plugin',
            author: 'Test Author',
            storeId: 'test-store',
            tags: ['development', 'api'],
            rating: 4.0,
            downloadCount: 500,
          ),
        ];

        tagManager.updateTagStatistics('development', testPlugins);

        final stats = tagManager.getTagStatistics('development');
        expect(stats, isNotNull);
        expect(stats!.usageCount, equals(2));
        expect(stats.totalDownloads, equals(1500));
        expect(stats.averageRating, equals(4.25));
      });

      test('应该正确导出和导入分类数据', () async {
        // 导出数据
        final exportedData = categoryManager.exportCategories();
        expect(exportedData, isNotNull);
        expect(exportedData['categories'], isNotNull);
        expect(exportedData['hierarchy'], isNotNull);

        // 清空数据
        categoryManager.clearCache();

        // 导入数据
        await categoryManager.importCategories(exportedData);

        // 验证数据恢复
        final categories = categoryManager.getAllCategories();
        expect(categories.isNotEmpty, isTrue);
      });

      test('应该正确导出和导入标签数据', () async {
        // 导出数据
        final exportedData = tagManager.exportTags();
        expect(exportedData, isNotNull);
        expect(exportedData['tags'], isNotNull);
        expect(exportedData['relations'], isNotNull);

        // 清空数据
        tagManager.clearCache();

        // 导入数据
        await tagManager.importTags(exportedData);

        // 验证数据恢复
        final tags = tagManager.getAllTags();
        expect(tags.isNotEmpty, isTrue);
      });
    });
  });
}
