/*
---------------------------------------------------------------
File name:          keyboard_shortcut_manager.dart
Author:             Pet App V3 Team
Date created:       2025-07-19
Last modified:      2025-07-19
Dart Version:       3.2+
Description:        Phase 3.3.2.3 键盘快捷键管理器
---------------------------------------------------------------
Change History:
    2025-07-19: Phase 3.3.2.3 - 实现键盘快捷键、自定义配置、无障碍支持;
---------------------------------------------------------------
*/

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:communication_system/communication_system.dart' as comm;

/// 快捷键组合
class ShortcutCombination {
  final Set<LogicalKeyboardKey> keys;
  final String description;
  final bool requiresCtrl;
  final bool requiresShift;
  final bool requiresAlt;
  final bool requiresMeta;

  const ShortcutCombination({
    required this.keys,
    required this.description,
    this.requiresCtrl = false,
    this.requiresShift = false,
    this.requiresAlt = false,
    this.requiresMeta = false,
  });

  /// 创建简单的快捷键组合
  factory ShortcutCombination.simple({
    required LogicalKeyboardKey key,
    required String description,
    bool ctrl = false,
    bool shift = false,
    bool alt = false,
    bool meta = false,
  }) {
    final keys = <LogicalKeyboardKey>{key};
    if (ctrl) keys.add(LogicalKeyboardKey.control);
    if (shift) keys.add(LogicalKeyboardKey.shift);
    if (alt) keys.add(LogicalKeyboardKey.alt);
    if (meta) keys.add(LogicalKeyboardKey.meta);

    return ShortcutCombination(
      keys: keys,
      description: description,
      requiresCtrl: ctrl,
      requiresShift: shift,
      requiresAlt: alt,
      requiresMeta: meta,
    );
  }

  /// 检查按键组合是否匹配
  bool matches(Set<LogicalKeyboardKey> pressedKeys) {
    // 检查所有必需的按键是否都被按下
    if (!keys.every((key) => pressedKeys.contains(key))) {
      return false;
    }

    // 检查修饰键要求
    final hasCtrl =
        pressedKeys.contains(LogicalKeyboardKey.controlLeft) ||
        pressedKeys.contains(LogicalKeyboardKey.controlRight);
    final hasShift =
        pressedKeys.contains(LogicalKeyboardKey.shiftLeft) ||
        pressedKeys.contains(LogicalKeyboardKey.shiftRight);
    final hasAlt =
        pressedKeys.contains(LogicalKeyboardKey.altLeft) ||
        pressedKeys.contains(LogicalKeyboardKey.altRight);
    final hasMeta =
        pressedKeys.contains(LogicalKeyboardKey.metaLeft) ||
        pressedKeys.contains(LogicalKeyboardKey.metaRight);

    return (requiresCtrl == hasCtrl) &&
        (requiresShift == hasShift) &&
        (requiresAlt == hasAlt) &&
        (requiresMeta == hasMeta);
  }

  /// 获取快捷键显示文本
  String get displayText {
    final parts = <String>[];
    if (requiresCtrl) parts.add('Ctrl');
    if (requiresShift) parts.add('Shift');
    if (requiresAlt) parts.add('Alt');
    if (requiresMeta) parts.add('Meta');

    // 添加主要按键
    final mainKey = keys.firstWhere(
      (key) =>
          key != LogicalKeyboardKey.control &&
          key != LogicalKeyboardKey.shift &&
          key != LogicalKeyboardKey.alt &&
          key != LogicalKeyboardKey.meta,
      orElse: () => keys.first,
    );

    parts.add(_getKeyDisplayName(mainKey));

    return parts.join(' + ');
  }

