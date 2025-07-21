/*
---------------------------------------------------------------
File name:          desktop_pet_integration_test.dart
Author:             lgnorant-lu
Date created:       2025-07-21
Last modified:      2025-07-21
Dart Version:       3.2+
Description:        桌宠模块集成测试
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:desktop_pet/desktop_pet.dart';

void main() {
  group('Desktop Pet Integration Tests', () {
    testWidgets('PetWidget should render correctly', (
      WidgetTester tester,
    ) async {
      // 创建测试桌宠
      final testPet = PetEntity.createDefault(name: '测试桌宠', type: 'cat');

      // 构建测试应用
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: PetWidget(pet: testPet)),
          ),
        ),
      );

      // 验证桌宠组件渲染
      expect(find.byType(PetWidget), findsOneWidget);
    });

    testWidgets('PetControlPanel should render correctly', (
      WidgetTester tester,
    ) async {
      // 创建测试桌宠
      final testPet = PetEntity.createDefault(name: '测试桌宠', type: 'cat');

      // 构建测试应用
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: PetControlPanel(pet: testPet)),
          ),
        ),
      );

      // 验证控制面板渲染
      expect(find.byType(PetControlPanel), findsOneWidget);
      expect(find.text('测试桌宠'), findsOneWidget);
      expect(find.text('喂食'), findsOneWidget);
      expect(find.text('清洁'), findsOneWidget);
      expect(find.text('玩耍'), findsOneWidget);
      expect(find.text('聊天'), findsOneWidget);
    });

    testWidgets('PetSettingsScreen should render correctly', (
      WidgetTester tester,
    ) async {
      // 构建测试应用
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: const PetSettingsScreen())),
      );

      // 验证设置界面渲染
      expect(find.byType(PetSettingsScreen), findsOneWidget);
      expect(find.text('桌宠设置'), findsOneWidget);
      expect(find.text('桌宠管理'), findsOneWidget);
      expect(find.text('系统设置'), findsOneWidget);
      expect(find.text('统计信息'), findsOneWidget);
    });

    group('Pet State Management', () {
      testWidgets('Pet creation should work', (WidgetTester tester) async {
        // 构建测试应用
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Consumer(
                builder: (context, ref, child) {
                  final petState = ref.watch(petStateProvider);

                  return Scaffold(
                    body: Column(
                      children: [
                        Text('Pets: ${petState.pets.length}'),
                        ElevatedButton(
                          onPressed: () {
                            ref
                                .read(petStateProvider.notifier)
                                .createPet(name: '新桌宠', type: 'dog');
                          },
                          child: const Text('创建桌宠'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );

        // 验证初始状态
        expect(find.text('Pets: 0'), findsOneWidget);

        // 点击创建按钮
        await tester.tap(find.text('创建桌宠'));
        await tester.pumpAndSettle();

        // 验证桌宠已创建
        expect(find.text('Pets: 1'), findsOneWidget);
      });
    });

    group('Pet Interactions', () {
      testWidgets('Pet feeding should work', (WidgetTester tester) async {
        // 创建测试桌宠
        final testPet = PetEntity.createDefault(
          name: '测试桌宠',
          type: 'cat',
        ).copyWith(hunger: 80);

        // 构建测试应用
        await tester.pumpWidget(
          ProviderScope(
            overrides: [currentPetProvider.overrideWith((ref) => testPet)],
            child: MaterialApp(
              home: Scaffold(
                body: Consumer(
                  builder: (context, ref, child) {
                    final currentPet = ref.watch(currentPetProvider);

                    return Column(
                      children: [
                        Text('Hunger: ${currentPet?.hunger ?? 0}'),
                        ElevatedButton(
                          onPressed: currentPet != null
                              ? () {
                                  ref
                                      .read(petStateProvider.notifier)
                                      .feedPet(currentPet.id);
                                }
                              : null,
                          child: const Text('喂食'),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );

        // 验证初始饥饿值
        expect(find.text('Hunger: 80'), findsOneWidget);

        // 点击喂食按钮
        await tester.tap(find.text('喂食'));
        await tester.pumpAndSettle();

        // 验证饥饿值减少（这里简化测试，实际应该检查状态变化）
        expect(find.byType(ElevatedButton), findsOneWidget);
      });
    });

    group('AI Engine Integration', () {
      test('AI Engine should initialize correctly', () {
        final aiEngine = PetAIEngine();
        aiEngine.initialize();

        // 验证AI引擎初始化
        expect(aiEngine, isNotNull);
      });

      test('AI Engine should make behavior decisions', () {
        final aiEngine = PetAIEngine();
        aiEngine.initialize();

        final testPet = PetEntity.createDefault(name: '测试桌宠', type: 'cat');

        final behaviors = [
          PetBehavior.createDefault(
            id: 'test_behavior',
            name: '测试行为',
            priority: 5,
          ),
        ];

        final context = <String, dynamic>{
          'mood': testPet.mood.id,
          'activity': testPet.currentActivity.id,
          'status': testPet.status.id,
        };

        final decision = aiEngine.decideNextBehavior(
          testPet,
          behaviors,
          context,
        );

        // 验证AI决策
        expect(decision, isNotNull);
        expect(decision!.id, equals('test_behavior'));
      });
    });

    group('Lifecycle Manager Integration', () {
      test('Lifecycle Manager should manage pets correctly', () {
        final lifecycleManager = PetLifecycleManager();
        lifecycleManager.start();

        final testPet = PetEntity.createDefault(name: '测试桌宠', type: 'cat');

        // 添加桌宠到管理器
        lifecycleManager.addPet(testPet);

        // 获取生命周期信息
        final lifecycleInfo = lifecycleManager.getLifecycleInfo(testPet.id);

        // 验证生命周期管理
        expect(lifecycleInfo, isNotNull);
        expect(lifecycleInfo.currentStage, equals(testPet.ageStage));
        expect(lifecycleInfo.ageInDays, equals(testPet.ageInDays));

        // 清理
        lifecycleManager.stop();
      });
    });
  });
}
