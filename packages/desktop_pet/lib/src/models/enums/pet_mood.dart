/*
---------------------------------------------------------------
File name:          pet_mood.dart
Author:             lgnorant-lu
Date created:       2025-07-21
Last modified:      2025-07-21
Dart Version:       3.2+
Description:        桌宠心情枚举 - 定义桌宠的各种心情状态
---------------------------------------------------------------
*/

/// 桌宠心情枚举
/// 
/// 定义桌宠的各种心情状态，影响桌宠的行为和外观
enum PetMood {
  /// 开心 - 桌宠处于愉快状态
  happy('happy', '开心', '😊'),
  
  /// 兴奋 - 桌宠处于兴奋状态
  excited('excited', '兴奋', '🤩'),
  
  /// 平静 - 桌宠处于平静状态
  calm('calm', '平静', '😌'),
  
  /// 困倦 - 桌宠感到疲倦
  sleepy('sleepy', '困倦', '😴'),
  
  /// 饥饿 - 桌宠需要食物
  hungry('hungry', '饥饿', '🤤'),
  
  /// 无聊 - 桌宠感到无聊
  bored('bored', '无聊', '😑'),
  
  /// 好奇 - 桌宠对周围环境感兴趣
  curious('curious', '好奇', '🤔'),
  
  /// 生气 - 桌宠感到不满
  angry('angry', '生气', '😠'),
  
  /// 悲伤 - 桌宠感到难过
  sad('sad', '悲伤', '😢'),
  
  /// 害怕 - 桌宠感到恐惧
  scared('scared', '害怕', '😨'),
  
  /// 生病 - 桌宠身体不适
  sick('sick', '生病', '🤒'),
  
  /// 爱心 - 桌宠感受到关爱
  loving('loving', '爱心', '🥰');

  const PetMood(this.id, this.displayName, this.emoji);

  /// 心情ID
  final String id;
  
  /// 显示名称
  final String displayName;
  
  /// 心情表情符号
  final String emoji;

  /// 从ID获取心情
  static PetMood fromId(String id) => PetMood.values.firstWhere(
      (PetMood mood) => mood.id == id,
      orElse: () => PetMood.calm,
    );

  /// 获取所有积极心情
  static List<PetMood> get positiveMoods => <PetMood>[
    PetMood.happy,
    PetMood.excited,
    PetMood.calm,
    PetMood.curious,
    PetMood.loving,
  ];

  /// 获取所有消极心情
  static List<PetMood> get negativeMoods => <PetMood>[
    PetMood.angry,
    PetMood.sad,
    PetMood.scared,
    PetMood.sick,
    PetMood.bored,
  ];

  /// 获取所有中性心情
  static List<PetMood> get neutralMoods => <PetMood>[
    PetMood.sleepy,
    PetMood.hungry,
  ];

  /// 判断是否为积极心情
  bool get isPositive => positiveMoods.contains(this);

  /// 判断是否为消极心情
  bool get isNegative => negativeMoods.contains(this);

  /// 判断是否为中性心情
  bool get isNeutral => neutralMoods.contains(this);

  /// 获取心情值 (-1到1之间，-1最消极，1最积极)
  double get moodValue {
    switch (this) {
      case PetMood.excited:
      case PetMood.loving:
        return 1;
      case PetMood.happy:
        return 0.8;
      case PetMood.curious:
        return 0.6;
      case PetMood.calm:
        return 0.4;
      case PetMood.sleepy:
      case PetMood.hungry:
        return 0;
      case PetMood.bored:
        return -0.3;
      case PetMood.sad:
        return -0.6;
      case PetMood.angry:
        return -0.7;
      case PetMood.scared:
      case PetMood.sick:
        return -1;
    }
  }

  @override
  String toString() => displayName;
}
