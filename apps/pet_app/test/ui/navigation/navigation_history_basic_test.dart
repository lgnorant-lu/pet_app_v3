/*
---------------------------------------------------------------
File name:          navigation_history_basic_test.dart
Author:             Pet App V3 Team
Date created:       2025-07-19
Last modified:      2025-07-19
Dart Version:       3.2+
Description:        Phase 3.3.2.2 导航历史记录基础测试（纯Dart版）
---------------------------------------------------------------
Change History:
    2025-07-19: Phase 3.3.2.2 - 实现导航历史记录基础测试;
---------------------------------------------------------------
*/

import 'package:test/test.dart';
import 'dart:async';

/// 简化的导航历史条目（用于测试）
class TestNavigationHistoryEntry {
  final String id;
  final String route;
  final Map<String, dynamic> parameters;
  final DateTime timestamp;
  final String? title;
  final String? description;

  const TestNavigationHistoryEntry({
    required this.id,
    required this.route,
    required this.parameters,
    required this.timestamp,
    this.title,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'route': route,
      'parameters': parameters,
      'timestamp': timestamp.toIso8601String(),
      'title': title,
      'description': description,
    };
  }

  factory TestNavigationHistoryEntry.fromJson(Map<String, dynamic> json) {
    return TestNavigationHistoryEntry(
      id: json['id'],
      route: json['route'],
      parameters: Map<String, dynamic>.from(json['parameters'] ?? {}),
      timestamp: DateTime.parse(json['timestamp']),
      title: json['title'],
      description: json['description'],
    );
  }
}

/// 简化的书签条目（用于测试）
class TestBookmarkEntry {
  final String id;
  final String route;
  final Map<String, dynamic> parameters;
  final String title;
  final String? description;
  final DateTime createdAt;
  final DateTime? lastAccessedAt;
  final int accessCount;
  final List<String> tags;

  const TestBookmarkEntry({
    required this.id,
    required this.route,
    required this.parameters,
    required this.title,
    this.description,
    required this.createdAt,
    this.lastAccessedAt,
    this.accessCount = 0,
    this.tags = const [],
  });

  TestBookmarkEntry copyWithAccess() {
    return TestBookmarkEntry(
      id: id,
      route: route,
      parameters: parameters,
      title: title,
      description: description,
      createdAt: createdAt,
      lastAccessedAt: DateTime.now(),
      accessCount: accessCount + 1,
      tags: tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'route': route,
      'parameters': parameters,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'lastAccessedAt': lastAccessedAt?.toIso8601String(),
      'accessCount': accessCount,
      'tags': tags,
    };
  }

