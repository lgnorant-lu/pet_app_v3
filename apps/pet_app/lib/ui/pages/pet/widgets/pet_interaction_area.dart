/*
---------------------------------------------------------------
File name:          pet_interaction_area.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        桌宠交互区域 - 桌宠显示和交互的主要区域
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/pet/models/pet_entity.dart';
import 'pet_widget.dart';

/// 桌宠交互区域
class PetInteractionArea extends StatefulWidget {
  final PetEntity pet;
  final Animation<double>? scaleAnimation;
  final Animation<double>? rotationAnimation;

  const PetInteractionArea({
    super.key,
    required this.pet,
    this.scaleAnimation,
    this.rotationAnimation,
  });

  @override
  State<PetInteractionArea> createState() => _PetInteractionAreaState();
}

class _PetInteractionAreaState extends State<PetInteractionArea>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late AnimationController _particleController;
  late Animation<double> _floatingAnimation;
  late Animation<double> _particleAnimation;

  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // 浮动动画
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _floatingAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    // 粒子动画
    _particleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.easeOut),
    );

    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)],
        ),
      ),
      child: Stack(
        children: [
          // 背景装饰
          _buildBackgroundDecorations(),

          // 粒子效果
          AnimatedBuilder(
            animation: _particleAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: ParticlePainter(_particles, _particleAnimation.value),
                size: Size.infinite,
              );
            },
          ),

          // 桌宠主体
          Center(
            child: AnimatedBuilder(
              animation: _floatingAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatingAnimation.value),
                  child: PetWidget(
                    pet: widget.pet,
                    size: 150,
                    scaleAnimation: widget.scaleAnimation,
                    rotationAnimation: widget.rotationAnimation,
                    onTap: _onPetTap,
                    onLongPress: _onPetLongPress,
                  ),
                );
              },
            ),
          ),

          // 交互提示
          if (_shouldShowInteractionHint()) _buildInteractionHint(),

          // 点击检测区域
          GestureDetector(
            onTapDown: (details) {
              _onAreaTap(details.localPosition);
            },
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundDecorations() {
    return Stack(
      children: [
        // 云朵
        Positioned(
          top: 50,
          left: 100,
          child: _buildCloud(size: 60, opacity: 0.3),
        ),
        Positioned(
          top: 80,
          right: 150,
          child: _buildCloud(size: 40, opacity: 0.2),
        ),
        Positioned(
          bottom: 100,
          left: 50,
          child: _buildCloud(size: 50, opacity: 0.25),
        ),

        // 星星
        Positioned(
          top: 120,
          right: 80,
          child: _buildStar(size: 20, opacity: 0.4),
        ),
        Positioned(
          top: 200,
          left: 200,
          child: _buildStar(size: 15, opacity: 0.3),
        ),
        Positioned(
          bottom: 150,
          right: 200,
          child: _buildStar(size: 18, opacity: 0.35),
        ),
      ],
    );
  }

  Widget _buildCloud({required double size, required double opacity}) {
    return Container(
      width: size,
      height: size * 0.6,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(opacity),
        borderRadius: BorderRadius.circular(size / 2),
      ),
    );
  }

  Widget _buildStar({required double size, required double opacity}) {
    return Icon(
      Icons.star,
      size: size,
      color: Colors.yellow.withOpacity(opacity),
    );
  }

  Widget _buildInteractionHint() {
    return Positioned(
      bottom: 100,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            '点击桌宠进行互动',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
    );
  }

  bool _shouldShowInteractionHint() {
    // 如果桌宠长时间没有互动，显示提示
    final timeSinceLastInteraction = DateTime.now().difference(
      widget.pet.lastInteraction,
    );
    return timeSinceLastInteraction.inMinutes > 5;
  }

  void _onPetTap() {
    // 创建点击特效
    _createTapEffect(const Offset(0, 0));

    // 显示互动反馈
    _showInteractionFeedback();
  }

  void _onPetLongPress() {
    // 长按显示详细信息
    _showPetDetails();
  }

  void _onAreaTap(Offset position) {
    _createTapEffect(position);
  }

  void _createTapEffect(Offset position) {
    setState(() {
      // 创建粒子效果
      for (int i = 0; i < 8; i++) {
        _particles.add(
          Particle(
            position: position,
            velocity: Offset(
              (math.Random().nextDouble() - 0.5) * 200,
              (math.Random().nextDouble() - 0.5) * 200,
            ),
            color: Colors
                .primaries[math.Random().nextInt(Colors.primaries.length)],
            size: math.Random().nextDouble() * 6 + 2,
            life: 1.0,
          ),
        );
      }
    });

    _particleController.reset();
    _particleController.forward().then((_) {
      setState(() {
        _particles.clear();
      });
    });
  }

  void _showInteractionFeedback() {
    final messages = [
      '${widget.pet.name}很开心！',
      '${widget.pet.name}想和你玩！',
      '${widget.pet.name}感受到了你的关爱',
      '${widget.pet.name}心情变好了',
    ];

    final message = messages[math.Random().nextInt(messages.length)];

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showPetDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${widget.pet.name}的详细信息'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('类型: ${widget.pet.type}'),
            Text('品种: ${widget.pet.breed}'),
            Text('颜色: ${widget.pet.color}'),
            Text('年龄: ${widget.pet.ageInDays}天'),
            Text('等级: ${widget.pet.level}'),
            Text('心情: ${widget.pet.mood.displayName}'),
            Text('活动: ${widget.pet.currentActivity.displayName}'),
            Text('状态: ${widget.pet.status.displayName}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}

/// 粒子类
class Particle {
  Offset position;
  Offset velocity;
  Color color;
  double size;
  double life;

  Particle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
    required this.life,
  });

  void update(double deltaTime) {
    position += velocity * deltaTime;
    life -= deltaTime;
    size *= 0.98;
  }
}

/// 粒子绘制器
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  ParticlePainter(this.particles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity((1.0 - animationValue) * 0.8)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        particle.position,
        particle.size * (1.0 - animationValue),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
