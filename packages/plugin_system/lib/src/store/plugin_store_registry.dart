/*
---------------------------------------------------------------
File name:          plugin_store_registry.dart
Author:             lgnorant-lu
Date created:       2025-07-23
Last modified:      2025-07-23
Dart Version:       3.2+
Description:        插件商店注册表管理器 - 基于Ming CLI TemplateRegistry设计
---------------------------------------------------------------
Change History:
    2025-07-23: Task 2.1.1 - 创建插件商店注册表管理器;
---------------------------------------------------------------
*/

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

import 'package:plugin_system/src/store/plugin_store_models.dart';

/// 插件商店注册表管理器 (基于Ming CLI TemplateRegistry设计)
class PluginStoreRegistry {
  PluginStoreRegistry({
    required this.registryPath,
    this.cacheEnabled = true,
    this.cacheTtl = const Duration(hours: 1),
    this.maxCacheSize = 1000,
  }) {
    _initializeRegistry();
  }

  /// 注册表路径
  final String registryPath;

  /// 是否启用缓存
  final bool cacheEnabled;

  /// 缓存TTL
  final Duration cacheTtl;

  /// 最大缓存大小
  final int maxCacheSize;

  /// 商店缓存
  final Map<String, PluginStore> _storeCache = <String, PluginStore>{};

  /// 插件条目缓存
  final Map<String, PluginStoreEntry> _entryCache =
      <String, PluginStoreEntry>{};

  /// 缓存时间戳
  final Map<String, DateTime> _cacheTimestamps = <String, DateTime>{};

  /// 是否已初始化
  bool _isInitialized = false;

  /// 初始化注册表
  Future<void> _initializeRegistry() async {
    if (_isInitialized) return;

    try {
      if (!kIsWeb) {
        // 确保注册表目录存在 (仅在非Web环境)
        final registryDir = Directory(registryPath);
        if (!await registryDir.exists()) {
          await registryDir.create(recursive: true);
        }
      }

      // 加载已注册的商店
      await _loadRegisteredStores();

      // 构建搜索索引
      await _buildSearchIndex();

      _isInitialized = true;
      debugPrint('插件商店注册表初始化完成: $registryPath');
    } catch (e) {
      debugPrint('插件商店注册表初始化失败: $e');
      rethrow;
    }
  }

  /// 注册插件商店
  Future<void> registerStore(PluginStore store) async {
    await _ensureInitialized();

    try {
      // 验证商店信息
      _validateStore(store);

      // 保存商店信息
      await _saveStoreMetadata(store);

      // 更新缓存
      if (cacheEnabled) {
        _storeCache[store.id] = store;
        _cacheTimestamps[store.id] = DateTime.now();
      }

      debugPrint('插件商店注册成功: ${store.name} (${store.id})');
    } catch (e) {
      debugPrint('插件商店注册失败: $e');
      rethrow;
    }
  }

  /// 获取所有注册的商店
  Future<List<PluginStore>> getRegisteredStores({
    bool enabledOnly = true,
  }) async {
    await _ensureInitialized();

    try {
      final stores = <PluginStore>[];

      if (!kIsWeb) {
        final storesDir = Directory(path.join(registryPath, 'stores'));

        if (await storesDir.exists()) {
          await for (final FileSystemEntity entity in storesDir.list()) {
            if (entity is File && entity.path.endsWith('.json')) {
              final store = await _loadStoreFromFile(entity);
              if (store != null && (!enabledOnly || store.isEnabled)) {
                stores.add(store);
              }
            }
          }
        }
      }

      // 按优先级排序
      stores.sort(
          (PluginStore a, PluginStore b) => b.priority.compareTo(a.priority));
      return stores;
    } catch (e) {
      debugPrint('获取注册商店失败: $e');
      return <PluginStore>[];
    }
  }

  /// 搜索插件
  Future<PluginSearchResult> searchPlugins(PluginSearchQuery query) async {
    await _ensureInitialized();

    final startTime = DateTime.now();
    try {
      // 获取所有启用的商店
      final stores = await getRegisteredStores();

      // 从指定商店搜索
      final targetStores = query.storeIds.isNotEmpty
          ? stores
              .where((PluginStore store) => query.storeIds.contains(store.id))
              .toList()
          : stores;

      // 收集所有插件条目
      final allEntries = <PluginStoreEntry>[];
      for (final store in targetStores) {
        final entries = await _getStoreEntries(store.id);
        allEntries.addAll(entries);
      }

      // 应用过滤条件
      var filteredEntries = _applyFilters(allEntries, query);

      // 应用排序
      _sortEntries(filteredEntries, query.sortBy, query.sortOrder);

      // 应用分页
      final totalCount = filteredEntries.length;
      final startIndex = query.offset;
      final endIndex = (startIndex + query.limit).clamp(0, totalCount);

      if (startIndex < totalCount) {
        filteredEntries = filteredEntries.sublist(startIndex, endIndex);
      } else {
        filteredEntries = <PluginStoreEntry>[];
      }

      final searchTime = DateTime.now().difference(startTime);

      return PluginSearchResult(
        plugins: filteredEntries,
        totalCount: totalCount,
        query: query,
        suggestions: _generateSearchSuggestions(query, allEntries),
        searchTime: searchTime,
      );
    } catch (e) {
      debugPrint('插件搜索失败: $e');
      return PluginSearchResult(
        plugins: const <PluginStoreEntry>[],
        totalCount: 0,
        query: query,
        searchTime: DateTime.now().difference(startTime),
      );
    }
  }

