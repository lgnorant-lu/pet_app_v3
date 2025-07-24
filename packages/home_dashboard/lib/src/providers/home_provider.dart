/*
---------------------------------------------------------------
File name:          home_provider.dart
Author:             lgnorant-lu
Date created:       2025-07-20
Last modified:      2025-07-21
Dart Version:       3.2+
Description:        首页数据提供者 - 管理首页仪表板状态 (迁移到模块)
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_dashboard/src/widgets/module_status_card.dart';

/// 首页数据状态
class HomeData {
  final List<ModuleInfo> modules;
  final Map<String, dynamic> userStats;
  final List<String> recentProjects;
  final List<String> achievements;
  final bool isLoading;

  const HomeData({
    this.modules = const [],
    this.userStats = const {},
    this.recentProjects = const [],
    this.achievements = const [],
    this.isLoading = false,
  });

  HomeData copyWith({
    List<ModuleInfo>? modules,
    Map<String, dynamic>? userStats,
    List<String>? recentProjects,
    List<String>? achievements,
    bool? isLoading,
  }) {
    return HomeData(
      modules: modules ?? this.modules,
      userStats: userStats ?? this.userStats,
      recentProjects: recentProjects ?? this.recentProjects,
      achievements: achievements ?? this.achievements,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// 首页数据通知器
class HomeNotifier extends StateNotifier<HomeData> {
  HomeNotifier() : super(const HomeData()) {
    // 延迟初始化，避免在构造函数中进行异步操作
    Future.microtask(() => _loadInitialData());
  }

  /// 加载初始数据
  Future<void> _loadInitialData() async {
    if (!mounted) return;

    state = state.copyWith(isLoading: true);

    try {
      // 模拟数据加载
      await Future<void>.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      final modules = [
        const ModuleInfo(
          id: 'workshop',
          title: '创意工坊',
          icon: Icons.build,
          status: ModuleStatus.active,
          subtitle: '3个项目进行中',
          metadata: {'projectCount': 3, 'lastActivity': '2小时前'},
        ),
        const ModuleInfo(
          id: 'apps',
          title: '应用管理',
          icon: Icons.apps,
          status: ModuleStatus.normal,
          subtitle: '12个应用已安装',
          metadata: {'appCount': 12, 'updateCount': 2},
        ),
        const ModuleInfo(
          id: 'pet',
          title: '桌宠',
          icon: Icons.pets,
          status: ModuleStatus.active,
          subtitle: '今日互动5次',
          metadata: {'mood': 'happy', 'interactionCount': 5},
        ),
        const ModuleInfo(
          id: 'settings',
          title: '设置',
          icon: Icons.settings,
          status: ModuleStatus.normal,
          subtitle: '已配置完成',
          metadata: {'configuredItems': 8},
        ),
      ];

      final userStats = {
        'usageHours': 24.5,
        'projectCount': 8,
        'pluginCount': 12,
        'achievementCount': 3,
      };

      final recentProjects = [
        'Flutter UI Kit',
        'Pet Animation System',
        'Plugin Template',
      ];

      final achievements = [
        'first_launch',
        'first_project',
        'settings_complete',
      ];

      if (!mounted) return;

      state = HomeData(
        modules: modules,
        userStats: userStats,
        recentProjects: recentProjects,
        achievements: achievements,
        isLoading: false,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false);
      // TODO: 处理错误
    }
  }

  /// 刷新数据
  Future<void> refresh() async {
    await _loadInitialData();
  }

  /// 更新模块状态
  void updateModuleStatus(String moduleId, ModuleStatus status) {
    final updatedModules = state.modules.map((module) {
      if (module.id == moduleId) {
        return module.copyWith(status: status);
      }
      return module;
    }).toList();

    state = state.copyWith(modules: updatedModules);
  }

  /// 添加最近项目
  void addRecentProject(String projectName) {
    final updatedProjects = [projectName, ...state.recentProjects];
    if (updatedProjects.length > 5) {
      updatedProjects.removeLast();
    }
    state = state.copyWith(recentProjects: updatedProjects);
  }

  /// 添加成就
  void addAchievement(String achievementId) {
    if (!state.achievements.contains(achievementId)) {
      final updatedAchievements = [...state.achievements, achievementId];
      state = state.copyWith(achievements: updatedAchievements);
    }
  }

  /// 更新用户统计
  void updateUserStats(Map<String, dynamic> newStats) {
    final updatedStats = {...state.userStats, ...newStats};
    state = state.copyWith(userStats: updatedStats);
  }
}

/// 首页数据提供者
final homeProvider = StateNotifierProvider<HomeNotifier, HomeData>((ref) {
  return HomeNotifier();
});

/// 模块列表提供者
final modulesProvider = Provider<List<ModuleInfo>>((ref) {
  return ref.watch(homeProvider).modules;
});

/// 用户统计提供者
final userStatsProvider = Provider<Map<String, dynamic>>((ref) {
  return ref.watch(homeProvider).userStats;
});

/// 最近项目提供者
final recentProjectsProvider = Provider<List<String>>((ref) {
  return ref.watch(homeProvider).recentProjects;
});

/// 成就提供者
final achievementsProvider = Provider<List<String>>((ref) {
  return ref.watch(homeProvider).achievements;
});

/// 加载状态提供者
final homeLoadingProvider = Provider<bool>((ref) {
  return ref.watch(homeProvider).isLoading;
});

/// 特定模块状态提供者
Provider<ModuleInfo?> moduleProvider(String moduleId) {
  return Provider<ModuleInfo?>((ref) {
    final modules = ref.watch(modulesProvider);
    try {
      return modules.firstWhere((module) => module.id == moduleId);
    } catch (e) {
      return null;
    }
  });
}
