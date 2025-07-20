/*
---------------------------------------------------------------
File name:          pet_analytics_page.dart
Author:             Pet App V3 Team
Date created:       2025-07-20
Last modified:      2025-07-20
Dart Version:       3.2+
Description:        桌宠数据分析页面 - 显示桌宠的详细分析和洞察
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/pet_provider.dart';
import '../../../core/services/pet_data_service.dart';

/// 桌宠数据分析页面
class PetAnalyticsPage extends ConsumerStatefulWidget {
  const PetAnalyticsPage({super.key});

  @override
  ConsumerState<PetAnalyticsPage> createState() => _PetAnalyticsPageState();
}

class _PetAnalyticsPageState extends ConsumerState<PetAnalyticsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  PetInsights? _insights;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAnalytics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final currentPet = ref.read(currentPetProvider);
      if (currentPet == null) {
        setState(() {
          _error = '没有当前桌宠';
          _isLoading = false;
        });
        return;
      }

      final dataService = ref.read(petDataServiceProvider);
      final insights = await dataService.generateInsights(
        currentPet.id,
        currentPet,
        [], // TODO: 获取历史数据
      );

      setState(() {
        _insights = insights;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '桌宠分析',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: '健康趋势'),
            Tab(text: '行为模式'),
            Tab(text: '性格分析'),
            Tab(text: '照顾质量'),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
        ),
      );
    }

    if (_error != null) {
      return _buildErrorWidget();
    }

    if (_insights == null) {
      return _buildNoDataWidget();
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildHealthTrendTab(),
        _buildBehaviorPatternTab(),
        _buildPersonalityTab(),
        _buildCareQualityTab(),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('加载分析数据失败', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadAnalytics,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
            ),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            '暂无分析数据',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('与桌宠互动一段时间后再查看分析', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildHealthTrendTab() {
    final healthTrend = _insights!.healthTrend;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildTrendCard(
          title: '健康趋势',
          trend: healthTrend.healthTrend,
          icon: Icons.favorite,
          color: Colors.red,
        ),
        const SizedBox(height: 16),
        _buildTrendCard(
          title: '能量趋势',
          trend: healthTrend.energyTrend,
          icon: Icons.battery_charging_full,
          color: Colors.blue,
        ),
        const SizedBox(height: 16),
        _buildTrendCard(
          title: '快乐趋势',
          trend: healthTrend.happinessTrend,
          icon: Icons.sentiment_satisfied,
          color: Colors.pink,
        ),
        const SizedBox(height: 16),
        _buildTrendCard(
          title: '总体趋势',
          trend: healthTrend.overallTrend,
          icon: Icons.trending_up,
          color: Colors.green,
        ),
        const SizedBox(height: 16),
        _buildRiskFactorsCard(healthTrend.riskFactors),
        const SizedBox(height: 16),
        _buildRecommendationsCard(healthTrend.recommendations),
      ],
    );
  }

  Widget _buildBehaviorPatternTab() {
    final behaviorPattern = _insights!.behaviorPattern;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildFavoriteActivitiesCard(behaviorPattern.favoriteActivities),
        const SizedBox(height: 16),
        _buildCommonMoodsCard(behaviorPattern.commonMoods),
        const SizedBox(height: 16),
        _buildActiveHoursCard(behaviorPattern.activeHours),
        const SizedBox(height: 16),
        _buildDiversityCard(
          title: '活动多样性',
          value: behaviorPattern.activityDiversity,
          icon: Icons.diversity_3,
          color: Colors.orange,
        ),
        const SizedBox(height: 16),
        _buildDiversityCard(
          title: '心情稳定性',
          value: behaviorPattern.moodStability,
          icon: Icons.psychology,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildPersonalityTab() {
    final personalityTraits = _insights!.personalityTraits;
    final predictions = _insights!.predictions;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildPersonalityTraitsCard(personalityTraits),
        const SizedBox(height: 16),
        _buildPredictionsCard(predictions),
      ],
    );
  }

  Widget _buildCareQualityTab() {
    final careQuality = _insights!.careQuality;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCareQualityScoreCard(careQuality),
        const SizedBox(height: 16),
        _buildCareFactorsCard(careQuality.factors),
      ],
    );
  }

  Widget _buildTrendCard({
    required String title,
    required TrendDirection trend,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getTrendDescription(trend),
                  style: TextStyle(
                    color: _getTrendColor(trend),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(_getTrendIcon(trend), color: _getTrendColor(trend), size: 32),
        ],
      ),
    );
  }

  Widget _buildRiskFactorsCard(List<String> riskFactors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                '风险因素',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (riskFactors.isEmpty)
            const Text('暂无风险因素', style: TextStyle(color: Colors.green))
          else
            ...riskFactors.map(
              (risk) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 8, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(child: Text(risk)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard(List<String> recommendations) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                '建议',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recommendations.map(
            (recommendation) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 8, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(child: Text(recommendation)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteActivitiesCard(List<dynamic> activities) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.favorite, color: Colors.pink),
              SizedBox(width: 8),
              Text(
                '喜爱的活动',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (activities.isEmpty)
            const Text('暂无数据')
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: activities
                  .map(
                    (activity) => Chip(
                      label: Text('${activity.emoji} ${activity.displayName}'),
                      backgroundColor: Colors.pink.withOpacity(0.1),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildCommonMoodsCard(List<dynamic> moods) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.sentiment_satisfied, color: Colors.green),
              SizedBox(width: 8),
              Text(
                '常见心情',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (moods.isEmpty)
            const Text('暂无数据')
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: moods
                  .map(
                    (mood) => Chip(
                      label: Text('${mood.emoji} ${mood.displayName}'),
                      backgroundColor: Colors.green.withOpacity(0.1),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildActiveHoursCard(List<int> hours) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.schedule, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                '活跃时间段',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (hours.isEmpty)
            const Text('暂无数据')
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: hours
                  .map(
                    (hour) => Chip(
                      label: Text('${hour}:00'),
                      backgroundColor: Colors.blue.withOpacity(0.1),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildDiversityCard({
    required String title,
    required double value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: value,
                  backgroundColor: Colors.grey.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(value * 100).toInt()}%',
                  style: TextStyle(color: color, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalityTraitsCard(List<String> traits) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.psychology, color: Colors.purple),
              SizedBox(width: 8),
              Text(
                '性格特征',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (traits.isEmpty)
            const Text('性格发展中...')
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: traits
                  .map(
                    (trait) => Chip(
                      label: Text(trait),
                      backgroundColor: Colors.purple.withOpacity(0.1),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildPredictionsCard(List<String> predictions) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.indigo),
              SizedBox(width: 8),
              Text(
                '预测分析',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...predictions.map(
            (prediction) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 8, color: Colors.indigo),
                  const SizedBox(width: 8),
                  Expanded(child: Text(prediction)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCareQualityScoreCard(CareQuality careQuality) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber),
              const SizedBox(width: 8),
              const Text(
                '照顾质量评分',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getCareQualityColor(careQuality.score),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${careQuality.score}/100',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: careQuality.score / 100,
            backgroundColor: Colors.grey.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              _getCareQualityColor(careQuality.score),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '照顾水平: ${careQuality.level}',
            style: TextStyle(
              color: _getCareQualityColor(careQuality.score),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCareFactorsCard(List<String> factors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.checklist, color: Colors.green),
              SizedBox(width: 8),
              Text(
                '照顾要素',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...factors.map(
            (factor) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(child: Text(factor)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTrendDescription(TrendDirection trend) {
    switch (trend) {
      case TrendDirection.improving:
        return '正在改善';
      case TrendDirection.stable:
        return '保持稳定';
      case TrendDirection.declining:
        return '正在下降';
    }
  }

  Color _getTrendColor(TrendDirection trend) {
    switch (trend) {
      case TrendDirection.improving:
        return Colors.green;
      case TrendDirection.stable:
        return Colors.blue;
      case TrendDirection.declining:
        return Colors.red;
    }
  }

  IconData _getTrendIcon(TrendDirection trend) {
    switch (trend) {
      case TrendDirection.improving:
        return Icons.trending_up;
      case TrendDirection.stable:
        return Icons.trending_flat;
      case TrendDirection.declining:
        return Icons.trending_down;
    }
  }

  Color _getCareQualityColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    if (score >= 40) return Colors.deepOrange;
    return Colors.red;
  }
}
