/*
---------------------------------------------------------------
File name:          publish_manager_tab.dart
Author:             lgnorant-lu
Date created:       2025-07-22
Last modified:      2025-07-22
Dart Version:       3.2+
Description:        发布管理标签页
---------------------------------------------------------------
Change History:
    2025-07-22: Phase 5.0.6.3 - 发布管理功能实现;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';

/// 发布状态
enum PublishStatus {
  draft('草稿'),
  reviewing('审核中'),
  approved('已通过'),
  rejected('已拒绝'),
  published('已发布'),
  suspended('已暂停');

  const PublishStatus(this.displayName);
  final String displayName;
}

/// 发布记录
class PublishRecord {
  const PublishRecord({
    required this.id,
    required this.projectName,
    required this.version,
    required this.status,
    required this.submittedAt,
    this.publishedAt,
    this.downloads = 0,
    this.rating = 0.0,
    this.reviewNotes,
  });

  final String id;
  final String projectName;
  final String version;
  final PublishStatus status;
  final DateTime submittedAt;
  final DateTime? publishedAt;
  final int downloads;
  final double rating;
  final String? reviewNotes;
}

/// 发布管理标签页
class PublishManagerTab extends StatefulWidget {
  const PublishManagerTab({super.key});

  @override
  State<PublishManagerTab> createState() => _PublishManagerTabState();
}

class _PublishManagerTabState extends State<PublishManagerTab> {
  List<PublishRecord> _publishRecords = [];
  bool _isLoading = true;
  PublishStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadPublishRecords();
  }

  /// 加载发布记录
  Future<void> _loadPublishRecords() async {
    setState(() {
      _isLoading = true;
    });

    // TODO: Phase 5.0.6.3 - 从真实数据源加载发布记录
    // 当前使用模拟数据
    await Future<void>.delayed(const Duration(milliseconds: 500));

    final now = DateTime.now();
    _publishRecords = [
      PublishRecord(
        id: 'pub_001',
        projectName: '高级画笔工具',
        version: '1.2.0',
        status: PublishStatus.published,
        submittedAt: now.subtract(const Duration(days: 30)),
        publishedAt: now.subtract(const Duration(days: 28)),
        downloads: 1520,
        rating: 4.8,
      ),
      PublishRecord(
        id: 'pub_002',
        projectName: '高级画笔工具',
        version: '1.1.0',
        status: PublishStatus.published,
        submittedAt: now.subtract(const Duration(days: 60)),
        publishedAt: now.subtract(const Duration(days: 58)),
        downloads: 890,
        rating: 4.6,
      ),
      PublishRecord(
        id: 'pub_003',
        projectName: '拼图游戏引擎',
        version: '0.9.0',
        status: PublishStatus.reviewing,
        submittedAt: now.subtract(const Duration(days: 3)),
        reviewNotes: '正在进行安全性审核',
      ),
      PublishRecord(
        id: 'pub_004',
        projectName: '颜色管理器',
        version: '0.8.0',
        status: PublishStatus.rejected,
        submittedAt: now.subtract(const Duration(days: 10)),
        reviewNotes: '需要完善用户文档和示例代码',
      ),
      PublishRecord(
        id: 'pub_005',
        projectName: '暗色主题包',
        version: '1.0.0',
        status: PublishStatus.approved,
        submittedAt: now.subtract(const Duration(days: 5)),
        reviewNotes: '审核通过，等待发布',
      ),
    ];

    setState(() {
      _isLoading = false;
    });
  }

  /// 过滤发布记录
  List<PublishRecord> get _filteredRecords {
    if (_selectedStatus == null) {
      return _publishRecords;
    }
    return _publishRecords.where((record) => record.status == _selectedStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 统计面板
        _buildStatsPanel(),

        // 过滤栏
        _buildFilterBar(),

        // 发布记录列表
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildPublishRecordsList(),
        ),
      ],
    );
  }

  /// 构建统计面板
  Widget _buildStatsPanel() {
    final totalPublished = _publishRecords.where((r) => r.status == PublishStatus.published).length;
    final totalDownloads = _publishRecords.fold<int>(0, (sum, record) => sum + record.downloads);
    final averageRating = _publishRecords.where((r) => r.rating > 0).isEmpty
        ? 0.0
        : _publishRecords.where((r) => r.rating > 0).fold<double>(0, (sum, record) => sum + record.rating) /
            _publishRecords.where((r) => r.rating > 0).length;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.publish,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '发布统计',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '已发布',
                  totalPublished.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '总下载量',
                  _formatNumber(totalDownloads),
                  Icons.download,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '平均评分',
                  averageRating.toStringAsFixed(1),
                  Icons.star,
                  Colors.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '审核中',
                  _publishRecords.where((r) => r.status == PublishStatus.reviewing).length.toString(),
                  Icons.hourglass_empty,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建统计卡片
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 构建过滤栏
  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text('状态过滤:'),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('全部'),
                    selected: _selectedStatus == null,
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatus = selected ? null : _selectedStatus;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  ...PublishStatus.values.map((status) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(status.displayName),
                          selected: _selectedStatus == status,
                          onSelected: (selected) {
                            setState(() {
                              _selectedStatus = selected ? status : null;
                            });
                          },
                        ),
                      )),
                ],
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _publishNewVersion,
            icon: const Icon(Icons.publish),
            label: const Text('发布新版本'),
          ),
        ],
      ),
    );
  }

  /// 构建发布记录列表
  Widget _buildPublishRecordsList() {
    final filteredRecords = _filteredRecords;

    if (filteredRecords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.publish,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _publishRecords.isEmpty ? '暂无发布记录' : '没有找到匹配的记录',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            if (_publishRecords.isEmpty) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _publishNewVersion,
                icon: const Icon(Icons.publish),
                label: const Text('发布第一个版本'),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredRecords.length,
      itemBuilder: (context, index) {
        return _buildPublishRecordCard(filteredRecords[index]);
      },
    );
  }

  /// 构建发布记录卡片
  Widget _buildPublishRecordCard(PublishRecord record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 项目名称和版本
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${record.projectName} v${record.version}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusChip(record.status),
              ],
            ),

            const SizedBox(height: 12),

            // 发布信息
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '提交: ${_formatDate(record.submittedAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                if (record.publishedAt != null) ...[
                  const SizedBox(width: 16),
                  Icon(
                    Icons.publish,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '发布: ${_formatDate(record.publishedAt!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),

            // 统计信息（仅已发布版本）
            if (record.status == PublishStatus.published) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.download,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_formatNumber(record.downloads)} 下载',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.star,
                    size: 16,
                    color: Colors.amber[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${record.rating.toStringAsFixed(1)} 评分',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],

            // 审核备注
            if (record.reviewNotes != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getStatusColor(record.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: _getStatusColor(record.status).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.note,
                      size: 16,
                      color: _getStatusColor(record.status),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        record.reviewNotes!,
                        style: TextStyle(
                          fontSize: 12,
                          color: _getStatusColor(record.status),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // 操作按钮
            const SizedBox(height: 12),
            Row(
              children: [
                if (record.status == PublishStatus.approved)
                  ElevatedButton.icon(
                    onPressed: () => _publishVersion(record),
                    icon: const Icon(Icons.publish, size: 16),
                    label: const Text('立即发布'),
                  ),
                if (record.status == PublishStatus.rejected)
                  ElevatedButton.icon(
                    onPressed: () => _resubmitVersion(record),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('重新提交'),
                  ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _viewDetails(record),
                  icon: const Icon(Icons.info, size: 16),
                  label: const Text('详情'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建状态标签
  Widget _buildStatusChip(PublishStatus status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  /// 获取状态颜色
  Color _getStatusColor(PublishStatus status) {
    switch (status) {
      case PublishStatus.draft:
        return Colors.grey;
      case PublishStatus.reviewing:
        return Colors.orange;
      case PublishStatus.approved:
        return Colors.green;
      case PublishStatus.rejected:
        return Colors.red;
      case PublishStatus.published:
        return Colors.blue;
      case PublishStatus.suspended:
        return Colors.purple;
    }
  }

  /// 格式化数字
  String _formatNumber(int number) {
    if (number < 1000) {
      return number.toString();
    } else if (number < 1000000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 发布新版本
  void _publishNewVersion() {
    // TODO: Phase 5.0.6.3 - 实现发布新版本功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('发布新版本功能即将推出...')),
    );
  }

  /// 发布版本
  void _publishVersion(PublishRecord record) {
    // TODO: Phase 5.0.6.3 - 实现版本发布功能
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('正在发布 ${record.projectName} v${record.version}...')),
    );
  }

  /// 重新提交版本
  void _resubmitVersion(PublishRecord record) {
    // TODO: Phase 5.0.6.3 - 实现重新提交功能
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('重新提交 ${record.projectName} v${record.version}...')),
    );
  }

  /// 查看详情
  void _viewDetails(PublishRecord record) {
    // TODO: Phase 5.0.6.3 - 实现详情页面
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('查看 ${record.projectName} v${record.version} 详情')),
    );
  }
}
