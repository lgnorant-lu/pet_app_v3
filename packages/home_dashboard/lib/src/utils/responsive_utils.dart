/*
---------------------------------------------------------------
File name:          responsive_utils.dart
Author:             lgnorant-lu
Date created:       2025-07-24
Last modified:      2025-07-24
Dart Version:       3.2+
Description:        响应式布局工具类 - Phase 5.0.7.3 交互体验优化
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

/// 设备类型枚举
enum DeviceType {
  /// 手机
  mobile,
  /// 平板
  tablet,
  /// 桌面
  desktop,
}

/// 屏幕尺寸枚举
enum ScreenSize {
  /// 小屏幕 (< 600px)
  small,
  /// 中等屏幕 (600px - 1024px)
  medium,
  /// 大屏幕 (1024px - 1440px)
  large,
  /// 超大屏幕 (> 1440px)
  extraLarge,
}

/// 响应式布局工具类
class ResponsiveUtils {
  ResponsiveUtils._();

  /// 断点定义
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

  /// 获取设备类型
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < mobileBreakpoint) {
      return DeviceType.mobile;
    } else if (width < tabletBreakpoint) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// 获取屏幕尺寸
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < mobileBreakpoint) {
      return ScreenSize.small;
    } else if (width < tabletBreakpoint) {
      return ScreenSize.medium;
    } else if (width < desktopBreakpoint) {
      return ScreenSize.large;
    } else {
      return ScreenSize.extraLarge;
    }
  }

  /// 是否为手机
  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }

  /// 是否为平板
  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  /// 是否为桌面
  static bool isDesktop(BuildContext context) {
    return getDeviceType(context) == DeviceType.desktop;
  }

  /// 获取网格列数
  static int getGridColumns(BuildContext context, {
    int mobileColumns = 2,
    int tabletColumns = 3,
    int desktopColumns = 4,
  }) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return mobileColumns;
      case DeviceType.tablet:
        return tabletColumns;
      case DeviceType.desktop:
        return desktopColumns;
    }
  }

  /// 获取响应式值
  static T getResponsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }

  /// 获取响应式边距
  static EdgeInsets getResponsivePadding(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: const EdgeInsets.all(16),
      tablet: const EdgeInsets.all(24),
      desktop: const EdgeInsets.all(32),
    );
  }

  /// 获取响应式字体大小
  static double getResponsiveFontSize(
    BuildContext context,
    double baseFontSize,
  ) {
    final scaleFactor = getResponsiveValue(
      context,
      mobile: 1.0,
      tablet: 1.1,
      desktop: 1.2,
    );
    return baseFontSize * scaleFactor;
  }

  /// 获取响应式间距
  static double getResponsiveSpacing(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: 8.0,
      tablet: 12.0,
      desktop: 16.0,
    );
  }

  /// 获取响应式卡片宽度
  static double getCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return getResponsiveValue(
      context,
      mobile: screenWidth - 32, // 留出边距
      tablet: (screenWidth - 64) / 2, // 两列布局
      desktop: (screenWidth - 96) / 3, // 三列布局
    );
  }

  /// 获取响应式最大宽度
  static double getMaxWidth(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: double.infinity,
      tablet: 800,
      desktop: 1200,
    );
  }

  /// 获取响应式侧边栏宽度
  static double getSidebarWidth(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: MediaQuery.of(context).size.width * 0.8,
      tablet: 300,
      desktop: 350,
    );
  }
}

/// 响应式构建器组件
class ResponsiveBuilder extends StatelessWidget {
  /// 手机布局构建器
  final Widget Function(BuildContext context)? mobile;
  
  /// 平板布局构建器
  final Widget Function(BuildContext context)? tablet;
  
  /// 桌面布局构建器
  final Widget Function(BuildContext context)? desktop;
  
  /// 默认布局构建器
  final Widget Function(BuildContext context) builder;

  const ResponsiveBuilder({
    super.key,
    this.mobile,
    this.tablet,
    this.desktop,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveUtils.getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile?.call(context) ?? builder(context);
      case DeviceType.tablet:
        return tablet?.call(context) ?? mobile?.call(context) ?? builder(context);
      case DeviceType.desktop:
        return desktop?.call(context) ?? 
               tablet?.call(context) ?? 
               mobile?.call(context) ?? 
               builder(context);
    }
  }
}

/// 响应式网格组件
class ResponsiveGrid extends StatelessWidget {
  /// 子组件列表
  final List<Widget> children;
  
  /// 手机列数
  final int mobileColumns;
  
  /// 平板列数
  final int tabletColumns;
  
  /// 桌面列数
  final int desktopColumns;
  
  /// 主轴间距
  final double mainAxisSpacing;
  
  /// 交叉轴间距
  final double crossAxisSpacing;
  
  /// 子组件宽高比
  final double childAspectRatio;
  
  /// 是否收缩包装
  final bool shrinkWrap;
  
  /// 滚动物理
  final ScrollPhysics? physics;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 2,
    this.tabletColumns = 3,
    this.desktopColumns = 4,
    this.mainAxisSpacing = 16,
    this.crossAxisSpacing = 16,
    this.childAspectRatio = 1.0,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveUtils.getGridColumns(
      context,
      mobileColumns: mobileColumns,
      tabletColumns: tabletColumns,
      desktopColumns: desktopColumns,
    );

    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// 响应式容器组件
class ResponsiveContainer extends StatelessWidget {
  /// 子组件
  final Widget child;
  
  /// 最大宽度
  final double? maxWidth;
  
  /// 是否居中
  final bool center;
  
  /// 内边距
  final EdgeInsets? padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.center = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveMaxWidth = maxWidth ?? ResponsiveUtils.getMaxWidth(context);
    final effectivePadding = padding ?? ResponsiveUtils.getResponsivePadding(context);

    Widget container = Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
      padding: effectivePadding,
      child: child,
    );

    if (center) {
      container = Center(child: container);
    }

    return container;
  }
}

/// 响应式文本组件
class ResponsiveText extends StatelessWidget {
  /// 文本内容
  final String text;
  
  /// 基础字体大小
  final double baseFontSize;
  
  /// 文本样式
  final TextStyle? style;
  
  /// 文本对齐
  final TextAlign? textAlign;
  
  /// 最大行数
  final int? maxLines;
  
  /// 溢出处理
  final TextOverflow? overflow;

  const ResponsiveText(
    this.text, {
    super.key,
    this.baseFontSize = 16,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final responsiveFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      baseFontSize,
    );

    return Text(
      text,
      style: (style ?? const TextStyle()).copyWith(
        fontSize: responsiveFontSize,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// 响应式间距组件
class ResponsiveSpacing extends StatelessWidget {
  /// 垂直间距
  final bool vertical;
  
  /// 倍数
  final double multiplier;

  const ResponsiveSpacing({
    super.key,
    this.vertical = true,
    this.multiplier = 1.0,
  });

  /// 垂直间距
  const ResponsiveSpacing.vertical({
    super.key,
    this.multiplier = 1.0,
  }) : vertical = true;

  /// 水平间距
  const ResponsiveSpacing.horizontal({
    super.key,
    this.multiplier = 1.0,
  }) : vertical = false;

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveUtils.getResponsiveSpacing(context) * multiplier;
    
    return SizedBox(
      width: vertical ? null : spacing,
      height: vertical ? spacing : null,
    );
  }
}
