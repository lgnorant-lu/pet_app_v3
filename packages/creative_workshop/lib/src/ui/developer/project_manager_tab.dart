/*
---------------------------------------------------------------
File name:          project_manager_tab.dart
Author:             lgnorant-lu
Date created:       2025-07-22
Last modified:      2025-07-22
Dart Version:       3.2+
Description:        项目管理标签页
---------------------------------------------------------------
Change History:
    2025-07-22: Phase 5.0.6.3 - 项目管理功能实现;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';

/// 开发者项目信息
class DeveloperProject {
  const DeveloperProject({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.lastModified,
    this.version = '1.0.0',
    this.tags = const [],
  });

  final String id;
  final String name;
  final String description;
  final ProjectType type;
  final ProjectStatus status;
  final DateTime createdAt;
  final DateTime lastModified;
  final String version;
  final List<String> tags;
}

/// 项目类型
enum ProjectType {
  tool('工具插件'),
  game('游戏插件'),
  utility('实用程序'),
  theme('主题插件'),
  other('其他');

  const ProjectType(this.displayName);
  final String displayName;
}

/// 项目状态
enum ProjectStatus {
  development('开发中'),
  testing('测试中'),
  ready('准备发布'),
  published('已发布'),
  archived('已归档');

  const ProjectStatus(this.displayName);
  final String displayName;
}

/// 项目管理标签页
class ProjectManagerTab extends StatefulWidget {
  const ProjectManagerTab({super.key});

  @override
  State<ProjectManagerTab> createState() => _ProjectManagerTabState();
}

class _ProjectManagerTabState extends State<ProjectManagerTab> {
  List<DeveloperProject> _projects = [];
  bool _isLoading = true;
  String _searchQuery = '';
  ProjectType? _selectedType;
  ProjectStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  /// 加载项目列表
  Future<void> _loadProjects() async {
    setState(() {
      _isLoading = true;
    });

    // TODO: Phase 5.0.6.3 - 从真实数据源加载项目
    // 当前使用模拟数据
    await Future<void>.delayed(const Duration(milliseconds: 500));

    final now = DateTime.now();
    _projects = [
      DeveloperProject(
        id: 'proj_001',
        name: '高级画笔工具',
        description: '提供多种画笔效果和纹理的专业绘画工具',
        type: ProjectType.tool,
        status: ProjectStatus.published,
        createdAt: now.subtract(const Duration(days: 30)),
        lastModified: now.subtract(const Duration(days: 2)),
        version: '1.2.0',
        tags: ['绘画', '画笔', '艺术'],
      ),
      DeveloperProject(
        id: 'proj_002',
        name: '拼图游戏引擎',
        description: '可配置的拼图游戏框架，支持自定义图片和难度',
        type: ProjectType.game,
        status: ProjectStatus.testing,
        createdAt: now.subtract(const Duration(days: 15)),
        lastModified: now.subtract(const Duration(hours: 6)),
        version: '0.9.0',
        tags: ['游戏', '拼图', '引擎'],
      ),
      DeveloperProject(
        id: 'proj_003',
        name: '颜色管理器',
        description: '专业的颜色选择和管理工具',
        type: ProjectType.utility,
        status: ProjectStatus.development,
        createdAt: now.subtract(const Duration(days: 7)),
        lastModified: now.subtract(const Duration(hours: 2)),
        version: '0.5.0',
        tags: ['颜色', '工具', '设计'],
      ),
      DeveloperProject(
        id: 'proj_004',
        name: '暗色主题包',
        description: '现代化的暗色主题集合',
        type: ProjectType.theme,
        status: ProjectStatus.ready,
        createdAt: now.subtract(const Duration(days: 20)),
        lastModified: now.subtract(const Duration(days: 1)),
        version: '1.0.0',
        tags: ['主题', '暗色', 'UI'],
      ),
      DeveloperProject(
        id: 'proj_005',
        name: '数据导出工具',
        description: '支持多种格式的数据导出功能',
        type: ProjectType.utility,
        status: ProjectStatus.archived,
        createdAt: now.subtract(const Duration(days: 60)),
        lastModified: now.subtract(const Duration(days: 30)),
        version: '1.1.0',
        tags: ['导出', '数据', '工具'],
      ),
    ];

    setState(() {
      _isLoading = false;
    });
  }

  /// 过滤项目
  List<DeveloperProject> get _filteredProjects {
    return _projects.where((project) {
      // 搜索过滤
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!project.name.toLowerCase().contains(query) &&
            !project.description.toLowerCase().contains(query) &&
            !project.tags.any((tag) => tag.toLowerCase().contains(query))) {
          return false;
        }
      }

      // 类型过滤
      if (_selectedType != null && project.type != _selectedType) {
        return false;
      }

      // 状态过滤
      if (_selectedStatus != null && project.status != _selectedStatus) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 搜索和过滤栏
        _buildSearchAndFilterBar(),

        // 项目列表
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildProjectList(),
        ),
      ],
    );
  }

  /// 构建搜索和过滤栏
  Widget _buildSearchAndFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 搜索框
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: '搜索项目...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
          ),

          const SizedBox(height: 12),

          // 过滤器
          Row(
            children: [
              // 类型过滤
              Expanded(
                child: DropdownButtonFormField<ProjectType?>(
                  value: _selectedType,
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: '项目类型',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: [
                    const DropdownMenuItem<ProjectType?>(
                      value: null,
                      child: Text('全部类型'),
                    ),
                    ...ProjectType.values.map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.displayName),
                        )),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // 状态过滤
              Expanded(
                child: DropdownButtonFormField<ProjectStatus?>(
                  value: _selectedStatus,
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: '项目状态',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: [
                    const DropdownMenuItem<ProjectStatus?>(
                      value: null,
                      child: Text('全部状态'),
                    ),
                    ...ProjectStatus.values.map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.displayName),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建项目列表
  Widget _buildProjectList() {
    final filteredProjects = _filteredProjects;

    if (filteredProjects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _projects.isEmpty ? '暂无项目' : '没有找到匹配的项目',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            if (_projects.isEmpty) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _createNewProject,
                icon: const Icon(Icons.add),
                label: const Text('创建第一个项目'),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredProjects.length,
      itemBuilder: (context, index) {
        return _buildProjectCard(filteredProjects[index]);
      },
    );
  }

  /// 构建项目卡片
  Widget _buildProjectCard(DeveloperProject project) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _openProject(project),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 项目标题和状态
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusChip(project.status),
                ],
              ),

              const SizedBox(height: 8),

              // 项目描述
              Text(
                project.description,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // 项目信息
              Row(
                children: [
                  Icon(
                    _getTypeIcon(project.type),
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    project.type.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(project.lastModified),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'v${project.version}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),

              // 标签
              if (project.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: project.tags.map((tag) => Chip(
                        label: Text(
                          tag,
                          style: const TextStyle(fontSize: 10),
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      )).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 构建状态标签
  Widget _buildStatusChip(ProjectStatus status) {
    Color color;
    switch (status) {
      case ProjectStatus.development:
        color = Colors.blue;
        break;
      case ProjectStatus.testing:
        color = Colors.orange;
        break;
      case ProjectStatus.ready:
        color = Colors.green;
        break;
      case ProjectStatus.published:
        color = Colors.purple;
        break;
      case ProjectStatus.archived:
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  /// 获取类型图标
  IconData _getTypeIcon(ProjectType type) {
    switch (type) {
      case ProjectType.tool:
        return Icons.build;
      case ProjectType.game:
        return Icons.games;
      case ProjectType.utility:
        return Icons.widgets;
      case ProjectType.theme:
        return Icons.palette;
      case ProjectType.other:
        return Icons.extension;
    }
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  /// 打开项目
  void _openProject(DeveloperProject project) {
    // TODO: Phase 5.0.6.3 - 实现项目详情页面
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('打开项目: ${project.name}')),
    );
  }

  /// 创建新项目
  void _createNewProject() {
    // TODO: Phase 5.0.6.3 - 实现新建项目对话框
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('新建项目功能即将推出...')),
    );
  }
}
