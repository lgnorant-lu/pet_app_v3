/*
---------------------------------------------------------------
File name:          navigation_shortcuts_basic_test.dart
Author:             Pet App V3 Team
Date created:       2025-07-19
Last modified:      2025-07-19
Dart Version:       3.2+
Description:        Phase 3.3.2.3 快捷键基础测试（纯Dart版）
---------------------------------------------------------------
Change History:
    2025-07-19: Phase 3.3.2.3 - 实现快捷键基础测试;
---------------------------------------------------------------
*/

import 'package:test/test.dart';
import 'dart:async';

/// 简化的快捷键组合（用于测试）
class SimpleShortcut {
  final String id;
  final Set<String> keys;
  final String description;
  final String category;
  final bool enabled;
  final int priority;

  const SimpleShortcut({
    required this.id,
    required this.keys,
    required this.description,
    this.category = 'general',
    this.enabled = true,
    this.priority = 0,
  });

  bool matches(Set<String> pressedKeys) {
    return keys.every((key) => pressedKeys.contains(key));
  }

  String get displayText {
    return keys.join(' + ').toUpperCase();
  }

  SimpleShortcut copyWith({
    String? id,
    Set<String>? keys,
    String? description,
    String? category,
    bool? enabled,
    int? priority,
  }) {
    return SimpleShortcut(
      id: id ?? this.id,
      keys: keys ?? this.keys,
      description: description ?? this.description,
      category: category ?? this.category,
      enabled: enabled ?? this.enabled,
      priority: priority ?? this.priority,
    );
  }
}

/// 简化的快捷键管理器（用于测试）
class SimpleShortcutManager {
  final Map<String, SimpleShortcut> _shortcuts = {};
  final Set<String> _pressedKeys = {};
  final Map<String, List<String>> _categories = {};
  bool _enabled = true;

  final StreamController<SimpleShortcut> _shortcutController =
      StreamController<SimpleShortcut>.broadcast();

  final List<String> _executedActions = [];

  /// 注册快捷键
  void registerShortcut(SimpleShortcut shortcut) {
    if (_hasConflict(shortcut)) {
      return;
    }

    _shortcuts[shortcut.id] = shortcut;

    _categories.putIfAbsent(shortcut.category, () => []);
    if (!_categories[shortcut.category]!.contains(shortcut.id)) {
      _categories[shortcut.category]!.add(shortcut.id);
    }
  }

  /// 注销快捷键
  void unregisterShortcut(String shortcutId) {
    final shortcut = _shortcuts.remove(shortcutId);
    if (shortcut != null) {
      _categories[shortcut.category]?.remove(shortcutId);
    }
  }

  /// 处理按键按下
  bool handleKeyDown(String key) {
    if (!_enabled) return false;

    _pressedKeys.add(key);

    final matchingShortcuts = _findMatchingShortcuts(_pressedKeys);

    if (matchingShortcuts.isNotEmpty) {
      matchingShortcuts.sort((a, b) => b.priority.compareTo(a.priority));

      final shortcut = matchingShortcuts.first;
      if (shortcut.enabled) {
        _executedActions.add(shortcut.id);
        _shortcutController.add(shortcut);
        return true;
      }
    }

    return false;
  }

  /// 处理按键释放
  void handleKeyUp(String key) {
    _pressedKeys.remove(key);
  }

  /// 查找匹配的快捷键
  List<SimpleShortcut> _findMatchingShortcuts(Set<String> pressedKeys) {
    return _shortcuts.values
        .where((shortcut) => shortcut.matches(pressedKeys))
        .toList();
  }

  /// 检查快捷键冲突
  bool _hasConflict(SimpleShortcut newShortcut) {
    return _shortcuts.values.any(
      (existing) =>
          existing.keys.difference(newShortcut.keys).isEmpty &&
          newShortcut.keys.difference(existing.keys).isEmpty &&
          existing.category == newShortcut.category,
    );
  }

  /// 启用/禁用快捷键
  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// 启用/禁用特定快捷键
  void setShortcutEnabled(String shortcutId, bool enabled) {
    final shortcut = _shortcuts[shortcutId];
    if (shortcut != null) {
      _shortcuts[shortcutId] = shortcut.copyWith(enabled: enabled);
    }
  }

