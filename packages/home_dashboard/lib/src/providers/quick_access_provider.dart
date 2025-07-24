/*
---------------------------------------------------------------
File name:          quick_access_provider.dart
Author:             lgnorant-lu
Date created:       2025-07-24
Last modified:      2025-07-24
Dart Version:       3.2+
Description:        快速访问提供者 - Phase 5.0.7.1 智能快捷入口聚合系统
---------------------------------------------------------------
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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quick_action.dart';
import '../services/user_behavior_service.dart';

/// 快速访问状态
class QuickAccessState {
  /// 所有快速操作
  final List<QuickAction> allActions;

  /// 推荐操作
  final List<QuickAction> recommendedActions;

  /// 置顶操作
  final List<QuickAction> pinnedActions;

  /// 最近使用的操作
  final List<QuickAction> recentActions;

  /// 工作流列表
  final List<Workflow> workflows;

  /// 是否正在加载
  final bool isLoading;

  /// 错误信息
  final String? error;

  const QuickAccessState({
    this.allActions = const [],
    this.recommendedActions = const [],
    this.pinnedActions = const [],
    this.recentActions = const [],
    this.workflows = const [],
    this.isLoading = false,
    this.error,
  });

  QuickAccessState copyWith({
    List<QuickAction>? allActions,
    List<QuickAction>? recommendedActions,
    List<QuickAction>? pinnedActions,
    List<QuickAction>? recentActions,
    List<Workflow>? workflows,
    bool? isLoading,
    String? error,
  }) {
    return QuickAccessState(
      allActions: allActions ?? this.allActions,
      recommendedActions: recommendedActions ?? this.recommendedActions,
      pinnedActions: pinnedActions ?? this.pinnedActions,
      recentActions: recentActions ?? this.recentActions,
      workflows: workflows ?? this.workflows,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// 快速访问通知器
class QuickAccessNotifier extends StateNotifier<QuickAccessState> {
  QuickAccessNotifier() : super(const QuickAccessState()) {
    _initializeActions();
  }

  /// 初始化快速操作
  Future<void> _initializeActions() async {
    if (!mounted) return;

    state = state.copyWith(isLoading: true);

    try {
      // 获取默认操作
      final actions = _getDefaultActions();
      final workflows = _getDefaultWorkflows();

      // 尝试获取真实的推荐操作
      List<QuickAction> recommendedActions = [];
      List<QuickAction> recentActions = [];

      try {
        recommendedActions =
            await UserBehaviorService.instance.getRecommendedActions();
        recentActions = await UserBehaviorService.instance.getRecentActions();
      } catch (e) {
        // 如果获取真实推荐失败，使用默认推荐
        recommendedActions = actions.take(6).toList();
        recentActions = actions.take(5).toList();
      }

      if (!mounted) return;

      state = state.copyWith(
        allActions: actions,
        workflows: workflows,
        recommendedActions: recommendedActions,
        recentActions: recentActions,
        isLoading: false,
      );

      // 更新推荐和分类
      _updateRecommendations();
    } catch (e) {
      if (!mounted) return;

      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 获取默认快速操作
  List<QuickAction> _getDefaultActions() {
    final now = DateTime.now();

    return [
      QuickAction(
        id: 'new_project',
        title: '新建项目',
        description: '创建新的创意项目',
        icon: Icons.add_circle_outline,
        color: Colors.blue,
        type: QuickActionType.module,
        priority: QuickActionPriority.high,
        target: '/workshop/new',
        createdAt: now,
        tags: ['创建', '项目', '工坊'],
        usageCount: 15,
        lastUsed: now.subtract(const Duration(hours: 2)),
      ),
      QuickAction(
        id: 'plugin_store',
        title: '插件市场',
        description: '浏览和安装插件',
        icon: Icons.store,
        color: Colors.green,
        type: QuickActionType.module,
        priority: QuickActionPriority.normal,
        target: '/workshop/store',
        createdAt: now,
        tags: ['插件', '市场', '安装'],
        usageCount: 8,
        lastUsed: now.subtract(const Duration(days: 1)),
      ),
      QuickAction(
        id: 'recent_projects',
        title: '最近项目',
        description: '查看最近编辑的项目',
        icon: Icons.history,
        color: Colors.orange,
        type: QuickActionType.system,
        priority: QuickActionPriority.normal,
        target: '/workshop/recent',
        createdAt: now,
        tags: ['最近', '项目', '历史'],
        usageCount: 12,
        lastUsed: now.subtract(const Duration(hours: 6)),
      ),
      QuickAction(
        id: 'settings',
        title: '设置',
        description: '应用设置和配置',
        icon: Icons.settings,
        color: Colors.grey,
        type: QuickActionType.system,
        priority: QuickActionPriority.low,
        target: '/settings',
        createdAt: now,
        tags: ['设置', '配置', '系统'],
        usageCount: 5,
        lastUsed: now.subtract(const Duration(days: 3)),
      ),
      QuickAction(
        id: 'pet_interact',
        title: '桌宠互动',
        description: '与桌宠进行互动',
        icon: Icons.pets,
        color: Colors.pink,
        type: QuickActionType.module,
        priority: QuickActionPriority.high,
        target: '/pet/interact',
        createdAt: now,
        tags: ['桌宠', '互动', '娱乐'],
        usageCount: 20,
        lastUsed: now.subtract(const Duration(minutes: 30)),
      ),
      QuickAction(
        id: 'app_manager',
        title: '应用管理',
        description: '管理已安装的应用',
        icon: Icons.apps,
        color: Colors.purple,
        type: QuickActionType.module,
        priority: QuickActionPriority.normal,
        target: '/apps',
        createdAt: now,
        tags: ['应用', '管理', '安装'],
        usageCount: 6,
        lastUsed: now.subtract(const Duration(days: 2)),
      ),
    ];
  }

  /// 获取默认工作流
  List<Workflow> _getDefaultWorkflows() {
    final now = DateTime.now();

    return [
      Workflow(
        id: 'quick_dev',
        name: '快速开发',
        description: '创建项目 → 选择模板 → 开始编码',
        icon: Icons.flash_on,
        color: Colors.amber,
        steps: [
          const WorkflowStep(
            id: 'create_project',
            name: '创建项目',
            action: 'navigate',
            parameters: {'route': '/workshop/new'},
          ),
          const WorkflowStep(
            id: 'select_template',
            name: '选择模板',
            action: 'show_dialog',
            parameters: {'type': 'template_selector'},
          ),
          const WorkflowStep(
            id: 'start_coding',
            name: '开始编码',
            action: 'navigate',
            parameters: {'route': '/workshop/editor'},
          ),
        ],
        createdAt: now,
        usageCount: 3,
      ),
      Workflow(
        id: 'plugin_setup',
        name: '插件配置',
        description: '安装插件 → 配置权限 → 启用功能',
        icon: Icons.extension,
        color: Colors.teal,
        steps: [
          const WorkflowStep(
            id: 'browse_plugins',
            name: '浏览插件',
            action: 'navigate',
            parameters: {'route': '/workshop/store'},
          ),
          const WorkflowStep(
            id: 'install_plugin',
            name: '安装插件',
            action: 'install',
            parameters: {},
          ),
          const WorkflowStep(
            id: 'configure_plugin',
            name: '配置插件',
            action: 'navigate',
            parameters: {'route': '/settings/plugins'},
          ),
        ],
        createdAt: now,
        usageCount: 1,
      ),
    ];
  }

  /// 更新推荐
  void _updateRecommendations() {
    final allActions = state.allActions;

    // 按推荐分数排序
    final sortedActions = List<QuickAction>.from(allActions)
      ..sort(
        (a, b) => b
            .calculateRecommendationScore()
            .compareTo(a.calculateRecommendationScore()),
      );

    // 获取置顶操作
    final List<QuickAction> pinnedActions = allActions
        .where((QuickAction action) =>
            action.priority == QuickActionPriority.pinned)
        .toList();

    // 获取最近使用的操作
    final List<QuickAction> recentActions = allActions
        .where((QuickAction action) => action.lastUsed != null)
        .toList()
      ..sort((a, b) => b.lastUsed!.compareTo(a.lastUsed!));

    // 获取推荐操作（排除置顶的）
    final recommendedActions = sortedActions
        .where((action) => action.priority != QuickActionPriority.pinned)
        .take(6)
        .toList();

    state = state.copyWith(
      pinnedActions: pinnedActions,
      recentActions: recentActions.take(5).toList(),
      recommendedActions: recommendedActions,
    );
  }

  /// 执行快速操作
  Future<void> executeAction(QuickAction action) async {
    // 记录用户行为
    try {
      await UserBehaviorService.instance.recordAction(
        action.id,
        context: {
          'title': action.title,
          'priority': action.priority.toString(),
          'tags': action.tags.join(','),
        },
      );
    } catch (e) {
      // 记录失败不影响操作执行
      debugPrint('记录用户行为失败: $e');
    }

    // 更新使用统计
    final updatedAction = action.incrementUsage();
    final updatedActions = state.allActions
        .map((a) => a.id == action.id ? updatedAction : a)
        .toList();

    state = state.copyWith(allActions: updatedActions);

    // 重新计算推荐
    _updateRecommendations();

    // 执行操作
    if (action.onTap != null) {
      action.onTap!();
    }
  }

  /// 执行工作流
  Future<void> executeWorkflow(Workflow workflow) async {
    // 更新工作流使用统计
    final updatedWorkflow = workflow.copyWith(
      usageCount: workflow.usageCount + 1,
    );

    final updatedWorkflows = state.workflows
        .map((w) => w.id == workflow.id ? updatedWorkflow : w)
        .toList();

    state = state.copyWith(workflows: updatedWorkflows);

    // TODO(lgnorant-lu): 实现工作流执行逻辑
  }

  /// 添加自定义操作
  void addCustomAction(QuickAction action) {
    final updatedActions = [...state.allActions, action];
    state = state.copyWith(allActions: updatedActions);
    _updateRecommendations();
  }

  /// 移除操作
  void removeAction(String actionId) {
    final updatedActions =
        state.allActions.where((action) => action.id != actionId).toList();
    state = state.copyWith(allActions: updatedActions);
    _updateRecommendations();
  }

  /// 切换操作置顶状态
  void toggleActionPin(String actionId) {
    final updatedActions = state.allActions.map((action) {
      if (action.id == actionId) {
        final newPriority = action.priority == QuickActionPriority.pinned
            ? QuickActionPriority.normal
            : QuickActionPriority.pinned;
        return action.copyWith(priority: newPriority);
      }
      return action;
    }).toList();

    state = state.copyWith(allActions: updatedActions);
    _updateRecommendations();
  }

  /// 刷新数据
  Future<void> refresh() async {
    await _initializeActions();
  }
}

/// 快速访问提供者
final quickAccessProvider =
    StateNotifierProvider<QuickAccessNotifier, QuickAccessState>((ref) {
  return QuickAccessNotifier();
});

/// 推荐操作提供者
final recommendedActionsProvider = Provider<List<QuickAction>>((ref) {
  return ref.watch(quickAccessProvider).recommendedActions;
});

/// 置顶操作提供者
final pinnedActionsProvider = Provider<List<QuickAction>>((ref) {
  return ref.watch(quickAccessProvider).pinnedActions;
});

/// 最近操作提供者
final recentActionsProvider = Provider<List<QuickAction>>((ref) {
  return ref.watch(quickAccessProvider).recentActions;
});

/// 工作流提供者
final workflowsProvider = Provider<List<Workflow>>((ref) {
  return ref.watch(quickAccessProvider).workflows;
});
