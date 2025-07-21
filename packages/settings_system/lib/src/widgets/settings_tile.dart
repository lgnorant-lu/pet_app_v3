/*
---------------------------------------------------------------
File name:          settings_tile.dart
Author:             lgnorant-lu
Date created:       2025-07-21
Last modified:      2025-07-21
Dart Version:       3.2+
Description:        设置项组件 - 各种类型的设置项UI组件
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';

/// 选择选项数据模型
class SelectionOption<T> {
  final T value;
  final String title;
  final String? subtitle;

  const SelectionOption({
    required this.value,
    required this.title,
    this.subtitle,
  });
}

/// 设置项组件
///
/// 提供多种类型的设置项UI：
/// - 开关设置项
/// - 选择设置项
/// - 滑块设置项
/// - 文本输入设置项
class SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? contentPadding;

  const SettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      leading: leading != null ? Icon(leading) : null,
      trailing: trailing,
      onTap: onTap,
      contentPadding: contentPadding ??
          const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
    );
  }

  /// 开关设置项
  static SettingsTile switchTile({
    required String title,
    String? subtitle,
    IconData? leading,
    required bool value,
    required ValueChanged<bool> onChanged,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return SettingsTile(
      title: title,
      subtitle: subtitle,
      leading: leading,
      contentPadding: contentPadding,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  /// 选择设置项
  static SettingsTile selection<T>({
    required String title,
    String? subtitle,
    IconData? leading,
    required T value,
    required List<SelectionOption<T>> options,
    required ValueChanged<T?> onChanged,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return SettingsTile(
      title: title,
      subtitle: subtitle,
      leading: leading,
      contentPadding: contentPadding,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _showSelectionDialog<T>(
        title: title,
        value: value,
        options: options,
        onChanged: onChanged,
      ),
    );
  }

  /// 滑块设置项
  static Widget sliderTile({
    required String title,
    String? subtitle,
    IconData? leading,
    required double value,
    required double min,
    required double max,
    int? divisions,
    required ValueChanged<double> onChanged,
    EdgeInsetsGeometry? contentPadding,
    String Function(double)? valueFormatter,
  }) {
    return Builder(
      builder: (context) {
        return Column(
          children: [
            SettingsTile(
              title: title,
              subtitle: subtitle,
              leading: leading,
              contentPadding: contentPadding,
              trailing: Text(
                valueFormatter?.call(value) ?? value.toStringAsFixed(0),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: divisions,
                onChanged: onChanged,
              ),
            ),
          ],
        );
      },
    );
  }

  /// 文本输入设置项
  static Widget textField({
    required String title,
    String? subtitle,
    IconData? leading,
    required String value,
    String? hintText,
    TextInputType? keyboardType,
    required ValueChanged<String> onChanged,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return Builder(
      builder: (context) {
        return SettingsTile(
          title: title,
          subtitle: subtitle,
          leading: leading,
          contentPadding: contentPadding,
          trailing: const Icon(Icons.edit, size: 16),
          onTap: () => _showTextFieldDialog(
            context: context,
            title: title,
            value: value,
            hintText: hintText,
            keyboardType: keyboardType,
            onChanged: onChanged,
          ),
        );
      },
    );
  }

  /// 显示选择对话框
  static void _showSelectionDialog<T>({
    required String title,
    required T value,
    required List<SelectionOption<T>> options,
    required ValueChanged<T?> onChanged,
  }) {
    // 获取当前上下文
    final context = _getCurrentContext();
    if (context == null) return;

    showDialog<T>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((option) {
              return RadioListTile<T>(
                title: Text(option.title),
                subtitle:
                    option.subtitle != null ? Text(option.subtitle!) : null,
                value: option.value,
                groupValue: value,
                onChanged: (selectedValue) {
                  Navigator.of(context).pop();
                  onChanged(selectedValue);
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
        );
      },
    );
  }

  /// 显示文本输入对话框
  static void _showTextFieldDialog({
    required BuildContext context,
    required String title,
    required String value,
    String? hintText,
    TextInputType? keyboardType,
    required ValueChanged<String> onChanged,
  }) {
    final controller = TextEditingController(text: value);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              border: const OutlineInputBorder(),
            ),
            keyboardType: keyboardType,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onChanged(controller.text);
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  /// 获取当前上下文（简化实现）
  static BuildContext? _getCurrentContext() {
    // 这是一个简化的实现，实际使用中应该通过其他方式获取上下文
    // 在实际使用中，这个方法会被重写或通过其他方式提供上下文
    return null;
  }
}