  /// 获取插件详情
  Future<PluginStoreEntry?> getPluginDetails(
    String pluginId, {
    String? storeId,
  }) async {
    await _ensureInitialized();

    try {
      // 检查缓存
      if (cacheEnabled && _entryCache.containsKey(pluginId)) {
        final timestamp = _cacheTimestamps[pluginId];
        if (timestamp != null &&
            DateTime.now().difference(timestamp) < cacheTtl) {
          return _entryCache[pluginId];
        }
      }

      // 从商店加载
      final stores = storeId != null
          ? <PluginStore?>[await getStore(storeId)]
              .whereType<PluginStore>()
              .toList()
          : await getRegisteredStores();

      for (final store in stores) {
        final entries = await _getStoreEntries(store.id);
        final entry =
            entries.where((PluginStoreEntry e) => e.id == pluginId).firstOrNull;
        if (entry != null) {
          // 更新缓存
          if (cacheEnabled) {
            _entryCache[pluginId] = entry;
            _cacheTimestamps[pluginId] = DateTime.now();
          }
          return entry;
        }
      }

      return null;
    } catch (e) {
      debugPrint('获取插件详情失败: $e');
      return null;
    }
  }

  /// 获取指定商店
  Future<PluginStore?> getStore(String storeId) async {
    await _ensureInitialized();

    try {
      // 检查缓存
      if (cacheEnabled && _storeCache.containsKey(storeId)) {
        final timestamp = _cacheTimestamps[storeId];
        if (timestamp != null &&
            DateTime.now().difference(timestamp) < cacheTtl) {
          return _storeCache[storeId];
        }
      }

      // 从文件加载 (仅在非Web环境)
      if (!kIsWeb) {
        final storeFile =
            File(path.join(registryPath, 'stores', '$storeId.json'));
        if (await storeFile.exists()) {
          return await _loadStoreFromFile(storeFile);
        }
      }

      return null;
    } catch (e) {
      debugPrint('获取商店信息失败: $e');
      return null;
    }
  }

  /// 同步商店数据
  Future<void> syncStore(String storeId) async {
    await _ensureInitialized();

    try {
      final store = await getStore(storeId);
      if (store == null) {
        throw Exception('商店不存在: $storeId');
      }

      debugPrint('开始同步商店: ${store.name}');

      // TODO: 实现具体的同步逻辑
      // 这里应该从远程商店API获取最新的插件列表

      // 更新最后同步时间
      final updatedStore = PluginStore(
        id: store.id,
        name: store.name,
        url: store.url,
        type: store.type,
        description: store.description,
        isOfficial: store.isOfficial,
        isEnabled: store.isEnabled,
        priority: store.priority,
        lastSync: DateTime.now(),
        pluginCount: store.pluginCount,
        metadata: store.metadata,
      );

      await _saveStoreMetadata(updatedStore);

      debugPrint('商店同步完成: ${store.name}');
    } catch (e) {
      debugPrint('商店同步失败: $e');
      rethrow;
    }
  }

  /// 清理缓存
  void clearCache() {
    _storeCache.clear();
    _entryCache.clear();
    _cacheTimestamps.clear();
    debugPrint('插件商店缓存已清理');
  }

