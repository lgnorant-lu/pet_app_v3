/*
---------------------------------------------------------------
File name:          test_plugin.dart
Author:             lgnorant-lu
Date created:       2025/07/18
Last modified:      2025/07/18
Dart Version:       3.2+
Description:        测试插件 (Test Plugin)
---------------------------------------------------------------
Change History:
    2025/07/18: Initial creation - 测试插件 (Test Plugin);
---------------------------------------------------------------
*/

import 'dart:async';

import 'package:plugin_system/src/core/plugin.dart';
import 'package:plugin_system/src/core/event_bus.dart';

/// 简单的测试插件
///
/// 用于验证插件系统的完整流程
class TestPlugin extends Plugin {
  TestPlugin({
    this.pluginId = 'test_plugin',
    this.pluginName = 'Test Plugin',
    this.pluginVersion = '1.0.0',
    this.pluginDescription = 'A simple test plugin for validation',
    this.pluginAuthor = 'Pet App Team',
    this.pluginDependencies = const <PluginDependency>[],
  });

  final String pluginId;
  final String pluginName;
  final String pluginVersion;
  final String pluginDescription;
  final String pluginAuthor;
  final List<PluginDependency> pluginDependencies;

  /// 插件状态
  PluginState _currentState = PluginState.unloaded;

  /// 状态变化控制器
  final StreamController<PluginState> _stateController =
      StreamController<PluginState>.broadcast();

  /// 事件总线
  final EventBus _eventBus = EventBus.instance;

  /// 事件订阅
  final List<EventSubscription> _subscriptions = <EventSubscription>[];

  /// 消息计数器
  int _messageCount = 0;

  /// 配置数据
  final Map<String, dynamic> _config = <String, dynamic>{
    'enabled': true,
    'debug': false,
    'maxMessages': 100,
  };

  @override
  String get id => pluginId;

  @override
  String get name => pluginName;

  @override
  String get version => pluginVersion;

  @override
  String get description => pluginDescription;

  @override
  String get author => pluginAuthor;

  @override
  PluginType get category => PluginType.tool;

  @override
  List<PluginPermission> get requiredPermissions => <PluginPermission>[
        PluginPermission.fileSystem,
        PluginPermission.notifications,
      ];

  @override
  List<PluginDependency> get dependencies => pluginDependencies;

  @override
  List<SupportedPlatform> get supportedPlatforms => <SupportedPlatform>[
        SupportedPlatform.android,
        SupportedPlatform.ios,
        SupportedPlatform.windows,
        SupportedPlatform.macos,
        SupportedPlatform.linux,
        SupportedPlatform.web,
      ];

  @override
  PluginState get currentState => _currentState;

  @override
  Stream<PluginState> get stateChanges => _stateController.stream;

  @override
  Future<void> initialize() async {
    _updateState(PluginState.initialized);

    // 订阅系统事件
    _subscriptions.add(
      _eventBus.onSystemEvent(SystemEvents.systemShutdown, _onSystemShutdown),
    );

    // 发布初始化事件
    _eventBus.publishPluginEvent(SystemEvents.pluginLoaded, id);

    print('[$id] Plugin initialized');
  }

  @override
  Future<void> start() async {
    _updateState(PluginState.started);

    // 发布启动事件
    _eventBus.publishPluginEvent(SystemEvents.pluginStarted, id);

    print('[$id] Plugin started');
  }

  @override
  Future<void> pause() async {
    _updateState(PluginState.paused);

    // 发布暂停事件
    _eventBus.publishPluginEvent(SystemEvents.pluginPaused, id);

    print('[$id] Plugin paused');
  }

  @override
  Future<void> resume() async {
    _updateState(PluginState.started);

    // 发布恢复事件
    _eventBus.publishPluginEvent(SystemEvents.pluginResumed, id);

    print('[$id] Plugin resumed');
  }

  @override
  Future<void> stop() async {
    _updateState(PluginState.stopped);

    // 发布停止事件
    _eventBus.publishPluginEvent(SystemEvents.pluginStopped, id);

    print('[$id] Plugin stopped');
  }

