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

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:plugin_system/plugin_system.dart';

/// 插件搜索栏组件 (增强版 - 集成PluginSearchEngine)
class PluginSearchBar extends StatefulWidget {
  const PluginSearchBar({
    super.key,
    this.initialQuery = '',
    this.onSearchChanged,
    this.hintText = '搜索插件...',
    this.searchEngine,
    this.enableSuggestions = true,
    this.enableHistory = true,
  });

  /// 初始搜索查询
  final String initialQuery;

  /// 搜索变化回调
  final void Function(String query)? onSearchChanged;

  /// 提示文本
  final String hintText;

  /// 搜索引擎实例
  final PluginSearchEngine? searchEngine;

  /// 是否启用搜索建议
  final bool enableSuggestions;

  /// 是否启用搜索历史
  final bool enableHistory;

  @override
  State<PluginSearchBar> createState() => _PluginSearchBarState();
}

class _PluginSearchBarState extends State<PluginSearchBar> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  Timer? _debounceTimer;

  // 搜索建议和历史
  List<SearchSuggestion> _suggestions = [];
  List<String> _searchHistory = [];
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _focusNode = FocusNode();

    // 监听焦点变化
    _focusNode.addListener(_onFocusChanged);

    // 加载搜索历史
    _loadSearchHistory();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _debounceTimer?.cancel();
    _hideOverlay();
    super.dispose();
  }

  /// 加载搜索历史
  void _loadSearchHistory() {
    if (widget.enableHistory && widget.searchEngine != null) {
      _searchHistory = widget.searchEngine!.getSearchHistory();
    }
  }

  /// 焦点变化处理
  void _onFocusChanged() {
    if (_focusNode.hasFocus && widget.enableSuggestions) {
      _showSuggestionsOverlay();
    } else {
      _hideOverlay();
    }
  }

  /// 显示建议覆盖层
  void _showSuggestionsOverlay() {
    if (_overlayEntry != null) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height,
        width: size.width,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          child: _buildSuggestionsPanel(),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  /// 隐藏覆盖层
  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    // 覆盖层已移除
  }

  /// 搜索变化处理 (增强版)
  void _onSearchChanged() {
    final query = _controller.text;

    // 防抖处理
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _updateSuggestions(query);
    });

    // 立即回调
    widget.onSearchChanged?.call(query);
  }

  /// 更新搜索建议
  Future<void> _updateSuggestions(String query) async {
    if (!widget.enableSuggestions || widget.searchEngine == null) return;

    try {
      final suggestions = await widget.searchEngine!.getSuggestions(query);
      if (mounted) {
        setState(() {
          _suggestions = suggestions;
        });
      }
    } catch (e) {
      // 忽略建议获取错误
    }
  }

  void _clearSearch() {
    _controller.clear();
    _onSearchChanged();
  }

  /// 构建搜索建议面板
  Widget _buildSuggestionsPanel() {
    final hasHistory = _searchHistory.isNotEmpty;
    final hasSuggestions = _suggestions.isNotEmpty;

    if (!hasHistory && !hasSuggestions) {
      return const SizedBox.shrink();
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 搜索建议
            if (hasSuggestions) ...[
              _buildSectionHeader('搜索建议'),
              ..._suggestions.map((suggestion) => _buildSuggestionItem(
                    suggestion.text,
                    _getSuggestionIcon(suggestion.type),
                    () => _selectSuggestion(suggestion.text),
                  )),
            ],

            // 搜索历史
            if (hasHistory && _controller.text.isEmpty) ...[
              if (hasSuggestions) const Divider(height: 1),
              _buildSectionHeader('搜索历史'),
              ..._searchHistory.take(5).map((history) => _buildSuggestionItem(
                    history,
                    Icons.history,
                    () => _selectSuggestion(history),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建章节标题
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }

  /// 构建建议项
  Widget _buildSuggestionItem(String text, IconData icon, VoidCallback onTap) {
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 20),
      title: Text(text),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  /// 获取建议图标
  IconData _getSuggestionIcon(SearchSuggestionType type) {
    switch (type) {
      case SearchSuggestionType.keyword:
        return Icons.search;
      case SearchSuggestionType.category:
        return Icons.category;
      case SearchSuggestionType.tag:
        return Icons.tag;
      case SearchSuggestionType.author:
        return Icons.person;
      case SearchSuggestionType.plugin:
        return Icons.extension;
    }
  }

  /// 选择建议
  void _selectSuggestion(String suggestion) {
    _controller.text = suggestion;
    _hideOverlay();
    widget.onSearchChanged?.call(suggestion);
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
