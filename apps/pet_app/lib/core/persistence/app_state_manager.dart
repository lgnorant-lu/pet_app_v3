/*
---------------------------------------------------------------
File name:          app_state_manager.dart
Author:             Pet App V3 Team
Date created:       2025-07-19
Last modified:      2025-07-19
Dart Version:       3.2+
Description:        应用状态持久化管理器 - Phase 3.1 核心组件
---------------------------------------------------------------
Change History:
    2025-07-19: Phase 3.1 - 实现状态持久化、用户偏好管理、数据同步;
---------------------------------------------------------------
*/

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 应用状态数据
class AppStateData {
  final ThemeMode themeMode;
  final Locale locale;
  final Map<String, dynamic> userPreferences;
  final Map<String, dynamic> moduleStates;
  final DateTime lastSaved;

  AppStateData({
    required this.themeMode,
    required this.locale,
    required this.userPreferences,
    required this.moduleStates,
    required this.lastSaved,
  });

  Map<String, dynamic> toJson() {
    return {
      'theme_mode': themeMode.name,
      'locale': '${locale.languageCode}_${locale.countryCode}',
      'user_preferences': userPreferences,
      'module_states': moduleStates,
      'last_saved': lastSaved.toIso8601String(),
    };
  }

  factory AppStateData.fromJson(Map<String, dynamic> json) {
    final localeStr = json['locale'] as String? ?? 'zh_CN';
    final localeParts = localeStr.split('_');
    
    return AppStateData(
      themeMode: ThemeMode.values.firstWhere(
        (mode) => mode.name == json['theme_mode'],
        orElse: () => ThemeMode.system,
      ),
      locale: Locale(
        localeParts.isNotEmpty ? localeParts[0] : 'zh',
        localeParts.length > 1 ? localeParts[1] : 'CN',
      ),
      userPreferences: Map<String, dynamic>.from(json['user_preferences'] ?? {}),
      moduleStates: Map<String, dynamic>.from(json['module_states'] ?? {}),
      lastSaved: DateTime.tryParse(json['last_saved'] ?? '') ?? DateTime.now(),
    );
  }
}

/// 应用状态持久化管理器
/// 
/// Phase 3.1 核心功能：
/// - 状态持久化系统
/// - 用户偏好管理
/// - 模块状态同步
/// - 数据备份恢复
class AppStateManager {
  static final AppStateManager _instance = AppStateManager._();
  static AppStateManager get instance => _instance;
  
  AppStateManager._();

  /// SharedPreferences实例
  SharedPreferences? _prefs;
  
  /// 是否已初始化
  bool _isInitialized = false;
  
  /// 当前应用状态
  AppStateData? _currentState;
  
  /// 状态变更流控制器
  final StreamController<AppStateData> _stateController = 
      StreamController<AppStateData>.broadcast();
  
  /// 自动保存定时器
  Timer? _autoSaveTimer;
  
  /// 状态变更标记
  bool _hasUnsavedChanges = false;

  /// 存储键名常量
  static const String _stateKey = 'pet_app_v3_state';
  static const String _backupKey = 'pet_app_v3_state_backup';
  
  /// 获取是否已初始化
  bool get isInitialized => _isInitialized;
  
  /// 获取当前状态
  AppStateData? get currentState => _currentState;
  
  /// 获取状态变更流
  Stream<AppStateData> get stateStream => _stateController.stream;
  
  /// 获取是否有未保存的变更
  bool get hasUnsavedChanges => _hasUnsavedChanges;

  /// 初始化状态管理器
  Future<void> initialize() async {
    if (_isInitialized) {
      _log('warning', '应用状态管理器已经初始化');
      return;
    }

    try {
      _log('info', '初始化应用状态管理器');
      
      // 初始化SharedPreferences
      _prefs = await SharedPreferences.getInstance();
      
      // 加载保存的状态
      await _loadState();
      
      // 启动自动保存
      _startAutoSave();
      
      _isInitialized = true;
      _log('info', '应用状态管理器初始化完成');
      
    } catch (e, stackTrace) {
      _log('severe', '应用状态管理器初始化失败', e, stackTrace);
      rethrow;
    }
  }

  /// 获取主题模式
  Future<ThemeMode?> getThemeMode() async {
    await _ensureInitialized();
    return _currentState?.themeMode;
  }

  /// 设置主题模式
  Future<void> setThemeMode(ThemeMode themeMode) async {
    await _ensureInitialized();
    
    _currentState = _createUpdatedState(
      themeMode: themeMode,
    );
    
    _markChanged();
    _log('info', '主题模式已更新: ${themeMode.name}');
  }

  /// 获取语言环境
  Future<Locale?> getLocale() async {
    await _ensureInitialized();
    return _currentState?.locale;
  }

  /// 设置语言环境
  Future<void> setLocale(Locale locale) async {
    await _ensureInitialized();
    
    _currentState = _createUpdatedState(
      locale: locale,
    );
    
    _markChanged();
    _log('info', '语言环境已更新: ${locale.languageCode}_${locale.countryCode}');
  }

  /// 获取用户偏好
  Future<T?> getUserPreference<T>(String key) async {
    await _ensureInitialized();
    return _currentState?.userPreferences[key] as T?;
  }

  /// 设置用户偏好
  Future<void> setUserPreference<T>(String key, T value) async {
    await _ensureInitialized();
    
    final preferences = Map<String, dynamic>.from(_currentState?.userPreferences ?? {});
    preferences[key] = value;
    
    _currentState = _createUpdatedState(
      userPreferences: preferences,
    );
    
    _markChanged();
    _log('info', '用户偏好已更新: $key = $value');
  }