  /// 获取快捷键列表
  List<SimpleShortcut> getShortcuts({String? category}) {
    if (category != null) {
      final categoryIds = _categories[category] ?? [];
      return categoryIds
          .map((id) => _shortcuts[id])
          .where((shortcut) => shortcut != null)
          .cast<SimpleShortcut>()
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
              'combination': shortcut.displayText,
              'description': shortcut.description,
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

  /// 获取执行的动作
  List<String> get executedActions => List.unmodifiable(_executedActions);

  /// 清除执行历史
  void clearExecutedActions() {
    _executedActions.clear();
  }

  /// 是否启用
  bool get enabled => _enabled;

  /// 快捷键事件流
  Stream<SimpleShortcut> get shortcutStream => _shortcutController.stream;

  /// 清理资源
  void dispose() {
    _shortcutController.close();
    _shortcuts.clear();
    _categories.clear();
    _pressedKeys.clear();
    _executedActions.clear();
  }
}

void main() {
  group('Navigation Shortcuts Basic Tests', () {
    late SimpleShortcutManager shortcutManager;

    setUp(() {
      shortcutManager = SimpleShortcutManager();
    });

    tearDown(() {
      shortcutManager.dispose();
    });

    group('快捷键基础功能', () {
      test('应该能够注册快捷键', () {
        final shortcut = SimpleShortcut(
          id: 'go_home',
          keys: {'ctrl', 'h'},
          description: '回到首页',
          category: 'navigation',
        );

        shortcutManager.registerShortcut(shortcut);

        final shortcuts = shortcutManager.getShortcuts();
        expect(shortcuts.length, equals(1));
        expect(shortcuts.first.id, equals('go_home'));
        expect(shortcuts.first.category, equals('navigation'));
      });

      test('应该能够注销快捷键', () {
        final shortcut = SimpleShortcut(
          id: 'test_shortcut',
          keys: {'t'},
          description: '测试快捷键',
        );

        shortcutManager.registerShortcut(shortcut);
        expect(shortcutManager.getShortcuts().length, equals(1));

        shortcutManager.unregisterShortcut('test_shortcut');
        expect(shortcutManager.getShortcuts().length, equals(0));
      });

      test('应该拒绝冲突的快捷键', () {
        final shortcut1 = SimpleShortcut(
          id: 'shortcut1',
          keys: {'ctrl', 'h'},
          description: '快捷键1',
          category: 'navigation',
        );

        final shortcut2 = SimpleShortcut(
          id: 'shortcut2',
          keys: {'ctrl', 'h'},
          description: '快捷键2',
          category: 'navigation',
        );

        shortcutManager.registerShortcut(shortcut1);
        shortcutManager.registerShortcut(shortcut2);

        // 应该只有第一个快捷键被注册
        expect(shortcutManager.getShortcuts().length, equals(1));
        expect(shortcutManager.getShortcuts().first.id, equals('shortcut1'));
      });

      test('应该允许不同分类的相同快捷键', () {
        final shortcut1 = SimpleShortcut(
          id: 'nav_shortcut',
          keys: {'ctrl', 'h'},
          description: '导航快捷键',
          category: 'navigation',
        );

        final shortcut2 = SimpleShortcut(
          id: 'app_shortcut',
          keys: {'ctrl', 'h'},
          description: '应用快捷键',
          category: 'application',
        );

        shortcutManager.registerShortcut(shortcut1);
        shortcutManager.registerShortcut(shortcut2);

        // 不同分类应该都能注册
        expect(shortcutManager.getShortcuts().length, equals(2));
      });
    });

    group('快捷键执行', () {
      test('应该能够执行匹配的快捷键', () {
        final shortcut = SimpleShortcut(
          id: 'test_action',
          keys: {'ctrl', 'h'},
          description: '测试动作',
        );

        shortcutManager.registerShortcut(shortcut);

        // 模拟按键
        shortcutManager.handleKeyDown('ctrl');
        final handled = shortcutManager.handleKeyDown('h');

        expect(handled, isTrue);
        expect(shortcutManager.executedActions, contains('test_action'));
      });

      test('应该按优先级执行快捷键', () {
        final lowPriorityShortcut = SimpleShortcut(
          id: 'low_priority',
          keys: {'ctrl', 'h'},
          description: '低优先级',
          priority: 1,
          category: 'test1', // 不同分类避免冲突检测
        );

        final highPriorityShortcut = SimpleShortcut(
          id: 'high_priority',
          keys: {'ctrl', 'h'},
          description: '高优先级',
          priority: 10,
          category: 'test2', // 不同分类避免冲突检测
        );

        shortcutManager.registerShortcut(lowPriorityShortcut);
        shortcutManager.registerShortcut(highPriorityShortcut);

        shortcutManager.handleKeyDown('ctrl');
        shortcutManager.handleKeyDown('h');

        expect(shortcutManager.executedActions, contains('high_priority'));
        expect(
          shortcutManager.executedActions,
          isNot(contains('low_priority')),
        );
      });

      test('应该忽略禁用的快捷键', () {
        final shortcut = SimpleShortcut(
          id: 'disabled_shortcut',
          keys: {'ctrl', 'h'},
          description: '禁用的快捷键',
          enabled: false,
        );

        shortcutManager.registerShortcut(shortcut);

        shortcutManager.handleKeyDown('ctrl');
        final handled = shortcutManager.handleKeyDown('h');

        expect(handled, isFalse);
        expect(shortcutManager.executedActions, isEmpty);
      });

      test('应该处理按键释放', () {
        final shortcut = SimpleShortcut(
          id: 'test_shortcut',
          keys: {'ctrl', 'h'},
          description: '测试快捷键',
        );

        shortcutManager.registerShortcut(shortcut);

        shortcutManager.handleKeyDown('ctrl');
        shortcutManager.handleKeyDown('h');

        shortcutManager.handleKeyUp('h');
        shortcutManager.handleKeyUp('ctrl');

        // 释放按键后应该无法再次触发
        shortcutManager.clearExecutedActions();
        final handled = shortcutManager.handleKeyDown('h');
        expect(handled, isFalse);
      });
    });

    group('快捷键分类和帮助', () {
      test('应该能够按分类获取快捷键', () {
        final navShortcut = SimpleShortcut(
          id: 'nav_shortcut',
          keys: {'ctrl', 'h'},
          description: '导航快捷键',
          category: 'navigation',
        );

        final appShortcut = SimpleShortcut(
          id: 'app_shortcut',
          keys: {'ctrl', 'q'},
          description: '应用快捷键',
          category: 'application',
        );

        shortcutManager.registerShortcut(navShortcut);
        shortcutManager.registerShortcut(appShortcut);

        final navShortcuts = shortcutManager.getShortcuts(
          category: 'navigation',
        );
        final appShortcuts = shortcutManager.getShortcuts(
          category: 'application',
        );

        expect(navShortcuts.length, equals(1));
        expect(navShortcuts.first.id, equals('nav_shortcut'));
        expect(appShortcuts.length, equals(1));
        expect(appShortcuts.first.id, equals('app_shortcut'));
      });

      test('应该能够获取分类列表', () {
        final shortcuts = [
          SimpleShortcut(
            id: 'nav1',
            keys: {'h'},
            description: '导航1',
            category: 'navigation',
          ),
          SimpleShortcut(
            id: 'app1',
            keys: {'q'},
            description: '应用1',
            category: 'application',
          ),
          SimpleShortcut(
            id: 'edit1',
            keys: {'c'},
            description: '编辑1',
            category: 'editing',
          ),
        ];

        for (final shortcut in shortcuts) {
          shortcutManager.registerShortcut(shortcut);
        }

        final categories = shortcutManager.categories;
        expect(
          categories,
          containsAll(['navigation', 'application', 'editing']),
        );
      });

      test('应该能够生成帮助信息', () {
        final shortcut = SimpleShortcut(
          id: 'help_test',
          keys: {'ctrl', 'h'},
          description: '显示帮助',
          category: 'help',
        );

        shortcutManager.registerShortcut(shortcut);

        final help = shortcutManager.getShortcutHelp();
        expect(help['help'], isNotNull);
        expect(help['help']!.length, equals(1));
        expect(help['help']!.first['combination'], equals('CTRL + H'));
        expect(help['help']!.first['description'], equals('显示帮助'));
      });
    });

    group('快捷键状态管理', () {
      test('应该能够启用/禁用快捷键系统', () {
        shortcutManager.setEnabled(false);
        expect(shortcutManager.enabled, isFalse);

        shortcutManager.setEnabled(true);
        expect(shortcutManager.enabled, isTrue);
      });

      test('应该能够启用/禁用特定快捷键', () {
        final shortcut = SimpleShortcut(
          id: 'toggle_test',
          keys: {'h'},
          description: '切换测试',
        );

        shortcutManager.registerShortcut(shortcut);
        expect(shortcutManager.getShortcuts().first.enabled, isTrue);

        shortcutManager.setShortcutEnabled('toggle_test', false);
        expect(shortcutManager.getShortcuts().first.enabled, isFalse);

        shortcutManager.setShortcutEnabled('toggle_test', true);
        expect(shortcutManager.getShortcuts().first.enabled, isTrue);
      });

      test('应该能够清除按键状态', () {
        final shortcut = SimpleShortcut(
          id: 'clear_test',
          keys: {'ctrl', 'h'},
          description: '清除测试',
        );

        shortcutManager.registerShortcut(shortcut);

        shortcutManager.handleKeyDown('ctrl');
        shortcutManager.clearPressedKeys();

        // 清除后应该无法触发快捷键
        final handled = shortcutManager.handleKeyDown('h');
        expect(handled, isFalse);
        expect(shortcutManager.executedActions, isEmpty);
      });
    });

    group('流监听', () {
      test('应该能够监听快捷键执行事件', () async {
        final executedShortcuts = <SimpleShortcut>[];
        final subscription = shortcutManager.shortcutStream.listen(
          (shortcut) => executedShortcuts.add(shortcut),
        );

        final shortcut = SimpleShortcut(
          id: 'stream_test',
          keys: {'ctrl', 'h'},
          description: '流测试',
        );

        shortcutManager.registerShortcut(shortcut);

        shortcutManager.handleKeyDown('ctrl');
        shortcutManager.handleKeyDown('h');

        // 等待流事件
        await Future.delayed(const Duration(milliseconds: 10));

        expect(executedShortcuts.length, equals(1));
        expect(executedShortcuts.first.id, equals('stream_test'));

        await subscription.cancel();
      });
    });

    group('快捷键显示', () {
      test('应该正确显示快捷键文本', () {
        final shortcuts = [
          SimpleShortcut(id: '1', keys: {'ctrl', 'h'}, description: 'Home'),
          SimpleShortcut(
            id: '2',
            keys: {'ctrl', 'shift', 'w'},
            description: 'Workshop',
          ),
          SimpleShortcut(id: '3', keys: {'f1'}, description: 'Help'),
          SimpleShortcut(id: '4', keys: {'alt', 'left'}, description: 'Back'),
        ];

        expect(shortcuts[0].displayText, equals('CTRL + H'));
        expect(shortcuts[1].displayText, equals('CTRL + SHIFT + W'));
        expect(shortcuts[2].displayText, equals('F1'));
        expect(shortcuts[3].displayText, equals('ALT + LEFT'));
      });

      test('应该正确匹配按键组合', () {
        final shortcut = SimpleShortcut(
          id: 'match_test',
          keys: {'ctrl', 'shift', 'w'},
          description: '匹配测试',
        );

        // 匹配的按键组合
        expect(shortcut.matches({'ctrl', 'shift', 'w'}), isTrue);
        expect(shortcut.matches({'ctrl', 'shift', 'w', 'extra'}), isTrue);

        // 不匹配的按键组合
        expect(shortcut.matches({'ctrl', 'w'}), isFalse);
        expect(shortcut.matches({'shift', 'w'}), isFalse);
        expect(shortcut.matches({'w'}), isFalse);
        expect(shortcut.matches({}), isFalse);
      });
    });
  });
}
