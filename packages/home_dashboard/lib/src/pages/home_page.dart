/*
---------------------------------------------------------------
File name:          home_page.dart
Author:             lgnorant-lu
Date created:       2025-07-20
Last modified:      2025-07-24
Dart Version:       3.2+
Description:        首页仪表板 - Phase 4.1 核心功能 (迁移到模块)
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:home_dashboard/src/providers/home_provider.dart';
import 'package:home_dashboard/src/utils/animation_utils.dart';
import 'package:home_dashboard/src/utils/responsive_utils.dart';
import 'package:home_dashboard/src/widgets/module_status_card.dart';
import 'package:home_dashboard/src/widgets/quick_access_panel.dart';
import 'package:home_dashboard/src/widgets/status_overview_panel.dart';
import 'package:home_dashboard/src/widgets/user_overview_widget.dart';
import 'package:home_dashboard/src/widgets/welcome_header.dart';

/// 首页仪表板
///
/// Phase 5.0.7 增强功能：
/// - 模块状态展示
/// - 快速访问入口
/// - 用户数据概览
/// - 个性化推荐
/// - 响应式布局
/// - 动画反馈
/// - 交互体验优化
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();

    // 初始化动画控制器
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // 初始化动画
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.elasticOut,
    );

    // 启动动画
    _startAnimations();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  /// 启动动画序列
  void _startAnimations() {
    Future<void>.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _fabAnimationController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeData = ref.watch(homeProvider);
    final modules = ref.watch(modulesProvider);

    return Scaffold(
      body: ResponsiveContainer(
        child: RefreshIndicator(
          onRefresh: () => ref.read(homeProvider.notifier).refresh(),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 欢迎头部
              SliverToBoxAdapter(
                child: AnimationUtils.delayedAnimation(
                  delay: const Duration(milliseconds: 200),
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: WelcomeHeader(),
                  ),
                ),
              ),

              // 快速访问面板
              SliverToBoxAdapter(
                child: AnimationUtils.delayedAnimation(
                  delay: const Duration(milliseconds: 400),
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: QuickAccessPanel(),
                  ),
                ),
              ),

              // 模块状态卡片
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: homeData.isLoading
                    ? const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      )
                    : SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              ResponsiveUtils.getGridColumns(context),
                          childAspectRatio: 1.2,
                          crossAxisSpacing:
                              ResponsiveUtils.getResponsiveSpacing(context),
                          mainAxisSpacing:
                              ResponsiveUtils.getResponsiveSpacing(context),
                        ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final module = modules[index];
                          return AnimationUtils.listItemAnimation(
                            index: index,
                            child: ModuleStatusCard(
                              title: module.title,
                              icon: module.icon,
                              status: module.status.label,
                              statusColor: module.status.color,
                              subtitle: module.subtitle,
                              onTap: () =>
                                  _navigateToModule(context, module.id),
                            ),
                          );
                        }, childCount: modules.length),
                      ),
              ),

              // 状态概览面板
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: StatusOverviewPanel(),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // 用户概览
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: UserOverviewWidget(),
                ),
              ),

              // 底部间距
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),

      // 动画化的浮动操作按钮
      floatingActionButton: _buildAnimatedFAB(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  /// 构建动画化的浮动操作按钮
  Widget _buildAnimatedFAB(BuildContext context) {
    final theme = Theme.of(context);

    return ScaleTransition(
      scale: _fabAnimation,
      child: FloatingActionButton.extended(
        onPressed: () => _showQuickActions(context),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: ResponsiveBuilder(
          mobile: (context) => const SizedBox.shrink(),
          builder: (context) => const Text('快速操作'),
        ),
        tooltip: '快速操作',
      ),
    );
  }

  /// 显示快速操作
  void _showQuickActions(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('快速操作功能开发中...'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: '了解',
          onPressed: () {},
        ),
      ),
    );
  }

  /// 导航到模块
  void _navigateToModule(BuildContext context, String moduleId) {
    switch (moduleId) {
      case 'workshop':
        // TODO: 导航到创意工坊
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('创意工坊功能开发中...')));
        break;
      case 'apps':
        // TODO: 导航到应用管理
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('应用管理功能开发中...')));
        break;
      case 'pet':
        // TODO: 导航到桌宠
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('桌宠功能开发中...')));
        break;
      case 'settings':
        Navigator.of(context).pushNamed('/settings');
        break;
    }
  }
}
