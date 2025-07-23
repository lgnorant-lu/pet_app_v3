/*
---------------------------------------------------------------
File name:          plugin_security.dart
Author:             lgnorant-lu
Date created:       2025-07-23
Last modified:      2025-07-23
Dart Version:       3.2+
Description:        插件安全验证系统 - 集成Ming CLI的安全验证功能
---------------------------------------------------------------
Change History:
    2025-07-23: Task 1.2.2 - 完善安全验证流程;
---------------------------------------------------------------
*/

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import 'package:plugin_system/src/core/plugin_signature.dart';

/// 安全等级枚举 (集成Ming CLI功能)
enum PluginSecurityLevel {
  /// 安全 - 通过所有检查
  safe,

  /// 警告 - 有轻微安全问题
  warning,

  /// 危险 - 有严重安全问题
  dangerous,

  /// 阻止 - 禁止使用
  blocked,
}

/// 安全策略枚举 (集成Ming CLI功能)
enum PluginSecurityPolicy {
  /// 企业级 - 最严格的安全策略
  enterprise,

  /// 标准 - 平衡安全性和可用性
  standard,

  /// 宽松 - 较为宽松的安全策略
  relaxed,
}

/// 验证步骤枚举 (集成Ming CLI功能)
enum PluginValidationStep {
  /// 数字签名验证
  signatureVerification,

  /// 可信源验证
  trustedSourceVerification,

  /// 恶意代码检测
  malwareDetection,

  /// 安全策略检查
  policyCheck,
}

/// 威胁类型枚举 (集成Ming CLI功能)
enum PluginThreatType {
  /// 恶意代码
  malware,

  /// 可疑行为
  suspiciousBehavior,

  /// 数据泄露
  dataLeak,

  /// 权限滥用
  privilegeEscalation,

  /// 网络攻击
  networkAttack,

  /// 文件系统攻击
  fileSystemAttack,
}

/// 威胁等级枚举 (集成Ming CLI功能)
enum PluginThreatLevel {
  /// 低风险
  low,

  /// 中等风险
  medium,

  /// 高风险
  high,

  /// 严重风险
  critical,
}

/// 安全问题 (集成Ming CLI功能)
@immutable
class PluginSecurityIssue {
  const PluginSecurityIssue({
    required this.id,
    required this.title,
    required this.description,
    required this.threatType,
    required this.severity,
    required this.confidence,
    this.filePath,
    this.references = const <String>[],
    this.suggestions = const <String>[],
  });

  /// 问题ID
  final String id;

  /// 问题标题
  final String title;

  /// 问题描述
  final String description;

  /// 威胁类型
  final PluginThreatType threatType;

  /// 严重程度
  final PluginThreatLevel severity;

  /// 置信度 (0-100)
  final int confidence;

  /// 文件路径
  final String? filePath;

  /// 参考链接
  final List<String> references;

  /// 修复建议
  final List<String> suggestions;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PluginSecurityIssue &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// 安全事件 (集成Ming CLI功能)
@immutable
class PluginSecurityEvent {
  const PluginSecurityEvent({
    required this.id,
    required this.eventType,
    required this.description,
    required this.securityLevel,
    required this.timestamp,
    this.filePath,
    this.sourceUrl,
    this.metadata = const <String, dynamic>{},
  });

  /// 事件ID
  final String id;

  /// 事件类型
  final String eventType;

  /// 事件描述
  final String description;

  /// 安全等级
  final PluginSecurityLevel securityLevel;

  /// 事件时间
  final DateTime timestamp;

  /// 文件路径
  final String? filePath;

  /// 源URL
  final String? sourceUrl;

  /// 元数据
  final Map<String, dynamic> metadata;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PluginSecurityEvent &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// 安全审计日志 (集成Ming CLI功能)
@immutable
class PluginSecurityAuditLog {
  const PluginSecurityAuditLog({
    required this.id,
    required this.operation,
    required this.success,
    required this.timestamp,
    required this.details,
    this.userId,
    this.resourcePath,
  });

  /// 日志ID
  final String id;

  /// 操作类型
  final String operation;

  /// 操作结果
  final bool success;

  /// 用户ID
  final String? userId;

  /// 资源路径
  final String? resourcePath;

  /// 操作时间
  final DateTime timestamp;

  /// 详细信息
  final Map<String, dynamic> details;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PluginSecurityAuditLog &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// 恶意代码检测结果 (集成Ming CLI功能)
@immutable
class PluginMalwareDetectionResult {
  const PluginMalwareDetectionResult({
    required this.hasThreat,
    required this.threatTypes,
    required this.issues,
    required this.scanDuration,
    required this.scannedAt,
    this.isHighRisk = false,
  });