  /// 获取按键显示名称
  String _getKeyDisplayName(LogicalKeyboardKey key) {
    final keyMap = {
      LogicalKeyboardKey.arrowUp: '↑',
      LogicalKeyboardKey.arrowDown: '↓',
      LogicalKeyboardKey.arrowLeft: '←',
      LogicalKeyboardKey.arrowRight: '→',
      LogicalKeyboardKey.enter: 'Enter',
      LogicalKeyboardKey.escape: 'Esc',
      LogicalKeyboardKey.space: 'Space',
      LogicalKeyboardKey.tab: 'Tab',
      LogicalKeyboardKey.backspace: 'Backspace',
      LogicalKeyboardKey.delete: 'Delete',
      LogicalKeyboardKey.home: 'Home',
      LogicalKeyboardKey.end: 'End',
      LogicalKeyboardKey.pageUp: 'Page Up',
      LogicalKeyboardKey.pageDown: 'Page Down',
    };

    return keyMap[key] ?? key.keyLabel.toUpperCase();
  }

  @override
  String toString() {
    return 'ShortcutCombination($displayText: $description)';
  }
}

/// 快捷键动作
typedef ShortcutAction = Future<bool> Function();

/// 快捷键条目
class ShortcutEntry {
  final String id;
  final ShortcutCombination combination;
  final ShortcutAction action;
  final String category;
  final bool enabled;
  final int priority;

  const ShortcutEntry({
    required this.id,
    required this.combination,
    required this.action,
    this.category = 'general',
    this.enabled = true,
    this.priority = 0,
  });

  /// 创建副本
  ShortcutEntry copyWith({
    String? id,
    ShortcutCombination? combination,
    ShortcutAction? action,
    String? category,
    bool? enabled,
    int? priority,
  }) {
    return ShortcutEntry(
      id: id ?? this.id,
      combination: combination ?? this.combination,
      action: action ?? this.action,
      category: category ?? this.category,
      enabled: enabled ?? this.enabled,
      priority: priority ?? this.priority,
    );
  }
}

/// 键盘快捷键管理器
///
/// Phase 3.3.2.3 核心功能：
/// - 快捷键注册和管理
/// - 按键事件处理
/// - 自定义快捷键配置
/// - 快捷键冲突检测
/// - 无障碍支持
class KeyboardShortcutManager {
  KeyboardShortcutManager._();

  static final KeyboardShortcutManager _instance = KeyboardShortcutManager._();
  static KeyboardShortcutManager get instance => _instance;

  /// 统一消息总线
  final comm.UnifiedMessageBus _messageBus = comm.UnifiedMessageBus.instance;

  /// 注册的快捷键
  final Map<String, ShortcutEntry> _shortcuts = {};

  /// 当前按下的按键
  final Set<LogicalKeyboardKey> _pressedKeys = {};

  /// 快捷键分类
  final Map<String, List<String>> _categories = {};

  /// 是否启用快捷键
  bool _enabled = true;

  /// 快捷键事件流
  final StreamController<ShortcutEntry> _shortcutController =
      StreamController<ShortcutEntry>.broadcast();