  @override
  Future<void> dispose() async {
    // 取消所有事件订阅
    for (final EventSubscription subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    // 发布卸载事件
    _eventBus.publishPluginEvent(SystemEvents.pluginUnloaded, id);

    // 更新状态（在关闭控制器之前）
    _updateState(PluginState.unloaded);

    // 关闭状态控制器
    await _stateController.close();

    print('[$id] Plugin disposed');
  }

  @override
  Object? getConfigWidget() {
    // 返回配置界面的描述（在实际Flutter应用中会返回Widget）
    return <String, dynamic>{
      'type': 'config_form',
      'title': 'Test Plugin Configuration',
      'fields': <Map<String, dynamic>>[
        <String, dynamic>{
          'name': 'enabled',
          'type': 'boolean',
          'label': 'Enable Plugin',
          'value': _config['enabled'],
        },
        <String, dynamic>{
          'name': 'debug',
          'type': 'boolean',
          'label': 'Debug Mode',
          'value': _config['debug'],
        },
        <String, dynamic>{
          'name': 'maxMessages',
          'type': 'number',
          'label': 'Max Messages',
          'value': _config['maxMessages'],
        },
      ],
    };
  }

  @override
  Object getMainWidget() {
    // 返回主界面的描述（在实际Flutter应用中会返回Widget）
    return <String, dynamic>{
      'type': 'test_plugin_widget',
      'title': 'Test Plugin',
      'content': <String, dynamic>{
        'status': _currentState.toString(),
        'messageCount': _messageCount,
        'config': _config,
        'subscriptions': _subscriptions.length,
      },
    };
  }

  @override
  Future<dynamic> handleMessage(
    String action,
    Map<String, dynamic> data,
  ) async {
    _messageCount++;

    print('[$id] Received message: $action with data: $data');

    switch (action) {
      case 'ping':
        return <String, dynamic>{
          'response': 'pong',
          'timestamp': DateTime.now().toIso8601String(),
          'messageCount': _messageCount,
        };

      case 'getStatus':
        return <String, dynamic>{
          'id': id,
          'name': name,
          'version': version,
          'state': _currentState.toString(),
          'messageCount': _messageCount,
          'config': _config,
        };

      case 'updateConfig':
        final String? key = data['key'] as String?;
        final dynamic value = data['value'];

        if (key != null && _config.containsKey(key)) {
          _config[key] = value;

          // 发布配置变更事件
          _eventBus.publishPluginEvent(
            SystemEvents.configChanged,
            id,
            data: <String, dynamic>{
              'key': key,
              'value': value,
            },
          );

          return <String, dynamic>{
            'success': true,
            'message': 'Config updated',
            'config': _config,
          };
        } else {
          return <String, dynamic>{
            'success': false,
            'message': 'Invalid config key: $key',
          };
        }

      case 'echo':
        return data;

      case 'error':
        throw Exception('Test error: ${data['message'] ?? 'Unknown error'}');

      default:
        return <String, dynamic>{
          'success': false,
          'message': 'Unknown action: $action',
          'supportedActions': <String>[
            'ping',
            'getStatus',
            'updateConfig',
            'echo',
            'error',
          ],
        };
    }
  }

  /// 更新插件状态
  void _updateState(PluginState newState) {
    if (_currentState != newState) {
      _currentState = newState;
      if (!_stateController.isClosed) {
        _stateController.add(newState);
      }
    }
  }

  /// 处理系统关闭事件
  void _onSystemShutdown(PluginEvent event) {
    print('[$id] Received system shutdown event, preparing to stop...');
    // 在实际应用中，这里可以进行清理工作
  }

  /// 获取插件统计信息
  Map<String, dynamic> getStats() => <String, dynamic>{
        'messageCount': _messageCount,
        'subscriptions': _subscriptions.length,
        'config': Map<String, dynamic>.from(_config),
        'uptime': DateTime.now().toIso8601String(),
      };

  /// 重置统计信息
  void resetStats() {
    _messageCount = 0;
    print('[$id] Stats reset');
  }
}

/// 另一个测试插件，用于测试插件间通信
class EchoPlugin extends Plugin {
  EchoPlugin({
    this.pluginId = 'echo_plugin',
    this.pluginName = 'Echo Plugin',
  });

