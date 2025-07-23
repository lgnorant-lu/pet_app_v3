/*
---------------------------------------------------------------
File name:          plugin_category_manager.dart
Author:             lgnorant-lu
Date created:       2025-07-23
Last modified:      2025-07-23
Dart Version:       3.2+
Description:        插件分类管理系统 - 基于Ming CLI分类架构设计
---------------------------------------------------------------
Change History:
    2025-07-23: Task 2.3.1 - 创建插件分类管理系统;
---------------------------------------------------------------
*/

import 'dart:math' as math;
import 'package:flutter/foundation.dart';

import 'package:plugin_system/src/store/plugin_store_models.dart';

/// 插件分类信息
@immutable
class PluginCategory {
  const PluginCategory({
    required this.id,
    required this.name,
    required this.displayName,
    this.description,
    this.parentId,
    this.level = 0,
    this.iconName,
    this.color,
    this.isSystem = false,
    this.isActive = true,
    this.sortOrder = 0,
    this.metadata = const <String, dynamic>{},
  });

  factory PluginCategory.fromJson(Map<String, dynamic> json) => PluginCategory(
        id: json['id'] as String,
        name: json['name'] as String,
        displayName: json['displayName'] as String,
        description: json['description'] as String?,
        parentId: json['parentId'] as String?,
        level: json['level'] as int? ?? 0,
        iconName: json['iconName'] as String?,
        color: json['color'] as String?,
        isSystem: json['isSystem'] as bool? ?? false,
        isActive: json['isActive'] as bool? ?? true,
        sortOrder: json['sortOrder'] as int? ?? 0,
        metadata: Map<String, dynamic>.from(
          json['metadata'] as Map? ?? <String, dynamic>{},
        ),
      );

  final String id;
  final String name;
  final String displayName;
  final String? description;
  final String? parentId;
  final int level;
  final String? iconName;
  final String? color;
  final bool isSystem;
  final bool isActive;
  final int sortOrder;
  final Map<String, dynamic> metadata;

  /// 是否为根分类
  bool get isRoot => parentId == null;

  /// 是否为叶子分类
  bool get isLeaf => level > 0;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'displayName': displayName,
        'description': description,
        'parentId': parentId,
        'level': level,
        'iconName': iconName,
        'color': color,
        'isSystem': isSystem,
        'isActive': isActive,
        'sortOrder': sortOrder,
        'metadata': metadata,
      };

  @override
  String toString() => 'PluginCategory(id: $id, name: $name, level: $level)';
}

/// 分类统计信息
@immutable
class CategoryStatistics {
  const CategoryStatistics({
    required this.categoryId,
    required this.pluginCount,
    required this.downloadCount,
    required this.averageRating,
    required this.lastUpdated,
    this.trendingScore = 0.0,
    this.popularityRank = 0,
  });

  final String categoryId;
  final int pluginCount;
  final int downloadCount;
  final double averageRating;
  final DateTime lastUpdated;
  final double trendingScore;
  final int popularityRank;

  @override
  String toString() =>
      'CategoryStatistics(category: $categoryId, plugins: $pluginCount)';
}

/// 分类建议结果
@immutable
class CategorySuggestion {
  const CategorySuggestion({
    required this.category,
    required this.confidence,
    required this.reason,
    this.metadata = const <String, dynamic>{},
  });

  final PluginCategory category;
  final double confidence;
  final String reason;
  final Map<String, dynamic> metadata;

  @override
  String toString() =>
      'CategorySuggestion(category: ${category.name}, confidence: $confidence)';
}

/// 插件分类管理器 (基于Ming CLI ModuleClassification设计)
class PluginCategoryManager extends ChangeNotifier {
  PluginCategoryManager._();
  static final PluginCategoryManager _instance = PluginCategoryManager._();
  static PluginCategoryManager get instance => _instance;

  /// 分类注册表
  final Map<String, PluginCategory> _categories = <String, PluginCategory>{};

  /// 分类层次结构
  final Map<String, List<String>> _categoryHierarchy = <String, List<String>>{};

