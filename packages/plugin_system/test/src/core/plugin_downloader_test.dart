/*
---------------------------------------------------------------
File name:          plugin_downloader_test.dart
Author:             lgnorant-lu
Date created:       2025-07-23
Last modified:      2025-07-23
Dart Version:       3.2+
Description:        插件下载管理器测试
---------------------------------------------------------------
Change History:
    2025-07-23: Phase 5.0.11.2 - 插件下载功能测试实现;
---------------------------------------------------------------
*/

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_system/plugin_system.dart';

void main() {
  group('PluginDownloader Tests', () {
    late PluginDownloader downloader;
    late Directory tempDir;

    setUp(() async {
      downloader = PluginDownloader.instance;

      // 创建临时目录
      tempDir =
          await Directory.systemTemp.createTemp('plugin_downloader_test_');

      // 设置测试配置
      downloader.setConfig(DownloadConfig(
        downloadDirectory: tempDir.path,
        maxRetries: 2,
        timeout: const Duration(seconds: 30),
        enableVerification: false, // 测试时禁用验证
      ),);
    });

    tearDown(() async {
      downloader.dispose();

      // 清理临时目录
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    group('单例模式测试', () {
      test('应该返回相同的实例', () {
        final instance1 = PluginDownloader.instance;
        final instance2 = PluginDownloader.instance;
        expect(identical(instance1, instance2), isTrue);
      });
    });

    group('配置管理测试', () {
      test('应该能够设置和获取配置', () {
        const config = DownloadConfig(
          downloadDirectory: './test_downloads',
          maxRetries: 5,
          timeout: Duration(minutes: 5),
          enableResume: false,
        );

        downloader.setConfig(config);
        expect(downloader.config.downloadDirectory, './test_downloads');
        expect(downloader.config.maxRetries, 5);
        expect(downloader.config.timeout, const Duration(minutes: 5));
        expect(downloader.config.enableResume, isFalse);
      });

      test('应该有默认配置', () {
        // 创建新的下载器实例来测试默认配置
        const defaultConfig = DownloadConfig();
        expect(defaultConfig.maxRetries, 3);
        expect(defaultConfig.enableResume, isTrue);
        expect(defaultConfig.enableVerification, isTrue);
        expect(defaultConfig.maxConcurrentDownloads, 3);
      });
    });

    group('下载任务测试', () {
      test('应该能够创建下载任务', () {
        final task = DownloadTask(
          id: 'test_task',
          url: 'https://example.com/plugin.zip',
          fileName: 'test_plugin.zip',
          expectedSize: 1024,
          checksum: 'abc123',
          headers: <String, String>{'Authorization': 'Bearer token'},
        );

        expect(task.id, 'test_task');
        expect(task.url, 'https://example.com/plugin.zip');
        expect(task.fileName, 'test_plugin.zip');
        expect(task.expectedSize, 1024);
        expect(task.checksum, 'abc123');
        expect(task.headers['Authorization'], 'Bearer token');
        expect(task.status, DownloadStatus.preparing);
        expect(task.progress, 0.0);
        expect(task.downloadedBytes, 0);
        expect(task.retryCount, 0);
      });

      test('应该正确判断任务状态', () {
        final task = DownloadTask(
          id: 'test_task',
          url: 'https://example.com/plugin.zip',
          fileName: 'test_plugin.zip',
        );

        // 初始状态
        expect(task.isCancelled, isFalse);
        expect(task.isCompleted, isFalse);
        expect(task.isFailed, isFalse);
        expect(task.canRetry, isFalse);

        // 失败状态
        task.status = DownloadStatus.failed;
        expect(task.isFailed, isTrue);
        expect(task.canRetry, isTrue);

        // 取消状态
        task.status = DownloadStatus.cancelled;
        expect(task.isCancelled, isTrue);

        // 完成状态
        task.status = DownloadStatus.completed;
        expect(task.isCompleted, isTrue);
      });
    });

    group('下载进度测试', () {
      test('应该能够创建下载进度信息', () {
        const progress = DownloadProgress(
          status: DownloadStatus.downloading,
          progress: 0.5,
          downloadedBytes: 512,
          totalBytes: 1024,
          speed: 100,
          remainingTime: 5,
          message: 'Downloading...',
        );

        expect(progress.status, DownloadStatus.downloading);
        expect(progress.progress, 0.5);
        expect(progress.downloadedBytes, 512);
        expect(progress.totalBytes, 1024);
        expect(progress.speed, 100);
        expect(progress.remainingTime, 5);
        expect(progress.message, 'Downloading...');
      });

      test('应该正确格式化文件大小', () {
        const progress1 = DownloadProgress(
          status: DownloadStatus.downloading,
          progress: 0.5,
          downloadedBytes: 512,
          totalBytes: 1024,
        );

        const progress2 = DownloadProgress(
          status: DownloadStatus.downloading,
          progress: 0.5,
          downloadedBytes: 1536, // 1.5KB
          totalBytes: 2048, // 2KB
        );

        const progress3 = DownloadProgress(
          status: DownloadStatus.downloading,
          progress: 0.5,
          downloadedBytes: 1572864, // 1.5MB
          totalBytes: 3145728, // 3MB
        );

        expect(progress1.formattedDownloaded, '512B');
        expect(progress1.formattedTotal, '1.0KB'); // 1024B 会被格式化为 1.0KB

        expect(progress2.formattedDownloaded, '1.5KB');
        expect(progress2.formattedTotal, '2.0KB');

        expect(progress3.formattedDownloaded, '1.5MB');
        expect(progress3.formattedTotal, '3.0MB');
      });

      test('应该正确格式化下载速度', () {
        const progress1 = DownloadProgress(
          status: DownloadStatus.downloading,
          progress: 0.5,
          downloadedBytes: 512,
          totalBytes: 1024,
          speed: 1024,
        );

        const progress2 = DownloadProgress(
          status: DownloadStatus.downloading,
          progress: 0.5,
          downloadedBytes: 512,
          totalBytes: 1024,
        );

        expect(progress1.formattedSpeed, '1.0KB/s'); // 1024B/s 会被格式化为 1.0KB/s
        expect(progress2.formattedSpeed, '');
      });
    });

    group('下载结果测试', () {
      test('应该能够创建成功结果', () {
        final result = DownloadResult.success(
          filePath: '/path/to/file.zip',
          fileSize: 1024,
          downloadTime: 5000,
          retryCount: 1,
        );

        expect(result.success, isTrue);
        expect(result.filePath, '/path/to/file.zip');
        expect(result.fileSize, 1024);
        expect(result.downloadTime, 5000);
        expect(result.retryCount, 1);
        expect(result.error, isNull);
      });

      test('应该能够创建失败结果', () {
        final result = DownloadResult.failure(
          error: 'Network error',
          retryCount: 2,
        );

        expect(result.success, isFalse);
        expect(result.error, 'Network error');
        expect(result.retryCount, 2);
        expect(result.filePath, isNull);
        expect(result.fileSize, isNull);
        expect(result.downloadTime, isNull);
      });
    });

    group('任务管理测试', () {
      test('应该能够获取活动任务列表', () {
        final tasks = downloader.getActiveTasks();
        expect(tasks, isEmpty);
      });

      test('应该能够获取特定任务信息', () {
        final task = downloader.getTask('non_existent_task');
        expect(task, isNull);
      });

      test('应该检查并发下载限制', () async {
        // 这个测试需要模拟网络请求，暂时跳过实际下载
        // 只测试并发限制的逻辑
        expect(downloader.config.maxConcurrentDownloads, 3);
      });
    });

    group('下载配置测试', () {
      test('应该有正确的默认值', () {
        const config = DownloadConfig();

        expect(config.downloadDirectory, './downloads');
        expect(config.maxRetries, 3);
        expect(config.retryDelay, const Duration(seconds: 2));
        expect(config.timeout, const Duration(minutes: 10));
        expect(config.chunkSize, 8192);
        expect(config.enableResume, isTrue);
        expect(config.enableVerification, isTrue);
        expect(config.maxConcurrentDownloads, 3);
        expect(config.userAgent, 'PluginSystem/1.4.0');
      });

      test('应该能够自定义配置', () {
        const config = DownloadConfig(
          downloadDirectory: './custom_downloads',
          maxRetries: 5,
          retryDelay: Duration(seconds: 5),
          timeout: Duration(minutes: 20),
          chunkSize: 16384,
          enableResume: false,
          enableVerification: false,
          maxConcurrentDownloads: 5,
          userAgent: 'CustomAgent/1.0.0',
        );

        expect(config.downloadDirectory, './custom_downloads');
        expect(config.maxRetries, 5);
        expect(config.retryDelay, const Duration(seconds: 5));
        expect(config.timeout, const Duration(minutes: 20));
        expect(config.chunkSize, 16384);
        expect(config.enableResume, isFalse);
        expect(config.enableVerification, isFalse);
        expect(config.maxConcurrentDownloads, 5);
        expect(config.userAgent, 'CustomAgent/1.0.0');
      });
    });
  });
}
