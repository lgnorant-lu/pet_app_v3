/*
---------------------------------------------------------------
File name:          plugin_downloader.dart
Author:             lgnorant-lu
Date created:       2025-07-23
Last modified:      2025-07-23
Dart Version:       3.2+
Description:        插件下载管理器 - Phase 5.0.11.2 插件下载功能
---------------------------------------------------------------
Change History:
    2025-07-23: Phase 5.0.11.2 - 插件下载功能实现;
---------------------------------------------------------------
*/

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import 'package:plugin_system/src/core/plugin_security.dart';
import 'package:plugin_system/src/core/plugin_signature.dart';

/// 下载状态
enum DownloadStatus {
  /// 准备中
  preparing,

  /// 下载中
  downloading,

  /// 验证中
  verifying,

  /// 已完成
  completed,

  /// 已暂停
  paused,

  /// 失败
  failed,

  /// 已取消
  cancelled,
}

/// 下载结果
class DownloadResult {
  const DownloadResult({
    required this.success,
    this.filePath,
    this.fileSize,
    this.downloadTime,
    this.error,
    this.retryCount = 0,
  });

  /// 创建成功结果
  factory DownloadResult.success({
    required String filePath,
    required int fileSize,
    required int downloadTime,
    int retryCount = 0,
  }) =>
      DownloadResult(
        success: true,
        filePath: filePath,
        fileSize: fileSize,
        downloadTime: downloadTime,
        retryCount: retryCount,
      );

  /// 创建失败结果
  factory DownloadResult.failure({
    required String error,
    int retryCount = 0,
  }) =>
      DownloadResult(
        success: false,
        error: error,
        retryCount: retryCount,
      );

  /// 是否成功
  final bool success;

  /// 下载文件路径
  final String? filePath;

  /// 文件大小（字节）
  final int? fileSize;

  /// 下载耗时（毫秒）
  final int? downloadTime;

  /// 错误信息
  final String? error;

  /// 重试次数
  final int retryCount;
}

/// 下载进度信息
class DownloadProgress {
  const DownloadProgress({
    required this.status,
    required this.progress,
    required this.downloadedBytes,
    required this.totalBytes,
    this.speed,
    this.remainingTime,
    this.message,
  });

  /// 当前状态
  final DownloadStatus status;

  /// 进度百分比 (0.0 - 1.0)
  final double progress;

  /// 已下载字节数
  final int downloadedBytes;

  /// 总字节数
  final int totalBytes;

  /// 下载速度（字节/秒）
  final int? speed;

  /// 剩余时间（秒）
  final int? remainingTime;

  /// 状态消息
  final String? message;

  /// 格式化文件大小
  String get formattedDownloaded => _formatBytes(downloadedBytes);
  String get formattedTotal => _formatBytes(totalBytes);
  String get formattedSpeed => speed != null ? '${_formatBytes(speed!)}/s' : '';

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
}

/// 下载配置
class DownloadConfig {
  const DownloadConfig({
    this.downloadDirectory = './downloads',
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 2),
    this.timeout = const Duration(minutes: 10),
    this.chunkSize = 8192,
    this.enableResume = true,
    this.enableVerification = true,
    this.enableSignatureVerification = true,
    this.enableSecurityValidation = true,
    this.securityPolicy = PluginSecurityPolicy.standard,
    this.maxConcurrentDownloads = 3,
    this.userAgent = 'PluginSystem/1.4.0',
  });

  /// 下载目录
  final String downloadDirectory;

  /// 最大重试次数
  final int maxRetries;

  /// 重试延迟
  final Duration retryDelay;

  /// 超时时间
  final Duration timeout;

  /// 分块大小
  final int chunkSize;

  /// 是否启用断点续传
  final bool enableResume;

  /// 是否启用文件验证
  final bool enableVerification;

  /// 是否启用数字签名验证
  final bool enableSignatureVerification;

  /// 是否启用安全验证
  final bool enableSecurityValidation;

  /// 安全策略
  final PluginSecurityPolicy securityPolicy;

  /// 最大并发下载数
  final int maxConcurrentDownloads;

  /// 用户代理
  final String userAgent;
}

/// 下载任务
class DownloadTask {
  DownloadTask({
    required this.id,
    required this.url,
    required this.fileName,
    this.expectedSize,
    this.checksum,
    this.headers = const <String, String>{},
  });

  /// 任务ID
  final String id;

  /// 下载URL
  final String url;

  /// 文件名
  final String fileName;

  /// 预期文件大小
  final int? expectedSize;

