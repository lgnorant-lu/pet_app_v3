/*
---------------------------------------------------------------
File name:          project_templates.dart
Author:             lgnorant-lu
Date created:       2025-07-18
Last modified:      2025-07-18
Dart Version:       3.2+
Description:        创意项目模板系统
---------------------------------------------------------------
Change History:
    2025-07-18: Initial creation - 项目模板系统实现;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:creative_workshop/src/core/projects/project_manager.dart';

/// 项目模板
class ProjectTemplate {
  const ProjectTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.icon,
    this.tags = const <String>[],
    this.defaultMetadata = const <String, dynamic>{},
    this.defaultData = const <String, dynamic>{},
    this.previewImage,
  });

  /// 模板ID
  final String id;

  /// 模板名称
  final String name;

  /// 模板描述
  final String description;

  /// 项目类型
  final ProjectType type;

  /// 模板图标
  final IconData icon;

  /// 标签列表
  final List<String> tags;

  /// 默认元数据
  final Map<String, dynamic> defaultMetadata;

  /// 默认数据
  final Map<String, dynamic> defaultData;

  /// 预览图片路径
  final String? previewImage;

  /// 创建项目实例
  CreativeProject createProject({
    required String name,
    String? description,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    Map<String, dynamic>? data,
  }) => CreativeProject(
      name: name,
      type: type,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      metadata: <String, dynamic>{
        ...defaultMetadata,
        ...?metadata,
      },
      data: <String, dynamic>{
        ...defaultData,
        ...?data,
      },
    );
}

/// 项目模板管理器
class ProjectTemplateManager {
  ProjectTemplateManager._();

  static final ProjectTemplateManager _instance = ProjectTemplateManager._();
  static ProjectTemplateManager get instance => _instance;

  /// 内置模板列表
  final List<ProjectTemplate> _templates = <ProjectTemplate>[];

  /// 初始化模板管理器
  void initialize() {
    _registerBuiltinTemplates();
    debugPrint('项目模板管理器已初始化，共 ${_templates.length} 个模板');
  }

  /// 注册内置模板
  void _registerBuiltinTemplates() {
    _templates.addAll(<ProjectTemplate>[
      // 绘画项目模板
      const ProjectTemplate(
        id: 'blank_drawing',
        name: '空白画布',
        description: '创建一个空白的绘画项目',
        type: ProjectType.drawing,
        icon: Icons.brush,
        tags: <String>['绘画', '空白'],
        defaultMetadata: <String, dynamic>{
          'canvasWidth': 800,
          'canvasHeight': 600,
          'backgroundColor': 0xFFFFFFFF,
        },
        defaultData: <String, dynamic>{
          'layers': <Map<String, dynamic>>[],
          'tools': <String>['brush', 'pencil', 'eraser'],
        },
      ),

      const ProjectTemplate(
        id: 'sketch_drawing',
        name: '素描画板',
        description: '适合素描和线稿的项目模板',
        type: ProjectType.drawing,
        icon: Icons.edit,
        tags: <String>['绘画', '素描', '线稿'],
        defaultMetadata: <String, dynamic>{
          'canvasWidth': 1024,
          'canvasHeight': 768,
          'backgroundColor': 0xFFF5F5F5,
        },
        defaultData: <String, dynamic>{
          'layers': <Map<String, Object>>[
            <String, Object>{'name': '草稿层', 'opacity': 0.5},
            <String, Object>{'name': '线稿层', 'opacity': 1.0},
          ],
          'tools': <String>['pencil', 'eraser'],
        },
      ),

      // 设计项目模板
      const ProjectTemplate(
        id: 'ui_design',
        name: 'UI设计',
        description: '用户界面设计项目模板',
        type: ProjectType.design,
        icon: Icons.design_services,
        tags: <String>['设计', 'UI', '界面'],
        defaultMetadata: <String, dynamic>{
          'canvasWidth': 1920,
          'canvasHeight': 1080,
          'gridSize': 8,
          'showGrid': true,
        },
        defaultData: <String, dynamic>{
          'artboards': <Map<String, Object>>[
            <String, Object>{'name': '桌面版', 'width': 1920, 'height': 1080},
            <String, Object>{'name': '移动版', 'width': 375, 'height': 812},
          ],
          'components': <dynamic>[],
        },
      ),

      const ProjectTemplate(
        id: 'logo_design',
        name: 'Logo设计',
        description: '标志和品牌设计项目模板',
        type: ProjectType.design,
        icon: Icons.account_balance,
        tags: <String>['设计', 'Logo', '品牌'],
        defaultMetadata: <String, dynamic>{
          'canvasWidth': 500,
          'canvasHeight': 500,
          'backgroundColor': 0xFFFFFFFF,
        },
        defaultData: <String, dynamic>{
          'versions': <dynamic>[],
          'colorPalette': <dynamic>[],
          'guidelines': <dynamic, dynamic>{},
        },
      ),

      // 游戏项目模板
      const ProjectTemplate(
        id: 'simple_game',
        name: '简单游戏',
        description: '基础游戏项目模板',
        type: ProjectType.game,
        icon: Icons.games,
        tags: <String>['游戏', '简单'],
        defaultMetadata: <String, dynamic>{
          'gameType': 'puzzle',
          'targetPlatform': 'mobile',
        },
        defaultData: <String, dynamic>{
          'scenes': <Map<String, String>>[
            <String, String>{'name': '主菜单', 'type': 'menu'},
            <String, String>{'name': '游戏场景', 'type': 'gameplay'},
          ],
          'assets': <dynamic>[],
        },
      ),

      const ProjectTemplate(
        id: 'puzzle_game',
        name: '益智游戏',
        description: '益智类游戏项目模板',
        type: ProjectType.game,
        icon: Icons.extension,
        tags: <String>['游戏', '益智', '解谜'],
        defaultMetadata: <String, dynamic>{
          'gameType': 'puzzle',
          'difficulty': 'medium',
          'levels': 10,
        },
        defaultData: <String, dynamic>{
          'levels': <dynamic>[],
          'mechanics': <String>['match', 'move', 'rotate'],
        },
      ),

      // 动画项目模板
      const ProjectTemplate(
        id: 'simple_animation',
        name: '简单动画',
        description: '基础动画项目模板',
        type: ProjectType.animation,
        icon: Icons.movie,
        tags: <String>['动画', '简单'],
        defaultMetadata: <String, dynamic>{
          'frameRate': 24,
          'duration': 5.0,
          'resolution': '1920x1080',
        },
        defaultData: <String, dynamic>{
          'timeline': <dynamic>[],
          'keyframes': <dynamic>[],
        },
      ),

      // 3D项目模板
      const ProjectTemplate(
        id: 'simple_3d',
        name: '简单3D模型',
        description: '基础3D建模项目模板',
        type: ProjectType.model3d,
        icon: Icons.view_in_ar,
        tags: <String>['3D', '建模'],
        defaultMetadata: <String, dynamic>{
          'renderer': 'basic',
          'lighting': 'default',
        },
        defaultData: <String, dynamic>{
          'objects': <dynamic>[],
          'materials': <dynamic>[],
          'cameras': <Map<String, Object>>[
            <String, Object>{
              'name': '主相机',
              'position': <int>[0, 0, 5],
            },
          ],
        },
      ),

      // 混合项目模板
      const ProjectTemplate(
        id: 'creative_mix',
        name: '创意混合',
        description: '包含多种创意元素的混合项目',
        type: ProjectType.mixed,
        icon: Icons.auto_awesome,
        tags: <String>['混合', '创意', '多元素'],
        defaultMetadata: <String, dynamic>{
          'components': <String>['drawing', 'design', 'animation'],
        },
        defaultData: <String, dynamic>{
          'sections': <Map<String, String>>[
            <String, String>{'type': 'drawing', 'name': '绘画部分'},
            <String, String>{'type': 'design', 'name': '设计部分'},
          ],
        },
      ),
    ]);
  }

  /// 获取所有模板
  List<ProjectTemplate> get templates => List.unmodifiable(_templates);

  /// 按类型获取模板
  List<ProjectTemplate> getTemplatesByType(ProjectType type) => _templates.where((ProjectTemplate template) => template.type == type).toList();

  /// 按标签获取模板
  List<ProjectTemplate> getTemplatesByTag(String tag) => _templates
        .where((ProjectTemplate template) => template.tags
            .any((String t) => t.toLowerCase().contains(tag.toLowerCase())),)
        .toList();

  /// 搜索模板
  List<ProjectTemplate> searchTemplates(String query) {
    final lowerQuery = query.toLowerCase();
    return _templates.where((ProjectTemplate template) => template.name.toLowerCase().contains(lowerQuery) ||
          template.description.toLowerCase().contains(lowerQuery) ||
          template.tags.any((String tag) => tag.toLowerCase().contains(lowerQuery)),).toList();
  }

  /// 获取模板
  ProjectTemplate? getTemplate(String templateId) {
    try {
      return _templates.firstWhere((ProjectTemplate template) => template.id == templateId);
    } catch (e) {
      return null;
    }
  }

  /// 注册自定义模板
  bool registerTemplate(ProjectTemplate template) {
    // 检查ID是否已存在
    if (_templates.any((ProjectTemplate t) => t.id == template.id)) {
      debugPrint('模板ID已存在: ${template.id}');
      return false;
    }

    _templates.add(template);
    debugPrint('自定义模板已注册: ${template.name}');
    return true;
  }

  /// 注销模板
  bool unregisterTemplate(String templateId) {
    final index = _templates.indexWhere((ProjectTemplate t) => t.id == templateId);
    if (index == -1) {
      debugPrint('模板不存在: $templateId');
      return false;
    }

    final template = _templates.removeAt(index);
    debugPrint('模板已注销: ${template.name}');
    return true;
  }

  /// 获取模板统计信息
  Map<String, dynamic> getTemplateStats() {
    final stats = <String, dynamic>{};

    // 按类型统计
    for (final type in ProjectType.values) {
      stats['type_${type.name}'] = getTemplatesByType(type).length;
    }

    // 总数统计
    stats['total'] = _templates.length;

    // 标签统计
    final allTags = <String>{};
    for (final template in _templates) {
      allTags.addAll(template.tags);
    }
    stats['uniqueTags'] = allTags.length;

    return stats;
  }
}
