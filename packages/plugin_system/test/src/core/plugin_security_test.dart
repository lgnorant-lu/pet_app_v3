/*
---------------------------------------------------------------
File name:          plugin_security_test.dart
Author:             lgnorant-lu
Date created:       2025-07-23
Last modified:      2025-07-23
Dart Version:       3.2+
Description:        插件安全验证测试 - 集成Ming CLI测试
---------------------------------------------------------------
Change History:
    2025-07-23: Task 1.2.2 - 完善安全验证流程测试;
---------------------------------------------------------------
*/

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_system/src/core/plugin_security.dart';

void main() {
  group('PluginSecurityValidator Tests', () {
    late PluginSecurityValidator securityValidator;

    setUp(() {
      securityValidator = PluginSecurityValidator.instance;
      securityValidator.clearCache();
    });

    group('安全等级测试', () {
      test('应该正确识别安全文件', () async {
        final Uint8List safeData = Uint8List.fromList(
          'import "package:flutter/material.dart"; class SafeWidget extends StatelessWidget {}'
              .codeUnits,
        );

        final result = await securityValidator.validatePluginSecurity(
          'safe_plugin.dart',
          safeData,
        );

        expect(result.securityLevel, PluginSecurityLevel.safe);
        expect(result.isValid, isTrue);
        expect(result.hasSecurityIssues, isFalse);
      });

      test('应该检测可疑导入', () async {
        final Uint8List suspiciousData = Uint8List.fromList(
          'import "dart:ffi"; import "dart:mirrors"; void main() {}'.codeUnits,
        );

        final result = await securityValidator.validatePluginSecurity(
          'suspicious_plugin.dart',
          suspiciousData,
        );

        expect(result.securityLevel, PluginSecurityLevel.warning);
        expect(result.hasSecurityIssues, isTrue);
        expect(
            result.securityIssues.any((issue) =>
                issue.threatType == PluginThreatType.suspiciousBehavior),
            isTrue);
      });

      test('应该检测危险函数调用', () async {
        final Uint8List dangerousData = Uint8List.fromList(
          'Process.run("rm", ["-rf", "/"]); File.writeAsBytes("evil.exe", data);'
              .codeUnits,
        );

        final result = await securityValidator.validatePluginSecurity(
          'dangerous_plugin.dart',
          dangerousData,
        );

        expect(result.securityLevel, PluginSecurityLevel.dangerous);
        expect(result.hasHighRiskIssues, isTrue);
        expect(
            result.securityIssues.any((issue) =>
                issue.threatType == PluginThreatType.privilegeEscalation),
            isTrue);
      });

      test('应该检测大文件', () async {
        // 创建一个大文件 (模拟超过50MB)
        final Uint8List largeData = Uint8List(60 * 1024 * 1024); // 60MB

        final result = await securityValidator.validatePluginSecurity(
          'large_plugin.bin',
          largeData,
        );

        expect(result.hasSecurityIssues, isTrue);
        expect(
            result.securityIssues
                .any((issue) => issue.title.contains('Large Plugin File')),
            isTrue);
      });
    });

    group('安全策略测试', () {
      test('企业级策略应该最严格', () async {
        final enterpriseValidator = PluginSecurityValidator(
          policy: PluginSecurityPolicy.enterprise,
        );

        final Uint8List unsignedData = Uint8List.fromList(
          'unsigned plugin data'.codeUnits,
        );

        final result = await enterpriseValidator.validatePluginSecurity(
          'unsigned_plugin.dart',
          unsignedData,
        );

        // 企业级策略要求签名，所以应该失败
        expect(result.isValid, isFalse);
      });

      test('标准策略应该平衡安全性', () async {
        final standardValidator = PluginSecurityValidator(
          policy: PluginSecurityPolicy.standard,
        );

        final Uint8List cleanData = Uint8List.fromList(
          'clean plugin code without dangerous patterns'.codeUnits,
        );

        final result = await standardValidator.validatePluginSecurity(
          'clean_plugin.dart',
          cleanData,
        );

        expect(result.isValid, isTrue);
        expect(result.securityLevel, PluginSecurityLevel.safe);
      });

      test('宽松策略应该允许更多内容', () async {
        final relaxedValidator = PluginSecurityValidator(
          policy: PluginSecurityPolicy.relaxed,
        );

        final Uint8List suspiciousData = Uint8List.fromList(
          'import "dart:ffi"; void main() {}'.codeUnits,
        );

        final result = await relaxedValidator.validatePluginSecurity(
          'suspicious_plugin.dart',
          suspiciousData,
        );

        // 宽松策略应该允许可疑但非严重的内容
        expect(result.isValid, isTrue);
      });
    });

    group('恶意代码检测测试', () {
      test('应该检测混淆代码', () async {
        // 创建看起来像混淆代码的内容
        final String obfuscatedCode = List.generate(
                10,
                (index) =>
                    'var ${String.fromCharCode(65 + index)} = "${List.generate(250, (i) => 'x').join()}";')
            .join('\n');

        final Uint8List obfuscatedData =
            Uint8List.fromList(obfuscatedCode.codeUnits);

        final result = await securityValidator.validatePluginSecurity(
          'obfuscated_plugin.dart',
          obfuscatedData,
        );

        expect(result.hasSecurityIssues, isTrue);
        expect(
            result.securityIssues
                .any((issue) => issue.title.contains('Obfuscated Code')),
            isTrue);
      });

      test('应该检测可疑模式', () async {
        final Uint8List patternData = Uint8List.fromList(
          'eval("malicious code"); Function("return evil")(); dynamic x = dangerous;'
              .codeUnits,
        );

        final result = await securityValidator.validatePluginSecurity(
          'pattern_plugin.dart',
          patternData,
        );

        expect(result.hasSecurityIssues, isTrue);
        expect(
            result.securityIssues.any(
                (issue) => issue.title.contains('Suspicious Code Pattern')),
            isTrue);
      });
    });

    group('可信源验证测试', () {
      test('应该信任已知的可信源', () async {
        final Uint8List testData = Uint8List.fromList('test data'.codeUnits);

        final result = await securityValidator.validatePluginSecurity(
          'test_plugin.dart',
          testData,
          sourceUrl: 'https://github.com/flutter/plugins',
        );

        // GitHub是可信源，应该通过可信源验证
        expect(
            result.stepResults[PluginValidationStep.trustedSourceVerification],
            isTrue);
      });

      test('应该拒绝黑名单源', () async {
        final Uint8List testData = Uint8List.fromList('test data'.codeUnits);

        final result = await securityValidator.validatePluginSecurity(
          'test_plugin.dart',
          testData,
          sourceUrl: 'https://malware-site.com/evil-plugin',
        );

        // 黑名单源应该被拒绝
        expect(
            result.stepResults[PluginValidationStep.trustedSourceVerification],
            isFalse);
      });
    });

    group('安全事件和审计测试', () {
      test('应该记录安全事件', () async {
        final Uint8List dangerousData = Uint8List.fromList(
          'Process.run("evil", ["command"]);'.codeUnits,
        );

        await securityValidator.validatePluginSecurity(
          'dangerous_plugin.dart',
          dangerousData,
        );

        final events = securityValidator.getSecurityEvents();
        expect(events, isNotEmpty);
        expect(
            events.any((event) =>
                event.eventType.contains('malware') ||
                event.eventType.contains('validation')),
            isTrue);
      });

      test('应该记录审计日志', () async {
        final Uint8List testData = Uint8List.fromList('test data'.codeUnits);

        await securityValidator.validatePluginSecurity(
          'test_plugin.dart',
          testData,
        );

        final logs = securityValidator.getAuditLogs();
        expect(logs, isNotEmpty);
        expect(logs.any((log) => log.operation.contains('validation')), isTrue);
      });

      test('应该生成安全报告', () {
        final report = securityValidator.generateSecurityReport();

        expect(report, isA<Map<String, dynamic>>());
        expect(report['reportGeneratedAt'], isNotNull);
        expect(report['policy'], isNotNull);
        expect(report['validationStats'], isA<Map<String, int>>());
        expect(report['recentEvents'], isA<Map<String, dynamic>>());
        expect(report['recentAuditLogs'], isA<Map<String, dynamic>>());
      });
    });

    group('验证统计测试', () {
      test('应该更新验证统计', () async {
        final Uint8List testData1 = Uint8List.fromList('safe data'.codeUnits);
        final Uint8List testData2 =
            Uint8List.fromList('Process.run("evil");'.codeUnits);

        // 执行多次验证
        await securityValidator.validatePluginSecurity('safe.dart', testData1);
        await securityValidator.validatePluginSecurity(
            'dangerous.dart', testData2);

        final stats = securityValidator.getValidationStats();
        expect(stats['total'], greaterThan(0));
        expect(stats['valid'], isA<int>());
        expect(stats['invalid'], isA<int>());
      });
    });

    group('缓存管理测试', () {
      test('应该能够清理缓存', () async {
        // 先生成一些数据
        final Uint8List testData = Uint8List.fromList('test data'.codeUnits);
        await securityValidator.validatePluginSecurity('test.dart', testData);

        // 清理缓存
        securityValidator.clearCache();

        // 验证缓存已清理
        final events = securityValidator.getSecurityEvents();
        final logs = securityValidator.getAuditLogs();
        final stats = securityValidator.getValidationStats();

        expect(events, isEmpty);
        expect(logs, isEmpty);
        expect(stats, isEmpty);
      });
    });

    group('错误处理测试', () {
      test('应该处理空文件', () async {
        final Uint8List emptyData = Uint8List(0);

        final result = await securityValidator.validatePluginSecurity(
          'empty_plugin.dart',
          emptyData,
        );

        expect(result, isA<PluginSecurityValidationResult>());
        expect(result.securityLevel, isNotNull);
      });

      test('应该处理无效文件路径', () async {
        final Uint8List testData = Uint8List.fromList('test data'.codeUnits);

        final result = await securityValidator.validatePluginSecurity(
          '', // 空路径
          testData,
        );

        expect(result, isA<PluginSecurityValidationResult>());
      });
    });

    group('威胁检测集成测试', () {
      test('应该检测多种威胁类型', () async {
        final Uint8List multiThreatData = Uint8List.fromList(
          '''
          import "dart:ffi";
          import "dart:mirrors";
          
          void main() {
            Process.run("rm", ["-rf", "/"]);
            File.writeAsBytes("evil.exe", data);
            eval("malicious code");
            dynamic x = dangerous;
          }
          '''
              .codeUnits,
        );

        final result = await securityValidator.validatePluginSecurity(
          'multi_threat_plugin.dart',
          multiThreatData,
        );

        expect(result.hasSecurityIssues, isTrue);
        expect(result.hasHighRiskIssues, isTrue);
        expect(result.securityLevel, PluginSecurityLevel.dangerous);

        // 应该检测到多种威胁类型
        final threatTypes =
            result.securityIssues.map((issue) => issue.threatType).toSet();
        expect(threatTypes.length, greaterThan(1));
      });
    });
  });
}
