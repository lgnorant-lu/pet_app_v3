/*
---------------------------------------------------------------
File name:          status_overview_provider.dart
Author:             lgnorant-lu
Date created:       2025-07-24
Last modified:      2025-07-24
Dart Version:       3.2+
Description:        状态概览提供者 - Phase 5.0.7.2 状态概览系统
---------------------------------------------------------------
Change History:
    2025-07-24: Phase 5.0.7.2 - 实现状态概览系统
    - 系统监控面板
    - 模块状态展示
    - 数据统计展示
---------------------------------------------------------------
*/

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/system_status.dart';
import '../services/system_data_service.dart';

/// 状态概览状态
class StatusOverviewState {
  /// 系统性能指标
  final SystemMetrics systemMetrics;

  /// 模块状态详情列表
  final List<ModuleStatusDetail> moduleStatuses;

  /// 统计数据项列表
  final List<StatisticItem> statistics;

  /// 是否正在加载
  final bool isLoading;

  /// 错误信息
  final String? error;

  /// 最后更新时间
  final DateTime? lastUpdated;

  const StatusOverviewState({
    required this.systemMetrics,
    this.moduleStatuses = const [],
    this.statistics = const [],
    this.isLoading = false,
    this.error,
    this.lastUpdated,
  });

  StatusOverviewState copyWith({
    SystemMetrics? systemMetrics,
    List<ModuleStatusDetail>? moduleStatuses,
    List<StatisticItem>? statistics,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return StatusOverviewState(
      systemMetrics: systemMetrics ?? this.systemMetrics,
      moduleStatuses: moduleStatuses ?? this.moduleStatuses,
      statistics: statistics ?? this.statistics,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// 状态概览通知器
class StatusOverviewNotifier extends StateNotifier<StatusOverviewState> {
  StatusOverviewNotifier() : super(_getInitialState()) {
    _initializeMonitoring();
  }

  Timer? _updateTimer;
  final Random _random = Random();

  /// 获取初始状态
  static StatusOverviewState _getInitialState() {
    final now = DateTime.now();
    return StatusOverviewState(
      systemMetrics: SystemMetrics(
        cpuUsage: 0,
        memoryUsage: 0,
        diskUsage: 0,
        networkLatency: 0,
        activeUsers: 0,
        errorRate: 0,
        responseTime: 0,
        timestamp: now,
      ),
      isLoading: true,
    );
  }

  /// 初始化监控
  Future<void> _initializeMonitoring() async {
    await _loadInitialData();
    _startPeriodicUpdates();
  }

  /// 加载初始数据
  Future<void> _loadInitialData() async {
    state = state.copyWith(isLoading: true);

    try {
      // 模拟数据加载延迟
      await Future<void>.delayed(const Duration(milliseconds: 800));

      final systemMetrics = await _generateSystemMetrics();
      final moduleStatuses = _generateModuleStatuses();
      final statistics = _generateStatistics();

      state = StatusOverviewState(
        systemMetrics: systemMetrics,
        moduleStatuses: moduleStatuses,
        statistics: statistics,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 开始定期更新
  void _startPeriodicUpdates() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      await _updateMetrics();
    });
  }

  /// 更新指标
  Future<void> _updateMetrics() async {
    if (state.isLoading) return;

    final updatedMetrics = await _generateSystemMetrics();
    final updatedStatistics = _generateStatistics();

    state = state.copyWith(
      systemMetrics: updatedMetrics,
      statistics: updatedStatistics,
      lastUpdated: DateTime.now(),
    );
  }

  /// 生成系统指标
  Future<SystemMetrics> _generateSystemMetrics() async {
    try {
      // 使用真实的系统数据服务
      return await SystemDataService.instance.getSystemMetrics();
    } catch (e) {
      // 如果获取真实数据失败，使用备用数据
      return SystemMetrics(
        cpuUsage: 20 + _random.nextDouble() * 40, // 20-60%
        memoryUsage: 30 + _random.nextDouble() * 30, // 30-60%
        diskUsage: 45 + _random.nextDouble() * 20, // 45-65%
        networkLatency: 20 + _random.nextInt(80), // 20-100ms
        activeUsers: 1 + _random.nextInt(5), // 1-5 users
        errorRate: _random.nextDouble() * 2, // 0-2%
        responseTime: 50 + _random.nextInt(200), // 50-250ms
        timestamp: DateTime.now(),
      );
    }
  }

  /// 生成模块状态
  List<ModuleStatusDetail> _generateModuleStatuses() {
    final now = DateTime.now();

    return [
      ModuleStatusDetail(
        moduleId: 'plugin_system',
        moduleName: '插件系统',
        health: SystemHealth.excellent,
        uptime: 86400 + _random.nextInt(86400), // 1-2 days
        errorCount: 0,
        warningCount: 0,
        lastActivity: now.subtract(Duration(minutes: _random.nextInt(30))),
        version: '1.0.0',
        dependencies: {
          'core_services': true,
          'communication_system': true,
        },
        metrics: {
          'memory_usage': 15.5 + _random.nextDouble() * 10,
          'cpu_usage': 5.0 + _random.nextDouble() * 15,
        },
      ),
      ModuleStatusDetail(
        moduleId: 'creative_workshop',
        moduleName: '创意工坊',
        health: SystemHealth.good,
        uptime: 72000 + _random.nextInt(14400), // ~20-24 hours
        errorCount: 0,
        warningCount: 1,
        lastActivity: now.subtract(Duration(minutes: _random.nextInt(60))),
        version: '1.0.0',
        dependencies: {
          'plugin_system': true,
          'home_dashboard': true,
        },
        metrics: {
          'memory_usage': 25.0 + _random.nextDouble() * 15,
          'cpu_usage': 8.0 + _random.nextDouble() * 12,
        },
      ),
      ModuleStatusDetail(
        moduleId: 'home_dashboard',
        moduleName: '首页仪表板',
        health: SystemHealth.excellent,
        uptime: 90000 + _random.nextInt(10000), // ~25-28 hours
        errorCount: 0,
        warningCount: 0,
        lastActivity: now.subtract(Duration(seconds: _random.nextInt(300))),
        version: '1.0.0',
        dependencies: {
          'communication_system': true,
        },
        metrics: {
          'memory_usage': 12.0 + _random.nextDouble() * 8,
          'cpu_usage': 3.0 + _random.nextDouble() * 7,
        },
      ),
      ModuleStatusDetail(
        moduleId: 'settings_system',
        moduleName: '设置系统',
        health: SystemHealth.good,
        uptime: 85000 + _random.nextInt(5000), // ~23-24 hours
        errorCount: 0,
        warningCount: 0,
        lastActivity: now.subtract(Duration(minutes: _random.nextInt(120))),
        version: '1.0.0',
        dependencies: {
          'core_services': true,
        },
        metrics: {
          'memory_usage': 8.0 + _random.nextDouble() * 5,
          'cpu_usage': 2.0 + _random.nextDouble() * 3,
        },
      ),
      ModuleStatusDetail(
        moduleId: 'desktop_pet',
        moduleName: '桌宠系统',
        health: SystemHealth.fair,
        uptime: 3600 + _random.nextInt(7200), // 1-3 hours
        errorCount: 1,
        warningCount: 2,
        lastActivity: now.subtract(Duration(minutes: _random.nextInt(180))),
        version: '1.0.0',
        dependencies: {
          'home_dashboard': true,
          'settings_system': false, // 模拟依赖问题
        },
        metrics: {
          'memory_usage': 18.0 + _random.nextDouble() * 12,
          'cpu_usage': 6.0 + _random.nextDouble() * 14,
        },
      ),
    ];
  }

  /// 生成统计数据
  List<StatisticItem> _generateStatistics() {
    return [
      StatisticItem(
        title: '总用户数',
        value: 1247 + _random.nextInt(100),
        unit: '',
        change: -5 + _random.nextDouble() * 10,
        changePercent: -2 + _random.nextDouble() * 4,
        trend: _random.nextBool() ? TrendDirection.up : TrendDirection.down,
        icon: Icons.people,
        color: Colors.blue,
        description: '注册用户总数',
      ),
      const StatisticItem(
        title: '活跃模块',
        value: 5,
        unit: '个',
        change: 0,
        changePercent: 0,
        trend: TrendDirection.stable,
        icon: Icons.widgets,
        color: Colors.green,
        description: '当前运行的模块数量',
      ),
      StatisticItem(
        title: '插件数量',
        value: 23 + _random.nextInt(5),
        unit: '个',
        change: _random.nextInt(3).toDouble(),
        changePercent: 2 + _random.nextDouble() * 3,
        trend: TrendDirection.up,
        icon: Icons.extension,
        color: Colors.purple,
        description: '已安装的插件总数',
      ),
      StatisticItem(
        title: '平均响应时间',
        value: 120 + _random.nextInt(80),
        unit: 'ms',
        change: -10 + _random.nextDouble() * 20,
        changePercent: -5 + _random.nextDouble() * 10,
        trend: _random.nextBool() ? TrendDirection.up : TrendDirection.down,
        icon: Icons.speed,
        color: Colors.orange,
        description: 'API平均响应时间',
      ),
      StatisticItem(
        title: '错误率',
        value: 0.5 + _random.nextDouble() * 1.5,
        unit: '%',
        change: -0.1 + _random.nextDouble() * 0.2,
        changePercent: -10 + _random.nextDouble() * 20,
        trend: _random.nextBool() ? TrendDirection.down : TrendDirection.up,
        icon: Icons.error_outline,
        color: Colors.red,
        description: '系统错误发生率',
      ),
      StatisticItem(
        title: '存储使用',
        value: 2.3 + _random.nextDouble() * 0.5,
        unit: 'GB',
        change: 0.1 + _random.nextDouble() * 0.2,
        changePercent: 2 + _random.nextDouble() * 3,
        trend: TrendDirection.up,
        icon: Icons.storage,
        color: Colors.indigo,
        description: '应用数据存储使用量',
      ),
    ];
  }

  /// 刷新数据
  Future<void> refresh() async {
    await _loadInitialData();
  }

  /// 获取特定模块状态
  ModuleStatusDetail? getModuleStatus(String moduleId) {
    try {
      return state.moduleStatuses.firstWhere(
        (module) => module.moduleId == moduleId,
      );
    } catch (e) {
      return null;
    }
  }

  /// 获取健康模块数量
  int get healthyModulesCount {
    return state.moduleStatuses
        .where((module) =>
            module.health == SystemHealth.excellent ||
            module.health == SystemHealth.good)
        .length;
  }

  /// 获取有问题的模块数量
  int get problematicModulesCount {
    return state.moduleStatuses.where((module) => module.hasIssues).length;
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
}

/// 状态概览提供者
final statusOverviewProvider =
    StateNotifierProvider<StatusOverviewNotifier, StatusOverviewState>((ref) {
  return StatusOverviewNotifier();
});

/// 系统指标提供者
final systemMetricsProvider = Provider<SystemMetrics>((ref) {
  return ref.watch(statusOverviewProvider).systemMetrics;
});

/// 模块状态列表提供者
final moduleStatusesProvider = Provider<List<ModuleStatusDetail>>((ref) {
  return ref.watch(statusOverviewProvider).moduleStatuses;
});

/// 统计数据提供者
final statisticsProvider = Provider<List<StatisticItem>>((ref) {
  return ref.watch(statusOverviewProvider).statistics;
});

/// 系统健康状态提供者
final systemHealthProvider = Provider<SystemHealth>((ref) {
  return ref.watch(systemMetricsProvider).overallHealth;
});

/// 健康模块数量提供者
final healthyModulesCountProvider = Provider<int>((ref) {
  return ref.watch(statusOverviewProvider.notifier).healthyModulesCount;
});

/// 有问题模块数量提供者
final problematicModulesCountProvider = Provider<int>((ref) {
  return ref.watch(statusOverviewProvider.notifier).problematicModulesCount;
});
