/*
---------------------------------------------------------------
File name:          plugin_store_models.dart
Author:             lgnorant-lu
Date created:       2025-07-23
Last modified:      2025-07-23
Dart Version:       3.2+
Description:        插件商店数据模型
---------------------------------------------------------------
Change History:
    2025-07-23: Task 2.1.1 - 创建插件商店数据模型;
---------------------------------------------------------------
*/

import 'package:flutter/foundation.dart';

@immutable
class PluginStore {
  const PluginStore({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    this.description,
    this.isOfficial = false,
    this.isEnabled = true,
    this.priority = 0,
    this.lastSync,
    this.pluginCount = 0,
    this.metadata = const <String, dynamic>{},
  });

  factory PluginStore.fromJson(Map<String, dynamic> json) => PluginStore(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      type: PluginStoreType.values.firstWhere(
        (PluginStoreType e) => e.name == json['type'],
        orElse: () => PluginStoreType.community,
      ),
      description: json['description'] as String?,
      isOfficial: json['isOfficial'] as bool? ?? false,
      isEnabled: json['isEnabled'] as bool? ?? true,
      priority: json['priority'] as int? ?? 0,
      lastSync: json['lastSync'] != null
          ? DateTime.parse(json['lastSync'] as String)
          : null,
      pluginCount: json['pluginCount'] as int? ?? 0,
      metadata: Map<String, dynamic>.from(
          json['metadata'] as Map? ?? <String, dynamic>{},),
    );

  final String id;
  final String name;
  final String url;
  final PluginStoreType type;
  final String? description;
  final bool isOfficial;
  final bool isEnabled;
  final int priority;
  final DateTime? lastSync;
  final int pluginCount;
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toJson() => <String, dynamic>{
      'id': id,
      'name': name,
      'url': url,
      'type': type.name,
      'description': description,
      'isOfficial': isOfficial,
      'isEnabled': isEnabled,
      'priority': priority,
      'lastSync': lastSync?.toIso8601String(),
      'pluginCount': pluginCount,
      'metadata': metadata,
    };

  @override
  String toString() => 'PluginStore(id: $id, name: $name, type: $type)';
}

enum PluginStoreType {
  official,
  community,
  enterprise,
  local,
  developer,
}

@immutable
class PluginStoreEntry {
  const PluginStoreEntry({
    required this.id,
    required this.name,
    required this.version,
    required this.description,
    required this.author,
    required this.storeId,
    this.category,
    this.tags = const <String>[],
    this.downloadUrl,
    this.homepageUrl,
    this.repositoryUrl,
    this.documentationUrl,
    this.licenseType,
    this.minSdkVersion,
    this.maxSdkVersion,
    this.supportedPlatforms = const <String>[],
    this.dependencies = const <String>[],
    this.screenshots = const <String>[],
    this.rating = 0.0,
    this.downloadCount = 0,
    this.reviewCount = 0,
    this.publishedAt,
    this.updatedAt,
    this.isVerified = false,
    this.isFeatured = false,
    this.metadata = const <String, dynamic>{},
  });

  factory PluginStoreEntry.fromJson(Map<String, dynamic> json) => PluginStoreEntry(
      id: json['id'] as String,
      name: json['name'] as String,
      version: json['version'] as String,
      description: json['description'] as String,
      author: json['author'] as String,
      storeId: json['storeId'] as String,
      category: json['category'] as String?,
      tags: List<String>.from(json['tags'] as List? ?? <String>[]),
      downloadUrl: json['downloadUrl'] as String?,
      homepageUrl: json['homepageUrl'] as String?,
      repositoryUrl: json['repositoryUrl'] as String?,
      documentationUrl: json['documentationUrl'] as String?,
      licenseType: json['licenseType'] as String?,
      minSdkVersion: json['minSdkVersion'] as String?,
      maxSdkVersion: json['maxSdkVersion'] as String?,
      supportedPlatforms:
          List<String>.from(json['supportedPlatforms'] as List? ?? <String>[]),
      dependencies:
          List<String>.from(json['dependencies'] as List? ?? <String>[]),
      screenshots:
          List<String>.from(json['screenshots'] as List? ?? <String>[]),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      downloadCount: json['downloadCount'] as int? ?? 0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      isVerified: json['isVerified'] as bool? ?? false,
      isFeatured: json['isFeatured'] as bool? ?? false,
      metadata: Map<String, dynamic>.from(
          json['metadata'] as Map? ?? <String, dynamic>{},),
    );