  /// 获取模块状态
  Future<Map<String, dynamic>?> getModuleState(String moduleId) async {
    await _ensureInitialized();
    return _currentState?.moduleStates[moduleId] as Map<String, dynamic>?;
  }

  /// 设置模块状态
  Future<void> setModuleState(String moduleId, Map<String, dynamic> state) async {
    await _ensureInitialized();
    
    final moduleStates = Map<String, dynamic>.from(_currentState?.moduleStates ?? {});
    moduleStates[moduleId] = state;
    
    _currentState = _createUpdatedState(
      moduleStates: moduleStates,
    );
    
    _markChanged();
    _log('info', '模块状态已更新: $moduleId');
  }

  /// 手动保存状态
  Future<void> saveState() async {
    await _ensureInitialized();
    
    if (_currentState == null) {
      _log('warning', '没有状态需要保存');
      return;
    }

    try {
      // 创建备份
      await _createBackup();
      
      // 保存当前状态
      final stateJson = jsonEncode(_currentState!.toJson());
      await _prefs!.setString(_stateKey, stateJson);
      
      _hasUnsavedChanges = false;
      _log('info', '应用状态已保存');
      
    } catch (e, stackTrace) {
      _log('severe', '保存应用状态失败', e, stackTrace);
      rethrow;
    }
  }

  /// 恢复状态
  Future<void> restoreState() async {
    await _ensureInitialized();
    
    try {
      // 尝试从备份恢复
      final backupJson = _prefs!.getString(_backupKey);
      if (backupJson != null) {
        final backupData = jsonDecode(backupJson) as Map<String, dynamic>;
        _currentState = AppStateData.fromJson(backupData);
        
        // 保存恢复的状态
        await saveState();
        
        _notifyStateChanged();
        _log('info', '应用状态已从备份恢复');
      } else {
        _log('warning', '没有找到备份状态');
      }
      
    } catch (e, stackTrace) {
      _log('severe', '恢复应用状态失败', e, stackTrace);
      rethrow;
    }
  }

  /// 清除所有状态
  Future<void> clearState() async {
    await _ensureInitialized();
    
    try {
      await _prefs!.remove(_stateKey);
      await _prefs!.remove(_backupKey);
      
      _currentState = _createDefaultState();
      _hasUnsavedChanges = false;
      
      _notifyStateChanged();
      _log('info', '应用状态已清除');
      
    } catch (e, stackTrace) {
      _log('severe', '清除应用状态失败', e, stackTrace);
      rethrow;
    }
  }

  /// 加载状态
  Future<void> _loadState() async {
    try {
      final stateJson = _prefs!.getString(_stateKey);
      
      if (stateJson != null) {
        final stateData = jsonDecode(stateJson) as Map<String, dynamic>;
        _currentState = AppStateData.fromJson(stateData);
        _log('info', '应用状态已加载');
      } else {
        _currentState = _createDefaultState();
        _log('info', '使用默认应用状态');
      }
      
      _notifyStateChanged();
      
    } catch (e, stackTrace) {
      _log('warning', '加载应用状态失败，使用默认状态', e, stackTrace);
      _currentState = _createDefaultState();
      _notifyStateChanged();
    }
  }

  /// 创建默认状态
  AppStateData _createDefaultState() {
    return AppStateData(
      themeMode: ThemeMode.system,
      locale: const Locale('zh', 'CN'),
      userPreferences: {},
      moduleStates: {},
      lastSaved: DateTime.now(),
    );
  }

  /// 创建更新后的状态
  AppStateData _createUpdatedState({
    ThemeMode? themeMode,
    Locale? locale,
    Map<String, dynamic>? userPreferences,
    Map<String, dynamic>? moduleStates,
  }) {
    final current = _currentState ?? _createDefaultState();
    
    return AppStateData(
      themeMode: themeMode ?? current.themeMode,
      locale: locale ?? current.locale,
      userPreferences: userPreferences ?? current.userPreferences,
      moduleStates: moduleStates ?? current.moduleStates,
      lastSaved: DateTime.now(),
    );
  }

  /// 标记状态已变更
  void _markChanged() {
    _hasUnsavedChanges = true;
    _notifyStateChanged();
  }

  /// 通知状态变更
  void _notifyStateChanged() {
    if (_currentState != null) {
      _stateController.add(_currentState!);
    }
  }

  /// 启动自动保存
  void _startAutoSave() {
    _autoSaveTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (_hasUnsavedChanges) {
        saveState();
      }
    });
  }

  /// 创建备份
  Future<void> _createBackup() async {
    try {
      final currentJson = _prefs!.getString(_stateKey);
      if (currentJson != null) {
        await _prefs!.setString(_backupKey, currentJson);
      }
    } catch (e) {
      _log('warning', '创建状态备份失败', e);
    }
  }

  /// 确保已初始化
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  /// 清理资源
  Future<void> dispose() async {
    try {
      _log('info', '清理应用状态管理器资源');
      
      // 保存未保存的变更
      if (_hasUnsavedChanges) {
        await saveState();
      }
      
      // 停止自动保存
      _autoSaveTimer?.cancel();
      
      // 关闭状态流
      await _stateController.close();
      
      _log('info', '应用状态管理器资源清理完成');
    } catch (e) {
      _log('warning', '清理应用状态管理器资源时发生错误', e);
    }
  }

  /// 日志记录
  void _log(String level, String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      print('[$timestamp] [AppStateManager] [$level] $message');
      if (error != null) print('Error: $error');
      if (stackTrace != null) print('StackTrace: $stackTrace');
    }
  }
}
