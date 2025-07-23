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
import 'package:plugin_system/plugin_system.dart';

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
  late final PluginStoreManager _storeManager;
  late final PluginSearchEngine _searchEngine;
  late final PluginRecommendationEngine _recommendationEngine;

  // 搜索和过滤状态
  String _searchQuery = '';
  StorePluginCategory? _selectedCategory;
  bool _showInstalledOnly = false;

  // 插件数据 (懒加载优化)
  List<PluginInfo> _allPlugins = [];
  List<PluginInfo> _filteredPlugins = [];
  List<PluginStoreEntry> _storeEntries = [];

  // 懒加载状态
  int _currentPage = 0;
  static const int _pageSize = 20;

  // 推荐数据
  List<PluginRecommendation> _recommendations = [];
  bool _isLoadingRecommendations = false;

  // 加载状态
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // 初始化Plugin System组件
    _storeManager = PluginStoreManager.instance;
    _searchEngine = PluginSearchEngine();
    _recommendationEngine = PluginRecommendationEngine();

    // 初始化状态
    _searchQuery = widget.initialSearchQuery ?? '';
    _selectedCategory = widget.initialCategory;

    // 加载插件数据
    _loadPlugins();

    // 延迟加载推荐数据，优先显示主要内容
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        _loadRecommendations();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();

    // 清理内存，释放大型数据结构
    _allPlugins.clear();
    _filteredPlugins.clear();
    _storeEntries.clear();
    _recommendations.clear();

    super.dispose();
  }

  /// 加载插件数据 (懒加载优化)
  Future<void> _loadPlugins() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 分页加载插件数据，减少初始加载时间
      final searchResult = await _storeManager.searchPlugins(
        PluginSearchQuery(
          keyword: '',
          limit: _pageSize, // 使用分页大小
          offset: _currentPage * _pageSize,
        ),
      );

      if (_currentPage == 0) {
        _storeEntries = searchResult.plugins;
        _allPlugins = _convertStoreEntriesToPluginInfo(_storeEntries);
      } else {
        _storeEntries.addAll(searchResult.plugins);
        _allPlugins
            .addAll(_convertStoreEntriesToPluginInfo(searchResult.plugins));
      }

      _filterPlugins();
      _currentPage++;
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

  /// 转换PluginStoreEntry到PluginInfo
  List<PluginInfo> _convertStoreEntriesToPluginInfo(
      List<PluginStoreEntry> entries) {
    return entries
        .map((entry) => PluginInfo(
              id: entry.id,
              name: entry.name,
              description: entry.description,
              version: entry.version,
              author: entry.author,
              category: _convertCategoryStringToStoreCategory(entry.category),
              tags: entry.tags,
              rating: entry.rating,
              downloadCount: entry.downloadCount,
              isInstalled: false, // TODO: 检查实际安装状态
              iconUrl: null, // PluginStoreEntry没有iconUrl字段
              screenshots: entry.screenshots,
              price: 0.0, // 假设所有插件都是免费的
            ))
        .toList();
  }

  /// 转换分类字符串到StorePluginCategory
  StorePluginCategory _convertCategoryStringToStoreCategory(String? category) {
    if (category == null) return StorePluginCategory.other;

    switch (category.toLowerCase()) {
      case 'tool':
      case 'tools':
        return StorePluginCategory.tool;
      case 'game':
      case 'games':
        return StorePluginCategory.game;
      case 'utility':
      case 'utilities':
        return StorePluginCategory.utility;
      case 'theme':
      case 'themes':
        return StorePluginCategory.theme;
      default:
        return StorePluginCategory.other;
    }
  }

  /// 加载推荐数据
  Future<void> _loadRecommendations() async {
    setState(() {
      _isLoadingRecommendations = true;
    });

    try {
      // 模拟用户ID (实际应用中应该从用户管理系统获取)
      const userId = 'demo_user';

      // 获取已安装插件ID列表 (模拟数据)
      final installedPluginIds = <String>[];

      // 并发生成推荐，限制数据量提升性能
      final limitedEntries = _storeEntries.take(50).toList(); // 限制处理的插件数量

      final recommendations =
          await _recommendationEngine.generateRecommendations(
        userId: userId,
        availablePlugins: limitedEntries,
        installedPluginIds: installedPluginIds,
        preferredType: RecommendationType.hybrid,
        limit: 10,
      );

      if (mounted) {
        setState(() {
          _recommendations = recommendations;
        });
      }
    } catch (e) {
      // 推荐加载失败不影响主要功能
      print('推荐加载失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRecommendations = false;
        });
      }
    }
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
          // 搜索栏 (增强版 - 集成PluginSearchEngine)
          PluginSearchBar(
            initialQuery: _searchQuery,
            onSearchChanged: _onSearchChanged,
            searchEngine: _searchEngine,
            enableSuggestions: true,
            enableHistory: true,
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

    return CustomScrollView(
      slivers: [
        // 推荐区域
        if (_recommendations.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: _buildRecommendationSection(),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),
        ],

        // 所有插件网格
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return PluginCard(
                  plugin: _filteredPlugins[index],
                  onInstall: _handlePluginInstall,
                  onUninstall: _handlePluginUninstall,
                  onTap: _handlePluginTap,
                );
              },
              childCount: _filteredPlugins.length,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建推荐区域
  Widget _buildRecommendationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 推荐标题
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(
                Icons.recommend,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '为您推荐',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              if (_isLoadingRecommendations)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ),

        // 推荐插件水平列表
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _recommendations.length,
            itemBuilder: (context, index) {
              final recommendation = _recommendations[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                child: _buildRecommendationCard(recommendation),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 构建推荐卡片
  Widget _buildRecommendationCard(PluginRecommendation recommendation) {
    final plugin = recommendation.plugin;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _handleRecommendationTap(recommendation),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 插件图标和评分
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.extension,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getRecommendationTypeColor(recommendation.type),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getRecommendationTypeText(recommendation.type),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // 插件名称
              Text(
                plugin.name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // 推荐理由
              Text(
                recommendation.reason,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const Spacer(),

              // 评分和下载量
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    size: 14,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    plugin.rating.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Text(
                    '${plugin.downloadCount}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 获取推荐类型颜色
  Color _getRecommendationTypeColor(RecommendationType type) {
    switch (type) {
      case RecommendationType.contentBased:
        return Colors.blue;
      case RecommendationType.collaborative:
        return Colors.green;
      case RecommendationType.popularity:
        return Colors.orange;
      case RecommendationType.behavioral:
        return Colors.purple;
      case RecommendationType.hybrid:
        return Colors.red;
    }
  }

  /// 获取推荐类型文本
  String _getRecommendationTypeText(RecommendationType type) {
    switch (type) {
      case RecommendationType.contentBased:
        return '相似';
      case RecommendationType.collaborative:
        return '协同';
      case RecommendationType.popularity:
        return '热门';
      case RecommendationType.behavioral:
        return '习惯';
      case RecommendationType.hybrid:
        return '智能';
    }
  }

  /// 处理推荐点击
  void _handleRecommendationTap(PluginRecommendation recommendation) {
    // 记录用户行为
    _recommendationEngine.recordUserBehavior(
      UserBehavior(
        userId: 'demo_user',
        action: 'view',
        pluginId: recommendation.plugin.id,
        timestamp: DateTime.now(),
        metadata: {
          'recommendation_type': recommendation.type.toString(),
          'recommendation_score': recommendation.score,
        },
      ),
    );

    // 转换为PluginInfo并处理点击
    final pluginInfo =
        _convertStoreEntriesToPluginInfo([recommendation.plugin]).first;
    _handlePluginTap(pluginInfo);
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
