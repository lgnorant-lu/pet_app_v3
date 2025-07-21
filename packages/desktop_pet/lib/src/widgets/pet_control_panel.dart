/*
---------------------------------------------------------------
File name:          pet_control_panel.dart
Author:             lgnorant-lu
Date created:       2025-07-21
Last modified:      2025-07-21
Dart Version:       3.2+
Description:        桌宠控制面板 - 桌宠的操作控制界面
---------------------------------------------------------------
*/

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:desktop_pet/src/models/index.dart';
import 'package:desktop_pet/src/providers/pet_provider.dart';

/// 桌宠控制面板
///
/// 提供桌宠的基本操作控制界面
class PetControlPanel extends ConsumerWidget {
  const PetControlPanel({
    required this.pet,
    super.key,
    this.isCompact = false,
  });

  /// 桌宠实体
  final PetEntity pet;

  /// 是否紧凑模式
  final bool isCompact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petState = ref.watch(petStateProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 标题
          _buildHeader(context),

          const SizedBox(height: 16),

          // 基本操作按钮
          _buildActionButtons(context, ref),

          if (!isCompact) ...<Widget>[
            const SizedBox(height: 16),

            // 状态显示
            _buildStatusDisplay(context),

            const SizedBox(height: 16),

            // 快速统计
            _buildQuickStats(context),
          ],

          // 错误显示
          if (petState.error != null) ...<Widget>[
            const SizedBox(height: 12),
            _buildErrorDisplay(context, petState.error!, ref),
          ],
        ],
      ),
    );
  }

  /// 构建标题
  Widget _buildHeader(BuildContext context) => Row(
        children: <Widget>[
          Icon(
            Icons.pets,
            color: Theme.of(context).primaryColor,
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  pet.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '${pet.type} • ${pet.ageStage}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
          _buildStatusChip(context),
        ],
      );

  /// 构建状态芯片
  Widget _buildStatusChip(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getStatusColor().withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getStatusColor(),
          ),
        ),
        child: Text(
          pet.status.displayName,
          style: TextStyle(
            color: _getStatusColor(),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      );

  /// 获取状态颜色
  Color _getStatusColor() {
    if (pet.status.isHealthy) {
      return Colors.green;
    } else if (pet.status.needsAttention) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  /// 构建操作按钮
  Widget _buildActionButtons(BuildContext context, WidgetRef ref) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: <Widget>[
          _buildActionButton(
            context: context,
            icon: Icons.restaurant,
            label: '喂食',
            color: Colors.orange,
            onPressed: () => _feedPet(ref),
          ),
          _buildActionButton(
            context: context,
            icon: Icons.cleaning_services,
            label: '清洁',
            color: Colors.blue,
            onPressed: () => _cleanPet(ref),
          ),
          _buildActionButton(
            context: context,
            icon: Icons.sports_esports,
            label: '玩耍',
            color: Colors.green,
            onPressed: () => _playWithPet(ref),
          ),
          _buildActionButton(
            context: context,
            icon: Icons.chat,
            label: '聊天',
            color: Colors.purple,
            onPressed: () => _talkToPet(ref),
          ),
        ],
      );

  /// 构建单个操作按钮
  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) =>
      ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );

  /// 构建状态显示
  Widget _buildStatusDisplay(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '状态',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(child: _buildStatBar('健康', pet.health, Colors.red)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildStatBar('快乐', pet.happiness, Colors.yellow)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(child: _buildStatBar('能量', pet.energy, Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatBar('饥饿', pet.hunger, Colors.orange)),
            ],
          ),
        ],
      );

  /// 构建状态条
  Widget _buildStatBar(String label, int value, Color color) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                label,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              Text(
                '$value%',
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: value / 100.0,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      );

  /// 构建快速统计
  Widget _buildQuickStats(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '信息',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          _buildInfoRow('心情', pet.mood.displayName),
          _buildInfoRow('活动', pet.currentActivity.displayName),
          _buildInfoRow('年龄', '${pet.ageInDays} 天'),
          _buildInfoRow('品种', pet.breed),
        ],
      );

  /// 构建信息行
  Widget _buildInfoRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );

  /// 构建错误显示
  Widget _buildErrorDisplay(
          BuildContext context, String error, WidgetRef ref) =>
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Row(
          children: <Widget>[
            const Icon(Icons.error, color: Colors.red, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
            IconButton(
              onPressed: () => ref.read(petStateProvider.notifier).clearError(),
              icon: const Icon(Icons.close, size: 16),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      );

  /// 喂食桌宠
  void _feedPet(WidgetRef ref) {
    ref.read(petStateProvider.notifier).feedPet(pet.id);
  }

  /// 清洁桌宠
  void _cleanPet(WidgetRef ref) {
    ref.read(petStateProvider.notifier).cleanPet(pet.id);
  }

  /// 与桌宠玩耍
  void _playWithPet(WidgetRef ref) {
    ref.read(petStateProvider.notifier).interactWithPet(pet.id, 'play');
  }

  /// 与桌宠聊天
  void _talkToPet(WidgetRef ref) {
    ref.read(petStateProvider.notifier).interactWithPet(pet.id, 'talk');
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<PetEntity>('pet', pet));
    properties.add(DiagnosticsProperty<bool>('isCompact', isCompact));
  }
}
