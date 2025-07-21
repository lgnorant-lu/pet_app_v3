/*
---------------------------------------------------------------
File name:          gesture_navigation_manager.dart
Author:             Pet App V3 Team
Date created:       2025-07-19
Last modified:      2025-07-19
Dart Version:       3.2+
Description:        Phase 3.3.2.3 手势导航管理器
---------------------------------------------------------------
Change History:
    2025-07-19: Phase 3.3.2.3 - 实现手势导航、滑动手势、多点触控;
---------------------------------------------------------------
*/

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:communication_system/communication_system.dart' as comm;

/// 手势类型
enum GestureType {
  /// 滑动手势
  swipe,
  
  /// 捏合手势
  pinch,
  
  /// 旋转手势
  rotate,
  
  /// 长按手势
  longPress,
  
  /// 双击手势
  doubleTap,
  
  /// 三指手势
  threeFingerTap,
  
  /// 边缘滑动
  edgeSwipe,
}

/// 滑动方向
enum SwipeDirection {
  left,
  right,
  up,
  down,
}

/// 手势配置
class GestureConfig {
  final GestureType type;
  final double sensitivity;
  final Duration timeout;
  final double minDistance;
  final double maxDistance;
  final int minFingers;
  final int maxFingers;
  final bool enabled;

  const GestureConfig({
    required this.type,
    this.sensitivity = 1.0,
    this.timeout = const Duration(milliseconds: 500),
    this.minDistance = 50.0,
    this.maxDistance = double.infinity,
    this.minFingers = 1,
    this.maxFingers = 1,
    this.enabled = true,
  });

  /// 预定义配置
  static const GestureConfig swipeLeft = GestureConfig(
    type: GestureType.swipe,
    minDistance: 100.0,
    sensitivity: 1.2,
  );

  static const GestureConfig swipeRight = GestureConfig(
    type: GestureType.swipe,
    minDistance: 100.0,
    sensitivity: 1.2,
  );

  static const GestureConfig edgeSwipeBack = GestureConfig(
    type: GestureType.edgeSwipe,
    minDistance: 50.0,
    sensitivity: 1.5,
  );

  static const GestureConfig pinchZoom = GestureConfig(
    type: GestureType.pinch,
    minFingers: 2,
    maxFingers: 2,
    sensitivity: 0.8,
  );

  static const GestureConfig threeFingerNavigation = GestureConfig(
    type: GestureType.threeFingerTap,
    minFingers: 3,
    maxFingers: 3,
    timeout: Duration(milliseconds: 300),
  );
}

/// 手势事件
class GestureEvent {
  final GestureType type;
  final Offset startPosition;
  final Offset currentPosition;
  final Offset? endPosition;
  final SwipeDirection? direction;
  final double velocity;
  final double scale;
  final double rotation;
  final int fingerCount;
  final Duration duration;
  final DateTime timestamp;

  const GestureEvent({
    required this.type,
    required this.startPosition,
    required this.currentPosition,
    this.endPosition,
    this.direction,
    this.velocity = 0.0,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.fingerCount = 1,
    required this.duration,
    required this.timestamp,
  });

  /// 获取滑动距离
  double get distance {
    final end = endPosition ?? currentPosition;
    return (end - startPosition).distance;
  }

  /// 获取滑动角度
  double get angle {
    final end = endPosition ?? currentPosition;
    final delta = end - startPosition;
    return math.atan2(delta.dy, delta.dx);
  }

  @override
  String toString() {
    return 'GestureEvent(type: $type, direction: $direction, distance: ${distance.toStringAsFixed(1)})';
  }
}

/// 手势动作
typedef GestureAction = Future<bool> Function(GestureEvent event);

/// 手势条目
class GestureEntry {
  final String id;
  final GestureConfig config;
  final GestureAction action;
  final String description;
  final String category;
  final bool enabled;
  final int priority;

  const GestureEntry({
    required this.id,
    required this.config,
    required this.action,
    required this.description,
    this.category = 'general',
    this.enabled = true,
    this.priority = 0,
  });

  /// 创建副本
  GestureEntry copyWith({
    String? id,
    GestureConfig? config,
    GestureAction? action,
    String? description,
    String? category,
    bool? enabled,
    int? priority,
  }) {
    return GestureEntry(
      id: id ?? this.id,
      config: config ?? this.config,
      action: action ?? this.action,
      description: description ?? this.description,
      category: category ?? this.category,
      enabled: enabled ?? this.enabled,
      priority: priority ?? this.priority,
    );
  }
}

