/*
---------------------------------------------------------------
File name:          plugin_development_tab.dart
Author:             lgnorant-lu
Date created:       2025-07-22
Last modified:      2025-07-22
Dart Version:       3.2+
Description:        插件开发标签页
---------------------------------------------------------------
Change History:
    2025-07-22: Phase 5.0.6.3 - 插件开发功能实现;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';

/// 开发工具类型
enum DevelopmentTool {
  codeEditor('代码编辑器'),
  debugger('调试器'),
  tester('测试工具'),
  profiler('性能分析'),
  documentation('文档生成'),
  packaging('打包工具');

  const DevelopmentTool(this.displayName);
  final String displayName;
}

/// 插件开发标签页
class PluginDevelopmentTab extends StatefulWidget {
  const PluginDevelopmentTab({super.key});

  @override
  State<PluginDevelopmentTab> createState() => _PluginDevelopmentTabState();
}

class _PluginDevelopmentTabState extends State<PluginDevelopmentTab> {
  String? _selectedProjectId;
  DevelopmentTool _selectedTool = DevelopmentTool.codeEditor;
  bool _isToolLoading = false;

  // 模拟项目列表
  final List<Map<String, String>> _projects = [
    {'id': 'proj_001', 'name': '高级画笔工具'},
    {'id': 'proj_002', 'name': '拼图游戏引擎'},
    {'id': 'proj_003', 'name': '颜色管理器'},
    {'id': 'proj_004', 'name': '暗色主题包'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 项目选择和工具栏
        _buildToolbar(),

        // 主要开发区域
        Expanded(
          child: _selectedProjectId == null
              ? _buildProjectSelector()
              : _buildDevelopmentArea(),
        ),
      ],
    );
  }

  /// 构建工具栏
  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          // 项目选择
          Row(
            children: [
              const Icon(Icons.folder),
              const SizedBox(width: 8),
              const Text('当前项目:'),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String?>(
                  value: _selectedProjectId,
                  onChanged: (value) {
                    setState(() {
                      _selectedProjectId = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: '选择项目',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('请选择项目'),
                    ),
                    ..._projects.map((project) => DropdownMenuItem(
                          value: project['id'],
                          child: Text(project['name']!),
                        )),
                  ],
                ),
              ),
            ],
          ),

          if (_selectedProjectId != null) ...[
            const SizedBox(height: 12),

            // 开发工具选择
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: DevelopmentTool.values.map((tool) {
                  final isSelected = _selectedTool == tool;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(tool.displayName),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedTool = tool;
                          });
                        }
                      },
                      avatar: Icon(
                        _getToolIcon(tool),
                        size: 18,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建项目选择器
  Widget _buildProjectSelector() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.code,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '选择项目开始开发',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '请在上方选择一个项目来开始插件开发',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _createNewProject,
            icon: const Icon(Icons.add),
            label: const Text('创建新项目'),
          ),
        ],
      ),
    );
  }

  /// 构建开发区域
  Widget _buildDevelopmentArea() {
    if (_isToolLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在加载开发工具...'),
          ],
        ),
      );
    }

    switch (_selectedTool) {
      case DevelopmentTool.codeEditor:
        return _buildCodeEditor();
      case DevelopmentTool.debugger:
        return _buildDebugger();
      case DevelopmentTool.tester:
        return _buildTester();
      case DevelopmentTool.profiler:
        return _buildProfiler();
      case DevelopmentTool.documentation:
        return _buildDocumentation();
      case DevelopmentTool.packaging:
        return _buildPackaging();
    }
  }

  /// 构建代码编辑器
  Widget _buildCodeEditor() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.code,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '代码编辑器',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _openExternalEditor,
                icon: const Icon(Icons.open_in_new),
                label: const Text('在 VS Code 中打开'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '// 插件主文件 - main.dart',
                      style: TextStyle(
                        color: Colors.green,
                        fontFamily: 'monospace',
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'import \'package:plugin_system/plugin_system.dart\';\n\nclass MyPlugin extends ToolPlugin {\n  @override\n  String get id => \'my_plugin\';\n\n  @override\n  String get name => \'我的插件\';\n\n  @override\n  String get version => \'1.0.0\';\n\n  @override\n  Future<void> initialize() async {\n    // 插件初始化逻辑\n  }\n}',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'monospace',
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建调试器
  Widget _buildDebugger() {
    return _buildToolPlaceholder(
      DevelopmentTool.debugger,
      '调试和断点管理',
      Icons.bug_report,
      [
        '设置断点',
        '变量监视',
        '调用堆栈',
        '性能监控',
      ],
    );
  }

  /// 构建测试工具
  Widget _buildTester() {
    return _buildToolPlaceholder(
      DevelopmentTool.tester,
      '自动化测试和验证',
      Icons.verified,
      [
        '单元测试',
        '集成测试',
        'UI测试',
        '性能测试',
      ],
    );
  }

  /// 构建性能分析器
  Widget _buildProfiler() {
    return _buildToolPlaceholder(
      DevelopmentTool.profiler,
      '性能分析和优化',
      Icons.speed,
      [
        'CPU 使用率',
        '内存分析',
        '渲染性能',
        '网络请求',
      ],
    );
  }

  /// 构建文档生成器
  Widget _buildDocumentation() {
    return _buildToolPlaceholder(
      DevelopmentTool.documentation,
      'API文档自动生成',
      Icons.description,
      [
        'API 文档',
        '用户手册',
        '示例代码',
        '发布说明',
      ],
    );
  }

  /// 构建打包工具
  Widget _buildPackaging() {
    return _buildToolPlaceholder(
      DevelopmentTool.packaging,
      '插件打包和分发',
      Icons.archive,
      [
        '代码编译',
        '资源打包',
        '签名验证',
        '版本管理',
      ],
    );
  }

  /// 构建工具占位符
  Widget _buildToolPlaceholder(
    DevelopmentTool tool,
    String description,
    IconData icon,
    List<String> features,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                tool.displayName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    tool.displayName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '功能特性:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...features.map((feature) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: Colors.green[600],
                            ),
                            const SizedBox(width: 8),
                            Text(feature),
                          ],
                        ),
                      )),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _launchTool(tool),
                    child: Text('启动${tool.displayName}'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 获取工具图标
  IconData _getToolIcon(DevelopmentTool tool) {
    switch (tool) {
      case DevelopmentTool.codeEditor:
        return Icons.code;
      case DevelopmentTool.debugger:
        return Icons.bug_report;
      case DevelopmentTool.tester:
        return Icons.verified;
      case DevelopmentTool.profiler:
        return Icons.speed;
      case DevelopmentTool.documentation:
        return Icons.description;
      case DevelopmentTool.packaging:
        return Icons.archive;
    }
  }

  /// 打开外部编辑器
  void _openExternalEditor() {
    // TODO: Phase 5.0.6.3 - 集成外部编辑器
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('正在启动 VS Code...'),
      ),
    );
  }

  /// 启动开发工具
  void _launchTool(DevelopmentTool tool) {
    setState(() {
      _isToolLoading = true;
    });

    // 模拟工具启动
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isToolLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${tool.displayName}启动完成'),
        ),
      );
    });
  }

  /// 创建新项目
  void _createNewProject() {
    // TODO: Phase 5.0.6.3 - 实现新建项目功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('新建项目功能即将推出...'),
      ),
    );
  }
}
