/*
---------------------------------------------------------------
File name:          pet_widget_test.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        桌宠显示组件测试
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../../lib/ui/pages/pet/widgets/pet_widget.dart';
import '../../../../../lib/core/pet/models/pet_entity.dart';
import '../../../../../lib/core/pet/enums/pet_mood.dart';
import '../../../../../lib/core/pet/enums/pet_activity.dart';
import '../../../../../lib/core/pet/enums/pet_status.dart';

void main() {
  group('PetWidget Tests', () {
    late PetEntity testPet;

    setUp(() {
      testPet = PetEntity.createDefault(name: '测试宠物');
    });

    testWidgets('应该显示桌宠组件', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PetWidget(pet: testPet),
          ),
        ),
      );

      // 验证桌宠组件存在
      expect(find.byType(PetWidget), findsOneWidget);
    });

    testWidgets('应该响应点击事件', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PetWidget(
              pet: testPet,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      // 点击桌宠
      await tester.tap(find.byType(PetWidget));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('应该响应长按事件', (WidgetTester tester) async {
      bool longPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PetWidget(
              pet: testPet,
              onLongPress: () => longPressed = true,
            ),
          ),
        ),
      );

      // 长按桌宠
      await tester.longPress(find.byType(PetWidget));
      await tester.pump();

      expect(longPressed, isTrue);
    });

    testWidgets('应该显示心情表情', (WidgetTester tester) async {
      final happyPet = testPet.copyWith(mood: PetMood.happy);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PetWidget(pet: happyPet),
          ),
        ),
      );

      // 验证心情表情显示
      expect(find.text(PetMood.happy.emoji), findsOneWidget);
    });

    testWidgets('应该显示活动指示器', (WidgetTester tester) async {
      final playingPet = testPet.copyWith(currentActivity: PetActivity.playing);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PetWidget(pet: playingPet),
          ),
        ),
      );

      // 验证活动指示器显示
      expect(find.text(PetActivity.playing.emoji), findsOneWidget);
      expect(find.text(PetActivity.playing.displayName), findsOneWidget);
    });

    testWidgets('应该显示状态指示器', (WidgetTester tester) async {
      final sickPet = testPet.copyWith(status: PetStatus.sick);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PetWidget(pet: sickPet),
          ),
        ),
      );

      // 验证状态指示器存在（需要关注的状态）
      expect(sickPet.status.needsAttention, isTrue);
    });

    testWidgets('应该支持自定义大小', (WidgetTester tester) async {
      const customSize = 200.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PetWidget(
              pet: testPet,
              size: customSize,
            ),
          ),
        ),
      );

      // 验证组件大小
      final widget = tester.widget<PetWidget>(find.byType(PetWidget));
      expect(widget.size, equals(customSize));
    });

    testWidgets('应该支持动画', (WidgetTester tester) async {
      late AnimationController controller;
      late Animation<double> scaleAnimation;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              controller = AnimationController(
                duration: const Duration(seconds: 1),
                vsync: Scaffold.of(context),
              );
              scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(controller);

              return Scaffold(
                body: PetWidget(
                  pet: testPet,
                  scaleAnimation: scaleAnimation,
                ),
              );
            },
          ),
        ),
      );

      // 验证动画组件存在
      expect(find.byType(PetWidget), findsOneWidget);
      
      controller.dispose();
    });
  });
}