  /// 是否有威胁
  final bool hasThreat;

  /// 威胁类型列表
  final Set<PluginThreatType> threatTypes;

  /// 安全问题列表
  final List<PluginSecurityIssue> issues;

  /// 扫描耗时
  final Duration scanDuration;

  /// 扫描时间
  final DateTime scannedAt;

  /// 是否高风险
  final bool isHighRisk;

  /// 创建安全结果
  factory PluginMalwareDetectionResult.safe() => PluginMalwareDetectionResult(
        hasThreat: false,
        threatTypes: const <PluginThreatType>{},
        issues: const <PluginSecurityIssue>[],
        scanDuration: Duration.zero,
        scannedAt: DateTime.now(),
      );

  /// 创建威胁结果
  factory PluginMalwareDetectionResult.threat({
    required Set<PluginThreatType> threatTypes,
    required List<PluginSecurityIssue> issues,
    required Duration scanDuration,
    bool isHighRisk = false,
  }) =>
      PluginMalwareDetectionResult(
        hasThreat: true,
        threatTypes: threatTypes,
        issues: issues,
        scanDuration: scanDuration,
        scannedAt: DateTime.now(),
        isHighRisk: isHighRisk,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PluginMalwareDetectionResult &&
          runtimeType == other.runtimeType &&
          hasThreat == other.hasThreat &&
          setEquals(threatTypes, other.threatTypes);

  @override
  int get hashCode => hasThreat.hashCode ^ threatTypes.hashCode;
}

/// 安全验证结果 (集成Ming CLI功能)
@immutable
class PluginSecurityValidationResult {
  const PluginSecurityValidationResult({
    required this.securityLevel,
    required this.isValid,
    required this.stepResults,
    required this.securityIssues,
    required this.validatedAt,
    required this.validationDuration,
    required this.policy,
    required this.validatorVersion,
    this.signatureResult,
    this.trustedSourceResult,
    this.malwareResult,
    this.metadata = const <String, dynamic>{},
  });

  /// 安全等级
  final PluginSecurityLevel securityLevel;

  /// 是否验证通过
  final bool isValid;

  /// 各步骤验证结果
  final Map<PluginValidationStep, bool> stepResults;

  /// 签名验证结果
  final PluginSignatureVerificationResult? signatureResult;

  /// 可信源验证结果
  final bool? trustedSourceResult;

  /// 恶意代码检测结果
  final PluginMalwareDetectionResult? malwareResult;

  /// 安全问题列表
  final List<PluginSecurityIssue> securityIssues;

  /// 验证时间
  final DateTime validatedAt;

  /// 验证耗时
  final Duration validationDuration;

  /// 安全策略
  final PluginSecurityPolicy policy;

  /// 验证器版本
  final String validatorVersion;

  /// 元数据
  final Map<String, dynamic> metadata;

  /// 是否有安全问题
  bool get hasSecurityIssues => securityIssues.isNotEmpty;

  /// 是否有高风险问题
  bool get hasHighRiskIssues => securityIssues.any(
        (PluginSecurityIssue issue) =>
            issue.severity == PluginThreatLevel.high ||
            issue.severity == PluginThreatLevel.critical,
      );

