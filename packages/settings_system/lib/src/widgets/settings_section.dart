/*
---------------------------------------------------------------
File name:          settings_section.dart
Author:             lgnorant-lu
Date created:       2025-07-21
Last modified:      2025-07-21
Dart Version:       3.2+
Description:        设置分组组件 - 设置项的分组容器
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';

/// 设置分组组件
/// 
/// 用于将相关的设置项组织在一起，提供统一的视觉样式
class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 分组标题
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          // 设置项容器
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: _buildChildren(),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建子组件列表，添加分隔线
  List<Widget> _buildChildren() {
    final List<Widget> widgets = [];
    
    for (int i = 0; i < children.length; i++) {
      widgets.add(children[i]);
      
      // 添加分隔线（除了最后一个）
      if (i < children.length - 1) {
        widgets.add(
          const Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
          ),
        );
      }
    }
    
    return widgets;
  }
}
