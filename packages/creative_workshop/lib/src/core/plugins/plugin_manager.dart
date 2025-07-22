/*
---------------------------------------------------------------
File name:          plugin_manager.dart
Author:             lgnorant-lu
Date created:       2025-07-22
Last modified:      2025-07-22
Dart Version:       3.2+
Description:        插件管理核心服务
---------------------------------------------------------------
Change History:
    2025-07-22: Phase 5.0.6.4 - 插件管理功能实现;
---------------------------------------------------------------
*/

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
// import 'package:creative_workshop/src/core/plugins/plugin_registry.dart'; // TODO: Phase 5.0.6.4 - 集成插件注册表
import 'plugin_file_manager.dart';
import 'plugin_manifest_parser.dart';

/// 插件状态
enum PluginState {
  /// 未安装
  notInstalled,

  /// 正在下载
  downloading,

  /// 正在安装
  installing,

  /// 已安装
  installed,

  /// 正在启用
  enabling,

  /// 已启用
  enabled,

  /// 正在禁用
  disabling,

  /// 已禁用
  disabled,

  /// 正在卸载
  uninstalling,

  /// 安装失败
  installFailed,

  /// 需要更新
  updateAvailable,

  /// 正在更新
  updating,
}

/// 插件权限
enum PluginPermission {
  /// 文件系统访问
  fileSystem('文件系统访问'),

  /// 网络访问
  network('网络访问'),

  /// 系统通知
  notifications('系统通知'),

  /// 剪贴板访问
  clipboard('剪贴板访问'),

  /// 相机访问
  camera('相机访问'),

  /// 麦克风访问
  microphone('麦克风访问'),

  /// 位置信息
  location('位置信息'),

  /// 设备信息
  deviceInfo('设备信息');

  const PluginPermission(this.displayName);
  final String displayName;
}

/// 插件依赖
class PluginDependency {
  const PluginDependency({
    required this.pluginId,
    required this.version,
    required this.isRequired,
  });

  final String pluginId;
  final String version;
  final bool isRequired;
}

/// 插件安装信息
class PluginInstallInfo {
  const PluginInstallInfo({
    required this.id,
    required this.name,
    required this.version,
    required this.state,
    required this.installedAt,
    this.lastUsedAt,
    this.permissions = const [],
    this.dependencies = const [],
    this.size = 0,
    this.autoUpdate = true,
  });

  final String id;
  final String name;
  final String version;
  final PluginState state;
  final DateTime installedAt;
  final DateTime? lastUsedAt;
  final List<PluginPermission> permissions;
  final List<PluginDependency> dependencies;
  final int size; // 字节
  final bool autoUpdate;

  PluginInstallInfo copyWith({
    String? id,
    String? name,
    String? version,
    PluginState? state,
    DateTime? installedAt,
    DateTime? lastUsedAt,
    List<PluginPermission>? permissions,
    List<PluginDependency>? dependencies,
    int? size,
    bool? autoUpdate,
  }) {
    return PluginInstallInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      version: version ?? this.version,
      state: state ?? this.state,
      installedAt: installedAt ?? this.installedAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      permissions: permissions ?? this.permissions,
      dependencies: dependencies ?? this.dependencies,
      size: size ?? this.size,
      autoUpdate: autoUpdate ?? this.autoUpdate,
    );
  }
}

/// 插件操作结果
class PluginOperationResult {
  const PluginOperationResult({
    required this.success,
    this.message,
    this.error,
  });

  final bool success;
  final String? message;
  final String? error;

  factory PluginOperationResult.success([String? message]) {
    return PluginOperationResult(success: true, message: message);
  }

  factory PluginOperationResult.failure(String error) {
    return PluginOperationResult(success: false, error: error);
  }
}

/// 插件管理器
class PluginManager extends ChangeNotifier {
  PluginManager._();
  static final PluginManager _instance = PluginManager._();
  static PluginManager get instance => _instance;

  // final PluginRegistry _registry = PluginRegistry.instance; // TODO: Phase 5.0.6.4 - 集成插件注册表
  final Map<String, PluginInstallInfo> _installedPlugins = {};
  final Map<String, StreamController<double>> _progressControllers = {};

