/*
---------------------------------------------------------------
File name:          index.dart
Author:             lgnorant-lu
Date created:       2025-07-21
Last modified:      2025-07-21
Dart Version:       3.2+
Description:        桌宠枚举导出文件 - 统一导出所有桌宠枚举
---------------------------------------------------------------
*/

/// 桌宠枚举导出
///
/// 从 desktop_pet 模块重新导出所有桌宠相关的枚举类型
library;

// 从 desktop_pet 模块导入所有枚举
export 'package:desktop_pet/desktop_pet.dart'
    show
        ActionType,
        PetActivity,
        PetInteractionMode,
        PetMood,
        PetStatus,
        TriggerType;