  /// 确保已初始化
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await _initializeRegistry();
    }
  }

  /// 验证商店信息
  void _validateStore(PluginStore store) {
    if (store.id.isEmpty) {
      throw ArgumentError('商店ID不能为空');
    }
    if (store.name.isEmpty) {
      throw ArgumentError('商店名称不能为空');
    }
    if (store.url.isEmpty) {
      throw ArgumentError('商店URL不能为空');
    }
  }

  /// 保存商店元数据
  Future<void> _saveStoreMetadata(PluginStore store) async {
    if (kIsWeb) {
      // Web环境下跳过文件系统操作
      return;
    }

    final storesDir = Directory(path.join(registryPath, 'stores'));
    if (!await storesDir.exists()) {
      await storesDir.create(recursive: true);
    }

    final storeFile = File(path.join(storesDir.path, '${store.id}.json'));
    await storeFile.writeAsString(
      const JsonEncoder.withIndent('  ').convert(store.toJson()),
    );
  }

  /// 加载已注册的商店
  Future<void> _loadRegisteredStores() async {
    if (kIsWeb) {
      // Web环境下跳过文件系统操作
      return;
    }

    final storesDir = Directory(path.join(registryPath, 'stores'));
    if (!await storesDir.exists()) {
      return;
    }

    await for (final FileSystemEntity entity in storesDir.list()) {
      if (entity is File && entity.path.endsWith('.json')) {
        final store = await _loadStoreFromFile(entity);
        if (store != null && cacheEnabled) {
          _storeCache[store.id] = store;
          _cacheTimestamps[store.id] = DateTime.now();
        }
      }
    }
  }

  /// 从文件加载商店
  Future<PluginStore?> _loadStoreFromFile(File file) async {
    try {
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      return PluginStore.fromJson(json);
    } catch (e) {
      debugPrint('加载商店文件失败: ${file.path}, $e');
      return null;
    }
  }

  /// 获取商店条目
  Future<List<PluginStoreEntry>> _getStoreEntries(String storeId) async {
    // TODO: 实现从商店加载插件条目的逻辑
    // 这里应该从本地缓存或远程API获取插件列表
    return <PluginStoreEntry>[];
  }

  /// 应用过滤条件
  List<PluginStoreEntry> _applyFilters(
    List<PluginStoreEntry> entries,
    PluginSearchQuery query,
  ) =>
      entries.where((PluginStoreEntry entry) {
        // 关键词过滤
        if (query.keyword != null && query.keyword!.isNotEmpty) {
          final String keyword = query.keyword!.toLowerCase();
          if (!entry.name.toLowerCase().contains(keyword) &&
              !entry.description.toLowerCase().contains(keyword) &&
              !entry.tags
                  .any((String tag) => tag.toLowerCase().contains(keyword))) {
            return false;
          }
        }

        // 分类过滤
        if (query.category != null && entry.category != query.category) {
          return false;
        }

        // 标签过滤
        if (query.tags.isNotEmpty &&
            !query.tags.any((String tag) => entry.tags.contains(tag))) {
          return false;
        }

        // 作者过滤
        if (query.author != null && entry.author != query.author) {
          return false;
        }

        // 评分过滤
        if (query.minRating != null && entry.rating < query.minRating!) {
          return false;
        }

        // 平台过滤
        if (query.platforms.isNotEmpty &&
            !query.platforms.any((String platform) =>
                entry.supportedPlatforms.contains(platform))) {
          return false;
        }

        // 验证状态过滤
        if (query.onlyVerified && !entry.isVerified) {
          return false;
        }

        // 精选状态过滤
        if (query.onlyFeatured && !entry.isFeatured) {
          return false;
        }

        return true;
      }).toList();

  /// 排序条目
  void _sortEntries(
    List<PluginStoreEntry> entries,
    PluginSortBy sortBy,
    SortOrder sortOrder,
  ) {
    entries.sort((PluginStoreEntry a, PluginStoreEntry b) {
      int comparison;
      switch (sortBy) {
        case PluginSortBy.name:
          comparison = a.name.compareTo(b.name);
        case PluginSortBy.rating:
          comparison = a.rating.compareTo(b.rating);
        case PluginSortBy.downloads:
          comparison = a.downloadCount.compareTo(b.downloadCount);
        case PluginSortBy.published:
          comparison = (a.publishedAt ?? DateTime(0))
              .compareTo(b.publishedAt ?? DateTime(0));
        case PluginSortBy.updated:
          comparison = (a.updatedAt ?? DateTime(0))
              .compareTo(b.updatedAt ?? DateTime(0));
        case PluginSortBy.relevance:
          // 相关性排序：精选 > 验证 > 评分 > 下载量
          comparison = _calculateRelevanceScore(b)
              .compareTo(_calculateRelevanceScore(a));
      }

      return sortOrder == SortOrder.ascending ? comparison : -comparison;
    });
  }

  /// 计算相关性评分
  double _calculateRelevanceScore(PluginStoreEntry entry) {
    double score = 0.0;

    // 精选插件加分
    if (entry.isFeatured) score += 100.0;

    // 验证插件加分
    if (entry.isVerified) score += 50.0;

    // 评分加分
    score += entry.rating * 10.0;

    // 下载量加分 (对数缩放)
    if (entry.downloadCount > 0) {
      score += (entry.downloadCount + 1).toDouble().log() * 5.0;
    }

    return score;
  }

  /// 生成搜索建议
  List<String> _generateSearchSuggestions(
    PluginSearchQuery query,
    List<PluginStoreEntry> allEntries,
  ) {
    // TODO: 实现智能搜索建议
    return <String>[];
  }

  /// 构建搜索索引
  Future<void> _buildSearchIndex() async {
    // TODO: 实现搜索索引构建
  }
}

/// 扩展方法
extension on double {
  double log() => math.log(this);
}
