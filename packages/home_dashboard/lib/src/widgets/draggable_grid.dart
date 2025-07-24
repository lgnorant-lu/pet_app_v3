/*
---------------------------------------------------------------
File name:          draggable_grid.dart
Author:             lgnorant-lu
Date created:       2025-07-24
Last modified:      2025-07-24
Dart Version:       3.2+
Description:        可拖拽网格组件 - Phase 5.0.7.3 交互体验优化
---------------------------------------------------------------
Change History:
    2025-07-24: Phase 5.0.7.3 - 实现交互体验优化
    - 响应式布局
    - 动画反馈
    - 拖拽排序
    - 手势交互
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import '../utils/animation_utils.dart';
import '../utils/responsive_utils.dart';

/// 可拖拽项目数据
class DraggableItem<T> {
  /// 唯一标识符
  final String id;
  
  /// 数据
  final T data;
  
  /// 是否可拖拽
  final bool isDraggable;
  
  /// 是否可接受拖拽
  final bool canAcceptDrop;

  const DraggableItem({
    required this.id,
    required this.data,
    this.isDraggable = true,
    this.canAcceptDrop = true,
  });

  DraggableItem<T> copyWith({
    String? id,
    T? data,
    bool? isDraggable,
    bool? canAcceptDrop,
  }) {
    return DraggableItem<T>(
      id: id ?? this.id,
      data: data ?? this.data,
      isDraggable: isDraggable ?? this.isDraggable,
      canAcceptDrop: canAcceptDrop ?? this.canAcceptDrop,
    );
  }
}

/// 拖拽回调函数类型定义
typedef DragCallback<T> = void Function(int oldIndex, int newIndex, DraggableItem<T> item);
typedef ItemBuilder<T> = Widget Function(BuildContext context, DraggableItem<T> item, int index);

/// 可拖拽网格组件
class DraggableGrid<T> extends StatefulWidget {
  /// 项目列表
  final List<DraggableItem<T>> items;
  
  /// 项目构建器
  final ItemBuilder<T> itemBuilder;
  
  /// 拖拽完成回调
  final DragCallback<T>? onReorder;
  
  /// 网格列数
  final int? crossAxisCount;
  
  /// 子组件宽高比
  final double childAspectRatio;
  
  /// 主轴间距
  final double mainAxisSpacing;
  
  /// 交叉轴间距
  final double crossAxisSpacing;
  
  /// 内边距
  final EdgeInsets padding;
  
  /// 是否启用拖拽
  final bool enableDrag;
  
  /// 拖拽反馈构建器
  final Widget Function(BuildContext context, DraggableItem<T> item)? feedbackBuilder;
  
  /// 拖拽时的占位符构建器
  final Widget Function(BuildContext context, DraggableItem<T> item)? placeholderBuilder;

  const DraggableGrid({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.onReorder,
    this.crossAxisCount,
    this.childAspectRatio = 1.0,
    this.mainAxisSpacing = 16,
    this.crossAxisSpacing = 16,
    this.padding = const EdgeInsets.all(16),
    this.enableDrag = true,
    this.feedbackBuilder,
    this.placeholderBuilder,
  });

  @override
  State<DraggableGrid<T>> createState() => _DraggableGridState<T>();
}

class _DraggableGridState<T> extends State<DraggableGrid<T>>
    with TickerProviderStateMixin {
  late List<DraggableItem<T>> _items;
  int? _draggedIndex;
  int? _hoveredIndex;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
    _animationController = AnimationController(
      duration: AnimationUtils.fastDuration,
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(DraggableGrid<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items != oldWidget.items) {
      _items = List.from(widget.items);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final columns = widget.crossAxisCount ?? 
        ResponsiveUtils.getGridColumns(context);

    return Padding(
      padding: widget.padding,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          childAspectRatio: widget.childAspectRatio,
          mainAxisSpacing: widget.mainAxisSpacing,
          crossAxisSpacing: widget.crossAxisSpacing,
        ),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return _buildDraggableItem(context, item, index);
        },
      ),
    );
  }

  /// 构建可拖拽项目
  Widget _buildDraggableItem(BuildContext context, DraggableItem<T> item, int index) {
    final isDragging = _draggedIndex == index;
    final isHovered = _hoveredIndex == index;

    Widget child = widget.itemBuilder(context, item, index);

    // 添加悬停效果
    if (isHovered && !isDragging) {
      child = AnimationUtils.scaleIn(
        duration: AnimationUtils.fastDuration,
        begin: 1.0,
        end: 1.02,
        child: child,
      );
    }

    // 添加拖拽中的透明效果
    if (isDragging) {
      child = Opacity(
        opacity: 0.5,
        child: child,
      );
    }

    // 如果不启用拖拽或项目不可拖拽，直接返回
    if (!widget.enableDrag || !item.isDraggable) {
      return AnimationUtils.listItemAnimation(
        index: index,
        child: child,
      );
    }

    return AnimationUtils.listItemAnimation(
      index: index,
      child: LongPressDraggable<DraggableItem<T>>(
        data: item,
        feedback: _buildFeedback(context, item),
        childWhenDragging: _buildPlaceholder(context, item),
        onDragStarted: () => _onDragStarted(index),
        onDragEnd: (_) => _onDragEnd(),
        child: DragTarget<DraggableItem<T>>(
          onWillAccept: (data) => _canAcceptDrop(item, data),
          onAccept: (data) => _onAcceptDrop(index, data),
          onMove: (_) => _onDragMove(index),
          onLeave: (_) => _onDragLeave(),
          builder: (context, candidateData, rejectedData) {
            return MouseRegion(
              onEnter: (_) => _onHoverEnter(index),
              onExit: (_) => _onHoverExit(),
              child: child,
            );
          },
        ),
      ),
    );
  }

  /// 构建拖拽反馈
  Widget _buildFeedback(BuildContext context, DraggableItem<T> item) {
    if (widget.feedbackBuilder != null) {
      return widget.feedbackBuilder!(context, item);
    }

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Center(
          child: Icon(
            Icons.drag_indicator,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  /// 构建占位符
  Widget _buildPlaceholder(BuildContext context, DraggableItem<T> item) {
    if (widget.placeholderBuilder != null) {
      return widget.placeholderBuilder!(context, item);
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          style: BorderStyle.solid,
          width: 2,
        ),
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.1),
      ),
      child: Center(
        child: Icon(
          Icons.add,
          size: 32,
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  /// 开始拖拽
  void _onDragStarted(int index) {
    setState(() {
      _draggedIndex = index;
    });
    _animationController.forward();
  }

  /// 结束拖拽
  void _onDragEnd() {
    setState(() {
      _draggedIndex = null;
      _hoveredIndex = null;
    });
    _animationController.reverse();
  }

  /// 拖拽移动
  void _onDragMove(int index) {
    if (_hoveredIndex != index) {
      setState(() {
        _hoveredIndex = index;
      });
    }
  }

  /// 拖拽离开
  void _onDragLeave() {
    setState(() {
      _hoveredIndex = null;
    });
  }

  /// 悬停进入
  void _onHoverEnter(int index) {
    if (_draggedIndex == null) {
      setState(() {
        _hoveredIndex = index;
      });
    }
  }

  /// 悬停离开
  void _onHoverExit() {
    if (_draggedIndex == null) {
      setState(() {
        _hoveredIndex = null;
      });
    }
  }

  /// 检查是否可以接受拖拽
  bool _canAcceptDrop(DraggableItem<T> target, DraggableItem<T>? source) {
    if (source == null || source.id == target.id) return false;
    return target.canAcceptDrop;
  }

  /// 接受拖拽
  void _onAcceptDrop(int targetIndex, DraggableItem<T> sourceItem) {
    final sourceIndex = _items.indexWhere((item) => item.id == sourceItem.id);
    if (sourceIndex == -1 || sourceIndex == targetIndex) return;

    setState(() {
      final item = _items.removeAt(sourceIndex);
      _items.insert(targetIndex, item);
    });

    // 触发回调
    widget.onReorder?.call(sourceIndex, targetIndex, sourceItem);
  }
}

/// 简化的可拖拽列表组件
class DraggableList<T> extends StatefulWidget {
  /// 项目列表
  final List<DraggableItem<T>> items;
  
  /// 项目构建器
  final ItemBuilder<T> itemBuilder;
  
  /// 拖拽完成回调
  final DragCallback<T>? onReorder;
  
  /// 内边距
  final EdgeInsets padding;
  
  /// 项目间距
  final double spacing;
  
  /// 是否启用拖拽
  final bool enableDrag;

  const DraggableList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.onReorder,
    this.padding = const EdgeInsets.all(16),
    this.spacing = 8,
    this.enableDrag = true,
  });

  @override
  State<DraggableList<T>> createState() => _DraggableListState<T>();
}

class _DraggableListState<T> extends State<DraggableList<T>> {
  late List<DraggableItem<T>> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
  }

  @override
  void didUpdateWidget(DraggableList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items != oldWidget.items) {
      _items = List.from(widget.items);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      padding: widget.padding,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _items.length,
      onReorder: _onReorder,
      itemBuilder: (context, index) {
        final item = _items[index];
        return Container(
          key: ValueKey(item.id),
          margin: EdgeInsets.only(bottom: widget.spacing),
          child: AnimationUtils.listItemAnimation(
            index: index,
            child: widget.itemBuilder(context, item, index),
          ),
        );
      },
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
    });

    widget.onReorder?.call(oldIndex, newIndex, _items[newIndex]);
  }
}
