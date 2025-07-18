/*
---------------------------------------------------------------
File name:          settings_system_model.dart
Author:             Pet App Team
Date created:       2025-07-18
Last modified:      2025-07-18
Dart Version:       3.2+
Description:        settings_system数据模型类
---------------------------------------------------------------
Change History:
    2025-07-18: Initial creation - settings_system数据模型类;
---------------------------------------------------------------
*/

import 'package:equatable/equatable.dart';

/// settings_system数据模型
///
/// ## 使用示例
///
/// ```dart
/// final model = SettingsSystemModel(id: 1, name: '示例');
/// ```
///
/// ```dart
/// final json = model.toJson();
/// ```
///
/// ```dart
/// final fromJson = SettingsSystemModel.fromJson(json);
/// ```
///
class SettingsSystemModel extends Equatable {
  /// 唯一标识符
  final int id;

  /// 名称
  final String name;

  /// 描述
  final String? description;

  /// 状态
  final String status;

  /// 元数据
  final Map<String, dynamic>? metadata;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;

  /// 创建SettingsSystemModel实例
  SettingsSystemModel({
    required this.id,
    required this.name,
    this.description,
    this.status = 'active',
    this.metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// 从JSON创建实例
  factory SettingsSystemModel.fromJson(Map<String, dynamic> json) {
    return SettingsSystemModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'active',
      metadata: json['metadata'] != null ? Map<String, dynamic>.from(json['metadata'] as Map<String, dynamic>) : <String, dynamic>{},
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      'status': status,
      if (metadata != null) 'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 创建副本并更新指定字段
  SettingsSystemModel copyWith({
    int? id,
    String? name,
    String? description,
    String? status,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SettingsSystemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        status,
        metadata,
        createdAt,
        updatedAt,
      ];
}

/// settings_system列表响应模型
///
class SettingsSystemModelListResponse extends Equatable {
  /// 数据列表
  final List<SettingsSystemModel> data;

  /// 总数量
  final int total;

  /// 当前页
  final int page;

  /// 每页数量
  final int perPage;

  /// 总页数
  final int totalPages;

  /// 创建SettingsSystemModelListResponse实例
  const SettingsSystemModelListResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.perPage,
    required this.totalPages,
  });

  /// 从JSON创建实例
  factory SettingsSystemModelListResponse.fromJson(Map<String, dynamic> json) {
    return SettingsSystemModelListResponse(
      data: (json['data'] as List)
          .map((item) => SettingsSystemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      perPage: json['per_page'] as int,
      totalPages: json['total_pages'] as int,
    );
  }

  @override
  List<Object?> get props => [data, total, page, perPage, totalPages];
}

/// settings_system创建请求模型
///
class SettingsSystemModelCreateRequest extends Equatable {
  /// 名称
  final String name;

  /// 描述
  final String? description;

  /// 元数据
  final Map<String, dynamic>? metadata;

  /// 创建SettingsSystemModelCreateRequest实例
  const SettingsSystemModelCreateRequest({
    required this.name,
    this.description,
    this.metadata,
  });

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null) 'description': description,
      if (metadata != null) 'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [name, description, metadata];
}

/// settings_system更新请求模型
///
class SettingsSystemModelUpdateRequest extends Equatable {
  /// 名称
  final String? name;

  /// 描述
  final String? description;

  /// 状态
  final String? status;

  /// 元数据
  final Map<String, dynamic>? metadata;

  /// 创建SettingsSystemModelUpdateRequest实例
  const SettingsSystemModelUpdateRequest({
    this.name,
    this.description,
    this.status,
    this.metadata,
  });

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (name != null) json['name'] = name;
    if (description != null) json['description'] = description;
    if (status != null) json['status'] = status;
    if (metadata != null) json['metadata'] = metadata;
    return json;
  }

  @override
  List<Object?> get props => [name, description, status, metadata];
}

