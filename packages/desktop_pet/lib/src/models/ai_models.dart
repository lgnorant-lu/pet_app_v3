/*
---------------------------------------------------------------
File name:          ai_models.dart
Author:             lgnorant-lu
Date created:       2025-07-21
Last modified:      2025-07-21
Dart Version:       3.2+
Description:        AI相关数据模型 - 定义AI学习和记忆相关的数据结构
---------------------------------------------------------------
*/

/// AI记忆模型
///
/// 存储桌宠的学习历史和行为偏好
class AIMemory {

  const AIMemory({
    required this.petId,
    required this.createdAt, required this.updatedAt, this.behaviorHistory = const <BehaviorRecord>[],
    this.learningProgress = 0.0,
  });

  /// 创建新的AI记忆
  factory AIMemory.create(String petId) {
    final DateTime now = DateTime.now();
    return AIMemory(
      petId: petId,
      createdAt: now,
      updatedAt: now,
    );
  }
  /// 桌宠ID
  final String petId;

  /// 行为历史记录
  final List<BehaviorRecord> behaviorHistory;

  /// 学习进度 (0.0-1.0)
  final double learningProgress;

  /// 创建时间
  final DateTime createdAt;

  /// 最后更新时间
  final DateTime updatedAt;

  /// 记录行为结果
  AIMemory recordBehaviorResult(
    String behaviorId,
    bool success,
    double satisfaction,
  ) {
    final record = BehaviorRecord(
      behaviorId: behaviorId,
      success: success,
      satisfaction: satisfaction,
      timestamp: DateTime.now(),
    );

    final newHistory = <BehaviorRecord>[...behaviorHistory, record];
    final newProgress = _calculateLearningProgress(newHistory);

    return AIMemory(
      petId: petId,
      behaviorHistory: newHistory,
      learningProgress: newProgress,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// 获取特定行为的历史记录
  List<BehaviorRecord> getBehaviorHistory(String behaviorId) => behaviorHistory
        .where((BehaviorRecord record) => record.behaviorId == behaviorId)
        .toList();

  /// 获取最近的成功率
  double getRecentSuccessRate(int count) {
    if (behaviorHistory.isEmpty) return 0;

    final recentRecords = behaviorHistory
        .skip((behaviorHistory.length - count).clamp(0, behaviorHistory.length))
        .toList();

    if (recentRecords.isEmpty) return 0;

    final successCount = recentRecords.where((BehaviorRecord r) => r.success).length;
    return successCount / recentRecords.length;
  }

  /// 获取顶级偏好
  List<String> getTopPreferences(int count) {
    if (behaviorHistory.isEmpty) return <String>[];

    // 按行为ID分组并计算平均满意度
    final behaviorSatisfaction = <String, List<double>>{};

    for (final record in behaviorHistory) {
      behaviorSatisfaction.putIfAbsent(record.behaviorId, () => <double>[]);
      behaviorSatisfaction[record.behaviorId]!.add(record.satisfaction);
    }

    // 计算平均满意度并排序
    final avgSatisfaction = behaviorSatisfaction.entries.map((MapEntry<String, List<double>> entry) {
      final avg = entry.value.reduce((double a, double b) => a + b) / entry.value.length;
      return MapEntry(entry.key, avg);
    }).toList()
      ..sort((MapEntry<String, double> a, MapEntry<String, double> b) => b.value.compareTo(a.value));

    return avgSatisfaction.take(count).map((MapEntry<String, double> entry) => entry.key).toList();
  }

  /// 计算学习进度
  double _calculateLearningProgress(List<BehaviorRecord> history) {
    if (history.isEmpty) return 0;

    // 基于行为数量和成功率计算进度
    final behaviorCount = history.length;
    final successRate = getRecentSuccessRate(20);

    // 行为数量贡献 (最多50%)
    final countProgress = (behaviorCount / 100.0).clamp(0.0, 0.5);

    // 成功率贡献 (最多50%)
    final successProgress = successRate * 0.5;

    return (countProgress + successProgress).clamp(0.0, 1.0);
  }
}

/// 行为记录模型
///
/// 记录单次行为的执行结果
class BehaviorRecord {

  const BehaviorRecord({
    required this.behaviorId,
    required this.success,
    required this.satisfaction,
    required this.timestamp,
  });
  /// 行为ID
  final String behaviorId;

  /// 是否成功
  final bool success;

  /// 满意度 (0.0-1.0)
  final double satisfaction;

  /// 记录时间
  final DateTime timestamp;
}

/// AI状态模型
///
/// 表示桌宠AI的当前状态和能力
class AIStatus {

  const AIStatus({
    required this.learningProgress,
    required this.behaviorCount,
    required this.adaptationLevel,
    required this.preferences,
  });
  /// 学习进度 (0.0-1.0)
  final double learningProgress;

  /// 行为记录数量
  final int behaviorCount;

  /// 适应水平 (0.0-1.0)
  final double adaptationLevel;

  /// 偏好行为列表
  final List<String> preferences;

  /// 获取AI等级
  String get aiLevel {
    if (learningProgress < 0.2) return '新手';
    if (learningProgress < 0.4) return '学习中';
    if (learningProgress < 0.6) return '适应中';
    if (learningProgress < 0.8) return '熟练';
    return '专家';
  }

  /// 判断是否为高级AI
  bool get isAdvanced => learningProgress >= 0.6;
}
