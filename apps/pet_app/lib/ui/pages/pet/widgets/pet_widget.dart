/*
---------------------------------------------------------------
File name:          pet_widget.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        桌宠显示组件 - 桌宠的可视化表示
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/pet/models/pet_entity.dart';

import '../../../../core/pet/enums/pet_activity.dart';
import '../../../../core/pet/enums/pet_status.dart';

/// 桌宠显示组件
class PetWidget extends StatefulWidget {
  final PetEntity pet;
  final double size;
  final Animation<double>? scaleAnimation;
  final Animation<double>? rotationAnimation;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const PetWidget({
    super.key,
    required this.pet,
    this.size = 120,
    this.scaleAnimation,
    this.rotationAnimation,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<PetWidget> createState() => _PetWidgetState();
}

class _PetWidgetState extends State<PetWidget> with TickerProviderStateMixin {
  late AnimationController _blinkController;
  late AnimationController _bounceController;
  late Animation<double> _blinkAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // 眨眼动画
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _blinkAnimation = Tween<double>(begin: 1.0, end: 0.1).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );

    // 弹跳动画
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    // 定期眨眼
    _startBlinking();
  }

  void _startBlinking() {
    Future.delayed(Duration(seconds: 2 + math.Random().nextInt(3)), () {
      if (mounted) {
        _blinkController.forward().then((_) {
          _blinkController.reverse().then((_) {
            _startBlinking();
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _blinkController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _bounceController.forward().then((_) => _bounceController.reverse());
        widget.onTap?.call();
      },
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          widget.scaleAnimation,
          widget.rotationAnimation,
          _blinkAnimation,
          _bounceAnimation,
        ]),
        builder: (context, child) {
          double scale = 1.0;
          double rotation = 0.0;

          if (widget.scaleAnimation != null) {
            scale *= widget.scaleAnimation!.value;
          }
          if (widget.rotationAnimation != null) {
            rotation += widget.rotationAnimation!.value;
          }

          // 添加弹跳效果
          scale *= (1.0 + _bounceAnimation.value * 0.2);

          return Transform.scale(
            scale: scale,
            child: Transform.rotate(angle: rotation, child: _buildPetBody()),
          );
        },
      ),
    );
  }

  Widget _buildPetBody() {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 阴影
          Positioned(
            bottom: 5,
            child: Container(
              width: widget.size * 0.8,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          // 主体
          Container(
            width: widget.size * 0.9,
            height: widget.size * 0.9,
            decoration: BoxDecoration(
              color: _getPetColor(),
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [_getPetColor(), _getPetColor().withOpacity(0.8)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 眼睛
                _buildEyes(),

                // 嘴巴
                _buildMouth(),

                // 状态指示器
                _buildStatusIndicator(),

                // 心情表情
                _buildMoodEmoji(),
              ],
            ),
          ),

          // 活动指示器
          if (widget.pet.currentActivity != PetActivity.idle)
            _buildActivityIndicator(),
        ],
      ),
    );
  }

  Widget _buildEyes() {
    return Positioned(
      top: widget.size * 0.25,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildEye(),
          SizedBox(width: widget.size * 0.1),
          _buildEye(),
        ],
      ),
    );
  }

  Widget _buildEye() {
    return AnimatedBuilder(
      animation: _blinkAnimation,
      builder: (context, child) {
        return Container(
          width: widget.size * 0.12,
          height: widget.size * 0.12 * _blinkAnimation.value,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: _blinkAnimation.value > 0.5
              ? Container(
                  margin: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildMouth() {
    return Positioned(
      top: widget.size * 0.45,
      child: Container(
        width: widget.size * 0.15,
        height: widget.size * 0.08,
        decoration: BoxDecoration(
          color: _getMouthColor(),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    if (!widget.pet.status.needsAttention) return const SizedBox.shrink();

    return Positioned(
      top: 5,
      right: 5,
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: _getStatusColor(),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1),
        ),
      ),
    );
  }

  Widget _buildMoodEmoji() {
    return Positioned(
      bottom: widget.size * 0.1,
      child: Text(
        widget.pet.mood.emoji,
        style: TextStyle(fontSize: widget.size * 0.15),
      ),
    );
  }

  Widget _buildActivityIndicator() {
    return Positioned(
      top: -5,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.pet.currentActivity.emoji,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(width: 4),
            Text(
              widget.pet.currentActivity.displayName,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPetColor() {
    switch (widget.pet.color.toLowerCase()) {
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

  Color _getMouthColor() {
    if (widget.pet.mood.isPositive) {
      return Colors.pink;
    } else if (widget.pet.mood.isNegative) {
      return Colors.grey;
    } else {
      return Colors.orange;
    }
  }

  Color _getStatusColor() {
    switch (widget.pet.status) {
      case PetStatus.sick:
      case PetStatus.injured:
        return Colors.red;
      case PetStatus.tired:
      case PetStatus.weak:
        return Colors.orange;
      case PetStatus.recovering:
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }
}