  /// 创建成功结果
  factory PluginSecurityValidationResult.success({
    required PluginSecurityPolicy policy,
    Map<PluginValidationStep, bool> stepResults =
        const <PluginValidationStep, bool>{},
    List<PluginSecurityIssue> securityIssues = const <PluginSecurityIssue>[],
    Duration? validationDuration,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) =>
      PluginSecurityValidationResult(
        securityLevel: PluginSecurityLevel.safe,
        isValid: true,
        stepResults: stepResults,
        securityIssues: securityIssues,
        validatedAt: DateTime.now(),
        validationDuration: validationDuration ?? Duration.zero,
        policy: policy,
        validatorVersion: '1.4.0',
        metadata: metadata,
      );

  /// 创建失败结果
  factory PluginSecurityValidationResult.failure({
    required PluginSecurityLevel securityLevel,
    required PluginSecurityPolicy policy,
    required List<PluginSecurityIssue> securityIssues,
    Map<PluginValidationStep, bool> stepResults =
        const <PluginValidationStep, bool>{},
    Duration? validationDuration,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) =>
      PluginSecurityValidationResult(
        securityLevel: securityLevel,
        isValid: false,
        stepResults: stepResults,
        securityIssues: securityIssues,
        validatedAt: DateTime.now(),
        validationDuration: validationDuration ?? Duration.zero,
        policy: policy,
        validatorVersion: '1.4.0',
        metadata: metadata,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PluginSecurityValidationResult &&
          runtimeType == other.runtimeType &&
          securityLevel == other.securityLevel &&
          isValid == other.isValid;

  @override
  int get hashCode => securityLevel.hashCode ^ isValid.hashCode;
}

/// 插件安全验证器 (集成Ming CLI功能)
///
/// 负责插件的全面安全验证，包括数字签名验证、
/// 可信源验证、恶意代码检测和安全策略检查。
///
/// 版本: v1.4.0 - 集成Ming CLI的安全验证功能
/// 集成来源: Ming CLI SecurityValidator
class PluginSecurityValidator {
  /// 构造函数
  PluginSecurityValidator({
    PluginSecurityPolicy policy = PluginSecurityPolicy.standard,
    PluginSignature? signature,
  })  : _policy = policy,
        _signature = signature ?? PluginSignature.instance {
    _initializeDefaultTrustedSources();
    _initializeAlertThresholds();
  }

  /// 获取单例实例
  static PluginSecurityValidator? _instance;
  static PluginSecurityValidator get instance =>
      _instance ??= PluginSecurityValidator();

  /// 安全策略
  final PluginSecurityPolicy _policy;

  /// 数字签名验证器
  final PluginSignature _signature;

  /// 可信源列表
  final Set<String> _trustedSources = <String>{};

  /// 黑名单源列表
  final Set<String> _blacklistedSources = <String>{};

  /// 安全事件列表
  final List<PluginSecurityEvent> _securityEvents = <PluginSecurityEvent>[];

  /// 审计日志列表
  final List<PluginSecurityAuditLog> _auditLogs = <PluginSecurityAuditLog>[];

  /// 验证统计
  final Map<String, int> _validationStats = <String, int>{};

  /// 告警阈值配置
  final Map<String, int> _alertThresholds = <String, int>{};

  /// 恶意代码特征库
  final Map<String, List<String>> _malwareSignatures = <String, List<String>>{
    'suspicious_imports': <String>[
      'dart:ffi',
      'dart:isolate',
      'dart:mirrors',
      'package:ffi/',
    ],
    'dangerous_functions': <String>[
      'Process.run',
      'Process.start',
      'File.writeAsBytes',
      'Directory.delete',
      'HttpClient',
      'Socket.connect',
    ],
    'suspicious_patterns': <String>[
      r'eval\s*\(',
      r'Function\s*\(',
      r'\.call\s*\(',
      r'dynamic\s+\w+\s*=',
    ],
  };

  /// 验证插件安全性 (集成Ming CLI功能)
  ///
  /// [filePath] 文件路径
  /// [fileData] 文件数据
  /// [sourceUrl] 源URL
  Future<PluginSecurityValidationResult> validatePluginSecurity(
    String filePath,
    Uint8List fileData, {
    String? sourceUrl,
  }) async {
    final DateTime startTime = DateTime.now();
    final Map<PluginValidationStep, bool> stepResults =
        <PluginValidationStep, bool>{};
    final List<PluginSecurityIssue> securityIssues = <PluginSecurityIssue>[];

    try {
      // 记录验证开始
      await _recordAuditLog(
        'plugin_security_validation_start',
        true,
        resourcePath: filePath,
        details: <String, dynamic>{
          'fileSize': fileData.length,
          'sourceUrl': sourceUrl,
          'policy': _policy.name,
        },
      );

      // 步骤1: 数字签名验证
      PluginSignatureVerificationResult? signatureResult;
      try {
        signatureResult = await _signature.verifyPluginSignature(
          filePath,
          fileData,
        );
        stepResults[PluginValidationStep.signatureVerification] =
            signatureResult.isValid;

        if (!signatureResult.isValid &&
            _policy == PluginSecurityPolicy.enterprise) {
          securityIssues.addAll(
            signatureResult.errors.map(
              (String error) => PluginSecurityIssue(
                id: 'signature_error_${DateTime.now().millisecondsSinceEpoch}',
                title: 'Digital Signature Verification Failed',
                description: error,
                threatType: PluginThreatType.suspiciousBehavior,
                severity: PluginThreatLevel.high,
                confidence: 90,
                filePath: filePath,
                suggestions: <String>[
                  'Verify the plugin source',
                  'Check signature validity',
                  'Contact plugin publisher',
                ],
              ),
            ),
          );
        }
      } catch (e) {
        stepResults[PluginValidationStep.signatureVerification] = false;
        await _recordSecurityEvent(
          'signature_verification_error',
          'Signature verification failed: $e',
          PluginSecurityLevel.warning,
          filePath: filePath,
          sourceUrl: sourceUrl,
        );
      }

      // 步骤2: 可信源验证
      bool? trustedSourceResult;
      if (sourceUrl != null) {
        try {
          trustedSourceResult = await _verifyTrustedSource(sourceUrl);
          stepResults[PluginValidationStep.trustedSourceVerification] =
              trustedSourceResult;

          if (!trustedSourceResult) {
            securityIssues.add(
              PluginSecurityIssue(
                id: 'untrusted_source_${DateTime.now().millisecondsSinceEpoch}',
                title: 'Untrusted Source',
                description:
                    'Plugin comes from an untrusted source: $sourceUrl',
                threatType: PluginThreatType.suspiciousBehavior,
                severity: PluginThreatLevel.medium,
                confidence: 80,
                filePath: filePath,
                suggestions: <String>[
                  'Verify source authenticity',
                  'Check source reputation',
                  'Use trusted plugin repositories',
                ],
              ),
            );
          }
        } catch (e) {
          stepResults[PluginValidationStep.trustedSourceVerification] = false;
          await _recordSecurityEvent(
            'trusted_source_verification_error',
            'Trusted source verification failed: $e',
            PluginSecurityLevel.warning,
            filePath: filePath,
            sourceUrl: sourceUrl,
          );
        }
      }

      // 步骤3: 恶意代码检测
      PluginMalwareDetectionResult? malwareResult;
      try {
        malwareResult = await _detectMalware(fileData, filePath);
        stepResults[PluginValidationStep.malwareDetection] =
            !malwareResult.hasThreat;

        if (malwareResult.hasThreat) {
          securityIssues.addAll(malwareResult.issues);

          await _recordSecurityEvent(
            'malware_detected',
            'Malware detected in plugin: ${malwareResult.threatTypes.join(', ')}',
            PluginSecurityLevel.dangerous,
            filePath: filePath,
            sourceUrl: sourceUrl,
          );
        }
      } catch (e) {
        stepResults[PluginValidationStep.malwareDetection] = false;
        await _recordSecurityEvent(
          'malware_detection_error',
          'Malware detection failed: $e',
          PluginSecurityLevel.warning,
          filePath: filePath,
          sourceUrl: sourceUrl,
        );
      }

      // 步骤4: 安全策略检查
      bool policyCheckResult;
      try {
        policyCheckResult = await _performPolicyCheck(
          signatureResult,
          trustedSourceResult,
          malwareResult,
          securityIssues,
        );
        stepResults[PluginValidationStep.policyCheck] = policyCheckResult;
      } catch (e) {
        stepResults[PluginValidationStep.policyCheck] = false;
        await _recordSecurityEvent(
          'policy_check_error',
          'Policy check failed: $e',
          PluginSecurityLevel.warning,
          filePath: filePath,
          sourceUrl: sourceUrl,
        );
      }

      // 确定安全等级
      final PluginSecurityLevel securityLevel = _determineSecurityLevel(
        stepResults,
        securityIssues,
      );

      // 判断是否通过验证
      final bool isValid = _isValidationPassed(securityLevel, stepResults);

      final DateTime endTime = DateTime.now();

      // 更新统计
      _updateValidationStats(securityLevel, isValid);

      // 检查告警阈值
      await _checkAlertThresholds();

      // 记录验证完成
      await _recordAuditLog(
        'plugin_security_validation_complete',
        isValid,
        resourcePath: filePath,
        details: <String, dynamic>{
          'securityLevel': securityLevel.name,
          'stepsCompleted': stepResults.length,
          'issuesFound': securityIssues.length,
          'validationDuration': endTime.difference(startTime).inMilliseconds,
        },
      );

      return PluginSecurityValidationResult(
        securityLevel: securityLevel,
        isValid: isValid,
        stepResults: stepResults,
        signatureResult: signatureResult,
        trustedSourceResult: trustedSourceResult,
        malwareResult: malwareResult,
        securityIssues: securityIssues,
        validatedAt: endTime,
        validationDuration: endTime.difference(startTime),
        policy: _policy,
        validatorVersion: '1.4.0',
        metadata: <String, dynamic>{
          'filePath': filePath,
          'sourceUrl': sourceUrl,
          'fileSize': fileData.length,
          'stepsCompleted': stepResults.length,
        },
      );
    } catch (e) {
      await _recordAuditLog(
        'plugin_security_validation_error',
        false,
        resourcePath: filePath,
        details: <String, dynamic>{
          'error': e.toString(),
          'fileSize': fileData.length,
          'sourceUrl': sourceUrl,
        },
      );

      return PluginSecurityValidationResult.failure(
        securityLevel: PluginSecurityLevel.blocked,
        policy: _policy,
        securityIssues: <PluginSecurityIssue>[
          PluginSecurityIssue(
            id: 'validation_error_${DateTime.now().millisecondsSinceEpoch}',
            title: 'Security Validation Error',
            description: 'Failed to validate plugin security: $e',
            threatType: PluginThreatType.suspiciousBehavior,
            severity: PluginThreatLevel.high,
            confidence: 100,
            filePath: filePath,
          ),
        ],
        validationDuration: DateTime.now().difference(startTime),
      );
    }
  }

  /// 验证可信源 (集成Ming CLI功能)
  Future<bool> _verifyTrustedSource(String sourceUrl) async {
    // 检查黑名单
    if (_blacklistedSources
        .any((String source) => sourceUrl.contains(source))) {
      return false;
    }

    // 检查可信源列表
    if (_trustedSources.any((String source) => sourceUrl.contains(source))) {
      return true;
    }

    // 默认策略：未知源根据安全策略决定
    switch (_policy) {
      case PluginSecurityPolicy.enterprise:
        return false; // 企业级策略：只允许可信源
      case PluginSecurityPolicy.standard:
        return false; // 标准策略：默认不信任未知源
      case PluginSecurityPolicy.relaxed:
        return true; // 宽松策略：允许未知源
    }
  }

  /// 检测恶意代码 (集成Ming CLI功能)
  Future<PluginMalwareDetectionResult> _detectMalware(
    Uint8List fileData,
    String? filePath,
  ) async {
    final DateTime startTime = DateTime.now();
    final List<PluginSecurityIssue> issues = <PluginSecurityIssue>[];
    final Set<PluginThreatType> threatTypes = <PluginThreatType>{};

    try {
      final String content = String.fromCharCodes(fileData);

      // 静态代码分析
      await _performStaticAnalysis(content, filePath, issues, threatTypes);

      // 启发式检测
      await _performHeuristicDetection(content, filePath, issues, threatTypes);

      // 文件大小检查
      if (fileData.length > 50 * 1024 * 1024) {
        // 超过50MB的插件可能有问题
        issues.add(
          PluginSecurityIssue(
            id: 'large_file_${DateTime.now().millisecondsSinceEpoch}',
            title: 'Unusually Large Plugin File',
            description:
                'Plugin file size (${fileData.length} bytes) is unusually large',
            threatType: PluginThreatType.suspiciousBehavior,
            severity: PluginThreatLevel.medium,
            confidence: 70,
            filePath: filePath,
            suggestions: <String>[
              'Verify plugin contents',
              'Check for embedded resources',
              'Consider file size optimization',
            ],
          ),
        );
        threatTypes.add(PluginThreatType.suspiciousBehavior);
      }

      final Duration scanDuration = DateTime.now().difference(startTime);
      final bool isHighRisk = issues.any(
        (PluginSecurityIssue issue) =>
            issue.severity == PluginThreatLevel.high ||
            issue.severity == PluginThreatLevel.critical,
      );

      if (issues.isEmpty) {
        return PluginMalwareDetectionResult.safe();
      } else {
        return PluginMalwareDetectionResult.threat(
          threatTypes: threatTypes,
          issues: issues,
          scanDuration: scanDuration,
          isHighRisk: isHighRisk,
        );
      }
    } catch (e) {
      return PluginMalwareDetectionResult.threat(
        threatTypes: <PluginThreatType>{PluginThreatType.suspiciousBehavior},
        issues: <PluginSecurityIssue>[
          PluginSecurityIssue(
            id: 'malware_scan_error_${DateTime.now().millisecondsSinceEpoch}',
            title: 'Malware Scan Error',
            description: 'Failed to scan plugin for malware: $e',
            threatType: PluginThreatType.suspiciousBehavior,
            severity: PluginThreatLevel.medium,
            confidence: 50,
            filePath: filePath,
          ),
        ],
        scanDuration: DateTime.now().difference(startTime),
      );
    }
  }

  /// 执行静态代码分析 (集成Ming CLI功能)
  Future<void> _performStaticAnalysis(
    String content,
    String? filePath,
    List<PluginSecurityIssue> issues,
    Set<PluginThreatType> threatTypes,
  ) async {
    // 检查可疑导入
    for (final String suspiciousImport
        in _malwareSignatures['suspicious_imports']!) {
      if (content.contains(suspiciousImport)) {
        issues.add(
          PluginSecurityIssue(
            id: 'suspicious_import_${DateTime.now().millisecondsSinceEpoch}',
            title: 'Suspicious Import Detected',
            description:
                'Found potentially dangerous import: $suspiciousImport',
            threatType: PluginThreatType.suspiciousBehavior,
            severity: PluginThreatLevel.medium,
            confidence: 80,
            filePath: filePath,
            suggestions: <String>[
              'Review import usage',
              'Verify necessity of this import',
              'Check for alternative implementations',
            ],
          ),
        );
        threatTypes.add(PluginThreatType.suspiciousBehavior);
      }
    }

    // 检查危险函数调用
    for (final String dangerousFunction
        in _malwareSignatures['dangerous_functions']!) {
      if (content.contains(dangerousFunction)) {
        issues.add(
          PluginSecurityIssue(
            id: 'dangerous_function_${DateTime.now().millisecondsSinceEpoch}',
            title: 'Dangerous Function Call',
            description:
                'Found potentially dangerous function call: $dangerousFunction',
            threatType: PluginThreatType.privilegeEscalation,
            severity: PluginThreatLevel.high,
            confidence: 85,
            filePath: filePath,
            suggestions: <String>[
              'Review function usage',
              'Implement proper security checks',
              'Consider safer alternatives',
            ],
          ),
        );
        threatTypes.add(PluginThreatType.privilegeEscalation);
      }
    }
  }

  /// 执行启发式检测 (集成Ming CLI功能)
  Future<void> _performHeuristicDetection(
    String content,
    String? filePath,
    List<PluginSecurityIssue> issues,
    Set<PluginThreatType> threatTypes,
  ) async {
    // 检查可疑模式
    for (final String pattern in _malwareSignatures['suspicious_patterns']!) {
      final RegExp regex = RegExp(pattern, caseSensitive: false);
      if (regex.hasMatch(content)) {
        issues.add(
          PluginSecurityIssue(
            id: 'suspicious_pattern_${DateTime.now().millisecondsSinceEpoch}',
            title: 'Suspicious Code Pattern',
            description: 'Found potentially dangerous code pattern: $pattern',
            threatType: PluginThreatType.suspiciousBehavior,
            severity: PluginThreatLevel.medium,
            confidence: 75,
            filePath: filePath,
            suggestions: <String>[
              'Review code pattern',
              'Verify code safety',
              'Consider refactoring',
            ],
          ),
        );
        threatTypes.add(PluginThreatType.suspiciousBehavior);
      }
    }

    // 检查混淆代码
    final int totalLines = content.split('\n').length;
    final int longLines =
        content.split('\n').where((String line) => line.length > 200).length;
    if (totalLines > 0 && (longLines / totalLines) > 0.3) {
      issues.add(
        PluginSecurityIssue(
          id: 'obfuscated_code_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Potentially Obfuscated Code',
          description: 'Code appears to be obfuscated or minified',
          threatType: PluginThreatType.suspiciousBehavior,
          severity: PluginThreatLevel.medium,
          confidence: 60,
          filePath: filePath,
          suggestions: <String>[
            'Review code readability',
            'Verify code source',
            'Request unobfuscated version',
          ],
        ),
      );
      threatTypes.add(PluginThreatType.suspiciousBehavior);
    }
  }

  /// 执行安全策略检查 (集成Ming CLI功能)
  Future<bool> _performPolicyCheck(
    PluginSignatureVerificationResult? signatureResult,
    bool? trustedSourceResult,
    PluginMalwareDetectionResult? malwareResult,
    List<PluginSecurityIssue> securityIssues,
  ) async {
    switch (_policy) {
      case PluginSecurityPolicy.enterprise:
        // 企业级策略：必须有签名、来自可信源、无恶意代码
        return (signatureResult?.isValid ?? false) &&
            (trustedSourceResult ?? false) &&
            !(malwareResult?.hasThreat ?? true);

      case PluginSecurityPolicy.standard:
        // 标准策略：有签名或来自可信源，且无高危恶意代码
        final bool hasSignatureOrTrustedSource =
            (signatureResult?.isValid ?? false) ||
                (trustedSourceResult ?? false);
        final bool noHighRiskMalware = !(malwareResult?.isHighRisk ?? false);
        return hasSignatureOrTrustedSource && noHighRiskMalware;

      case PluginSecurityPolicy.relaxed:
        // 宽松策略：只要无严重恶意代码即可
        final bool noSeriousMalware = malwareResult?.issues
                .where((PluginSecurityIssue issue) =>
                    issue.severity == PluginThreatLevel.critical)
                .isEmpty ??
            true;
        return noSeriousMalware;
    }
  }

  /// 确定安全等级 (集成Ming CLI功能)
  PluginSecurityLevel _determineSecurityLevel(
    Map<PluginValidationStep, bool> stepResults,
    List<PluginSecurityIssue> securityIssues,
  ) {
    // 检查是否有严重问题
    final bool hasCriticalIssues = securityIssues.any(
      (PluginSecurityIssue issue) =>
          issue.severity == PluginThreatLevel.critical,
    );
    if (hasCriticalIssues) {
      return PluginSecurityLevel.blocked;
    }

    // 检查是否有高风险问题
    final bool hasHighRiskIssues = securityIssues.any(
      (PluginSecurityIssue issue) => issue.severity == PluginThreatLevel.high,
    );
    if (hasHighRiskIssues) {
      return PluginSecurityLevel.dangerous;
    }

    // 检查是否有中等风险问题
    final bool hasMediumRiskIssues = securityIssues.any(
      (PluginSecurityIssue issue) => issue.severity == PluginThreatLevel.medium,
    );
    if (hasMediumRiskIssues) {
      return PluginSecurityLevel.warning;
    }

    // 检查验证步骤是否全部通过
    final bool allStepsPassed =
        stepResults.values.every((bool result) => result);
    if (!allStepsPassed) {
      return PluginSecurityLevel.warning;
    }

    return PluginSecurityLevel.safe;
  }

  /// 判断验证是否通过 (集成Ming CLI功能)
  bool _isValidationPassed(
    PluginSecurityLevel securityLevel,
    Map<PluginValidationStep, bool> stepResults,
  ) {
    switch (_policy) {
      case PluginSecurityPolicy.enterprise:
        return securityLevel == PluginSecurityLevel.safe;

      case PluginSecurityPolicy.standard:
        return securityLevel == PluginSecurityLevel.safe ||
            securityLevel == PluginSecurityLevel.warning;

      case PluginSecurityPolicy.relaxed:
        return securityLevel != PluginSecurityLevel.blocked;
    }
  }

  /// 记录安全事件 (集成Ming CLI功能)
  Future<void> _recordSecurityEvent(
    String eventType,
    String description,
    PluginSecurityLevel securityLevel, {
    String? filePath,
    String? sourceUrl,
    Map<String, dynamic>? metadata,
  }) async {
    final PluginSecurityEvent event = PluginSecurityEvent(
      id: 'event_${DateTime.now().millisecondsSinceEpoch}',
      eventType: eventType,
      description: description,
      securityLevel: securityLevel,
      timestamp: DateTime.now(),
      filePath: filePath,
      sourceUrl: sourceUrl,
      metadata: metadata ?? <String, dynamic>{},
    );

    _securityEvents.add(event);

    // 保持事件列表在合理范围内
    if (_securityEvents.length > 10000) {
      _securityEvents.removeRange(0, _securityEvents.length - 10000);
    }
  }

  /// 记录审计日志 (集成Ming CLI功能)
  Future<void> _recordAuditLog(
    String operation,
    bool success, {
    String? userId,
    String? resourcePath,
    Map<String, dynamic>? details,
  }) async {
    final PluginSecurityAuditLog log = PluginSecurityAuditLog(
      id: 'audit_${DateTime.now().millisecondsSinceEpoch}',
      operation: operation,
      success: success,
      userId: userId,
      resourcePath: resourcePath,
      timestamp: DateTime.now(),
      details: details ?? <String, dynamic>{},
    );

    _auditLogs.add(log);

    // 保持审计日志在合理范围内
    if (_auditLogs.length > 50000) {
      _auditLogs.removeRange(0, _auditLogs.length - 50000);
    }
  }

  /// 更新验证统计 (集成Ming CLI功能)
  void _updateValidationStats(PluginSecurityLevel securityLevel, bool isValid) {
    final String levelKey = 'level_${securityLevel.name}';
    _validationStats[levelKey] = (_validationStats[levelKey] ?? 0) + 1;

    final String resultKey = isValid ? 'valid' : 'invalid';
    _validationStats[resultKey] = (_validationStats[resultKey] ?? 0) + 1;

    _validationStats['total'] = (_validationStats['total'] ?? 0) + 1;
  }

  /// 检查告警阈值 (集成Ming CLI功能)
  Future<void> _checkAlertThresholds() async {
    final DateTime now = DateTime.now();
    final DateTime oneHourAgo = now.subtract(const Duration(hours: 1));

    // 检查恶意代码检测告警
    final int malwareDetections = _securityEvents
        .where((PluginSecurityEvent event) =>
            event.eventType == 'malware_detected' &&
            event.timestamp.isAfter(oneHourAgo))
        .length;

    if (malwareDetections >= _alertThresholds['malware_detections_per_hour']!) {
      await _recordSecurityEvent(
        'malware_detection_threshold_exceeded',
        'Malware detection threshold exceeded: $malwareDetections detections in the last hour',
        PluginSecurityLevel.dangerous,
      );
    }

    // 检查签名验证失败告警
    final int signatureFailures = _securityEvents
        .where((PluginSecurityEvent event) =>
            event.eventType == 'signature_verification_error' &&
            event.timestamp.isAfter(oneHourAgo))
        .length;

    if (signatureFailures >= _alertThresholds['signature_failures_per_hour']!) {
      await _recordSecurityEvent(
        'signature_failure_threshold_exceeded',
        'Signature failure threshold exceeded: $signatureFailures failures in the last hour',
        PluginSecurityLevel.warning,
      );
    }
  }

  /// 初始化默认可信源 (集成Ming CLI功能)
  void _initializeDefaultTrustedSources() {
    _trustedSources.addAll(<String>[
      'github.com',
      'pub.dev',
      'plugins.flutter.dev',
      'dart.dev',
      'flutter.dev',
    ]);

    _blacklistedSources.addAll(<String>[
      'malware-site.com',
      'suspicious-domain.net',
    ]);
  }

  /// 初始化告警阈值 (集成Ming CLI功能)
  void _initializeAlertThresholds() {
    _alertThresholds.addAll(<String, int>{
      'malware_detections_per_hour': 5,
      'signature_failures_per_hour': 10,
      'untrusted_source_attempts_per_hour': 20,
    });
  }

  /// 获取安全事件
  List<PluginSecurityEvent> getSecurityEvents({
    PluginSecurityLevel? level,
    DateTime? since,
    int? limit,
  }) {
    var events = _securityEvents.where((PluginSecurityEvent event) {
      if (level != null && event.securityLevel != level) {
        return false;
      }
      if (since != null && event.timestamp.isBefore(since)) {
        return false;
      }
      return true;
    }).toList();

    // 按时间倒序排列
    events.sort((PluginSecurityEvent a, PluginSecurityEvent b) =>
        b.timestamp.compareTo(a.timestamp));

    if (limit != null && events.length > limit) {
      events = events.take(limit).toList();
    }

    return events;
  }

  /// 获取审计日志
  List<PluginSecurityAuditLog> getAuditLogs({
    bool? successOnly,
    DateTime? since,
    int? limit,
  }) {
    var logs = _auditLogs.where((PluginSecurityAuditLog log) {
      if (successOnly != null && log.success != successOnly) {
        return false;
      }
      if (since != null && log.timestamp.isBefore(since)) {
        return false;
      }
      return true;
    }).toList();

    // 按时间倒序排列
    logs.sort((PluginSecurityAuditLog a, PluginSecurityAuditLog b) =>
        b.timestamp.compareTo(a.timestamp));

    if (limit != null && logs.length > limit) {
      logs = logs.take(limit).toList();
    }

    return logs;
  }

  /// 获取验证统计信息
  Map<String, int> getValidationStats() =>
      Map<String, int>.from(_validationStats);

  /// 生成安全报告
  Map<String, dynamic> generateSecurityReport() {
    final DateTime now = DateTime.now();
    final DateTime last24Hours = now.subtract(const Duration(hours: 24));

    final List<PluginSecurityEvent> recentEvents =
        getSecurityEvents(since: last24Hours);
    final List<PluginSecurityAuditLog> recentLogs =
        getAuditLogs(since: last24Hours);

    return <String, dynamic>{
      'reportGeneratedAt': now.toIso8601String(),
      'policy': _policy.name,
      'validationStats': _validationStats,
      'recentEvents': <String, dynamic>{
        'total': recentEvents.length,
        'byLevel': <String, int>{
          for (final PluginSecurityLevel level in PluginSecurityLevel.values)
            level.name: recentEvents
                .where((PluginSecurityEvent e) => e.securityLevel == level)
                .length,
        },
      },
      'recentAuditLogs': <String, dynamic>{
        'total': recentLogs.length,
        'successful': recentLogs
            .where((PluginSecurityAuditLog log) => log.success)
            .length,
        'failed': recentLogs
            .where((PluginSecurityAuditLog log) => !log.success)
            .length,
      },
      'trustedSources': _trustedSources.length,
      'blacklistedSources': _blacklistedSources.length,
      'alertThresholds': _alertThresholds,
    };
  }

  /// 清理缓存和历史数据
  void clearCache() {
    _securityEvents.clear();
    _auditLogs.clear();
    _validationStats.clear();
  }
}
