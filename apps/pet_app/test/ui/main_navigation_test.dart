/*
---------------------------------------------------------------
File name:          main_navigation_test.dart
Author:             Pet App V3 Team
Date created:       2025-07-19
Last modified:      2025-07-19
Dart Version:       3.2+
Description:        主导航测试 - 纯Dart版本
---------------------------------------------------------------
*/

import 'package:test/test.dart';
import 'dart:async';

/// 导航页面类型
enum TestNavigationPage { home, plugins, workshop, settings, about }

/// 导航状态
class TestNavigationState {
  final TestNavigationPage currentPage;
  final Map<String, dynamic> pageData;
  final List<TestNavigationPage> history;
  final DateTime timestamp;

  TestNavigationState({
    required this.currentPage,
    Map<String, dynamic>? pageData,
    List<TestNavigationPage>? history,
    DateTime? timestamp,
  }) : pageData = pageData ?? {},
       history = history ?? [],
       timestamp = timestamp ?? DateTime.now();
}

/// 导航事件
class TestNavigationEvent {
  final String type;
  final TestNavigationPage? fromPage;
  final TestNavigationPage? toPage;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  TestNavigationEvent({
    required this.type,
    this.fromPage,
    this.toPage,
    Map<String, dynamic>? data,
    DateTime? timestamp,
  }) : data = data ?? {},
       timestamp = timestamp ?? DateTime.now();
}

/// 简化的主导航管理器（测试版本）
class TestMainNavigationManager {
  TestNavigationPage _currentPage = TestNavigationPage.home;
  final List<TestNavigationPage> _history = [];
  final Map<TestNavigationPage, Map<String, dynamic>> _pageData = {};
  final List<TestNavigationEvent> _eventHistory = [];
  final StreamController<TestNavigationState> _stateController =
      StreamController<TestNavigationState>.broadcast();
  final StreamController<TestNavigationEvent> _eventController =
      StreamController<TestNavigationEvent>.broadcast();

  TestNavigationPage get currentPage => _currentPage;
  List<TestNavigationPage> get history => List.unmodifiable(_history);
  Stream<TestNavigationState> get stateStream => _stateController.stream;
  Stream<TestNavigationEvent> get eventStream => _eventController.stream;
  List<TestNavigationEvent> get eventHistory =>
      List.unmodifiable(_eventHistory);

  /// 导航到指定页面
  Future<bool> navigateTo(
    TestNavigationPage page, {
    Map<String, dynamic>? data,
  }) async {
    if (_currentPage == page) {
      return true; // 已经在目标页面
    }

    final fromPage = _currentPage;

    // 触发导航前事件
    _addEvent('navigation_start', fromPage, page, data);

    // 模拟页面切换延迟
    await Future.delayed(const Duration(milliseconds: 50));

    // 更新状态
    _history.add(_currentPage);
    _currentPage = page;

    if (data != null) {
      _pageData[page] = data;
    }

    // 触发导航完成事件
    _addEvent('navigation_complete', fromPage, page, data);

    // 发送状态更新
    _stateController.add(
      TestNavigationState(
        currentPage: _currentPage,
        pageData: _pageData[_currentPage] ?? {},
        history: _history,
      ),
    );

    return true;
  }

  /// 返回上一页
  Future<bool> goBack() async {
    if (_history.isEmpty) {
      return false; // 没有历史记录
    }

    final fromPage = _currentPage;
    final toPage = _history.removeLast();

    _addEvent('navigation_back', fromPage, toPage);

    await Future.delayed(const Duration(milliseconds: 30));

    _currentPage = toPage;

    _addEvent('navigation_back_complete', fromPage, toPage);

    _stateController.add(
      TestNavigationState(
        currentPage: _currentPage,
        pageData: _pageData[_currentPage] ?? {},
        history: _history,
      ),
    );

    return true;
  }

  /// 清除历史记录
  void clearHistory() {
    _history.clear();
    _addEvent('history_cleared');
  }

  /// 重置到首页
  Future<void> resetToHome() async {
    final fromPage = _currentPage;

    _addEvent('navigation_reset', fromPage, TestNavigationPage.home);

    _currentPage = TestNavigationPage.home;
    _history.clear();
    _pageData.clear();

    _addEvent('navigation_reset_complete', fromPage, TestNavigationPage.home);

    _stateController.add(
      TestNavigationState(currentPage: _currentPage, pageData: {}, history: []),
    );
  }

