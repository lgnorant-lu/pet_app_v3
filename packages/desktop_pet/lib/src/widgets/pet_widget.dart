/*
---------------------------------------------------------------
File name:          pet_widget.dart
Author:             lgnorant-lu
Date created:       2025-07-21
Last modified:      2025-07-21
Dart Version:       3.2+
Description:        桌宠显示组件 - 主要的桌宠UI组件
---------------------------------------------------------------
*/

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:desktop_pet/src/models/index.dart';
import 'package:desktop_pet/src/providers/pet_provider.dart';

/// 桌宠显示组件
///
/// 主要的桌宠UI组件，显示桌宠的外观和状态
class PetWidget extends ConsumerStatefulWidget {
  const PetWidget({
    required this.pet,
    super.key,
    this.isDraggable = true,
    this.showStatusBar = true,
    this.onTap,
    this.onLongPress,
  });

  /// 桌宠实体
  final PetEntity pet;

  /// 是否可拖拽
  final bool isDraggable;

  /// 是否显示状态栏
  final bool showStatusBar;

  /// 点击回调
  final VoidCallback? onTap;

  /// 长按回调
  final VoidCallback? onLongPress;

  @override
  ConsumerState<PetWidget> createState() => _PetWidgetState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<PetEntity>('pet', pet));
    properties.add(DiagnosticsProperty<bool>('isDraggable', isDraggable));
    properties.add(DiagnosticsProperty<bool>('showStatusBar', showStatusBar));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onTap', onTap));
    properties
        .add(ObjectFlagProperty<VoidCallback?>.has('onLongPress', onLongPress));
  }
}

class _PetWidgetState extends ConsumerState<PetWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _idleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _idleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _idleController.dispose();
    super.dispose();
  }

  /// 设置动画
  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _idleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 0.95,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _idleAnimation = Tween<double>(
      begin: 0,
      end: 5,
    ).animate(
      CurvedAnimation(
        parent: _idleController,
        curve: Curves.easeInOut,
      ),
    );
  }

  /// 处理点击
  void _handleTap() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    // 触发互动
    ref.read(petStateProvider.notifier).interactWithPet(widget.pet.id, 'pet');

    widget.onTap?.call();
  }

  /// 处理长按
  void _handleLongPress() {
    // 触发特殊互动
    ref.read(petStateProvider.notifier).interactWithPet(widget.pet.id, 'play');

    widget.onLongPress?.call();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: _handleTap,
        onLongPress: _handleLongPress,
        child: AnimatedBuilder(
          animation:
              Listenable.merge(<Listenable?>[_scaleAnimation, _idleAnimation]),
          builder: (BuildContext context, Widget? child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.translate(
              offset: Offset(0, _idleAnimation.value),
              child: _buildPetBody(),
            ),
          ),
        ),
      );

  /// 构建桌宠主体
  Widget _buildPetBody() => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // 桌宠图像
          _buildPetImage(),

          // 状态栏
          if (widget.showStatusBar) _buildStatusBar(),

          // 心情指示器
          _buildMoodIndicator(),
        ],
      );

  /// 构建桌宠图像
  Widget _buildPetImage() => Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(60),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(60),
          child: _getPetImage(),
        ),
      );

  /// 获取桌宠图像
  Widget _getPetImage() {
    // 根据桌宠类型、心情和状态选择图像
    final String imagePath = _getImagePath();

    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) =>
              _buildDefaultPetImage(),
    );
  }

  /// 获取图像路径
  String _getImagePath() {
    final String baseType = widget.pet.type;
    final String mood = widget.pet.mood.id;
    final String status = widget.pet.status.id;

    // 优先使用心情图像，然后是状态图像，最后是默认图像
    return 'assets/images/pets/$baseType/${mood}_$status.png';
  }

  /// 构建默认桌宠图像
  Widget _buildDefaultPetImage() => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              _getPetColor().withOpacity(0.8),
              _getPetColor(),
            ],
          ),
        ),
        child: Center(
          child: Icon(
            _getPetIcon(),
            size: 60,
            color: Colors.white,
          ),
        ),
      );

  /// 获取桌宠颜色
  Color _getPetColor() {
    switch (widget.pet.type) {
      case 'cat':
        return Colors.orange;
      case 'dog':
        return Colors.brown;
      case 'rabbit':
        return Colors.pink;
      case 'bird':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  /// 获取桌宠图标
  IconData _getPetIcon() {
    switch (widget.pet.type) {
      case 'cat':
        return Icons.pets;
      case 'dog':
        return Icons.pets;
      case 'rabbit':
        return Icons.cruelty_free;
      case 'bird':
        return Icons.flutter_dash;
      default:
        return Icons.favorite;
    }
  }

  /// 构建状态栏
  Widget _buildStatusBar() => Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildStatBar('❤️', widget.pet.health, Colors.red),
            const SizedBox(width: 8),
            _buildStatBar('😊', widget.pet.happiness, Colors.yellow),
            const SizedBox(width: 8),
            _buildStatBar('⚡', widget.pet.energy, Colors.blue),
          ],
        ),
      );

  /// 构建单个状态条
  Widget _buildStatBar(String icon, int value, Color color) => Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 2),
          Container(
            width: 30,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value / 100.0,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      );

  /// 构建心情指示器
  Widget _buildMoodIndicator() => Container(
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: _getMoodColor().withOpacity(0.8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          _getMoodEmoji(),
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      );

  /// 获取心情颜色
  Color _getMoodColor() {
    if (widget.pet.mood.isPositive) {
      return Colors.green;
    } else if (widget.pet.mood.isNegative) {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }

  /// 获取心情表情
  String _getMoodEmoji() {
    switch (widget.pet.mood.id) {
      case 'happy':
        return '😊';
      case 'excited':
        return '🤩';
      case 'loving':
        return '🥰';
      case 'playful':
        return '😄';
      case 'content':
        return '😌';
      case 'curious':
        return '🤔';
      case 'neutral':
        return '😐';
      case 'tired':
        return '😴';
      case 'bored':
        return '😑';
      case 'sad':
        return '😢';
      case 'angry':
        return '😠';
      case 'sick':
        return '🤒';
      default:
        return '😐';
    }
  }
}
