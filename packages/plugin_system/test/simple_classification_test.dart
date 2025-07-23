/*
---------------------------------------------------------------
File name:          simple_classification_test.dart
Author:             lgnorant-lu
Date created:       2025-07-23
Last modified:      2025-07-23
Dart Version:       3.2+
Description:        简化的分类和标签系统测试
---------------------------------------------------------------
*/

import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_system/src/classification/index.dart';
import 'package:plugin_system/src/store/plugin_store_models.dart';

void main() {
  group('简化分类和标签系统测试', () {
    late PluginCategoryManager categoryManager;
    late PluginTagManager tagManager;

    setUp(() async {
      categoryManager = PluginCategoryManager.instance;
      tagManager = PluginTagManager.instance;
      
      await categoryManager.initialize();
      await tagManager.initialize();
    });

    test('分类管理器初始化测试', () {
      final List<PluginCategory> categories = categoryManager.getAllCategories();
      expect(categories.isNotEmpty, isTrue);
      
      final List<PluginCategory> rootCategories = categoryManager.getRootCategories();
      expect(rootCategories.isNotEmpty, isTrue);
      
      print('✅ 发现 ${categories.length} 个分类，${rootCategories.length} 个根分类');
    });

    test('标签管理器初始化测试', () {
      final List<PluginTag> tags = tagManager.getAllTags();
      expect(tags.isNotEmpty, isTrue);
      
      print('✅ 发现 ${tags.length} 个标签');
    });

    test('分类建议功能测试', () async {
      const PluginStoreEntry testPlugin = PluginStoreEntry(
        id: 'test-plugin',
        name: 'Code Editor Plugin',
        version: '1.0.0',
        description: 'A powerful code editor with debugging features',
        author: 'Test Author',
        storeId: 'test-store',
        tags: <String>['editor', 'code', 'debug'],
      );

      final List<CategorySuggestion> suggestions =
          await categoryManager.suggestCategories(testPlugin);
      expect(suggestions.isNotEmpty, isTrue);
      
      print('✅ 生成了 ${suggestions.length} 个分类建议');
    });

    test('标签建议功能测试', () async {
      const PluginStoreEntry testPlugin = PluginStoreEntry(
        id: 'test-plugin',
        name: 'Game Development Tool',
        version: '1.0.0',
        description: 'A tool for game development and testing',
        author: 'Test Author',
        storeId: 'test-store',
        category: 'development',
        tags: <String>['game'],
      );

      final List<TagSuggestion> suggestions = await tagManager.suggestTags(testPlugin);
      expect(suggestions.isNotEmpty, isTrue);
      
      print('✅ 生成了 ${suggestions.length} 个标签建议');
    });

    test('搜索功能测试', () {
      final List<PluginCategory> categoryResults = categoryManager.searchCategories('dev');
      expect(categoryResults.isNotEmpty, isTrue);
      
      final List<PluginTag> tagResults = tagManager.searchTags('dev');
      expect(tagResults.isNotEmpty, isTrue);
      
      print('✅ 搜索"dev"找到 ${categoryResults.length} 个分类，${tagResults.length} 个标签');
    });
  });
}
