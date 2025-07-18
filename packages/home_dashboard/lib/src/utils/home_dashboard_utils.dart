/*
---------------------------------------------------------------
File name:          home_dashboard_utils.dart
Author:             Pet App Team
Date created:       2025-07-18
Last modified:      2025-07-18
Dart Version:       3.2+
Description:        home_dashboard工具类和辅助函数
---------------------------------------------------------------
Change History:
    2025-07-18: Initial creation - home_dashboard工具类和辅助函数;
---------------------------------------------------------------
*/

import 'dart:math';
import 'dart:async';
import 'dart:convert';

/// home_dashboard主要工具类
///
/// ## 使用示例
///
/// ```dart
/// HomeDashboardUtils.isValidEmail("test@example.com")
/// ```
///
/// ```dart
/// HomeDashboardUtils.isValidPassword("password123")
/// ```
///
/// ```dart
/// HomeDashboardUtils.formatToTitleCase("hello world")
/// ```
///
/// ```dart
/// HomeDashboardUtils.formatDateTime(DateTime.now())
/// ```
///
class HomeDashboardUtils {
  /// 私有构造函数，防止实例化
  HomeDashboardUtils._();

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

/// home_dashboard数据验证器
///
/// ## 使用示例
///
/// ```dart
/// HomeDashboardValidator.isValidEmail("test@example.com")
/// ```
///
/// ```dart
/// HomeDashboardValidator.isValidPassword("password123")
/// ```
///
/// ```dart
/// HomeDashboardValidator.validateRequired("value", "字段名")
/// ```
///
class HomeDashboardValidator {
  /// 私有构造函数，防止实例化
  HomeDashboardValidator._();

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

  /// 验证URL格式
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && uri.hasAuthority;
    } catch (e) {
      return false;
    }
  }

  /// 验证手机号格式（中国大陆）
  static bool isValidPhoneNumber(String phone) {
    final phoneRegex = RegExp(r'^1[3-9]\d{9}$');
    return phoneRegex.hasMatch(phone);
  }

}

/// home_dashboard数据格式化器
///
/// ## 使用示例
///
/// ```dart
/// HomeDashboardFormatter.formatDate(DateTime.now())
/// ```
///
/// ```dart
/// HomeDashboardFormatter.formatFileSize(1024)
/// ```
///
/// ```dart
/// HomeDashboardFormatter.formatCurrency(99.99)
/// ```
///
class HomeDashboardFormatter {
  /// 私有构造函数，防止实例化
  HomeDashboardFormatter._();

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

  /// 格式化相对时间
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

}

/// home_dashboard辅助函数集合
///
/// ## 使用示例
///
/// ```dart
/// HomeDashboardHelper.generateId()
/// ```
///
/// ```dart
/// HomeDashboardHelper.debounce(() => print("执行"), Duration(seconds: 1))
/// ```
///
/// ```dart
/// HomeDashboardHelper.retry(() async => await someOperation(), maxAttempts: 3)
/// ```
///
class HomeDashboardHelper {
  /// 私有构造函数，防止实例化
  HomeDashboardHelper._();

  /// 生成唯一ID
  static String generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999);
    return '$timestamp$random';
  }

  /// 生成UUID
  static String generateUuid() {
    final random = Random();
    final bytes = List<int>.generate(16, (i) => random.nextInt(256));
    
    // 设置版本号和变体
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // 版本4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // 变体
    
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
  }

  /// 防抖函数
  static Timer? _debounceTimer;
  static void debounce(VoidCallback callback, Duration duration) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(duration, callback);
  }

  /// 重试函数
  static Future<T> retry<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await operation();
      } catch (e) {
        if (attempt == maxAttempts) rethrow;
        await Future<void>.delayed(delay * attempt);
      }
    }
    throw StateError('Unreachable code');
  }

  /// 深拷贝Map
  static Map<String, dynamic> deepCopyMap(Map<String, dynamic> original) {
    return Map<String, dynamic>.from(jsonDecode(jsonEncode(original)) as Map);
  }

}

/// String扩展方法
extension HomeDashboardStringExtension on String {
  /// 首字母大写
  String get capitalize {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  /// 是否为空或只包含空白字符
  bool get isBlank => trim().isEmpty;

  /// 是否不为空且不只包含空白字符
  bool get isNotBlank => !isBlank;

  /// 转换为驼峰命名
  String get toCamelCase {
    final words = split(RegExp(r'[\s_-]+'));
    if (words.isEmpty) return this;
    
    final first = words.first.toLowerCase();
    final rest = words.skip(1).map((word) => word.capitalize);
    
    return first + rest.join();
  }

  /// 转换为蛇形命名
  String get toSnakeCase {
    return replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    ).replaceFirst(RegExp(r'^\_'), '');
  }

}

/// DateTime扩展方法
extension HomeDashboardDateTimeExtension on DateTime {
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
