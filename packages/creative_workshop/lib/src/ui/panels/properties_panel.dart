/*
---------------------------------------------------------------
File name:          properties_panel.dart
Author:             lgnorant-lu
Date created:       2025-07-18
Last modified:      2025-07-18
Dart Version:       3.2+
Description:        创意工坊属性面板组件
---------------------------------------------------------------
Change History:
    2025-07-18: Initial creation - 属性面板组件实现;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:creative_workshop/src/core/tools/index.dart';
import 'package:creative_workshop/src/core/projects/index.dart';

/// 属性面板组件
class PropertiesPanel extends StatefulWidget {
  const PropertiesPanel({
    super.key,
    this.width = 300,
    this.backgroundColor,
  });

  /// 面板宽度
  final double width;

  /// 背景颜色
  final Color? backgroundColor;

  @override
  State<PropertiesPanel> createState() => _PropertiesPanelState();
}

class _PropertiesPanelState extends State<PropertiesPanel> {
  late SimpleToolManager _toolManager;
  late ProjectManager _projectManager;

  @override
  void initState() {
    super.initState();
    _toolManager = SimpleToolManager.instance;
    _projectManager = ProjectManager.instance;
    _toolManager.addListener(_onToolChanged);
    _projectManager.addListener(_onProjectChanged);
  }

  @override
  void dispose() {
    _toolManager.removeListener(_onToolChanged);
    _projectManager.removeListener(_onProjectChanged);
    super.dispose();
  }

  void _onToolChanged() {
    setState(() {});
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 面板标题
          _buildPanelHeader(),

          // 面板内容
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // 工具属性
                  _buildToolProperties(),

                  const SizedBox(height: 24),

                  // 项目属性
                  _buildProjectProperties(),

                  const SizedBox(height: 24),

                  // 画布属性
                  _buildCanvasProperties(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanelHeader() => Container(
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
        child: const Row(
          children: <Widget>[
            Icon(Icons.settings, size: 20),
            SizedBox(width: 8),
            Text(
              '属性面板',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );

  Widget _buildToolProperties() {
    final activeTool = _toolManager.activeTool;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          '工具属性',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (activeTool == null) ...<Widget>[
          const Text(
            '没有选择工具',
            style: TextStyle(color: Colors.grey),
          ),
        ] else if (activeTool is SimpleBrushTool) ...<Widget>[
          _buildBrushProperties(activeTool),
        ] else if (activeTool is SimplePencilTool) ...<Widget>[
          _buildPencilProperties(activeTool),
        ] else ...<Widget>[
          Text(
            '工具: ${activeTool.runtimeType}',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ],
    );
  }

  Widget _buildBrushProperties(SimpleBrushTool brush) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Row(
            children: <Widget>[
              Icon(Icons.brush, size: 16, color: Colors.blue),
              SizedBox(width: 8),
              Text('画笔工具'),
            ],
          ),
          const SizedBox(height: 16),

          // 画笔大小
          const Text('大小'),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: Slider(
                  value: brush.brushSize,
                  min: 1,
                  max: 50,
                  divisions: 49,
                  label: brush.brushSize.toInt().toString(),
                  onChanged: (double value) {
                    brush.brushSize = value;
                  },
                ),
              ),
              SizedBox(
                width: 40,
                child: Text(
                  '${brush.brushSize.toInt()}',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 画笔颜色
          const Text('颜色'),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: brush.brushColor,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'RGB: ${brush.brushColor.red}, ${brush.brushColor.green}, ${brush.brushColor.blue}',
                    ),
                    Text('透明度: ${(brush.brushColor.opacity * 100).toInt()}%'),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 颜色预设
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Color>[
              Colors.black,
              Colors.red,
              Colors.green,
              Colors.blue,
              Colors.yellow,
              Colors.purple,
              Colors.orange,
              Colors.brown,
            ]
                .map(
                  (Color color) => GestureDetector(
                    onTap: () {
                      brush.brushColor = color;
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: color,
                        border: Border.all(
                          color: brush.brushColor == color
                              ? Colors.white
                              : Colors.grey,
                          width: brush.brushColor == color ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      );

  Widget _buildPencilProperties(SimplePencilTool pencil) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Row(
            children: <Widget>[
              Icon(Icons.edit, size: 16, color: Colors.green),
              SizedBox(width: 8),
              Text('铅笔工具'),
            ],
          ),
          const SizedBox(height: 16),

          // 铅笔大小
          const Text('大小'),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: Slider(
                  value: pencil.pencilSize,
                  min: 1,
                  max: 20,
                  divisions: 19,
                  label: pencil.pencilSize.toInt().toString(),
                  onChanged: (double value) {
                    pencil.pencilSize = value;
                  },
                ),
              ),
              SizedBox(
                width: 40,
                child: Text(
                  '${pencil.pencilSize.toInt()}',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 铅笔颜色
          const Text('颜色'),
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: pencil.pencilColor,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      );

  Widget _buildProjectProperties() {
    final currentProject = _projectManager.currentProject;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          '项目属性',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (currentProject == null) ...<Widget>[
          const Text(
            '没有打开的项目',
            style: TextStyle(color: Colors.grey),
          ),
        ] else ...<Widget>[
          _buildPropertyRow('项目名称', currentProject.name),
          _buildPropertyRow('项目类型', _getProjectTypeName(currentProject.type)),
          _buildPropertyRow('创建时间', _formatDateTime(currentProject.createdAt)),
          _buildPropertyRow('更新时间', _formatDateTime(currentProject.updatedAt)),
          _buildPropertyRow(
            '项目状态',
            _getProjectStatusName(currentProject.status),
          ),
          if (currentProject.description.isNotEmpty)
            _buildPropertyRow('描述', currentProject.description),
          if (currentProject.tags.isNotEmpty)
            _buildPropertyRow('标签', currentProject.tags.join(', ')),
        ],
      ],
    );
  }

  Widget _buildCanvasProperties() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            '画布属性',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildPropertyRow('画布大小', '800 x 600'),
          _buildPropertyRow('缩放级别', '100%'),
          _buildPropertyRow('背景颜色', '白色'),
          _buildPropertyRow('网格显示', '关闭'),
        ],
      );

  Widget _buildPropertyRow(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 80,
              child: Text(
                '$label:',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(color: Colors.black87),
              ),
            ),
          ],
        ),
      );

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

  String _getProjectStatusName(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.draft:
        return '草稿';
      case ProjectStatus.inProgress:
        return '进行中';
      case ProjectStatus.completed:
        return '已完成';
      case ProjectStatus.published:
        return '已发布';
      case ProjectStatus.archived:
        return '已归档';
    }
  }

  String _formatDateTime(DateTime dateTime) =>
      '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
      '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
}
