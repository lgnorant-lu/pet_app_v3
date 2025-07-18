/*
---------------------------------------------------------------
File name:          creative_workspace.dart
Author:             lgnorant-lu
Date created:       2025-07-18
Last modified:      2025-07-18
Dart Version:       3.2+
Description:        创意工坊主工作区组件
---------------------------------------------------------------
Change History:
    2025-07-18: Initial creation - 主工作区组件实现;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:creative_workshop/src/ui/index.dart';
import 'package:creative_workshop/src/core/projects/index.dart';

/// 工作区布局模式
enum WorkspaceLayout {
  /// 标准布局（左侧项目浏览器，中间画布，右侧属性面板）
  standard,

  /// 游戏模式（中间游戏区域，底部控制面板）
  gaming,

  /// 专注模式（只有画布和工具栏）
  focus,

  /// 自定义布局
  custom,
}

/// 创意工作区组件
class CreativeWorkspace extends StatefulWidget {
  const CreativeWorkspace({
    super.key,
    this.layout = WorkspaceLayout.standard,
    this.showStatusBar = true,
    this.showProjectBrowser = true,
    this.showPropertiesPanel = true,
    this.showToolbar = true,
  });

  /// 工作区布局
  final WorkspaceLayout layout;

  /// 是否显示状态栏
  final bool showStatusBar;

  /// 是否显示项目浏览器
  final bool showProjectBrowser;

  /// 是否显示属性面板
  final bool showPropertiesPanel;

  /// 是否显示工具栏
  final bool showToolbar;

  @override
  State<CreativeWorkspace> createState() => _CreativeWorkspaceState();
}

class _CreativeWorkspaceState extends State<CreativeWorkspace> {
  late ProjectManager _projectManager;

  // 面板可见性状态
  bool _isProjectBrowserVisible = true;
  bool _isPropertiesPanelVisible = true;
  bool _isToolbarVisible = true;

  @override
  void initState() {
    super.initState();
    _projectManager = ProjectManager.instance;
    _projectManager.addListener(_onProjectChanged);

    // 初始化面板可见性
    _isProjectBrowserVisible = widget.showProjectBrowser;
    _isPropertiesPanelVisible = widget.showPropertiesPanel;
    _isToolbarVisible = widget.showToolbar;
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
  Widget build(BuildContext context) => Scaffold(
        body: Column(
          children: <Widget>[
            // 主工作区
            Expanded(
              child: _buildWorkspaceContent(),
            ),

            // 状态栏
            if (widget.showStatusBar) const StatusBar(),
          ],
        ),
      );

  Widget _buildWorkspaceContent() {
    switch (widget.layout) {
      case WorkspaceLayout.standard:
        return _buildStandardLayout();
      case WorkspaceLayout.gaming:
        return _buildGamingLayout();
      case WorkspaceLayout.focus:
        return _buildFocusLayout();
      case WorkspaceLayout.custom:
        return _buildCustomLayout();
    }
  }

  Widget _buildStandardLayout() => Row(
        children: <Widget>[
          // 左侧项目浏览器
          if (_isProjectBrowserVisible) const ProjectBrowser(width: 280),

          // 中间主要工作区
          Expanded(
            child: Column(
              children: <Widget>[
                // 工具栏
                if (_isToolbarVisible)
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: const ToolToolbar(),
                  ),

                // 画布区域
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: _buildMainContent(),
                  ),
                ),
              ],
            ),
          ),

          // 右侧属性面板
          if (_isPropertiesPanelVisible) const PropertiesPanel(width: 280),
        ],
      );

  Widget _buildGamingLayout() => Column(
        children: <Widget>[
          // 顶部工具栏
          if (_isToolbarVisible)
            Container(
              padding: const EdgeInsets.all(8),
              child: const ToolToolbar(),
            ),

          // 主游戏区域
          Expanded(
            child: Row(
              children: <Widget>[
                // 左侧项目浏览器（可选）
                if (_isProjectBrowserVisible) const ProjectBrowser(width: 250),

                // 中间游戏区域
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const GameArea(),
                  ),
                ),

                // 右侧属性面板（可选）
                if (_isPropertiesPanelVisible)
                  const PropertiesPanel(width: 250),
              ],
            ),
          ),
        ],
      );

  Widget _buildFocusLayout() => Column(
        children: <Widget>[
          // 简化工具栏
          if (_isToolbarVisible)
            Container(
              padding: const EdgeInsets.all(8),
              child: const ToolToolbar(),
            ),

          // 全屏画布
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              child: _buildMainContent(),
            ),
          ),
        ],
      );

  Widget _buildCustomLayout() {
    // 自定义布局，可以根据用户偏好配置
    return _buildStandardLayout();
  }

  Widget _buildMainContent() {
    final currentProject = _projectManager.currentProject;

    if (currentProject == null) {
      return _buildWelcomeScreen();
    }

    // 根据项目类型显示不同的内容
    switch (currentProject.type) {
      case ProjectType.game:
        return const GameArea();
      case ProjectType.drawing:
      case ProjectType.design:
      case ProjectType.animation:
      case ProjectType.model3d:
      case ProjectType.mixed:
      case ProjectType.custom:
        return CreativeCanvas(
          project: currentProject,
          mode: _getCanvasModeFromProjectType(currentProject.type),
        );
    }
  }

  Widget _buildWelcomeScreen() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.auto_awesome,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              '欢迎使用创意工坊',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '创建或打开一个项目开始您的创意之旅',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),

            // 快速操作按钮
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: <Widget>[
                _buildQuickActionCard(
                  icon: Icons.add,
                  title: '新建项目',
                  subtitle: '从模板创建新项目',
                  color: Colors.blue,
                  onTap: _showCreateProjectDialog,
                ),
                _buildQuickActionCard(
                  icon: Icons.folder_open,
                  title: '打开项目',
                  subtitle: '打开现有项目',
                  color: Colors.green,
                  onTap: _showOpenProjectDialog,
                ),
                _buildQuickActionCard(
                  icon: Icons.games,
                  title: '启动游戏',
                  subtitle: '体验内置游戏',
                  color: Colors.purple,
                  onTap: _showGameSelector,
                ),
              ],
            ),
          ],
        ),
      );

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) =>
      Card(
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 200,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: <Widget>[
                Icon(icon, size: 48, color: color),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );

  CanvasMode _getCanvasModeFromProjectType(ProjectType type) {
    switch (type) {
      case ProjectType.drawing:
        return CanvasMode.drawing;
      case ProjectType.design:
        return CanvasMode.design;
      case ProjectType.game:
        return CanvasMode.game;
      case ProjectType.animation:
      case ProjectType.model3d:
      case ProjectType.mixed:
      case ProjectType.custom:
        return CanvasMode.drawing;
    }
  }

  void _showCreateProjectDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => const ProjectCreationWizard(),
    );
  }

  void _showOpenProjectDialog() {
    // 切换项目浏览器可见性
    setState(() {
      _isProjectBrowserVisible = true;
    });
  }

  void _showGameSelector() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => const GameSelectorDialog(),
    );
  }

  // 面板切换方法
  void toggleProjectBrowser() {
    setState(() {
      _isProjectBrowserVisible = !_isProjectBrowserVisible;
    });
  }

  void togglePropertiesPanel() {
    setState(() {
      _isPropertiesPanelVisible = !_isPropertiesPanelVisible;
    });
  }

  void toggleToolbar() {
    setState(() {
      _isToolbarVisible = !_isToolbarVisible;
    });
  }

  void switchLayout(WorkspaceLayout newLayout) {
    // TODO: 实现布局切换功能
    setState(() {
      // widget.layout = newLayout; // 需要通过父组件更新
    });
  }
}
