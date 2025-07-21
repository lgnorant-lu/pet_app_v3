/*
---------------------------------------------------------------
File name:          pet_settings_screen.dart
Author:             lgnorant-lu
Date created:       2025-07-21
Last modified:      2025-07-21
Dart Version:       3.2+
Description:        桌宠设置界面 - 桌宠的配置和管理界面
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:desktop_pet/src/models/index.dart';
import 'package:desktop_pet/src/providers/pet_provider.dart';
import 'package:desktop_pet/src/widgets/pet_control_panel.dart';

/// 桌宠设置界面
///
/// 提供桌宠的配置和管理功能
class PetSettingsScreen extends ConsumerStatefulWidget {
  const PetSettingsScreen({super.key});

  @override
  ConsumerState<PetSettingsScreen> createState() => _PetSettingsScreenState();
}

class _PetSettingsScreenState extends ConsumerState<PetSettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final petState = ref.watch(petStateProvider);
    final currentPet = ref.watch(currentPetProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('桌宠设置'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.pets), text: '桌宠管理'),
            Tab(icon: Icon(Icons.settings), text: '系统设置'),
            Tab(icon: Icon(Icons.analytics), text: '统计信息'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPetManagementTab(petState, currentPet),
          _buildSystemSettingsTab(petState),
          _buildStatisticsTab(currentPet),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePetDialog(context),
        child: const Icon(Icons.add),
        tooltip: '创建新桌宠',
      ),
    );
  }

  /// 构建桌宠管理标签页
  Widget _buildPetManagementTab(PetState petState, PetEntity? currentPet) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 当前桌宠
          if (currentPet != null) ...[
            Text(
              '当前桌宠',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            PetControlPanel(pet: currentPet),
            const SizedBox(height: 24),
          ],

          // 桌宠列表
          Text(
            '所有桌宠',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          if (petState.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (petState.pets.isEmpty)
            _buildEmptyState()
          else
            _buildPetList(petState.pets, currentPet),
        ],
      ),
    );
  }

  /// 构建系统设置标签页
  Widget _buildSystemSettingsTab(PetState petState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '系统设置',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // 桌宠系统开关
          _buildSettingTile(
            title: '启用桌宠系统',
            subtitle: '开启或关闭桌宠功能',
            trailing: Switch(
              value: petState.isEnabled,
              onChanged: (value) {
                ref.read(petStateProvider.notifier).togglePetSystem();
              },
            ),
          ),

          // 桌宠可见性
          _buildSettingTile(
            title: '桌宠可见性',
            subtitle: '控制桌宠是否显示在桌面上',
            trailing: Switch(
              value: petState.isVisible,
              onChanged: petState.isEnabled
                  ? (value) {
                      ref.read(petStateProvider.notifier).togglePetVisibility();
                    }
                  : null,
            ),
          ),

          // 交互模式
          _buildSettingTile(
            title: '交互模式',
            subtitle: '设置桌宠的交互方式',
            trailing: DropdownButton<PetInteractionMode>(
              value: petState.interactionMode,
              onChanged: petState.isEnabled
                  ? (mode) {
                      if (mode != null) {
                        ref
                            .read(petStateProvider.notifier)
                            .setInteractionMode(mode);
                      }
                    }
                  : null,
              items: PetInteractionMode.values.map((mode) {
                return DropdownMenuItem(
                  value: mode,
                  child: Text(mode.displayName),
                );
              }).toList(),
            ),
          ),

          const Divider(height: 32),

          // 数据管理
          Text(
            '数据管理',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          _buildActionTile(
            title: '刷新数据',
            subtitle: '重新加载桌宠数据',
            icon: Icons.refresh,
            onTap: () {
              ref.read(petStateProvider.notifier).refreshPets();
            },
          ),

          _buildActionTile(
            title: '导出数据',
            subtitle: '导出桌宠数据到文件',
            icon: Icons.download,
            onTap: () {
              // TODO: 实现数据导出
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('功能开发中...')),
              );
            },
          ),

          _buildActionTile(
            title: '导入数据',
            subtitle: '从文件导入桌宠数据',
            icon: Icons.upload,
            onTap: () {
              // TODO: 实现数据导入
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('功能开发中...')),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 构建统计信息标签页
  Widget _buildStatisticsTab(PetEntity? currentPet) {
    if (currentPet == null) {
      return const Center(
        child: Text('请先选择一个桌宠'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${currentPet.name} 的统计信息',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // 基本信息卡片
          _buildStatsCard(
            title: '基本信息',
            children: [
              _buildStatRow('名称', currentPet.name),
              _buildStatRow('类型', currentPet.type),
              _buildStatRow('品种', currentPet.breed),
              _buildStatRow('性别', currentPet.gender),
              _buildStatRow('年龄', '${currentPet.ageInDays} 天'),
              _buildStatRow('生命阶段', currentPet.ageStage),
            ],
          ),

          const SizedBox(height: 16),

          // 状态信息卡片
          _buildStatsCard(
            title: '当前状态',
            children: [
              _buildStatRow('健康', '${currentPet.health}%'),
              _buildStatRow('快乐', '${currentPet.happiness}%'),
              _buildStatRow('能量', '${currentPet.energy}%'),
              _buildStatRow('饥饿', '${currentPet.hunger}%'),
              _buildStatRow('清洁', '${currentPet.cleanliness}%'),
              _buildStatRow('社交', '${currentPet.social}%'),
            ],
          ),

          const SizedBox(height: 16),

          // 活动信息卡片
          _buildStatsCard(
            title: '活动信息',
            children: [
              _buildStatRow('当前心情', currentPet.mood.displayName),
              _buildStatRow('当前活动', currentPet.currentActivity.displayName),
              _buildStatRow('生命状态', currentPet.status.displayName),
              _buildStatRow('整体评分', '${currentPet.overallScore}%'),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pets,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '还没有桌宠',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右下角的 + 按钮创建你的第一个桌宠',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建桌宠列表
  Widget _buildPetList(List<PetEntity> pets, PetEntity? currentPet) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pets.length,
      itemBuilder: (context, index) {
        final pet = pets[index];
        final isSelected = currentPet?.id == pet.id;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey[300],
              child: Icon(
                Icons.pets,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
            title: Text(pet.name),
            subtitle: Text('${pet.type} • ${pet.ageStage}'),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'select',
                  child: Text('选择'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('删除'),
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 'select':
                    ref.read(currentPetProvider.notifier).state = pet;
                    break;
                  case 'delete':
                    _deletePet(pet);
                    break;
                }
              },
            ),
            selected: isSelected,
            onTap: () {
              ref.read(currentPetProvider.notifier).state = pet;
            },
          ),
        );
      },
    );
  }

  /// 构建设置项
  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing,
    );
  }

  /// 构建操作项
  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }

  /// 构建统计卡片
  Widget _buildStatsCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  /// 构建统计行
  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  /// 显示创建桌宠对话框
  void _showCreatePetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreatePetDialog(),
    );
  }

  /// 删除桌宠
  void _deletePet(PetEntity pet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除桌宠 "${pet.name}" 吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              ref.read(petStateProvider.notifier).deletePet(pet.id);
              Navigator.of(context).pop();
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

/// 创建桌宠对话框
class CreatePetDialog extends ConsumerStatefulWidget {
  const CreatePetDialog({super.key});

  @override
  ConsumerState<CreatePetDialog> createState() => _CreatePetDialogState();
}

class _CreatePetDialogState extends ConsumerState<CreatePetDialog> {
  final _nameController = TextEditingController();
  String _selectedType = 'cat';
  String _selectedBreed = 'domestic';
  String _selectedColor = 'orange';
  String _selectedGender = 'unknown';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('创建新桌宠'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '桌宠名称',
                hintText: '给你的桌宠起个名字',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: '类型'),
              items: const [
                DropdownMenuItem(value: 'cat', child: Text('猫咪')),
                DropdownMenuItem(value: 'dog', child: Text('小狗')),
                DropdownMenuItem(value: 'rabbit', child: Text('兔子')),
                DropdownMenuItem(value: 'bird', child: Text('小鸟')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedType = value);
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(labelText: '性别'),
              items: const [
                DropdownMenuItem(value: 'unknown', child: Text('未知')),
                DropdownMenuItem(value: 'male', child: Text('雄性')),
                DropdownMenuItem(value: 'female', child: Text('雌性')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedGender = value);
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _createPet,
          child: const Text('创建'),
        ),
      ],
    );
  }

  void _createPet() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入桌宠名称')),
      );
      return;
    }

    ref.read(petStateProvider.notifier).createPet(
          name: _nameController.text.trim(),
          type: _selectedType,
          breed: _selectedBreed,
          color: _selectedColor,
          gender: _selectedGender,
        );

    Navigator.of(context).pop();
  }
}