  factory TestBookmarkEntry.fromJson(Map<String, dynamic> json) {
    return TestBookmarkEntry(
      id: json['id'],
      route: json['route'],
      parameters: Map<String, dynamic>.from(json['parameters'] ?? {}),
      title: json['title'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      lastAccessedAt: json['lastAccessedAt'] != null 
          ? DateTime.parse(json['lastAccessedAt']) 
          : null,
      accessCount: json['accessCount'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}

/// 简化的导航历史管理器（用于测试）
class TestNavigationHistoryManager {
  final List<TestNavigationHistoryEntry> _historyStack = [];
  final List<TestNavigationHistoryEntry> _forwardStack = [];
  final List<TestBookmarkEntry> _bookmarks = [];
  
  int _currentIndex = -1;
  final int _maxHistorySize = 100;
  final int _maxBookmarkSize = 50;
  
  final StreamController<List<TestNavigationHistoryEntry>> _historyController = 
      StreamController<List<TestNavigationHistoryEntry>>.broadcast();
  
  final StreamController<List<TestBookmarkEntry>> _bookmarkController = 
      StreamController<List<TestBookmarkEntry>>.broadcast();

  /// 添加历史记录
  void addHistory({
    required String route,
    Map<String, dynamic>? parameters,
    String? title,
    String? description,
  }) {
    final entry = TestNavigationHistoryEntry(
      id: _generateId(),
      route: route,
      parameters: parameters ?? {},
      timestamp: DateTime.now(),
      title: title,
      description: description,
    );

    // 如果当前不在历史栈顶部，清除前进历史
    if (_currentIndex < _historyStack.length - 1) {
      _forwardStack.clear();
      _historyStack.removeRange(_currentIndex + 1, _historyStack.length);
    }

    // 添加新记录
    _historyStack.add(entry);
    _currentIndex = _historyStack.length - 1;

    // 限制历史记录数量
    if (_historyStack.length > _maxHistorySize) {
      _historyStack.removeAt(0);
      _currentIndex--;
    }

    _notifyHistoryChanged();
  }

  /// 后退
  TestNavigationHistoryEntry? goBack() {
    if (!canGoBack) return null;

    final currentEntry = _historyStack[_currentIndex];
    _forwardStack.add(currentEntry);
    _currentIndex--;

    final targetEntry = _historyStack[_currentIndex];
    _notifyHistoryChanged();
    
    return targetEntry;
  }

  /// 前进
  TestNavigationHistoryEntry? goForward() {
    if (!canGoForward) return null;

    _currentIndex++;
    final targetEntry = _historyStack[_currentIndex];
    
    if (_forwardStack.isNotEmpty) {
      _forwardStack.removeLast();
    }
    
    _notifyHistoryChanged();
    return targetEntry;
  }

  /// 跳转到指定历史记录
  TestNavigationHistoryEntry? goToHistory(int index) {
    if (index < 0 || index >= _historyStack.length) return null;

    _currentIndex = index;
    final targetEntry = _historyStack[_currentIndex];
    _notifyHistoryChanged();
    
    return targetEntry;
  }

  /// 添加书签
  bool addBookmark({
    required String route,
    Map<String, dynamic>? parameters,
    required String title,
    String? description,
    List<String>? tags,
  }) {
    // 检查是否已存在
    if (_bookmarks.any((bookmark) => 
        bookmark.route == route && 
        _parametersEqual(bookmark.parameters, parameters ?? {}))) {
      return false;
    }

    final bookmark = TestBookmarkEntry(
      id: _generateId(),
      route: route,
      parameters: parameters ?? {},
      title: title,
      description: description,
      createdAt: DateTime.now(),
      tags: tags ?? [],
    );

    _bookmarks.add(bookmark);

    // 限制书签数量
    if (_bookmarks.length > _maxBookmarkSize) {
      _bookmarks.removeAt(0);
    }

    _notifyBookmarkChanged();
    return true;
  }

  /// 移除书签
  bool removeBookmark(String bookmarkId) {
    final index = _bookmarks.indexWhere((bookmark) => bookmark.id == bookmarkId);
    if (index == -1) return false;

    _bookmarks.removeAt(index);
    _notifyBookmarkChanged();
    return true;
  }

  /// 访问书签
  TestBookmarkEntry? accessBookmark(String bookmarkId) {
    final index = _bookmarks.indexWhere((bookmark) => bookmark.id == bookmarkId);
    if (index == -1) return null;

    final updatedBookmark = _bookmarks[index].copyWithAccess();
    _bookmarks[index] = updatedBookmark;
    _notifyBookmarkChanged();
    
    return updatedBookmark;
  }

  /// 清除历史记录
  void clearHistory() {
    _historyStack.clear();
    _forwardStack.clear();
    _currentIndex = -1;
    _notifyHistoryChanged();
  }

  /// 清除书签
  void clearBookmarks() {
    _bookmarks.clear();
    _notifyBookmarkChanged();
  }

  /// 生成唯一ID
  String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${_historyStack.length}';
  }

  /// 比较参数是否相等
  bool _parametersEqual(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;
    
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) {
        return false;
      }
    }
    
    return true;
  }

  /// 通知历史变更
  void _notifyHistoryChanged() {
    _historyController.add(List.unmodifiable(_historyStack));
  }

  /// 通知书签变更
  void _notifyBookmarkChanged() {
    _bookmarkController.add(List.unmodifiable(_bookmarks));
  }

  /// 获取历史记录
  List<TestNavigationHistoryEntry> get history => List.unmodifiable(_historyStack);

  /// 获取书签列表
  List<TestBookmarkEntry> get bookmarks => List.unmodifiable(_bookmarks);

  /// 获取当前历史记录
  TestNavigationHistoryEntry? get currentHistory => 
      _currentIndex >= 0 && _currentIndex < _historyStack.length 
          ? _historyStack[_currentIndex] 
          : null;

  /// 是否可以后退
  bool get canGoBack => _currentIndex > 0;

  /// 是否可以前进
  bool get canGoForward => _currentIndex < _historyStack.length - 1;

  /// 历史记录流
  Stream<List<TestNavigationHistoryEntry>> get historyStream => _historyController.stream;

  /// 书签流
  Stream<List<TestBookmarkEntry>> get bookmarkStream => _bookmarkController.stream;

  /// 清理资源
  void dispose() {
    _historyController.close();
    _bookmarkController.close();
  }
}

void main() {
  group('Navigation History Basic Tests', () {
    late TestNavigationHistoryManager historyManager;

    setUp(() {
      historyManager = TestNavigationHistoryManager();
    });

    tearDown(() {
      historyManager.dispose();
    });

    group('历史记录管理', () {
      test('应该能够添加历史记录', () {
        // 执行
        historyManager.addHistory(
          route: '/workshop',
          parameters: {'mode': 'edit'},
          title: '创意工坊',
          description: '编辑模式',
        );

        // 验证
        final history = historyManager.history;
        expect(history.length, equals(1));
        expect(history.first.route, equals('/workshop'));
        expect(history.first.parameters['mode'], equals('edit'));
        expect(history.first.title, equals('创意工坊'));
      });

      test('应该能够管理多个历史记录', () {
        // 添加多个记录
        historyManager.addHistory(route: '/');
        historyManager.addHistory(route: '/workshop');
        historyManager.addHistory(route: '/notes');

        // 验证
        final history = historyManager.history;
        expect(history.length, equals(3));
        expect(history[0].route, equals('/'));
        expect(history[1].route, equals('/workshop'));
        expect(history[2].route, equals('/notes'));
        
        // 验证当前记录
        final current = historyManager.currentHistory;
        expect(current?.route, equals('/notes'));
      });

      test('应该能够后退', () {
        // 准备
        historyManager.addHistory(route: '/');
        historyManager.addHistory(route: '/workshop');
        historyManager.addHistory(route: '/notes');

        // 执行后退
        final backEntry = historyManager.goBack();

        // 验证
        expect(backEntry?.route, equals('/workshop'));
        expect(historyManager.currentHistory?.route, equals('/workshop'));
        expect(historyManager.canGoBack, isTrue);
        expect(historyManager.canGoForward, isTrue);
      });

      test('应该能够前进', () {
        // 准备
        historyManager.addHistory(route: '/');
        historyManager.addHistory(route: '/workshop');
        historyManager.addHistory(route: '/notes');
        historyManager.goBack(); // 现在在 /workshop

        // 执行前进
        final forwardEntry = historyManager.goForward();

        // 验证
        expect(forwardEntry?.route, equals('/notes'));
        expect(historyManager.currentHistory?.route, equals('/notes'));
        expect(historyManager.canGoForward, isFalse);
      });

      test('应该能够跳转到指定历史记录', () {
        // 准备
        historyManager.addHistory(route: '/');
        historyManager.addHistory(route: '/workshop');
        historyManager.addHistory(route: '/notes');
        historyManager.addHistory(route: '/settings');

        // 执行跳转
        final targetEntry = historyManager.goToHistory(1);

        // 验证
        expect(targetEntry?.route, equals('/workshop'));
        expect(historyManager.currentHistory?.route, equals('/workshop'));
      });

      test('应该正确处理边界情况', () {
        // 空历史时不能后退
        expect(historyManager.canGoBack, isFalse);
        expect(historyManager.goBack(), isNull);

        // 添加一个记录
        historyManager.addHistory(route: '/');
        expect(historyManager.canGoBack, isFalse);
        expect(historyManager.canGoForward, isFalse);

        // 无效索引跳转
        expect(historyManager.goToHistory(-1), isNull);
        expect(historyManager.goToHistory(10), isNull);
      });

      test('应该限制历史记录数量', () {
        // 添加超过限制的记录
        for (int i = 0; i < 150; i++) {
          historyManager.addHistory(route: '/test$i');
        }

        // 验证数量被限制
        final history = historyManager.history;
        expect(history.length, lessThanOrEqualTo(100));
        
        // 验证最新的记录还在
        expect(history.last.route, equals('/test149'));
      });

      test('应该清除历史记录', () {
        // 准备
        historyManager.addHistory(route: '/');
        historyManager.addHistory(route: '/workshop');

        // 执行清除
        historyManager.clearHistory();

        // 验证
        expect(historyManager.history.length, equals(0));
        expect(historyManager.currentHistory, isNull);
        expect(historyManager.canGoBack, isFalse);
        expect(historyManager.canGoForward, isFalse);
      });
    });

    group('书签管理', () {
      test('应该能够添加书签', () {
        // 执行
        final result = historyManager.addBookmark(
          route: '/workshop',
          parameters: {'mode': 'edit'},
          title: '我的工坊',
          description: '创意工坊编辑页面',
          tags: ['工作', '创意'],
        );

        // 验证
        expect(result, isTrue);
        
        final bookmarks = historyManager.bookmarks;
        expect(bookmarks.length, equals(1));
        expect(bookmarks.first.route, equals('/workshop'));
        expect(bookmarks.first.title, equals('我的工坊'));
        expect(bookmarks.first.tags, contains('工作'));
      });

      test('应该拒绝重复的书签', () {
        // 添加第一个书签
        historyManager.addBookmark(
          route: '/workshop',
          title: '工坊1',
        );

        // 尝试添加重复书签
        final result = historyManager.addBookmark(
          route: '/workshop',
          title: '工坊2',
        );

        // 验证
        expect(result, isFalse);
        expect(historyManager.bookmarks.length, equals(1));
      });

      test('应该能够移除书签', () {
        // 准备
        historyManager.addBookmark(
          route: '/workshop',
          title: '我的工坊',
        );
        
        final bookmarkId = historyManager.bookmarks.first.id;

        // 执行移除
        final result = historyManager.removeBookmark(bookmarkId);

        // 验证
        expect(result, isTrue);
        expect(historyManager.bookmarks.length, equals(0));
      });

      test('应该能够访问书签并更新统计', () {
        // 准备
        historyManager.addBookmark(
          route: '/workshop',
          title: '我的工坊',
        );
        
        final bookmarkId = historyManager.bookmarks.first.id;
        final originalAccessCount = historyManager.bookmarks.first.accessCount;

        // 执行访问
        final accessedBookmark = historyManager.accessBookmark(bookmarkId);

        // 验证
        expect(accessedBookmark, isNotNull);
        expect(accessedBookmark!.accessCount, equals(originalAccessCount + 1));
        expect(accessedBookmark.lastAccessedAt, isNotNull);
        
        // 验证书签列表中的记录也被更新
        final updatedBookmark = historyManager.bookmarks.first;
        expect(updatedBookmark.accessCount, equals(originalAccessCount + 1));
      });

      test('应该限制书签数量', () {
        // 添加超过限制的书签
        for (int i = 0; i < 60; i++) {
          historyManager.addBookmark(
            route: '/test$i',
            title: '测试书签$i',
          );
        }

        // 验证数量被限制
        final bookmarks = historyManager.bookmarks;
        expect(bookmarks.length, lessThanOrEqualTo(50));
      });

      test('应该清除所有书签', () {
        // 准备
        historyManager.addBookmark(route: '/workshop', title: '工坊');
        historyManager.addBookmark(route: '/notes', title: '笔记');

        // 执行清除
        historyManager.clearBookmarks();

        // 验证
        expect(historyManager.bookmarks.length, equals(0));
      });
    });

    group('流监听', () {
      test('应该能够监听历史记录变更', () async {
        final historyChanges = <List<TestNavigationHistoryEntry>>[];
        final subscription = historyManager.historyStream.listen(
          (history) => historyChanges.add(history),
        );

        // 添加历史记录
        historyManager.addHistory(route: '/workshop');
        historyManager.addHistory(route: '/notes');

        // 等待流事件
        await Future.delayed(const Duration(milliseconds: 10));

        // 验证
        expect(historyChanges.length, greaterThan(0));
        expect(historyChanges.last.length, equals(2));

        await subscription.cancel();
      });

      test('应该能够监听书签变更', () async {
        final bookmarkChanges = <List<TestBookmarkEntry>>[];
        final subscription = historyManager.bookmarkStream.listen(
          (bookmarks) => bookmarkChanges.add(bookmarks),
        );

        // 添加书签
        historyManager.addBookmark(route: '/workshop', title: '工坊');

        // 等待流事件
        await Future.delayed(const Duration(milliseconds: 10));

        // 验证
        expect(bookmarkChanges.length, greaterThan(0));
        expect(bookmarkChanges.last.length, equals(1));

        await subscription.cancel();
      });
    });

    group('JSON序列化', () {
      test('TestNavigationHistoryEntry应该能够序列化和反序列化', () {
        final entry = TestNavigationHistoryEntry(
          id: 'test_id',
          route: '/workshop',
          parameters: {'mode': 'edit'},
          timestamp: DateTime.now(),
          title: '测试标题',
          description: '测试描述',
        );

        // 序列化
        final json = entry.toJson();
        expect(json['id'], equals('test_id'));
        expect(json['route'], equals('/workshop'));

        // 反序列化
        final restored = TestNavigationHistoryEntry.fromJson(json);
        expect(restored.id, equals(entry.id));
        expect(restored.route, equals(entry.route));
        expect(restored.parameters['mode'], equals('edit'));
        expect(restored.title, equals(entry.title));
      });

      test('TestBookmarkEntry应该能够序列化和反序列化', () {
        final bookmark = TestBookmarkEntry(
          id: 'bookmark_id',
          route: '/workshop',
          parameters: {'mode': 'view'},
          title: '我的工坊',
          description: '工坊描述',
          createdAt: DateTime.now(),
          tags: ['工作', '创意'],
        );

        // 序列化
        final json = bookmark.toJson();
        expect(json['id'], equals('bookmark_id'));
        expect(json['title'], equals('我的工坊'));

        // 反序列化
        final restored = TestBookmarkEntry.fromJson(json);
        expect(restored.id, equals(bookmark.id));
        expect(restored.route, equals(bookmark.route));
        expect(restored.title, equals(bookmark.title));
        expect(restored.tags, equals(bookmark.tags));
      });
    });
  });
}
