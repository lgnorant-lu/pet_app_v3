/*
---------------------------------------------------------------
File name:          simple_games_test.dart
Author:             lgnorant-lu
Date created:       2025-07-19
Last modified:      2025-07-19
Dart Version:       3.2+
Description:        简单游戏单元测试
---------------------------------------------------------------
Change History:
    2025-07-19: Initial creation - 简单游戏测试覆盖;
---------------------------------------------------------------
*/

import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_system/plugin_system.dart';
import 'package:creative_workshop/src/core/games/simple_games.dart';
import 'package:creative_workshop/src/core/games/game_plugin.dart';

void main() {
  group('Simple Games Tests', () {
    group('SimpleClickGame Tests', () {
      late SimpleClickGame clickGame;

      setUp(() {
        clickGame = SimpleClickGame();
      });

      tearDown(() {
        clickGame.dispose();
      });

      test('应该有正确的插件信息', () {
        expect(clickGame.id, equals('simple_click_game'));
        expect(clickGame.name, equals('点击游戏'));
        expect(clickGame.version, equals('1.0.0'));
        expect(clickGame.author, equals('Creative Workshop'));
        expect(clickGame.description, equals('点击按钮获得分数'));
      });

      test('应该支持所有平台', () {
        expect(
            clickGame.supportedPlatforms, contains(SupportedPlatform.android));
        expect(clickGame.supportedPlatforms, contains(SupportedPlatform.ios));
        expect(clickGame.supportedPlatforms, contains(SupportedPlatform.web));
        expect(
            clickGame.supportedPlatforms, contains(SupportedPlatform.windows));
        expect(clickGame.supportedPlatforms, contains(SupportedPlatform.macos));
        expect(clickGame.supportedPlatforms, contains(SupportedPlatform.linux));
      });

      test('应该没有权限要求', () {
        expect(clickGame.requiredPermissions, isEmpty);
      });

      test('应该没有依赖', () {
        expect(clickGame.dependencies, isEmpty);
      });

      group('生命周期测试', () {
        test('应该能够正常初始化', () async {
          expect(() => clickGame.initialize(), returnsNormally);
        });

        test('应该能够启动和停止', () async {
          await clickGame.initialize();
          expect(() => clickGame.start(), returnsNormally);
          expect(() => clickGame.stop(), returnsNormally);
        });

        test('应该能够暂停和恢复', () async {
          await clickGame.initialize();
          await clickGame.start();
          expect(() => clickGame.pause(), returnsNormally);
          expect(() => clickGame.resume(), returnsNormally);
        });
      });

      group('游戏状态测试', () {
        test('初始状态应该是未开始', () {
          expect(clickGame.gameState, equals(GameState.notStarted));
        });

        test('应该能够开始游戏', () async {
          final result = await clickGame.startGame();
          expect(result.success, isTrue);
          expect(clickGame.gameState, equals(GameState.playing));
        });

        test('应该能够暂停游戏', () async {
          await clickGame.startGame();
          final result = await clickGame.pauseGame();
          expect(result.success, isTrue);
          expect(clickGame.gameState, equals(GameState.paused));
        });

        test('应该能够恢复游戏', () async {
          await clickGame.startGame();
          await clickGame.pauseGame();
          final result = await clickGame.resumeGame();
          expect(result.success, isTrue);
          expect(clickGame.gameState, equals(GameState.playing));
        });

        test('应该能够结束游戏', () async {
          await clickGame.startGame();
          final result = await clickGame.endGame();
          expect(result.success, isTrue);
          expect(clickGame.gameState, equals(GameState.gameOver));
        });

        test('应该能够重新开始游戏', () async {
          await clickGame.startGame();
          await clickGame.endGame();
          final result = await clickGame.restartGame();
          expect(result.success, isTrue);
          expect(clickGame.gameState, equals(GameState.playing));
        });
      });

      group('游戏逻辑测试', () {
        test('开始游戏时应该重置分数和时间', () async {
          // 先设置一些分数和时间
          clickGame.updateScore(100);
          clickGame.updateGameTime(60);

          await clickGame.startGame();

          expect(clickGame.score, equals(0));
          expect(clickGame.gameTime, equals(0));
        });

        test('应该能够更新分数', () {
          clickGame.updateScore(10);
          expect(clickGame.score, equals(10));

          clickGame.updateScore(5);
          expect(clickGame.score, equals(15));
        });

        test('应该能够更新游戏时间', () {
          clickGame.updateGameTime(30);
          expect(clickGame.gameTime, equals(30));

          clickGame.updateGameTime(60);
          expect(clickGame.gameTime, equals(60));
        });

        test('应该能够处理点击', () async {
          await clickGame.startGame();
          final initialScore = clickGame.score;
          final initialClickCount = clickGame.clickCount;

          clickGame.handleClick();

          expect(clickGame.score, greaterThan(initialScore));
          expect(clickGame.clickCount, equals(initialClickCount + 1));
        });

        test('达到目标点击数时应该胜利', () async {
          await clickGame.startGame();

          // 模拟达到目标点击数 (50次)
          for (int i = 0; i < clickGame.targetClicks; i++) {
            clickGame.handleClick();
          }

          expect(clickGame.gameState, equals(GameState.victory));
        });

        test('非游戏状态时点击应该无效', () async {
          final initialScore = clickGame.score;
          final initialClickCount = clickGame.clickCount;

          // 游戏未开始时点击
          clickGame.handleClick();

          expect(clickGame.score, equals(initialScore));
          expect(clickGame.clickCount, equals(initialClickCount));
        });
      });

      group('高分记录测试', () {
        test('结束游戏时应该更新高分', () async {
          await clickGame.startGame();
          clickGame.updateScore(150);

          final initialHighScore = clickGame.highScore;
          await clickGame.endGame();

          if (150 > initialHighScore) {
            expect(clickGame.highScore, equals(150));
          }
        });

        test('低分不应该更新高分', () async {
          // 先设置一个高分
          await clickGame.startGame();
          clickGame.updateScore(200);
          await clickGame.endGame();

          final highScore = clickGame.highScore;

          // 再玩一局低分游戏
          await clickGame.startGame();
          clickGame.updateScore(50);
          await clickGame.endGame();

          expect(clickGame.highScore, equals(highScore));
        });
      });

      group('消息处理测试', () {
        test('应该能够处理开始游戏消息', () async {
          final result = await clickGame.handleMessage('start', {});
          expect(result.success, isTrue);
          expect(clickGame.gameState, equals(GameState.playing));
        });

        test('应该能够处理暂停游戏消息', () async {
          await clickGame.startGame();
          final result = await clickGame.handleMessage('pause', {});
          expect(result.success, isTrue);
          expect(clickGame.gameState, equals(GameState.paused));
        });

        test('应该能够处理恢复游戏消息', () async {
          await clickGame.startGame();
          await clickGame.pauseGame();
          final result = await clickGame.handleMessage('resume', {});
          expect(result.success, isTrue);
          expect(clickGame.gameState, equals(GameState.playing));
        });

        test('应该能够处理结束游戏消息', () async {
          await clickGame.startGame();
          final result = await clickGame.handleMessage('end', {});
          expect(result.success, isTrue);
          expect(clickGame.gameState, equals(GameState.gameOver));
        });

        test('应该能够处理重新开始游戏消息', () async {
          await clickGame.startGame();
          await clickGame.endGame();
          final result = await clickGame.handleMessage('restart', {});
          expect(result.success, isTrue);
          expect(clickGame.gameState, equals(GameState.playing));
        });

        test('未知消息应该返回错误', () async {
          final result = await clickGame.handleMessage('unknown', {});
          expect(result.success, isFalse);
          expect(result.error, contains('Unknown action'));
        });
      });
    });
  });
}
