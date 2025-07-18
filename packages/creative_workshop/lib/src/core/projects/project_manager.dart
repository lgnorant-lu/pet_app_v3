/*
---------------------------------------------------------------
File name:          project_manager.dart
Author:             lgnorant-lu
Date created:       2025-07-18
Last modified:      2025-07-18
Dart Version:       3.2+
Description:        创意项目管理器
---------------------------------------------------------------
Change History:
    2025-07-18: Initial creation - 创意项目管理器;
---------------------------------------------------------------
*/

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:creative_workshop/src/core/projects/project_storage.dart';
import 'package:creative_workshop/src/core/projects/project_templates.dart';

/// 项目类型枚举
enum ProjectType {
  /// 绘画项目
  drawing,

  /// 设计项目
  design,

  /// 游戏项目
  game,

  /// 动画项目
  animation,

  /// 3D项目
  model3d,

  /// 混合项目
  mixed,

  /// 自定义项目
  custom,
}

/// 项目状态
enum ProjectStatus {
  /// 草稿
  draft,

  /// 进行中
  inProgress,

  /// 已完成
  completed,

  /// 已发布
  published,

  /// 已归档
  archived,
}

/// 创意项目模型
class CreativeProject {
  CreativeProject({
    required this.name, required this.type, String? id,
    this.description = '',
    this.status = ProjectStatus.draft,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.tags = const <String>[],
    this.metadata = const <String, dynamic>{},
    this.data = const <String, dynamic>{},
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// 从JSON创建项目
  factory CreativeProject.fromJson(Map<String, dynamic> json) => CreativeProject(
      id: json['id'] as String,
      name: json['name'] as String,
      type: ProjectType.values.firstWhere(
        (ProjectType e) => e.name == json['type'],
        orElse: () => ProjectType.custom,
      ),
      description: json['description'] as String? ?? '',
      status: ProjectStatus.values.firstWhere(
        (ProjectStatus e) => e.name == json['status'],
        orElse: () => ProjectStatus.draft,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      tags: List<String>.from(json['tags'] as List? ?? <dynamic>[]),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? <dynamic, dynamic>{}),
      data: Map<String, dynamic>.from(json['data'] as Map? ?? <dynamic, dynamic>{}),
    );

  /// 项目ID
  final String id;

  /// 项目名称
  final String name;

  /// 项目类型
  final ProjectType type;

  /// 项目描述
  final String description;

  /// 项目状态
  final ProjectStatus status;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;

  /// 标签列表
  final List<String> tags;

  /// 元数据
  final Map<String, dynamic> metadata;

  /// 项目数据
  final Map<String, dynamic> data;

  /// 复制项目并更新字段
  CreativeProject copyWith({
    String? name,
    ProjectType? type,
    String? description,
    ProjectStatus? status,
    DateTime? updatedAt,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    Map<String, dynamic>? data,
  }) => CreativeProject(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      data: data ?? this.data,
    );

  /// 转换为JSON
  Map<String, dynamic> toJson() => <String, dynamic>{
      'id': id,
      'name': name,
      'type': type.name,
      'description': description,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'tags': tags,
      'metadata': metadata,
      'data': data,
    };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CreativeProject && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'CreativeProject(id: $id, name: $name, type: $type, status: $status)';
}

/// 项目操作结果
class ProjectResult<T> {
  const ProjectResult({
    required this.success,
    this.data,
    this.error,
  });

  /// 成功结果
  factory ProjectResult.success(T data) => ProjectResult(success: true, data: data);

  /// 失败结果
  factory ProjectResult.failure(String error) => ProjectResult(success: false, error: error);

  /// 操作是否成功
  final bool success;

  /// 结果数据
  final T? data;

  /// 错误信息
  final String? error;
}

/// 创意项目管理器
class ProjectManager extends ChangeNotifier {
  ProjectManager._();

  /// 单例实例
  static final ProjectManager _instance = ProjectManager._();
  static ProjectManager get instance => _instance;

  /// 项目列表
  final List<CreativeProject> _projects = <CreativeProject>[];

  /// 当前项目
  CreativeProject? _currentProject;

  /// 项目变更流控制器
  final StreamController<CreativeProject> _projectChangesController =
      StreamController<CreativeProject>.broadcast();

  /// 存储管理器
  ProjectStorageManager get _storageManager => ProjectStorageManager.instance;

  /// 模板管理器
  ProjectTemplateManager get _templateManager =>
      ProjectTemplateManager.instance;

  /// 获取所有项目
  List<CreativeProject> get projects => List.unmodifiable(_projects);

  /// 获取当前项目
  CreativeProject? get currentProject => _currentProject;

  /// 项目变更流
  Stream<CreativeProject> get projectChanges =>
      _projectChangesController.stream;

  /// 初始化项目管理器
  Future<void> initialize() async {
    try {
      // 初始化存储管理器
      _storageManager.initialize();

      // 初始化模板管理器
      _templateManager.initialize();

      // 加载已保存的项目
      await _loadSavedProjects();

      debugPrint('项目管理器初始化完成，共加载 ${_projects.length} 个项目');
    } catch (e) {
      debugPrint('项目管理器初始化失败: $e');
      rethrow;
    }
  }

  /// 加载已保存的项目
  Future<void> _loadSavedProjects() async {
    try {
      final projectIds = await _storageManager.storage.getAllProjectIds();
      final loadedProjects = await _storageManager.loadProjects(projectIds);

      _projects.clear();
      _projects.addAll(loadedProjects);

      debugPrint('已加载 ${loadedProjects.length} 个保存的项目');
    } catch (e) {
      debugPrint('加载保存的项目失败: $e');
    }
  }

  /// 创建新项目
  Future<ProjectResult<CreativeProject>> createProject({
    required String name,
    required ProjectType type,
    String description = '',
    List<String> tags = const <String>[],
    Map<String, dynamic> metadata = const <String, dynamic>{},
    Map<String, dynamic> data = const <String, dynamic>{},
  }) async {
    try {
      final project = CreativeProject(
        name: name,
        type: type,
        description: description,
        tags: tags,
        metadata: metadata,
        data: data,
      );

      _projects.add(project);
      _currentProject = project;

      // 保存到存储
      await _storageManager.storage.saveProject(project);

      notifyListeners();
      _projectChangesController.add(project);

      return ProjectResult.success(project);
    } catch (e) {
      return ProjectResult.failure('创建项目失败: $e');
    }
  }

  /// 从模板创建项目
  Future<ProjectResult<CreativeProject>> createProjectFromTemplate({
    required String templateId,
    required String name,
    String? description,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    Map<String, dynamic>? data,
  }) async {
    try {
      final template = _templateManager.getTemplate(templateId);
      if (template == null) {
        return ProjectResult.failure('模板不存在: $templateId');
      }

      final project = template.createProject(
        name: name,
        description: description,
        tags: tags,
        metadata: metadata,
        data: data,
      );

      _projects.add(project);
      _currentProject = project;

      // 保存到存储
      await _storageManager.storage.saveProject(project);

      notifyListeners();
      _projectChangesController.add(project);

      debugPrint('从模板创建项目: ${template.name} -> $name');
      return ProjectResult.success(project);
    } catch (e) {
      return ProjectResult.failure('从模板创建项目失败: $e');
    }
  }

  /// 打开项目
  Future<ProjectResult<CreativeProject>> openProject(String projectId) async {
    try {
      final project = _projects.firstWhere(
        (CreativeProject p) => p.id == projectId,
        orElse: () => throw Exception('项目不存在'),
      );

      _currentProject = project;
      notifyListeners();

      return ProjectResult.success(project);
    } catch (e) {
      return ProjectResult.failure('打开项目失败: $e');
    }
  }

  /// 保存项目
  Future<ProjectResult<CreativeProject>> saveProject(
    CreativeProject project,
  ) async {
    try {
      final index = _projects.indexWhere((CreativeProject p) => p.id == project.id);
      if (index == -1) {
        return ProjectResult.failure('项目不存在');
      }

      final updatedProject = project.copyWith(updatedAt: DateTime.now());
      _projects[index] = updatedProject;

      if (_currentProject?.id == project.id) {
        _currentProject = updatedProject;
      }

      // 保存到存储
      final saveSuccess =
          await _storageManager.storage.saveProject(updatedProject);
      if (!saveSuccess) {
        return ProjectResult.failure('保存到存储失败');
      }

      notifyListeners();
      _projectChangesController.add(updatedProject);

      return ProjectResult.success(updatedProject);
    } catch (e) {
      return ProjectResult.failure('保存项目失败: $e');
    }
  }

  /// 删除项目
  Future<ProjectResult<bool>> deleteProject(String projectId) async {
    try {
      final index = _projects.indexWhere((CreativeProject p) => p.id == projectId);
      if (index == -1) {
        return ProjectResult.failure('项目不存在');
      }

      // 从存储中删除
      final deleteSuccess =
          await _storageManager.storage.deleteProject(projectId);
      if (!deleteSuccess) {
        return ProjectResult.failure('从存储删除失败');
      }

      _projects.removeAt(index);

      if (_currentProject?.id == projectId) {
        _currentProject = null;
      }

      notifyListeners();

      return ProjectResult.success(true);
    } catch (e) {
      return ProjectResult.failure('删除项目失败: $e');
    }
  }

  /// 复制项目
  Future<ProjectResult<CreativeProject>> duplicateProject(
    String projectId,
  ) async {
    try {
      final originalProject = _projects.firstWhere(
        (CreativeProject p) => p.id == projectId,
        orElse: () => throw Exception('项目不存在'),
      );

      final duplicatedProject = CreativeProject(
        name: '${originalProject.name} (副本)',
        type: originalProject.type,
        description: originalProject.description,
        tags: List.from(originalProject.tags),
        metadata: Map.from(originalProject.metadata),
        data: Map.from(originalProject.data),
      );

      _projects.add(duplicatedProject);
      notifyListeners();

      return ProjectResult.success(duplicatedProject);
    } catch (e) {
      return ProjectResult.failure('复制项目失败: $e');
    }
  }

  /// 按类型筛选项目
  List<CreativeProject> getProjectsByType(ProjectType type) => _projects.where((CreativeProject p) => p.type == type).toList();

  /// 按状态筛选项目
  List<CreativeProject> getProjectsByStatus(ProjectStatus status) => _projects.where((CreativeProject p) => p.status == status).toList();

  /// 搜索项目
  List<CreativeProject> searchProjects(String query) {
    final lowerQuery = query.toLowerCase();
    return _projects.where((CreativeProject p) => p.name.toLowerCase().contains(lowerQuery) ||
          p.description.toLowerCase().contains(lowerQuery) ||
          p.tags.any((String tag) => tag.toLowerCase().contains(lowerQuery)),).toList();
  }

  /// 获取项目统计
  Map<String, int> getProjectStats() {
    final stats = <String, int>{};

    // 按类型统计
    for (final type in ProjectType.values) {
      stats['type_${type.name}'] = getProjectsByType(type).length;
    }

    // 按状态统计
    for (final status in ProjectStatus.values) {
      stats['status_${status.name}'] = getProjectsByStatus(status).length;
    }

    stats['total'] = _projects.length;

    return stats;
  }

  /// 获取所有可用模板
  List<ProjectTemplate> getAvailableTemplates() => _templateManager.templates;

  /// 按类型获取模板
  List<ProjectTemplate> getTemplatesByType(ProjectType type) => _templateManager.getTemplatesByType(type);

  /// 搜索模板
  List<ProjectTemplate> searchTemplates(String query) => _templateManager.searchTemplates(query);

  /// 获取存储统计信息
  Future<Map<String, dynamic>> getStorageStats() async => _storageManager.getStorageStats();

  /// 导出项目
  Future<ProjectResult<Map<String, dynamic>>> exportProject(
      String projectId,) async {
    try {
      final project = _projects.firstWhere(
        (CreativeProject p) => p.id == projectId,
        orElse: () => throw Exception('项目不存在'),
      );

      final exportData = <String, Object>{
        'project': project.toJson(),
        'exportTime': DateTime.now().toIso8601String(),
        'version': '1.0.0',
      };

      return ProjectResult.success(exportData);
    } catch (e) {
      return ProjectResult.failure('导出项目失败: $e');
    }
  }

  /// 导入项目
  Future<ProjectResult<CreativeProject>> importProject(
      Map<String, dynamic> importData,) async {
    try {
      final projectData = importData['project'] as Map<String, dynamic>;
      final project = CreativeProject.fromJson(projectData);

      // 生成新的ID避免冲突
      final importedProject = CreativeProject(
        name: '${project.name} (导入)',
        type: project.type,
        description: project.description,
        tags: project.tags,
        metadata: project.metadata,
        data: project.data,
      );

      _projects.add(importedProject);

      // 保存到存储
      await _storageManager.storage.saveProject(importedProject);

      notifyListeners();

      return ProjectResult.success(importedProject);
    } catch (e) {
      return ProjectResult.failure('导入项目失败: $e');
    }
  }

  /// 清理资源
  @override
  void dispose() {
    _projectChangesController.close();
    super.dispose();
  }
}