  /// 获取页面数据
  Map<String, dynamic>? getPageData(TestNavigationPage page) {
    return _pageData[page];
  }

  /// 设置页面数据
  void setPageData(TestNavigationPage page, Map<String, dynamic> data) {
    _pageData[page] = data;

    if (page == _currentPage) {
      _stateController.add(
        TestNavigationState(
          currentPage: _currentPage,
          pageData: data,
          history: _history,
        ),
      );
    }
  }

  /// 检查是否可以返回
  bool get canGoBack => _history.isNotEmpty;

  /// 获取历史记录深度
  int get historyDepth => _history.length;

  /// 检查是否在首页
  bool get isAtHome => _currentPage == TestNavigationPage.home;

  /// 获取导航统计
  Map<String, dynamic> getNavigationStatistics() {
    final pageVisits = <TestNavigationPage, int>{};
    final eventTypes = <String, int>{};

    for (final event in _eventHistory) {
      if (event.toPage != null) {
        pageVisits[event.toPage!] = (pageVisits[event.toPage!] ?? 0) + 1;
      }
      eventTypes[event.type] = (eventTypes[event.type] ?? 0) + 1;
    }

    return {
      'pageVisits': pageVisits,
      'eventTypes': eventTypes,
      'totalEvents': _eventHistory.length,
      'currentHistoryDepth': _history.length,
    };
  }

  /// 添加事件
  void _addEvent(
    String type, [
    TestNavigationPage? fromPage,
    TestNavigationPage? toPage,
    Map<String, dynamic>? data,
  ]) {
    final event = TestNavigationEvent(
      type: type,
      fromPage: fromPage,
      toPage: toPage,
      data: data,
    );

    _eventHistory.add(event);
    _eventController.add(event);
  }

  /// 清理资源
  void dispose() {
    _history.clear();
    _pageData.clear();
    _eventHistory.clear();
    _stateController.close();
    _eventController.close();
  }
}