  /// 文件校验和
  final String? checksum;

  /// 请求头
  final Map<String, String> headers;

  /// 任务状态
  DownloadStatus status = DownloadStatus.preparing;

  /// 下载进度
  double progress = 0;

  /// 已下载字节数
  int downloadedBytes = 0;

  /// 总字节数
  int totalBytes = 0;

  /// 重试次数
  int retryCount = 0;

  /// 错误信息
  String? error;

  /// 开始时间
  DateTime? startTime;

  /// 完成时间
  DateTime? completedTime;

  /// 文件路径
  String? filePath;

  /// 是否已取消
  bool get isCancelled => status == DownloadStatus.cancelled;

  /// 是否已完成
  bool get isCompleted => status == DownloadStatus.completed;

  /// 是否失败
  bool get isFailed => status == DownloadStatus.failed;

  /// 是否可以重试
  bool get canRetry => isFailed && retryCount < 3;
}

/// 插件下载管理器
///
/// 负责插件的下载功能，包括进度显示、断点续传、失败重试等
class PluginDownloader {
  PluginDownloader._();
  static final PluginDownloader _instance = PluginDownloader._();
  static PluginDownloader get instance => _instance;

  /// 下载配置
  DownloadConfig _config = const DownloadConfig();

  /// 活动下载任务
  final Map<String, DownloadTask> _activeTasks = <String, DownloadTask>{};

  /// 进度控制器
  final Map<String, StreamController<DownloadProgress>> _progressControllers =
      <String, StreamController<DownloadProgress>>{};

  /// HTTP客户端
  final http.Client _httpClient = http.Client();

  /// 并发下载计数
  int _concurrentDownloads = 0;

  /// 设置下载配置
  void setConfig(DownloadConfig config) {
    _config = config;
  }

  /// 获取当前配置
  DownloadConfig get config => _config;

  /// 下载插件
  ///
  /// [taskId] 任务ID
  /// [url] 下载URL
  /// [fileName] 文件名
  /// [expectedSize] 预期文件大小
  /// [checksum] 文件校验和
  /// [headers] 请求头
  Future<DownloadResult> downloadPlugin({
    required String taskId,
    required String url,
    required String fileName,
    int? expectedSize,
    String? checksum,
    Map<String, String> headers = const <String, String>{},
  }) async {
    // 检查并发下载限制
    if (_concurrentDownloads >= _config.maxConcurrentDownloads) {
      return DownloadResult.failure(
        error: '已达到最大并发下载数限制 (${_config.maxConcurrentDownloads})',
      );
    }

    // 创建下载任务
    final task = DownloadTask(
      id: taskId,
      url: url,
      fileName: fileName,
      expectedSize: expectedSize,
      checksum: checksum,
      headers: headers,
    );

    _activeTasks[taskId] = task;
    _concurrentDownloads++;

    try {
      return await _executeDownload(task);
    } finally {
      _activeTasks.remove(taskId);
      _concurrentDownloads--;
    }
  }

  /// 获取下载进度流
  Stream<DownloadProgress>? getDownloadProgress(String taskId) =>
      _progressControllers[taskId]?.stream;

  /// 暂停下载
  Future<bool> pauseDownload(String taskId) async {
    final task = _activeTasks[taskId];
    if (task != null && task.status == DownloadStatus.downloading) {
      task.status = DownloadStatus.paused;
      return true;
    }
    return false;
  }

  /// 恢复下载
  Future<bool> resumeDownload(String taskId) async {
    final task = _activeTasks[taskId];
    if (task != null && task.status == DownloadStatus.paused) {
      task.status = DownloadStatus.downloading;
      return true;
    }
    return false;
  }

  /// 取消下载
  Future<bool> cancelDownload(String taskId) async {
    final task = _activeTasks[taskId];
    if (task != null && !task.isCompleted) {
      task.status = DownloadStatus.cancelled;

      // 清理临时文件
      if (task.filePath != null) {
        final file = File(task.filePath!);
        if (await file.exists()) {
          await file.delete();
        }
      }

      return true;
    }
    return false;
  }

  /// 重试下载
  Future<DownloadResult> retryDownload(String taskId) async {
    final task = _activeTasks[taskId];
    if (task == null || !task.canRetry) {
      return DownloadResult.failure(
        error: '任务不存在或无法重试',
      );
    }

    task.retryCount++;
    task.status = DownloadStatus.preparing;
    task.error = null;

    return _executeDownload(task);
  }

