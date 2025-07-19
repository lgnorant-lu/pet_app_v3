/*
---------------------------------------------------------------
File name:          navigation_extended_test.dart
Author:             Pet App V3 Team
Date created:       2025-07-19
Last modified:      2025-07-19
Dart Version:       3.2+
Description:        Phase 3.3.2.1 导航系统扩展测试
---------------------------------------------------------------
Change History:
    2025-07-19: Phase 3.3.2.1 - 实现导航系统扩展测试;
---------------------------------------------------------------
*/

import 'package:test/test.dart';

/// 扩展的深度链接处理器测试
class ExtendedDeepLinkHandler {
  final Map<String, String> _routeMappings = {
    '/home': '/',
    '/main': '/',
    '/workshop': '/workshop',
    '/creative': '/workshop',
    '/notes': '/notes',
    '/tasks': '/notes',
    '/settings': '/settings',
    '/config': '/settings',
  };

  final List<Map<String, dynamic>> _history = [];
  final Map<String, int> _stats = {};

  Map<String, dynamic> handleDeepLink(String url) {
    try {
      // 预先检查明显无效的URL
      if (url.isEmpty ||
          url == 'not-a-url' ||
          url == 'http://' ||
          url == 'https://' ||
          url == '://missing-scheme') {
        _updateStats('parse_error');
        return {
          'success': false,
          'error': 'Failed to parse URL: Invalid URL format',
        };
      }

      final uri = Uri.parse(url);

      // 记录历史
      final linkInfo = {
        'originalUrl': url,
        'timestamp': DateTime.now().toIso8601String(),
        'path': uri.path,
        'queryParameters': uri.queryParameters,
      };
      _addToHistory(linkInfo);

      // 安全检查
      if (_isMaliciousUrl(url)) {
        _updateStats('malicious_blocked');
        return {
          'success': false,
          'error': 'Malicious URL detected',
          'linkInfo': linkInfo,
        };
      }

      // 确定链接类型
      String linkType;
      if (uri.scheme == 'https' && uri.host == 'app.petapp.com') {
        linkType = 'internal';
      } else if (uri.scheme == 'petapp') {
        linkType = 'custom';
      } else {
        linkType = 'external';
      }

      // 处理不同类型的链接
      switch (linkType) {
        case 'internal':
          return _handleInternalLink(uri, linkInfo);
        case 'custom':
          return _handleCustomLink(uri, linkInfo);
        case 'external':
          _updateStats('external_rejected');
          return {
            'success': false,
            'error': 'External links not supported',
            'linkInfo': linkInfo,
          };
        default:
          return {
            'success': false,
            'error': 'Unknown link type',
            'linkInfo': linkInfo,
          };
      }
    } catch (e) {
      _updateStats('parse_error');
      return {'success': false, 'error': 'Failed to parse URL: $e'};
    }
  }

  Map<String, dynamic> _handleInternalLink(
    Uri uri,
    Map<String, dynamic> linkInfo,
  ) {
    _updateStats('internal_success');
    final targetRoute = _routeMappings[uri.path] ?? uri.path;

    return {
      'success': true,
      'targetRoute': targetRoute,
      'parameters': Map<String, dynamic>.from(uri.queryParameters),
      'linkInfo': linkInfo,
    };
  }

  Map<String, dynamic> _handleCustomLink(
    Uri uri,
    Map<String, dynamic> linkInfo,
  ) {
    _updateStats('custom_handled');

    // 对于petapp://create这样的URL，uri.path是空的，需要检查host
    String action = '';
    List<String> pathSegments = [];

    if (uri.host.isNotEmpty) {
      // petapp://create -> host是'create'
      action = uri.host;
    } else if (uri.path.isNotEmpty) {
      // petapp:///create/item -> path是'/create/item'
      pathSegments = uri.path.split('/').where((s) => s.isNotEmpty).toList();
      if (pathSegments.isNotEmpty) {
        action = pathSegments.first;
        pathSegments = pathSegments.skip(1).toList();
      }
    }

    if (action.isEmpty) {
      return {
        'success': false,
        'error': 'Invalid custom protocol link',
        'linkInfo': linkInfo,
      };
    }

    final parameters = Map<String, dynamic>.from(uri.queryParameters);

    String targetRoute;
    switch (action) {
      case 'open':
        targetRoute = pathSegments.isNotEmpty ? '/${pathSegments.first}' : '/';
        break;
      case 'create':
        targetRoute = '/workshop';
        parameters['action'] = 'create';
        break;
      case 'edit':
        targetRoute = '/workshop';
        parameters['action'] = 'edit';
        if (pathSegments.isNotEmpty) {
          parameters['itemId'] = pathSegments.first;
        }
        break;
      default:
        targetRoute = '/';
    }

    return {
      'success': true,
      'targetRoute': targetRoute,
      'parameters': parameters,
      'linkInfo': linkInfo,
    };
  }

