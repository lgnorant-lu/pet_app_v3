/*
---------------------------------------------------------------
File name:          main_app_framework.dart
Author:             Pet App V3 Team
Date created:       2025-07-19
Last modified:      2025-07-19
Dart Version:       3.2+
Description:        Phase 3.3.1 主应用框架 - 增强的UI框架
---------------------------------------------------------------
Change History:
    2025-07-19: Phase 3.3.1 - 实现状态栏、工具栏、快捷操作面板;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../core/communication/unified_message_bus.dart';
import '../../core/communication/module_communication_coordinator.dart' as comm;

/// 应用状态信息
class AppStatusInfo {
  final String moduleId;
  final String status;
  final String? message;
  final IconData? icon;
  final Color? color;
  final DateTime timestamp;

  const AppStatusInfo({
    required this.moduleId,
    required this.status,
    this.message,
    this.icon,
    this.color,
    required this.timestamp,
  });
}

/// 快捷操作项
class QuickAction {
  final String id;
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  final String? tooltip;

  const QuickAction({
    required this.id,
    required this.title,
    required this.icon,
    required this.onTap,
    this.enabled = true,
    this.tooltip,
  });
}

/// 主应用框架
/// 
/// Phase 3.3.1 核心功能：
/// - 状态栏显示系统信息
/// - 工具栏提供常用操作
/// - 快捷操作面板
/// - 模块状态监控
/// - 通知系统集成
class MainAppFramework extends StatefulWidget {
  final Widget child;
  final String title;
  final List<QuickAction> quickActions;
  final bool showStatusBar;
  final bool showToolBar;
  final bool showQuickPanel;

  const MainAppFramework({
    super.key,
    required this.child,
    this.title = 'Pet App V3',
    this.quickActions = const [],
    this.showStatusBar = true,
    this.showToolBar = true,
    this.showQuickPanel = true,
  });

  @override
  State<MainAppFramework> createState() => _MainAppFrameworkState();
}

class _MainAppFrameworkState extends State<MainAppFramework>
    with TickerProviderStateMixin {
  /// 统一消息总线
  final UnifiedMessageBus _messageBus = UnifiedMessageBus.instance;
  
  /// 通信协调器
  final comm.ModuleCommunicationCoordinator _coordinator = 
      comm.ModuleCommunicationCoordinator.instance;

  /// 应用状态信息列表
  final List<AppStatusInfo> _statusInfos = [];
  
  /// 通知列表
  final List<String> _notifications = [];
  
  /// 快捷面板是否展开
  bool _isQuickPanelExpanded = false;
  
  /// 状态栏动画控制器
  late AnimationController _statusBarAnimationController;
  
  /// 快捷面板动画控制器
  late AnimationController _quickPanelAnimationController;
  
  /// 消息订阅
  MessageSubscription? _messageSubscription;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeMessageSubscription();
    _initializeDefaultStatus();
  }

  @override
  void dispose() {
    _statusBarAnimationController.dispose();
    _quickPanelAnimationController.dispose();
    _messageSubscription?.cancel();
    super.dispose();
  }

  /// 初始化动画
  void _initializeAnimations() {
    _statusBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _quickPanelAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  /// 初始化消息订阅
  void _initializeMessageSubscription() {
    _messageSubscription = _messageBus.subscribe(
      _handleSystemMessage,
      filter: (message) => message.action.startsWith('system_') ||
                          message.action.startsWith('module_') ||
                          message.action.startsWith('notification_'),
    );
  }

  /// 初始化默认状态
  void _initializeDefaultStatus() {
    _addStatusInfo(AppStatusInfo(
      moduleId: 'system',
      status: 'running',
      message: '系统运行正常',
      icon: Icons.check_circle,
      color: Colors.green,
      timestamp: DateTime.now(),
    ));
  }

  /// 处理系统消息
  Future<Map<String, dynamic>?> _handleSystemMessage(UnifiedMessage message) async {
    switch (message.action) {
      case 'system_status_update':
        _handleStatusUpdate(message);
        break;
      case 'module_status_changed':
        _handleModuleStatusChange(message);
        break;
      case 'notification_new':
        _handleNewNotification(message);
        break;
    }
    return null;
  }

  /// 处理状态更新
  void _handleStatusUpdate(UnifiedMessage message) {
    final data = message.data;
    _addStatusInfo(AppStatusInfo(
      moduleId: data['moduleId'] ?? 'unknown',
      status: data['status'] ?? 'unknown',
      message: data['message'],
      icon: _getStatusIcon(data['status']),
      color: _getStatusColor(data['status']),
      timestamp: DateTime.now(),
    ));
  }

  /// 处理模块状态变更
  void _handleModuleStatusChange(UnifiedMessage message) {
    final data = message.data;
    _addStatusInfo(AppStatusInfo(
      moduleId: data['moduleId'] ?? 'unknown',
      status: data['newStatus'] ?? 'unknown',
      message: '模块状态变更',
      icon: Icons.swap_horiz,
      color: Colors.blue,
      timestamp: DateTime.now(),
    ));
  }

  /// 处理新通知
  void _handleNewNotification(UnifiedMessage message) {
    final notification = message.data['message'] as String? ?? '新通知';
    setState(() {
      _notifications.insert(0, notification);
      // 保持最近10条通知
      if (_notifications.length > 10) {
        _notifications.removeLast();
      }
    });
    
    // 触发状态栏动画
    _statusBarAnimationController.forward().then((_) {
      _statusBarAnimationController.reverse();
    });
  }

  /// 添加状态信息
  void _addStatusInfo(AppStatusInfo info) {
    setState(() {
      _statusInfos.insert(0, info);
      // 保持最近20条状态信息
      if (_statusInfos.length > 20) {
        _statusInfos.removeLast();
      }
    });
  }

  /// 获取状态图标
  IconData _getStatusIcon(String? status) {
    switch (status) {
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

  /// 获取状态颜色
  Color _getStatusColor(String? status) {
    switch (status) {
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

  /// 切换快捷面板
  void _toggleQuickPanel() {
    setState(() {
      _isQuickPanelExpanded = !_isQuickPanelExpanded;
    });
    
    if (_isQuickPanelExpanded) {
      _quickPanelAnimationController.forward();
    } else {
      _quickPanelAnimationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 状态栏
          if (widget.showStatusBar) _buildStatusBar(),
          
          // 工具栏
          if (widget.showToolBar) _buildToolBar(),
          
          // 主内容区域
          Expanded(child: widget.child),
          
          // 快捷操作面板
          if (widget.showQuickPanel) _buildQuickPanel(),
        ],
      ),
    );
  }

  /// 构建状态栏
  Widget _buildStatusBar() {
    return AnimatedBuilder(
      animation: _statusBarAnimationController,
      builder: (context, child) {
        return Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(
              0.8 + 0.2 * _statusBarAnimationController.value,
            ),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              // 应用标题
              Text(
                widget.title,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // 状态指示器
              if (_statusInfos.isNotEmpty) ...[
                Icon(
                  _statusInfos.first.icon,
                  size: 16,
                  color: _statusInfos.first.color,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _statusInfos.first.message ?? _statusInfos.first.status,
                    style: Theme.of(context).textTheme.labelSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              
              // 通知指示器
              if (_notifications.isNotEmpty) ...[
                const SizedBox(width: 8),
                Badge(
                  label: Text('${_notifications.length}'),
                  child: Icon(
                    Icons.notifications,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
              
              // 时间显示
              const SizedBox(width: 8),
              Text(
                _formatTime(DateTime.now()),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建工具栏
  Widget _buildToolBar() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // 快捷面板切换按钮
          IconButton(
            icon: AnimatedRotation(
              turns: _isQuickPanelExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.expand_more),
            ),
            onPressed: _toggleQuickPanel,
            tooltip: _isQuickPanelExpanded ? '收起快捷面板' : '展开快捷面板',
          ),
          
          const SizedBox(width: 8),
          
          // 分隔线
          Container(
            width: 1,
            height: 24,
            color: Theme.of(context).dividerColor,
          ),
          
          const SizedBox(width: 8),
          
          // 工具栏操作按钮
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshApp,
            tooltip: '刷新应用',
          ),
          
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: _showDebugInfo,
            tooltip: '调试信息',
          ),
          
          const Spacer(),
          
          // 系统信息
          Text(
            '模块: ${_coordinator.registeredModules.length}',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }

  /// 构建快捷操作面板
  Widget _buildQuickPanel() {
    return AnimatedBuilder(
      animation: _quickPanelAnimationController,
      builder: (context, child) {
        return SizeTransition(
          sizeFactor: _quickPanelAnimationController,
          child: Container(
            height: 80,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                // 默认快捷操作
                _buildQuickActionButton(
                  icon: Icons.home,
                  label: '首页',
                  onTap: () => _navigateToHome(),
                ),
                
                _buildQuickActionButton(
                  icon: Icons.build,
                  label: '工坊',
                  onTap: () => _navigateToWorkshop(),
                ),
                
                _buildQuickActionButton(
                  icon: Icons.settings,
                  label: '设置',
                  onTap: () => _navigateToSettings(),
                ),
                
                const SizedBox(width: 16),
                
                // 分隔线
                Container(
                  width: 1,
                  height: 48,
                  color: Theme.of(context).dividerColor,
                ),
                
                const SizedBox(width: 16),
                
                // 自定义快捷操作
                ...widget.quickActions.map((action) => _buildQuickActionButton(
                  icon: action.icon,
                  label: action.title,
                  onTap: action.enabled ? action.onTap : null,
                  tooltip: action.tooltip,
                )),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 构建快捷操作按钮
  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    String? tooltip,
  }) {
    final button = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 64,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: onTap != null 
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: onTap != null 
                    ? Theme.of(context).colorScheme.onSurfaceVariant
                    : Theme.of(context).disabledColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );

    return tooltip != null 
        ? Tooltip(message: tooltip, child: button)
        : button;
  }

  /// 格式化时间
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
           '${time.minute.toString().padLeft(2, '0')}';
  }

  /// 刷新应用
  void _refreshApp() {
    _messageBus.publishEvent(
      'main_framework',
      'app_refresh_requested',
      {'timestamp': DateTime.now().toIso8601String()},
      priority: MessagePriority.high,
    );
    
    HapticFeedback.lightImpact();
    _log('info', '应用刷新请求已发送');
  }

  /// 显示调试信息
  void _showDebugInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('调试信息'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('模块数量: ${_coordinator.registeredModules.length}'),
              Text('状态信息: ${_statusInfos.length}'),
              Text('通知数量: ${_notifications.length}'),
              Text('消息统计: ${_messageBus.messageStats}'),
              const SizedBox(height: 16),
              const Text('最近状态:', style: TextStyle(fontWeight: FontWeight.bold)),
              ..._statusInfos.take(5).map((info) => Text(
                '${info.moduleId}: ${info.status} - ${info.message ?? ""}',
                style: const TextStyle(fontSize: 12),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  /// 导航到首页
  void _navigateToHome() {
    _messageBus.publishEvent(
      'main_framework',
      'navigate_to_home',
      {},
      priority: MessagePriority.normal,
    );
  }

  /// 导航到工坊
  void _navigateToWorkshop() {
    _messageBus.publishEvent(
      'main_framework',
      'navigate_to_workshop',
      {},
      priority: MessagePriority.normal,
    );
  }

  /// 导航到设置
  void _navigateToSettings() {
    _messageBus.publishEvent(
      'main_framework',
      'navigate_to_settings',
      {},
      priority: MessagePriority.normal,
    );
  }

  /// 日志记录
  void _log(String level, String message) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      print('[$timestamp] [MainAppFramework] [$level] $message');
    }
  }
}
