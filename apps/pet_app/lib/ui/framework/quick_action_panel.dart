/*
---------------------------------------------------------------
File name:          quick_action_panel.dart
Author:             Pet App V3 Team
Date created:       2025-07-19
Last modified:      2025-07-19
Dart Version:       3.2+
Description:        Phase 3.3.1 快捷操作面板 - 常用功能快速访问
---------------------------------------------------------------
Change History:
    2025-07-19: Phase 3.3.1 - 实现快捷操作面板、自定义操作、动画效果;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../core/communication/unified_message_bus.dart';

/// 快捷操作类型
enum QuickActionType {
  /// 导航操作
  navigation,
  
  /// 工具操作
  tool,
  
  /// 系统操作
  system,
  
  /// 自定义操作
  custom,
}

/// 快捷操作项
class QuickActionItem {
  final String id;
  final String title;
  final String? subtitle;
  final IconData icon;
  final QuickActionType type;
  final VoidCallback? onTap;
  final bool enabled;
  final String? tooltip;
  final Color? color;
  final Widget? badge;
  final List<QuickActionItem>? subActions;

  const QuickActionItem({
    required this.id,
    required this.title,
    required this.icon,
    this.subtitle,
    this.type = QuickActionType.custom,
    this.onTap,
    this.enabled = true,
    this.tooltip,
    this.color,
    this.badge,
    this.subActions,
  });

  /// 是否有子操作
  bool get hasSubActions => subActions != null && subActions!.isNotEmpty;
}

/// 快捷操作面板
/// 
/// Phase 3.3.1 核心功能：
/// - 可折叠的快捷操作面板
/// - 支持分组和子操作
/// - 自定义操作项
/// - 动画效果
/// - 键盘快捷键支持
class QuickActionPanel extends StatefulWidget {
  final List<QuickActionItem> actions;
  final bool isExpanded;
  final ValueChanged<bool>? onExpandedChanged;
  final double height;
  final EdgeInsets padding;
  final Color? backgroundColor;
  final bool showToggleButton;
  final String toggleButtonTooltip;

  const QuickActionPanel({
    super.key,
    this.actions = const [],
    this.isExpanded = false,
    this.onExpandedChanged,
    this.height = 80,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
    this.showToggleButton = true,
    this.toggleButtonTooltip = '切换快捷面板',
  });

  @override
  State<QuickActionPanel> createState() => _QuickActionPanelState();
}

class _QuickActionPanelState extends State<QuickActionPanel>
    with TickerProviderStateMixin {
  /// 统一消息总线
  final UnifiedMessageBus _messageBus = UnifiedMessageBus.instance;

  /// 展开状态
  late bool _isExpanded;
  
  /// 动画控制器
  late AnimationController _animationController;
  late Animation<double> _sizeAnimation;
  late Animation<double> _fadeAnimation;
  
  /// 选中的子操作
  String? _selectedSubActionParent;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;
    _initializeAnimations();
  }

  @override
  void didUpdateWidget(QuickActionPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      _setExpanded(widget.isExpanded);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// 初始化动画
  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _sizeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeIn),
    );

    if (_isExpanded) {
      _animationController.value = 1.0;
    }
  }

  /// 设置展开状态
  void _setExpanded(bool expanded) {
    if (_isExpanded == expanded) return;
    
    setState(() {
      _isExpanded = expanded;
    });
    
    if (expanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
      _selectedSubActionParent = null;
    }
    
    widget.onExpandedChanged?.call(expanded);
    
    // 发送状态变更事件
    _messageBus.publishEvent(
      'quick_panel',
      'panel_toggled',
      {'expanded': expanded},
    );
  }

  /// 切换展开状态
  void _toggleExpanded() {
    _setExpanded(!_isExpanded);
    HapticFeedback.lightImpact();
  }

  /// 执行操作
  void _executeAction(QuickActionItem action) {
    if (!action.enabled) return;
    
    // 如果有子操作，切换子操作显示
    if (action.hasSubActions) {
      setState(() {
        _selectedSubActionParent = _selectedSubActionParent == action.id 
            ? null 
            : action.id;
      });
      return;
    }
    
    // 执行操作
    action.onTap?.call();
    
    // 发送操作执行事件
    _messageBus.publishEvent(
      'quick_panel',
      'action_executed',
      {
        'actionId': action.id,
        'actionType': action.type.name,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    
    HapticFeedback.selectionClick();
    _log('info', '执行快捷操作: ${action.title}');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 切换按钮
        if (widget.showToggleButton) _buildToggleButton(),
        
        // 快捷操作面板
        AnimatedBuilder(
          animation: _sizeAnimation,
          builder: (context, child) {
            return SizeTransition(
              sizeFactor: _sizeAnimation,
              child: Container(
                height: widget.height,
                padding: widget.padding,
                decoration: BoxDecoration(
                  color: widget.backgroundColor ?? 
                         Theme.of(context).colorScheme.surfaceVariant,
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 0.5,
                    ),
                  ),
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildActionContent(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// 构建切换按钮
  Widget _buildToggleButton() {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Center(
        child: Tooltip(
          message: widget.toggleButtonTooltip,
          child: InkWell(
            onTap: _toggleExpanded,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: AnimatedRotation(
                turns: _isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.expand_more,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建操作内容
  Widget _buildActionContent() {
    if (widget.actions.isEmpty) {
      return Center(
        child: Text(
          '暂无快捷操作',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // 主操作
          ..._buildMainActions(),
          
          // 分隔线
          if (_hasSubActions()) ...[
            const SizedBox(width: 16),
            Container(
              width: 1,
              height: 48,
              color: Theme.of(context).dividerColor,
            ),
            const SizedBox(width: 16),
          ],
          
          // 子操作
          ..._buildSubActions(),
        ],
      ),
    );
  }

  /// 构建主操作
  List<Widget> _buildMainActions() {
    final actions = <Widget>[];
    
    for (int i = 0; i < widget.actions.length; i++) {
      final action = widget.actions[i];
      actions.add(_buildActionButton(action));
      
      if (i < widget.actions.length - 1) {
        actions.add(const SizedBox(width: 12));
      }
    }
    
    return actions;
  }

  /// 构建子操作
  List<Widget> _buildSubActions() {
    if (_selectedSubActionParent == null) return [];
    
    final parentAction = widget.actions.firstWhere(
      (action) => action.id == _selectedSubActionParent,
      orElse: () => widget.actions.first,
    );
    
    if (!parentAction.hasSubActions) return [];
    
    final actions = <Widget>[];
    final subActions = parentAction.subActions!;
    
    for (int i = 0; i < subActions.length; i++) {
      final action = subActions[i];
      actions.add(_buildActionButton(action, isSubAction: true));
      
      if (i < subActions.length - 1) {
        actions.add(const SizedBox(width: 8));
      }
    }
    
    return actions;
  }

  /// 构建操作按钮
  Widget _buildActionButton(QuickActionItem action, {bool isSubAction = false}) {
    final isSelected = !isSubAction && action.id == _selectedSubActionParent;
    
    Widget button = InkWell(
      onTap: action.enabled ? () => _executeAction(action) : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: isSubAction ? 56 : 64,
        padding: EdgeInsets.symmetric(
          vertical: isSubAction ? 6 : 8,
          horizontal: 4,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected 
              ? Theme.of(context).colorScheme.primaryContainer
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 图标和徽章
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  action.icon,
                  size: isSubAction ? 20 : 24,
                  color: action.enabled
                      ? (action.color ?? 
                         (isSelected 
                             ? Theme.of(context).colorScheme.onPrimaryContainer
                             : Theme.of(context).colorScheme.primary))
                      : Theme.of(context).disabledColor,
                ),
                if (action.badge != null)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: action.badge!,
                  ),
                if (action.hasSubActions && !isSubAction)
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Icon(
                      Icons.more_horiz,
                      size: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 4),
            
            // 标题
            Text(
              action.title,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: action.enabled
                    ? (isSelected 
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : Theme.of(context).colorScheme.onSurfaceVariant)
                    : Theme.of(context).disabledColor,
                fontSize: isSubAction ? 10 : 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
            // 副标题
            if (action.subtitle != null && !isSubAction) ...[
              const SizedBox(height: 2),
              Text(
                action.subtitle!,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                  fontSize: 9,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );

    // 添加工具提示
    if (action.tooltip != null) {
      button = Tooltip(
        message: action.tooltip!,
        child: button,
      );
    }

    return button;
  }

  /// 检查是否有子操作
  bool _hasSubActions() {
    return _selectedSubActionParent != null &&
           widget.actions.any((action) => 
               action.id == _selectedSubActionParent && action.hasSubActions);
  }

  /// 日志记录
  void _log(String level, String message) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      print('[$timestamp] [QuickActionPanel] [$level] $message');
    }
  }
}

/// 快捷操作构建器
class QuickActionBuilder {
  static List<QuickActionItem> buildDefaultActions() {
    return [
      // 导航操作
      QuickActionItem(
        id: 'nav_home',
        title: '首页',
        icon: Icons.home,
        type: QuickActionType.navigation,
        onTap: () => _navigateTo('home'),
        tooltip: '返回首页',
      ),
      
      QuickActionItem(
        id: 'nav_workshop',
        title: '工坊',
        icon: Icons.build,
        type: QuickActionType.navigation,
        onTap: () => _navigateTo('workshop'),
        tooltip: '打开创意工坊',
      ),
      
      // 工具操作
      QuickActionItem(
        id: 'tools',
        title: '工具',
        icon: Icons.construction,
        type: QuickActionType.tool,
        tooltip: '工具集合',
        subActions: [
          QuickActionItem(
            id: 'tool_brush',
            title: '画笔',
            icon: Icons.brush,
            onTap: () => _openTool('brush'),
          ),
          QuickActionItem(
            id: 'tool_pencil',
            title: '铅笔',
            icon: Icons.edit,
            onTap: () => _openTool('pencil'),
          ),
          QuickActionItem(
            id: 'tool_eraser',
            title: '橡皮',
            icon: Icons.cleaning_services,
            onTap: () => _openTool('eraser'),
          ),
        ],
      ),
      
      // 系统操作
      QuickActionItem(
        id: 'system',
        title: '系统',
        icon: Icons.settings,
        type: QuickActionType.system,
        tooltip: '系统操作',
        subActions: [
          QuickActionItem(
            id: 'sys_refresh',
            title: '刷新',
            icon: Icons.refresh,
            onTap: () => _systemAction('refresh'),
          ),
          QuickActionItem(
            id: 'sys_debug',
            title: '调试',
            icon: Icons.bug_report,
            onTap: () => _systemAction('debug'),
          ),
          QuickActionItem(
            id: 'sys_settings',
            title: '设置',
            icon: Icons.tune,
            onTap: () => _systemAction('settings'),
          ),
        ],
      ),
    ];
  }

  static void _navigateTo(String destination) {
    final messageBus = UnifiedMessageBus.instance;
    messageBus.publishEvent(
      'quick_actions',
      'navigate_to',
      {'destination': destination},
    );
  }

  static void _openTool(String toolId) {
    final messageBus = UnifiedMessageBus.instance;
    messageBus.publishEvent(
      'quick_actions',
      'open_tool',
      {'toolId': toolId},
    );
  }

  static void _systemAction(String action) {
    final messageBus = UnifiedMessageBus.instance;
    messageBus.publishEvent(
      'quick_actions',
      'system_action',
      {'action': action},
    );
  }
}
