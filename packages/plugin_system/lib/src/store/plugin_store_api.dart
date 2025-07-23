/*
---------------------------------------------------------------
File name:          plugin_store_api.dart
Author:             lgnorant-lu
Date created:       2025-07-23
Last modified:      2025-07-23
Dart Version:       3.2+
Description:        插件商店API接口 - 基于Ming CLI网络通信设计
---------------------------------------------------------------
Change History:
    2025-07-23: Task 2.1.1 - 创建插件商店API接口;
---------------------------------------------------------------
*/

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:plugin_system/src/store/plugin_store_models.dart';

/// 插件商店API客户端 (基于Ming CLI网络通信设计)
class PluginStoreApi {
  PluginStoreApi({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 30),
    this.retryCount = 3,
    this.enableCache = true,
    Map<String, String>? headers,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: timeout,
        receiveTimeout: timeout,
        headers: <String, dynamic>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'PetApp-PluginSystem/1.0.0',
          ...?headers,
        },
      ),
    );

    // 添加拦截器
    _dio.interceptors.add(_createRetryInterceptor());
    if (enableCache) {
      _dio.interceptors.add(_createCacheInterceptor());
    }
    _dio.interceptors.add(_createLoggingInterceptor());
  }

  /// API基础URL
  final String baseUrl;

  /// 请求超时时间
  final Duration timeout;

  /// 重试次数
  final int retryCount;

  /// 是否启用缓存
  final bool enableCache;

  /// Dio实例
  late final Dio _dio;

  /// 缓存存储
  final Map<String, _CacheEntry> _cache = <String, _CacheEntry>{};

  /// 搜索插件
  Future<PluginSearchResult> searchPlugins(PluginSearchQuery query) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/plugins/search',
        queryParameters: _buildSearchParams(query),
      );

      if (response.data == null) {
        throw Exception('API返回数据为空');
      }

      return PluginSearchResult.fromJson(response.data!);
    } catch (e) {
      debugPrint('搜索插件失败: $e');
      rethrow;
    }
  }

  /// 获取插件详情
  Future<PluginStoreEntry?> getPluginDetails(String pluginId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/plugins/$pluginId',
      );

      if (response.data == null) {
        return null;
      }

      return PluginStoreEntry.fromJson(response.data!);
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return null;
      }
      debugPrint('获取插件详情失败: $e');
      rethrow;
    }
  }

  /// 获取插件版本列表
  Future<List<String>> getPluginVersions(String pluginId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/plugins/$pluginId/versions',
      );

      if (response.data == null) {
        return <String>[];
      }

      final versions = response.data!['versions'] as List<dynamic>?;
      return versions?.cast<String>() ?? <String>[];
    } catch (e) {
      debugPrint('获取插件版本失败: $e');
      return <String>[];
    }
  }

  /// 下载插件
  Future<void> downloadPlugin(
    String pluginId,
    String version,
    String savePath, {
    ProgressCallback? onProgress,
  }) async {
    try {
      await _dio.download(
        '/plugins/$pluginId/download',
        savePath,
        queryParameters: <String, dynamic>{'version': version},
        onReceiveProgress: onProgress,
      );
    } catch (e) {
      debugPrint('下载插件失败: $e');
      rethrow;
    }
  }

  /// 获取分类列表
  Future<List<String>> getCategories() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/categories');

      if (response.data == null) {
        return <String>[];
      }

      final categories = response.data!['categories'] as List<dynamic>?;
      return categories?.cast<String>() ?? <String>[];
    } catch (e) {
      debugPrint('获取分类列表失败: $e');
      return <String>[];
    }
  }

  /// 获取热门插件
  Future<List<PluginStoreEntry>> getFeaturedPlugins({int limit = 10}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/plugins/featured',
        queryParameters: <String, dynamic>{'limit': limit},
      );

      if (response.data == null) {
        return <PluginStoreEntry>[];
      }

      final plugins = response.data!['plugins'] as List<dynamic>?;
      return plugins
              ?.map(
                (json) =>
                    PluginStoreEntry.fromJson(json as Map<String, dynamic>),
              )
              .toList() ??
          <PluginStoreEntry>[];
    } catch (e) {
      debugPrint('获取热门插件失败: $e');
      return <PluginStoreEntry>[];
    }
  }

  /// 获取最新插件
  Future<List<PluginStoreEntry>> getLatestPlugins({int limit = 10}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/plugins/latest',
        queryParameters: <String, dynamic>{'limit': limit},
      );

      if (response.data == null) {
        return <PluginStoreEntry>[];
      }

      final plugins = response.data!['plugins'] as List<dynamic>?;
      return plugins
              ?.map(
                (json) =>
                    PluginStoreEntry.fromJson(json as Map<String, dynamic>),
              )
              .toList() ??
          <PluginStoreEntry>[];
    } catch (e) {
      debugPrint('获取最新插件失败: $e');
      return <PluginStoreEntry>[];
    }
  }

  /// 提交插件评价
  Future<bool> submitReview(
    String pluginId,
    double rating,
    String comment,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/plugins/$pluginId/reviews',
        data: <String, Object>{
          'rating': rating,
          'comment': comment,
        },
      );

      return response.statusCode == 201;
    } catch (e) {
      debugPrint('提交评价失败: $e');
      return false;
    }
  }

  /// 获取插件评价
  Future<List<Map<String, dynamic>>> getPluginReviews(
    String pluginId, {
    int offset = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/plugins/$pluginId/reviews',
        queryParameters: <String, dynamic>{
          'offset': offset,
          'limit': limit,
        },
      );

      if (response.data == null) {
        return <Map<String, dynamic>>[];
      }

      final reviews = response.data!['reviews'] as List<dynamic>?;
      return reviews?.cast<Map<String, dynamic>>() ?? <Map<String, dynamic>>[];
    } catch (e) {
      debugPrint('获取插件评价失败: $e');
      return <Map<String, dynamic>>[];
    }
  }

  /// 构建搜索参数
  Map<String, dynamic> _buildSearchParams(PluginSearchQuery query) {
    final params = <String, dynamic>{};

    if (query.keyword != null) params['q'] = query.keyword;
    if (query.category != null) params['category'] = query.category;
    if (query.tags.isNotEmpty) params['tags'] = query.tags.join(',');
    if (query.author != null) params['author'] = query.author;
    if (query.minRating != null) params['min_rating'] = query.minRating;
    if (query.platforms.isNotEmpty) {
      params['platforms'] = query.platforms.join(',');
    }

    params['sort_by'] = query.sortBy.name;
    params['sort_order'] = query.sortOrder.name;
    params['offset'] = query.offset;
    params['limit'] = query.limit;

    if (query.includePrerelease) params['include_prerelease'] = true;
    if (query.onlyVerified) params['only_verified'] = true;
    if (query.onlyFeatured) params['only_featured'] = true;

    return params;
  }

  /// 创建重试拦截器
  Interceptor _createRetryInterceptor() => InterceptorsWrapper(
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.sendTimeout) {
            // 实现重试逻辑
            for (var i = 0; i < retryCount; i++) {
              try {
                await Future<void>.delayed(Duration(seconds: i + 1));
                final Response<dynamic> response =
                    await _dio.fetch<dynamic>(error.requestOptions);
                handler.resolve(response);
                return;
              } catch (e) {
                if (i == retryCount - 1) {
                  handler.next(error);
                  return;
                }
              }
            }
          }
          handler.next(error);
        },
      );

  /// 创建缓存拦截器
  Interceptor _createCacheInterceptor() => InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          if (options.method == 'GET') {
            final String cacheKey = _generateCacheKey(options);
            final _CacheEntry? cacheEntry = _cache[cacheKey];
            if (cacheEntry != null && !cacheEntry.isExpired) {
              handler.resolve(
                Response(
                  requestOptions: options,
                  data: cacheEntry.data,
                  statusCode: 200,
                ),
              );
              return;
            }
          }
          handler.next(options);
        },
        onResponse:
            (Response<dynamic> response, ResponseInterceptorHandler handler) {
          if (response.requestOptions.method == 'GET' &&
              response.statusCode == 200) {
            final String cacheKey = _generateCacheKey(response.requestOptions);
            _cache[cacheKey] = _CacheEntry(
              data: response.data,
              expiry: DateTime.now().add(const Duration(minutes: 5)),
            );
          }
          handler.next(response);
        },
      );

  /// 创建日志拦截器
  Interceptor _createLoggingInterceptor() => LogInterceptor(
        requestBody: kDebugMode,
        responseBody: kDebugMode,
        logPrint: (Object object) => debugPrint(object.toString()),
      );

  /// 生成缓存键
  String _generateCacheKey(RequestOptions options) =>
      '${options.method}:${options.uri}';

  /// 清理所有缓存
  void clearCache() {
    _cache.clear();
  }

  /// 释放资源
  void dispose() {
    _dio.close();
    _cache.clear();
  }
}

/// 缓存条目
class _CacheEntry {
  _CacheEntry({
    required this.data,
    required this.expiry,
  });

  final dynamic data;
  final DateTime expiry;

  bool get isExpired => DateTime.now().isAfter(expiry);
}
