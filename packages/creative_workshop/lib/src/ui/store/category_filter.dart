/*
---------------------------------------------------------------
File name:          category_filter.dart
Author:             lgnorant-lu
Date created:       2025-07-22
Last modified:      2025-07-22
Dart Version:       3.2+
Description:        分类过滤器组件
---------------------------------------------------------------
Change History:
    2025-07-22: Initial creation - 分类过滤器组件;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:creative_workshop/src/ui/store/plugin_card.dart';

/// 分类过滤器组件
class CategoryFilter extends StatelessWidget {
  const CategoryFilter({
    super.key,
    this.selectedCategory,
    this.onCategoryChanged,
    this.showInstalledOnly = false,
    this.onInstalledFilterChanged,
  });

  /// 选中的分类
  final StorePluginCategory? selectedCategory;

  /// 分类变化回调
  final void Function(StorePluginCategory? category)? onCategoryChanged;

  /// 是否只显示已安装
  final bool showInstalledOnly;

  /// 已安装过滤变化回调
  final void Function(bool showInstalledOnly)? onInstalledFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 分类筛选
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // 全部分类
                _buildCategoryChip(
                  context,
                  label: '全部',
                  isSelected: selectedCategory == null,
                  onTap: () => onCategoryChanged?.call(null),
                ),

                const SizedBox(width: 8),

                // 各个分类
                ...StorePluginCategory.values.map((category) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildCategoryChip(
                        context,
                        label: category.displayName,
                        isSelected: selectedCategory == category,
                        onTap: () => onCategoryChanged?.call(category),
                      ),
                    )),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 其他过滤选项
          Row(
            children: [
              // 只显示已安装
              FilterChip(
                label: const Text('已安装'),
                selected: showInstalledOnly,
                onSelected: (selected) =>
                    onInstalledFilterChanged?.call(selected),
                avatar: Icon(
                  showInstalledOnly ? Icons.check_circle : Icons.download,
                  size: 18,
                ),
              ),

              const SizedBox(width: 8),

              // 免费插件
              FilterChip(
                label: const Text('免费'),
                selected: false, // TODO: 实现免费过滤
                onSelected: (selected) {
                  // TODO: 实现免费插件过滤
                },
                avatar: const Icon(
                  Icons.money_off,
                  size: 18,
                ),
              ),

              const SizedBox(width: 8),

              // 高评分
              FilterChip(
                label: const Text('高评分'),
                selected: false, // TODO: 实现高评分过滤
                onSelected: (selected) {
                  // TODO: 实现高评分插件过滤
                },
                avatar: const Icon(
                  Icons.star,
                  size: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建分类筛选片
  Widget _buildCategoryChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
