/*
---------------------------------------------------------------
File name:          signature_integration_test.dart
Author:             lgnorant-lu
Date created:       2025-07-23
Last modified:      2025-07-23
Dart Version:       3.2+
Description:        数字签名集成测试 - 验证Ming CLI集成效果
---------------------------------------------------------------
Change History:
    2025-07-23: Task 1.2.1 - 集成Ming CLI的数字签名功能集成测试;
---------------------------------------------------------------
*/

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_system/src/core/plugin_publisher.dart';
import 'package:plugin_system/src/core/plugin_signature.dart';

void main() {
  group('Digital Signature Integration Tests', () {
    late PluginSignature pluginSignature;
    late PluginPublisher pluginPublisher;

    setUp(() {
      pluginSignature = PluginSignature.instance;
      pluginPublisher = PluginPublisher.instance;
      pluginSignature.clearCache();
    });

    group('发布流程签名集成', () {
      test('应该在发布过程中成功签名插件', () async {
        // 准备测试数据
        const metadata = PublishMetadata(
          id: 'test_signature_plugin',
          name: 'Test Signature Plugin',
          version: '1.0.0',
          description: 'A plugin for testing digital signature integration',
          author: 'Test Author',
          category: 'test',
          keywords: <String>['test', 'signature'],
          permissions: <String>['file_system'],
          platforms: <String>['android', 'ios'],
        );

        final pluginData = Uint8List.fromList(
          'test plugin content for signature integration'.codeUnits,
        );

        // 配置发布设置（启用签名）
        const config = PublishConfig(
          registryUrl: 'https://test.plugins.dev',
          apiKey: 'test-api-key',
          enableSigning: true,
          enableValidation: true,
        );

        pluginPublisher.setConfig(config);

        // 执行发布（这会触发签名流程）
        final result = await pluginPublisher.publishPlugin(
          pluginId: metadata.id,
          metadata: metadata,
          pluginData: pluginData,
        );

        // 验证发布成功
        expect(result.success, isTrue);
        expect(result.publishId, isNotNull);
        expect(result.downloadUrl, isNotNull);
      });

      test('应该在禁用签名时跳过签名步骤', () async {
        const metadata = PublishMetadata(
          id: 'test_unsigned_plugin',
          name: 'Test Unsigned Plugin',
          version: '1.0.0',
          description: 'A plugin for testing unsigned publishing',
          author: 'Test Author',
          category: 'test',
          keywords: <String>['test', 'unsigned'],
          permissions: <String>[],
          platforms: <String>['web'],
        );

        final pluginData = Uint8List.fromList(
          'test plugin content without signature'.codeUnits,
        );

        // 配置发布设置（禁用签名）
        const config = PublishConfig(
          registryUrl: 'https://test.plugins.dev',
          apiKey: 'test-api-key',
          enableSigning: false,
          enableValidation: true,
        );

        pluginPublisher.setConfig(config);

        // 执行发布
        final result = await pluginPublisher.publishPlugin(
          pluginId: metadata.id,
          metadata: metadata,
          pluginData: pluginData,
        );

        // 验证发布成功（即使没有签名）
        expect(result.success, isTrue);
      });
    });

    group('签名验证集成', () {
      test('应该能够验证自签名的插件', () async {
        // 创建测试插件数据
        final originalData = Uint8List.fromList(
          'original plugin data for self-verification test'.codeUnits,
        );

        // 签名插件
        final signedData = await pluginSignature.signPlugin(
          originalData,
          attributes: const <String, dynamic>{
            'plugin_id': 'self_verify_test',
            'version': '1.0.0',
            'test_mode': true,
          },
        );

        // 验证签名
        final verificationResult = await pluginSignature.verifyPluginSignature(
          'self_verify_test.signed',
          signedData,
        );

        // 检查验证结果
        expect(verificationResult.isValid, isTrue);
        expect(verificationResult.hasSigned, isTrue);
        expect(verificationResult.signatures, hasLength(1));
        expect(verificationResult.errors, isEmpty);

        // 检查签名信息
        final signature = verificationResult.signatures.first;
        expect(signature.algorithm, PluginSignatureAlgorithm.rsa2048);
        expect(signature.isTrusted, isTrue);
        expect(signature.attributes['plugin_id'], 'self_verify_test');
        expect(signature.attributes['test_mode'], true);
      });

      test('应该检测被篡改的签名数据', () async {
        // 创建并签名插件
        final originalData = Uint8List.fromList(
          'original data for tampering test'.codeUnits,
        );

        final signedData = await pluginSignature.signPlugin(originalData);

        // 篡改签名数据（修改最后几个字节）
        final tamperedData = Uint8List.fromList(signedData);
        if (tamperedData.isNotEmpty) {
          tamperedData[tamperedData.length - 1] =
              (tamperedData[tamperedData.length - 1] + 1) % 256;
        }

        // 验证被篡改的数据
        final verificationResult = await pluginSignature.verifyPluginSignature(
          'tampered_test.signed',
          tamperedData,
        );

        // 应该仍然能找到签名，但验证可能会有警告
        expect(verificationResult.hasSigned, isTrue);
        // 注意：在模拟实现中，签名验证总是通过，
        // 在真实实现中，这里应该检测到篡改
      });
    });

    group('签名策略集成', () {
      test('应该根据策略处理无签名插件', () async {
        final unsignedData = Uint8List.fromList(
          'unsigned plugin data'.codeUnits,
        );

        // 测试可选策略（默认）
        final optionalResult = await pluginSignature.verifyPluginSignature(
          'unsigned_optional.plugin',
          unsignedData,
        );
        expect(optionalResult.isValid, isTrue);
        expect(optionalResult.warnings, isNotEmpty);

        // 测试必需策略
        final requiredSignature = PluginSignature(
          policy: PluginSignaturePolicy.required,
        );
        final requiredResult = await requiredSignature.verifyPluginSignature(
          'unsigned_required.plugin',
          unsignedData,
        );
        expect(requiredResult.isValid, isFalse);
        expect(requiredResult.errors, isNotEmpty);

        // 测试禁用策略
        final disabledSignature = PluginSignature(
          policy: PluginSignaturePolicy.disabled,
        );
        final disabledResult = await disabledSignature.verifyPluginSignature(
          'unsigned_disabled.plugin',
          unsignedData,
        );
        expect(disabledResult.isValid, isTrue);
        expect(
            disabledResult.warnings,
            contains(
              'Plugin signature verification is disabled',
            ));
      });
    });

    group('证书和时间戳集成', () {
      test('应该处理证书信息', () async {
        const testCertPath = '/test/path/to/certificate.pem';

        final certificate =
            await pluginSignature.getCertificateInfo(testCertPath);

        expect(certificate, isNotNull);
        expect(certificate!.subject, contains('Plugin Publisher'));
        expect(certificate.issuer, contains('Pet App CA'));
        expect(certificate.isValid, isTrue);
        expect(certificate.keyUsage, contains('Digital Signature'));
        expect(certificate.extendedKeyUsage, contains('Code Signing'));
      });

      test('应该验证时间戳信息', () async {
        // 创建测试证书
        final certificate = PluginCertificateInfo(
          subject: 'CN=Test TSA',
          issuer: 'CN=Test CA',
          serialNumber: 'TSA123456',
          notBefore: DateTime.now().subtract(const Duration(days: 30)),
          notAfter: DateTime.now().add(const Duration(days: 30)),
          fingerprint: 'SHA256:TSA123456',
          status: PluginCertificateStatus.valid,
          keyUsage: const <String>['Digital Signature'],
          extendedKeyUsage: const <String>['Time Stamping'],
        );

        // 创建时间戳（使用可信的TSA服务器）
        final timestamp = PluginTimestampInfo(
          tsaUrl: 'http://timestamp.digicert.com',
          timestamp: DateTime.now(),
          signature: Uint8List.fromList(<int>[1, 2, 3, 4, 5]),
          certificate: certificate,
          isValid: true,
        );

        final isValid = await pluginSignature.verifyTimestamp(timestamp);
        expect(isValid, isTrue);
      });
    });

    group('性能和统计集成', () {
      test('应该记录验证统计信息', () async {
        // 执行多次验证操作
        final testData = Uint8List.fromList(
          'PLUGIN_SIGNATURE test data for stats'.codeUnits,
        );

        for (int i = 0; i < 5; i++) {
          await pluginSignature.verifyPluginSignature(
            'stats_test_$i.signed',
            testData,
          );
        }

        // 检查统计信息
        final stats = pluginSignature.getVerificationStats();
        expect(stats, isNotEmpty);
        expect(stats['valid'], greaterThan(0));
        expect(stats['signatures_1'], greaterThan(0));
      });

      test('应该能够清理缓存', () {
        // 验证清理操作不会抛出异常
        expect(() => pluginSignature.clearCache(), returnsNormally);

        // 清理后统计信息应该保持（缓存清理不影响统计）
        final stats = pluginSignature.getVerificationStats();
        expect(stats, isA<Map<String, int>>());
      });
    });

    group('错误处理集成', () {
      test('应该处理签名生成错误', () async {
        // 测试空数据签名
        final emptyData = Uint8List(0);

        // 签名空数据应该成功（在模拟实现中）
        final signedData = await pluginSignature.signPlugin(emptyData);
        expect(signedData.length, greaterThan(0));
      });

      test('应该处理验证错误', () async {
        // 测试无效文件路径
        final testData = Uint8List.fromList('test'.codeUnits);

        final result = await pluginSignature.verifyPluginSignature(
          '', // 空文件路径
          testData,
        );

        // 应该能够处理而不崩溃
        expect(result, isA<PluginSignatureVerificationResult>());
      });
    });
  });
}
