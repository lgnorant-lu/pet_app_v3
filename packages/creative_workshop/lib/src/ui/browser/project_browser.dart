/*
---------------------------------------------------------------
File name:          project_browser.dart
Author:             lgnorant-lu
Date created:       2025-07-18
Last modified:      2025-07-18
Dart Version:       3.2+
Description:        创意工坊项目浏览器组件
---------------------------------------------------------------
Change History:
    2025-07-18: Initial creation - 项目浏览器组件实现;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:creative_workshop/src/core/projects/index.dart';

/// 项目浏览器组件
class ProjectBrowser extends StatefulWidget {
  const ProjectBrowser({
    super.key,
    this.width = 300,
    this.backgroundColor,
    this.showCreateButton = true,
  });

  /// 浏览器宽度
  final double width;

  /// 背景颜色
  final Color? backgroundColor;

  /// 是否显示创建按钮
  final bool showCreateButton;

  @override
  State<ProjectBrowser> createState() => _ProjectBrowserState();
}

class _ProjectBrowserState extends State<ProjectBrowser> {
  late ProjectManager _projectManager;
  String _searchQuery = '';
  ProjectType? _filterType;

  @override
  void initState() {
    super.initState();
    _projectManager = ProjectManager.instance;
    _projectManager.addListener(_onProjectChanged);
  }

  @override
  void dispose() {
    _projectManager.removeListener(_onProjectChanged);
    super.dispose();
  }

  void _onProjectChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = widget.backgroundColor ?? theme.colorScheme.surface;

    return Container(
      width: widget.width,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: <Widget>[
          // 浏览器标题
          _buildBrowserHeader(),

          // 搜索和筛选
          _buildSearchAndFilter(),

          // 项目列表
          Expanded(
            child: _buildProjectList(),
          ),

          // 底部操作栏
          if (widget.showCreateButton) _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildBrowserHeader() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: Row(
          children: <Widget>[
            const Icon(Icons.folder, size: 20),
            const SizedBox(width: 8),
            const Text(
              '项目浏览器',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),

            // 项目统计
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_projectManager.projects.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildSearchAndFilter() => Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: <Widget>[
            // 搜索框
            TextField(
              decoration: const InputDecoration(
                hintText: '搜索项目...',
                prefixIcon: Icon(Icons.search, size: 20),
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true,
              ),
              onChanged: (String value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),

            const SizedBox(height: 8),

            // 类型筛选
            DropdownButtonFormField<ProjectType?>(
              value: _filterType,
              decoration: const InputDecoration(
                labelText: '项目类型',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true,
              ),
              items: <DropdownMenuItem<ProjectType?>>[
                const DropdownMenuItem<ProjectType?>(
                  child: Text('全部类型'),
                ),
                ...ProjectType.values.map(
                  (ProjectType type) => DropdownMenuItem(
                    value: type,
                    child: Text(_getProjectTypeName(type)),
                  ),
                ),
              ],
              onChanged: (ProjectType? value) {
                setState(() {
                  _filterType = value;
                });
              },
            ),
          ],
        ),
      );

  Widget _buildProjectList() {
    final filteredProjects = _getFilteredProjects();

    if (filteredProjects.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: filteredProjects.length,
      itemBuilder: (BuildContext context, int index) {
        final project = filteredProjects[index];
        return _buildProjectItem(project);
      },
    );
  }

  Widget _buildEmptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.folder_open,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty || _filterType != null
                  ? '没有找到匹配的项目'
                  : '还没有项目',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty || _filterType != null
                  ? '尝试调整搜索条件'
                  : '创建第一个项目开始吧！',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );

  Widget _buildProjectItem(CreativeProject project) {
    final isCurrentProject = _projectManager.currentProject?.id == project.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isCurrentProject ? 2 : 1,
      child: ListTile(
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: _getProjectTypeColor(project.type),
          child: Icon(
            _getProjectTypeIcon(project.type),
            size: 16,
            color: Colors.white,
          ),
        ),
        title: Text(
          project.name,
          style: TextStyle(
            fontWeight: isCurrentProject ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _getProjectTypeName(project.type),
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(
              _formatDate(project.updatedAt),
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          iconSize: 16,
          onSelected: (String action) => _handleProjectAction(action, project),
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem(
              value: 'open',
              child: Row(
                children: <Widget>[
                  Icon(Icons.open_in_new, size: 16),
                  SizedBox(width: 8),
                  Text('打开'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'rename',
              child: Row(
                children: <Widget>[
                  Icon(Icons.edit, size: 16),
                  SizedBox(width: 8),
                  Text('重命名'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'duplicate',
              child: Row(
                children: <Widget>[
                  Icon(Icons.copy, size: 16),
                  SizedBox(width: 8),
                  Text('复制'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: <Widget>[
                  Icon(Icons.delete, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('删除', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        selected: isCurrentProject,
        selectedTileColor: Colors.blue.withOpacity(0.1),
        onTap: () {
          _projectManager.openProject(project.id);
        },
      ),
    );
  }

  Widget _buildBottomActions() => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
          border: Border(
            top: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _showCreateProjectDialog,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('新建项目'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _refreshProjects,
              icon: const Icon(Icons.refresh, size: 20),
              tooltip: '刷新',
            ),
          ],
        ),
      );

  List<CreativeProject> _getFilteredProjects() {
    var projects = _projectManager.projects;

    // 按类型筛选
    if (_filterType != null) {
      projects =
          projects.where((CreativeProject p) => p.type == _filterType).toList();
    }

    // 按搜索查询筛选
    if (_searchQuery.isNotEmpty) {
      projects = _projectManager.searchProjects(_searchQuery);
    }

    // 按更新时间排序
    projects.sort((CreativeProject a, CreativeProject b) =>
        b.updatedAt.compareTo(a.updatedAt));

    return projects;
  }

  void _handleProjectAction(String action, CreativeProject project) {
    switch (action) {
      case 'open':
        _projectManager.openProject(project.id);
      case 'rename':
        _showRenameDialog(project);
      case 'duplicate':
        _projectManager.duplicateProject(project.id);
      case 'delete':
        _showDeleteDialog(project);
    }
  }

  void _showCreateProjectDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => const ProjectCreationWizard(),
    );
  }

  void _showRenameDialog(CreativeProject project) {
    final controller = TextEditingController(text: project.name);

    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('重命名项目'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '项目名称',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != project.name) {
                final updatedProject = project.copyWith(name: newName);
                _projectManager.saveProject(updatedProject);
              }
              Navigator.of(context).pop();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(CreativeProject project) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('删除项目'),
        content: Text('确定要删除项目 "${project.name}" 吗？此操作无法撤销。'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _projectManager.deleteProject(project.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _refreshProjects() async {
    try {
      // 显示刷新指示器
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('正在刷新项目列表...'),
              ],
            ),
            duration: Duration(seconds: 1),
          ),
        );
      }

      // 重新加载项目列表
      await _projectManager.refreshProjects();

      // 更新UI
      if (mounted) {
        setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('项目列表已刷新'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('刷新失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getProjectTypeName(ProjectType type) {
    switch (type) {
      case ProjectType.drawing:
        return '绘画';
      case ProjectType.design:
        return '设计';
      case ProjectType.game:
        return '游戏';
      case ProjectType.animation:
        return '动画';
      case ProjectType.model3d:
        return '3D模型';
      case ProjectType.mixed:
        return '混合';
      case ProjectType.custom:
        return '自定义';
    }
  }

  IconData _getProjectTypeIcon(ProjectType type) {
    switch (type) {
      case ProjectType.drawing:
        return Icons.brush;
      case ProjectType.design:
        return Icons.design_services;
      case ProjectType.game:
        return Icons.games;
      case ProjectType.animation:
        return Icons.movie;
      case ProjectType.model3d:
        return Icons.view_in_ar;
      case ProjectType.mixed:
        return Icons.auto_awesome;
      case ProjectType.custom:
        return Icons.extension;
    }
  }

  Color _getProjectTypeColor(ProjectType type) {
    switch (type) {
      case ProjectType.drawing:
        return Colors.red;
      case ProjectType.design:
        return Colors.blue;
      case ProjectType.game:
        return Colors.green;
      case ProjectType.animation:
        return Colors.purple;
      case ProjectType.model3d:
        return Colors.orange;
      case ProjectType.mixed:
        return Colors.teal;
      case ProjectType.custom:
        return Colors.grey;
    }
  }

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
}
