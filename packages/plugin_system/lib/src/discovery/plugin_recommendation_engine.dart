/*
---------------------------------------------------------------
File name:          plugin_recommendation_engine.dart
Author:             lgnorant-lu
Date created:       2025-07-23
Last modified:      2025-07-23
Dart Version:       3.2+
Description:        插件智能推荐引擎 - 基于Ming CLI推荐算法设计
---------------------------------------------------------------
Change History:
    2025-07-23: Task 2.2.1 - 创建插件智能推荐引擎;
---------------------------------------------------------------
*/

import 'dart:math' as math;
import 'package:flutter/foundation.dart';

import 'package:plugin_system/src/store/plugin_store_models.dart';

/// 推荐类型
enum RecommendationType {
  /// 基于内容的推荐
  contentBased,

  /// 基于协同过滤的推荐
  collaborative,

  /// 基于流行度的推荐
  popularity,

  /// 基于用户行为的推荐
  behavioral,

  /// 混合推荐
  hybrid,
}

/// 推荐结果
@immutable
class PluginRecommendation {
  const PluginRecommendation({
    required this.plugin,
    required this.score,
    required this.type,
    required this.reason,
    this.confidence = 0.0,
    this.metadata = const <String, dynamic>{},
  });

  final PluginStoreEntry plugin;
  final double score;
  final RecommendationType type;
  final String reason;
  final double confidence;
  final Map<String, dynamic> metadata;

  @override
  String toString() =>
      'PluginRecommendation(plugin: ${plugin.name}, score: $score, type: $type)';
}

/// 用户行为数据
@immutable
class UserBehavior {
  const UserBehavior({
    required this.userId,
    required this.action,
    required this.pluginId,
    required this.timestamp,
    this.metadata = const <String, dynamic>{},
  });

  final String userId;
  final String action; // view, download, install, rate, uninstall
  final String pluginId;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
}

/// 插件智能推荐引擎 (基于Ming CLI SmartRecommendationEngine设计)
class PluginRecommendationEngine {
  PluginRecommendationEngine({
    this.enableCaching = true,
    this.cacheExpiration = const Duration(hours: 1),
    this.maxRecommendations = 20,
  });

  final bool enableCaching;
  final Duration cacheExpiration;
  final int maxRecommendations;

  /// 推荐缓存
  final Map<String, List<PluginRecommendation>> _cache =
      <String, List<PluginRecommendation>>{};
  final Map<String, DateTime> _cacheTimestamps = <String, DateTime>{};

  /// 用户行为历史
  final Map<String, List<UserBehavior>> _userBehaviors =
      <String, List<UserBehavior>>{};

  /// 插件统计数据
  final Map<String, Map<String, dynamic>> _pluginStats =
      <String, Map<String, dynamic>>{};

  /// 生成个性化推荐
  Future<List<PluginRecommendation>> generateRecommendations({
    required String userId,
    required List<PluginStoreEntry> availablePlugins,
    List<String>? installedPluginIds,
    List<String>? categories,
    RecommendationType? preferredType,
    int? limit,
  }) async {
    final cacheKey = _generateCacheKey(userId, categories, preferredType);

    // 检查缓存
    if (enableCaching && _isCacheValid(cacheKey)) {
      return _cache[cacheKey]!.take(limit ?? maxRecommendations).toList();
    }

    final recommendations = <PluginRecommendation>[];
    final installedIds = installedPluginIds?.toSet() ?? <String>{};

    // 过滤已安装的插件
    final candidatePlugins = availablePlugins
        .where((PluginStoreEntry plugin) => !installedIds.contains(plugin.id))
        .toList();

    // 根据推荐类型生成推荐
    switch (preferredType ?? RecommendationType.hybrid) {
      case RecommendationType.contentBased:
        recommendations.addAll(
          await _generateContentBasedRecommendations(
            userId,
            candidatePlugins,
            installedPluginIds ?? <String>[],
          ),
        );
      case RecommendationType.collaborative:
        recommendations.addAll(
          await _generateCollaborativeRecommendations(
            userId,
            candidatePlugins,
          ),
        );
      case RecommendationType.popularity:
        recommendations
            .addAll(await _generatePopularityRecommendations(candidatePlugins));
      case RecommendationType.behavioral:
        recommendations.addAll(
          await _generateBehavioralRecommendations(userId, candidatePlugins),
        );
      case RecommendationType.hybrid:
        recommendations.addAll(
          await _generateHybridRecommendations(
            userId,
            candidatePlugins,
            installedPluginIds ?? <String>[],
          ),
        );
    }

    // 排序和去重
    recommendations.sort((PluginRecommendation a, PluginRecommendation b) =>
        b.score.compareTo(a.score));
    final uniqueRecommendations = _deduplicateRecommendations(recommendations);

    // 缓存结果
    if (enableCaching) {
      _cache[cacheKey] = uniqueRecommendations;
      _cacheTimestamps[cacheKey] = DateTime.now();
    }

    return uniqueRecommendations.take(limit ?? maxRecommendations).toList();
  }