  /// 获取活动任务列表
  List<DownloadTask> getActiveTasks() => _activeTasks.values.toList();

  /// 获取任务信息
  DownloadTask? getTask(String taskId) => _activeTasks[taskId];

  /// 执行下载
  Future<DownloadResult> _executeDownload(DownloadTask task) async {
    final progressController = StreamController<DownloadProgress>.broadcast();
    _progressControllers[task.id] = progressController;

    try {
      task.startTime = DateTime.now();

      // 阶段1: 准备下载
      task.status = DownloadStatus.preparing;
      progressController.add(
        DownloadProgress(
          status: DownloadStatus.preparing,
          progress: 0,
          downloadedBytes: 0,
          totalBytes: task.expectedSize ?? 0,
          message: '准备下载...',
        ),
      );

      // 创建下载目录
      await _ensureDownloadDirectory();

      // 构建文件路径
      task.filePath = path.join(_config.downloadDirectory, task.fileName);

      // 检查断点续传
      int resumeFrom = 0;
      if (_config.enableResume && await File(task.filePath!).exists()) {
        resumeFrom = await File(task.filePath!).length();
        task.downloadedBytes = resumeFrom;
      }

      // 阶段2: 开始下载
      task.status = DownloadStatus.downloading;

      int retryCount = 0;
      while (retryCount <= _config.maxRetries) {
        try {
          await _performDownload(task, progressController, resumeFrom);

          // 阶段3: 验证文件
          if (_config.enableVerification && task.checksum != null) {
            task.status = DownloadStatus.verifying;
            progressController.add(
              DownloadProgress(
                status: DownloadStatus.verifying,
                progress: 1,
                downloadedBytes: task.downloadedBytes,
                totalBytes: task.totalBytes,
                message: '验证文件完整性...',
              ),
            );

            final isValid = await _verifyFile(task.filePath!, task.checksum!);
            if (!isValid) {
              throw Exception('文件校验失败');
            }
          }

          // 下载完成
          task.status = DownloadStatus.completed;
          task.completedTime = DateTime.now();

          final downloadTime =
              task.completedTime!.difference(task.startTime!).inMilliseconds;

          progressController.add(
            DownloadProgress(
              status: DownloadStatus.completed,
              progress: 1,
              downloadedBytes: task.downloadedBytes,
              totalBytes: task.totalBytes,
              message: '下载完成',
            ),
          );

          return DownloadResult.success(
            filePath: task.filePath!,
            fileSize: task.downloadedBytes,
            downloadTime: downloadTime,
            retryCount: retryCount,
          );
        } catch (e) {
          retryCount++;
          task.error = e.toString();

          if (retryCount <= _config.maxRetries) {
            debugPrint('下载失败，准备重试 ($retryCount/${_config.maxRetries}): $e');
            await Future<void>.delayed(_config.retryDelay);
          } else {
            task.status = DownloadStatus.failed;
            progressController.add(
              DownloadProgress(
                status: DownloadStatus.failed,
                progress: task.progress,
                downloadedBytes: task.downloadedBytes,
                totalBytes: task.totalBytes,
                message: '下载失败: $e',
              ),
            );

            return DownloadResult.failure(
              error: '下载失败: $e',
              retryCount: retryCount - 1,
            );
          }
        }
      }

      return DownloadResult.failure(
        error: '下载失败: 超过最大重试次数',
        retryCount: _config.maxRetries,
      );
    } finally {
      // 清理进度控制器
      await progressController.close();
      _progressControllers.remove(task.id);
    }
  }

