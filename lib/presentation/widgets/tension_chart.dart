import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:i18next/i18next.dart';
import 'package:untense/core/constants/app_constants.dart';
import 'package:untense/core/constants/tension_zones.dart';
import 'package:untense/core/utils/date_time_utils.dart';
import 'package:untense/domain/entities/tension_entry.dart';

/// Real-time line chart showing tension curve over the day.
/// Uses fl_chart for rendering.
class TensionChart extends StatelessWidget {
  final List<TensionEntry> entries;
  final TimeOfDay dayStart;
  final TimeOfDay dayEnd;

  const TensionChart({
    super.key,
    required this.entries,
    required this.dayStart,
    required this.dayEnd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final minX = AppDateTimeUtils.timeOfDayToDouble(dayStart);
    final maxX = AppDateTimeUtils.timeOfDayToDouble(dayEnd);

    return Container(
      height: 280,
      padding: const EdgeInsets.only(right: 16, top: 16, bottom: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: entries.isEmpty
          ? Center(
              child: Text(
                I18Next.of(context)?.t('chart.noData') ?? 'No data',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            )
          : LineChart(
              LineChartData(
                minX: minX,
                maxX: maxX,
                minY: AppConstants.tensionMin,
                maxY: AppConstants.tensionMax,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 10,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    // Highlight tipping points
                    if (value == AppConstants.tippingPoint1 ||
                        value == AppConstants.tippingPoint2) {
                      return FlLine(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.3)
                            : Colors.black.withValues(alpha: 0.2),
                        strokeWidth: 1.5,
                        dashArray: [8, 4],
                      );
                    }
                    return FlLine(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.07)
                          : Colors.black.withValues(alpha: 0.05),
                      strokeWidth: 0.5,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.07)
                          : Colors.black.withValues(alpha: 0.05),
                      strokeWidth: 0.5,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    axisNameWidget: Text(
                      I18Next.of(context)?.t('chart.tensionLevel') ?? 'Tension',
                      style: theme.textTheme.labelSmall,
                    ),
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 10,
                      getTitlesWidget: (value, meta) {
                        if (value % 20 == 0) {
                          return Text(
                            value.toInt().toString(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    axisNameWidget: Text(
                      I18Next.of(context)?.t('chart.timeOfDay') ?? 'Time',
                      style: theme.textTheme.labelSmall,
                    ),
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 2,
                      getTitlesWidget: (value, meta) {
                        final hour = value.toInt();
                        if (hour >= dayStart.hour &&
                            hour <= dayEnd.hour &&
                            value == value.roundToDouble()) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '${hour.toString().padLeft(2, '0')}:00',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 10,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    left: BorderSide(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    ),
                    bottom: BorderSide(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                // Background zone areas
                rangeAnnotations: RangeAnnotations(
                  horizontalRangeAnnotations: [
                    // Mindfulness Zone (0-30) - green
                    HorizontalRangeAnnotation(
                      y1: AppConstants.mindfulnessMin,
                      y2: AppConstants.mindfulnessMax,
                      color: TensionZone.mindfulness.color.withValues(
                        alpha: 0.08,
                      ),
                    ),
                    // Emotion Regulation Zone (30-70) - orange
                    HorizontalRangeAnnotation(
                      y1: AppConstants.emotionRegulationMin,
                      y2: AppConstants.emotionRegulationMax,
                      color: TensionZone.emotionRegulation.color.withValues(
                        alpha: 0.08,
                      ),
                    ),
                    // Stress Tolerance Zone (70-100) - red
                    HorizontalRangeAnnotation(
                      y1: AppConstants.stressToleranceMin,
                      y2: AppConstants.stressToleranceMax,
                      color: TensionZone.stressTolerance.color.withValues(
                        alpha: 0.08,
                      ),
                    ),
                  ],
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: _buildSpots(),
                    isCurved: true,
                    curveSmoothness: 0.3,
                    preventCurveOverShooting: true,
                    color: theme.colorScheme.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) {
                        final zone = TensionZoneExtension.fromValue(spot.y);
                        return FlDotCirclePainter(
                          radius: 5,
                          color: zone.color,
                          strokeWidth: 2,
                          strokeColor: isDark ? Colors.white : Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          theme.colorScheme.primary.withValues(alpha: 0.15),
                          theme.colorScheme.primary.withValues(alpha: 0.02),
                        ],
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) =>
                        theme.colorScheme.surface.withValues(alpha: 0.95),
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (spots) {
                      return spots.map((spot) {
                        final zone = TensionZoneExtension.fromValue(spot.y);
                        final hour = spot.x.floor();
                        final minute = ((spot.x - hour) * 60).round();
                        final timeStr =
                            '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
                        return LineTooltipItem(
                          '$timeStr\n${spot.y.toInt()}',
                          TextStyle(
                            color: zone.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
    );
  }

  List<FlSpot> _buildSpots() {
    return entries.map((entry) {
      final x = AppDateTimeUtils.timeToDouble(entry.timestamp);
      return FlSpot(x, entry.tensionLevel);
    }).toList()..sort((a, b) => a.x.compareTo(b.x));
  }
}
