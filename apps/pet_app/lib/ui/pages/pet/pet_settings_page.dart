/*
---------------------------------------------------------------
File name:          pet_settings_page.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        桌宠设置页面 - 桌宠系统配置和个性化设置
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/pet_provider.dart';
import '../../../core/providers/pet_behavior_provider.dart';
import '../../../core/pet/models/pet_state.dart';

/// 桌宠设置页面
class PetSettingsPage extends ConsumerStatefulWidget {
  const PetSettingsPage({super.key});

  @override
  ConsumerState<PetSettingsPage> createState() => _PetSettingsPageState();
}

class _PetSettingsPageState extends ConsumerState<PetSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final petState = ref.watch(petProvider);
    final behaviorState = ref.watch(petBehaviorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '桌宠设置',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 系统设置
          _buildSystemSettings(petState, behaviorState),
          
          const SizedBox(height: 16),
          
          // 显示设置
          _buildDisplaySettings(petState),
          
          const SizedBox(height: 16),
          
          // 交互设置
          _buildInteractionSettings(petState),
          
          const SizedBox(height: 16),
          
          // 行为设置
          _buildBehaviorSettings(behaviorState),
          
          const SizedBox(height: 16),
          
          // 数据管理
          _buildDataManagement(),
          
          const SizedBox(height: 16),
          
          // 关于信息
          _buildAboutSection(),
        ],
      ),
    );
  }

  Widget _buildSystemSettings(PetState petState, PetBehaviorState behaviorState) {
    return _buildSettingsCard(
      title: '系统设置',
      icon: Icons.settings,
      children: [
        SwitchListTile(
          title: const Text('启用桌宠系统'),
          subtitle: const Text('开启或关闭桌宠功能'),
          value: petState.isEnabled,
          onChanged: (value) {
            ref.read(petProvider.notifier).setPetSystemEnabled(value);
          },
          activeColor: const Color(0xFF6C63FF),
        ),
        SwitchListTile(
          title: const Text('自动行为系统'),
          subtitle: const Text('允许桌宠自动执行行为'),
          value: behaviorState.isEnabled,
          onChanged: (value) {
            ref.read(petBehaviorProvider.notifier).setBehaviorSystemEnabled(value);
          },
          activeColor: const Color(0xFF6C63FF),
        ),
        ListTile(
          title: const Text('系统状态'),
          subtitle: Text(petState.statusDescription),
          trailing: Icon(
            petState.isAvailable ? Icons.check_circle : Icons.error,
            color: petState.isAvailable ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildDisplaySettings(PetState petState) {
    return _buildSettingsCard(
      title: '显示设置',
      icon: Icons.visibility,
      children: [
        SwitchListTile(
          title: const Text('显示桌宠'),
          subtitle: const Text('控制桌宠的可见性'),
          value: petState.isVisible,
          onChanged: (value) {
            ref.read(petProvider.notifier).setPetVisibility(value);
          },
          activeColor: const Color(0xFF6C63FF),
        ),
        ListTile(
          title: const Text('交互模式'),
          subtitle: Text(petState.interactionMode.displayName),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => _showInteractionModeDialog(),
        ),
        ListTile(
          title: const Text('主题设置'),
          subtitle: const Text('自定义桌宠外观'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => _showThemeSettings(),
        ),
      ],
    );
  }

  Widget _buildInteractionSettings(PetState petState) {
    return _buildSettingsCard(
      title: '交互设置',
      icon: Icons.touch_app,
      children: [
        ListTile(
          title: const Text('互动频率'),
          subtitle: const Text('调整桌宠主动互动的频率'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => _showInteractionFrequencyDialog(),
        ),
        ListTile(
          title: const Text('通知设置'),
          subtitle: const Text('配置桌宠通知提醒'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => _showNotificationSettings(),
        ),
        ListTile(
          title: const Text('声音设置'),
          subtitle: const Text('配置桌宠音效'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => _showSoundSettings(),
        ),
      ],
    );
  }

  Widget _buildBehaviorSettings(PetBehaviorState behaviorState) {
    return _buildSettingsCard(
      title: '行为设置',
      icon: Icons.psychology,
      children: [
        ListTile(
          title: const Text('可用行为'),
          subtitle: Text('${behaviorState.availableBehaviors.length} 个行为'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => _showBehaviorList(),
        ),
        ListTile(
          title: const Text('执行历史'),
          subtitle: Text('${behaviorState.executionHistory.length} 条记录'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => _showExecutionHistory(),
        ),
        ListTile(
          title: const Text('行为偏好'),
          subtitle: const Text('查看和调整桌宠行为偏好'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => _showBehaviorPreferences(),
        ),
      ],
    );
  }

  Widget _buildDataManagement() {
    return _buildSettingsCard(
      title: '数据管理',
      icon: Icons.storage,
      children: [
        ListTile(
          title: const Text('导出数据'),
          subtitle: const Text('备份桌宠数据'),
          trailing: const Icon(Icons.download),
          onTap: () => _exportData(),
        ),
        ListTile(
          title: const Text('导入数据'),
          subtitle: const Text('恢复桌宠数据'),
          trailing: const Icon(Icons.upload),
          onTap: () => _importData(),
        ),
        ListTile(
          title: const Text('清除数据'),
          subtitle: const Text('删除所有桌宠数据'),
          trailing: const Icon(Icons.delete, color: Colors.red),
          onTap: () => _showClearDataDialog(),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return _buildSettingsCard(
      title: '关于',
      icon: Icons.info,
      children: [
        const ListTile(
          title: Text('版本'),
          subtitle: Text('Pet App V3 1.0.0'),
        ),
        const ListTile(
          title: Text('开发团队'),
          subtitle: Text('Pet App V3 Team'),
        ),
        ListTile(
          title: const Text('帮助与支持'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => _showHelp(),
        ),
        ListTile(
          title: const Text('隐私政策'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => _showPrivacyPolicy(),
        ),
      ],
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: const Color(0xFF6C63FF),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6C63FF),
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  void _showInteractionModeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择交互模式'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: PetInteractionMode.values.map((mode) {
            return RadioListTile<PetInteractionMode>(
              title: Text(mode.displayName),
              value: mode,
              groupValue: ref.read(petProvider).interactionMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(petProvider.notifier).setInteractionMode(value);
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  void _showThemeSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('主题设置功能开发中...')),
    );
  }

  void _showInteractionFrequencyDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('互动频率设置功能开发中...')),
    );
  }

  void _showNotificationSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('通知设置功能开发中...')),
    );
  }

  void _showSoundSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('声音设置功能开发中...')),
    );
  }

  void _showBehaviorList() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('行为列表功能开发中...')),
    );
  }

  void _showExecutionHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('执行历史功能开发中...')),
    );
  }

  void _showBehaviorPreferences() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('行为偏好功能开发中...')),
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('数据导出功能开发中...')),
    );
  }

  void _importData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('数据导入功能开发中...')),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除数据'),
        content: const Text('确定要删除所有桌宠数据吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('数据清除功能开发中...')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showHelp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('帮助功能开发中...')),
    );
  }

  void _showPrivacyPolicy() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('隐私政策功能开发中...')),
    );
  }
}
