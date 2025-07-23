/*
---------------------------------------------------------------
File name:          plugin_tag_manager.dart
Author:             lgnorant-lu
Date created:       2025-07-23
Last modified:      2025-07-23
Dart Version:       3.2+
Description:        插件标签管理系统 - 基于Ming CLI标签架构设计
---------------------------------------------------------------
Change History:
    2025-07-23: Task 2.3.2 - 创建插件标签管理系统;
---------------------------------------------------------------
*/

import 'dart:math' as math;
import 'package:flutter/foundation.dart';

import 'package:plugin_system/src/store/plugin_store_models.dart';

/// 插件标签信息
@immutable
class PluginTag {
  const PluginTag({
    required this.name,
    required this.displayName,
    this.description,
    this.color,
    this.iconName,
    this.category,
    this.isSystem = false,
    this.isActive = true,
    this.usageCount = 0,
    this.trendingScore = 0.0,
    this.metadata = const <String, dynamic>{},
  });

  factory PluginTag.fromJson(Map<String, dynamic> json) => PluginTag(
        name: json['name'] as String,
        displayName: json['displayName'] as String,
        description: json['description'] as String?,
        color: json['color'] as String?,
        iconName: json['iconName'] as String?,
        category: json['category'] as String?,
        isSystem: json['isSystem'] as bool? ?? false,
        isActive: json['isActive'] as bool? ?? true,
        usageCount: json['usageCount'] as int? ?? 0,
        trendingScore: (json['trendingScore'] as num?)?.toDouble() ?? 0.0,
        metadata: Map<String, dynamic>.from(
          json['metadata'] as Map? ?? <String, dynamic>{},
        ),
      );

  final String name;
  final String displayName;
  final String? description;
  final String? color;
  final String? iconName;
  final String? category;
  final bool isSystem;
  final bool isActive;
  final int usageCount;
  final double trendingScore;
  final Map<String, dynamic> metadata;

  /// 标签ID (使用name作为唯一标识)
  String get id => name;

  /// 转换为JSON
  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'displayName': displayName,
        'description': description,
        'color': color,
        'iconName': iconName,
        'category': category,
        'isSystem': isSystem,
        'isActive': isActive,
        'usageCount': usageCount,
        'trendingScore': trendingScore,
        'metadata': metadata,
      };

  @override
  String toString() => 'PluginTag(name: $name, usage: $usageCount)';
}

/// 标签建议结果
@immutable
class TagSuggestion {
  const TagSuggestion({
    required this.tag,
    required this.confidence,
    required this.reason,
    this.metadata = const <String, dynamic>{},
  });

  final PluginTag tag;
  final double confidence;
  final String reason;
  final Map<String, dynamic> metadata;

  @override
  String toString() =>
      'TagSuggestion(tag: ${tag.name}, confidence: $confidence)';
}

/// 标签统计信息
@immutable
class TagStatistics {
  const TagStatistics({
    required this.tagName,
    required this.usageCount,
    required this.pluginCount,
    required this.averageRating,
    required this.totalDownloads,
    required this.lastUsed,
    this.trendingScore = 0.0,
    this.popularityRank = 0,
  });

  final String tagName;
  final int usageCount;
  final int pluginCount;
  final double averageRating;
  final int totalDownloads;
  final DateTime lastUsed;
  final double trendingScore;
  final int popularityRank;

  @override
  String toString() => 'TagStatistics(tag: $tagName, usage: $usageCount)';
}

/// 插件标签管理器 (基于Ming CLI标签系统设计)
class PluginTagManager extends ChangeNotifier {
  PluginTagManager._();
  static final PluginTagManager _instance = PluginTagManager._();
  static PluginTagManager get instance => _instance;

  /// 标签注册表
  final Map<String, PluginTag> _tags = <String, PluginTag>{};

  /// 标签统计信息
  final Map<String, TagStatistics> _tagStats = <String, TagStatistics>{};

  /// 标签关联关系 (标签 -> 相关标签)
  final Map<String, Set<String>> _tagRelations = <String, Set<String>>{};

  /// 标签分类映射
  final Map<String, Set<String>> _categoryTags = <String, Set<String>>{};

  /// 是否已初始化
  bool _isInitialized = false;

  /// 初始化标签管理器
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _initializeSystemTags();
    await _buildTagRelations();

