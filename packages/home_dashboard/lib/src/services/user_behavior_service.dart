/*
---------------------------------------------------------------
File name:          user_behavior_service.dart
Author:             lgnorant-lu
Date created:       2025-07-24
Last modified:      2025-07-24
Dart Version:       3.2+
Description:        用户行为分析服务 - 替换模拟数据为真实数据
---------------------------------------------------------------
Change History:
    2025-07-24: 创建用户行为分析服务，替换模拟数据
---------------------------------------------------------------
*/

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quick_action.dart';

/// 用户行为分析服务
class UserBehaviorService {
  UserBehaviorService._();

  static final UserBehaviorService _instance = UserBehaviorService._();
  static UserBehaviorService get instance => _instance;

  static const String _actionsKey = 'user_actions_history';
  static const String _preferencesKey = 'user_preferences';
  static const String _usageStatsKey = 'usage_statistics';

  /// 记录用户操作
  Future<void> recordAction(
    String actionId, {
    Map<String, dynamic>? context,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await _getActionHistory();

      final record = {
        'actionId': actionId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'context': context ?? {},
      };

      history.add(record);

      // 保留最近1000条记录
      if (history.length > 1000) {
        history.removeRange(0, history.length - 1000);
      }

      await prefs.setString(_actionsKey, jsonEncode(history));

      // 更新使用统计
      await _updateUsageStats(actionId);
    } catch (e) {
      debugPrint('记录用户操作失败: $e');
    }
  }

