/*
---------------------------------------------------------------
File name:          app_manager_constants.dart
Author:             Pet App Team
Date created:       2025-07-18
Last modified:      2025-07-18
Dart Version:       3.2+
Description:        app_manager应用程序常量定义
---------------------------------------------------------------
Change History:
    2025-07-18: Initial creation - app_manager应用程序常量定义;
---------------------------------------------------------------
*/

/// app_manager主要常量类
///
/// ## 使用示例
///
/// ```dart
/// AppManagerConstants.appName
/// ```
///
/// ```dart
/// AppManagerConstants.appVersion
/// ```
///
/// ```dart
/// AppManagerConstants.defaultTimeout
/// ```
///
/// ```dart
/// AppManagerConstants.maxRetryAttempts
/// ```
///
class AppManagerConstants {
  /// 私有构造函数，防止实例化
  AppManagerConstants._();

  /// 应用名称
  static const String appName = 'AppManager';

  /// 应用版本
  static const String appVersion = '1.0.0';

  /// 默认超时时间
  static const Duration defaultTimeout = Duration(seconds: 30);

  /// 最大重试次数
  static const int maxRetryAttempts = 3;

  /// 默认页面大小
  static const int defaultPageSize = 20;

  /// 支持的语言
  static const List<String> supportedLanguages = ['en', 'zh'];

  /// 默认语言
  static const String defaultLanguage = 'en';

}

/// app_manager应用程序基础常量
///
/// ## 使用示例
///
/// ```dart
/// AppManagerAppConstants.appName
/// ```
///
/// ```dart
/// AppManagerAppConstants.version
/// ```
///
/// ```dart
/// AppManagerAppConstants.buildNumber
/// ```
///
class AppManagerAppConstants {
  /// 私有构造函数，防止实例化
  AppManagerAppConstants._();

  /// 应用名称
  static const String appName = 'AppManager';

  /// 应用版本
  static const String version = '1.0.0';

  /// 构建号
  static const int buildNumber = 1;

  /// 应用包名
  static const String packageName = 'com.example.app_manager';

  /// 开发环境
  static const String envDevelopment = 'development';

  /// 测试环境
  static const String envTesting = 'testing';

  /// 生产环境
  static const String envProduction = 'production';

  /// 默认超时时间（秒）
  static const int defaultTimeoutSeconds = 30;

  /// 默认分页大小
  static const int defaultPageSize = 20;

  /// 最大分页大小
  static const int maxPageSize = 100;

  /// 缓存过期时间（毫秒）
  static const int cacheExpirationMs = 300000; // 5分钟

  /// 最大重试次数
  static const int maxRetryAttempts = 3;

  /// 重试延迟（毫秒）
  static const int retryDelayMs = 1000;

}

/// app_managerAPI相关常量
///
/// ## 使用示例
///
/// ```dart
/// AppManagerApiConstants.baseUrl
/// ```
///
/// ```dart
/// AppManagerApiConstants.endpoints.users
/// ```
///
/// ```dart
/// AppManagerApiConstants.headers.contentType
/// ```
///
class AppManagerApiConstants {
  /// 私有构造函数，防止实例化
  AppManagerApiConstants._();

  /// 开发环境API基础URL
  static const String baseUrlDev = 'https://api-dev.example.com';

  /// 测试环境API基础URL
  static const String baseUrlTest = 'https://api-test.example.com';

  /// 生产环境API基础URL
  static const String baseUrlProd = 'https://api.example.com';

  /// 当前环境API基础URL
  static const String baseUrl = baseUrlDev; // TODO: 根据环境配置

  /// API端点
  static const ApiEndpoints endpoints = ApiEndpoints._();

  /// HTTP头部
  static const ApiHeaders headers = ApiHeaders._();

  /// HTTP状态码
  static const ApiStatusCodes statusCodes = ApiStatusCodes._();

}

/// API端点常量
class ApiEndpoints {
  const ApiEndpoints._();

  /// 用户相关端点
  String get users => '/api/v1/users';
  String get userProfile => '/api/v1/users/profile';
  String get userById => '/api/v1/users/{id}';

  /// 认证相关端点
  String get login => '/api/v1/auth/login';
  String get logout => '/api/v1/auth/logout';
  String get refresh => '/api/v1/auth/refresh';

  /// app_manager相关端点
  String get app_managers => '/api/v1/app_managers';
  String get app_managerById => '/api/v1/app_managers/{id}';

}

/// HTTP头部常量
class ApiHeaders {
  const ApiHeaders._();

  /// Content-Type
  String get contentType => 'Content-Type';
  String get contentTypeJson => 'application/json';
  String get contentTypeForm => 'application/x-www-form-urlencoded';