  /// 执行实际下载
  Future<void> _performDownload(
    DownloadTask task,
    StreamController<DownloadProgress> progressController,
    int resumeFrom,
  ) async {
    // 构建请求头
    final headers = Map<String, String>.from(task.headers);
    headers['User-Agent'] = _config.userAgent;

    if (resumeFrom > 0) {
      headers['Range'] = 'bytes=$resumeFrom-';
    }

    // 发送请求
    final request = http.Request('GET', Uri.parse(task.url));
    request.headers.addAll(headers);

    final response = await _httpClient.send(request).timeout(_config.timeout);

    if (response.statusCode != 200 && response.statusCode != 206) {
      throw Exception('HTTP错误: ${response.statusCode}');
    }

    // 获取文件大小
    final contentLength = response.contentLength;
    if (contentLength != null) {
      task.totalBytes = resumeFrom + contentLength;
    } else if (task.expectedSize != null) {
      task.totalBytes = task.expectedSize!;
    }

    // 打开文件写入
    final file = File(task.filePath!);
    final sink =
        file.openWrite(mode: resumeFrom > 0 ? FileMode.append : FileMode.write);

    try {
      final startTime = DateTime.now();
      int lastProgressUpdate = 0;

      await for (final List<int> chunk in response.stream) {
        // 检查是否已取消
        if (task.isCancelled) {
          throw Exception('下载已取消');
        }

        // 检查是否已暂停
        while (task.status == DownloadStatus.paused) {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          if (task.isCancelled) {
            throw Exception('下载已取消');
          }
        }

        // 写入数据
        sink.add(chunk);
        task.downloadedBytes += chunk.length;

        // 更新进度
        if (task.totalBytes > 0) {
          task.progress = task.downloadedBytes / task.totalBytes;
        }

        // 限制进度更新频率（每100ms更新一次）
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now - lastProgressUpdate > 100) {
          lastProgressUpdate = now;

          // 计算下载速度
          final elapsed = DateTime.now().difference(startTime).inSeconds;
          final speed = elapsed > 0 ? task.downloadedBytes ~/ elapsed : 0;

          // 计算剩余时间
          int? remainingTime;
          if (speed > 0 && task.totalBytes > 0) {
            final remainingBytes = task.totalBytes - task.downloadedBytes;
            remainingTime = remainingBytes ~/ speed;
          }

          progressController.add(
            DownloadProgress(
              status: DownloadStatus.downloading,
              progress: task.progress,
              downloadedBytes: task.downloadedBytes,
              totalBytes: task.totalBytes,
              speed: speed,
              remainingTime: remainingTime,
              message: '下载中...',
            ),
          );
        }
      }
    } finally {
      await sink.close();
    }
  }

  /// 确保下载目录存在
  Future<void> _ensureDownloadDirectory() async {
    final directory = Directory(_config.downloadDirectory);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
  }

  /// 验证文件 (集成Ming CLI数字签名验证)
  Future<bool> _verifyFile(String filePath, String expectedChecksum) async {
    try {
      // 读取文件数据
      final File file = File(filePath);
      if (!await file.exists()) {
        debugPrint('验证失败: 文件不存在 $filePath');
        return false;
      }

      final Uint8List fileData = await file.readAsBytes();

      // 1. 校验和验证
      final Digest actualHash = sha256.convert(fileData);
      final String actualChecksum = actualHash.toString();

      if (actualChecksum != expectedChecksum) {
        debugPrint('校验和验证失败: 期望 $expectedChecksum, 实际 $actualChecksum');
        return false;
      }

      // 2. 数字签名验证 (如果启用)
      if (_config.enableSignatureVerification) {
        final PluginSignature signature = PluginSignature.instance;
        final PluginSignatureVerificationResult verificationResult =
            await signature.verifyPluginSignature(filePath, fileData);

        if (!verificationResult.isValid) {
          debugPrint('数字签名验证失败: ${verificationResult.errors.join(', ')}');
          return false;
        }

        if (verificationResult.warnings.isNotEmpty) {
          debugPrint('签名验证警告: ${verificationResult.warnings.join(', ')}');
        }

        debugPrint('数字签名验证成功: ${verificationResult.signatures.length} 个签名');
      }

      // 3. 安全验证 (如果启用)
      if (_config.enableSecurityValidation) {
        final PluginSecurityValidator securityValidator =
            PluginSecurityValidator(
          policy: _config.securityPolicy,
        );

        final PluginSecurityValidationResult securityResult =
            await securityValidator.validatePluginSecurity(filePath, fileData);

        if (!securityResult.isValid) {
          debugPrint('安全验证失败: 安全等级 ${securityResult.securityLevel.name}');
          debugPrint(
              '安全问题: ${securityResult.securityIssues.map((issue) => issue.title).join(', ')}');
          return false;
        }

        if (securityResult.hasSecurityIssues) {
          debugPrint(
              '安全验证警告: 发现 ${securityResult.securityIssues.length} 个安全问题');
          for (final issue in securityResult.securityIssues) {
            debugPrint('  - ${issue.title}: ${issue.description}');
          }
        }

        debugPrint('安全验证成功: 安全等级 ${securityResult.securityLevel.name}');
      }

      debugPrint('文件验证成功: $filePath');
      return true;
    } catch (e) {
      debugPrint('文件验证异常: $e');
      return false;
    }
  }

  /// 清理资源
  void dispose() {
    for (final controller in _progressControllers.values) {
      controller.close();
    }
    _progressControllers.clear();
    _httpClient.close();
  }
}
