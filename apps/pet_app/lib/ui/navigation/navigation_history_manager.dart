/*
---------------------------------------------------------------
File name:          navigation_history_manager.dart
Author:             Pet App V3 Team
Date created:       2025-07-19
Last modified:      2025-07-19
Dart Version:       3.2+
Description:        Phase 3.3.2.2 导航历史记录管理器
---------------------------------------------------------------
Change History:
    2025-07-19: Phase 3.3.2.2 - 实现导航历史栈、状态保持、书签系统;
---------------------------------------------------------------
*/

import 'package:flutter/foundation.dart';
import 'dart:async';
// import 'dart:convert'; // 暂时未使用
import 'package:communication_system/communication_system.dart' as comm;

/// 导航历史条目
class NavigationHistoryEntry {
  final String id;
  final String route;
  final Map<String, dynamic> parameters;
  final DateTime timestamp;
  final String? title;
  final String? description;
  final Map<String, dynamic>? state;
  final bool canRestore;

  const NavigationHistoryEntry({
    required this.id,
    required this.route,
    required this.parameters,
    required this.timestamp,
    this.title,
    this.description,
    this.state,
    this.canRestore = true,
  });

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'route': route,
      'parameters': parameters,
      'timestamp': timestamp.toIso8601String(),
      'title': title,
      'description': description,
      'state': state,
      'canRestore': canRestore,
    };
  }

  /// 从JSON创建
  factory NavigationHistoryEntry.fromJson(Map<String, dynamic> json) {
    return NavigationHistoryEntry(
      id: json['id'],
      route: json['route'],
      parameters: Map<String, dynamic>.from(json['parameters'] ?? {}),
      timestamp: DateTime.parse(json['timestamp']),
      title: json['title'],
      description: json['description'],
      state: json['state'] != null
          ? Map<String, dynamic>.from(json['state'])
          : null,
      canRestore: json['canRestore'] ?? true,
    );
  }

  @override
  String toString() {
    return 'NavigationHistoryEntry(id: $id, route: $route, timestamp: $timestamp)';
  }
}

/// 书签条目
class BookmarkEntry {
  final String id;
  final String route;
  final Map<String, dynamic> parameters;
  final String title;
  final String? description;
  final String? iconData;
  final DateTime createdAt;
  final DateTime? lastAccessedAt;
  final int accessCount;
  final List<String> tags;

  const BookmarkEntry({
    required this.id,
    required this.route,
    required this.parameters,
    required this.title,
    this.description,
    this.iconData,
    required this.createdAt,
    this.lastAccessedAt,
    this.accessCount = 0,
    this.tags = const [],
  });

  /// 更新访问信息
  BookmarkEntry copyWithAccess() {
    return BookmarkEntry(
      id: id,
      route: route,
      parameters: parameters,
      title: title,
      description: description,
      iconData: iconData,
      createdAt: createdAt,
      lastAccessedAt: DateTime.now(),
      accessCount: accessCount + 1,
      tags: tags,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'route': route,
      'parameters': parameters,
      'title': title,
      'description': description,
      'iconData': iconData,
      'createdAt': createdAt.toIso8601String(),
      'lastAccessedAt': lastAccessedAt?.toIso8601String(),
      'accessCount': accessCount,
      'tags': tags,
    };
  }

