/*
---------------------------------------------------------------
File name:          developer_platform_page.dart
Author:             lgnorant-lu
Date created:       2025-07-22
Last modified:      2025-07-22
Dart Version:       3.2+
Description:        开发者平台主界面
---------------------------------------------------------------
Change History:
    2025-07-22: Phase 5.0.6.3 - 开发者平台功能实现;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:creative_workshop/src/ui/developer/project_manager_tab.dart';
import 'package:creative_workshop/src/ui/developer/plugin_development_tab.dart';
import 'package:creative_workshop/src/ui/developer/publish_manager_tab.dart';
import 'package:creative_workshop/src/ui/developer/ming_cli_integration_tab.dart';

/// 开发者平台主界面
class DeveloperPlatformPage extends StatefulWidget {
  const DeveloperPlatformPage({
    super.key,
    this.initialTabIndex = 0,
  });

  /// 初始标签页索引
  final int initialTabIndex;

  @override
  State<DeveloperPlatformPage> createState() => _DeveloperPlatformPageState();
}

class _DeveloperPlatformPageState extends State<DeveloperPlatformPage>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  // 开发者统计数据
  int _totalProjects = 0;
  int _publishedPlugins = 0;
  int _totalDownloads = 0;
  double _averageRating = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );

    // 加载开发者统计数据
    _loadDeveloperStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// 加载开发者统计数据
  Future<void> _loadDeveloperStats() async {
    // TODO: Phase 5.0.6.3 - 从真实数据源加载统计信息
    // 当前使用模拟数据
    await Future<void>.delayed(const Duration(milliseconds: 300));

    setState(() {
      _totalProjects = 5;
      _publishedPlugins = 3;
      _totalDownloads = 1250;
      _averageRating = 4.6;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('开发者平台'),
        actions: [
          IconButton(
            icon: const Icon(Icons.store),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: '返回应用商店',
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showDeveloperHelp,
            tooltip: '开发者帮助',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.folder), text: '项目管理'),
            Tab(icon: Icon(Icons.code), text: '插件开发'),
            Tab(icon: Icon(Icons.publish), text: '发布管理'),
            Tab(icon: Icon(Icons.terminal), text: 'Ming CLI'),
          ],
        ),
      ),
      body: Column(
        children: [
          // 开发者统计面板
          _buildDeveloperStatsPanel(),

          // 主要内容区域
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                ProjectManagerTab(),
                PluginDevelopmentTab(),
                PublishManagerTab(),
                MingCliIntegrationTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewProject,
        icon: const Icon(Icons.add),
        label: const Text('新建项目'),
      ),
    );
  }

  /// 构建开发者统计面板
  Widget _buildDeveloperStatsPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '开发者统计',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '项目数量',
                  _totalProjects.toString(),
                  Icons.folder,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '已发布插件',
                  _publishedPlugins.toString(),
                  Icons.extension,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '总下载量',
                  _formatNumber(_totalDownloads),
                  Icons.download,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '平均评分',
                  _averageRating.toStringAsFixed(1),
                  Icons.star,
                  Colors.amber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建统计卡片
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 格式化数字
  String _formatNumber(int number) {
    if (number < 1000) {
      return number.toString();
    } else if (number < 1000000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }
  }

  /// 显示开发者帮助
  void _showDeveloperHelp() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('开发者帮助'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '欢迎使用 Creative Workshop 开发者平台！',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('功能介绍：'),
              SizedBox(height: 8),
              Text('• 项目管理：创建、编辑、管理插件项目'),
              Text('• 插件开发：代码编辑、调试、测试工具'),
              Text('• 发布管理：打包、版本管理、发布流程'),
              Text('• Ming CLI：集成 Ming CLI 开发工具'),
              SizedBox(height: 16),
              Text(
                '快速开始：',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('1. 点击"新建项目"创建插件项目'),
              Text('2. 在"插件开发"标签页编写代码'),
              Text('3. 使用"发布管理"发布到应用商店'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: 打开详细文档
            },
            child: const Text('查看文档'),
          ),
        ],
      ),
    );
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
