import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/providers.dart';
import '../../core/models/models.dart';

class RecyclingScreen extends ConsumerWidget {
  const RecyclingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(recyclingStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF0D2B0D), AppColors.background],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            const Text('♻️', style: TextStyle(fontSize: 28)),
                            const SizedBox(width: 10),
                            const Text('Recycling Impact',
                                style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text('Track your environmental contribution',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _HeroStat(
                              value: '${stats.totalKgDiverted.toStringAsFixed(1)} kg',
                              label: 'Total Diverted',
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: 20),
                            _HeroStat(
                              value: '${stats.co2Saved.toStringAsFixed(1)} kg',
                              label: 'CO₂ Saved',
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 20),
                            _HeroStat(
                              value: '🏆 ${stats.creditsEarned}',
                              label: 'Credits',
                              color: AppColors.warning,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Bar chart: Monthly diversion
                _SectionTitle('Monthly Progress'),
                const SizedBox(height: 12),
                Container(
                  height: 200,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _MonthlyBarChart(data: stats.monthlyData),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Legend(color: AppColors.accent, label: 'Recycled'),
                    const SizedBox(width: 20),
                    _Legend(color: AppColors.textMuted, label: 'General'),
                  ],
                ),
                const SizedBox(height: 24),

                // Stream breakdown
                _SectionTitle('By Waste Stream'),
                const SizedBox(height: 12),
                ...stats.byStream.entries.map((e) => _StreamBar(
                      stream: e.key,
                      kg: e.value,
                      total: stats.totalKgDiverted,
                    )),
                const SizedBox(height: 24),

                // Pie chart
                _SectionTitle('Diversion Mix'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        height: 160,
                        width: 160,
                        child: PieChart(
                          PieChartData(
                            sections: stats.byStream.entries.map((e) {
                              return PieChartSectionData(
                                value: e.value,
                                color: e.key.color,
                                radius: 55,
                                showTitle: false,
                              );
                            }).toList(),
                            centerSpaceRadius: 40,
                            sectionsSpace: 3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: stats.byStream.entries.map((e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 12, height: 12,
                                  decoration: BoxDecoration(
                                    color: e.key.color,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(e.key.label,
                                      style: const TextStyle(
                                          color: AppColors.textSecondary, fontSize: 12)),
                                ),
                                Text('${e.value.toStringAsFixed(1)} kg',
                                    style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          )).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Environmental equivalents
                _SectionTitle('Your Impact Equivalent'),
                const SizedBox(height: 12),
                _ImpactCard(
                  icon: '🌳',
                  title: '${(stats.co2Saved / 21.77).toStringAsFixed(0)} trees',
                  subtitle: 'CO₂ absorption equivalent for 1 year',
                  color: AppColors.accentDim,
                ),
                const SizedBox(height: 10),
                _ImpactCard(
                  icon: '🚗',
                  title: '${(stats.co2Saved / 0.21).toStringAsFixed(0)} km',
                  subtitle: 'Equivalent car emissions offset',
                  color: AppColors.info,
                ),
                const SizedBox(height: 10),
                _ImpactCard(
                  icon: '💧',
                  title: '${(stats.byStream[WasteStream.plastics]! * 16.5).toStringAsFixed(0)} L',
                  subtitle: 'Water saved by recycling plastics',
                  color: AppColors.streamGlass,
                ),
                const SizedBox(height: 32),

                // Credits card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A3800), Color(0xFF0D2A00)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text('🏆', style: TextStyle(fontSize: 28)),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Green Credits',
                                  style: TextStyle(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18)),
                              Text('Earned for quality recycling',
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Balance',
                                  style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                              Text('${stats.creditsEarned} credits',
                                  style: const TextStyle(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 26)),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(120, 44),
                            ),
                            child: const Text('Redeem'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: stats.creditsEarned / 500,
                        backgroundColor: AppColors.primary,
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      const SizedBox(height: 6),
                      Text('${500 - stats.creditsEarned} credits to next reward tier',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _HeroStat({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 18)),
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: const TextStyle(
            color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w700));
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
      ],
    );
  }
}

class _MonthlyBarChart extends StatelessWidget {
  final List<MonthlyData> data;
  const _MonthlyBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: data.map((d) => d.kgDiverted + d.kgGeneral).reduce((a, b) => a > b ? a : b) * 1.2,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, _) {
                final idx = val.toInt();
                if (idx < 0 || idx >= data.length) return const SizedBox.shrink();
                return Text(data[idx].month,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11));
              },
              reservedSize: 24,
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppColors.primaryLight.withOpacity(0.15),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(data.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: data[i].kgDiverted + data[i].kgGeneral,
                color: AppColors.textMuted.withOpacity(0.3),
                width: 16,
                borderRadius: BorderRadius.circular(4),
                rodStackItems: [
                  BarChartRodStackItem(0, data[i].kgDiverted, AppColors.accent),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _StreamBar extends StatelessWidget {
  final WasteStream stream;
  final double kg;
  final double total;

  const _StreamBar({required this.stream, required this.kg, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Row(
            children: [
              Text(stream.emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(stream.label,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ),
              Text('${kg.toStringAsFixed(1)} kg',
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: kg / total,
              backgroundColor: AppColors.card,
              color: stream.color,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImpactCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final Color color;

  const _ImpactCard({
    required this.icon, required this.title,
    required this.subtitle, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: color, fontWeight: FontWeight.w700, fontSize: 16)),
                Text(subtitle,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
