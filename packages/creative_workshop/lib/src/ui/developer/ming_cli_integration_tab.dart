/*
---------------------------------------------------------------
File name:          ming_cli_integration_tab.dart
Author:             lgnorant-lu
Date created:       2025-07-22
Last modified:      2025-07-22
Dart Version:       3.2+
Description:        Ming CLI 集成标签页
---------------------------------------------------------------
Change History:
    2025-07-21: Phase 5.0.6.3 - Ming CLI 集成功能实现;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';

/// CLI 命令类型
enum CliCommandType {
  create('创建项目'),
  build('构建项目'),
  test('运行测试'),
  publish('发布插件'),
  validate('验证项目'),
  doctor('环境诊断');

  const CliCommandType(this.displayName);
  final String displayName;
}

/// CLI 命令历史
class CliCommandHistory {
  const CliCommandHistory({
    required this.command,
    required this.executedAt,
    required this.success,
    this.output,
    this.error,
  });

  final String command;
  final DateTime executedAt;
  final bool success;
  final String? output;
  final String? error;
}

/// Ming CLI 集成标签页
class MingCliIntegrationTab extends StatefulWidget {
  const MingCliIntegrationTab({super.key});

  @override
  State<MingCliIntegrationTab> createState() => _MingCliIntegrationTabState();
}

class _MingCliIntegrationTabState extends State<MingCliIntegrationTab> {
  final TextEditingController _commandController = TextEditingController();
  final ScrollController _outputScrollController = ScrollController();

  bool _isCliInstalled = false;
  bool _isExecuting = false;
  String _cliVersion = '';
  List<CliCommandHistory> _commandHistory = [];
  String _currentOutput = '';

  @override
  void initState() {
    super.initState();
    _checkCliInstallation();
    _loadCommandHistory();
  }

  @override
  void dispose() {
    _commandController.dispose();
    _outputScrollController.dispose();
    super.dispose();
  }

  /// 检查 CLI 安装状态
  Future<void> _checkCliInstallation() async {
    // TODO: Phase 5.0.6.3 - 实际检查 Ming CLI 安装状态
    // 当前使用模拟检查
    await Future<void>.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isCliInstalled = true; // 模拟已安装
      _cliVersion = '1.2.0';
    });
  }

  /// 加载命令历史
  Future<void> _loadCommandHistory() async {
    // TODO: Phase 5.0.6.3 - 从本地存储加载命令历史
    // 当前使用模拟数据
    final now = DateTime.now();
    _commandHistory = [
      CliCommandHistory(
        command: 'ming create my-plugin --type tool',
        executedAt: now.subtract(const Duration(hours: 2)),
        success: true,
        output: '✅ 项目创建成功\n📁 项目路径: ./my-plugin\n🎯 项目类型: 工具插件',
      ),
      CliCommandHistory(
        command: 'ming build',
        executedAt: now.subtract(const Duration(minutes: 30)),
        success: true,
        output: '🔨 开始构建...\n✅ 构建完成\n📦 输出: ./build/my-plugin.zip',
      ),
      CliCommandHistory(
        command: 'ming test',
        executedAt: now.subtract(const Duration(minutes: 15)),
        success: false,
        error: '❌ 测试失败\n📝 错误: 缺少必要的测试文件',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // CLI 状态面板
        _buildCliStatusPanel(),

        // 快速命令面板
        _buildQuickCommandsPanel(),

        // 命令输入和输出区域
        Expanded(
          child: Row(
            children: [
              // 左侧：命令历史
              Expanded(
                flex: 1,
                child: _buildCommandHistory(),
              ),

              // 右侧：命令输入和输出
              Expanded(
                flex: 2,
                child: _buildCommandInterface(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建 CLI 状态面板
  Widget _buildCliStatusPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.terminal,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ming CLI 状态',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      _isCliInstalled ? Icons.check_circle : Icons.error,
                      size: 16,
                      color: _isCliInstalled ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isCliInstalled ? '已安装 (v$_cliVersion)' : '未安装',
                      style: TextStyle(
                        color: _isCliInstalled ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!_isCliInstalled)
            ElevatedButton.icon(
              onPressed: _installCli,
              icon: const Icon(Icons.download),
              label: const Text('安装 CLI'),
            )
          else
            Row(
              children: [
                IconButton(
                  onPressed: _updateCli,
                  icon: const Icon(Icons.update),
                  tooltip: '检查更新',
                ),
                IconButton(
                  onPressed: _openCliDocumentation,
                  icon: const Icon(Icons.help),
                  tooltip: '查看文档',
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// 构建快速命令面板
  Widget _buildQuickCommandsPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '快速命令',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: CliCommandType.values.map((type) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(type.displayName),
                    avatar: Icon(
                      _getCommandIcon(type),
                      size: 16,
                    ),
                    onPressed: () => _executeQuickCommand(type),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建命令历史
  Widget _buildCommandHistory() {
    return Container(
      margin: const EdgeInsets.only(left: 16, bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.history, size: 16),
                const SizedBox(width: 8),
                Text(
                  '命令历史',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _commandHistory.isEmpty
                ? const Center(
                    child: Text(
                      '暂无命令历史',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _commandHistory.length,
                    itemBuilder: (context, index) {
                      final history = _commandHistory[index];
                      return ListTile(
                        dense: true,
                        leading: Icon(
                          history.success ? Icons.check_circle : Icons.error,
                          size: 16,
                          color: history.success ? Colors.green : Colors.red,
                        ),
                        title: Text(
                          history.command,
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          _formatTime(history.executedAt),
                          style: const TextStyle(fontSize: 10),
                        ),
                        onTap: () => _rerunCommand(history.command),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// 构建命令界面
  Widget _buildCommandInterface() {
    return Container(
      margin: const EdgeInsets.only(right: 16, bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          // 命令输入
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'ming',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _commandController,
                    enabled: _isCliInstalled && !_isExecuting,
                    decoration: const InputDecoration(
                      hintText: '输入命令...',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: const TextStyle(fontFamily: 'monospace'),
                    onSubmitted: _executeCommand,
                  ),
                ),
                IconButton(
                  onPressed: _isCliInstalled && !_isExecuting
                      ? () => _executeCommand(_commandController.text)
                      : null,
                  icon: _isExecuting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow),
                  tooltip: '执行命令',
                ),
              ],
            ),
          ),

          // 输出区域
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                controller: _outputScrollController,
                child: Text(
                  _currentOutput.isEmpty ? '等待命令执行...' : _currentOutput,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: _currentOutput.isEmpty ? Colors.grey : null,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 获取命令图标
  IconData _getCommandIcon(CliCommandType type) {
    switch (type) {
      case CliCommandType.create:
        return Icons.create_new_folder;
      case CliCommandType.build:
        return Icons.build;
      case CliCommandType.test:
        return Icons.verified;
      case CliCommandType.publish:
        return Icons.publish;
      case CliCommandType.validate:
        return Icons.check_circle;
      case CliCommandType.doctor:
        return Icons.medical_services;
    }
  }

  /// 格式化时间
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小时前';
    } else {
      return '${difference.inDays}天前';
    }
  }

  /// 执行快速命令
  void _executeQuickCommand(CliCommandType type) {
    String command;
    switch (type) {
      case CliCommandType.create:
        command = 'create my-plugin --type tool';
        break;
      case CliCommandType.build:
        command = 'build';
        break;
      case CliCommandType.test:
        command = 'test';
        break;
      case CliCommandType.publish:
        command = 'publish';
        break;
      case CliCommandType.validate:
        command = 'validate';
        break;
      case CliCommandType.doctor:
        command = 'doctor';
        break;
    }

    _commandController.text = command;
    _executeCommand(command);
  }

  /// 执行命令
  Future<void> _executeCommand(String command) async {
    if (command.trim().isEmpty || !_isCliInstalled || _isExecuting) {
      return;
    }

    setState(() {
      _isExecuting = true;
      _currentOutput = '\$ ming $command\n正在执行...\n';
    });

    // TODO: Phase 5.0.6.3 - 实际执行 Ming CLI 命令
    // 当前使用模拟执行
    await Future<void>.delayed(const Duration(seconds: 2));

    final success = command != 'test'; // 模拟测试命令失败
    final output = success
        ? '✅ 命令执行成功\n📝 输出: 模拟命令输出内容\n⏱️ 执行时间: 2.1s'
        : '❌ 命令执行失败\n📝 错误: 模拟错误信息\n💡 建议: 检查命令参数';

    setState(() {
      _isExecuting = false;
      _currentOutput = '\$ ming $command\n$output';
    });

    // 添加到历史记录
    _commandHistory.insert(
      0,
      CliCommandHistory(
        command: 'ming $command',
        executedAt: DateTime.now(),
        success: success,
        output: success ? output : null,
        error: success ? null : output,
      ),
    );

    // 滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _outputScrollController.animateTo(
        _outputScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    _commandController.clear();
  }

  /// 重新运行命令
  void _rerunCommand(String command) {
    final cleanCommand =
        command.startsWith('ming ') ? command.substring(5) : command;
    _commandController.text = cleanCommand;
    _executeCommand(cleanCommand);
  }

  /// 安装 CLI
  void _installCli() {
    // TODO: Phase 5.0.6.3 - 实现 CLI 安装功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('CLI 安装功能即将推出...')),
    );
  }

  /// 更新 CLI
  void _updateCli() {
    // TODO: Phase 5.0.6.3 - 实现 CLI 更新功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('检查 CLI 更新...')),
    );
  }

  /// 打开 CLI 文档
  void _openCliDocumentation() {
    // TODO: Phase 5.0.6.3 - 打开 CLI 文档
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('打开 Ming CLI 文档...')),
    );
  }
}