  /// 基于内容的推荐 (基于Ming CLI内容推荐算法)
  Future<List<PluginRecommendation>> _generateContentBasedRecommendations(
    String userId,
    List<PluginStoreEntry> candidatePlugins,
    List<String> installedPluginIds,
  ) async {
    final recommendations = <PluginRecommendation>[];

    // 获取用户已安装插件的特征
    final userProfile = await _buildUserProfile(userId, installedPluginIds);

    for (final plugin in candidatePlugins) {
      final score = _calculateContentSimilarity(plugin, userProfile);
      if (score > 0.1) {
        recommendations.add(
          PluginRecommendation(
            plugin: plugin,
            score: score,
            type: RecommendationType.contentBased,
            reason: '基于您已安装插件的相似性推荐',
            confidence: score,
            metadata: <String, dynamic>{'similarity_score': score},
          ),
        );
      }
    }

    return recommendations;
  }

  /// 基于协同过滤的推荐
  Future<List<PluginRecommendation>> _generateCollaborativeRecommendations(
    String userId,
    List<PluginStoreEntry> candidatePlugins,
  ) async {
    final recommendations = <PluginRecommendation>[];

    // 找到相似用户
    final similarUsers = await _findSimilarUsers(userId);

    for (final plugin in candidatePlugins) {
      final score = _calculateCollaborativeScore(plugin, similarUsers);
      if (score > 0.1) {
        recommendations.add(
          PluginRecommendation(
            plugin: plugin,
            score: score,
            type: RecommendationType.collaborative,
            reason: '基于相似用户的选择推荐',
            confidence: score,
            metadata: <String, dynamic>{
              'similar_users_count': similarUsers.length
            },
          ),
        );
      }
    }

    return recommendations;
  }

  /// 基于流行度的推荐
  Future<List<PluginRecommendation>> _generatePopularityRecommendations(
    List<PluginStoreEntry> candidatePlugins,
  ) async {
    final recommendations = <PluginRecommendation>[];

    for (final plugin in candidatePlugins) {
      final score = _calculatePopularityScore(plugin);
      recommendations.add(
        PluginRecommendation(
          plugin: plugin,
          score: score,
          type: RecommendationType.popularity,
          reason: '基于插件流行度推荐',
          confidence: 0.8,
          metadata: <String, dynamic>{
            'download_count': plugin.downloadCount,
            'rating': plugin.rating,
          },
        ),
      );
    }

    return recommendations;
  }

  /// 基于用户行为的推荐
  Future<List<PluginRecommendation>> _generateBehavioralRecommendations(
    String userId,
    List<PluginStoreEntry> candidatePlugins,
  ) async {
    final recommendations = <PluginRecommendation>[];
    final userBehaviors = _userBehaviors[userId] ?? <UserBehavior>[];

    for (final plugin in candidatePlugins) {
      final score = _calculateBehavioralScore(plugin, userBehaviors);
      if (score > 0.1) {
        recommendations.add(
          PluginRecommendation(
            plugin: plugin,
            score: score,
            type: RecommendationType.behavioral,
            reason: '基于您的使用习惯推荐',
            confidence: score,
            metadata: <String, dynamic>{'behavior_score': score},
          ),
        );
      }
    }

    return recommendations;
  }

