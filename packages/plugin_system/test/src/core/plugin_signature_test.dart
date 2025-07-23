/*
---------------------------------------------------------------
File name:          plugin_signature_test.dart
Author:             lgnorant-lu
Date created:       2025-07-23
Last modified:      2025-07-23
Dart Version:       3.2+
Description:        插件数字签名测试 - 集成Ming CLI测试
---------------------------------------------------------------
Change History:
    2025-07-23: Task 1.2.1 - 集成Ming CLI的数字签名功能测试;
---------------------------------------------------------------
*/

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_system/src/core/plugin_signature.dart';

void main() {
  group('PluginSignature Tests', () {
    late PluginSignature pluginSignature;

    setUp(() {
      pluginSignature = PluginSignature.instance;
      pluginSignature.clearCache();
    });

    group('证书信息测试', () {
      test('应该创建有效的证书信息', () {
        final certificate = PluginCertificateInfo(
          subject: 'CN=Test Plugin Publisher',
          issuer: 'CN=Test CA',
          serialNumber: '123456789',
          notBefore: DateTime.now().subtract(const Duration(days: 30)),
          notAfter: DateTime.now().add(const Duration(days: 30)),
          fingerprint: 'SHA256:ABCDEF123456',
          status: PluginCertificateStatus.valid,
          keyUsage: const <String>['Digital Signature'],
          extendedKeyUsage: const <String>['Code Signing'],
        );

        expect(certificate.subject, equals('CN=Test Plugin Publisher'));
        expect(certificate.isValid, isTrue);
        expect(certificate.isExpired, isFalse);
        expect(certificate.isInValidPeriod, isTrue);
      });

      test('应该检测过期证书', () {
        final expiredCertificate = PluginCertificateInfo(
          subject: 'CN=Expired Publisher',
          issuer: 'CN=Test CA',
          serialNumber: '987654321',
          notBefore: DateTime.now().subtract(const Duration(days: 60)),
          notAfter: DateTime.now().subtract(const Duration(days: 30)),
          fingerprint: 'SHA256:EXPIRED123456',
          status: PluginCertificateStatus.valid,
          keyUsage: const <String>['Digital Signature'],
          extendedKeyUsage: const <String>['Code Signing'],
        );

        expect(expiredCertificate.isExpired, isTrue);
        expect(expiredCertificate.isInValidPeriod, isFalse);
        expect(expiredCertificate.isValid, isFalse);
      });
    });

    group('签名信息测试', () {
      test('应该创建签名信息', () {
        final certificate = PluginCertificateInfo(
          subject: 'CN=Test Publisher',
          issuer: 'CN=Test CA',
          serialNumber: '123456789',
          notBefore: DateTime.now().subtract(const Duration(days: 30)),
          notAfter: DateTime.now().add(const Duration(days: 30)),
          fingerprint: 'SHA256:ABCDEF123456',
          status: PluginCertificateStatus.valid,
          keyUsage: const <String>['Digital Signature'],
          extendedKeyUsage: const <String>['Code Signing'],
        );

        final signature = PluginSignatureInfo(
          algorithm: PluginSignatureAlgorithm.rsa2048,
          signature: Uint8List.fromList(<int>[1, 2, 3, 4, 5]),
          signedAt: DateTime.now(),
          certificate: certificate,
          attributes: const <String, dynamic>{'version': '1.0'},
        );

        expect(signature.algorithm, PluginSignatureAlgorithm.rsa2048);
        expect(signature.signature, isNotEmpty);
        expect(signature.hasTimestamp, isFalse);
        expect(signature.isTrusted, isTrue);
      });

      test('应该检测带时间戳的签名', () {
        final certificate = PluginCertificateInfo(
          subject: 'CN=Test Publisher',
          issuer: 'CN=Test CA',
          serialNumber: '123456789',
          notBefore: DateTime.now().subtract(const Duration(days: 30)),
          notAfter: DateTime.now().add(const Duration(days: 30)),
          fingerprint: 'SHA256:ABCDEF123456',
          status: PluginCertificateStatus.valid,
          keyUsage: const <String>['Digital Signature'],
          extendedKeyUsage: const <String>['Code Signing'],
        );

        final timestamp = PluginTimestampInfo(
          tsaUrl: 'http://timestamp.test.com',
          timestamp: DateTime.now(),
          signature: Uint8List.fromList(<int>[5, 4, 3, 2, 1]),
          certificate: certificate,
          isValid: true,
        );

        final signature = PluginSignatureInfo(
          algorithm: PluginSignatureAlgorithm.rsa2048,
          signature: Uint8List.fromList(<int>[1, 2, 3, 4, 5]),
          signedAt: DateTime.now(),
          certificate: certificate,
          timestamp: timestamp,
        );

        expect(signature.hasTimestamp, isTrue);
        expect(signature.isTrusted, isTrue);
      });
    });

    group('签名验证测试', () {
      test('应该验证有签名的插件文件', () async {
        const String testFilePath = 'test_plugin.signed';
        final Uint8List testData = Uint8List.fromList(
          'PLUGIN_SIGNATURE test plugin data'.codeUnits,
        );

        final result = await pluginSignature.verifyPluginSignature(
          testFilePath,
          testData,
        );

        expect(result.isValid, isTrue);
        expect(result.hasSigned, isTrue);
        expect(result.signatures, hasLength(1));
        expect(result.errors, isEmpty);
      });

      test('应该处理无签名的插件文件', () async {
        const String testFilePath = 'test_plugin.unsigned';
        final Uint8List testData = Uint8List.fromList(
          'unsigned plugin data'.codeUnits,
        );

        final result = await pluginSignature.verifyPluginSignature(
          testFilePath,
          testData,
        );

        expect(result.isValid, isTrue); // 默认策略是可选的
        expect(result.hasSigned, isFalse);
        expect(result.signatures, isEmpty);
        expect(
            result.warnings, contains('No digital signature found for plugin'));
      });

      test('应该在必需签名策略下拒绝无签名文件', () async {
        final requiredSignature = PluginSignature(
          policy: PluginSignaturePolicy.required,
        );

        const String testFilePath = 'test_plugin.unsigned';
        final Uint8List testData = Uint8List.fromList(
          'unsigned plugin data'.codeUnits,
        );

        final result = await requiredSignature.verifyPluginSignature(
          testFilePath,
          testData,
        );

        expect(result.isValid, isFalse);
        expect(result.hasSigned, isFalse);
        expect(
            result.errors,
            contains(
              'No digital signature found, but signature is required for plugins',
            ));
      });

      test('应该在禁用策略下跳过验证', () async {
        final disabledSignature = PluginSignature(
          policy: PluginSignaturePolicy.disabled,
        );

        const String testFilePath = 'test_plugin.any';
        final Uint8List testData = Uint8List.fromList(
          'any plugin data'.codeUnits,
        );

        final result = await disabledSignature.verifyPluginSignature(
          testFilePath,
          testData,
        );

        expect(result.isValid, isTrue);
        expect(result.hasSigned, isFalse);
        expect(
            result.warnings,
            contains(
              'Plugin signature verification is disabled',
            ));
      });
    });

    group('插件签名生成测试', () {
      test('应该能够签名插件数据', () async {
        final Uint8List testData = Uint8List.fromList(
          'test plugin data for signing'.codeUnits,
        );

        final signedData = await pluginSignature.signPlugin(
          testData,
          attributes: const <String, dynamic>{
            'plugin_id': 'test_plugin',
            'version': '1.0.0',
          },
        );

        expect(signedData.length, greaterThan(testData.length));

        // 验证签名标记是否存在
        final String signedContent = String.fromCharCodes(signedData);
        expect(signedContent, contains('PLUGIN_SIGNATURE'));
      });

      test('应该能够验证自己签名的插件', () async {
        final Uint8List testData = Uint8List.fromList(
          'test plugin data for self verification'.codeUnits,
        );

        // 签名插件
        final signedData = await pluginSignature.signPlugin(testData);

        // 验证签名
        final result = await pluginSignature.verifyPluginSignature(
          'self_signed_plugin.signed',
          signedData,
        );

        expect(result.isValid, isTrue);
        expect(result.hasSigned, isTrue);
        expect(result.signatures, hasLength(1));
      });
    });

    group('证书管理测试', () {
      test('应该能够获取证书信息', () async {
        const String testCertPath = '/path/to/test.cert';

        final certificate =
            await pluginSignature.getCertificateInfo(testCertPath);

        expect(certificate, isNotNull);
        expect(certificate!.subject, contains('Plugin Publisher'));
        expect(certificate.isValid, isTrue);
      });

      test('应该能够检查证书撤销状态', () async {
        final certificate = PluginCertificateInfo(
          subject: 'CN=Test Publisher',
          issuer: 'CN=Test CA',
          serialNumber: '123456789',
          notBefore: DateTime.now().subtract(const Duration(days: 30)),
          notAfter: DateTime.now().add(const Duration(days: 30)),
          fingerprint: 'SHA256:ABCDEF123456',
          status: PluginCertificateStatus.valid,
          keyUsage: const <String>['Digital Signature'],
          extendedKeyUsage: const <String>['Code Signing'],
        );

        final status =
            await pluginSignature.checkCertificateRevocation(certificate);

        expect(status, PluginCertificateStatus.valid);
      });
    });

    group('时间戳验证测试', () {
      test('应该验证有效的时间戳', () async {
        final certificate = PluginCertificateInfo(
          subject: 'CN=TSA',
          issuer: 'CN=TSA CA',
          serialNumber: 'TSA123456789',
          notBefore: DateTime.now().subtract(const Duration(days: 30)),
          notAfter: DateTime.now().add(const Duration(days: 30)),
          fingerprint: 'SHA256:TSA123456',
          status: PluginCertificateStatus.valid,
          keyUsage: const <String>['Digital Signature'],
          extendedKeyUsage: const <String>['Time Stamping'],
        );

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

      test('应该拒绝不可信的时间戳服务器', () async {
        final certificate = PluginCertificateInfo(
          subject: 'CN=Untrusted TSA',
          issuer: 'CN=Untrusted CA',
          serialNumber: 'UNTRUSTED123',
          notBefore: DateTime.now().subtract(const Duration(days: 30)),
          notAfter: DateTime.now().add(const Duration(days: 30)),
          fingerprint: 'SHA256:UNTRUSTED123',
          status: PluginCertificateStatus.valid,
          keyUsage: const <String>['Digital Signature'],
          extendedKeyUsage: const <String>['Time Stamping'],
        );

        final timestamp = PluginTimestampInfo(
          tsaUrl: 'http://untrusted.timestamp.com',
          timestamp: DateTime.now(),
          signature: Uint8List.fromList(<int>[1, 2, 3, 4, 5]),
          certificate: certificate,
          isValid: true,
        );

        final isValid = await pluginSignature.verifyTimestamp(timestamp);
        expect(isValid, isFalse);
      });
    });

    group('统计和缓存测试', () {
      test('应该记录验证统计', () async {
        final Uint8List testData = Uint8List.fromList(
          'PLUGIN_SIGNATURE test data'.codeUnits,
        );

        // 执行几次验证
        await pluginSignature.verifyPluginSignature('test1.signed', testData);
        await pluginSignature.verifyPluginSignature('test2.signed', testData);

        final stats = pluginSignature.getVerificationStats();
        expect(stats['valid'], greaterThan(0));
        expect(stats['signatures_1'], greaterThan(0));
      });

      test('应该能够清理缓存', () {
        // 这个测试主要验证方法不会抛出异常
        expect(() => pluginSignature.clearCache(), returnsNormally);
      });
    });
  });
}
