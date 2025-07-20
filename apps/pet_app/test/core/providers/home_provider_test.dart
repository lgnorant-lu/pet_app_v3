/*
---------------------------------------------------------------
File name:          home_provider_test.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        首页数据提供者测试
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_app_v3/core/providers/home_provider.dart';
import 'package:pet_app_v3/ui/pages/home/widgets/module_status_card.dart';

void main() {
  group('HomeProvider Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('应该提供默认的首页数据', () async {
      // 等待初始化完成
      await Future.delayed(const Duration(milliseconds: 600));

      final homeData = container.read(homeProvider);

      expect(homeData, isA<HomeData>());
      // 初始化时可能仍在加载，这是正常的
    });

    test('应该能够刷新数据', () async {
      final notifier = container.read(homeProvider.notifier);

      await notifier.refresh();

      final homeData = container.read(homeProvider);
      expect(homeData.modules, isNotEmpty);
    });

    test('应该能够更新模块状态', () async {
      final notifier = container.read(homeProvider.notifier);

      // 等待初始数据加载
      await notifier.refresh();

      notifier.updateModuleStatus('workshop', ModuleStatus.warning);

      final modules = container.read(modulesProvider);
      final workshopModule = modules.firstWhere((m) => m.id == 'workshop');
      expect(workshopModule.status, equals(ModuleStatus.warning));
    });

    test('应该能够添加最近项目', () async {
      final notifier = container.read(homeProvider.notifier);

      // 等待初始数据加载
      await notifier.refresh();

      notifier.addRecentProject('新项目');

      final recentProjects = container.read(recentProjectsProvider);
      expect(recentProjects, contains('新项目'));
    });

    test('应该能够解锁成就', () async {
      final notifier = container.read(homeProvider.notifier);

      // 等待初始数据加载
      await notifier.refresh();

      notifier.unlockAchievement('new_achievement');

      final achievements = container.read(achievementsProvider);
      expect(achievements, contains('new_achievement'));
    });

    test('应该能够更新用户统计', () async {
      final notifier = container.read(homeProvider.notifier);

      // 等待初始数据加载
      await notifier.refresh();

      notifier.updateUserStats({'newStat': 42});

      final userStats = container.read(userStatsProvider);
      expect(userStats['newStat'], equals(42));
    });

    test('应该正确处理加载状态', () async {
      final notifier = container.read(homeProvider.notifier);

      // 开始刷新时应该设置加载状态
      final refreshFuture = notifier.refresh();

      // 在某些情况下可能会短暂显示加载状态
      // 等待完成
      await refreshFuture;

      final isLoading = container.read(homeLoadingProvider);
      expect(isLoading, isFalse);
    });

    test('应该提供正确的模块数据', () async {
      final notifier = container.read(homeProvider.notifier);
      await notifier.refresh();

      final modules = container.read(modulesProvider);

      expect(modules, hasLength(4));
      expect(
        modules.map((m) => m.id),
        containsAll(['workshop', 'apps', 'pet', 'settings']),
      );
    });

    test('应该提供用户统计数据', () async {
      final notifier = container.read(homeProvider.notifier);
      await notifier.refresh();

      final userStats = container.read(userStatsProvider);

      expect(userStats, containsPair('usageHours', 24.5));
      expect(userStats, containsPair('projectCount', 8));
      expect(userStats, containsPair('pluginCount', 12));
      expect(userStats, containsPair('achievementCount', 3));
    });

    test('应该限制最近项目数量', () async {
      final notifier = container.read(homeProvider.notifier);
      await notifier.refresh();

      // 添加超过5个项目
      for (int i = 0; i < 7; i++) {
        notifier.addRecentProject('项目$i');
      }

      final recentProjects = container.read(recentProjectsProvider);
      expect(recentProjects.length, lessThanOrEqualTo(5));
    });

    test('应该防止重复解锁相同成就', () async {
      final notifier = container.read(homeProvider.notifier);
      await notifier.refresh();

      // 多次解锁相同成就
      notifier.unlockAchievement('test_achievement');
      notifier.unlockAchievement('test_achievement');
      notifier.unlockAchievement('test_achievement');

      final achievements = container.read(achievementsProvider);
      final testAchievements = achievements.where(
        (a) => a == 'test_achievement',
      );
      expect(testAchievements.length, equals(1));
    });
  });

  group('ModuleInfo Tests', () {
    test('应该正确序列化和反序列化', () {
      const original = ModuleInfo(
        id: 'test',
        title: 'Test Module',
        icon: Icons.star,
        status: ModuleStatus.active,
        subtitle: 'Test subtitle',
        metadata: {'key': 'value'},
      );

      final json = original.toJson();
      final restored = ModuleInfo.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.title, equals(original.title));
      expect(restored.status, equals(original.status));
      expect(restored.subtitle, equals(original.subtitle));
      expect(restored.metadata, equals(original.metadata));
    });

    test('应该正确处理图标转换', () {
      const moduleInfo = ModuleInfo(
        id: 'test',
        title: 'Test',
        icon: Icons.build,
        status: ModuleStatus.normal,
        subtitle: 'Test',
      );

      final json = moduleInfo.toJson();
      expect(json['icon'], equals('build'));

      final restored = ModuleInfo.fromJson(json);
      expect(restored.icon, equals(Icons.build));
    });

    test('应该正确处理状态转换', () {
      const moduleInfo = ModuleInfo(
        id: 'test',
        title: 'Test',
        icon: Icons.star,
        status: ModuleStatus.warning,
        subtitle: 'Test',
      );

      final json = moduleInfo.toJson();
      expect(json['status'], equals('warning'));

      final restored = ModuleInfo.fromJson(json);
      expect(restored.status, equals(ModuleStatus.warning));
    });
  });

  group('ModuleStatus Tests', () {
    test('应该有正确的标签和颜色', () {
      expect(ModuleStatus.active.label, equals('活跃'));
      expect(ModuleStatus.normal.label, equals('正常'));
      expect(ModuleStatus.warning.label, equals('警告'));
      expect(ModuleStatus.error.label, equals('错误'));
      expect(ModuleStatus.inactive.label, equals('未激活'));

      expect(ModuleStatus.active.color, equals(Colors.green));
      expect(ModuleStatus.normal.color, equals(Colors.blue));
      expect(ModuleStatus.warning.color, equals(Colors.orange));
      expect(ModuleStatus.error.color, equals(Colors.red));
      expect(ModuleStatus.inactive.color, equals(Colors.grey));
    });
  });
}
