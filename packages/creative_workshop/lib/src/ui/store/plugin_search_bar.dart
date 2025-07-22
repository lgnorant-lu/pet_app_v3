/*
---------------------------------------------------------------
File name:          plugin_search_bar.dart
Author:             lgnorant-lu
Date created:       2025-07-22
Last modified:      2025-07-22
Dart Version:       3.2+
Description:        插件搜索栏组件
---------------------------------------------------------------
Change History:
    2025-07-22: Initial creation - 插件搜索栏组件;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';

/// 插件搜索栏组件
class PluginSearchBar extends StatefulWidget {
  const PluginSearchBar({
    super.key,
    this.initialQuery = '',
    this.onSearchChanged,
    this.hintText = '搜索插件...',
  });

  /// 初始搜索查询
  final String initialQuery;

  /// 搜索变化回调
  final void Function(String query)? onSearchChanged;

  /// 提示文本
  final String hintText;

  @override
  State<PluginSearchBar> createState() => _PluginSearchBarState();
}

class _PluginSearchBarState extends State<PluginSearchBar> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    widget.onSearchChanged?.call(_controller.text);
  }

  void _clearSearch() {
    _controller.clear();
    _onSearchChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: (_) => _onSearchChanged(),
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
      ),
    );
  }
}
