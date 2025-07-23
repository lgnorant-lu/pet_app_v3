/*
---------------------------------------------------------------
File name:          plugin_store_manager.dart
Author:             lgnorant-lu
Date created:       2025-07-23
Last modified:      2025-07-23
Dart Version:       3.2+
Description:        插件商店管理器 - 整合商店注册表和API功能
---------------------------------------------------------------
Change History:
    2025-07-23: Task 2.1.1 - 创建插件商店管理器;
---------------------------------------------------------------
*/

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

import 'package:dio/dio.dart';

import 'package:plugin_system/src/store/plugin_store_api.dart';
import 'package:plugin_system/src/store/plugin_store_models.dart';
import 'package:plugin_system/src/store/plugin_store_registry.dart';

/// 插件商店管理器 (整合注册表和API功能)
class PluginStoreManager {
  PluginStoreManager({
    required this.registryPath,
    this.defaultStores = const <PluginStore>[],
  }) {
    _registry = PluginStoreRegistry(registryPath: registryPath);
    _initializeDefaultStores();
  }

  /// 注册表路径
  final String registryPath;

  /// 默认商店列表
  final List<PluginStore> defaultStores;

  /// 商店注册表
  late final PluginStoreRegistry _registry;

  /// API客户端缓存
  final Map<String, PluginStoreApi> _apiClients = <String, PluginStoreApi>{};

  /// 单例实例
  static PluginStoreManager? _instance;

  /// 获取单例实例
  static PluginStoreManager get instance {
    _instance ??= PluginStoreManager(
      registryPath: kIsWeb
          ? '/plugin_stores'
          : path.join(Directory.current.path, '.plugin_stores'),
      defaultStores: _getDefaultStores(),
    );
    return _instance!;
  }

  /// 搜索插件 (聚合所有商店的结果)
  Future<PluginSearchResult> searchPlugins(PluginSearchQuery query) async {
    try {
      // 从注册表搜索
      final registryResult = await _registry.searchPlugins(query);

      // 从远程API搜索
      final apiResults = await _searchFromApis(query);

      // 合并结果
      final allPlugins = <PluginStoreEntry>[
        ...registryResult.plugins,
        ...apiResults,
      ];

      // 去重 (基于插件ID和版本)
      final uniquePlugins = _deduplicatePlugins(allPlugins);

      // 重新排序
      _sortPlugins(uniquePlugins, query.sortBy, query.sortOrder);

      // 应用分页
      final totalCount = uniquePlugins.length;
      final startIndex = query.offset;
      final endIndex = (startIndex + query.limit).clamp(0, totalCount);

      final paginatedPlugins = startIndex < totalCount
          ? uniquePlugins.sublist(startIndex, endIndex)
          : <PluginStoreEntry>[];

      return PluginSearchResult(
        plugins: paginatedPlugins,
        totalCount: totalCount,
        query: query,
        suggestions: registryResult.suggestions,
        searchTime: registryResult.searchTime,
      );
    } catch (e) {
      debugPrint('搜索插件失败: $e');
      return PluginSearchResult(
        plugins: const <PluginStoreEntry>[],
        totalCount: 0,
        query: query,
      );
    }
  }

  /// 获取插件详情
  Future<PluginStoreEntry?> getPluginDetails(
    String pluginId, {
    String? storeId,
  }) async {
    try {
      // 优先从注册表获取
      final registryEntry = await _registry.getPluginDetails(
        pluginId,
        storeId: storeId,
      );
      if (registryEntry != null) {
        return registryEntry;
      }

      // 从API获取
      if (storeId != null) {
        final store = await _registry.getStore(storeId);
        if (store != null) {
          final api = _getApiClient(store);
          return await api.getPluginDetails(pluginId);
        }
      } else {
        // 尝试所有启用的商店
        final stores = await _registry.getRegisteredStores();
        for (final store in stores) {
          try {
            final api = _getApiClient(store);
            final entry = await api.getPluginDetails(pluginId);
            if (entry != null) {
              return entry;
            }
          } catch (e) {
            debugPrint('从商店 ${store.name} 获取插件详情失败: $e');
          }
        }
      }

      return null;
    } catch (e) {
      debugPrint('获取插件详情失败: $e');
      return null;
    }
  }

  /// 下载插件
  Future<bool> downloadPlugin(
    String pluginId,
    String version,
    String savePath, {
    String? storeId,
    ProgressCallback? onProgress,
  }) async {
    try {
      final stores = storeId != null
          ? <PluginStore?>[await _registry.getStore(storeId)]
              .whereType<PluginStore>()
              .toList()
          : await _registry.getRegisteredStores();

      for (final store in stores) {
        try {
          final api = _getApiClient(store);
          await api.downloadPlugin(
            pluginId,
            version,
            savePath,
            onProgress: onProgress,
          );
          return true;
        } catch (e) {
          debugPrint('从商店 ${store.name} 下载插件失败: $e');
        }
      }

      return false;
    } catch (e) {
      debugPrint('下载插件失败: $e');
      return false;
    }
  }

