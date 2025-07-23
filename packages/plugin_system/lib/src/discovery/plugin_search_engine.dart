/*
---------------------------------------------------------------
File name:          plugin_search_engine.dart
Author:             lgnorant-lu
Date created:       2025-07-23
Last modified:      2025-07-23
Dart Version:       3.2+
Description:        插件高级搜索引擎 - 基于Ming CLI搜索算法设计
---------------------------------------------------------------
Change History:
    2025-07-23: Task 2.2.2 - 创建插件高级搜索引擎;
---------------------------------------------------------------
*/

import 'dart:math' as math;
import 'package:flutter/foundation.dart';

import 'package:plugin_system/src/store/plugin_store_models.dart';

/// 搜索过滤器
@immutable
class PluginSearchFilter {
  const PluginSearchFilter({
    this.categories = const <String>[],
    this.tags = const <String>[],
    this.authors = const <String>[],
    this.platforms = const <String>[],
    this.minRating,
    this.maxRating,
    this.minDownloads,
    this.maxDownloads,
    this.verifiedOnly = false,
    this.featuredOnly = false,
    this.freeOnly = false,
    this.hasDocumentation = false,
    this.hasScreenshots = false,
    this.licenseTypes = const <String>[],
    this.publishedAfter,
    this.publishedBefore,
    this.updatedAfter,
    this.updatedBefore,
    this.minSdkVersion,
    this.maxSdkVersion,
  });

  final List<String> categories;
  final List<String> tags;
  final List<String> authors;
  final List<String> platforms;
  final double? minRating;
  final double? maxRating;
  final int? minDownloads;
  final int? maxDownloads;
  final bool verifiedOnly;
  final bool featuredOnly;
  final bool freeOnly;
  final bool hasDocumentation;
  final bool hasScreenshots;
  final List<String> licenseTypes;
  final DateTime? publishedAfter;
  final DateTime? publishedBefore;
  final DateTime? updatedAfter;
  final DateTime? updatedBefore;
  final String? minSdkVersion;
  final String? maxSdkVersion;

  @override
  String toString() =>
      'PluginSearchFilter(categories: $categories, tags: $tags)';
}

/// 搜索建议
@immutable
class SearchSuggestion {
  const SearchSuggestion({
    required this.text,
    required this.type,
    this.score = 0.0,
    this.metadata = const <String, dynamic>{},
  });

  final String text;
  final SearchSuggestionType type;
  final double score;
  final Map<String, dynamic> metadata;

  @override
  String toString() =>
      'SearchSuggestion(text: $text, type: $type, score: $score)';
}

/// 搜索建议类型
enum SearchSuggestionType {
  keyword,
  category,
  tag,
  author,
  plugin,
}

/// 插件高级搜索引擎 (基于Ming CLI AdvancedSearchEngine设计)
class PluginSearchEngine {
  PluginSearchEngine({
    this.enableFuzzySearch = true,
    this.enableAutoComplete = true,
    this.maxSuggestions = 10,
    this.searchTimeout = const Duration(seconds: 5),
  });

  final bool enableFuzzySearch;
  final bool enableAutoComplete;
  final int maxSuggestions;
  final Duration searchTimeout;

  /// 搜索索引
  final Map<String, Set<String>> _keywordIndex = <String, Set<String>>{};
  final Map<String, Set<String>> _categoryIndex = <String, Set<String>>{};
  final Map<String, Set<String>> _tagIndex = <String, Set<String>>{};
  final Map<String, Set<String>> _authorIndex = <String, Set<String>>{};

  /// 搜索历史
  final List<String> _searchHistory = <String>[];
  final Map<String, int> _searchFrequency = <String, int>{};