  final String pluginId;
  final String pluginName;

  PluginState _currentState = PluginState.unloaded;
  final StreamController<PluginState> _stateController =
      StreamController<PluginState>.broadcast();

  @override
  String get id => pluginId;

  @override
  String get name => pluginName;

  @override
  String get version => '1.0.0';

  @override
  String get description => 'A simple echo plugin for testing communication';

  @override
  String get author => 'Pet App Team';

  @override
  PluginType get category => PluginType.tool;

  @override
  List<PluginPermission> get requiredPermissions => <PluginPermission>[];

  @override
  List<PluginDependency> get dependencies => <PluginDependency>[];

  @override
  List<SupportedPlatform> get supportedPlatforms => <SupportedPlatform>[
        SupportedPlatform.android,
        SupportedPlatform.ios,
        SupportedPlatform.windows,
        SupportedPlatform.macos,
        SupportedPlatform.linux,
        SupportedPlatform.web,
      ];

  @override
  PluginState get currentState => _currentState;

  @override
  Stream<PluginState> get stateChanges => _stateController.stream;

  @override
  Future<void> initialize() async {
    _currentState = PluginState.initialized;
    _stateController.add(_currentState);
    print('[$id] Echo plugin initialized');
  }

  @override
  Future<void> start() async {
    _currentState = PluginState.started;
    _stateController.add(_currentState);
    print('[$id] Echo plugin started');
  }

  @override
  Future<void> pause() async {
    _currentState = PluginState.paused;
    _stateController.add(_currentState);
  }

  @override
  Future<void> resume() async {
    _currentState = PluginState.started;
    _stateController.add(_currentState);
  }

  @override
  Future<void> stop() async {
    _currentState = PluginState.stopped;
    _stateController.add(_currentState);
    print('[$id] Echo plugin stopped');
  }

  @override
  Future<void> dispose() async {
    _currentState = PluginState.unloaded;
    await _stateController.close();
    print('[$id] Echo plugin disposed');
  }

  @override
  Object? getConfigWidget() => null;

  @override
  Object getMainWidget() => <String, dynamic>{
        'type': 'echo_widget',
        'title': 'Echo Plugin',
        'status': _currentState.toString(),
      };

  @override
  Future<dynamic> handleMessage(
    String action,
    Map<String, dynamic> data,
  ) async {
    print('[$id] Echo: $action -> $data');

    return <String, dynamic>{
      'echo': <String, dynamic>{
        'action': action,
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
        'from': id,
      },
    };
  }
}

/// 错误插件 - 用于测试错误处理
class ErrorPlugin extends Plugin {
  ErrorPlugin({required this.pluginId});

  final String pluginId;
  PluginState _currentState = PluginState.unloaded;
  final StreamController<PluginState> _stateController =
      StreamController<PluginState>.broadcast();

  @override
  String get id => pluginId;
  @override
  String get name => 'Error Plugin';
  @override
  String get version => '1.0.0';
  @override
  String get description => 'Plugin that throws errors for testing';
  @override
  String get author => 'Pet App Team';
  @override
  PluginType get category => PluginType.tool;
  @override
  List<PluginPermission> get requiredPermissions => <PluginPermission>[];
  @override
  List<PluginDependency> get dependencies => <PluginDependency>[];
  @override
  List<SupportedPlatform> get supportedPlatforms =>
      <SupportedPlatform>[SupportedPlatform.android];
  @override
  PluginState get currentState => _currentState;
  @override
  Stream<PluginState> get stateChanges => _stateController.stream;

  @override
  Future<void> initialize() async {
    throw Exception('Initialization error for testing');
  }

  @override
  Future<void> start() async {
    _currentState = PluginState.started;
    _stateController.add(_currentState);
  }