void main() {
  group('MainNavigation Tests', () {
    late TestMainNavigationManager navigation;

    setUp(() {
      navigation = TestMainNavigationManager();
    });

    tearDown(() {
      navigation.dispose();
    });

    group('基础导航功能', () {
      test('应该能够导航到不同页面', () async {
        expect(navigation.currentPage, equals(TestNavigationPage.home));

        final result = await navigation.navigateTo(TestNavigationPage.plugins);

        expect(result, isTrue);
        expect(navigation.currentPage, equals(TestNavigationPage.plugins));
        expect(navigation.history.length, equals(1));
        expect(navigation.history.last, equals(TestNavigationPage.home));
      });

      test('应该能够返回上一页', () async {
        await navigation.navigateTo(TestNavigationPage.workshop);
        await navigation.navigateTo(TestNavigationPage.settings);

        expect(navigation.currentPage, equals(TestNavigationPage.settings));
        expect(navigation.canGoBack, isTrue);

        final result = await navigation.goBack();

        expect(result, isTrue);
        expect(navigation.currentPage, equals(TestNavigationPage.workshop));
        expect(navigation.history.length, equals(1));
      });

      test('应该处理无历史记录的返回操作', () async {
        expect(navigation.canGoBack, isFalse);

        final result = await navigation.goBack();

        expect(result, isFalse);
        expect(navigation.currentPage, equals(TestNavigationPage.home));
      });

      test('应该能够重置到首页', () async {
        await navigation.navigateTo(TestNavigationPage.plugins);
        await navigation.navigateTo(TestNavigationPage.workshop);

        expect(navigation.currentPage, equals(TestNavigationPage.workshop));
        expect(navigation.history.isNotEmpty, isTrue);

        await navigation.resetToHome();

        expect(navigation.currentPage, equals(TestNavigationPage.home));
        expect(navigation.history.isEmpty, isTrue);
        expect(navigation.isAtHome, isTrue);
      });
    });

    group('页面数据管理', () {
      test('应该能够传递页面数据', () async {
        final data = {'userId': 123, 'mode': 'edit'};

        await navigation.navigateTo(TestNavigationPage.settings, data: data);

        final pageData = navigation.getPageData(TestNavigationPage.settings);
        expect(pageData, isNotNull);
        expect(pageData!['userId'], equals(123));
        expect(pageData['mode'], equals('edit'));
      });

      test('应该能够设置和获取页面数据', () {
        final data = {'theme': 'dark', 'language': 'zh'};

        navigation.setPageData(TestNavigationPage.settings, data);

        final retrievedData = navigation.getPageData(
          TestNavigationPage.settings,
        );
        expect(retrievedData, equals(data));
      });

      test('应该处理不存在的页面数据', () {
        final data = navigation.getPageData(TestNavigationPage.about);
        expect(data, isNull);
      });
    });

    group('导航历史管理', () {
      test('应该正确维护导航历史', () async {
        await navigation.navigateTo(TestNavigationPage.plugins);
        await navigation.navigateTo(TestNavigationPage.workshop);
        await navigation.navigateTo(TestNavigationPage.settings);

        expect(navigation.historyDepth, equals(3));
        expect(navigation.history[0], equals(TestNavigationPage.home));
        expect(navigation.history[1], equals(TestNavigationPage.plugins));
        expect(navigation.history[2], equals(TestNavigationPage.workshop));
      });

      test('应该能够清除历史记录', () async {
        await navigation.navigateTo(TestNavigationPage.plugins);
        await navigation.navigateTo(TestNavigationPage.workshop);

        expect(navigation.history.isNotEmpty, isTrue);

        navigation.clearHistory();

        expect(navigation.history.isEmpty, isTrue);
        expect(navigation.canGoBack, isFalse);
      });
    });

    group('导航事件监听', () {
      test('应该能够监听导航状态变更', () async {
        final receivedStates = <TestNavigationState>[];
        final subscription = navigation.stateStream.listen((state) {
          receivedStates.add(state);
        });

        await navigation.navigateTo(TestNavigationPage.plugins);
        await Future.delayed(const Duration(milliseconds: 10));

        expect(receivedStates.length, equals(1));
        expect(
          receivedStates.first.currentPage,
          equals(TestNavigationPage.plugins),
        );

        await subscription.cancel();
      });

      test('应该能够监听导航事件', () async {
        final receivedEvents = <TestNavigationEvent>[];
        final subscription = navigation.eventStream.listen((event) {
          receivedEvents.add(event);
        });

        await navigation.navigateTo(TestNavigationPage.workshop);
        await Future.delayed(const Duration(milliseconds: 10));

        expect(receivedEvents.length, equals(2)); // start + complete
        expect(receivedEvents[0].type, equals('navigation_start'));
        expect(receivedEvents[1].type, equals('navigation_complete'));

        await subscription.cancel();
      });
    });

    group('导航统计', () {
      test('应该收集导航统计信息', () async {
        await navigation.navigateTo(TestNavigationPage.plugins);
        await navigation.navigateTo(TestNavigationPage.workshop);
        await navigation.goBack();
        await navigation.navigateTo(TestNavigationPage.settings);

        final stats = navigation.getNavigationStatistics();

        expect(stats['totalEvents'], greaterThan(0));
        expect(
          stats['pageVisits'][TestNavigationPage.plugins],
          greaterThanOrEqualTo(1),
        );
        expect(
          stats['pageVisits'][TestNavigationPage.workshop],
          greaterThanOrEqualTo(1),
        );
        expect(
          stats['pageVisits'][TestNavigationPage.settings],
          greaterThanOrEqualTo(1),
        );
        expect(stats['eventTypes']['navigation_complete'], equals(3));
      });
    });

    group('边界条件测试', () {
      test('应该处理导航到当前页面', () async {
        await navigation.navigateTo(TestNavigationPage.plugins);

        final result = await navigation.navigateTo(TestNavigationPage.plugins);

        expect(result, isTrue);
        expect(navigation.currentPage, equals(TestNavigationPage.plugins));
      });

      test('应该处理复杂的导航序列', () async {
        // 复杂导航序列
        await navigation.navigateTo(TestNavigationPage.plugins);
        await navigation.navigateTo(TestNavigationPage.workshop);
        await navigation.goBack();
        await navigation.navigateTo(TestNavigationPage.settings);
        await navigation.goBack();
        await navigation.navigateTo(TestNavigationPage.about);
        await navigation.resetToHome();

        expect(navigation.currentPage, equals(TestNavigationPage.home));
        expect(navigation.history.isEmpty, isTrue);

        final stats = navigation.getNavigationStatistics();
        expect(stats['totalEvents'], greaterThan(10));
      });
    });
  });
}
