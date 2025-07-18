/*
---------------------------------------------------------------
File name:          desktop_pet_model.dart
Author:             Pet App Team
Date created:       2025-07-18
Last modified:      2025-07-18
Dart Version:       3.2+
Description:        desktop_pet数据模型类
---------------------------------------------------------------
Change History:
    2025-07-18: Initial creation - desktop_pet数据模型类;
---------------------------------------------------------------
*/

/// desktop_pet数据模型
///
/// ## 使用示例
///
/// ```dart
/// final model = DesktopPetModel(id: 1, name: '示例');
/// ```
///
/// ```dart
/// final json = model.toJson();
/// ```
///
/// ```dart
/// final fromJson = DesktopPetModel.fromJson(json);
/// ```
///
class DesktopPetModel {
  /// 唯一标识符
  final int id;

  /// 名称
  final String name;

  /// 描述
  final String? description;

  /// 创建时间
  final DateTime? createdAt;

  /// 创建DesktopPetModel实例
  const DesktopPetModel({
    required this.id,
    required this.name,
    this.description,
    this.createdAt,
  });

  @override
  String toString() {
    return 'DesktopPetModel(id: $id, name: $name, description: $description, createdAt: $createdAt)';
  }
}