  /// 获取操作历史
  Future<List<Map<String, dynamic>>> _getActionHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_actionsKey);

      if (historyJson != null) {
        final dynamic decoded = jsonDecode(historyJson);
        if (decoded is List) {
          return decoded.cast<Map<String, dynamic>>();
        }
      }
    } catch (e) {
      debugPrint('获取操作历史失败: $e');
    }

    return [];
  }

  /// 更新使用统计
  Future<void> _updateUsageStats(String actionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString(_usageStatsKey);

      Map<String, dynamic> stats = {};
      if (statsJson != null) {
        final dynamic decoded = jsonDecode(statsJson);
        if (decoded is Map<String, dynamic>) {
          stats = decoded;
        }
      }

      // 更新计数
      stats[actionId] = (stats[actionId] ?? 0) + 1;

      await prefs.setString(_usageStatsKey, jsonEncode(stats));
    } catch (e) {
      debugPrint('更新使用统计失败: $e');
    }
  }

  /// 获取推荐操作
  Future<List<QuickAction>> getRecommendedActions() async {
    try {
      final stats = await _getUsageStats();
      final timeBasedActions = await _getTimeBasedRecommendations();
      final contextBasedActions = await _getContextBasedRecommendations();

      // 合并不同类型的推荐
      final recommendations = <QuickAction>[];

      // 基于使用频率的推荐
      final frequentActions = await _getFrequentActions(stats);
      recommendations.addAll(frequentActions);

      // 基于时间的推荐
      recommendations.addAll(timeBasedActions);

      // 基于上下文的推荐
      recommendations.addAll(contextBasedActions);

      // 去重并排序
      final uniqueActions = _deduplicateActions(recommendations);
      uniqueActions.sort((a, b) => b.usageCount.compareTo(a.usageCount));

      // 返回前6个推荐
      return uniqueActions.take(6).toList();
    } catch (e) {
      debugPrint('获取推荐操作失败: $e');
      return _getFallbackRecommendations();
    }
  }

  /// 获取使用统计
  Future<Map<String, int>> _getUsageStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString(_usageStatsKey);

      if (statsJson != null) {
        final dynamic decoded = jsonDecode(statsJson);
        if (decoded is Map<String, dynamic>) {
          return decoded.map((key, value) => MapEntry(key, value as int));
        }
      }
    } catch (e) {
      debugPrint('获取使用统计失败: $e');
    }

    return {};
  }

  /// 获取高频操作
  Future<List<QuickAction>> _getFrequentActions(Map<String, int> stats) async {
    final actions = <QuickAction>[];

    // 根据使用频率排序
    final sortedStats = stats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (final entry in sortedStats.take(3)) {
      final action = await _createActionFromId(entry.key);
      if (action != null) {
        actions.add(action.copyWith(
          usageCount: entry.value,
          priority: QuickActionPriority.high,
        ));
      }
    }

    return actions;
  }

  /// 基于时间的推荐
  Future<List<QuickAction>> _getTimeBasedRecommendations() async {
    final now = DateTime.now();
    final hour = now.hour;
    final actions = <QuickAction>[];

    // 根据时间推荐不同操作
    if (hour >= 9 && hour <= 12) {
      // 上午：工作相关操作
      actions.addAll([
        _createWorkAction('new_project', '新建项目'),
        _createWorkAction('check_tasks', '查看任务'),
      ]);
    } else if (hour >= 13 && hour <= 18) {
      // 下午：协作相关操作
      actions.addAll([
        _createWorkAction('team_chat', '团队聊天'),
        _createWorkAction('review_code', '代码审查'),
      ]);
    } else {
      // 晚上：学习和娱乐相关操作
      actions.addAll([
        _createWorkAction('learning', '学习资源'),
        _createWorkAction('entertainment', '娱乐功能'),
      ]);
    }

    return actions;
  }

  /// 基于上下文的推荐
  Future<List<QuickAction>> _getContextBasedRecommendations() async {
    final actions = <QuickAction>[];
    final history = await _getActionHistory();

    if (history.isNotEmpty) {
      // 分析最近的操作模式
      final recentActions = history.where((record) {
        final timestamp =
            DateTime.fromMillisecondsSinceEpoch(record['timestamp'] as int);
        return DateTime.now().difference(timestamp).inHours < 24;
      }).toList();

      // 基于最近操作推荐相关操作
      final actionCounts = <String, int>{};
      for (final record in recentActions) {
        final actionId = record['actionId'] as String;
        actionCounts[actionId] = (actionCounts[actionId] ?? 0) + 1;
      }

      // 推荐相关操作
      for (final entry in actionCounts.entries) {
        final relatedActions = await _getRelatedActions(entry.key);
        actions.addAll(relatedActions);
      }
    }

    return actions;
  }

  /// 获取相关操作
  Future<List<QuickAction>> _getRelatedActions(String actionId) async {
    final relatedMap = {
      'new_project': ['project_template', 'git_init'],
      'check_tasks': ['create_task', 'task_report'],
      'team_chat': ['video_call', 'share_screen'],
      'review_code': ['run_tests', 'deploy'],
    };

    final related = relatedMap[actionId] ?? [];
    final actions = <QuickAction>[];

    for (final relatedId in related) {
      final action = await _createActionFromId(relatedId);
      if (action != null) {
        actions.add(action);
      }
    }

    return actions;
  }

  /// 从ID创建操作
  Future<QuickAction?> _createActionFromId(String actionId) async {
    final actionMap = {
      'new_project': _createWorkAction('new_project', '新建项目'),
      'check_tasks': _createWorkAction('check_tasks', '查看任务'),
      'team_chat': _createWorkAction('team_chat', '团队聊天'),
      'review_code': _createWorkAction('review_code', '代码审查'),
      'learning': _createWorkAction('learning', '学习资源'),
      'entertainment': _createWorkAction('entertainment', '娱乐功能'),
      'project_template': _createWorkAction('project_template', '项目模板'),
      'git_init': _createWorkAction('git_init', 'Git初始化'),
      'create_task': _createWorkAction('create_task', '创建任务'),
      'task_report': _createWorkAction('task_report', '任务报告'),
      'video_call': _createWorkAction('video_call', '视频通话'),
      'share_screen': _createWorkAction('share_screen', '屏幕共享'),
      'run_tests': _createWorkAction('run_tests', '运行测试'),
      'deploy': _createWorkAction('deploy', '部署应用'),
    };

    return actionMap[actionId];
  }

  /// 创建工作操作
  QuickAction _createWorkAction(String id, String title) {
    return QuickAction(
      id: id,
      title: title,
      description: '$title的详细描述',
      icon: _getIconForAction(id),
      color: Colors.blue,
      type: QuickActionType.workflow,
      priority: QuickActionPriority.normal,
      isEnabled: true,
      usageCount: 0,
      lastUsed: null,
      createdAt: DateTime.now(),
      tags: const ['工作', '效率'],
      onTap: () {
        debugPrint('执行操作: $title');
      },
    );
  }

  /// 获取操作图标
  IconData _getIconForAction(String actionId) {
    final iconMap = {
      'new_project': Icons.add_circle,
      'check_tasks': Icons.checklist,
      'team_chat': Icons.chat,
      'review_code': Icons.code,
      'learning': Icons.school,
      'entertainment': Icons.games,
      'project_template': Icons.description,
      'git_init': Icons.settings,
      'create_task': Icons.add_task,
      'task_report': Icons.analytics,
      'video_call': Icons.video_call,
      'share_screen': Icons.screen_share,
      'run_tests': Icons.bug_report,
      'deploy': Icons.rocket_launch,
    };

    return iconMap[actionId] ?? Icons.flash_on;
  }

  /// 去重操作
  List<QuickAction> _deduplicateActions(List<QuickAction> actions) {
    final seen = <String>{};
    final unique = <QuickAction>[];

    for (final action in actions) {
      if (!seen.contains(action.id)) {
        seen.add(action.id);
        unique.add(action);
      }
    }

    return unique;
  }

  /// 备用推荐（当真实推荐失败时使用）
  List<QuickAction> _getFallbackRecommendations() {
    return [
      _createWorkAction('new_project', '新建项目'),
      _createWorkAction('check_tasks', '查看任务'),
      _createWorkAction('team_chat', '团队聊天'),
      _createWorkAction('learning', '学习资源'),
    ];
  }

  /// 获取最近操作
  Future<List<QuickAction>> getRecentActions() async {
    try {
      final history = await _getActionHistory();
      final recentHistory = history.where((record) {
        final timestamp =
            DateTime.fromMillisecondsSinceEpoch(record['timestamp'] as int);
        return DateTime.now().difference(timestamp).inDays < 7;
      }).toList();

      // 按时间排序
      recentHistory.sort(
          (a, b) => (b['timestamp'] as int).compareTo(a['timestamp'] as int));

      final actions = <QuickAction>[];
      final seen = <String>{};

      for (final record in recentHistory) {
        final actionId = record['actionId'] as String;
        if (!seen.contains(actionId)) {
          seen.add(actionId);
          final action = await _createActionFromId(actionId);
          if (action != null) {
            actions.add(action.copyWith(
              lastUsed: DateTime.fromMillisecondsSinceEpoch(
                  record['timestamp'] as int),
            ));
          }
        }

        if (actions.length >= 5) break;
      }

      return actions;
    } catch (e) {
      debugPrint('获取最近操作失败: $e');
      return [];
    }
  }

  /// 清除用户数据
  Future<void> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_actionsKey);
      await prefs.remove(_preferencesKey);
      await prefs.remove(_usageStatsKey);
    } catch (e) {
      debugPrint('清除用户数据失败: $e');
    }
  }

  /// 导出用户数据
  Future<Map<String, dynamic>> exportUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'actions': prefs.getString(_actionsKey),
        'preferences': prefs.getString(_preferencesKey),
        'stats': prefs.getString(_usageStatsKey),
        'exportTime': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('导出用户数据失败: $e');
      return {};
    }
  }

  /// 导入用户数据
  Future<void> importUserData(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (data['actions'] != null) {
        await prefs.setString(_actionsKey, data['actions'] as String);
      }

      if (data['preferences'] != null) {
        await prefs.setString(_preferencesKey, data['preferences'] as String);
      }

      if (data['stats'] != null) {
        await prefs.setString(_usageStatsKey, data['stats'] as String);
      }
    } catch (e) {
      debugPrint('导入用户数据失败: $e');
    }
  }
}
