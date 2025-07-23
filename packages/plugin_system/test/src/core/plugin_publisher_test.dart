/*
---------------------------------------------------------------
File name:          plugin_publisher_test.dart
Author:             Pet App Team
Date created:       2025-07-23
Last modified:      2025-07-23
Dart Version:       3.2+
Description:        插件发布管理器测试
---------------------------------------------------------------
Change History:
    2025-07-23: Phase 5.0.11.1 - 插件发布功能测试实现;
---------------------------------------------------------------
*/

import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_system/plugin_system.dart';

void main() {
  group('PluginPublisher Tests', () {
    late PluginPublisher publisher;

    setUp(() {
      publisher = PluginPublisher.instance;
    });

    tearDown(() {
      publisher.dispose();
      // 重置为默认配置
      publisher.setConfig(const PublishConfig());
    });

    group('单例模式测试', () {
      test('应该返回相同的实例', () {
        final instance1 = PluginPublisher.instance;
        final instance2 = PluginPublisher.instance;
        expect(identical(instance1, instance2), isTrue);
      });
    });

    group('配置管理测试', () {
      test('应该能够设置和获取配置', () {
        const config = PublishConfig(
          registryUrl: 'https://test.example.com',
          apiKey: 'test-api-key',
          enableSigning: false,
        );

        publisher.setConfig(config);
        expect(publisher.config.registryUrl, 'https://test.example.com');
        expect(publisher.config.apiKey, 'test-api-key');
        expect(publisher.config.enableSigning, isFalse);
        expect(publisher.config.enableValidation, isTrue);
      });

      test('应该有默认配置', () {
        final config = publisher.config;
        expect(config.registryUrl, 'https://plugins.petapp.dev');
        expect(config.enableSigning, isTrue);
        expect(config.enableValidation, isTrue);
        expect(config.compressionLevel, 6);
        expect(config.visibility, PluginVisibility.public);
      });
    });

    group('发布元数据测试', () {
      test('应该能够创建发布元数据', () {
        const metadata = PublishMetadata(
          id: 'test_plugin',
          name: 'Test Plugin',
          version: '1.0.0',
          description: 'A test plugin',
          author: 'Test Author',
          category: 'utility',
          keywords: <String>['test', 'plugin'],
          permissions: <String>['file_system'],
          platforms: <String>['android', 'ios'],
        );

        expect(metadata.id, 'test_plugin');
        expect(metadata.name, 'Test Plugin');
        expect(metadata.version, '1.0.0');
        expect(metadata.description, 'A test plugin');
        expect(metadata.author, 'Test Author');
        expect(metadata.category, 'utility');
        expect(metadata.keywords, <String>['test', 'plugin']);
        expect(metadata.permissions, <String>['file_system']);
        expect(metadata.platforms, <String>['android', 'ios']);
      });

      test('应该能够转换为JSON', () {
        const metadata = PublishMetadata(
          id: 'test_plugin',
          name: 'Test Plugin',
          version: '1.0.0',
          description: 'A test plugin',
          author: 'Test Author',
        );

        final json = metadata.toJson();
        expect(json['id'], 'test_plugin');
        expect(json['name'], 'Test Plugin');
        expect(json['version'], '1.0.0');
        expect(json['description'], 'A test plugin');
        expect(json['author'], 'Test Author');
      });

      test('应该能够从JSON创建', () {
        final json = <String, Object>{
          'id': 'test_plugin',
          'name': 'Test Plugin',
          'version': '1.0.0',
          'description': 'A test plugin',
          'author': 'Test Author',
          'keywords': <String>['test'],
          'permissions': <String>['file_system'],
          'platforms': <String>['android'],
        };

        final metadata = PublishMetadata.fromJson(json);
        expect(metadata.id, 'test_plugin');
        expect(metadata.name, 'Test Plugin');
        expect(metadata.version, '1.0.0');
        expect(metadata.keywords, <String>['test']);
        expect(metadata.permissions, <String>['file_system']);
        expect(metadata.platforms, <String>['android']);
      });
    });

    group('发布流程测试', () {
      test('应该能够发布插件', () async {
        const config = PublishConfig(
          apiKey: 'test-api-key',
          enableSigning: false,
          enableValidation: false,
        );

        const metadata = PublishMetadata(
          id: 'test_plugin',
          name: 'Test Plugin',
          version: '1.0.0',
          description: 'A test plugin',
          author: 'Test Author',
        );

        final pluginData = Uint8List.fromList(<int>[1, 2, 3, 4, 5]);

        final result = await publisher.publishPlugin(
          pluginId: 'test_plugin',
          metadata: metadata,
          pluginData: pluginData,
          config: config,
        );

        expect(result.success, isTrue);
        expect(result.publishId, isNotNull);
        expect(result.downloadUrl, isNotNull);
        expect(result.version, '1.0.0');
        expect(result.error, isNull);
      });

      test('应该在API密钥缺失时失败', () async {
        const config = PublishConfig(
          
        );

        const metadata = PublishMetadata(
          id: 'test_plugin',
          name: 'Test Plugin',
          version: '1.0.0',
          description: 'A test plugin',
          author: 'Test Author',
        );

        final pluginData = Uint8List.fromList(<int>[1, 2, 3, 4, 5]);

        final result = await publisher.publishPlugin(
          pluginId: 'test_plugin',
          metadata: metadata,
          pluginData: pluginData,
          config: config,
        );

        expect(result.success, isFalse);
        expect(result.error, contains('API密钥未配置'));
      });

      test('应该在元数据无效时失败', () async {
        const config = PublishConfig(
          apiKey: 'test-api-key',
        );

        const metadata = PublishMetadata(
          id: '', // 无效的ID
          name: 'Test Plugin',
          version: '1.0.0',
          description: 'A test plugin',
          author: 'Test Author',
        );

        final pluginData = Uint8List.fromList(<int>[1, 2, 3, 4, 5]);

        final result = await publisher.publishPlugin(
          pluginId: 'test_plugin',
          metadata: metadata,
          pluginData: pluginData,
          config: config,
        );

        expect(result.success, isFalse);
        expect(result.error, contains('插件ID不能为空'));
      });

      test('应该在版本格式无效时失败', () async {
        const config = PublishConfig(
          apiKey: 'test-api-key',
        );

        const metadata = PublishMetadata(
          id: 'test_plugin',
          name: 'Test Plugin',
          version: 'invalid-version', // 无效的版本格式
          description: 'A test plugin',
          author: 'Test Author',
        );

        final pluginData = Uint8List.fromList(<int>[1, 2, 3, 4, 5]);

        final result = await publisher.publishPlugin(
          pluginId: 'test_plugin',
          metadata: metadata,
          pluginData: pluginData,
          config: config,
        );

        expect(result.success, isFalse);
        expect(result.error, contains('插件版本格式无效'));
      });
    });

    group('发布进度测试', () {
      test('应该能够获取发布进度', () async {
        const config = PublishConfig(
          apiKey: 'test-api-key',
          enableSigning: false,
          enableValidation: false,
        );

        const metadata = PublishMetadata(
          id: 'test_plugin',
          name: 'Test Plugin',
          version: '1.0.0',
          description: 'A test plugin',
          author: 'Test Author',
        );

        final pluginData = Uint8List.fromList(<int>[1, 2, 3, 4, 5]);

        // 获取进度流
        final progressStream = publisher.getPublishProgress('test_plugin');
        expect(progressStream, isNull); // 发布前应该为null

        // 开始发布
        final publishFuture = publisher.publishPlugin(
          pluginId: 'test_plugin',
          metadata: metadata,
          pluginData: pluginData,
          config: config,
        );

        // 等待发布完成
        final result = await publishFuture;
        expect(result.success, isTrue);
      });
    });

    group('发布结果测试', () {
      test('应该能够创建成功结果', () {
        final result = PublishResult.success(
          publishId: 'test-publish-id',
          downloadUrl: 'https://example.com/download',
          version: '1.0.0',
          warnings: <String>['test warning'],
        );

        expect(result.success, isTrue);
        expect(result.publishId, 'test-publish-id');
        expect(result.downloadUrl, 'https://example.com/download');
        expect(result.version, '1.0.0');
        expect(result.warnings, <String>['test warning']);
        expect(result.error, isNull);
      });

      test('应该能够创建失败结果', () {
        final result = PublishResult.failure(
          error: 'Test error',
          warnings: <String>['test warning'],
        );

        expect(result.success, isFalse);
        expect(result.error, 'Test error');
        expect(result.warnings, <String>['test warning']);
        expect(result.publishId, isNull);
        expect(result.downloadUrl, isNull);
        expect(result.version, isNull);
      });
    });

    group('发布进度信息测试', () {
      test('应该能够创建发布进度信息', () {
        const progress = PublishProgress(
          status: PublishStatus.uploading,
          progress: 0.5,
          message: 'Uploading...',
          details: <String, dynamic>{'uploaded': 50, 'total': 100},
        );

        expect(progress.status, PublishStatus.uploading);
        expect(progress.progress, 0.5);
        expect(progress.message, 'Uploading...');
        expect(progress.details?['uploaded'], 50);
        expect(progress.details?['total'], 100);
      });
    });
  });
}