  /// 执行高级搜索
  Future<PluginSearchResult> search({
    required List<PluginStoreEntry> plugins,
    String? keyword,
    PluginSearchFilter? filter,
    PluginSortBy sortBy = PluginSortBy.relevance,
    SortOrder sortOrder = SortOrder.descending,
    int offset = 0,
    int limit = 20,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      // 记录搜索历史
      if (keyword != null && keyword.isNotEmpty) {
        _recordSearch(keyword);
      }

      // 应用过滤器
      var filteredPlugins = _applyFilters(plugins, filter);

      // 应用关键词搜索
      if (keyword != null && keyword.isNotEmpty) {
        filteredPlugins = _applyKeywordSearch(filteredPlugins, keyword);
      }

      // 排序
      _sortPlugins(filteredPlugins, sortBy, sortOrder, keyword);

      // 分页
      final totalCount = filteredPlugins.length;
      final paginatedPlugins =
          filteredPlugins.skip(offset).take(limit).toList();

      // 生成搜索建议
      final suggestions = await _generateSuggestions(keyword, plugins);

      // 生成分面信息
      final facets = _generateFacets(filteredPlugins);

      stopwatch.stop();

      return PluginSearchResult(
        plugins: paginatedPlugins,
        totalCount: totalCount,
        query: PluginSearchQuery(
          keyword: keyword,
          sortBy: sortBy,
          sortOrder: sortOrder,
          offset: offset,
          limit: limit,
        ),
        suggestions: suggestions.map((SearchSuggestion s) => s.text).toList(),
        facets: facets,
        searchTime: stopwatch.elapsed,
      );
    } catch (e) {
      stopwatch.stop();
      return PluginSearchResult(
        plugins: const <PluginStoreEntry>[],
        totalCount: 0,
        query: PluginSearchQuery(
          keyword: keyword,
          sortBy: sortBy,
          sortOrder: sortOrder,
          offset: offset,
          limit: limit,
        ),
        searchTime: stopwatch.elapsed,
      );
    }
  }

  /// 获取搜索建议
  Future<List<SearchSuggestion>> getSuggestions(String query) async {
    if (query.isEmpty) {
      return _getPopularSuggestions();
    }

    final suggestions = <SearchSuggestion>[];
    final queryLower = query.toLowerCase();

    // 关键词建议
    suggestions.addAll(_getKeywordSuggestions(queryLower));

    // 分类建议
    suggestions.addAll(_getCategorySuggestions(queryLower));

    // 标签建议
    suggestions.addAll(_getTagSuggestions(queryLower));

    // 作者建议
    suggestions.addAll(_getAuthorSuggestions(queryLower));

    // 插件名称建议
    suggestions.addAll(_getPluginSuggestions(queryLower));

    // 排序和限制数量
    suggestions.sort((SearchSuggestion a, SearchSuggestion b) => b.score.compareTo(a.score));
    return suggestions.take(maxSuggestions).toList();
  }

  /// 构建搜索索引
  void buildIndex(List<PluginStoreEntry> plugins) {
    _clearIndex();

    for (final plugin in plugins) {
      _indexPlugin(plugin);
    }
  }

