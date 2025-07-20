/*
---------------------------------------------------------------
File name:          settings_tile.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        设置项组件 - 各种类型的设置项UI组件
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import '../../../../constants/app_strings.dart';

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

  /// 开关设置项
  factory SettingsTile.switchTile({
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
      trailing: Switch(value: value, onChanged: onChanged),
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
  factory SettingsTile.slider({
    required String title,
    String? subtitle,
    IconData? leading,
    required double value,
    required double min,
    required double max,
    int? divisions,
    required ValueChanged<double> onChanged,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return SettingsTile(
      title: title,
      subtitle: subtitle,
      leading: leading,
      contentPadding: contentPadding,
      trailing: SizedBox(
        width: 150,
        child: Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ),
    );
  }

  /// 文本输入设置项
  factory SettingsTile.textField({
    required String title,
    String? subtitle,
    IconData? leading,
    required String value,
    required ValueChanged<String> onChanged,
    String? hintText,
    TextInputType? keyboardType,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return SettingsTile(
      title: title,
      subtitle: subtitle,
      leading: leading,
      contentPadding: contentPadding,
      trailing: SizedBox(
        width: 150,
        child: TextField(
          controller: TextEditingController(text: value),
          decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
          keyboardType: keyboardType,
          onChanged: onChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading != null ? Icon(leading) : null,
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
      contentPadding:
          contentPadding ?? const EdgeInsets.symmetric(horizontal: 16.0),
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
    final context =
        WidgetsBinding.instance.focusManager.primaryFocus?.context ??
        WidgetsBinding.instance.rootElement;

    if (context == null) return;

    showDialog<T>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((option) {
              return RadioListTile<T>(
                title: Text(option.title),
                subtitle: option.subtitle != null
                    ? Text(option.subtitle!)
                    : null,
                value: option.value,
                groupValue: value,
                onChanged: (T? selectedValue) {
                  Navigator.of(context).pop();
                  onChanged(selectedValue);
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(AppStrings.cancel),
            ),
          ],
        );
      },
    );
  }
}