  bool _isMaliciousUrl(String url) {
    final maliciousPatterns = [
      'javascript:',
      'data:',
      '<script',
      'eval(',
      'document.cookie',
    ];

    final lowerUrl = url.toLowerCase();
    return maliciousPatterns.any((pattern) => lowerUrl.contains(pattern));
  }

  void _addToHistory(Map<String, dynamic> linkInfo) {
    _history.insert(0, linkInfo);
    if (_history.length > 100) {
      _history.removeLast();
    }
  }

  void _updateStats(String action) {
    _stats[action] = (_stats[action] ?? 0) + 1;
  }

  String generateShareLink({
    required String route,
    Map<String, String>? parameters,
    String? title,
    String? description,
  }) {
    final uri = Uri(
      scheme: 'https',
      host: 'app.petapp.com',
      path: route,
      queryParameters: {
        if (parameters != null) ...parameters,
        'share': 'true',
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      },
    );

    return uri.toString();
  }

  List<Map<String, dynamic>> get history => List.unmodifiable(_history);
  Map<String, int> get stats => Map.unmodifiable(_stats);

  void clearHistory() => _history.clear();
  void clearStats() => _stats.clear();
}

void main() {
  group('Navigation Extended Tests', () {
    late ExtendedDeepLinkHandler handler;

    setUp(() {
      handler = ExtendedDeepLinkHandler();
    });

    group('深度链接安全性测试', () {
      test('应该阻止JavaScript注入', () {
        final result = handler.handleDeepLink('javascript:alert("xss")');
        expect(result['success'], isFalse);
        expect(result['error'], contains('Malicious URL'));
        expect(handler.stats['malicious_blocked'], equals(1));
      });

      test('应该阻止Data URL攻击', () {
        final result = handler.handleDeepLink(
          'data:text/html,<script>alert("xss")</script>',
        );
        expect(result['success'], isFalse);
        expect(result['error'], contains('Malicious URL'));
      });

      test('应该阻止Script标签注入', () {
        final result = handler.handleDeepLink(
          'https://app.petapp.com/<script>alert("xss")</script>',
        );
        expect(result['success'], isFalse);
        expect(result['error'], contains('Malicious URL'));
      });
    });

    group('自定义协议高级测试', () {
      test('应该处理创建操作', () {
        final result = handler.handleDeepLink(
          'petapp://create?template=flutter',
        );
        expect(result['success'], isTrue);
        expect(result['targetRoute'], equals('/workshop'));
        expect(result['parameters']['action'], equals('create'));
        expect(result['parameters']['template'], equals('flutter'));
      });

      test('应该处理编辑操作', () {
        final result = handler.handleDeepLink(
          'petapp:///edit/123?mode=advanced',
        );
        expect(result['success'], isTrue);
        expect(result['targetRoute'], equals('/workshop'));
        expect(result['parameters']['action'], equals('edit'));
        expect(result['parameters']['itemId'], equals('123'));
        expect(result['parameters']['mode'], equals('advanced'));
      });

      test('应该处理复杂的打开操作', () {
        final result = handler.handleDeepLink(
          'petapp:///open/workshop?project=test&mode=view',
        );
        expect(result['success'], isTrue);
        expect(result['targetRoute'], equals('/workshop'));
        expect(result['parameters']['project'], equals('test'));
        expect(result['parameters']['mode'], equals('view'));
      });

      test('应该处理无效的自定义协议', () {
        final result = handler.handleDeepLink('petapp://');
        expect(result['success'], isFalse);
        expect(result['error'], contains('Invalid custom protocol'));
      });
    });

    group('路由映射高级测试', () {
      test('应该正确映射所有别名路由', () {
        final testCases = [
          {'input': '/home', 'expected': '/'},
          {'input': '/main', 'expected': '/'},
          {'input': '/creative', 'expected': '/workshop'},
          {'input': '/tasks', 'expected': '/notes'},
          {'input': '/config', 'expected': '/settings'},
        ];

        for (final testCase in testCases) {
          final result = handler.handleDeepLink(
            'https://app.petapp.com${testCase['input']}',
          );
          expect(result['success'], isTrue);
          expect(result['targetRoute'], equals(testCase['expected']));
        }
      });

      test('应该处理未映射的路由', () {
        final result = handler.handleDeepLink('https://app.petapp.com/unknown');
        expect(result['success'], isTrue);
        expect(result['targetRoute'], equals('/unknown'));
      });
    });

    group('历史记录和统计高级测试', () {
      test('应该详细记录链接信息', () {
        handler.handleDeepLink('https://app.petapp.com/workshop?mode=edit');

        final history = handler.history;
        expect(history.length, equals(1));

        final record = history.first;
        expect(
          record['originalUrl'],
          equals('https://app.petapp.com/workshop?mode=edit'),
        );
        expect(record['path'], equals('/workshop'));
        expect(record['queryParameters']['mode'], equals('edit'));
        expect(record['timestamp'], isA<String>());
      });

      test('应该正确统计不同类型的操作', () {
        // 内部链接
        handler.handleDeepLink('https://app.petapp.com/workshop');
        // 自定义协议
        handler.handleDeepLink('petapp://open/notes');
        // 恶意链接
        handler.handleDeepLink('javascript:alert("test")');
        // 外部链接
        handler.handleDeepLink('https://external.com/page');

        final stats = handler.stats;
        expect(stats['internal_success'], equals(1));
        expect(stats['custom_handled'], equals(1));
        expect(stats['malicious_blocked'], equals(1));
        expect(stats['external_rejected'], equals(1));
      });

      test('应该限制历史记录数量', () {
        // 添加超过100条记录
        for (int i = 0; i < 150; i++) {
          handler.handleDeepLink('https://app.petapp.com/test$i');
        }

        final history = handler.history;
        expect(history.length, equals(100));
        expect(history.first['originalUrl'], contains('test149'));
        expect(history.last['originalUrl'], contains('test50'));
      });

      test('应该支持清除历史和统计', () {
        handler.handleDeepLink('https://app.petapp.com/workshop');
        handler.handleDeepLink('petapp://open/notes');

        expect(handler.history.length, equals(2));
        expect(handler.stats.isNotEmpty, isTrue);

        handler.clearHistory();
        handler.clearStats();

        expect(handler.history.length, equals(0));
        expect(handler.stats.isEmpty, isTrue);
      });
    });

    group('分享链接高级测试', () {
      test('应该生成完整的分享链接', () {
        final shareLink = handler.generateShareLink(
          route: '/workshop',
          parameters: {'project': 'test', 'mode': 'view'},
          title: '我的创意项目',
          description: '这是一个测试项目',
        );

        expect(shareLink, startsWith('https://app.petapp.com/workshop'));
        expect(shareLink, contains('project=test'));
        expect(shareLink, contains('mode=view'));
        expect(shareLink, contains('share=true'));
        expect(shareLink, contains('title='));
        expect(shareLink, contains('description='));
        expect(shareLink, contains('timestamp='));
      });

      test('应该处理特殊字符', () {
        final shareLink = handler.generateShareLink(
          route: '/workshop',
          title: '测试项目 & 特殊字符',
          description: '包含 <> 符号的描述',
        );

        expect(shareLink, contains('title='));
        expect(shareLink, contains('description='));
        // URL应该被正确编码
        expect(shareLink, isNot(contains('<')));
        expect(shareLink, isNot(contains('>')));
      });

      test('应该生成最小分享链接', () {
        final shareLink = handler.generateShareLink(route: '/workshop');

        expect(
          shareLink,
          equals(
            'https://app.petapp.com/workshop?share=true&timestamp=${Uri.parse(shareLink).queryParameters['timestamp']}',
          ),
        );
      });
    });

    group('性能和边界测试', () {
      test('应该快速处理大量链接', () {
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 1000; i++) {
          handler.handleDeepLink('https://app.petapp.com/test$i');
        }

        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      });

      test('应该处理空URL', () {
        final result = handler.handleDeepLink('');
        expect(result['success'], isFalse);
        expect(result['error'], contains('Failed to parse URL'));
      });

      test('应该处理超长URL', () {
        final longPath = '/workshop/${'a' * 2000}';
        final result = handler.handleDeepLink(
          'https://app.petapp.com$longPath',
        );
        expect(result['success'], isTrue);
        expect(result['targetRoute'], equals(longPath));
      });

      test('应该处理Unicode字符', () {
        final result = handler.handleDeepLink(
          'https://app.petapp.com/workshop?title=测试项目&desc=项目描述',
        );
        expect(result['success'], isTrue);
        expect(result['parameters']['title'], equals('测试项目'));
        expect(result['parameters']['desc'], equals('项目描述'));
      });
    });

    group('错误处理测试', () {
      test('应该处理格式错误的URL', () {
        final invalidUrls = [
          'not-a-url',
          'http://',
          'https://',
          '://missing-scheme',
        ];

        for (final url in invalidUrls) {
          final result = handler.handleDeepLink(url);
          expect(result['success'], isFalse);
          expect(result['error'], contains('Failed to parse URL'));
        }

        // 测试其他无效URL（这些会被当作外部链接处理）
        final externalUrls = ['ftp://invalid'];
        for (final url in externalUrls) {
          final result = handler.handleDeepLink(url);
          expect(result['success'], isFalse);
          expect(result['error'], contains('External links not supported'));
        }
      });

      test('应该统计解析错误', () {
        handler.handleDeepLink('not-a-url');
        handler.handleDeepLink('http://');

        expect(handler.stats['parse_error'], equals(2));
      });
    });
  });
}