  /// 获取热门插件
  Future<List<PluginStoreEntry>> getFeaturedPlugins({int limit = 10}) async {
    try {
      final allFeatured = <PluginStoreEntry>[];
      final stores = await _registry.getRegisteredStores();

      for (final store in stores) {
        try {
          final api = _getApiClient(store);
          final featured = await api.getFeaturedPlugins(limit: limit);
          allFeatured.addAll(featured);
        } catch (e) {
          debugPrint('从商店 ${store.name} 获取热门插件失败: $e');
        }
      }

      // 去重并限制数量
      final uniqueFeatured = _deduplicatePlugins(allFeatured);
      return uniqueFeatured.take(limit).toList();
    } catch (e) {
      debugPrint('获取热门插件失败: $e');
      return <PluginStoreEntry>[];
    }
  }

  /// 获取最新插件
  Future<List<PluginStoreEntry>> getLatestPlugins({int limit = 10}) async {
    try {
      final allLatest = <PluginStoreEntry>[];
      final stores = await _registry.getRegisteredStores();

      for (final store in stores) {
        try {
          final api = _getApiClient(store);
          final latest = await api.getLatestPlugins(limit: limit);
          allLatest.addAll(latest);
        } catch (e) {
          debugPrint('从商店 ${store.name} 获取最新插件失败: $e');
        }
      }

      // 按更新时间排序并限制数量
      allLatest.sort(
        (PluginStoreEntry a, PluginStoreEntry b) =>
            (b.updatedAt ?? DateTime(0)).compareTo(a.updatedAt ?? DateTime(0)),
      );

      final uniqueLatest = _deduplicatePlugins(allLatest);
      return uniqueLatest.take(limit).toList();
    } catch (e) {
      debugPrint('获取最新插件失败: $e');
      return <PluginStoreEntry>[];
    }
  }

  /// 注册商店
  Future<void> registerStore(PluginStore store) async {
    await _registry.registerStore(store);
  }

  /// 获取已注册的商店
  Future<List<PluginStore>> getRegisteredStores({
    bool enabledOnly = true,
  }) async =>
      _registry.getRegisteredStores(enabledOnly: enabledOnly);

  /// 同步商店数据
  Future<void> syncStore(String storeId) async {
    await _registry.syncStore(storeId);
  }

  /// 同步所有商店
  Future<void> syncAllStores() async {
    final stores = await _registry.getRegisteredStores();
    for (final store in stores) {
      try {
        await _registry.syncStore(store.id);
      } catch (e) {
        debugPrint('同步商店 ${store.name} 失败: $e');
      }
    }
  }

  /// 清理缓存
  void clearCache() {
    _registry.clearCache();
    for (final api in _apiClients.values) {
      api.clearCache();
    }
  }

  /// 释放资源
  void dispose() {
    for (final api in _apiClients.values) {
      api.dispose();
    }
    _apiClients.clear();
  }

  /// 初始化默认商店
  Future<void> _initializeDefaultStores() async {
    for (final store in defaultStores) {
      try {
        final existingStore = await _registry.getStore(store.id);
        if (existingStore == null) {
          await _registry.registerStore(store);
        }
      } catch (e) {
        debugPrint('初始化默认商店失败: ${store.name}, $e');
      }
    }
  }

  /// 从API搜索
  Future<List<PluginStoreEntry>> _searchFromApis(
    PluginSearchQuery query,
  ) async {
    final results = <PluginStoreEntry>[];
    final stores = await _registry.getRegisteredStores();

    for (final store in stores) {
      if (store.type == PluginStoreType.local) continue;

      try {
        final api = _getApiClient(store);
        final searchResult = await api.searchPlugins(query);
        results.addAll(searchResult.plugins);
      } catch (e) {
        debugPrint('从商店 ${store.name} 搜索失败: $e');
      }
    }

    return results;
  }

  /// 获取API客户端
  PluginStoreApi _getApiClient(PluginStore store) => _apiClients.putIfAbsent(
        store.id,
        () => PluginStoreApi(
          baseUrl: store.url,
          headers: <String, String>{
            'X-Store-Id': store.id,
            'X-Store-Type': store.type.name,
          },
        ),
      );

  /// 去重插件
  List<PluginStoreEntry> _deduplicatePlugins(List<PluginStoreEntry> plugins) {
    final seen = <String>{};
    return plugins.where((PluginStoreEntry plugin) {
      final key = '${plugin.id}:${plugin.version}';
      if (seen.contains(key)) {
        return false;
      }
      seen.add(key);
      return true;
    }).toList();
  }

  /// 排序插件
  void _sortPlugins(
    List<PluginStoreEntry> plugins,
    PluginSortBy sortBy,
    SortOrder sortOrder,
  ) {
    plugins.sort((PluginStoreEntry a, PluginStoreEntry b) {
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

  /// 获取默认商店列表
  static List<PluginStore> _getDefaultStores() => <PluginStore>[
        const PluginStore(
          id: 'official',
          name: 'Pet App Official Store',
          url: 'https://plugins.petapp.dev',
          type: PluginStoreType.official,
          description: 'Pet App官方插件商店',
          isOfficial: true,
          priority: 100,
        ),
        const PluginStore(
          id: 'community',
          name: 'Pet App Community Store',
          url: 'https://community.petapp.dev',
          type: PluginStoreType.community,
          description: 'Pet App社区插件商店',
          priority: 80,
        ),
      ];
}

/// 扩展方法
extension on double {
  double log() => math.log(this);
}