  /// 文件管理器
  late final PluginFileManager _fileManager;

  /// 清单解析器
  late final PluginManifestParser _manifestParser;

  /// 是否已初始化
  bool _isInitialized = false;

  /// 获取所有已安装插件
  List<PluginInstallInfo> get installedPlugins =>
      _installedPlugins.values.toList();

  /// 获取已启用插件
  List<PluginInstallInfo> get enabledPlugins => _installedPlugins.values
      .where((p) => p.state == PluginState.enabled)
      .toList();

  /// 获取需要更新的插件
  List<PluginInstallInfo> get updatablePlugins => _installedPlugins.values
      .where((p) => p.state == PluginState.updateAvailable)
      .toList();

  /// 初始化插件管理器
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    // 初始化文件管理器
    _fileManager = PluginFileManager.instance;
    await _fileManager.initialize();

    // 初始化清单解析器
    _manifestParser = PluginManifestParser.instance;

    await _loadInstalledPlugins();
    await _checkForUpdates();

    _isInitialized = true;
    debugPrint('插件管理器已初始化');
  }

  /// 加载已安装插件
  Future<void> _loadInstalledPlugins() async {
    // TODO: Phase 5.0.6.4 - 从本地存储加载已安装插件
    // 当前使用模拟数据
    final now = DateTime.now();
    _installedPlugins.addAll({
      'advanced_brush': PluginInstallInfo(
        id: 'advanced_brush',
        name: '高级画笔工具',
        version: '1.2.0',
        state: PluginState.enabled,
        installedAt: now.subtract(const Duration(days: 30)),
        lastUsedAt: now.subtract(const Duration(hours: 2)),
        permissions: [
          PluginPermission.fileSystem,
          PluginPermission.clipboard,
        ],
        dependencies: [],
        size: 2048000, // 2MB
        autoUpdate: true,
      ),
      'shape_designer': PluginInstallInfo(
        id: 'shape_designer',
        name: '形状设计器',
        version: '2.1.0',
        state: PluginState.disabled,
        installedAt: now.subtract(const Duration(days: 15)),
        lastUsedAt: now.subtract(const Duration(days: 5)),
        permissions: [
          PluginPermission.fileSystem,
        ],
        dependencies: [
          const PluginDependency(
            pluginId: 'math_utils',
            version: '1.0.0',
            isRequired: true,
          ),
        ],
        size: 1536000, // 1.5MB
        autoUpdate: false,
      ),
      'color_palette': PluginInstallInfo(
        id: 'color_palette',
        name: '调色板专家',
        version: '1.5.2',
        state: PluginState.updateAvailable,
        installedAt: now.subtract(const Duration(days: 60)),
        lastUsedAt: now.subtract(const Duration(days: 1)),
        permissions: [
          PluginPermission.clipboard,
          PluginPermission.camera,
        ],
        dependencies: [],
        size: 1024000, // 1MB
        autoUpdate: true,
      ),
    });
  }

  /// 检查插件更新
  Future<void> _checkForUpdates() async {
    // TODO: Phase 5.0.6.4 - 实现真实的更新检查
    // 当前模拟更新检查
    for (final plugin in _installedPlugins.values) {
      if (plugin.autoUpdate && plugin.id == 'color_palette') {
        _installedPlugins[plugin.id] = plugin.copyWith(
          state: PluginState.updateAvailable,
        );
      }
    }
    notifyListeners();
  }

  /// 安装插件
  Future<PluginOperationResult> installPlugin(
    String pluginId, {
    String? version,
    bool autoUpdate = true,
  }) async {
    try {
      // 检查是否已安装
      if (_installedPlugins.containsKey(pluginId)) {
        return PluginOperationResult.failure('插件已安装');
      }

      // 创建进度控制器
      final progressController = StreamController<double>.broadcast();
      _progressControllers[pluginId] = progressController;

      // 执行真实安装过程
      await _performRealInstallation(pluginId, progressController);

      // 计算实际插件大小
      final pluginSize = await _fileManager.getPluginDirectorySize(pluginId);

      // 从清单文件读取插件信息
      final installInfo = await _createInstallInfoFromManifest(
        pluginId,
        pluginSize,
        autoUpdate,
      );

      _installedPlugins[pluginId] = installInfo;
      _progressControllers.remove(pluginId);

      notifyListeners();
      return PluginOperationResult.success('插件安装成功');
    } catch (e) {
      _progressControllers.remove(pluginId);
      return PluginOperationResult.failure('安装失败: $e');
    }
  }

  /// 执行真实的插件安装过程
  Future<void> _performRealInstallation(
    String pluginId,
    StreamController<double> progressController,
  ) async {
    try {
      // 阶段1: 检查插件是否已存在 (0-10%)
      progressController.add(0.0);
      final isInstalled = await _fileManager.isPluginInstalled(pluginId);
      if (isInstalled) {
        throw Exception('插件已安装: $pluginId');
      }
      progressController.add(0.1);

      // 阶段2: 创建插件目录 (10-30%)
      final createResult = await _fileManager.createPluginDirectory(pluginId);
      if (!createResult.success) {
        throw Exception('创建插件目录失败: ${createResult.error}');
      }
      progressController.add(0.3);

      // 阶段3: 创建基本插件文件 (30-70%)
      await _createBasicPluginFiles(pluginId, progressController);

      // 阶段4: 验证插件完整性 (70-90%)
      progressController.add(0.7);
      final isValid = await _fileManager.validatePluginDirectory(pluginId);
      if (!isValid) {
        // 清理失败的安装
        await _fileManager.deletePluginDirectory(pluginId);
        throw Exception('插件验证失败: $pluginId');
      }
      progressController.add(0.9);

      // 阶段5: 完成安装 (90-100%)
      progressController.add(1.0);
      debugPrint('插件安装完成: $pluginId');
    } catch (e) {
      // 安装失败时清理
      try {
        await _fileManager.deletePluginDirectory(pluginId);
      } catch (cleanupError) {
        debugPrint('清理失败的安装时出错: $cleanupError');
      }
      rethrow;
    }
  }

  /// 创建基本插件文件
  Future<void> _createBasicPluginFiles(
    String pluginId,
    StreamController<double> progressController,
  ) async {
    // 使用清单解析器生成默认清单文件
    final manifestContent = _manifestParser.generateDefaultManifest(
      pluginId: pluginId,
      pluginName: _formatPluginName(pluginId),
      description: '自动生成的插件',
      author: 'Creative Workshop',
      category: 'tool',
    );

    await _fileManager.writePluginFile(
      pluginId,
      'plugin.yaml',
      Uint8List.fromList(utf8.encode(manifestContent)),
    );
    progressController.add(0.5);

    // 创建主入口文件
    final mainContent = '''
// 插件主入口文件
// 插件ID: $pluginId
// 生成时间: ${DateTime.now().toIso8601String()}

class ${_toPascalCase(pluginId)}Plugin {
  static const String id = '$pluginId';
  static const String version = '1.0.0';

  void initialize() {
    print('插件 $pluginId 已初始化');
  }

  void dispose() {
    print('插件 $pluginId 已销毁');
  }
}
''';

    await _fileManager.writePluginFile(
      pluginId,
      'lib/main.dart',
      Uint8List.fromList(utf8.encode(mainContent)),
    );
    progressController.add(0.7);
  }

  /// 从清单文件创建安装信息
  Future<PluginInstallInfo> _createInstallInfoFromManifest(
    String pluginId,
    int pluginSize,
    bool autoUpdate,
  ) async {
    try {
      // 尝试解析插件清单
      final parseResult = await _manifestParser.parseFromPlugin(pluginId);

      if (parseResult.success && parseResult.manifest != null) {
        final manifest = parseResult.manifest!;

        // 转换权限格式
        final permissions = manifest.permissions
            .map((p) => _convertPermissionString(p))
            .where((p) => p != null)
            .cast<PluginPermission>()
            .toList();

        // 转换依赖格式
        final dependencies = manifest.dependencies
            .map((d) => PluginDependency(
                  pluginId: d.id,
                  version: d.version,
                  isRequired: d.required,
                ))
            .toList();

        return PluginInstallInfo(
          id: manifest.id,
          name: manifest.name,
          version: manifest.version,
          state: PluginState.installed,
          installedAt: DateTime.now(),
          permissions: permissions,
          dependencies: dependencies,
          size: pluginSize,
          autoUpdate: autoUpdate,
        );
      }
    } catch (e) {
      debugPrint('解析插件清单失败: $e');
    }

    // 如果解析失败，使用默认信息
    debugPrint('使用默认插件信息: $pluginId');
    return PluginInstallInfo(
      id: pluginId,
      name: _formatPluginName(pluginId),
      version: '1.0.0',
      state: PluginState.installed,
      installedAt: DateTime.now(),
      permissions: [],
      dependencies: [],
      size: pluginSize,
      autoUpdate: autoUpdate,
    );
  }

  /// 转换权限字符串为枚举
  PluginPermission? _convertPermissionString(String permission) {
    switch (permission) {
      case 'fileSystem':
        return PluginPermission.fileSystem;
      case 'network':
        return PluginPermission.network;
      case 'notifications':
        return PluginPermission.notifications;
      case 'clipboard':
        return PluginPermission.clipboard;
      case 'camera':
        return PluginPermission.camera;
      case 'microphone':
        return PluginPermission.microphone;
      case 'location':
        return PluginPermission.location;
      case 'deviceInfo':
        return PluginPermission.deviceInfo;
      default:
        return null;
    }
  }

  /// 格式化插件名称
  String _formatPluginName(String pluginId) {
    return pluginId
        .split('_')
        .map((word) =>
            word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  /// 将字符串转换为 PascalCase
  String _toPascalCase(String input) {
    return input
        .split('_')
        .map((word) =>
            word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join('');
  }

  /// 卸载插件
  Future<PluginOperationResult> uninstallPlugin(String pluginId) async {
    try {
      final plugin = _installedPlugins[pluginId];
      if (plugin == null) {
        return PluginOperationResult.failure('插件未安装');
      }

      // 如果插件已启用，先禁用
      if (plugin.state == PluginState.enabled) {
        await disablePlugin(pluginId);
      }

      // 检查依赖
      final dependents = _findDependentPlugins(pluginId);
      if (dependents.isNotEmpty) {
        return PluginOperationResult.failure(
          '无法卸载，以下插件依赖此插件: ${dependents.map((p) => p.name).join(', ')}',
        );
      }

      // 执行真实卸载过程
      _installedPlugins[pluginId] =
          plugin.copyWith(state: PluginState.uninstalling);
      notifyListeners();

      // 删除插件文件和目录
      final deleteResult = await _fileManager.deletePluginDirectory(pluginId);
      if (!deleteResult.success) {
        // 恢复状态
        _installedPlugins[pluginId] = plugin;
        notifyListeners();
        return PluginOperationResult.failure('删除插件文件失败: ${deleteResult.error}');
      }

      // 从已安装列表中移除
      _installedPlugins.remove(pluginId);
      notifyListeners();

      debugPrint('插件卸载完成: $pluginId');
      return PluginOperationResult.success('插件卸载成功');
    } catch (e) {
      return PluginOperationResult.failure('卸载失败: $e');
    }
  }

  /// 启用插件
  Future<PluginOperationResult> enablePlugin(String pluginId) async {
    try {
      final plugin = _installedPlugins[pluginId];
      if (plugin == null) {
        return PluginOperationResult.failure('插件未安装');
      }

      if (plugin.state == PluginState.enabled) {
        return PluginOperationResult.failure('插件已启用');
      }

      // 检查依赖
      final missingDeps = await _checkDependencies(plugin);
      if (missingDeps.isNotEmpty) {
        return PluginOperationResult.failure(
          '缺少依赖: ${missingDeps.map((d) => d.pluginId).join(', ')}',
        );
      }

      _installedPlugins[pluginId] =
          plugin.copyWith(state: PluginState.enabling);
      notifyListeners();

      // 模拟启用过程
      await Future<void>.delayed(const Duration(milliseconds: 500));

      _installedPlugins[pluginId] = plugin.copyWith(
        state: PluginState.enabled,
        lastUsedAt: DateTime.now(),
      );
      notifyListeners();

      return PluginOperationResult.success('插件启用成功');
    } catch (e) {
      return PluginOperationResult.failure('启用失败: $e');
    }
  }

  /// 禁用插件
  Future<PluginOperationResult> disablePlugin(String pluginId) async {
    try {
      final plugin = _installedPlugins[pluginId];
      if (plugin == null) {
        return PluginOperationResult.failure('插件未安装');
      }

      if (plugin.state != PluginState.enabled) {
        return PluginOperationResult.failure('插件未启用');
      }

      _installedPlugins[pluginId] =
          plugin.copyWith(state: PluginState.disabling);
      notifyListeners();

      // 模拟禁用过程
      await Future<void>.delayed(const Duration(milliseconds: 300));

      // 禁用后回到已安装状态
      _installedPlugins[pluginId] =
          plugin.copyWith(state: PluginState.installed);
      notifyListeners();

      return PluginOperationResult.success('插件禁用成功');
    } catch (e) {
      return PluginOperationResult.failure('禁用失败: $e');
    }
  }

  /// 更新插件
  Future<PluginOperationResult> updatePlugin(String pluginId) async {
    try {
      final plugin = _installedPlugins[pluginId];
      if (plugin == null) {
        return PluginOperationResult.failure('插件未安装');
      }

      if (plugin.state != PluginState.updateAvailable) {
        return PluginOperationResult.failure('插件无需更新');
      }

      _installedPlugins[pluginId] =
          plugin.copyWith(state: PluginState.updating);
      notifyListeners();

      // 模拟更新过程
      await Future<void>.delayed(const Duration(seconds: 2));

      _installedPlugins[pluginId] = plugin.copyWith(
        state: PluginState.enabled,
        version: '1.6.0', // 模拟新版本
      );
      notifyListeners();

      return PluginOperationResult.success('插件更新成功');
    } catch (e) {
      return PluginOperationResult.failure('更新失败: $e');
    }
  }

  /// 获取安装进度流
  Stream<double>? getInstallProgress(String pluginId) {
    return _progressControllers[pluginId]?.stream;
  }

  /// 检查插件依赖
  Future<List<PluginDependency>> _checkDependencies(
      PluginInstallInfo plugin) async {
    final missingDeps = <PluginDependency>[];

    for (final dep in plugin.dependencies) {
      final depPlugin = _installedPlugins[dep.pluginId];
      if (depPlugin == null || depPlugin.state != PluginState.enabled) {
        if (dep.isRequired) {
          missingDeps.add(dep);
        }
      }
    }

    return missingDeps;
  }

  /// 查找依赖此插件的其他插件
  List<PluginInstallInfo> _findDependentPlugins(String pluginId) {
    return _installedPlugins.values
        .where((plugin) =>
            plugin.dependencies.any((dep) => dep.pluginId == pluginId))
        .toList();
  }

  /// 获取插件信息
  PluginInstallInfo? getPluginInfo(String pluginId) {
    return _installedPlugins[pluginId];
  }

  /// 检查插件是否已安装
  bool isPluginInstalled(String pluginId) {
    return _installedPlugins.containsKey(pluginId);
  }

  /// 检查插件是否已启用
  bool isPluginEnabled(String pluginId) {
    final plugin = _installedPlugins[pluginId];
    return plugin?.state == PluginState.enabled;
  }

  /// 获取插件使用统计
  Map<String, dynamic> getPluginStats() {
    final totalInstalled = _installedPlugins.length;
    final totalEnabled = enabledPlugins.length;
    final totalSize =
        _installedPlugins.values.fold<int>(0, (sum, p) => sum + p.size);
    final needsUpdate = updatablePlugins.length;

    return {
      'totalInstalled': totalInstalled,
      'totalEnabled': totalEnabled,
      'totalSize': totalSize,
      'needsUpdate': needsUpdate,
    };
  }

  @override
  void dispose() {
    for (final controller in _progressControllers.values) {
      controller.close();
    }
    _progressControllers.clear();
    super.dispose();
  }
}