  @override
  Future<void> pause() async {
    _currentState = PluginState.paused;
    _stateController.add(_currentState);
  }

  @override
  Future<void> resume() async {
    _currentState = PluginState.started;
    _stateController.add(_currentState);
  }

  @override
  Future<void> stop() async {
    _currentState = PluginState.stopped;
    _stateController.add(_currentState);
  }

  @override
  Future<void> dispose() async {
    _currentState = PluginState.unloaded;
    await _stateController.close();
  }

  @override
  Object? getConfigWidget() => null;

  @override
  Object getMainWidget() => <String, dynamic>{'type': 'error_widget'};

  @override
  Future<dynamic> handleMessage(
    String action,
    Map<String, dynamic> data,
  ) async {
    throw Exception('Message handling error');
  }
}

/// 依赖插件 - 用于测试依赖解析
class DependentPlugin extends Plugin {
  DependentPlugin({required this.pluginId, required this.dependencyList});

  final String pluginId;
  final List<String> dependencyList;
  PluginState _currentState = PluginState.unloaded;
  final StreamController<PluginState> _stateController =
      StreamController<PluginState>.broadcast();

  @override
  String get id => pluginId;
  @override
  String get name => 'Dependent Plugin';
  @override
  String get version => '1.0.0';
  @override
  String get description => 'Plugin with dependencies for testing';
  @override
  String get author => 'Pet App Team';
  @override
  PluginType get category => PluginType.tool;
  @override
  List<PluginPermission> get requiredPermissions => <PluginPermission>[];
  @override
  List<PluginDependency> get dependencies => dependencyList
      .map((String dep) =>
          PluginDependency(pluginId: dep, versionConstraint: '1.0.0'))
      .toList();
  @override
  List<SupportedPlatform> get supportedPlatforms =>
      <SupportedPlatform>[SupportedPlatform.android];
  @override
  PluginState get currentState => _currentState;
  @override
  Stream<PluginState> get stateChanges => _stateController.stream;

  @override
  Future<void> initialize() async {
    _currentState = PluginState.initialized;
    _stateController.add(_currentState);
  }

  @override
  Future<void> start() async {
    _currentState = PluginState.started;
    _stateController.add(_currentState);
  }

  @override
  Future<void> pause() async {
    _currentState = PluginState.paused;
    _stateController.add(_currentState);
  }

  @override
  Future<void> resume() async {
    _currentState = PluginState.started;
    _stateController.add(_currentState);
  }

  @override
  Future<void> stop() async {
    _currentState = PluginState.stopped;
    _stateController.add(_currentState);
  }

  @override
  Future<void> dispose() async {
    _currentState = PluginState.unloaded;
    await _stateController.close();
  }

  @override
  Object? getConfigWidget() => null;

  @override
  Object getMainWidget() => <String, dynamic>{'type': 'dependent_widget'};

  @override
  Future<dynamic> handleMessage(
    String action,
    Map<String, dynamic> data,
  ) async =>
      <String, dynamic>{'response': 'dependent_response'};
}

/// 受限插件 - 用于测试权限系统
class RestrictedPlugin extends Plugin {
  RestrictedPlugin({required this.pluginId, required this.permissionList});

  final String pluginId;
  final List<String> permissionList;
  PluginState _currentState = PluginState.unloaded;
  final StreamController<PluginState> _stateController =
      StreamController<PluginState>.broadcast();

  @override
  String get id => pluginId;
  @override
  String get name => 'Restricted Plugin';
  @override
  String get version => '1.0.0';
  @override
  String get description => 'Plugin with restricted permissions';
  @override
  String get author => 'Pet App Team';
  @override
  PluginType get category => PluginType.tool;
  @override
  List<PluginPermission> get requiredPermissions => <PluginPermission>[
        PluginPermission.fileSystem,
        PluginPermission.network,
        PluginPermission.camera,
      ];
  @override
  List<PluginDependency> get dependencies => <PluginDependency>[];
  @override
  List<SupportedPlatform> get supportedPlatforms =>
      <SupportedPlatform>[SupportedPlatform.android];
  @override
  PluginState get currentState => _currentState;
  @override
  Stream<PluginState> get stateChanges => _stateController.stream;

