/*
---------------------------------------------------------------
File name:          settings_section.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
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
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 分组标题
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          
          // 设置项容器
          Card(
            elevation: 1,
            margin: EdgeInsets.zero,
            child: Padding(
              padding: padding ?? const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: _buildChildrenWithDividers(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建带分隔线的子组件列表
  List<Widget> _buildChildrenWithDividers() {
    if (children.isEmpty) return [];

    final List<Widget> result = [];
    
    for (int i = 0; i < children.length; i++) {
      result.add(children[i]);
      
      // 在非最后一个子组件后添加分隔线
      if (i < children.length - 1) {
        result.add(
          const Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
          ),
        );
      }
    }
    
    return result;
  }
}