  /// Authorization
  String get authorization => 'Authorization';
  String get bearer => 'Bearer';

  /// Accept
  String get accept => 'Accept';
  String get acceptJson => 'application/json';

  /// User-Agent
  String get userAgent => 'User-Agent';
  String get defaultUserAgent => 'AppManager/1.0.0';

}

/// HTTP状态码常量
class ApiStatusCodes {
  const ApiStatusCodes._();

  /// 成功状态码
  int get ok => 200;
  int get created => 201;
  int get accepted => 202;
  int get noContent => 204;

  /// 客户端错误状态码
  int get badRequest => 400;
  int get unauthorized => 401;
  int get forbidden => 403;
  int get notFound => 404;
  int get methodNotAllowed => 405;
  int get conflict => 409;
  int get unprocessableEntity => 422;
  int get tooManyRequests => 429;

  /// 服务器错误状态码
  int get internalServerError => 500;
  int get badGateway => 502;
  int get serviceUnavailable => 503;
  int get gatewayTimeout => 504;

}

/// app_manager配置相关常量
///
/// ## 使用示例
///
/// ```dart
/// AppManagerConfigConstants.database.name
/// ```
///
/// ```dart
/// AppManagerConfigConstants.storage.cacheDir
/// ```
///
/// ```dart
/// AppManagerConfigConstants.logging.level
/// ```
///
class AppManagerConfigConstants {
  /// 私有构造函数，防止实例化
  AppManagerConfigConstants._();

  /// 数据库配置
  static const DatabaseConfig database = DatabaseConfig._();

  /// 存储配置
  static const StorageConfig storage = StorageConfig._();

  /// 日志配置
  static const LoggingConfig logging = LoggingConfig._();

}

/// 数据库配置常量
class DatabaseConfig {
  const DatabaseConfig._();

  String get name => 'app_manager.db';
  int get version => 1;
  int get connectionPoolSize => 10;
  Duration get connectionTimeout => const Duration(seconds: 30);

}

/// 存储配置常量
class StorageConfig {
  const StorageConfig._();

  String get cacheDir => 'cache';
  String get tempDir => 'temp';
  String get dataDir => 'data';
  String get logDir => 'logs';

  /// 最大缓存大小（字节）
  int get maxCacheSize => 100 * 1024 * 1024; // 100MB

  /// 最大日志文件大小（字节）
  int get maxLogFileSize => 10 * 1024 * 1024; // 10MB

}

/// 日志配置常量
class LoggingConfig {
  const LoggingConfig._();

  String get level => 'INFO';
  String get format => '[{timestamp}] {level}: {message}';
  bool get enableConsole => true;
  bool get enableFile => true;
  int get maxFiles => 7; // 保留7天的日志

}

/// app_manager错误相关常量
///
/// ## 使用示例
///
/// ```dart
/// AppManagerErrorConstants.codes.networkError
/// ```
///
/// ```dart
/// AppManagerErrorConstants.messages.invalidInput
/// ```
///
/// ```dart
/// AppManagerErrorConstants.types.validation
/// ```
///
class AppManagerErrorConstants {
  /// 私有构造函数，防止实例化
  AppManagerErrorConstants._();

  /// 错误代码
  static const ErrorCodes codes = ErrorCodes._();

  /// 错误消息
  static const ErrorMessages messages = ErrorMessages._();

  /// 错误类型
  static const ErrorTypes types = ErrorTypes._();

}

/// 错误代码常量
class ErrorCodes {
  const ErrorCodes._();

  String get unknown => 'UNKNOWN_ERROR';
  String get networkError => 'NETWORK_ERROR';
  String get timeoutError => 'TIMEOUT_ERROR';
  String get validationError => 'VALIDATION_ERROR';
  String get authenticationError => 'AUTHENTICATION_ERROR';
  String get authorizationError => 'AUTHORIZATION_ERROR';
  String get notFoundError => 'NOT_FOUND_ERROR';
  String get serverError => 'SERVER_ERROR';

}

/// 错误消息常量
class ErrorMessages {
  const ErrorMessages._();

  String get unknown => '发生未知错误';
  String get networkError => '网络连接失败，请检查网络设置';
  String get timeoutError => '请求超时，请稍后重试';
  String get validationError => '输入数据验证失败';
  String get authenticationError => '身份验证失败，请重新登录';
  String get authorizationError => '权限不足，无法执行此操作';
  String get notFoundError => '请求的资源不存在';
  String get serverError => '服务器内部错误，请稍后重试';

}

/// 错误类型常量
class ErrorTypes {
  const ErrorTypes._();

  String get network => 'network';
  String get validation => 'validation';
  String get authentication => 'authentication';
  String get authorization => 'authorization';
  String get business => 'business';
  String get system => 'system';

}