  @override
  Future<void> initialize() async {
    _currentState = PluginState.initialized;
    _stateController.add(_currentState);
  }

  @override
  Future<void> start() async {
    _currentState = PluginState.started;
    _stateController.add(_currentState);
  }

  @override
  Future<void> pause() async {
    _currentState = PluginState.paused;
    _stateController.add(_currentState);
  }

  @override
  Future<void> resume() async {
    _currentState = PluginState.started;
    _stateController.add(_currentState);
  }

  @override
  Future<void> stop() async {
    _currentState = PluginState.stopped;
    _stateController.add(_currentState);
  }

  @override
  Future<void> dispose() async {
    _currentState = PluginState.unloaded;
    await _stateController.close();
  }

  @override
  Object? getConfigWidget() => null;

  @override
  Object getMainWidget() => <String, dynamic>{'type': 'restricted_widget'};

  @override
  Future<dynamic> handleMessage(
    String action,
    Map<String, dynamic> data,
  ) async =>
      <String, dynamic>{'response': 'restricted_response'};
}

/// 隔离插件 - 用于测试插件隔离
class IsolatedPlugin extends Plugin {
  IsolatedPlugin({required this.pluginId});

  final String pluginId;
  PluginState _currentState = PluginState.unloaded;
  final StreamController<PluginState> _stateController =
      StreamController<PluginState>.broadcast();
  bool isIsolated = false;

  @override
  String get id => pluginId;
  @override
  String get name => 'Isolated Plugin';
  @override
  String get version => '1.0.0';
  @override
  String get description => 'Plugin that runs in isolation';
  @override
  String get author => 'Pet App Team';
  @override
  PluginType get category => PluginType.tool;
  @override
  List<PluginPermission> get requiredPermissions => <PluginPermission>[];
  @override
  List<PluginDependency> get dependencies => <PluginDependency>[];
  @override
  List<SupportedPlatform> get supportedPlatforms =>
      <SupportedPlatform>[SupportedPlatform.android];
  @override
  PluginState get currentState => _currentState;
  @override
  Stream<PluginState> get stateChanges => _stateController.stream;

  @override
  Future<void> initialize() async {
    isIsolated = true; // 模拟隔离环境
    _currentState = PluginState.initialized;
    _stateController.add(_currentState);
  }

  @override
  Future<void> start() async {
    _currentState = PluginState.started;
    _stateController.add(_currentState);
  }

  @override
  Future<void> pause() async {
    _currentState = PluginState.paused;
    _stateController.add(_currentState);
  }

  @override
  Future<void> resume() async {
    _currentState = PluginState.started;
    _stateController.add(_currentState);
  }

  @override
  Future<void> stop() async {
    _currentState = PluginState.stopped;
    _stateController.add(_currentState);
  }

  @override
  Future<void> dispose() async {
    _currentState = PluginState.unloaded;
    await _stateController.close();
  }

  @override
  Object? getConfigWidget() => null;

  @override
  Object getMainWidget() => <String, dynamic>{'type': 'isolated_widget'};

  @override
  Future<dynamic> handleMessage(
    String action,
    Map<String, dynamic> data,
  ) async =>
      <String, dynamic>{'response': 'isolated_response'};
}

/// 恶意插件 - 用于测试安全防护
class MaliciousPlugin extends Plugin {
  MaliciousPlugin({required this.pluginId});

  final String pluginId;
  PluginState _currentState = PluginState.unloaded;
  final StreamController<PluginState> _stateController =
      StreamController<PluginState>.broadcast();