  /// 分类统计信息
  final Map<String, CategoryStatistics> _categoryStats =
      <String, CategoryStatistics>{};

  /// 分类关键词映射
  final Map<String, Set<String>> _categoryKeywords = <String, Set<String>>{};

  /// 是否已初始化
  bool _isInitialized = false;

  /// 初始化分类管理器
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _initializeSystemCategories();
    await _buildCategoryHierarchy();
    await _initializeCategoryKeywords();

    _isInitialized = true;
    debugPrint('插件分类管理器已初始化');
  }

  /// 获取所有分类
  List<PluginCategory> getAllCategories() =>
      _categories.values.where((PluginCategory cat) => cat.isActive).toList()
        ..sort((PluginCategory a, PluginCategory b) =>
            a.sortOrder.compareTo(b.sortOrder));

  /// 获取根分类
  List<PluginCategory> getRootCategories() => _categories.values
      .where((PluginCategory cat) => cat.isRoot && cat.isActive)
      .toList()
    ..sort((PluginCategory a, PluginCategory b) =>
        a.sortOrder.compareTo(b.sortOrder));

  /// 获取子分类
  List<PluginCategory> getSubCategories(String parentId) {
    final childIds = _categoryHierarchy[parentId] ?? <String>[];
    return childIds
        .map((String id) => _categories[id])
        .where((PluginCategory? cat) => cat != null && cat.isActive)
        .cast<PluginCategory>()
        .toList()
      ..sort((PluginCategory a, PluginCategory b) =>
          a.sortOrder.compareTo(b.sortOrder));
  }

  /// 获取分类路径
  List<PluginCategory> getCategoryPath(String categoryId) {
    final path = <PluginCategory>[];
    String? currentId = categoryId;

    while (currentId != null) {
      final category = _categories[currentId];
      if (category == null) break;

      path.insert(0, category);
      currentId = category.parentId;
    }

    return path;
  }

  /// 注册分类
  void registerCategory(PluginCategory category) {
    _categories[category.id] = category;
    _updateCategoryHierarchy(category);
    notifyListeners();
    debugPrint('注册分类: ${category.name}');
  }

  /// 智能分类建议
  Future<List<CategorySuggestion>> suggestCategories(
    PluginStoreEntry plugin, {
    int maxSuggestions = 3,
    double minConfidence = 0.3,
  }) async {
    final suggestions = <CategorySuggestion>[];

    // 基于名称和描述的关键词匹配
    suggestions.addAll(await _suggestByKeywords(plugin));

    // 基于标签的分类建议
    suggestions.addAll(await _suggestByTags(plugin));

    // 基于相似插件的分类建议
    suggestions.addAll(await _suggestBySimilarPlugins(plugin));

    // 排序和过滤
    suggestions.sort((CategorySuggestion a, CategorySuggestion b) =>
        b.confidence.compareTo(a.confidence));
    return suggestions
        .where((CategorySuggestion s) => s.confidence >= minConfidence)
        .take(maxSuggestions)
        .toList();
  }

  /// 获取分类统计
  CategoryStatistics? getCategoryStatistics(String categoryId) =>
      _categoryStats[categoryId];

  /// 更新分类统计
  void updateCategoryStatistics(
    String categoryId,
    List<PluginStoreEntry> plugins,
  ) {
    final categoryPlugins = plugins
        .where((PluginStoreEntry p) => p.category == categoryId)
        .toList();

    if (categoryPlugins.isEmpty) {
      _categoryStats.remove(categoryId);
      return;
    }

    final totalDownloads = categoryPlugins.fold<int>(
      0,
      (int sum, PluginStoreEntry plugin) => sum + plugin.downloadCount,
    );
    final averageRating = categoryPlugins.fold<double>(
          0,
          (double sum, PluginStoreEntry plugin) => sum + plugin.rating,
        ) /
        categoryPlugins.length;

    _categoryStats[categoryId] = CategoryStatistics(
      categoryId: categoryId,
      pluginCount: categoryPlugins.length,
      downloadCount: totalDownloads,
      averageRating: averageRating,
      lastUpdated: DateTime.now(),
      trendingScore: _calculateTrendingScore(categoryPlugins),
      popularityRank: _calculatePopularityRank(categoryId),
    );

    notifyListeners();
  }

  /// 搜索分类
  List<PluginCategory> searchCategories(String query) {
    final queryLower = query.toLowerCase();
    return _categories.values
        .where((PluginCategory cat) => cat.isActive)
        .where(
          (PluginCategory cat) =>
              cat.name.toLowerCase().contains(queryLower) ||
              cat.displayName.toLowerCase().contains(queryLower) ||
              (cat.description?.toLowerCase().contains(queryLower) ?? false),
        )
        .toList()
      ..sort((PluginCategory a, PluginCategory b) => a.name.compareTo(b.name));
  }

  /// 获取热门分类
  List<PluginCategory> getTrendingCategories({int limit = 10}) {
    final stats = _categoryStats.values.toList()
      ..sort((CategoryStatistics a, CategoryStatistics b) =>
          b.trendingScore.compareTo(a.trendingScore));

    return stats
        .take(limit)
        .map((CategoryStatistics stat) => _categories[stat.categoryId])
        .where((PluginCategory? cat) => cat != null)
        .cast<PluginCategory>()
        .toList();
  }

  /// 初始化系统分类
  Future<void> _initializeSystemCategories() async {
    final systemCategories = <PluginCategory>[
      // 根分类
      const PluginCategory(
        id: 'development',
        name: 'development',
        displayName: '开发工具',
        description: '开发和编程相关的插件',
        iconName: 'code',
        color: '#2196F3',
        isSystem: true,
        sortOrder: 1,
      ),
      const PluginCategory(
        id: 'productivity',
        name: 'productivity',
        displayName: '生产力',
        description: '提高工作效率的插件',
        iconName: 'work',
        color: '#4CAF50',
        isSystem: true,
        sortOrder: 2,
      ),
      const PluginCategory(
        id: 'entertainment',
        name: 'entertainment',
        displayName: '娱乐',
        description: '娱乐和游戏相关的插件',
        iconName: 'games',
        color: '#FF9800',
        isSystem: true,
        sortOrder: 3,
      ),
      const PluginCategory(
        id: 'utilities',
        name: 'utilities',
        displayName: '实用工具',
        description: '系统和实用工具插件',
        iconName: 'build',
        color: '#9C27B0',
        isSystem: true,
        sortOrder: 4,
      ),
      const PluginCategory(
        id: 'social',
        name: 'social',
        displayName: '社交',
        description: '社交和通信相关的插件',
        iconName: 'people',
        color: '#E91E63',
        isSystem: true,
        sortOrder: 5,
      ),

      // 子分类 - 开发工具
      const PluginCategory(
        id: 'development.ide',
        name: 'ide',
        displayName: 'IDE扩展',
        description: '集成开发环境扩展',
        parentId: 'development',
        level: 1,
        isSystem: true,
        sortOrder: 1,
      ),
      const PluginCategory(
        id: 'development.debugging',
        name: 'debugging',
        displayName: '调试工具',
        description: '代码调试和分析工具',
        parentId: 'development',
        level: 1,
        isSystem: true,
        sortOrder: 2,
      ),
      const PluginCategory(
        id: 'development.testing',
        name: 'testing',
        displayName: '测试工具',
        description: '代码测试和质量保证工具',
        parentId: 'development',
        level: 1,
        isSystem: true,
        sortOrder: 3,
      ),

      // 子分类 - 生产力
      const PluginCategory(
        id: 'productivity.notes',
        name: 'notes',
        displayName: '笔记工具',
        description: '笔记和文档管理工具',
        parentId: 'productivity',
        level: 1,
        isSystem: true,
        sortOrder: 1,
      ),
      const PluginCategory(
        id: 'productivity.task',
        name: 'task',
        displayName: '任务管理',
        description: '任务和项目管理工具',
        parentId: 'productivity',
        level: 1,
        isSystem: true,
        sortOrder: 2,
      ),
    ];

    for (final category in systemCategories) {
      _categories[category.id] = category;
    }
  }

  /// 构建分类层次结构
  Future<void> _buildCategoryHierarchy() async {
    _categoryHierarchy.clear();

    for (final category in _categories.values) {
      if (category.parentId != null) {
        _categoryHierarchy
            .putIfAbsent(category.parentId!, () => <String>[])
            .add(category.id);
      }
    }
  }

  /// 初始化分类关键词
  Future<void> _initializeCategoryKeywords() async {
    final keywordMappings = <String, List<String>>{
      'development': <String>[
        'code',
        'programming',
        'dev',
        'developer',
        'coding',
        'software',
        'api',
        'sdk',
      ],
      'development.ide': <String>[
        'editor',
        'ide',
        'vscode',
        'intellij',
        'sublime',
        'atom',
      ],
      'development.debugging': <String>[
        'debug',
        'debugger',
        'breakpoint',
        'trace',
        'profiler',
      ],
      'development.testing': <String>[
        'test',
        'testing',
        'unit',
        'integration',
        'mock',
        'coverage',
      ],
      'productivity': <String>[
        'productivity',
        'work',
        'office',
        'business',
        'efficiency',
      ],
      'productivity.notes': <String>[
        'note',
        'notes',
        'markdown',
        'document',
        'writing',
        'memo',
      ],
      'productivity.task': <String>[
        'task',
        'todo',
        'project',
        'management',
        'planning',
        'schedule',
      ],
      'entertainment': <String>[
        'game',
        'gaming',
        'fun',
        'entertainment',
        'music',
        'video',
      ],
      'utilities': <String>[
        'utility',
        'tool',
        'system',
        'helper',
        'converter',
        'calculator',
      ],
      'social': <String>[
        'social',
        'chat',
        'message',
        'communication',
        'share',
        'network',
      ],
    };

    for (final entry in keywordMappings.entries) {
      _categoryKeywords[entry.key] = entry.value.toSet();
    }
  }

  /// 更新分类层次结构
  void _updateCategoryHierarchy(PluginCategory category) {
    if (category.parentId != null) {
      _categoryHierarchy
          .putIfAbsent(category.parentId!, () => <String>[])
          .add(category.id);
    }
  }

  /// 基于关键词建议分类
  Future<List<CategorySuggestion>> _suggestByKeywords(
    PluginStoreEntry plugin,
  ) async {
    final suggestions = <CategorySuggestion>[];
    final text = '${plugin.name} ${plugin.description}'.toLowerCase();

    for (final entry in _categoryKeywords.entries) {
      final categoryId = entry.key;
      final keywords = entry.value;
      final category = _categories[categoryId];

      if (category == null || !category.isActive) continue;

      var matchCount = 0;
      var totalScore = 0.0;

      for (final keyword in keywords) {
        if (text.contains(keyword)) {
          matchCount++;
          // 名称匹配权重更高
          if (plugin.name.toLowerCase().contains(keyword)) {
            totalScore += 2.0;
          } else {
            totalScore += 1.0;
          }
        }
      }

      if (matchCount > 0) {
        final double confidence = math.min(totalScore / keywords.length, 1);
        suggestions.add(
          CategorySuggestion(
            category: category,
            confidence: confidence,
            reason: '基于关键词匹配: $matchCount个关键词',
            metadata: <String, dynamic>{
              'matched_keywords': matchCount,
              'total_keywords': keywords.length,
              'score': totalScore,
            },
          ),
        );
      }
    }

    return suggestions;
  }

  /// 基于标签建议分类
  Future<List<CategorySuggestion>> _suggestByTags(
    PluginStoreEntry plugin,
  ) async {
    final suggestions = <CategorySuggestion>[];

    for (final tag in plugin.tags) {
      final tagLower = tag.toLowerCase();

      for (final entry in _categoryKeywords.entries) {
        final categoryId = entry.key;
        final keywords = entry.value;
        final category = _categories[categoryId];

        if (category == null || !category.isActive) continue;

        if (keywords.contains(tagLower)) {
          suggestions.add(
            CategorySuggestion(
              category: category,
              confidence: 0.8,
              reason: '基于标签匹配: $tag',
              metadata: <String, dynamic>{
                'matched_tag': tag,
                'category_keywords': keywords.toList(),
              },
            ),
          );
        }
      }
    }

    return suggestions;
  }

  /// 基于相似插件建议分类
  Future<List<CategorySuggestion>> _suggestBySimilarPlugins(
    PluginStoreEntry plugin,
  ) async {
    // TODO: 实现基于相似插件的分类建议
    // 这需要访问插件数据库来查找相似插件
    return <CategorySuggestion>[];
  }

  /// 计算趋势评分
  double _calculateTrendingScore(List<PluginStoreEntry> plugins) {
    if (plugins.isEmpty) return 0;

    var score = 0.0;
    final now = DateTime.now();

    for (final plugin in plugins) {
      // 下载量评分
      score += math.log(plugin.downloadCount + 1) * 0.3;

      // 评分评分
      score += plugin.rating * 0.2;

      // 更新时间评分
      if (plugin.updatedAt != null) {
        final daysSinceUpdate = now.difference(plugin.updatedAt!).inDays;
        if (daysSinceUpdate < 30) {
          score += 0.3;
        } else if (daysSinceUpdate < 90) {
          score += 0.2;
        }
      }

      // 验证状态评分
      if (plugin.isVerified) score += 0.1;
      if (plugin.isFeatured) score += 0.1;
    }

    return score / plugins.length;
  }

  /// 计算流行度排名
  int _calculatePopularityRank(String categoryId) {
    final allStats = _categoryStats.values.toList()
      ..sort((CategoryStatistics a, CategoryStatistics b) =>
          b.downloadCount.compareTo(a.downloadCount));

    for (int i = 0; i < allStats.length; i++) {
      if (allStats[i].categoryId == categoryId) {
        return i + 1;
      }
    }

    return allStats.length + 1;
  }

  /// 清理缓存
  void clearCache() {
    _categoryStats.clear();
    notifyListeners();
  }

  /// 导出分类数据
  Map<String, dynamic> exportCategories() => <String, dynamic>{
        'categories': _categories.values
            .map((PluginCategory cat) => cat.toJson())
            .toList(),
        'hierarchy': _categoryHierarchy,
        'statistics': _categoryStats.map(
          (String key, CategoryStatistics value) =>
              MapEntry(key, <String, Object>{
            'categoryId': value.categoryId,
            'pluginCount': value.pluginCount,
            'downloadCount': value.downloadCount,
            'averageRating': value.averageRating,
            'lastUpdated': value.lastUpdated.toIso8601String(),
            'trendingScore': value.trendingScore,
            'popularityRank': value.popularityRank,
          }),
        ),
        'exportedAt': DateTime.now().toIso8601String(),
      };

  /// 导入分类数据
  Future<void> importCategories(Map<String, dynamic> data) async {
    try {
      // 导入分类
      final categoriesData = data['categories'] as List<dynamic>?;
      if (categoriesData != null) {
        _categories.clear();
        for (final categoryData in categoriesData) {
          final category =
              PluginCategory.fromJson(categoryData as Map<String, dynamic>);
          _categories[category.id] = category;
        }
      }

      // 导入层次结构
      final hierarchyData = data['hierarchy'] as Map<String, dynamic>?;
      if (hierarchyData != null) {
        _categoryHierarchy.clear();
        for (final entry in hierarchyData.entries) {
          _categoryHierarchy[entry.key] =
              List<String>.from(entry.value as List);
        }
      }

      notifyListeners();
      debugPrint('分类数据导入完成');
    } catch (e) {
      debugPrint('分类数据导入失败: $e');
      rethrow;
    }
  }
}
