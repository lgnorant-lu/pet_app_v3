/*
---------------------------------------------------------------
File name:          system_status.dart
Author:             lgnorant-lu
Date created:       2025-07-24
Last modified:      2025-07-24
Dart Version:       3.2+
Description:        系统状态模型 - Phase 5.0.7.2 状态概览系统
---------------------------------------------------------------
Change History:
    2025-07-24: Phase 5.0.7.2 - 实现状态概览系统
    - 系统监控面板
    - 模块状态展示
    - 数据统计展示
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';

/// 系统健康状态
enum SystemHealth {
  /// 优秀
  excellent,
  /// 良好
  good,
  /// 一般
  fair,
  /// 警告
  warning,
  /// 错误
  error,
}

/// 系统健康状态扩展
extension SystemHealthExtension on SystemHealth {
  /// 获取状态颜色
  Color get color {
    switch (this) {
      case SystemHealth.excellent:
        return Colors.green;
      case SystemHealth.good:
        return Colors.lightGreen;
      case SystemHealth.fair:
        return Colors.orange;
      case SystemHealth.warning:
        return Colors.amber;
      case SystemHealth.error:
        return Colors.red;
    }
  }

  /// 获取状态标签
  String get label {
    switch (this) {
      case SystemHealth.excellent:
        return '优秀';
      case SystemHealth.good:
        return '良好';
      case SystemHealth.fair:
        return '一般';
      case SystemHealth.warning:
        return '警告';
      case SystemHealth.error:
        return '错误';
    }
  }

  /// 获取状态图标
  IconData get icon {
    switch (this) {
      case SystemHealth.excellent:
        return Icons.check_circle;
      case SystemHealth.good:
        return Icons.check_circle_outline;
      case SystemHealth.fair:
        return Icons.info;
      case SystemHealth.warning:
        return Icons.warning;
      case SystemHealth.error:
        return Icons.error;
    }
  }

  /// 获取状态分数 (0-100)
  int get score {
    switch (this) {
      case SystemHealth.excellent:
        return 95;
      case SystemHealth.good:
        return 80;
      case SystemHealth.fair:
        return 60;
      case SystemHealth.warning:
        return 40;
      case SystemHealth.error:
        return 20;
    }
  }
}

/// 系统性能指标
class SystemMetrics {
  /// CPU 使用率 (0-100)
  final double cpuUsage;
  
  /// 内存使用率 (0-100)
  final double memoryUsage;
  
  /// 磁盘使用率 (0-100)
  final double diskUsage;
  
  /// 网络延迟 (毫秒)
  final int networkLatency;
  
  /// 活跃用户数
  final int activeUsers;
  
  /// 错误率 (0-100)
  final double errorRate;
  
  /// 响应时间 (毫秒)
  final int responseTime;
  
  /// 更新时间
  final DateTime timestamp;

  const SystemMetrics({
    required this.cpuUsage,
    required this.memoryUsage,
    required this.diskUsage,
    required this.networkLatency,
    required this.activeUsers,
    required this.errorRate,
    required this.responseTime,
    required this.timestamp,
  });

  /// 复制并修改
  SystemMetrics copyWith({
    double? cpuUsage,
    double? memoryUsage,
    double? diskUsage,
    int? networkLatency,
    int? activeUsers,
    double? errorRate,
    int? responseTime,
    DateTime? timestamp,
  }) {
    return SystemMetrics(
      cpuUsage: cpuUsage ?? this.cpuUsage,
      memoryUsage: memoryUsage ?? this.memoryUsage,
      diskUsage: diskUsage ?? this.diskUsage,
      networkLatency: networkLatency ?? this.networkLatency,
      activeUsers: activeUsers ?? this.activeUsers,
      errorRate: errorRate ?? this.errorRate,
      responseTime: responseTime ?? this.responseTime,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// 计算整体健康分数
  SystemHealth get overallHealth {
    final scores = [
      _getUsageScore(cpuUsage),
      _getUsageScore(memoryUsage),
      _getUsageScore(diskUsage),
      _getLatencyScore(networkLatency),
      _getErrorScore(errorRate),
      _getResponseScore(responseTime),
    ];

    final averageScore = scores.reduce((a, b) => a + b) / scores.length;

    if (averageScore >= 90) return SystemHealth.excellent;
    if (averageScore >= 75) return SystemHealth.good;
    if (averageScore >= 60) return SystemHealth.fair;
    if (averageScore >= 40) return SystemHealth.warning;
    return SystemHealth.error;
  }

  /// 获取使用率分数
  int _getUsageScore(double usage) {
    if (usage <= 50) return 100;
    if (usage <= 70) return 80;
    if (usage <= 85) return 60;
    if (usage <= 95) return 40;
    return 20;
  }

  /// 获取延迟分数
  int _getLatencyScore(int latency) {
    if (latency <= 50) return 100;
    if (latency <= 100) return 80;
    if (latency <= 200) return 60;
    if (latency <= 500) return 40;
    return 20;
  }

  /// 获取错误率分数
  int _getErrorScore(double errorRate) {
    if (errorRate <= 1) return 100;
    if (errorRate <= 3) return 80;
    if (errorRate <= 5) return 60;
    if (errorRate <= 10) return 40;
    return 20;
  }

  /// 获取响应时间分数
  int _getResponseScore(int responseTime) {
    if (responseTime <= 100) return 100;
    if (responseTime <= 300) return 80;
    if (responseTime <= 500) return 60;
    if (responseTime <= 1000) return 40;
    return 20;
  }
}

/// 模块状态详情
class ModuleStatusDetail {
  /// 模块ID
  final String moduleId;
  
  /// 模块名称
  final String moduleName;
  
  /// 健康状态
  final SystemHealth health;
  
  /// 运行时间 (秒)
  final int uptime;
  
  /// 错误计数
  final int errorCount;
  
  /// 警告计数
  final int warningCount;
  
  /// 最后活动时间
  final DateTime lastActivity;
  
  /// 版本号
  final String version;
  
  /// 依赖状态
  final Map<String, bool> dependencies;
  
  /// 性能指标
  final Map<String, double> metrics;

  const ModuleStatusDetail({
    required this.moduleId,
    required this.moduleName,
    required this.health,
    required this.uptime,
    required this.errorCount,
    required this.warningCount,
    required this.lastActivity,
    required this.version,
    this.dependencies = const {},
    this.metrics = const {},
  });

  /// 复制并修改
  ModuleStatusDetail copyWith({
    String? moduleId,
    String? moduleName,
    SystemHealth? health,
    int? uptime,
    int? errorCount,
    int? warningCount,
    DateTime? lastActivity,
    String? version,
    Map<String, bool>? dependencies,
    Map<String, double>? metrics,
  }) {
    return ModuleStatusDetail(
      moduleId: moduleId ?? this.moduleId,
      moduleName: moduleName ?? this.moduleName,
      health: health ?? this.health,
      uptime: uptime ?? this.uptime,
      errorCount: errorCount ?? this.errorCount,
      warningCount: warningCount ?? this.warningCount,
      lastActivity: lastActivity ?? this.lastActivity,
      version: version ?? this.version,
      dependencies: dependencies ?? this.dependencies,
      metrics: metrics ?? this.metrics,
    );
  }

  /// 获取运行时间格式化字符串
  String get formattedUptime {
    final duration = Duration(seconds: uptime);
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;

    if (days > 0) {
      return '${days}天 ${hours}小时';
    } else if (hours > 0) {
      return '${hours}小时 ${minutes}分钟';
    } else {
      return '${minutes}分钟';
    }
  }

  /// 是否有问题
  bool get hasIssues => errorCount > 0 || warningCount > 0;

  /// 依赖是否健康
  bool get dependenciesHealthy => dependencies.values.every((status) => status);
}

/// 数据统计项
class StatisticItem {
  /// 标题
  final String title;
  
  /// 当前值
  final dynamic value;
  
  /// 单位
  final String unit;
  
  /// 变化量
  final double? change;
  
  /// 变化百分比
  final double? changePercent;
  
  /// 趋势方向
  final TrendDirection trend;
  
  /// 图标
  final IconData icon;
  
  /// 颜色
  final Color color;
  
  /// 描述
  final String? description;

  const StatisticItem({
    required this.title,
    required this.value,
    this.unit = '',
    this.change,
    this.changePercent,
    this.trend = TrendDirection.stable,
    required this.icon,
    required this.color,
    this.description,
  });

  /// 复制并修改
  StatisticItem copyWith({
    String? title,
    dynamic value,
    String? unit,
    double? change,
    double? changePercent,
    TrendDirection? trend,
    IconData? icon,
    Color? color,
    String? description,
  }) {
    return StatisticItem(
      title: title ?? this.title,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      change: change ?? this.change,
      changePercent: changePercent ?? this.changePercent,
      trend: trend ?? this.trend,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      description: description ?? this.description,
    );
  }

  /// 格式化值
  String get formattedValue {
    if (value is double) {
      return '${(value as double).toStringAsFixed(1)}$unit';
    } else if (value is int) {
      return '${value}$unit';
    } else {
      return '$value$unit';
    }
  }

  /// 格式化变化
  String? get formattedChange {
    if (change == null) return null;
    final prefix = change! >= 0 ? '+' : '';
    return '$prefix${change!.toStringAsFixed(1)}$unit';
  }

  /// 格式化变化百分比
  String? get formattedChangePercent {
    if (changePercent == null) return null;
    final prefix = changePercent! >= 0 ? '+' : '';
    return '$prefix${changePercent!.toStringAsFixed(1)}%';
  }
}

/// 趋势方向
enum TrendDirection {
  /// 上升
  up,
  /// 下降
  down,
  /// 稳定
  stable,
}

/// 趋势方向扩展
extension TrendDirectionExtension on TrendDirection {
  /// 获取图标
  IconData get icon {
    switch (this) {
      case TrendDirection.up:
        return Icons.trending_up;
      case TrendDirection.down:
        return Icons.trending_down;
      case TrendDirection.stable:
        return Icons.trending_flat;
    }
  }

  /// 获取颜色
  Color get color {
    switch (this) {
      case TrendDirection.up:
        return Colors.green;
      case TrendDirection.down:
        return Colors.red;
      case TrendDirection.stable:
        return Colors.grey;
    }
  }
}
