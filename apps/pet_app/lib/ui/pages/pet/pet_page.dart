/*
---------------------------------------------------------------
File name:          pet_page.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        桌宠主页面 - 桌宠显示和交互的主界面
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/pet_provider.dart';
import '../../../core/providers/pet_behavior_provider.dart';
import '../../../core/pet/models/pet_entity.dart';

import 'widgets/pet_control_panel.dart';
import 'widgets/pet_status_bar.dart';
import 'widgets/pet_interaction_area.dart';

/// 桌宠主页面
class PetPage extends ConsumerStatefulWidget {
  const PetPage({super.key});

  @override
  ConsumerState<PetPage> createState() => _PetPageState();
}

class _PetPageState extends ConsumerState<PetPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final petState = ref.watch(petProvider);
    final behaviorState = ref.watch(petBehaviorProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(context, petState),
      body: _buildBody(context, petState, behaviorState),
      floatingActionButton: _buildFloatingActionButton(context, petState),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, petState) {
    return AppBar(
      title: Text(
        petState.currentPet?.name ?? '我的桌宠',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: const Color(0xFF6C63FF),
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () => _navigateToSettings(context),
        ),
        IconButton(
          icon: Icon(
            petState.isVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.white,
          ),
          onPressed: () => _togglePetVisibility(),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, petState, behaviorState) {
    if (petState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
        ),
      );
    }

    if (petState.error != null) {
      return _buildErrorWidget(petState.error!);
    }

    if (petState.currentPet == null) {
      return _buildNoPetWidget(context);
    }

    return Column(
      children: [
        // 桌宠状态栏
        PetStatusBar(pet: petState.currentPet!),

        // 主要内容区域
        Expanded(
          child: Row(
            children: [
              // 左侧控制面板
              SizedBox(
                width: 280,
                child: PetControlPanel(
                  pet: petState.currentPet!,
                  behaviorState: behaviorState,
                ),
              ),

              // 中间桌宠显示区域
              Expanded(
                child: PetInteractionArea(
                  pet: petState.currentPet!,
                  scaleAnimation: _scaleAnimation,
                  rotationAnimation: _rotationAnimation,
                ),
              ),

              // 右侧信息面板
              SizedBox(
                width: 280,
                child: _buildInfoPanel(petState.currentPet!),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('桌宠系统错误', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => ref.read(petProvider.notifier).refresh(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
            ),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoPetWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.pets, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text('还没有桌宠', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('创建你的第一个桌宠开始陪伴之旅吧！', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreatePetDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.add),
            label: const Text('创建桌宠'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPanel(PetEntity pet) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '桌宠信息',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6C63FF),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoItem('名称', pet.name),
          _buildInfoItem('类型', pet.type),
          _buildInfoItem('年龄', '${pet.ageInDays}天 (${pet.ageStage})'),
          _buildInfoItem('等级', 'Lv.${pet.level}'),
          _buildInfoItem('经验', '${pet.experience}'),
          const Divider(),
          _buildInfoItem('心情', '${pet.mood.emoji} ${pet.mood.displayName}'),
          _buildInfoItem(
            '活动',
            '${pet.currentActivity.emoji} ${pet.currentActivity.displayName}',
          ),
          _buildInfoItem('状态', '${pet.status.emoji} ${pet.status.displayName}'),
          const Divider(),
          _buildInfoItem('总体评分', '${pet.overallScore}/100'),
          if (pet.needsAttention)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '需要关注',
                      style: TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context, petState) {
    if (petState.currentPet == null) return const SizedBox.shrink();

    return FloatingActionButton(
      onPressed: () => _showQuickActions(context),
      backgroundColor: const Color(0xFF6C63FF),
      child: const Icon(Icons.touch_app, color: Colors.white),
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.of(context).pushNamed('/pet/settings');
  }

  void _togglePetVisibility() {
    final petNotifier = ref.read(petProvider.notifier);
    final currentVisibility = ref.read(petProvider).isVisible;
    petNotifier.setPetVisibility(!currentVisibility);
  }

  void _showCreatePetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('创建新桌宠'),
        content: const Text('功能开发中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: 实现创建桌宠功能
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '快速操作',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickActionButton(
                  icon: Icons.restaurant,
                  label: '喂食',
                  onPressed: () => _feedPet(),
                ),
                _buildQuickActionButton(
                  icon: Icons.cleaning_services,
                  label: '清洁',
                  onPressed: () => _cleanPet(),
                ),
                _buildQuickActionButton(
                  icon: Icons.sports_esports,
                  label: '玩耍',
                  onPressed: () => _playWithPet(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C63FF),
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
          ),
          child: Icon(icon, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  void _feedPet() {
    final pet = ref.read(currentPetProvider);
    if (pet != null) {
      ref.read(petProvider.notifier).feedPet(pet.id);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已喂食桌宠')));
    }
  }

  void _cleanPet() {
    final pet = ref.read(currentPetProvider);
    if (pet != null) {
      ref.read(petProvider.notifier).cleanPet(pet.id);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已清洁桌宠')));
    }
  }

  void _playWithPet() {
    final pet = ref.read(currentPetProvider);
    if (pet != null) {
      ref.read(petProvider.notifier).playWithPet(pet.id);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('与桌宠玩耍中')));
    }
  }
}
