/*
---------------------------------------------------------------
File name:          app_status_bar.dart
Author:             Pet App V3 Team
Date created:       2025-07-19
Last modified:      2025-07-19
Dart Version:       3.2+
Description:        Phase 3.3.1 应用状态栏 - 系统状态显示组件
---------------------------------------------------------------
Change History:
    2025-07-19: Phase 3.3.1 - 实现状态栏、系统监控、通知显示;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart'; // 暂时未使用
import 'dart:async';
import 'package:communication_system/communication_system.dart' as comm;

/// 状态栏项目类型
enum StatusBarItemType {
  /// 系统状态
  systemStatus,

  /// 模块状态
  moduleStatus,

  /// 通知
  notification,

  /// 性能指标
  performance,

  /// 自定义
  custom,
}

/// 状态栏项目
class StatusBarItem {
  final String id;
  final StatusBarItemType type;
  final Widget widget;
  final int priority;
  final bool visible;
  final Duration? updateInterval;

  const StatusBarItem({
    required this.id,
    required this.type,
    required this.widget,
    this.priority = 0,
    this.visible = true,
    this.updateInterval,
  });
}

/// 应用状态栏
///
/// Phase 3.3.1 核心功能：
/// - 实时系统状态显示
/// - 模块状态监控
/// - 通知指示器
/// - 性能指标显示
/// - 可自定义状态项
class AppStatusBar extends StatefulWidget {
  final double height;
  final Color? backgroundColor;
  final List<StatusBarItem> customItems;
  final bool showSystemStatus;
  final bool showModuleStatus;
  final bool showNotifications;
  final bool showPerformance;
  final bool showTime;

  const AppStatusBar({
    super.key,
    this.height = 32,
    this.backgroundColor,
    this.customItems = const [],
    this.showSystemStatus = true,
    this.showModuleStatus = true,
    this.showNotifications = true,
    this.showPerformance = false,
    this.showTime = true,
  });

  @override
  State<AppStatusBar> createState() => _AppStatusBarState();
}

class _AppStatusBarState extends State<AppStatusBar> {
  /// 统一消息总线
  final comm.UnifiedMessageBus _messageBus = comm.UnifiedMessageBus.instance;

  /// 通信协调器
  final comm.ModuleCommunicationCoordinator _coordinator =
      comm.ModuleCommunicationCoordinator.instance;

  /// 系统状态
  String _systemStatus = 'running';
  String _systemMessage = '系统运行正常';

  /// 模块状态计数
  int _runningModules = 0;
  int _totalModules = 0;

  /// 通知计数
  int _notificationCount = 0;

  /// 性能指标
  double _cpuUsage = 0.0;
  double _memoryUsage = 0.0;

  /// 当前时间
  DateTime _currentTime = DateTime.now();

  /// 定时器
  Timer? _timeTimer;
  Timer? _performanceTimer;

  /// 消息订阅
  StreamSubscription? _messageSubscription;

  @override
  void initState() {
    super.initState();
    _initializeStatusBar();
    _startTimers();
    _subscribeToMessages();
  }

  @override
  void dispose() {
    _timeTimer?.cancel();
    _performanceTimer?.cancel();
    _messageSubscription?.cancel();
    super.dispose();
  }

  /// 初始化状态栏
  void _initializeStatusBar() {
    _updateModuleStatus();
  }

  /// 启动定时器
  void _startTimers() {
    // 时间更新定时器
    if (widget.showTime) {
      _timeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _currentTime = DateTime.now();
        });
      });
    }

    // 性能监控定时器
    if (widget.showPerformance) {
      _performanceTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        _updatePerformanceMetrics();
      });
    }
  }

  /// 订阅消息
  void _subscribeToMessages() {
    _messageSubscription = _messageBus.messageStream
        .where(
          (message) =>
              message.action.startsWith('system_') ||
              message.action.startsWith('module_') ||
              message.action.startsWith('notification_'),
        )
        .listen(_handleStatusMessage);
  }

  /// 处理状态消息
  void _handleStatusMessage(comm.UnifiedMessage message) {
    switch (message.action) {
      case 'system_status_update':
        _handleSystemStatusUpdate(message);
        break;
      case 'module_registered':
      case 'module_unregistered':
      case 'module_status_changed':
        _updateModuleStatus();
        break;
      case 'notification_new':
        _handleNewNotification(message);
        break;
      case 'notification_clear':
        _handleClearNotifications(message);
        break;
    }
    return null;
  }

  /// 处理系统状态更新
  void _handleSystemStatusUpdate(comm.UnifiedMessage message) {
    final data = message.data;
    setState(() {
      _systemStatus = data['status'] ?? 'unknown';
      _systemMessage = data['message'] ?? '状态未知';
    });
  }

  /// 更新模块状态
  void _updateModuleStatus() {
    final modules = _coordinator.registeredModules;
    int running = 0;

    for (final module in modules) {
      final status = _coordinator.getModuleStatus(module.id);
      if (status == comm.ModuleStatus.running) {
        running++;
      }
    }

    setState(() {
      _totalModules = modules.length;
      _runningModules = running;
    });
  }

  /// 处理新通知
  void _handleNewNotification(comm.UnifiedMessage message) {
    setState(() {
      _notificationCount++;
    });
  }

  /// 处理清除通知
  void _handleClearNotifications(comm.UnifiedMessage message) {
    setState(() {
      _notificationCount = 0;
    });
  }

  /// 更新性能指标
  void _updatePerformanceMetrics() {
    // 模拟性能数据（实际应用中应该从系统获取真实数据）
    setState(() {
      _cpuUsage = (DateTime.now().millisecond % 100) / 100.0;
      _memoryUsage = (DateTime.now().second % 100) / 100.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color:
            widget.backgroundColor ??
            Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // 系统状态
          if (widget.showSystemStatus) _buildSystemStatus(),

          // 分隔符
          if (widget.showSystemStatus && _hasOtherItems()) _buildSeparator(),

          // 模块状态
          if (widget.showModuleStatus) _buildModuleStatus(),

          // 分隔符
          if (widget.showModuleStatus && _hasItemsAfterModules())
            _buildSeparator(),

          // 自定义项目
          ..._buildCustomItems(),

          // 弹性空间
          const Spacer(),

          // 性能指标
          if (widget.showPerformance) _buildPerformanceMetrics(),

          // 分隔符
          if (widget.showPerformance && _hasItemsAfterPerformance())
            _buildSeparator(),

          // 通知
          if (widget.showNotifications) _buildNotifications(),

          // 分隔符
          if (widget.showNotifications && widget.showTime) _buildSeparator(),

          // 时间
          if (widget.showTime) _buildTime(),
        ],
      ),
    );
  }

  /// 构建系统状态
  Widget _buildSystemStatus() {
    final statusColor = _getStatusColor(_systemStatus);
    final statusIcon = _getStatusIcon(_systemStatus);

    return Tooltip(
      message: _systemMessage,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 14, color: statusColor),
          const SizedBox(width: 4),
          Text(
            _systemStatus.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建模块状态
  Widget _buildModuleStatus() {
    return Tooltip(
      message: '运行中模块: $_runningModules / $_totalModules',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.extension,
            size: 14,
            color: _runningModules == _totalModules
                ? Colors.green
                : Colors.orange,
          ),
          const SizedBox(width: 4),
          Text(
            '$_runningModules/$_totalModules',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建性能指标
  Widget _buildPerformanceMetrics() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: 'CPU使用率: ${(_cpuUsage * 100).toStringAsFixed(1)}%',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.memory,
                size: 14,
                color: _cpuUsage > 0.8 ? Colors.red : Colors.blue,
              ),
              const SizedBox(width: 2),
              Text(
                '${(_cpuUsage * 100).toInt()}%',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Tooltip(
          message: '内存使用率: ${(_memoryUsage * 100).toStringAsFixed(1)}%',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.storage,
                size: 14,
                color: _memoryUsage > 0.8 ? Colors.red : Colors.green,
              ),
              const SizedBox(width: 2),
              Text(
                '${(_memoryUsage * 100).toInt()}%',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建通知
  Widget _buildNotifications() {
    return InkWell(
      onTap: _showNotificationDetails,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_notificationCount > 0) ...[
              Badge(
                label: Text('$_notificationCount'),
                child: Icon(
                  Icons.notifications,
                  size: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ] else ...[
              Icon(
                Icons.notifications_none,
                size: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建时间
  Widget _buildTime() {
    return Text(
      _formatTime(_currentTime),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontFeatures: [const FontFeature.tabularFigures()],
      ),
    );
  }

  /// 构建自定义项目
  List<Widget> _buildCustomItems() {
    final visibleItems =
        widget.customItems.where((item) => item.visible).toList()
          ..sort((a, b) => b.priority.compareTo(a.priority));

    final widgets = <Widget>[];
    for (int i = 0; i < visibleItems.length; i++) {
      widgets.add(visibleItems[i].widget);
      if (i < visibleItems.length - 1) {
        widgets.add(_buildSeparator());
      }
    }

    return widgets;
  }

  /// 构建分隔符
  Widget _buildSeparator() {
    return Container(
      width: 1,
      height: 16,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: Theme.of(context).dividerColor,
    );
  }

  /// 检查是否有其他项目
  bool _hasOtherItems() {
    return widget.showModuleStatus ||
        widget.customItems.any((item) => item.visible) ||
        widget.showPerformance ||
        widget.showNotifications ||
        widget.showTime;
  }

  /// 检查模块后是否有其他项目
  bool _hasItemsAfterModules() {
    return widget.customItems.any((item) => item.visible) ||
        widget.showPerformance ||
        widget.showNotifications ||
        widget.showTime;
  }

  /// 检查性能指标后是否有其他项目
  bool _hasItemsAfterPerformance() {
    return widget.showNotifications || widget.showTime;
  }

  /// 获取状态颜色
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'running':
        return Colors.green;
      case 'error':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'loading':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  /// 获取状态图标
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'running':
        return Icons.check_circle;
      case 'error':
        return Icons.error;
      case 'warning':
        return Icons.warning;
      case 'loading':
        return Icons.hourglass_empty;
      default:
        return Icons.info;
    }
  }

  /// 格式化时间
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}';
  }

  /// 显示通知详情
  void _showNotificationDetails() {
    if (_notificationCount == 0) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.notifications),
            const SizedBox(width: 8),
            Text('通知 ($_notificationCount)'),
          ],
        ),
        content: const Text('这里将显示详细的通知列表'),
        actions: [
          TextButton(
            onPressed: () {
              _messageBus.publishEvent('status_bar', 'notification_clear', {});
              Navigator.of(context).pop();
            },
            child: const Text('清除所有'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
