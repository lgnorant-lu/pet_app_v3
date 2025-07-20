/*
---------------------------------------------------------------
File name:          pet_status_bar.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        桌宠状态栏 - 显示桌宠的各项状态指标
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import '../../../../core/pet/models/pet_entity.dart';

/// 桌宠状态栏
class PetStatusBar extends StatelessWidget {
  final PetEntity pet;

  const PetStatusBar({
    super.key,
    required this.pet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
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
        children: [
          // 桌宠基本信息
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: _getPetColor(),
                child: Text(
                  pet.name.isNotEmpty ? pet.name[0] : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Lv.${pet.level} • ${pet.ageStage}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              // 总体评分
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getScoreColor(pet.overallScore),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${pet.overallScore}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 状态指标
          Row(
            children: [
              Expanded(
                child: _buildStatusIndicator(
                  icon: Icons.favorite,
                  label: '健康',
                  value: pet.health,
                  color: Colors.red,
                ),
              ),
              Expanded(
                child: _buildStatusIndicator(
                  icon: Icons.battery_charging_full,
                  label: '能量',
                  value: pet.energy,
                  color: Colors.blue,
                ),
              ),
              Expanded(
                child: _buildStatusIndicator(
                  icon: Icons.restaurant,
                  label: '饱食',
                  value: 100 - pet.hunger,
                  color: Colors.orange,
                ),
              ),
              Expanded(
                child: _buildStatusIndicator(
                  icon: Icons.sentiment_satisfied,
                  label: '快乐',
                  value: pet.happiness,
                  color: Colors.pink,
                ),
              ),
              Expanded(
                child: _buildStatusIndicator(
                  icon: Icons.cleaning_services,
                  label: '清洁',
                  value: pet.cleanliness,
                  color: Colors.cyan,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 经验值进度条
          _buildExperienceBar(),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator({
    required IconData icon,
    required String label,
    required int value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: color,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 4,
          width: 40,
          child: LinearProgressIndicator(
            value: value / 100,
            backgroundColor: Colors.grey.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildExperienceBar() {
    final nextLevelExp = pet.level * 100;
    final currentLevelExp = (pet.level - 1) * 100;
    final progress = (pet.experience - currentLevelExp) / (nextLevelExp - currentLevelExp);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '经验值',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            Text(
              '${pet.experience}/${nextLevelExp}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: Colors.grey.withOpacity(0.3),
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
        ),
      ],
    );
  }

  Color _getPetColor() {
    switch (pet.color.toLowerCase()) {
      case 'orange':
        return const Color(0xFFFF8C42);
      case 'black':
        return const Color(0xFF2C2C2C);
      case 'white':
        return const Color(0xFFF5F5F5);
      case 'brown':
        return const Color(0xFF8B4513);
      case 'gray':
        return const Color(0xFF808080);
      case 'blue':
        return const Color(0xFF4A90E2);
      case 'pink':
        return const Color(0xFFFF69B4);
      default:
        return const Color(0xFFFF8C42);
    }
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    if (score >= 40) return Colors.deepOrange;
    return Colors.red;
  }
}