  /// 初始化快捷键管理器
  Future<void> initialize() async {
    try {
      _registerDefaultShortcuts();
      debugPrint('KeyboardShortcutManager initialized');
    } catch (e, stackTrace) {
      debugPrint('Failed to initialize KeyboardShortcutManager: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// 注册默认快捷键
  void _registerDefaultShortcuts() {
    // 导航快捷键
    registerShortcut(
      ShortcutEntry(
        id: 'navigate_back',
        combination: ShortcutCombination.simple(
          key: LogicalKeyboardKey.arrowLeft,
          description: '返回上一页',
          alt: true,
        ),
        action: () async {
          _messageBus.publishEvent('keyboard_shortcut', 'navigate_back', {});
          return true;
        },
        category: 'navigation',
      ),
    );

    registerShortcut(
      ShortcutEntry(
        id: 'navigate_forward',
        combination: ShortcutCombination.simple(
          key: LogicalKeyboardKey.arrowRight,
          description: '前进到下一页',
          alt: true,
        ),
        action: () async {
          _messageBus.publishEvent('keyboard_shortcut', 'navigate_forward', {});
          return true;
        },
        category: 'navigation',
      ),
    );

    // 页面快捷键
    registerShortcut(
      ShortcutEntry(
        id: 'go_home',
        combination: ShortcutCombination.simple(
          key: LogicalKeyboardKey.keyH,
          description: '回到首页',
          ctrl: true,
        ),
        action: () async {
          _messageBus.publishEvent('keyboard_shortcut', 'navigate_to', {
            'route': '/',
          });
          return true;
        },
        category: 'navigation',
      ),
    );

    registerShortcut(
      ShortcutEntry(
        id: 'go_workshop',
        combination: ShortcutCombination.simple(
          key: LogicalKeyboardKey.keyW,
          description: '打开创意工坊',
          ctrl: true,
        ),
        action: () async {
          _messageBus.publishEvent('keyboard_shortcut', 'navigate_to', {
            'route': '/workshop',
          });
          return true;
        },
        category: 'navigation',
      ),
    );

    registerShortcut(
      ShortcutEntry(
        id: 'go_notes',
        combination: ShortcutCombination.simple(
          key: LogicalKeyboardKey.keyN,
          description: '打开事务管理',
          ctrl: true,
        ),
        action: () async {
          _messageBus.publishEvent('keyboard_shortcut', 'navigate_to', {
            'route': '/notes',
          });
          return true;
        },
        category: 'navigation',
      ),
    );

    // 应用快捷键
    registerShortcut(
      ShortcutEntry(
        id: 'show_help',
        combination: ShortcutCombination.simple(
          key: LogicalKeyboardKey.f1,
          description: '显示帮助',
        ),
        action: () async {
          _messageBus.publishEvent('keyboard_shortcut', 'show_help', {});
          return true;
        },
        category: 'application',
      ),
    );

    registerShortcut(
      ShortcutEntry(
        id: 'show_settings',
        combination: ShortcutCombination.simple(
          key: LogicalKeyboardKey.comma,
          description: '打开设置',
          ctrl: true,
        ),
        action: () async {
          _messageBus.publishEvent('keyboard_shortcut', 'navigate_to', {
            'route': '/settings',
          });
          return true;
        },
        category: 'application',
      ),
    );

    // 搜索快捷键
    registerShortcut(
      ShortcutEntry(
        id: 'global_search',
        combination: ShortcutCombination.simple(
          key: LogicalKeyboardKey.keyF,
          description: '全局搜索',
          ctrl: true,
        ),
        action: () async {
          _messageBus.publishEvent('keyboard_shortcut', 'show_search', {});
          return true;
        },
        category: 'search',
      ),
    );

    // 无障碍快捷键
    registerShortcut(
      ShortcutEntry(
        id: 'toggle_accessibility',
        combination: ShortcutCombination.simple(
          key: LogicalKeyboardKey.keyA,
          description: '切换无障碍模式',
          ctrl: true,
          shift: true,
        ),
        action: () async {
          _messageBus.publishEvent(
            'keyboard_shortcut',
            'toggle_accessibility',
            {},
          );
          return true;
        },
        category: 'accessibility',
      ),
    );
  }

  /// 注册快捷键
  void registerShortcut(ShortcutEntry shortcut) {
    // 检查冲突
    if (_hasConflict(shortcut)) {
      debugPrint('Shortcut conflict detected for: ${shortcut.id}');
      return;
    }

    _shortcuts[shortcut.id] = shortcut;

    // 添加到分类
    _categories.putIfAbsent(shortcut.category, () => []);
    if (!_categories[shortcut.category]!.contains(shortcut.id)) {
      _categories[shortcut.category]!.add(shortcut.id);
    }

    _messageBus.publishEvent('keyboard_shortcut', 'shortcut_registered', {
      'id': shortcut.id,
      'combination': shortcut.combination.displayText,
      'category': shortcut.category,
    });

    debugPrint(
      'Registered shortcut: ${shortcut.combination.displayText} -> ${shortcut.id}',
    );
  }

  /// 注销快捷键
  void unregisterShortcut(String shortcutId) {
    final shortcut = _shortcuts.remove(shortcutId);
    if (shortcut != null) {
      _categories[shortcut.category]?.remove(shortcutId);

      _messageBus.publishEvent('keyboard_shortcut', 'shortcut_unregistered', {
        'id': shortcutId,
      });

      debugPrint('Unregistered shortcut: $shortcutId');
    }
  }

  /// 处理按键按下事件
  Future<bool> handleKeyDown(LogicalKeyboardKey key) async {
    if (!_enabled) return false;

    _pressedKeys.add(key);

    // 查找匹配的快捷键
    final matchingShortcuts = _findMatchingShortcuts(_pressedKeys);

    if (matchingShortcuts.isNotEmpty) {
      // 按优先级排序
      matchingShortcuts.sort((a, b) => b.priority.compareTo(a.priority));

      final shortcut = matchingShortcuts.first;
      if (shortcut.enabled) {
        try {
          final handled = await shortcut.action();
          if (handled) {
            _shortcutController.add(shortcut);

            _messageBus.publishEvent('keyboard_shortcut', 'shortcut_executed', {
              'id': shortcut.id,
              'combination': shortcut.combination.displayText,
              'timestamp': DateTime.now().toIso8601String(),
            });

            debugPrint('Executed shortcut: ${shortcut.id}');
            return true;
          }
        } catch (e) {
          debugPrint('Error executing shortcut ${shortcut.id}: $e');
        }
      }
    }

    return false;
  }

  /// 处理按键释放事件
  void handleKeyUp(LogicalKeyboardKey key) {
    _pressedKeys.remove(key);
  }

  /// 查找匹配的快捷键
  List<ShortcutEntry> _findMatchingShortcuts(
    Set<LogicalKeyboardKey> pressedKeys,
  ) {
    return _shortcuts.values
        .where((shortcut) => shortcut.combination.matches(pressedKeys))
        .toList();
  }

  /// 检查快捷键冲突
  bool _hasConflict(ShortcutEntry newShortcut) {
    return _shortcuts.values.any(
      (existing) =>
          _setsEqual(existing.combination.keys, newShortcut.combination.keys) &&
          existing.category == newShortcut.category,
    );
  }

  /// 比较两个Set是否相等
  bool _setsEqual<T>(Set<T> set1, Set<T> set2) {
    if (set1.length != set2.length) return false;
    return set1.every((element) => set2.contains(element));
  }

  /// 启用/禁用快捷键
  void setEnabled(bool enabled) {
    _enabled = enabled;

    _messageBus.publishEvent('keyboard_shortcut', 'shortcuts_toggled', {
      'enabled': enabled,
    });

    debugPrint('Shortcuts ${enabled ? 'enabled' : 'disabled'}');
  }

  /// 启用/禁用特定快捷键
  void setShortcutEnabled(String shortcutId, bool enabled) {
    final shortcut = _shortcuts[shortcutId];
    if (shortcut != null) {
      _shortcuts[shortcutId] = shortcut.copyWith(enabled: enabled);

      _messageBus.publishEvent('keyboard_shortcut', 'shortcut_toggled', {
        'id': shortcutId,
        'enabled': enabled,
      });
    }
  }

  /// 获取快捷键列表
  List<ShortcutEntry> getShortcuts({String? category}) {
    if (category != null) {
      final categoryIds = _categories[category] ?? [];
      return categoryIds
          .map((id) => _shortcuts[id])
          .where((shortcut) => shortcut != null)
          .cast<ShortcutEntry>()
          .toList();
    }

    return List.unmodifiable(_shortcuts.values);
  }

  /// 获取快捷键分类
  List<String> get categories => List.unmodifiable(_categories.keys);

  /// 获取快捷键帮助信息
  Map<String, List<Map<String, String>>> getShortcutHelp() {
    final help = <String, List<Map<String, String>>>{};

    for (final category in _categories.keys) {
      help[category] = getShortcuts(category: category)
          .where((shortcut) => shortcut.enabled)
          .map(
            (shortcut) => {
              'combination': shortcut.combination.displayText,
              'description': shortcut.combination.description,
            },
          )
          .toList();
    }

    return help;
  }

  /// 清除所有按键状态
  void clearPressedKeys() {
    _pressedKeys.clear();
  }

  /// 是否启用
  bool get enabled => _enabled;

  /// 快捷键事件流
  Stream<ShortcutEntry> get shortcutStream => _shortcutController.stream;

  /// 清理资源
  void dispose() {
    _shortcutController.close();
    _shortcuts.clear();
    _categories.clear();
    _pressedKeys.clear();

    debugPrint('KeyboardShortcutManager disposed');
  }
}