/// 手势导航管理器
/// 
/// Phase 3.3.2.3 核心功能：
/// - 手势识别和处理
/// - 滑动导航支持
/// - 多点触控手势
/// - 边缘滑动检测
/// - 手势自定义配置
class GestureNavigationManager {
  GestureNavigationManager._();
  
  static final GestureNavigationManager _instance = GestureNavigationManager._();
  static GestureNavigationManager get instance => _instance;

  /// 统一消息总线
  final comm.UnifiedMessageBus _messageBus = comm.UnifiedMessageBus.instance;

  /// 注册的手势
  final Map<String, GestureEntry> _gestures = {};
  
  /// 手势分类
  final Map<String, List<String>> _categories = {};
  
  /// 当前活动的手势
  final Map<int, Offset> _activePointers = {};
  
  /// 手势开始时间
  DateTime? _gestureStartTime;
  
  /// 手势开始位置
  Offset? _gestureStartPosition;
  
  /// 是否启用手势
  bool _enabled = true;
  
  /// 边缘检测阈值
  final double _edgeThreshold = 20.0;
  
  /// 手势事件流
  final StreamController<GestureEvent> _gestureController = 
      StreamController<GestureEvent>.broadcast();

  /// 初始化手势管理器
  Future<void> initialize() async {
    try {
      _registerDefaultGestures();
      debugPrint('GestureNavigationManager initialized');
    } catch (e, stackTrace) {
      debugPrint('Failed to initialize GestureNavigationManager: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// 注册默认手势
  void _registerDefaultGestures() {
    // 滑动返回手势
    registerGesture(GestureEntry(
      id: 'swipe_back',
      config: GestureConfig.swipeRight,
      action: (event) async {
        if (event.direction == SwipeDirection.right && event.distance > 100) {
          _messageBus.publishEvent('gesture_navigation', 'navigate_back', {
            'distance': event.distance,
            'velocity': event.velocity,
          });
          return true;
        }
        return false;
      },
      description: '向右滑动返回',
      category: 'navigation',
    ));

    // 滑动前进手势
    registerGesture(GestureEntry(
      id: 'swipe_forward',
      config: GestureConfig.swipeLeft,
      action: (event) async {
        if (event.direction == SwipeDirection.left && event.distance > 100) {
          _messageBus.publishEvent('gesture_navigation', 'navigate_forward', {
            'distance': event.distance,
            'velocity': event.velocity,
          });
          return true;
        }
        return false;
      },
      description: '向左滑动前进',
      category: 'navigation',
    ));

    // 边缘滑动返回
    registerGesture(GestureEntry(
      id: 'edge_swipe_back',
      config: GestureConfig.edgeSwipeBack,
      action: (event) async {
        if (event.direction == SwipeDirection.right && 
            event.startPosition.dx < _edgeThreshold) {
          _messageBus.publishEvent('gesture_navigation', 'edge_navigate_back', {
            'startX': event.startPosition.dx,
            'distance': event.distance,
          });
          return true;
        }
        return false;
      },
      description: '从左边缘滑动返回',
      category: 'navigation',
    ));

    // 三指上滑显示概览
    registerGesture(GestureEntry(
      id: 'three_finger_overview',
      config: GestureConfig.threeFingerNavigation,
      action: (event) async {
        if (event.fingerCount >= 3 && event.direction == SwipeDirection.up) {
          _messageBus.publishEvent('gesture_navigation', 'show_overview', {
            'fingerCount': event.fingerCount,
          });
          return true;
        }
        return false;
      },
      description: '三指上滑显示概览',
      category: 'application',
    ));

    // 双击缩放
    registerGesture(GestureEntry(
      id: 'double_tap_zoom',
      config: const GestureConfig(
        type: GestureType.doubleTap,
        timeout: Duration(milliseconds: 300),
      ),
      action: (event) async {
        _messageBus.publishEvent('gesture_navigation', 'double_tap_zoom', {
          'position': {'x': event.currentPosition.dx, 'y': event.currentPosition.dy},
        });
        return true;
      },
      description: '双击缩放',
      category: 'interaction',
    ));

    // 长按显示菜单
    registerGesture(GestureEntry(
      id: 'long_press_menu',
      config: const GestureConfig(
        type: GestureType.longPress,
        timeout: Duration(milliseconds: 800),
      ),
      action: (event) async {
        _messageBus.publishEvent('gesture_navigation', 'show_context_menu', {
          'position': {'x': event.currentPosition.dx, 'y': event.currentPosition.dy},
        });
        return true;
      },
      description: '长按显示菜单',
      category: 'interaction',
    ));
  }

  /// 注册手势
  void registerGesture(GestureEntry gesture) {
    _gestures[gesture.id] = gesture;
    
    // 添加到分类
    _categories.putIfAbsent(gesture.category, () => []);
    if (!_categories[gesture.category]!.contains(gesture.id)) {
      _categories[gesture.category]!.add(gesture.id);
    }

    _messageBus.publishEvent(
      'gesture_navigation',
      'gesture_registered',
      {
        'id': gesture.id,
        'type': gesture.config.type.name,
        'category': gesture.category,
      },
    );

    debugPrint('Registered gesture: ${gesture.id} (${gesture.config.type.name})');
  }

  /// 注销手势
  void unregisterGesture(String gestureId) {
    final gesture = _gestures.remove(gestureId);
    if (gesture != null) {
      _categories[gesture.category]?.remove(gestureId);
      
      _messageBus.publishEvent(
        'gesture_navigation',
        'gesture_unregistered',
        {'id': gestureId},
      );
      
      debugPrint('Unregistered gesture: $gestureId');
    }
  }

  /// 处理指针按下事件
  void handlePointerDown(PointerDownEvent event) {
    if (!_enabled) return;

    _activePointers[event.pointer] = event.position;
    
    if (_activePointers.length == 1) {
      _gestureStartTime = DateTime.now();
      _gestureStartPosition = event.position;
    }
  }

  /// 处理指针移动事件
  void handlePointerMove(PointerMoveEvent event) {
    if (!_enabled || _gestureStartPosition == null) return;

    _activePointers[event.pointer] = event.position;
    
    // 检测滑动手势
    _detectSwipeGesture(event);
  }

  /// 处理指针抬起事件
  void handlePointerUp(PointerUpEvent event) {
    if (!_enabled) return;

    _activePointers.remove(event.pointer);
    
    if (_activePointers.isEmpty) {
      _finalizeGesture(event);
    }
  }

  /// 检测滑动手势
  void _detectSwipeGesture(PointerMoveEvent event) {
    if (_gestureStartPosition == null || _gestureStartTime == null) return;

    final distance = (event.position - _gestureStartPosition!).distance;
    final duration = DateTime.now().difference(_gestureStartTime!);
    
    if (distance > 50.0) { // 最小滑动距离
      final direction = _getSwipeDirection(_gestureStartPosition!, event.position);
      final velocity = distance / duration.inMilliseconds;
      
      final gestureEvent = GestureEvent(
        type: GestureType.swipe,
        startPosition: _gestureStartPosition!,
        currentPosition: event.position,
        direction: direction,
        velocity: velocity,
        fingerCount: _activePointers.length,
        duration: duration,
        timestamp: DateTime.now(),
      );
      
      _processGestureEvent(gestureEvent);
    }
  }

  /// 完成手势
  void _finalizeGesture(PointerUpEvent event) {
    if (_gestureStartPosition == null || _gestureStartTime == null) return;

    final distance = (event.position - _gestureStartPosition!).distance;
    final duration = DateTime.now().difference(_gestureStartTime!);
    
    // 检测点击手势
    if (distance < 10.0 && duration.inMilliseconds < 300) {
      final gestureEvent = GestureEvent(
        type: GestureType.doubleTap, // 简化处理，实际需要检测双击
        startPosition: _gestureStartPosition!,
        currentPosition: event.position,
        endPosition: event.position,
        duration: duration,
        timestamp: DateTime.now(),
      );
      
      _processGestureEvent(gestureEvent);
    }
    
    // 重置状态
    _gestureStartPosition = null;
    _gestureStartTime = null;
  }

  /// 处理手势事件
  Future<void> _processGestureEvent(GestureEvent event) async {
    final matchingGestures = _findMatchingGestures(event);
    
    if (matchingGestures.isNotEmpty) {
      // 按优先级排序
      matchingGestures.sort((a, b) => b.priority.compareTo(a.priority));
      
      for (final gesture in matchingGestures) {
        if (gesture.enabled && gesture.config.enabled) {
          try {
            final handled = await gesture.action(event);
            if (handled) {
              _gestureController.add(event);
              
              _messageBus.publishEvent(
                'gesture_navigation',
                'gesture_executed',
                {
                  'id': gesture.id,
                  'type': event.type.name,
                  'direction': event.direction?.name,
                  'distance': event.distance,
                  'timestamp': event.timestamp.toIso8601String(),
                },
              );
              
              debugPrint('Executed gesture: ${gesture.id}');
              break;
            }
          } catch (e) {
            debugPrint('Error executing gesture ${gesture.id}: $e');
          }
        }
      }
    }
  }

  /// 查找匹配的手势
  List<GestureEntry> _findMatchingGestures(GestureEvent event) {
    return _gestures.values
        .where((gesture) => _isGestureMatch(gesture, event))
        .toList();
  }

  /// 检查手势是否匹配
  bool _isGestureMatch(GestureEntry gesture, GestureEvent event) {
    final config = gesture.config;
    
    // 检查手势类型
    if (config.type != event.type) return false;
    
    // 检查距离
    if (event.distance < config.minDistance || event.distance > config.maxDistance) {
      return false;
    }
    
    // 检查手指数量
    if (event.fingerCount < config.minFingers || event.fingerCount > config.maxFingers) {
      return false;
    }
    
    // 检查边缘滑动
    if (config.type == GestureType.edgeSwipe) {
      return event.startPosition.dx < _edgeThreshold ||
             event.startPosition.dx > (800 - _edgeThreshold); // 假设屏幕宽度
    }
    
    return true;
  }

  /// 获取滑动方向
  SwipeDirection _getSwipeDirection(Offset start, Offset end) {
    final delta = end - start;
    
    if (delta.dx.abs() > delta.dy.abs()) {
      return delta.dx > 0 ? SwipeDirection.right : SwipeDirection.left;
    } else {
      return delta.dy > 0 ? SwipeDirection.down : SwipeDirection.up;
    }
  }

  /// 启用/禁用手势
  void setEnabled(bool enabled) {
    _enabled = enabled;
    
    _messageBus.publishEvent(
      'gesture_navigation',
      'gestures_toggled',
      {'enabled': enabled},
    );
    
    debugPrint('Gestures ${enabled ? 'enabled' : 'disabled'}');
  }

  /// 启用/禁用特定手势
  void setGestureEnabled(String gestureId, bool enabled) {
    final gesture = _gestures[gestureId];
    if (gesture != null) {
      _gestures[gestureId] = gesture.copyWith(enabled: enabled);
      
      _messageBus.publishEvent(
        'gesture_navigation',
        'gesture_toggled',
        {'id': gestureId, 'enabled': enabled},
      );
    }
  }

  /// 获取手势列表
  List<GestureEntry> getGestures({String? category}) {
    if (category != null) {
      final categoryIds = _categories[category] ?? [];
      return categoryIds
          .map((id) => _gestures[id])
          .where((gesture) => gesture != null)
          .cast<GestureEntry>()
          .toList();
    }
    
    return List.unmodifiable(_gestures.values);
  }

  /// 获取手势分类
  List<String> get categories => List.unmodifiable(_categories.keys);

  /// 获取手势帮助信息
  Map<String, List<Map<String, String>>> getGestureHelp() {
    final help = <String, List<Map<String, String>>>{};
    
    for (final category in _categories.keys) {
      help[category] = getGestures(category: category)
          .where((gesture) => gesture.enabled)
          .map((gesture) => {
                'type': gesture.config.type.name,
                'description': gesture.description,
              })
          .toList();
    }
    
    return help;
  }

  /// 清除活动指针
  void clearActivePointers() {
    _activePointers.clear();
    _gestureStartPosition = null;
    _gestureStartTime = null;
  }

  /// 是否启用
  bool get enabled => _enabled;

  /// 手势事件流
  Stream<GestureEvent> get gestureStream => _gestureController.stream;

  /// 清理资源
  void dispose() {
    _gestureController.close();
    _gestures.clear();
    _categories.clear();
    _activePointers.clear();
    
    debugPrint('GestureNavigationManager disposed');
  }
}
