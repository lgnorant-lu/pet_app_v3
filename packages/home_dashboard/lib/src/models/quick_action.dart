/*
---------------------------------------------------------------
File name:          quick_action.dart
Author:             lgnorant-lu
Date created:       2025-07-24
Last modified:      2025-07-24
Dart Version:       3.2+
Description:        快速操作模型 - Phase 5.0.7.1 智能快捷入口聚合系统
---------------------------------------------------------------
Change History:
    2025-07-24: Phase 5.0.7.1 - 实现智能快捷入口聚合系统
    - 动态快捷方式配置
    - 个性化推荐算法
    - 工作流集成
    - 权限控制
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';

/// 快速操作类型
enum QuickActionType {
  /// 模块功能
  module,
  /// 工作流
  workflow,
  /// 系统功能
  system,
  /// 自定义操作
  custom,
}

/// 快速操作优先级
enum QuickActionPriority {
  /// 低优先级
  low,
  /// 普通优先级
  normal,
  /// 高优先级
  high,
  /// 置顶
  pinned,
}

/// 快速操作权限
enum QuickActionPermission {
  /// 公开访问
  public,
  /// 需要登录
  authenticated,
  /// 需要特定权限
  restricted,
  /// 管理员专用
  admin,
}

/// 快速操作模型
class QuickAction {
  /// 唯一标识符
  final String id;
  
  /// 显示名称
  final String title;
  
  /// 描述信息
  final String description;
  
  /// 图标
  final IconData icon;
  
  /// 颜色
  final Color color;
  
  /// 操作类型
  final QuickActionType type;
  
  /// 优先级
  final QuickActionPriority priority;
  
  /// 权限要求
  final QuickActionPermission permission;
  
  /// 目标路由或模块ID
  final String? target;
  
  /// 自定义操作回调
  final VoidCallback? onTap;
  
  /// 是否启用
  final bool isEnabled;
  
  /// 是否可见
  final bool isVisible;
  
  /// 使用次数
  final int usageCount;
  
  /// 最后使用时间
  final DateTime? lastUsed;
  
  /// 创建时间
  final DateTime createdAt;
  
  /// 标签
  final List<String> tags;
  
  /// 元数据
  final Map<String, dynamic> metadata;

  const QuickAction({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.type = QuickActionType.module,
    this.priority = QuickActionPriority.normal,
    this.permission = QuickActionPermission.public,
    this.target,
    this.onTap,
    this.isEnabled = true,
    this.isVisible = true,
    this.usageCount = 0,
    this.lastUsed,
    required this.createdAt,
    this.tags = const [],
    this.metadata = const {},
  });

  /// 复制并修改
  QuickAction copyWith({
    String? id,
    String? title,
    String? description,
    IconData? icon,
    Color? color,
    QuickActionType? type,
    QuickActionPriority? priority,
    QuickActionPermission? permission,
    String? target,
    VoidCallback? onTap,
    bool? isEnabled,
    bool? isVisible,
    int? usageCount,
    DateTime? lastUsed,
    DateTime? createdAt,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    return QuickAction(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      permission: permission ?? this.permission,
      target: target ?? this.target,
      onTap: onTap ?? this.onTap,
      isEnabled: isEnabled ?? this.isEnabled,
      isVisible: isVisible ?? this.isVisible,
      usageCount: usageCount ?? this.usageCount,
      lastUsed: lastUsed ?? this.lastUsed,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
    );
  }

  /// 增加使用次数
  QuickAction incrementUsage() {
    return copyWith(
      usageCount: usageCount + 1,
      lastUsed: DateTime.now(),
    );
  }

  /// 判断是否可用
  bool get isAvailable => isEnabled && isVisible;

  /// 获取优先级权重
  int get priorityWeight {
    switch (priority) {
      case QuickActionPriority.low:
        return 1;
      case QuickActionPriority.normal:
        return 2;
      case QuickActionPriority.high:
        return 3;
      case QuickActionPriority.pinned:
        return 4;
    }
  }

  /// 计算推荐分数
  double calculateRecommendationScore() {
    double score = 0.0;
    
    // 基础优先级分数
    score += priorityWeight * 10;
    
    // 使用频率分数
    score += usageCount * 2;
    
    // 最近使用分数
    if (lastUsed != null) {
      final daysSinceLastUse = DateTime.now().difference(lastUsed!).inDays;
      if (daysSinceLastUse <= 1) {
        score += 20;
      } else if (daysSinceLastUse <= 7) {
        score += 10;
      } else if (daysSinceLastUse <= 30) {
        score += 5;
      }
    }
    
    return score;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuickAction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'QuickAction(id: $id, title: $title, type: $type, priority: $priority)';
  }
}

/// 工作流模型
class Workflow {
  /// 唯一标识符
  final String id;
  
  /// 工作流名称
  final String name;
  
  /// 描述
  final String description;
  
  /// 图标
  final IconData icon;
  
  /// 颜色
  final Color color;
  
  /// 步骤列表
  final List<WorkflowStep> steps;
  
  /// 是否启用
  final bool isEnabled;
  
  /// 创建时间
  final DateTime createdAt;
  
  /// 使用次数
  final int usageCount;

  const Workflow({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.steps,
    this.isEnabled = true,
    required this.createdAt,
    this.usageCount = 0,
  });

  /// 复制并修改
  Workflow copyWith({
    String? id,
    String? name,
    String? description,
    IconData? icon,
    Color? color,
    List<WorkflowStep>? steps,
    bool? isEnabled,
    DateTime? createdAt,
    int? usageCount,
  }) {
    return Workflow(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      steps: steps ?? this.steps,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      usageCount: usageCount ?? this.usageCount,
    );
  }
}

/// 工作流步骤
class WorkflowStep {
  /// 步骤ID
  final String id;
  
  /// 步骤名称
  final String name;
  
  /// 操作类型
  final String action;
  
  /// 参数
  final Map<String, dynamic> parameters;
  
  /// 是否必需
  final bool isRequired;

  const WorkflowStep({
    required this.id,
    required this.name,
    required this.action,
    this.parameters = const {},
    this.isRequired = true,
  });
}