  /// 混合推荐算法
  Future<List<PluginRecommendation>> _generateHybridRecommendations(
    String userId,
    List<PluginStoreEntry> candidatePlugins,
    List<String> installedPluginIds,
  ) async {
    final allRecommendations = <PluginRecommendation>[];

    // 获取各种推荐类型的结果
    final contentBased = await _generateContentBasedRecommendations(
      userId,
      candidatePlugins,
      installedPluginIds,
    );
    final collaborative =
        await _generateCollaborativeRecommendations(userId, candidatePlugins);
    final popularity =
        await _generatePopularityRecommendations(candidatePlugins);
    final behavioral =
        await _generateBehavioralRecommendations(userId, candidatePlugins);

    // 合并和加权
    final pluginScores = <String, double>{};
    final pluginReasons = <String, List<String>>{};
    final pluginMap = <String, PluginStoreEntry>{};

    // 内容推荐权重: 0.3
    for (final rec in contentBased) {
      pluginScores[rec.plugin.id] =
          (pluginScores[rec.plugin.id] ?? 0.0) + rec.score * 0.3;
      pluginReasons
          .putIfAbsent(rec.plugin.id, () => <String>[])
          .add(rec.reason);
      pluginMap[rec.plugin.id] = rec.plugin;
    }

    // 协同过滤权重: 0.25
    for (final rec in collaborative) {
      pluginScores[rec.plugin.id] =
          (pluginScores[rec.plugin.id] ?? 0.0) + rec.score * 0.25;
      pluginReasons
          .putIfAbsent(rec.plugin.id, () => <String>[])
          .add(rec.reason);
      pluginMap[rec.plugin.id] = rec.plugin;
    }

    // 流行度权重: 0.2
    for (final rec in popularity) {
      pluginScores[rec.plugin.id] =
          (pluginScores[rec.plugin.id] ?? 0.0) + rec.score * 0.2;
      pluginReasons
          .putIfAbsent(rec.plugin.id, () => <String>[])
          .add(rec.reason);
      pluginMap[rec.plugin.id] = rec.plugin;
    }

    // 行为推荐权重: 0.25
    for (final rec in behavioral) {
      pluginScores[rec.plugin.id] =
          (pluginScores[rec.plugin.id] ?? 0.0) + rec.score * 0.25;
      pluginReasons
          .putIfAbsent(rec.plugin.id, () => <String>[])
          .add(rec.reason);
      pluginMap[rec.plugin.id] = rec.plugin;
    }

    // 生成最终推荐
    for (final entry in pluginScores.entries) {
      final plugin = pluginMap[entry.key]!;
      final score = entry.value;
      final reasons = pluginReasons[entry.key]!;

      allRecommendations.add(
        PluginRecommendation(
          plugin: plugin,
          score: score,
          type: RecommendationType.hybrid,
          reason: '综合推荐: ${reasons.join(', ')}',
          confidence: math.min(score, 1),
          metadata: <String, dynamic>{
            'component_scores': <String, double>{
              'content': contentBased
                  .firstWhere(
                    (PluginRecommendation r) => r.plugin.id == entry.key,
                    orElse: () => const PluginRecommendation(
                      plugin: PluginStoreEntry(
                        id: '',
                        name: '',
                        version: '',
                        description: '',
                        author: '',
                        storeId: '',
                      ),
                      score: 0,
                      type: RecommendationType.contentBased,
                      reason: '',
                    ),
                  )
                  .score,
              'collaborative': collaborative
                  .firstWhere(
                    (PluginRecommendation r) => r.plugin.id == entry.key,
                    orElse: () => const PluginRecommendation(
                      plugin: PluginStoreEntry(
                        id: '',
                        name: '',
                        version: '',
                        description: '',
                        author: '',
                        storeId: '',
                      ),
                      score: 0,
                      type: RecommendationType.collaborative,
                      reason: '',
                    ),
                  )
                  .score,
              'popularity': popularity
                  .firstWhere(
                    (PluginRecommendation r) => r.plugin.id == entry.key,
                    orElse: () => const PluginRecommendation(
                      plugin: PluginStoreEntry(
                        id: '',
                        name: '',
                        version: '',
                        description: '',
                        author: '',
                        storeId: '',
                      ),
                      score: 0,
                      type: RecommendationType.popularity,
                      reason: '',
                    ),
                  )
                  .score,
              'behavioral': behavioral
                  .firstWhere(
                    (PluginRecommendation r) => r.plugin.id == entry.key,
                    orElse: () => const PluginRecommendation(
                      plugin: PluginStoreEntry(
                        id: '',
                        name: '',
                        version: '',
                        description: '',
                        author: '',
                        storeId: '',
                      ),
                      score: 0,
                      type: RecommendationType.behavioral,
                      reason: '',
                    ),
                  )
                  .score,
            },
          },
        ),
      );
    }

    return allRecommendations;
  }