  /// 应用过滤器
  List<PluginStoreEntry> _applyFilters(
    List<PluginStoreEntry> plugins,
    PluginSearchFilter? filter,
  ) {
    if (filter == null) return plugins;

    return plugins.where((PluginStoreEntry plugin) {
      // 分类过滤
      if (filter.categories.isNotEmpty) {
        if (plugin.category == null ||
            !filter.categories.contains(plugin.category)) {
          return false;
        }
      }

      // 标签过滤
      if (filter.tags.isNotEmpty) {
        if (!filter.tags.any((String tag) => plugin.tags.contains(tag))) {
          return false;
        }
      }

      // 作者过滤
      if (filter.authors.isNotEmpty) {
        if (!filter.authors.contains(plugin.author)) {
          return false;
        }
      }

      // 平台过滤
      if (filter.platforms.isNotEmpty) {
        if (!filter.platforms
            .any((String platform) => plugin.supportedPlatforms.contains(platform))) {
          return false;
        }
      }

      // 评分过滤
      if (filter.minRating != null && plugin.rating < filter.minRating!) {
        return false;
      }
      if (filter.maxRating != null && plugin.rating > filter.maxRating!) {
        return false;
      }

      // 下载量过滤
      if (filter.minDownloads != null &&
          plugin.downloadCount < filter.minDownloads!) {
        return false;
      }
      if (filter.maxDownloads != null &&
          plugin.downloadCount > filter.maxDownloads!) {
        return false;
      }

      // 验证状态过滤
      if (filter.verifiedOnly && !plugin.isVerified) {
        return false;
      }

      // 精选状态过滤
      if (filter.featuredOnly && !plugin.isFeatured) {
        return false;
      }

      // 文档过滤
      if (filter.hasDocumentation && plugin.documentationUrl == null) {
        return false;
      }

      // 截图过滤
      if (filter.hasScreenshots && plugin.screenshots.isEmpty) {
        return false;
      }

      // 许可证过滤
      if (filter.licenseTypes.isNotEmpty) {
        if (plugin.licenseType == null ||
            !filter.licenseTypes.contains(plugin.licenseType)) {
          return false;
        }
      }

      // 发布时间过滤
      if (filter.publishedAfter != null && plugin.publishedAt != null) {
        if (plugin.publishedAt!.isBefore(filter.publishedAfter!)) {
          return false;
        }
      }
      if (filter.publishedBefore != null && plugin.publishedAt != null) {
        if (plugin.publishedAt!.isAfter(filter.publishedBefore!)) {
          return false;
        }
      }

      // 更新时间过滤
      if (filter.updatedAfter != null && plugin.updatedAt != null) {
        if (plugin.updatedAt!.isBefore(filter.updatedAfter!)) {
          return false;
        }
      }
      if (filter.updatedBefore != null && plugin.updatedAt != null) {
        if (plugin.updatedAt!.isAfter(filter.updatedBefore!)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// 应用关键词搜索
  List<PluginStoreEntry> _applyKeywordSearch(
    List<PluginStoreEntry> plugins,
    String keyword,
  ) {
    final keywordLower = keyword.toLowerCase();
    final results = <PluginStoreEntry, double>{};

    for (final plugin in plugins) {
      final score = _calculateRelevanceScore(plugin, keywordLower);
      if (score > 0) {
        results[plugin] = score;
      }
    }

    // 按相关性排序
    final sortedEntries = results.entries.toList()
      ..sort((MapEntry<PluginStoreEntry, double> a, MapEntry<PluginStoreEntry, double> b) => b.value.compareTo(a.value));

    return sortedEntries.map((MapEntry<PluginStoreEntry, double> entry) => entry.key).toList();
  }

  /// 计算相关性评分
  double _calculateRelevanceScore(PluginStoreEntry plugin, String keyword) {
    var score = 0.0;

    // 名称匹配 (权重: 0.4)
    if (plugin.name.toLowerCase().contains(keyword)) {
      if (plugin.name.toLowerCase() == keyword) {
        score += 0.4; // 完全匹配
      } else if (plugin.name.toLowerCase().startsWith(keyword)) {
        score += 0.3; // 前缀匹配
      } else {
        score += 0.2; // 包含匹配
      }
    }

    // 描述匹配 (权重: 0.2)
    if (plugin.description.toLowerCase().contains(keyword)) {
      score += 0.2;
    }

    // 标签匹配 (权重: 0.2)
    for (final tag in plugin.tags) {
      if (tag.toLowerCase().contains(keyword)) {
        score += 0.2;
        break;
      }
    }

    // 分类匹配 (权重: 0.1)
    if (plugin.category?.toLowerCase().contains(keyword) ?? false) {
      score += 0.1;
    }

    // 作者匹配 (权重: 0.1)
    if (plugin.author.toLowerCase().contains(keyword)) {
      score += 0.1;
    }

    // 模糊匹配加分
    if (enableFuzzySearch) {
      final fuzzyScore =
          _calculateFuzzyScore(plugin.name.toLowerCase(), keyword);
      score += fuzzyScore * 0.1;
    }

    return math.min(score, 1);
  }

  /// 计算模糊匹配评分
  double _calculateFuzzyScore(String text, String query) {
    if (text == query) return 1;
    if (text.isEmpty || query.isEmpty) return 0;

    // 使用编辑距离算法
    final matrix = List<List<int>>.generate(
      text.length + 1,
      (int i) => List.filled(query.length + 1, 0),
    );

    for (int i = 0; i <= text.length; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= query.length; j++) {
      matrix[0][j] = j;
    }

    for (int i = 1; i <= text.length; i++) {
      for (int j = 1; j <= query.length; j++) {
        final cost = text[i - 1] == query[j - 1] ? 0 : 1;
        matrix[i][j] = math.min(
          math.min(matrix[i - 1][j] + 1, matrix[i][j - 1] + 1),
          matrix[i - 1][j - 1] + cost,
        );
      }
    }

    final distance = matrix[text.length][query.length];
    final int maxLength = math.max(text.length, query.length);
    return 1.0 - (distance / maxLength);
  }

  /// 排序插件
  void _sortPlugins(
    List<PluginStoreEntry> plugins,
    PluginSortBy sortBy,
    SortOrder sortOrder,
    String? keyword,
  ) {
    plugins.sort((PluginStoreEntry a, PluginStoreEntry b) {
      int comparison = 0;

      switch (sortBy) {
        case PluginSortBy.name:
          comparison = a.name.compareTo(b.name);
        case PluginSortBy.rating:
          comparison = a.rating.compareTo(b.rating);
        case PluginSortBy.downloads:
          comparison = a.downloadCount.compareTo(b.downloadCount);
        case PluginSortBy.published:
          final aDate = a.publishedAt ?? DateTime(1970);
          final bDate = b.publishedAt ?? DateTime(1970);
          comparison = aDate.compareTo(bDate);
        case PluginSortBy.updated:
          final aDate = a.updatedAt ?? DateTime(1970);
          final bDate = b.updatedAt ?? DateTime(1970);
          comparison = aDate.compareTo(bDate);
        case PluginSortBy.relevance:
          if (keyword != null) {
            final aScore = _calculateRelevanceScore(a, keyword.toLowerCase());
            final bScore = _calculateRelevanceScore(b, keyword.toLowerCase());
            comparison = aScore.compareTo(bScore);
          } else {
            // 无关键词时按综合评分排序
            final aScore = _calculateOverallScore(a);
            final bScore = _calculateOverallScore(b);
            comparison = aScore.compareTo(bScore);
          }
      }

      return sortOrder == SortOrder.ascending ? comparison : -comparison;
    });
  }

  /// 计算综合评分
  double _calculateOverallScore(PluginStoreEntry plugin) {
    var score = 0.0;

    // 评分权重: 0.3
    score += 0.3 * (plugin.rating / 5.0);

    // 下载量权重: 0.3
    score += 0.3 * math.min(plugin.downloadCount / 10000.0, 1.0);

    // 验证状态权重: 0.2
    if (plugin.isVerified) score += 0.2;

    // 精选状态权重: 0.1
    if (plugin.isFeatured) score += 0.1;

    // 更新时间权重: 0.1
    if (plugin.updatedAt != null) {
      final daysSinceUpdate =
          DateTime.now().difference(plugin.updatedAt!).inDays;
      if (daysSinceUpdate < 30) {
        score += 0.1;
      } else if (daysSinceUpdate < 90) {
        score += 0.05;
      }
    }

    return math.min(score, 1);
  }

  /// 生成分面信息
  Map<String, List<String>> _generateFacets(List<PluginStoreEntry> plugins) {
    final facets = <String, Map<String, int>>{
      'categories': <String, int>{},
      'tags': <String, int>{},
      'authors': <String, int>{},
      'platforms': <String, int>{},
      'licenses': <String, int>{},
    };

    for (final plugin in plugins) {
      // 分类分面
      if (plugin.category != null) {
        facets['categories']![plugin.category!] =
            (facets['categories']![plugin.category!] ?? 0) + 1;
      }

      // 标签分面
      for (final tag in plugin.tags) {
        facets['tags']![tag] = (facets['tags']![tag] ?? 0) + 1;
      }

      // 作者分面
      facets['authors']![plugin.author] =
          (facets['authors']![plugin.author] ?? 0) + 1;

      // 平台分面
      for (final platform in plugin.supportedPlatforms) {
        facets['platforms']![platform] =
            (facets['platforms']![platform] ?? 0) + 1;
      }

      // 许可证分面
      if (plugin.licenseType != null) {
        facets['licenses']![plugin.licenseType!] =
            (facets['licenses']![plugin.licenseType!] ?? 0) + 1;
      }
    }

    // 转换为排序后的列表
    final result = <String, List<String>>{};
    for (final entry in facets.entries) {
      final sortedEntries = entry.value.entries.toList()
        ..sort((MapEntry<String, int> a, MapEntry<String, int> b) => b.value.compareTo(a.value));
      result[entry.key] = sortedEntries
          .take(10) // 限制每个分面的数量
          .map((MapEntry<String, int> e) => '${e.key} (${e.value})')
          .toList();
    }

    return result;
  }

  /// 记录搜索
  void _recordSearch(String query) {
    _searchHistory.add(query);
    _searchFrequency[query] = (_searchFrequency[query] ?? 0) + 1;

    // 限制历史记录数量
    if (_searchHistory.length > 1000) {
      _searchHistory.removeRange(0, _searchHistory.length - 1000);
    }
  }

  /// 生成搜索建议
  Future<List<SearchSuggestion>> _generateSuggestions(
    String? keyword,
    List<PluginStoreEntry> plugins,
  ) async {
    if (keyword == null || keyword.isEmpty) {
      return _getPopularSuggestions();
    }

    return getSuggestions(keyword);
  }

  /// 获取流行建议
  List<SearchSuggestion> _getPopularSuggestions() {
    final suggestions = <SearchSuggestion>[];

    // 基于搜索频率的建议
    final sortedQueries = _searchFrequency.entries.toList()
      ..sort((MapEntry<String, int> a, MapEntry<String, int> b) => b.value.compareTo(a.value));

    for (final entry in sortedQueries.take(5)) {
      suggestions.add(SearchSuggestion(
        text: entry.key,
        type: SearchSuggestionType.keyword,
        score: entry.value.toDouble(),
        metadata: <String, dynamic>{'frequency': entry.value},
      ),);
    }

    return suggestions;
  }

  /// 获取关键词建议
  List<SearchSuggestion> _getKeywordSuggestions(String query) {
    final suggestions = <SearchSuggestion>[];

    for (final entry in _searchFrequency.entries) {
      if (entry.key.toLowerCase().contains(query)) {
        suggestions.add(SearchSuggestion(
          text: entry.key,
          type: SearchSuggestionType.keyword,
          score: entry.value.toDouble(),
          metadata: <String, dynamic>{'frequency': entry.value},
        ),);
      }
    }

    return suggestions;
  }

  /// 获取分类建议
  List<SearchSuggestion> _getCategorySuggestions(String query) {
    final suggestions = <SearchSuggestion>[];

    for (final entry in _categoryIndex.entries) {
      if (entry.key.toLowerCase().contains(query)) {
        suggestions.add(SearchSuggestion(
          text: entry.key,
          type: SearchSuggestionType.category,
          score: entry.value.length.toDouble(),
          metadata: <String, dynamic>{'plugin_count': entry.value.length},
        ),);
      }
    }

    return suggestions;
  }

  /// 获取标签建议
  List<SearchSuggestion> _getTagSuggestions(String query) {
    final suggestions = <SearchSuggestion>[];

    for (final entry in _tagIndex.entries) {
      if (entry.key.toLowerCase().contains(query)) {
        suggestions.add(SearchSuggestion(
          text: entry.key,
          type: SearchSuggestionType.tag,
          score: entry.value.length.toDouble(),
          metadata: <String, dynamic>{'plugin_count': entry.value.length},
        ),);
      }
    }

    return suggestions;
  }

  /// 获取作者建议
  List<SearchSuggestion> _getAuthorSuggestions(String query) {
    final suggestions = <SearchSuggestion>[];

    for (final entry in _authorIndex.entries) {
      if (entry.key.toLowerCase().contains(query)) {
        suggestions.add(SearchSuggestion(
          text: entry.key,
          type: SearchSuggestionType.author,
          score: entry.value.length.toDouble(),
          metadata: <String, dynamic>{'plugin_count': entry.value.length},
        ),);
      }
    }

    return suggestions;
  }

  /// 获取插件建议
  List<SearchSuggestion> _getPluginSuggestions(String query) {
    final suggestions = <SearchSuggestion>[];

    for (final entry in _keywordIndex.entries) {
      if (entry.key.toLowerCase().contains(query)) {
        suggestions.add(SearchSuggestion(
          text: entry.key,
          type: SearchSuggestionType.plugin,
          score: 1,
          metadata: <String, dynamic>{'plugin_ids': entry.value.toList()},
        ),);
      }
    }

    return suggestions;
  }

  /// 索引插件
  void _indexPlugin(PluginStoreEntry plugin) {
    // 索引名称
    _addToIndex(_keywordIndex, plugin.name.toLowerCase(), plugin.id);

    // 索引描述关键词
    final descriptionWords = plugin.description.toLowerCase().split(' ');
    for (final word in descriptionWords) {
      if (word.length > 2) {
        _addToIndex(_keywordIndex, word, plugin.id);
      }
    }

    // 索引分类
    if (plugin.category != null) {
      _addToIndex(_categoryIndex, plugin.category!.toLowerCase(), plugin.id);
    }

    // 索引标签
    for (final tag in plugin.tags) {
      _addToIndex(_tagIndex, tag.toLowerCase(), plugin.id);
    }

    // 索引作者
    _addToIndex(_authorIndex, plugin.author.toLowerCase(), plugin.id);
  }

  /// 添加到索引
  void _addToIndex(Map<String, Set<String>> index, String key, String value) {
    index.putIfAbsent(key, () => <String>{}).add(value);
  }

  /// 清理索引
  void _clearIndex() {
    _keywordIndex.clear();
    _categoryIndex.clear();
    _tagIndex.clear();
    _authorIndex.clear();
  }

  /// 获取搜索历史
  List<String> getSearchHistory() => List.from(_searchHistory.reversed.take(20));

  /// 清理搜索历史
  void clearSearchHistory() {
    _searchHistory.clear();
    _searchFrequency.clear();
  }
}