  @override
  String get id => pluginId;
  @override
  String get name => 'Malicious Plugin';
  @override
  String get version => '1.0.0';
  @override
  String get description => 'Plugin with malicious behavior';
  @override
  String get author => 'Unknown';
  @override
  PluginType get category => PluginType.tool;
  @override
  List<PluginPermission> get requiredPermissions => <PluginPermission>[
        PluginPermission.fileSystem,
        PluginPermission.network,
        PluginPermission.camera,
        PluginPermission.microphone,
      ];
  @override
  List<PluginDependency> get dependencies => <PluginDependency>[];
  @override
  List<SupportedPlatform> get supportedPlatforms =>
      <SupportedPlatform>[SupportedPlatform.android];
  @override
  PluginState get currentState => _currentState;
  @override
  Stream<PluginState> get stateChanges => _stateController.stream;

  @override
  Future<void> initialize() async {
    // 模拟恶意行为
    throw Exception('Malicious plugin detected');
  }

  @override
  Future<void> start() async {
    _currentState = PluginState.started;
    _stateController.add(_currentState);
  }

  @override
  Future<void> pause() async {
    _currentState = PluginState.paused;
    _stateController.add(_currentState);
  }

  @override
  Future<void> resume() async {
    _currentState = PluginState.started;
    _stateController.add(_currentState);
  }

  @override
  Future<void> stop() async {
    _currentState = PluginState.stopped;
    _stateController.add(_currentState);
  }

  @override
  Future<void> dispose() async {
    _currentState = PluginState.unloaded;
    await _stateController.close();
  }

  @override
  Object? getConfigWidget() => null;

  @override
  Object getMainWidget() => <String, dynamic>{'type': 'malicious_widget'};

  @override
  Future<dynamic> handleMessage(
    String action,
    Map<String, dynamic> data,
  ) async {
    throw Exception('Malicious message handling');
  }
}

/// 资源密集型插件 - 用于测试性能监控
class ResourceIntensivePlugin extends Plugin {
  ResourceIntensivePlugin({required this.pluginId});

  final String pluginId;
  PluginState _currentState = PluginState.unloaded;
  final StreamController<PluginState> _stateController =
      StreamController<PluginState>.broadcast();

  @override
  String get id => pluginId;
  @override
  String get name => 'Resource Intensive Plugin';
  @override
  String get version => '1.0.0';
  @override
  String get description => 'Plugin that uses lots of resources';
  @override
  String get author => 'Pet App Team';
  @override
  PluginType get category => PluginType.tool;
  @override
  List<PluginPermission> get requiredPermissions => <PluginPermission>[];
  @override
  List<PluginDependency> get dependencies => <PluginDependency>[];
  @override
  List<SupportedPlatform> get supportedPlatforms =>
      <SupportedPlatform>[SupportedPlatform.android];
  @override
  PluginState get currentState => _currentState;
  @override
  Stream<PluginState> get stateChanges => _stateController.stream;

  @override
  Future<void> initialize() async {
    _currentState = PluginState.initialized;
    _stateController.add(_currentState);
  }

  @override
  Future<void> start() async {
    _currentState = PluginState.started;
    _stateController.add(_currentState);
  }

  @override
  Future<void> pause() async {
    _currentState = PluginState.paused;
    _stateController.add(_currentState);
  }

  @override
  Future<void> resume() async {
    _currentState = PluginState.started;
    _stateController.add(_currentState);
  }

  @override
  Future<void> stop() async {
    _currentState = PluginState.stopped;
    _stateController.add(_currentState);
  }

  @override
  Future<void> dispose() async {
    _currentState = PluginState.unloaded;
    await _stateController.close();
  }

  @override
  Object? getConfigWidget() => null;

  @override
  Object getMainWidget() => <String, dynamic>{'type': 'resource_widget'};

  @override
  Future<dynamic> handleMessage(
    String action,
    Map<String, dynamic> data,
  ) async =>
      <String, dynamic>{'response': 'resource_response'};

  /// 模拟资源密集型工作
  Future<void> doWork() async {
    // 模拟CPU密集型操作
    await Future<void>.delayed(const Duration(milliseconds: 100));

    // 模拟内存使用
    final List<int> data = List<int>.filled(1000, 42);
    data.length; // 使用数据避免被优化掉
  }
}