  /// 记录用户行为
  void recordUserBehavior(UserBehavior behavior) {
    _userBehaviors
        .putIfAbsent(behavior.userId, () => <UserBehavior>[])
        .add(behavior);

    // 限制历史记录数量
    final behaviors = _userBehaviors[behavior.userId]!;
    if (behaviors.length > 1000) {
      behaviors.removeRange(0, behaviors.length - 1000);
    }
  }

  /// 更新插件统计
  void updatePluginStats(String pluginId, Map<String, dynamic> stats) {
    _pluginStats[pluginId] = <String, dynamic>{
      ..._pluginStats[pluginId] ?? <String, dynamic>{},
      ...stats,
    };
  }

  /// 构建用户画像
  Future<Map<String, dynamic>> _buildUserProfile(
    String userId,
    List<String> installedPluginIds,
  ) async {
    final profile = <String, dynamic>{
      'categories': <String, int>{},
      'tags': <String, int>{},
      'authors': <String, int>{},
      'platforms': <String, int>{},
    };

    // 基于已安装插件构建画像
    for (final pluginId in installedPluginIds) {
      final stats = _pluginStats[pluginId];
      if (stats != null) {
        // 统计分类偏好
        final category = stats['category'] as String?;
        if (category != null) {
          profile['categories'][category] =
              (profile['categories'][category] ?? 0) + 1;
        }

        // 统计标签偏好
        final tags = stats['tags'] as List<String>?;
        if (tags != null) {
          for (final tag in tags) {
            profile['tags'][tag] = (profile['tags'][tag] ?? 0) + 1;
          }
        }

        // 统计作者偏好
        final author = stats['author'] as String?;
        if (author != null) {
          profile['authors'][author] = (profile['authors'][author] ?? 0) + 1;
        }

        // 统计平台偏好
        final platforms = stats['platforms'] as List<String>?;
        if (platforms != null) {
          for (final platform in platforms) {
            profile['platforms'][platform] =
                (profile['platforms'][platform] ?? 0) + 1;
          }
        }
      }
    }

    return profile;
  }

  /// 计算内容相似度
  double _calculateContentSimilarity(
    PluginStoreEntry plugin,
    Map<String, dynamic> userProfile,
  ) {
    var score = 0.0;

    // 分类相似度 (权重: 0.3)
    final categories = userProfile['categories'] as Map<String, int>;
    if (plugin.category != null && categories.containsKey(plugin.category)) {
      score += 0.3 *
          (categories[plugin.category!]! /
              categories.values.fold(0, (num a, int b) => a + b));
    }

    // 标签相似度 (权重: 0.4)
    final tags = userProfile['tags'] as Map<String, int>;
    var tagScore = 0.0;
    var tagCount = 0;
    for (final tag in plugin.tags) {
      if (tags.containsKey(tag)) {
        tagScore += tags[tag]! / tags.values.fold(0, (num a, int b) => a + b);
        tagCount++;
      }
    }
    if (tagCount > 0) {
      score += 0.4 * (tagScore / tagCount);
    }

    // 作者相似度 (权重: 0.1)
    final authors = userProfile['authors'] as Map<String, int>;
    if (authors.containsKey(plugin.author)) {
      score += 0.1 *
          (authors[plugin.author]! /
              authors.values.fold(0, (num a, int b) => a + b));
    }

    // 平台相似度 (权重: 0.2)
    final platforms = userProfile['platforms'] as Map<String, int>;
    var platformScore = 0.0;
    var platformCount = 0;
    for (final platform in plugin.supportedPlatforms) {
      if (platforms.containsKey(platform)) {
        platformScore += platforms[platform]! /
            platforms.values.fold(0, (num a, int b) => a + b);
        platformCount++;
      }
    }
    if (platformCount > 0) {
      score += 0.2 * (platformScore / platformCount);
    }

    return math.min(score, 1);
  }

  /// 查找相似用户
  Future<List<String>> _findSimilarUsers(String userId) async {
    final userBehaviors = _userBehaviors[userId] ?? <UserBehavior>[];
    final userPlugins = userBehaviors
        .where((UserBehavior b) => b.action == 'install')
        .map((UserBehavior b) => b.pluginId)
        .toSet();

    final similarUsers = <String>[];

    for (final entry in _userBehaviors.entries) {
      if (entry.key == userId) continue;

      final otherUserPlugins = entry.value
          .where((UserBehavior b) => b.action == 'install')
          .map((UserBehavior b) => b.pluginId)
          .toSet();

      // 计算Jaccard相似度
      final intersection = userPlugins.intersection(otherUserPlugins);
      final union = userPlugins.union(otherUserPlugins);

      if (union.isNotEmpty) {
        final similarity = intersection.length / union.length;
        if (similarity > 0.2) {
          // 相似度阈值
          similarUsers.add(entry.key);
        }
      }
    }

    return similarUsers;
  }