  final String id;
  final String name;
  final String version;
  final String description;
  final String author;
  final String storeId;
  final String? category;
  final List<String> tags;
  final String? downloadUrl;
  final String? homepageUrl;
  final String? repositoryUrl;
  final String? documentationUrl;
  final String? licenseType;
  final String? minSdkVersion;
  final String? maxSdkVersion;
  final List<String> supportedPlatforms;
  final List<String> dependencies;
  final List<String> screenshots;
  final double rating;
  final int downloadCount;
  final int reviewCount;
  final DateTime? publishedAt;
  final DateTime? updatedAt;
  final bool isVerified;
  final bool isFeatured;
  final Map<String, dynamic> metadata;

  @override
  String toString() => 'PluginStoreEntry(id: , name: , version: )';
}

@immutable
class PluginSearchQuery {
  const PluginSearchQuery({
    this.keyword,
    this.category,
    this.tags = const <String>[],
    this.author,
    this.minRating,
    this.platforms = const <String>[],
    this.sortBy = PluginSortBy.relevance,
    this.sortOrder = SortOrder.descending,
    this.offset = 0,
    this.limit = 20,
    this.includePrerelease = false,
    this.onlyVerified = false,
    this.onlyFeatured = false,
    this.storeIds = const <String>[],
  });

  final String? keyword;
  final String? category;
  final List<String> tags;
  final String? author;
  final double? minRating;
  final List<String> platforms;
  final PluginSortBy sortBy;
  final SortOrder sortOrder;
  final int offset;
  final int limit;
  final bool includePrerelease;
  final bool onlyVerified;
  final bool onlyFeatured;
  final List<String> storeIds;

  @override
  String toString() => 'PluginSearchQuery(keyword: , category: )';
}

enum PluginSortBy {
  relevance,
  name,
  rating,
  downloads,
  published,
  updated,
}

enum SortOrder {
  ascending,
  descending,
}

@immutable
class PluginSearchResult {
  const PluginSearchResult({
    required this.plugins,
    required this.totalCount,
    required this.query,
    this.suggestions = const <String>[],
    this.facets = const <String, List<String>>{},
    this.searchTime,
  });

  factory PluginSearchResult.fromJson(Map<String, dynamic> json) => PluginSearchResult(
      plugins: (json['plugins'] as List<dynamic>?)
              ?.map((e) => PluginStoreEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          <PluginStoreEntry>[],
      totalCount: json['totalCount'] as int? ?? 0,
      query: const PluginSearchQuery(),
      suggestions:
          List<String>.from(json['suggestions'] as List? ?? <String>[]),
      facets: Map<String, List<String>>.from(
        (json['facets'] as Map? ?? <String, dynamic>{}).map(
          (key, value) => MapEntry(
              key as String, List<String>.from(value as List? ?? <String>[]),),
        ),
      ),
      searchTime: json['searchTime'] != null
          ? Duration(milliseconds: json['searchTime'] as int)
          : null,
    );

  final List<PluginStoreEntry> plugins;
  final int totalCount;
  final PluginSearchQuery query;
  final List<String> suggestions;
  final Map<String, List<String>> facets;
  final Duration? searchTime;

  bool get hasMore => query.offset + plugins.length < totalCount;
  int get currentPage => (query.offset ~/ query.limit) + 1;
  int get totalPages => (totalCount / query.limit).ceil();

  @override
  String toString() => 'PluginSearchResult(count: /)';
}
