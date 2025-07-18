/*
---------------------------------------------------------------
File name:          desktop_pet_utils.dart
Author:             Pet App Team
Date created:       2025-07-18
Last modified:      2025-07-18
Dart Version:       3.2+
Description:        desktop_pet工具类和辅助函数
---------------------------------------------------------------
Change History:
    2025-07-18: Initial creation - desktop_pet工具类和辅助函数;
---------------------------------------------------------------
*/

import 'dart:math';

/// desktop_pet主要工具类
///
/// ## 使用示例
///
/// ```dart
/// DesktopPetUtils.isValidEmail("test@example.com")
/// ```
///
/// ```dart
/// DesktopPetUtils.isValidPassword("password123")
/// ```
///
/// ```dart
/// DesktopPetUtils.formatToTitleCase("hello world")
/// ```
///
/// ```dart
/// DesktopPetUtils.formatDateTime(DateTime.now())
/// ```
///
class DesktopPetUtils {
  /// 私有构造函数，防止实例化
  DesktopPetUtils._();

  /// 验证邮箱格式
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// 验证密码强度
  static bool isValidPassword(String password, {int minLength = 8}) {
    if (password.length < minLength) return false;
    return true;
  }

  /// 格式化字符串为标题格式
  static String formatToTitleCase(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1).toLowerCase();
  }

  /// 格式化日期时间
  static String formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

}

/// desktop_pet数据验证器
///
/// ## 使用示例
///
/// ```dart
/// DesktopPetValidator.isValidEmail("test@example.com")
/// ```
///
/// ```dart
/// DesktopPetValidator.isValidPassword("password123")
/// ```
///
/// ```dart
/// DesktopPetValidator.validateRequired("value", "字段名")
/// ```
///
class DesktopPetValidator {
  /// 私有构造函数，防止实例化
  DesktopPetValidator._();

  /// 验证邮箱格式
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// 验证密码强度
  static bool isValidPassword(String password, {int minLength = 8}) {
    if (password.length < minLength) return false;
    
    // 至少包含一个数字和一个字母
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    
    return hasNumber && hasLetter;
  }

  /// 验证必填字段
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName不能为空';
    }
    return null;
  }

  /// 验证字符串长度
  static String? validateLength(
    String? value,
    String fieldName, {
    int? minLength,
    int? maxLength,
  }) {
    if (value == null) return null;
    
    if (minLength != null && value.length < minLength) {
      return '$fieldName长度不能少于$minLength个字符';
    }
    
    if (maxLength != null && value.length > maxLength) {
      return '$fieldName长度不能超过$maxLength个字符';
    }
    
    return null;
  }

}

/// desktop_pet数据格式化器
///
/// ## 使用示例
///
/// ```dart
/// DesktopPetFormatter.formatDate(DateTime.now())
/// ```
///
/// ```dart
/// DesktopPetFormatter.formatFileSize(1024)
/// ```
///
/// ```dart
/// DesktopPetFormatter.formatCurrency(99.99)
/// ```
///
class DesktopPetFormatter {
  /// 私有构造函数，防止实例化
  DesktopPetFormatter._();

  /// 格式化日期
  static String formatDate(DateTime date, {String pattern = 'yyyy-MM-dd'}) {
    switch (pattern) {
      case 'yyyy-MM-dd':
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      case 'yyyy-MM-dd HH:mm:ss':
        return '${formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
      case 'MM/dd/yyyy':
        return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
      default:
        return date.toIso8601String();
    }
  }

  /// 格式化文件大小
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// 格式化货币
  static String formatCurrency(double amount, {String symbol = '¥'}) {
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  /// 格式化数字（添加千分位分隔符）
  static String formatNumber(num number) {
    final parts = number.toString().split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? '.${parts[1]}' : '';
    
    final formatted = integerPart.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
    
    return formatted + decimalPart;
  }

}

/// desktop_pet辅助函数集合
///
/// ## 使用示例
///
/// ```dart
/// DesktopPetHelper.generateId()
/// ```
///
/// ```dart
/// DesktopPetHelper.debounce(() => print("执行"), Duration(seconds: 1))
/// ```
///
/// ```dart
/// DesktopPetHelper.retry(() async => await someOperation(), maxAttempts: 3)
/// ```
///
class DesktopPetHelper {
  /// 私有构造函数，防止实例化
  DesktopPetHelper._();

  /// 生成唯一ID
  static String generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999);
    return '$timestamp$random';
  }

}

/// String扩展方法
extension DesktopPetStringExtension on String {
  /// 首字母大写
  String get capitalize {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  /// 是否为空或只包含空白字符
  bool get isBlank => trim().isEmpty;

  /// 是否不为空且不只包含空白字符
  bool get isNotBlank => !isBlank;

}

/// DateTime扩展方法
extension DesktopPetDateTimeExtension on DateTime {
  /// 是否为今天
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// 是否为昨天
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  /// 格式化为友好的时间显示
  String get toFriendlyString {
    if (isToday) return '今天 ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    if (isYesterday) return '昨天 ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    return '${month.toString().padLeft(2, '0')}/${day.toString().padLeft(2, '0')} ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}
