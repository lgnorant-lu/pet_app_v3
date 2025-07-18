/*
---------------------------------------------------------------
File name:          project_widgets.dart
Author:             lgnorant-lu
Date created:       2025-07-18
Last modified:      2025-07-18
Dart Version:       3.2+
Description:        创意项目界面组件
---------------------------------------------------------------
Change History:
    2025-07-18: Initial creation - 项目界面组件实现;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:creative_workshop/src/core/projects/project_manager.dart';
import 'package:creative_workshop/src/core/projects/project_templates.dart';

/// 项目列表组件
class ProjectListWidget extends StatefulWidget {
  const ProjectListWidget({super.key});

  @override
  State<ProjectListWidget> createState() => _ProjectListWidgetState();
}

class _ProjectListWidgetState extends State<ProjectListWidget> {
  late ProjectManager _projectManager;
  String _searchQuery = '';
  ProjectType? _filterType;

  @override
  void initState() {
    super.initState();
    _projectManager = ProjectManager.instance;
    _projectManager.addListener(_onProjectManagerChanged);
  }

  @override
  void dispose() {
    _projectManager.removeListener(_onProjectManagerChanged);
    super.dispose();
  }

  void _onProjectManagerChanged() {
    setState(() {});
  }

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

    return projects;
  }

  @override
  Widget build(BuildContext context) {
    final filteredProjects = _getFilteredProjects();

    return Column(
      children: <Widget>[
        // 搜索和筛选栏
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: '搜索项目...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (String value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<ProjectType?>(
                value: _filterType,
                hint: const Text('类型筛选'),
                items: <DropdownMenuItem<ProjectType?>>[
                  const DropdownMenuItem<ProjectType?>(
                    child: Text('全部'),
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
        ),

        // 项目列表
        Expanded(
          child: filteredProjects.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.folder_open, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        '没有找到项目',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '创建一个新项目开始吧！',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: filteredProjects.length,
                  itemBuilder: (BuildContext context, int index) {
                    final project = filteredProjects[index];
                    return _buildProjectTile(project);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildProjectTile(CreativeProject project) {
    final isCurrentProject = _projectManager.currentProject?.id == project.id;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getProjectTypeColor(project.type),
          child: Icon(
            _getProjectTypeIcon(project.type),
            color: Colors.white,
          ),
        ),
        title: Text(
          project.name,
          style: TextStyle(
            fontWeight: isCurrentProject ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (project.description.isNotEmpty) Text(project.description),
            const SizedBox(height: 4),
            Row(
              children: <Widget>[
                _buildStatusChip(project.status),
                const SizedBox(width: 8),
                Text(
                  '更新: ${_formatDate(project.updatedAt)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (String action) => _handleProjectAction(action, project),
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem(
              value: 'open',
              child: ListTile(
                leading: Icon(Icons.open_in_new),
                title: Text('打开'),
              ),
            ),
            const PopupMenuItem(
              value: 'duplicate',
              child: ListTile(
                leading: Icon(Icons.copy),
                title: Text('复制'),
              ),
            ),
            const PopupMenuItem(
              value: 'export',
              child: ListTile(
                leading: Icon(Icons.download),
                title: Text('导出'),
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('删除', style: TextStyle(color: Colors.red)),
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

  Widget _buildStatusChip(ProjectStatus status) {
    Color color;
    String text;

    switch (status) {
      case ProjectStatus.draft:
        color = Colors.grey;
        text = '草稿';
      case ProjectStatus.inProgress:
        color = Colors.blue;
        text = '进行中';
      case ProjectStatus.completed:
        color = Colors.green;
        text = '已完成';
      case ProjectStatus.published:
        color = Colors.purple;
        text = '已发布';
      case ProjectStatus.archived:
        color = Colors.orange;
        text = '已归档';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  void _handleProjectAction(String action, CreativeProject project) {
    switch (action) {
      case 'open':
        _projectManager.openProject(project.id);
      case 'duplicate':
        _projectManager.duplicateProject(project.id);
      case 'export':
        _exportProject(project);
      case 'delete':
        _deleteProject(project);
    }
  }

  void _exportProject(CreativeProject project) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => _ProjectExportDialog(project: project),
    );
  }

  void _deleteProject(CreativeProject project) {
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

/// 项目创建向导组件
class ProjectCreationWizard extends StatefulWidget {
  const ProjectCreationWizard({super.key});

  @override
  State<ProjectCreationWizard> createState() => _ProjectCreationWizardState();
}

class _ProjectCreationWizardState extends State<ProjectCreationWizard> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // 项目信息
  String _projectName = '';
  String _projectDescription = '';
  ProjectTemplate? _selectedTemplate;

  late ProjectManager _projectManager;
  late ProjectTemplateManager _templateManager;

  @override
  void initState() {
    super.initState();
    _projectManager = ProjectManager.instance;
    _templateManager = ProjectTemplateManager.instance;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Dialog(
        child: Container(
          width: 600,
          height: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: <Widget>[
              // 标题
              const Text(
                '创建新项目',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // 步骤指示器
              _buildStepIndicator(),
              const SizedBox(height: 24),

              // 页面内容
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    _buildTemplateSelectionStep(),
                    _buildProjectInfoStep(),
                    _buildConfirmationStep(),
                  ],
                ),
              ),

              // 按钮栏
              _buildButtonBar(),
            ],
          ),
        ),
      );

  Widget _buildStepIndicator() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _buildStepCircle(0, '选择模板'),
          _buildStepLine(0),
          _buildStepCircle(1, '项目信息'),
          _buildStepLine(1),
          _buildStepCircle(2, '确认创建'),
        ],
      );

  Widget _buildStepCircle(int step, String label) {
    final isActive = step == _currentStep;
    final isCompleted = step < _currentStep;

    return Column(
      children: <Widget>[
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? Colors.green
                : isActive
                    ? Colors.blue
                    : Colors.grey.shade300,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.blue : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int step) {
    final isCompleted = step < _currentStep;

    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(bottom: 24),
      color: isCompleted ? Colors.green : Colors.grey.shade300,
    );
  }

  Widget _buildTemplateSelectionStep() {
    final templates = _templateManager.templates;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          '选择项目模板',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: templates.length,
            itemBuilder: (BuildContext context, int index) {
              final template = templates[index];
              final isSelected = _selectedTemplate?.id == template.id;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTemplate = template;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: isSelected ? Colors.blue.withOpacity(0.1) : null,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        template.icon,
                        size: 32,
                        color: isSelected ? Colors.blue : Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        template.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.blue : Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        template.description,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProjectInfoStep() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            '项目信息',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: '项目名称',
              border: OutlineInputBorder(),
              hintText: '输入项目名称',
            ),
            onChanged: (String value) {
              setState(() {
                _projectName = value;
              });
            },
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: '项目描述',
              border: OutlineInputBorder(),
              hintText: '输入项目描述（可选）',
            ),
            maxLines: 3,
            onChanged: (String value) {
              setState(() {
                _projectDescription = value;
              });
            },
          ),
          if (_selectedTemplate != null) ...<Widget>[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    '选择的模板',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      Icon(_selectedTemplate!.icon, size: 24),
                      const SizedBox(width: 8),
                      Text(_selectedTemplate!.name),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedTemplate!.description,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ],
      );

  Widget _buildConfirmationStep() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            '确认创建',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  '项目信息预览',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildInfoRow('项目名称', _projectName),
                if (_projectDescription.isNotEmpty)
                  _buildInfoRow('项目描述', _projectDescription),
                if (_selectedTemplate != null)
                  _buildInfoRow('项目模板', _selectedTemplate!.name),
                const SizedBox(height: 16),
                const Text(
                  '点击"创建项目"按钮完成创建。',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      );

  Widget _buildInfoRow(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 80,
              child: Text(
                '$label:',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              child: Text(value),
            ),
          ],
        ),
      );

  Widget _buildButtonBar() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          if (_currentStep > 0)
            TextButton(
              onPressed: _previousStep,
              child: const Text('上一步'),
            )
          else
            const SizedBox(),
          Row(
            children: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _canProceed() ? _nextStep : null,
                child: Text(_currentStep == 2 ? '创建项目' : '下一步'),
              ),
            ],
          ),
        ],
      );

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _selectedTemplate != null;
      case 1:
        return _projectName.trim().isNotEmpty;
      case 2:
        return true;
      default:
        return false;
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _createProject();
    }
  }

  Future<void> _createProject() async {
    if (_selectedTemplate == null || _projectName.trim().isEmpty) {
      return;
    }

    try {
      final result = await _projectManager.createProjectFromTemplate(
        templateId: _selectedTemplate!.id,
        name: _projectName.trim(),
        description: _projectDescription.trim().isNotEmpty
            ? _projectDescription.trim()
            : null,
      );

      if (result.success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('项目 "$_projectName" 创建成功！'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('创建项目失败: ${result.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('创建项目失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// 项目导出对话框
class _ProjectExportDialog extends StatefulWidget {
  const _ProjectExportDialog({required this.project});

  final CreativeProject project;

  @override
  State<_ProjectExportDialog> createState() => _ProjectExportDialogState();
}

class _ProjectExportDialogState extends State<_ProjectExportDialog> {
  String _selectedFormat = 'png';
  bool _includeMetadata = true;
  bool _isExporting = false;

  final List<Map<String, String>> _exportFormats = [
    {'value': 'png', 'label': 'PNG 图片'},
    {'value': 'jpg', 'label': 'JPEG 图片'},
    {'value': 'pdf', 'label': 'PDF 文档'},
    {'value': 'svg', 'label': 'SVG 矢量图'},
    {'value': 'json', 'label': 'JSON 数据'},
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('导出项目: ${widget.project.name}'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('选择导出格式:'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedFormat,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _exportFormats.map((format) {
                return DropdownMenuItem<String>(
                  value: format['value'],
                  child: Text(format['label']!),
                );
              }).toList(),
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    _selectedFormat = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('包含元数据'),
              subtitle: const Text('包含项目信息、创建时间等'),
              value: _includeMetadata,
              onChanged: (bool? value) {
                setState(() {
                  _includeMetadata = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
            if (_isExporting) ...[
              const SizedBox(height: 16),
              const Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('正在导出...'),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isExporting ? null : () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _isExporting ? null : _performExport,
          child: const Text('导出'),
        ),
      ],
    );
  }

  Future<void> _performExport() async {
    setState(() {
      _isExporting = true;
    });

    try {
      // 模拟导出过程
      await Future<void>.delayed(const Duration(seconds: 2));

      // 实际实现中，这里会根据选择的格式进行真实的导出操作
      await _exportToFormat(_selectedFormat);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('项目导出成功: ${widget.project.name}.$_selectedFormat'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导出失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _exportToFormat(String format) async {
    switch (format) {
      case 'png':
        await _exportToPng();
        break;
      case 'jpg':
        await _exportToJpg();
        break;
      case 'pdf':
        await _exportToPdf();
        break;
      case 'svg':
        await _exportToSvg();
        break;
      case 'json':
        await _exportToJson();
        break;
      default:
        throw UnsupportedError('不支持的导出格式: $format');
    }
  }

  Future<void> _exportToPng() async {
    // 实现PNG导出逻辑
    // 这里会将画布内容渲染为PNG图片
  }

  Future<void> _exportToJpg() async {
    // 实现JPEG导出逻辑
    // 这里会将画布内容渲染为JPEG图片
  }

  Future<void> _exportToPdf() async {
    // 实现PDF导出逻辑
    // 这里会将项目内容生成PDF文档
  }

  Future<void> _exportToSvg() async {
    // 实现SVG导出逻辑
    // 这里会将矢量图形导出为SVG格式
  }

  Future<void> _exportToJson() async {
    // 实现JSON导出逻辑
    // 这里会将项目数据序列化为JSON格式
    // 构建项目数据并导出
    // 包含项目信息和可选的元数据

    // 保存JSON数据到文件
    // 实际实现中会使用文件选择器让用户选择保存位置
  }
}