    _isInitialized = true;
    debugPrint('插件标签管理器已初始化');
  }

  /// 获取所有标签
  List<PluginTag> getAllTags() => _tags.values
      .where((PluginTag tag) => tag.isActive)
      .toList()
    ..sort((PluginTag a, PluginTag b) => b.usageCount.compareTo(a.usageCount));

  /// 获取热门标签
  List<PluginTag> getPopularTags({int limit = 20}) =>
      _tags.values.where((PluginTag tag) => tag.isActive).toList()
        ..sort((PluginTag a, PluginTag b) =>
            b.trendingScore.compareTo(a.trendingScore))
        ..take(limit);

  /// 获取分类标签
  List<PluginTag> getTagsByCategory(String category) {
    final tagNames = _categoryTags[category] ?? <String>{};
    return tagNames
        .map((String name) => _tags[name])
        .where((PluginTag? tag) => tag != null && tag.isActive)
        .cast<PluginTag>()
        .toList()
      ..sort(
          (PluginTag a, PluginTag b) => b.usageCount.compareTo(a.usageCount));
  }

  /// 搜索标签
  List<PluginTag> searchTags(String query) {
    final queryLower = query.toLowerCase();
    return _tags.values
        .where((PluginTag tag) => tag.isActive)
        .where(
          (PluginTag tag) =>
              tag.name.toLowerCase().contains(queryLower) ||
              tag.displayName.toLowerCase().contains(queryLower) ||
              (tag.description?.toLowerCase().contains(queryLower) ?? false),
        )
        .toList()
      ..sort(
          (PluginTag a, PluginTag b) => b.usageCount.compareTo(a.usageCount));
  }

  /// 智能标签建议
  Future<List<TagSuggestion>> suggestTags(
    PluginStoreEntry plugin, {
    int maxSuggestions = 10,
    double minConfidence = 0.3,
  }) async {
    final suggestions = <TagSuggestion>[];

    // 基于名称和描述的关键词提取
    suggestions.addAll(await _suggestByKeywords(plugin));

    // 基于分类的标签建议
    suggestions.addAll(await _suggestByCategory(plugin));

    // 基于相似插件的标签建议
    suggestions.addAll(await _suggestBySimilarPlugins(plugin));

    // 基于现有标签的相关标签建议
    suggestions.addAll(await _suggestByRelatedTags(plugin));

    // 排序和去重
    final uniqueSuggestions = _deduplicateSuggestions(suggestions);
    uniqueSuggestions.sort((TagSuggestion a, TagSuggestion b) =>
        b.confidence.compareTo(a.confidence));

    return uniqueSuggestions
        .where((TagSuggestion s) => s.confidence >= minConfidence)
        .take(maxSuggestions)
        .toList();
  }

  /// 注册标签
  void registerTag(PluginTag tag) {
    _tags[tag.name] = tag;

    // 更新分类映射
    if (tag.category != null) {
      _categoryTags.putIfAbsent(tag.category!, () => <String>{}).add(tag.name);
    }

    notifyListeners();
    debugPrint('注册标签: ${tag.name}');
  }

  /// 更新标签统计
  void updateTagStatistics(String tagName, List<PluginStoreEntry> plugins) {
    final tagPlugins = plugins
        .where((PluginStoreEntry p) => p.tags.contains(tagName))
        .toList();

    if (tagPlugins.isEmpty) {
      _tagStats.remove(tagName);
      return;
    }

    final totalDownloads = tagPlugins.fold<int>(
        0, (int sum, PluginStoreEntry plugin) => sum + plugin.downloadCount);
    final averageRating = tagPlugins.fold<double>(
            0, (double sum, PluginStoreEntry plugin) => sum + plugin.rating) /
        tagPlugins.length;

    _tagStats[tagName] = TagStatistics(
      tagName: tagName,
      usageCount: tagPlugins.length,
      pluginCount: tagPlugins.length,
      averageRating: averageRating,
      totalDownloads: totalDownloads,
      lastUsed: DateTime.now(),
      trendingScore: _calculateTagTrendingScore(tagPlugins),
      popularityRank: _calculateTagPopularityRank(tagName),
    );

    // 更新标签的使用统计
    final tag = _tags[tagName];
    if (tag != null) {
      _tags[tagName] = PluginTag(
        name: tag.name,
        displayName: tag.displayName,
        description: tag.description,
        color: tag.color,
        iconName: tag.iconName,
        category: tag.category,
        isSystem: tag.isSystem,
        isActive: tag.isActive,
        usageCount: tagPlugins.length,
        trendingScore: _calculateTagTrendingScore(tagPlugins),
        metadata: tag.metadata,
      );
    }

    notifyListeners();
  }

  /// 获取相关标签
  List<PluginTag> getRelatedTags(String tagName, {int limit = 5}) {
    final relatedTagNames = _tagRelations[tagName] ?? <String>{};
    return relatedTagNames
        .map((String name) => _tags[name])
        .where((PluginTag? tag) => tag != null && tag.isActive)
        .cast<PluginTag>()
        .toList()
      ..sort((PluginTag a, PluginTag b) => b.usageCount.compareTo(a.usageCount))
      ..take(limit);
  }

  /// 获取标签统计
  TagStatistics? getTagStatistics(String tagName) => _tagStats[tagName];

  /// 初始化系统标签
  Future<void> _initializeSystemTags() async {
    final systemTags = <PluginTag>[
      // 开发相关标签
      const PluginTag(
        name: 'development',
        displayName: '开发',
        description: '开发和编程相关',
        category: 'development',
        color: '#2196F3',
        iconName: 'code',
        isSystem: true,
      ),
      const PluginTag(
        name: 'debugging',
        displayName: '调试',
        description: '代码调试工具',
        category: 'development',
        color: '#FF5722',
        iconName: 'bug_report',
        isSystem: true,
      ),
      const PluginTag(
        name: 'testing',
        displayName: '测试',
        description: '代码测试工具',
        category: 'development',
        color: '#4CAF50',
        iconName: 'verified',
        isSystem: true,
      ),

      // 生产力标签
      const PluginTag(
        name: 'productivity',
        displayName: '生产力',
        description: '提高工作效率',
        category: 'productivity',
        color: '#FF9800',
        iconName: 'trending_up',
        isSystem: true,
      ),
      const PluginTag(
        name: 'automation',
        displayName: '自动化',
        description: '自动化工具',
        category: 'productivity',
        color: '#9C27B0',
        iconName: 'auto_fix_high',
        isSystem: true,
      ),

      // 工具标签
      const PluginTag(
        name: 'utility',
        displayName: '实用工具',
        description: '实用工具和助手',
        category: 'utilities',
        color: '#607D8B',
        iconName: 'build',
        isSystem: true,
      ),
      const PluginTag(
        name: 'converter',
        displayName: '转换器',
        description: '格式转换工具',
        category: 'utilities',
        color: '#795548',
        iconName: 'transform',
        isSystem: true,
      ),

      // 娱乐标签
      const PluginTag(
        name: 'game',
        displayName: '游戏',
        description: '游戏和娱乐',
        category: 'entertainment',
        color: '#E91E63',
        iconName: 'games',
        isSystem: true,
      ),
      const PluginTag(
        name: 'media',
        displayName: '媒体',
        description: '音视频媒体',
        category: 'entertainment',
        color: '#3F51B5',
        iconName: 'play_circle',
        isSystem: true,
      ),

      // 社交标签
      const PluginTag(
        name: 'social',
        displayName: '社交',
        description: '社交和通信',
        category: 'social',
        color: '#00BCD4',
        iconName: 'people',
        isSystem: true,
      ),
      const PluginTag(
        name: 'communication',
        displayName: '通信',
        description: '通信和消息',
        category: 'social',
        color: '#009688',
        iconName: 'chat',
        isSystem: true,
      ),
    ];

    for (final tag in systemTags) {
      _tags[tag.name] = tag;
      if (tag.category != null) {
        _categoryTags
            .putIfAbsent(tag.category!, () => <String>{})
            .add(tag.name);
      }
    }
  }

  /// 构建标签关联关系
  Future<void> _buildTagRelations() async {
    // 开发相关标签关联
    _addTagRelation(
        'development', <String>['debugging', 'testing', 'api', 'sdk']);
    _addTagRelation(
        'debugging', <String>['development', 'testing', 'profiler']);
    _addTagRelation(
        'testing', <String>['development', 'debugging', 'automation']);

    // 生产力标签关联
    _addTagRelation(
        'productivity', <String>['automation', 'utility', 'workflow']);
    _addTagRelation(
        'automation', <String>['productivity', 'utility', 'scripting']);

    // 工具标签关联
    _addTagRelation('utility', <String>['productivity', 'converter', 'helper']);
    _addTagRelation(
        'converter', <String>['utility', 'transformation', 'format']);

    // 娱乐标签关联
    _addTagRelation('game', <String>['entertainment', 'media', 'interactive']);
    _addTagRelation(
        'media', <String>['game', 'entertainment', 'audio', 'video']);

    // 社交标签关联
    _addTagRelation('social', <String>['communication', 'sharing', 'network']);
    _addTagRelation('communication', <String>['social', 'messaging', 'chat']);
  }

  /// 添加标签关联关系
  void _addTagRelation(String tagName, List<String> relatedTags) {
    _tagRelations[tagName] = relatedTags.toSet();
  }

  /// 基于关键词建议标签
  Future<List<TagSuggestion>> _suggestByKeywords(
    PluginStoreEntry plugin,
  ) async {
    final suggestions = <TagSuggestion>[];
    final text = '${plugin.name} ${plugin.description}'.toLowerCase();

    // 关键词到标签的映射
    final keywordToTags = <String, List<String>>{
      'debug': <String>['debugging'],
      'test': <String>['testing'],
      'game': <String>['game', 'entertainment'],
      'chat': <String>['communication', 'social'],
      'convert': <String>['converter', 'utility'],
      'tool': <String>['utility'],
      'auto': <String>['automation'],
      'media': <String>['media', 'entertainment'],
      'social': <String>['social', 'communication'],
      'dev': <String>['development'],
      'code': <String>['development'],
      'api': <String>['development'],
      'sdk': <String>['development'],
    };

    for (final entry in keywordToTags.entries) {
      final keyword = entry.key;
      final tagNames = entry.value;

      if (text.contains(keyword)) {
        for (final tagName in tagNames) {
          final tag = _tags[tagName];
          if (tag != null && tag.isActive) {
            var confidence = 0.6;
            // 名称匹配权重更高
            if (plugin.name.toLowerCase().contains(keyword)) {
              confidence = 0.8;
            }

            suggestions.add(
              TagSuggestion(
                tag: tag,
                confidence: confidence,
                reason: '基于关键词匹配: $keyword',
                metadata: <String, dynamic>{'keyword': keyword},
              ),
            );
          }
        }
      }
    }

    return suggestions;
  }

  /// 基于分类建议标签
  Future<List<TagSuggestion>> _suggestByCategory(
    PluginStoreEntry plugin,
  ) async {
    final suggestions = <TagSuggestion>[];

    if (plugin.category != null) {
      final categoryTags = getTagsByCategory(plugin.category!);
      for (final tag in categoryTags.take(5)) {
        suggestions.add(
          TagSuggestion(
            tag: tag,
            confidence: 0.7,
            reason: '基于分类匹配: ${plugin.category}',
            metadata: <String, dynamic>{'category': plugin.category},
          ),
        );
      }
    }

    return suggestions;
  }

  /// 基于相似插件建议标签
  Future<List<TagSuggestion>> _suggestBySimilarPlugins(
    PluginStoreEntry plugin,
  ) async {
    // TODO: 实现基于相似插件的标签建议
    return <TagSuggestion>[];
  }

  /// 基于相关标签建议标签
  Future<List<TagSuggestion>> _suggestByRelatedTags(
    PluginStoreEntry plugin,
  ) async {
    final suggestions = <TagSuggestion>[];

    for (final existingTag in plugin.tags) {
      final relatedTags = getRelatedTags(existingTag);
      for (final relatedTag in relatedTags) {
        if (!plugin.tags.contains(relatedTag.name)) {
          suggestions.add(
            TagSuggestion(
              tag: relatedTag,
              confidence: 0.5,
              reason: '基于相关标签: $existingTag',
              metadata: <String, dynamic>{'related_to': existingTag},
            ),
          );
        }
      }
    }

    return suggestions;
  }

  /// 去重建议
  List<TagSuggestion> _deduplicateSuggestions(List<TagSuggestion> suggestions) {
    final seen = <String>{};
    final unique = <TagSuggestion>[];

    for (final suggestion in suggestions) {
      if (!seen.contains(suggestion.tag.name)) {
        seen.add(suggestion.tag.name);
        unique.add(suggestion);
      }
    }

    return unique;
  }

  /// 计算标签趋势评分
  double _calculateTagTrendingScore(List<PluginStoreEntry> plugins) {
    if (plugins.isEmpty) return 0;

    var score = 0.0;
    final now = DateTime.now();

    for (final plugin in plugins) {
      // 下载量评分
      score += math.log(plugin.downloadCount + 1) * 0.4;

      // 评分评分
      score += plugin.rating * 0.3;

      // 更新时间评分
      if (plugin.updatedAt != null) {
        final daysSinceUpdate = now.difference(plugin.updatedAt!).inDays;
        if (daysSinceUpdate < 30) {
          score += 0.2;
        } else if (daysSinceUpdate < 90) {
          score += 0.1;
        }
      }

      // 验证状态评分
      if (plugin.isVerified) score += 0.1;
    }

    return score / plugins.length;
  }

  /// 计算标签流行度排名
  int _calculateTagPopularityRank(String tagName) {
    final allStats = _tagStats.values.toList()
      ..sort((TagStatistics a, TagStatistics b) =>
          b.usageCount.compareTo(a.usageCount));

    for (int i = 0; i < allStats.length; i++) {
      if (allStats[i].tagName == tagName) {
        return i + 1;
      }
    }

    return allStats.length + 1;
  }

  /// 自动生成标签
  List<String> generateTagsFromText(String text) {
    final generatedTags = <String>[];
    final textLower = text.toLowerCase();

    // 简单的关键词提取
    final keywords = <String>[
      'api',
      'sdk',
      'framework',
      'library',
      'tool',
      'utility',
      'game',
      'entertainment',
      'social',
      'chat',
      'message',
      'debug',
      'test',
      'automation',
      'productivity',
      'workflow',
      'converter',
      'parser',
      'generator',
      'validator',
      'formatter',
      'ui',
      'ux',
      'design',
      'theme',
      'style',
      'animation',
      'database',
      'storage',
      'cache',
      'network',
      'http',
      'rest',
      'security',
      'auth',
      'encryption',
      'validation',
      'permission',
      'analytics',
      'tracking',
      'monitoring',
      'logging',
      'metrics',
    ];

    for (final keyword in keywords) {
      if (textLower.contains(keyword) && !generatedTags.contains(keyword)) {
        generatedTags.add(keyword);
      }
    }

    return generatedTags.take(5).toList(); // 限制生成的标签数量
  }

  /// 清理缓存
  void clearCache() {
    _tagStats.clear();
    notifyListeners();
  }

  /// 导出标签数据
  Map<String, dynamic> exportTags() => <String, dynamic>{
        'tags': _tags.values.map((PluginTag tag) => tag.toJson()).toList(),
        'relations': _tagRelations.map(
            (String key, Set<String> value) => MapEntry(key, value.toList())),
        'categoryTags': _categoryTags.map(
            (String key, Set<String> value) => MapEntry(key, value.toList())),
        'statistics': _tagStats.map(
          (String key, TagStatistics value) => MapEntry(key, <String, Object>{
            'tagName': value.tagName,
            'usageCount': value.usageCount,
            'pluginCount': value.pluginCount,
            'averageRating': value.averageRating,
            'totalDownloads': value.totalDownloads,
            'lastUsed': value.lastUsed.toIso8601String(),
            'trendingScore': value.trendingScore,
            'popularityRank': value.popularityRank,
          }),
        ),
        'exportedAt': DateTime.now().toIso8601String(),
      };

  /// 导入标签数据
  Future<void> importTags(Map<String, dynamic> data) async {
    try {
      // 导入标签
      final tagsData = data['tags'] as List<dynamic>?;
      if (tagsData != null) {
        _tags.clear();
        for (final tagData in tagsData) {
          final tag = PluginTag.fromJson(tagData as Map<String, dynamic>);
          _tags[tag.name] = tag;
        }
      }

      // 导入关联关系
      final relationsData = data['relations'] as Map<String, dynamic>?;
      if (relationsData != null) {
        _tagRelations.clear();
        for (final entry in relationsData.entries) {
          _tagRelations[entry.key] = Set<String>.from(entry.value as List);
        }
      }

      // 导入分类映射
      final categoryTagsData = data['categoryTags'] as Map<String, dynamic>?;
      if (categoryTagsData != null) {
        _categoryTags.clear();
        for (final entry in categoryTagsData.entries) {
          _categoryTags[entry.key] = Set<String>.from(entry.value as List);
        }
      }

      notifyListeners();
      debugPrint('标签数据导入完成');
    } catch (e) {
      debugPrint('标签数据导入失败: $e');
      rethrow;
    }
  }
}
