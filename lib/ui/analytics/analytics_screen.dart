import "package:fl_chart/fl_chart.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:google_fonts/google_fonts.dart";
import "../../core/theme/app_colors.dart";
import "../../data/models/task_model.dart";
import "../../data/providers/tasks_provider.dart";
import "../components/bottom_nav.dart";
import "../components/glass_card.dart";

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider);
    final total = tasks.length;
    final done = tasks.where((t) => t.isCompleted).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Analytics", style: Theme.of(context).textTheme.headlineMedium),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Text("Last 30 Days",
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Weekly Completion Line Chart
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Weekly Completion",
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                      Text("This week",
                          style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 160,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          getDrawingHorizontalLine: (_) => FlLine(
                            color: AppColors.outlineVariant.withValues(alpha: 0.3), strokeWidth: 1),
                          drawVerticalLine: false,
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true, reservedSize: 22,
                              getTitlesWidget: (v, _) {
                                const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
                                if (v.toInt() < days.length) {
                                  return Text(days[v.toInt()],
                                      style: GoogleFonts.inter(fontSize: 10, color: AppColors.onSurfaceVariant));
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              const FlSpot(0, 3), const FlSpot(1, 5), const FlSpot(2, 4), const FlSpot(3, 7),
                              const FlSpot(4, 6), const FlSpot(5, 8), FlSpot(6, done.toDouble().clamp(1, 10)),
                            ],
                            isCurved: true,
                            color: AppColors.primary,
                            barWidth: 2.5,
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [AppColors.primary.withValues(alpha: 0.3), Colors.transparent],
                                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                              ),
                            ),
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                                radius: 3, color: AppColors.primary,
                                strokeColor: AppColors.surfaceContainerLow, strokeWidth: 2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 12),
            // Row: AI Insight + Focus Donut
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 16),
                          const SizedBox(width: 6),
                          Text("AI Insight", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                        ]),
                        const SizedBox(height: 8),
                        Text("Your peak productivity is 9AM — 4 tasks completed before noon.",
                            style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurface, height: 1.4)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Text("Optimize", style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.onPrimary)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassCard(
                    child: Column(
                      children: [
                        Text("Focus Allocation",
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 110,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              PieChart(PieChartData(
                                sections: [
                                  PieChartSectionData(value: 70, color: AppColors.primary, title: "", radius: 28),
                                  PieChartSectionData(value: 20, color: AppColors.tertiary, title: "", radius: 28),
                                  PieChartSectionData(value: 10, color: AppColors.outlineVariant, title: "", radius: 28),
                                ],
                                centerSpaceRadius: 32, sectionsSpace: 2,
                              )),
                              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Text("6.4h", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                                Text("Avg Daily", style: GoogleFonts.inter(fontSize: 9, color: AppColors.onSurfaceVariant)),
                              ]),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        _Legend(color: AppColors.primary, label: "Deep Work 70%"),
                        _Legend(color: AppColors.tertiary, label: "Meetings 20%"),
                        _Legend(color: AppColors.outlineVariant, label: "Admin 10%"),
                      ],
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 12),
            // Priority breakdown
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("By Priority",
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                  const SizedBox(height: 16),
                  ...TaskPriority.values.map((p) {
                    final count = tasks.where((t) => t.priority == p).length;
                    final frac = total == 0 ? 0.0 : count / total;
                    final colors = {
                      TaskPriority.low: AppColors.onSurfaceVariant,
                      TaskPriority.medium: AppColors.warning,
                      TaskPriority.high: AppColors.primary,
                      TaskPriority.urgent: AppColors.error,
                    };
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text(p.name[0].toUpperCase() + p.name.substring(1),
                                style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface)),
                            Text("$count", style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant)),
                          ]),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(9999),
                            child: LinearProgressIndicator(
                              value: frac, minHeight: 6,
                              backgroundColor: AppColors.outlineVariant,
                              valueColor: AlwaysStoppedAnimation(colors[p]!),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Row(children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.inter(fontSize: 9, color: AppColors.onSurfaceVariant)),
        ]),
      );
}