  /// 计算协同过滤评分
  double _calculateCollaborativeScore(
    PluginStoreEntry plugin,
    List<String> similarUsers,
  ) {
    var score = 0.0;
    var count = 0;

    for (final userId in similarUsers) {
      final behaviors = _userBehaviors[userId] ?? <UserBehavior>[];
      final hasInstalled = behaviors.any(
          (UserBehavior b) => b.pluginId == plugin.id && b.action == 'install');
      final hasRated = behaviors.any(
          (UserBehavior b) => b.pluginId == plugin.id && b.action == 'rate');

      if (hasInstalled) {
        score += 0.5;
        count++;
      }

      if (hasRated) {
        final rating = behaviors
                .firstWhere(
                  (UserBehavior b) =>
                      b.pluginId == plugin.id && b.action == 'rate',
                )
                .metadata['rating'] as double? ??
            0.0;
        score += rating / 5.0; // 归一化到0-1
        count++;
      }
    }

    return count > 0 ? score / count : 0.0;
  }

  /// 计算流行度评分
  double _calculatePopularityScore(PluginStoreEntry plugin) {
    var score = 0.0;

    // 下载量评分 (权重: 0.4)
    if (plugin.downloadCount > 0) {
      score += 0.4 * math.min(plugin.downloadCount / 10000.0, 1.0);
    }

    // 评分评分 (权重: 0.3)
    score += 0.3 * (plugin.rating / 5.0);

    // 验证状态 (权重: 0.2)
    if (plugin.isVerified) {
      score += 0.2;
    }

    // 精选状态 (权重: 0.1)
    if (plugin.isFeatured) {
      score += 0.1;
    }

    return math.min(score, 1);
  }

  /// 计算行为评分
  double _calculateBehavioralScore(
    PluginStoreEntry plugin,
    List<UserBehavior> userBehaviors,
  ) {
    var score = 0.0;

    // 查看相关插件的行为
    final relatedBehaviors = userBehaviors.where((UserBehavior b) {
      final behaviorTags = b.metadata['tags'] as List<dynamic>?;
      final hasTagMatch =
          plugin.tags.any((String tag) => behaviorTags?.contains(tag) ?? false);
      final hasCategoryMatch = plugin.category == b.metadata['category'];
      return hasTagMatch || hasCategoryMatch;
    }).toList();

    if (relatedBehaviors.isNotEmpty) {
      score += 0.3; // 基础相关性分数
    }

    // 最近活跃度
    final recentBehaviors = userBehaviors
        .where((UserBehavior b) =>
            DateTime.now().difference(b.timestamp).inDays < 30)
        .toList();

    if (recentBehaviors.isNotEmpty) {
      score += 0.2; // 活跃用户加分
    }

    return math.min(score, 1);
  }

  /// 去重推荐结果
  List<PluginRecommendation> _deduplicateRecommendations(
    List<PluginRecommendation> recommendations,
  ) {
    final seen = <String>{};
    final unique = <PluginRecommendation>[];

    for (final rec in recommendations) {
      if (!seen.contains(rec.plugin.id)) {
        seen.add(rec.plugin.id);
        unique.add(rec);
      }
    }

    return unique;
  }

  /// 生成缓存键
  String _generateCacheKey(
    String userId,
    List<String>? categories,
    RecommendationType? type,
  ) {
    final parts = <String>[userId];
    if (categories != null) {
      parts.add(categories.join(','));
    }
    if (type != null) {
      parts.add(type.name);
    }
    return parts.join('|');
  }

  /// 检查缓存是否有效
  bool _isCacheValid(String cacheKey) {
    final timestamp = _cacheTimestamps[cacheKey];
    if (timestamp == null) return false;

    return DateTime.now().difference(timestamp) < cacheExpiration;
  }

  /// 清理缓存
  void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }

  /// 清理过期缓存
  void cleanExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = <String>[];

    for (final entry in _cacheTimestamps.entries) {
      if (now.difference(entry.value) >= cacheExpiration) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }
}
