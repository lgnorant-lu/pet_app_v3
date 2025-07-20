/*
---------------------------------------------------------------
File name:          pet_control_panel.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        桌宠控制面板 - 桌宠操作和行为控制
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/pet/models/pet_entity.dart';
import '../../../../core/providers/pet_behavior_provider.dart';
import '../../../../core/providers/pet_provider.dart';
import '../../../../core/pet/enums/pet_mood.dart';
import '../../../../core/pet/enums/pet_activity.dart';

/// 桌宠控制面板
class PetControlPanel extends ConsumerWidget {
  final PetEntity pet;
  final PetBehaviorState behaviorState;

  const PetControlPanel({
    super.key,
    required this.pet,
    required this.behaviorState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 快速操作区域
          _buildQuickActions(context, ref),
          
          const SizedBox(height: 16),
          
          // 行为控制区域
          _buildBehaviorControl(context, ref),
          
          const SizedBox(height: 16),
          
          // 心情调节区域
          _buildMoodControl(context, ref),
          
          const SizedBox(height: 16),
          
          // 活动选择区域
          _buildActivityControl(context, ref),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '快速操作',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6C63FF),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.restaurant,
                  label: '喂食',
                  color: Colors.orange,
                  onPressed: () => _feedPet(ref),
                  enabled: pet.hunger > 30,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.cleaning_services,
                  label: '清洁',
                  color: Colors.cyan,
                  onPressed: () => _cleanPet(ref),
                  enabled: pet.cleanliness < 80,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.sports_esports,
                  label: '玩耍',
                  color: Colors.pink,
                  onPressed: () => _playWithPet(ref),
                  enabled: pet.energy > 20,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.hotel,
                  label: '休息',
                  color: Colors.blue,
                  onPressed: () => _restPet(ref),
                  enabled: pet.energy < 80,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBehaviorControl(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '行为控制',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6C63FF),
                ),
              ),
              const Spacer(),
              Switch(
                value: behaviorState.isEnabled,
                onChanged: (value) => _toggleBehaviorSystem(ref, value),
                activeColor: const Color(0xFF6C63FF),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // 当前行为显示
          if (behaviorState.currentBehavior != null)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue),
              ),
              child: Row(
                children: [
                  const Icon(Icons.play_arrow, color: Colors.blue, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '正在执行: ${behaviorState.currentBehavior!.name}',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          // 可用行为列表
          if (behaviorState.availableBehaviors.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '可用行为',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 100,
              child: ListView.builder(
                itemCount: behaviorState.availableBehaviors.length,
                itemBuilder: (context, index) {
                  final behavior = behaviorState.availableBehaviors[index];
                  return ListTile(
                    dense: true,
                    title: Text(
                      behavior.name,
                      style: const TextStyle(fontSize: 12),
                    ),
                    subtitle: Text(
                      behavior.description,
                      style: const TextStyle(fontSize: 10),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.play_arrow, size: 16),
                      onPressed: () => _triggerBehavior(ref, behavior.id),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMoodControl(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '心情调节',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6C63FF),
            ),
          ),
          const SizedBox(height: 12),
          
          // 当前心情显示
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getMoodColor(pet.mood).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _getMoodColor(pet.mood)),
            ),
            child: Row(
              children: [
                Text(
                  pet.mood.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '当前心情: ${pet.mood.displayName}',
                    style: TextStyle(
                      color: _getMoodColor(pet.mood),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 心情调节按钮
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildMoodButton(
                mood: PetMood.happy,
                onPressed: () => _changeMood(ref, PetMood.happy),
              ),
              _buildMoodButton(
                mood: PetMood.excited,
                onPressed: () => _changeMood(ref, PetMood.excited),
              ),
              _buildMoodButton(
                mood: PetMood.calm,
                onPressed: () => _changeMood(ref, PetMood.calm),
              ),
              _buildMoodButton(
                mood: PetMood.curious,
                onPressed: () => _changeMood(ref, PetMood.curious),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityControl(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '活动选择',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6C63FF),
            ),
          ),
          const SizedBox(height: 12),
          
          // 当前活动显示
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
            ),
            child: Row(
              children: [
                Text(
                  pet.currentActivity.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '当前活动: ${pet.currentActivity.displayName}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 活动选择按钮
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildActivityButton(
                activity: PetActivity.playing,
                onPressed: () => _changeActivity(ref, PetActivity.playing),
              ),
              _buildActivityButton(
                activity: PetActivity.learning,
                onPressed: () => _changeActivity(ref, PetActivity.learning),
              ),
              _buildActivityButton(
                activity: PetActivity.exploring,
                onPressed: () => _changeActivity(ref, PetActivity.exploring),
              ),
              _buildActivityButton(
                activity: PetActivity.sleeping,
                onPressed: () => _changeActivity(ref, PetActivity.sleeping),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    bool enabled = true,
  }) {
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: enabled ? color : Colors.grey,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodButton({
    required PetMood mood,
    required VoidCallback onPressed,
  }) {
    final isSelected = pet.mood == mood;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? _getMoodColor(mood) : Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(mood.emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text(
              mood.displayName,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityButton({
    required PetActivity activity,
    required VoidCallback onPressed,
  }) {
    final isSelected = pet.currentActivity == activity;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(activity.emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text(
              activity.displayName,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getMoodColor(PetMood mood) {
    if (mood.isPositive) return Colors.green;
    if (mood.isNegative) return Colors.red;
    return Colors.orange;
  }

  void _feedPet(WidgetRef ref) {
    ref.read(petProvider.notifier).feedPet(pet.id);
  }

  void _cleanPet(WidgetRef ref) {
    ref.read(petProvider.notifier).cleanPet(pet.id);
  }

  void _playWithPet(WidgetRef ref) {
    ref.read(petProvider.notifier).playWithPet(pet.id);
  }

  void _restPet(WidgetRef ref) {
    ref.read(petProvider.notifier).updatePetActivity(pet.id, PetActivity.sleeping);
  }

  void _toggleBehaviorSystem(WidgetRef ref, bool enabled) {
    ref.read(petBehaviorProvider.notifier).setBehaviorSystemEnabled(enabled);
  }

  void _triggerBehavior(WidgetRef ref, String behaviorId) {
    ref.read(petBehaviorProvider.notifier).triggerBehavior(behaviorId, pet.id);
  }

  void _changeMood(WidgetRef ref, PetMood mood) {
    ref.read(petProvider.notifier).updatePetMood(pet.id, mood);
  }

  void _changeActivity(WidgetRef ref, PetActivity activity) {
    ref.read(petProvider.notifier).updatePetActivity(pet.id, activity);
  }
}
