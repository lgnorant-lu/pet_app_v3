/*
---------------------------------------------------------------
File name:          app_status_bar_test.dart
Author:             Pet App V3 Team
Date created:       2025-07-19
Last modified:      2025-07-19
Dart Version:       3.2+
Description:        应用状态栏测试 - 纯Dart版本
---------------------------------------------------------------
*/

import 'package:test/test.dart';
import 'dart:async';

/// 状态栏项目类型
enum TestStatusBarItemType {
  systemStatus,
  moduleStatus,
  notification,
  performance,
  custom,
}

/// 测试状态栏项目
class TestStatusBarItem {
  final String id;
  final TestStatusBarItemType type;
  final String content;
  final int priority;
  final bool visible;
  final Duration? updateInterval;

  const TestStatusBarItem({
    required this.id,
    required this.type,
    required this.content,
    this.priority = 0,
    this.visible = true,
    this.updateInterval,
  });
}

/// 状态栏通知
class TestStatusBarNotification {
  final String id;
  final String message;
  final TestNotificationLevel level;
  final DateTime timestamp;
  final Duration? duration;

  TestStatusBarNotification({
    required this.id,
    required this.message,
    required this.level,
    DateTime? timestamp,
    this.duration,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// 通知级别
enum TestNotificationLevel {
  info,
  warning,
  error,
  success,
}

/// 简化的应用状态栏管理器（测试版本）
class TestAppStatusBarManager {
  final Map<String, TestStatusBarItem> _items = {};
  final List<TestStatusBarNotification> _notifications = [];
  final StreamController<TestStatusBarItem> _itemController = StreamController<TestStatusBarItem>.broadcast();
  final StreamController<TestStatusBarNotification> _notificationController = StreamController<TestStatusBarNotification>.broadcast();
  
  Stream<TestStatusBarItem> get itemStream => _itemController.stream;
  Stream<TestStatusBarNotification> get notificationStream => _notificationController.stream;
  
  /// 添加状态栏项目
  void addItem(TestStatusBarItem item) {
    _items[item.id] = item;
    _itemController.add(item);
  }
  
  /// 移除状态栏项目
  void removeItem(String id) {
    final item = _items.remove(id);
    if (item != null) {
      final removedItem = TestStatusBarItem(
        id: item.id,
        type: item.type,
        content: '',
        visible: false,
      );
      _itemController.add(removedItem);
    }
  }
  
  /// 更新状态栏项目
  void updateItem(String id, String content) {
    final item = _items[id];
    if (item != null) {
      final updatedItem = TestStatusBarItem(
        id: item.id,
        type: item.type,
        content: content,
        priority: item.priority,
        visible: item.visible,
        updateInterval: item.updateInterval,
      );
      _items[id] = updatedItem;
      _itemController.add(updatedItem);
    }
  }
  
  /// 显示通知
  void showNotification(TestStatusBarNotification notification) {
    _notifications.add(notification);
    _notificationController.add(notification);
    
    // 自动清理过期通知
    if (notification.duration != null) {
      Timer(notification.duration!, () {
        _notifications.removeWhere((n) => n.id == notification.id);
      });
    }
  }
  
  /// 清除通知
  void clearNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
  }
  
  /// 获取可见项目
  List<TestStatusBarItem> getVisibleItems() {
    final items = _items.values.where((item) => item.visible).toList();
    items.sort((a, b) => b.priority.compareTo(a.priority));
    return items;
  }
  
  /// 获取活跃通知
  List<TestStatusBarNotification> getActiveNotifications() {
    return List.unmodifiable(_notifications);
  }
  
  /// 获取项目数量
  int get itemCount => _items.length;
  
  /// 获取通知数量
  int get notificationCount => _notifications.length;
  
  /// 检查项目是否存在
  bool hasItem(String id) => _items.containsKey(id);
  
  /// 获取项目
  TestStatusBarItem? getItem(String id) => _items[id];
  
  /// 清理资源
  void dispose() {
    _items.clear();
    _notifications.clear();
    _itemController.close();
    _notificationController.close();
  }
}

void main() {
  group('AppStatusBar Tests', () {
    late TestAppStatusBarManager statusBar;
    
    setUp(() {
      statusBar = TestAppStatusBarManager();
    });
    
    tearDown(() {
      statusBar.dispose();
    });
    
    group('状态栏项目管理', () {
      test('应该能够添加状态栏项目', () {
        final item = TestStatusBarItem(
          id: 'system_status',
          type: TestStatusBarItemType.systemStatus,
          content: '系统正常',
          priority: 10,
        );
        
        statusBar.addItem(item);
        
        expect(statusBar.hasItem('system_status'), isTrue);
        expect(statusBar.itemCount, equals(1));
        expect(statusBar.getItem('system_status')?.content, equals('系统正常'));
      });
      
      test('应该能够移除状态栏项目', () {
        final item = TestStatusBarItem(
          id: 'test_item',
          type: TestStatusBarItemType.custom,
          content: '测试项目',
        );
        
        statusBar.addItem(item);
        expect(statusBar.hasItem('test_item'), isTrue);
        
        statusBar.removeItem('test_item');
        expect(statusBar.hasItem('test_item'), isFalse);
        expect(statusBar.itemCount, equals(0));
      });
      
      test('应该能够更新状态栏项目', () {
        final item = TestStatusBarItem(
          id: 'update_test',
          type: TestStatusBarItemType.moduleStatus,
          content: '初始内容',
        );
        
        statusBar.addItem(item);
        statusBar.updateItem('update_test', '更新内容');
        
        expect(statusBar.getItem('update_test')?.content, equals('更新内容'));
      });
    });
    
    group('通知管理', () {
      test('应该能够显示通知', () {
        final notification = TestStatusBarNotification(
          id: 'test_notification',
          message: '测试通知',
          level: TestNotificationLevel.info,
        );
        
        statusBar.showNotification(notification);
        
        expect(statusBar.notificationCount, equals(1));
        expect(statusBar.getActiveNotifications().first.message, equals('测试通知'));
      });
      
      test('应该能够清除通知', () {
        final notification = TestStatusBarNotification(
          id: 'clear_test',
          message: '待清除通知',
          level: TestNotificationLevel.warning,
        );
        
        statusBar.showNotification(notification);
        expect(statusBar.notificationCount, equals(1));
        
        statusBar.clearNotification('clear_test');
        expect(statusBar.notificationCount, equals(0));
      });
      
      test('应该自动清理过期通知', () async {
        final notification = TestStatusBarNotification(
          id: 'auto_clear',
          message: '自动清理通知',
          level: TestNotificationLevel.success,
          duration: const Duration(milliseconds: 100),
        );
        
        statusBar.showNotification(notification);
        expect(statusBar.notificationCount, equals(1));
        
        await Future.delayed(const Duration(milliseconds: 150));
        expect(statusBar.notificationCount, equals(0));
      });
    });
    
    group('优先级和排序', () {
      test('应该按优先级排序可见项目', () {
        final items = [
          TestStatusBarItem(
            id: 'low_priority',
            type: TestStatusBarItemType.custom,
            content: '低优先级',
            priority: 1,
          ),
          TestStatusBarItem(
            id: 'high_priority',
            type: TestStatusBarItemType.systemStatus,
            content: '高优先级',
            priority: 10,
          ),
          TestStatusBarItem(
            id: 'medium_priority',
            type: TestStatusBarItemType.moduleStatus,
            content: '中优先级',
            priority: 5,
          ),
        ];
        
        for (final item in items) {
          statusBar.addItem(item);
        }
        
        final visibleItems = statusBar.getVisibleItems();
        expect(visibleItems.length, equals(3));
        expect(visibleItems[0].id, equals('high_priority'));
        expect(visibleItems[1].id, equals('medium_priority'));
        expect(visibleItems[2].id, equals('low_priority'));
      });
      
      test('应该过滤不可见项目', () {
        final items = [
          TestStatusBarItem(
            id: 'visible',
            type: TestStatusBarItemType.systemStatus,
            content: '可见项目',
            visible: true,
          ),
          TestStatusBarItem(
            id: 'hidden',
            type: TestStatusBarItemType.custom,
            content: '隐藏项目',
            visible: false,
          ),
        ];
        
        for (final item in items) {
          statusBar.addItem(item);
        }
        
        final visibleItems = statusBar.getVisibleItems();
        expect(visibleItems.length, equals(1));
        expect(visibleItems.first.id, equals('visible'));
      });
    });
    
    group('事件流监听', () {
      test('应该能够监听项目变更', () async {
        final receivedItems = <TestStatusBarItem>[];
        final subscription = statusBar.itemStream.listen((item) {
          receivedItems.add(item);
        });
        
        final item = TestStatusBarItem(
          id: 'stream_test',
          type: TestStatusBarItemType.performance,
          content: '流测试',
        );
        
        statusBar.addItem(item);
        await Future.delayed(const Duration(milliseconds: 10));
        
        expect(receivedItems.length, equals(1));
        expect(receivedItems.first.id, equals('stream_test'));
        
        await subscription.cancel();
      });
      
      test('应该能够监听通知', () async {
        final receivedNotifications = <TestStatusBarNotification>[];
        final subscription = statusBar.notificationStream.listen((notification) {
          receivedNotifications.add(notification);
        });
        
        final notification = TestStatusBarNotification(
          id: 'stream_notification',
          message: '流通知测试',
          level: TestNotificationLevel.error,
        );
        
        statusBar.showNotification(notification);
        await Future.delayed(const Duration(milliseconds: 10));
        
        expect(receivedNotifications.length, equals(1));
        expect(receivedNotifications.first.message, equals('流通知测试'));
        
        await subscription.cancel();
      });
    });
  });
}
