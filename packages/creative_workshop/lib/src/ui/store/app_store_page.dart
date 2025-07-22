/*
---------------------------------------------------------------
File name:          app_store_page.dart
Author:             lgnorant-lu
Date created:       2025-07-22
Last modified:      2025-07-22
Dart Version:       3.2+
Description:        应用商店主页面
---------------------------------------------------------------
Change History:
    2025-07-22: Initial creation - 应用商店主页面;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';

import 'package:creative_workshop/src/ui/store/plugin_card.dart';
import 'package:creative_workshop/src/ui/store/plugin_search_bar.dart';
import 'package:creative_workshop/src/ui/store/category_filter.dart';

/// 应用商店主页面
class AppStorePage extends StatefulWidget {
  const AppStorePage({
    super.key,
    this.initialCategory,
    this.initialSearchQuery,
  });

  /// 初始分类
  final StorePluginCategory? initialCategory;

  /// 初始搜索查询
  final String? initialSearchQuery;

  @override
  State<AppStorePage> createState() => _AppStorePageState();
}

class _AppStorePageState extends State<AppStorePage>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  // 搜索和过滤状态
  String _searchQuery = '';
  StorePluginCategory? _selectedCategory;
  bool _showInstalledOnly = false;

  // 插件数据
  List<PluginInfo> _allPlugins = [];
  List<PluginInfo> _filteredPlugins = [];

  // 加载状态
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // 初始化状态
    _searchQuery = widget.initialSearchQuery ?? '';
    _selectedCategory = widget.initialCategory;

    // 加载插件数据
    _loadPlugins();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// 加载插件数据
  Future<void> _loadPlugins() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: Phase 5.0.6.2 - 从插件市场API加载插件
      // 当前使用模拟数据
      _allPlugins = await _loadMockPlugins();
      _filterPlugins();
    } catch (e) {
      setState(() {
        _errorMessage = '加载插件失败: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 加载模拟插件数据
  Future<List<PluginInfo>> _loadMockPlugins() async {
    // 模拟网络延迟
    await Future<void>.delayed(const Duration(milliseconds: 500));

    return [
      const PluginInfo(
        id: 'advanced_brush',
        name: '高级画笔工具',
        description: '提供多种画笔效果和纹理',
        version: '1.2.0',
        author: 'Creative Tools Inc.',
        category: StorePluginCategory.tool,
        rating: 4.8,
        downloadCount: 15420,
        isInstalled: false,
        iconUrl: 'https://example.com/icons/brush.png',
        screenshots: [
          'https://example.com/screenshots/brush1.png',
          'https://example.com/screenshots/brush2.png',
        ],
        tags: ['绘画', '画笔', '艺术'],
        price: 0.0, // 免费
      ),
      const PluginInfo(
        id: 'shape_designer',
        name: '形状设计器',
        description: '专业的几何形状设计工具',
        version: '2.1.0',
        author: 'Design Studio',
        category: StorePluginCategory.tool,
        rating: 4.6,
        downloadCount: 8930,
        isInstalled: true,
        iconUrl: 'https://example.com/icons/shapes.png',
        screenshots: [
          'https://example.com/screenshots/shapes1.png',
        ],
        tags: ['设计', '形状', '几何'],
        price: 9.99,
      ),
      const PluginInfo(
        id: 'puzzle_master',
        name: '拼图大师',
        description: '经典拼图游戏，多种难度',
        version: '1.0.5',
        author: 'Game Makers',
        category: StorePluginCategory.game,
        rating: 4.9,
        downloadCount: 25680,
        isInstalled: false,
        iconUrl: 'https://example.com/icons/puzzle.png',
        screenshots: [
          'https://example.com/screenshots/puzzle1.png',
          'https://example.com/screenshots/puzzle2.png',
          'https://example.com/screenshots/puzzle3.png',
        ],
        tags: ['游戏', '拼图', '益智'],
        price: 4.99,
      ),
      const PluginInfo(
        id: 'color_palette',
        name: '调色板专家',
        description: '专业的颜色管理和调色工具',
        version: '1.5.2',
        author: 'Color Labs',
        category: StorePluginCategory.utility,
        rating: 4.7,
        downloadCount: 12340,
        isInstalled: true,
        iconUrl: 'https://example.com/icons/palette.png',
        screenshots: [
          'https://example.com/screenshots/palette1.png',
        ],
        tags: ['颜色', '调色板', '设计'],
        price: 0.0,
      ),
    ];
  }

  /// 过滤插件
  void _filterPlugins() {
    _filteredPlugins = _allPlugins.where((plugin) {
      // 搜索过滤
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!plugin.name.toLowerCase().contains(query) &&
            !plugin.description.toLowerCase().contains(query) &&
            !plugin.tags.any((tag) => tag.toLowerCase().contains(query))) {
          return false;
        }
      }

      // 分类过滤
      if (_selectedCategory != null && plugin.category != _selectedCategory) {
        return false;
      }

      // 已安装过滤
      if (_showInstalledOnly && !plugin.isInstalled) {
        return false;
      }

      return true;
    }).toList();

    setState(() {});
  }

  /// 处理搜索
  void _onSearchChanged(String query) {
    _searchQuery = query;
    _filterPlugins();
  }

  /// 处理分类选择
  void _onCategoryChanged(StorePluginCategory? category) {
    _selectedCategory = category;
    _filterPlugins();
  }

  /// 处理已安装过滤
  void _onInstalledFilterChanged(bool showInstalledOnly) {
    _showInstalledOnly = showInstalledOnly;
    _filterPlugins();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('应用商店'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.explore), text: '发现'),
            Tab(icon: Icon(Icons.category), text: '分类'),
            Tab(icon: Icon(Icons.download), text: '已安装'),
            Tab(icon: Icon(Icons.update), text: '更新'),
          ],
        ),
      ),
      body: Column(
        children: [
          // 搜索栏
          PluginSearchBar(
            initialQuery: _searchQuery,
            onSearchChanged: _onSearchChanged,
          ),

          // 分类过滤器
          CategoryFilter(
            selectedCategory: _selectedCategory,
            onCategoryChanged: _onCategoryChanged,
            showInstalledOnly: _showInstalledOnly,
            onInstalledFilterChanged: _onInstalledFilterChanged,
          ),

          // 主内容区域
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDiscoverTab(),
                _buildCategoryTab(),
                _buildInstalledTab(),
                _buildUpdatesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建发现标签页
  Widget _buildDiscoverTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPlugins,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (_filteredPlugins.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '没有找到匹配的插件',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredPlugins.length,
      itemBuilder: (context, index) {
        return PluginCard(
          plugin: _filteredPlugins[index],
          onInstall: _handlePluginInstall,
          onUninstall: _handlePluginUninstall,
          onTap: _handlePluginTap,
        );
      },
    );
  }

  /// 构建分类标签页
  Widget _buildCategoryTab() {
    // TODO: 实现分类视图
    return const Center(
      child: Text('分类视图 - 待实现'),
    );
  }

  /// 构建已安装标签页
  Widget _buildInstalledTab() {
    final installedPlugins = _allPlugins.where((p) => p.isInstalled).toList();

    if (installedPlugins.isEmpty) {
      return const Center(
        child: Text('暂无已安装的插件'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: installedPlugins.length,
      itemBuilder: (context, index) {
        return PluginCard(
          plugin: installedPlugins[index],
          onInstall: _handlePluginInstall,
          onUninstall: _handlePluginUninstall,
          onTap: _handlePluginTap,
        );
      },
    );
  }

  /// 构建更新标签页
  Widget _buildUpdatesTab() {
    // TODO: 实现更新检查
    return const Center(
      child: Text('更新检查 - 待实现'),
    );
  }

  /// 处理插件安装
  Future<void> _handlePluginInstall(PluginInfo plugin) async {
    // TODO: 实现插件安装逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('正在安装 ${plugin.name}...')),
    );
  }

  /// 处理插件卸载
  Future<void> _handlePluginUninstall(PluginInfo plugin) async {
    // TODO: 实现插件卸载逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('正在卸载 ${plugin.name}...')),
    );
  }

  /// 处理插件点击
  void _handlePluginTap(PluginInfo plugin) {
    // TODO: 导航到插件详情页
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('查看 ${plugin.name} 详情')),
    );
  }
}

/// 插件信息数据模型
class PluginInfo {
  const PluginInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.version,
    required this.author,
    required this.category,
    required this.rating,
    required this.downloadCount,
    required this.isInstalled,
    this.iconUrl,
    this.screenshots = const [],
    this.tags = const [],
    this.price = 0.0,
  });

  final String id;
  final String name;
  final String description;
  final String version;
  final String author;
  final StorePluginCategory category;
  final double rating;
  final int downloadCount;
  final bool isInstalled;
  final String? iconUrl;
  final List<String> screenshots;
  final List<String> tags;
  final double price;
}