  /// 从JSON创建
  factory BookmarkEntry.fromJson(Map<String, dynamic> json) {
    return BookmarkEntry(
      id: json['id'],
      route: json['route'],
      parameters: Map<String, dynamic>.from(json['parameters'] ?? {}),
      title: json['title'],
      description: json['description'],
      iconData: json['iconData'],
      createdAt: DateTime.parse(json['createdAt']),
      lastAccessedAt: json['lastAccessedAt'] != null
          ? DateTime.parse(json['lastAccessedAt'])
          : null,
      accessCount: json['accessCount'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}

/// 导航历史管理器
///
/// Phase 3.3.2.2 核心功能：
/// - 导航历史栈管理
/// - 状态保持和恢复
/// - 书签系统
/// - 前进/后退功能
/// - 历史记录持久化
class NavigationHistoryManager {
  NavigationHistoryManager._();

  static final NavigationHistoryManager _instance =
      NavigationHistoryManager._();
  static NavigationHistoryManager get instance => _instance;

  /// 统一消息总线
  final comm.UnifiedMessageBus _messageBus = comm.UnifiedMessageBus.instance;

  /// 导航历史栈
  final List<NavigationHistoryEntry> _historyStack = [];

  /// 前进历史栈
  final List<NavigationHistoryEntry> _forwardStack = [];

  /// 书签列表
  final List<BookmarkEntry> _bookmarks = [];

  /// 当前历史索引
  int _currentIndex = -1;

  /// 最大历史记录数
  final int _maxHistorySize = 100;

  /// 最大书签数
  final int _maxBookmarkSize = 50;

  /// 历史变更流
  final StreamController<List<NavigationHistoryEntry>> _historyController =
      StreamController<List<NavigationHistoryEntry>>.broadcast();

  /// 书签变更流
  final StreamController<List<BookmarkEntry>> _bookmarkController =
      StreamController<List<BookmarkEntry>>.broadcast();

  /// 初始化历史管理器
  Future<void> initialize() async {
    try {
      await _loadPersistedData();
      debugPrint('NavigationHistoryManager initialized');
    } catch (e, stackTrace) {
      debugPrint('Failed to initialize NavigationHistoryManager: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// 添加历史记录
  void addHistory({
    required String route,
    Map<String, dynamic>? parameters,
    String? title,
    String? description,
    Map<String, dynamic>? state,
  }) {
    final entry = NavigationHistoryEntry(
      id: _generateId(),
      route: route,
      parameters: parameters ?? {},
      timestamp: DateTime.now(),
      title: title,
      description: description,
      state: state,
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

    // 通知变更
    _notifyHistoryChanged();

    // 发送消息
    _messageBus.publishEvent('navigation_history', 'history_added', {
      'entry': entry.toJson(),
      'currentIndex': _currentIndex,
      'totalCount': _historyStack.length,
    });

    debugPrint('Added history: $route (index: $_currentIndex)');
  }

  /// 后退
  NavigationHistoryEntry? goBack() {
    if (!canGoBack) return null;

    final currentEntry = _historyStack[_currentIndex];
    _forwardStack.add(currentEntry);
    _currentIndex--;

    final targetEntry = _historyStack[_currentIndex];

    _notifyHistoryChanged();

    _messageBus.publishEvent('navigation_history', 'navigated_back', {
      'targetEntry': targetEntry.toJson(),
      'currentIndex': _currentIndex,
    });

    debugPrint('Navigated back to: ${targetEntry.route}');
    return targetEntry;
  }

  /// 前进
  NavigationHistoryEntry? goForward() {
    if (!canGoForward) return null;

    _currentIndex++;
    final targetEntry = _historyStack[_currentIndex];

    if (_forwardStack.isNotEmpty) {
      _forwardStack.removeLast();
    }

    _notifyHistoryChanged();

    _messageBus.publishEvent('navigation_history', 'navigated_forward', {
      'targetEntry': targetEntry.toJson(),
      'currentIndex': _currentIndex,
    });

    debugPrint('Navigated forward to: ${targetEntry.route}');
    return targetEntry;
  }

  /// 跳转到指定历史记录
  NavigationHistoryEntry? goToHistory(int index) {
    if (index < 0 || index >= _historyStack.length) return null;

    _currentIndex = index;
    final targetEntry = _historyStack[_currentIndex];

    _notifyHistoryChanged();

    _messageBus.publishEvent('navigation_history', 'navigated_to_history', {
      'targetEntry': targetEntry.toJson(),
      'currentIndex': _currentIndex,
    });

    return targetEntry;
  }

  /// 添加书签
  Future<bool> addBookmark({
    required String route,
    Map<String, dynamic>? parameters,
    required String title,
    String? description,
    String? iconData,
    List<String>? tags,
  }) async {
    // 检查是否已存在
    if (_bookmarks.any(
      (bookmark) =>
          bookmark.route == route &&
          _parametersEqual(bookmark.parameters, parameters ?? {}),
    )) {
      return false;
    }

    final bookmark = BookmarkEntry(
      id: _generateId(),
      route: route,
      parameters: parameters ?? {},
      title: title,
      description: description,
      iconData: iconData,
      createdAt: DateTime.now(),
      tags: tags ?? [],
    );

    _bookmarks.add(bookmark);

    // 限制书签数量
    if (_bookmarks.length > _maxBookmarkSize) {
      _bookmarks.removeAt(0);
    }

    _notifyBookmarkChanged();
    await _persistBookmarks();

    _messageBus.publishEvent('navigation_history', 'bookmark_added', {
      'bookmark': bookmark.toJson(),
    });

    debugPrint('Added bookmark: $title');
    return true;
  }

  /// 移除书签
  Future<bool> removeBookmark(String bookmarkId) async {
    final index = _bookmarks.indexWhere(
      (bookmark) => bookmark.id == bookmarkId,
    );
    if (index == -1) return false;

    final removedBookmark = _bookmarks.removeAt(index);

    _notifyBookmarkChanged();
    await _persistBookmarks();

    _messageBus.publishEvent('navigation_history', 'bookmark_removed', {
      'bookmark': removedBookmark.toJson(),
    });

    return true;
  }

  /// 访问书签
  Future<BookmarkEntry?> accessBookmark(String bookmarkId) async {
    final index = _bookmarks.indexWhere(
      (bookmark) => bookmark.id == bookmarkId,
    );
    if (index == -1) return null;

    final updatedBookmark = _bookmarks[index].copyWithAccess();
    _bookmarks[index] = updatedBookmark;

    _notifyBookmarkChanged();
    await _persistBookmarks();

    return updatedBookmark;
  }

  /// 清除历史记录
  void clearHistory() {
    _historyStack.clear();
    _forwardStack.clear();
    _currentIndex = -1;

    _notifyHistoryChanged();

    _messageBus.publishEvent('navigation_history', 'history_cleared', {});

    debugPrint('History cleared');
  }

  /// 清除书签
  Future<void> clearBookmarks() async {
    _bookmarks.clear();

    _notifyBookmarkChanged();
    await _persistBookmarks();

    _messageBus.publishEvent('navigation_history', 'bookmarks_cleared', {});
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

  /// 加载持久化数据
  Future<void> _loadPersistedData() async {
    // 这里可以从本地存储加载数据
    // 暂时使用空实现
  }

  /// 持久化书签
  Future<void> _persistBookmarks() async {
    // 这里可以将书签保存到本地存储
    // 暂时使用空实现
  }

  /// 获取历史记录
  List<NavigationHistoryEntry> get history => List.unmodifiable(_historyStack);

  /// 获取书签列表
  List<BookmarkEntry> get bookmarks => List.unmodifiable(_bookmarks);

  /// 获取当前历史记录
  NavigationHistoryEntry? get currentHistory =>
      _currentIndex >= 0 && _currentIndex < _historyStack.length
      ? _historyStack[_currentIndex]
      : null;

  /// 是否可以后退
  bool get canGoBack => _currentIndex > 0;

  /// 是否可以前进
  bool get canGoForward => _currentIndex < _historyStack.length - 1;

  /// 历史记录流
  Stream<List<NavigationHistoryEntry>> get historyStream =>
      _historyController.stream;

  /// 书签流
  Stream<List<BookmarkEntry>> get bookmarkStream => _bookmarkController.stream;

  /// 清理资源
  void dispose() {
    _historyController.close();
    _bookmarkController.close();

    debugPrint('NavigationHistoryManager disposed');
  }
}
