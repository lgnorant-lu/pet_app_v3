/*
---------------------------------------------------------------
File name:          home_page.dart
Author:             lgnorant-lu
Date created:       2025-07-20
Last modified:      2025-07-21
Dart Version:       3.2+
Description:        首页仪表板 - Phase 4.1 核心功能 (迁移到模块)
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:home_dashboard/src/providers/home_provider.dart';
import 'package:home_dashboard/src/widgets/module_status_card.dart';
import 'package:home_dashboard/src/widgets/quick_access_panel.dart';
import 'package:home_dashboard/src/widgets/user_overview_widget.dart';
import 'package:home_dashboard/src/widgets/welcome_header.dart';

/// 首页仪表板
///
/// Phase 4.1 核心功能：
/// - 模块状态展示
/// - 快速访问入口
/// - 用户数据概览
/// - 个性化推荐
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeData = ref.watch(homeProvider);
    final modules = ref.watch(modulesProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(homeProvider.notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            // 欢迎头部
            const SliverToBoxAdapter(child: WelcomeHeader()),

            // 快速访问面板
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: QuickAccessPanel(),
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
                        crossAxisCount: _getCrossAxisCount(context),
                        childAspectRatio: 1.2,
                        crossAxisSpacing: 12.0,
                        mainAxisSpacing: 12.0,
                      ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final module = modules[index];
                        return ModuleStatusCard(
                          title: module.title,
                          icon: module.icon,
                          status: module.status.label,
                          statusColor: module.status.color,
                          subtitle: module.subtitle,
                          onTap: () => _navigateToModule(context, module.id),
                        );
                      }, childCount: modules.length),
                    ),
            ),

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
    );
  }

  /// 获取网格列数
  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 2;
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
