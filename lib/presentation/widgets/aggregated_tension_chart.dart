import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:i18next/i18next.dart';
import 'package:untense/core/constants/app_constants.dart';
import 'package:untense/core/constants/history_view_mode.dart';
import 'package:untense/core/constants/tension_zones.dart';
import 'package:untense/presentation/widgets/tension_chart.dart'
    show responsiveChartHeight;

/// A data point representing the average tension for a time bucket
/// (a day in week/month view, or a month in year view).
class AggregatedDataPoint {
  /// Position on the X-axis (0-based index)
  final double x;

  /// Average tension level for this bucket
  final double avgTension;

  /// Label for the X-axis (e.g. "Mo", "1", "Jan")
  final String label;

  /// Number of entries that contributed to this average
  final int entryCount;

  const AggregatedDataPoint({
    required this.x,
    required this.avgTension,
    required this.label,
    required this.entryCount,
  });
}

/// A line chart that shows aggregated tension data for week, month, or year.
///
/// Supports horizontal scrolling for mobile-first readability.
class AggregatedTensionChart extends StatelessWidget {
  /// The aggregated data points to display
  final List<AggregatedDataPoint> dataPoints;

  /// The current view mode (week, month, or year)
  final HistoryViewMode viewMode;

  const AggregatedTensionChart({
    super.key,
    required this.dataPoints,
    required this.viewMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final i18n = I18Next.of(context);

    final pointsWithData = dataPoints.where((p) => p.entryCount > 0).toList();

    final chartHeight = responsiveChartHeight(context);

    if (pointsWithData.isEmpty) {
      return Container(
        height: chartHeight,
        padding: const EdgeInsets.all(16),
        decoration: _boxDecoration(theme),
        child: Center(
          child: Text(
            i18n?.t('history.noDataForPeriod') ?? 'No data for this period.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
      );
    }

    // Determine chart width: ensure a minimum width per data point
    // so the chart is scrollable on mobile
    final double minPointWidth = viewMode == HistoryViewMode.year ? 56 : 48;
    final double totalPoints = dataPoints.length.toDouble();
    final double minimumChartWidth = totalPoints * minPointWidth;

    return Container(
      height: chartHeight + 20,
      decoration: _boxDecoration(theme),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double chartWidth = minimumChartWidth > constraints.maxWidth
                ? minimumChartWidth
                : constraints.maxWidth;

            final chartChild = SizedBox(
              width: chartWidth,
              height: chartHeight,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 16,
                  top: 16,
                  bottom: 8,
                  left: 4,
                ),
                child: LineChart(
                  LineChartData(
                    minX: -0.5,
                    maxX: totalPoints - 0.5,
                    minY: AppConstants.tensionMin,
                    maxY: AppConstants.tensionMax,
                    clipData: const FlClipData.all(),
                    gridData: _gridData(isDark),
                    titlesData: _titlesData(theme),
                    borderData: _borderData(theme),
                    rangeAnnotations: _zoneAnnotations(),
                    lineBarsData: [_lineBarData(theme, isDark)],
                    lineTouchData: _touchData(theme),
                  ),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
              ),
            );

            if (chartWidth > constraints.maxWidth) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: chartChild,
              );
            }
            return chartChild;
          },
        ),
      ),
    );
  }

  BoxDecoration _boxDecoration(ThemeData theme) {
    return BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  FlGridData _gridData(bool isDark) {
    return FlGridData(
      show: true,
      drawVerticalLine: true,
      horizontalInterval: 10,
      verticalInterval: 1,
      getDrawingHorizontalLine: (value) {
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
    );
  }

  FlTitlesData _titlesData(ThemeData theme) {
    return FlTitlesData(
      leftTitles: AxisTitles(
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
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 28,
          interval: 1,
          getTitlesWidget: (value, meta) {
            final index = value.round();
            // Only show labels at exact integer positions to avoid
            // duplicate labels at boundary ticks (-0.5, 11.5, etc.)
            if ((value - index).abs() > 0.01 ||
                index < 0 ||
                index >= dataPoints.length) {
              return const SizedBox.shrink();
            }
            // For month view with many days, show every other label
            if (viewMode == HistoryViewMode.month && dataPoints.length > 15) {
              if (index % 2 != 0 && index != dataPoints.length - 1) {
                return const SizedBox.shrink();
              }
            }
            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                dataPoints[index].label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            );
          },
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  FlBorderData _borderData(ThemeData theme) {
    return FlBorderData(
      show: true,
      border: Border(
        left: BorderSide(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
        ),
        bottom: BorderSide(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
        ),
      ),
    );
  }

  RangeAnnotations _zoneAnnotations() {
    return RangeAnnotations(
      horizontalRangeAnnotations: [
        HorizontalRangeAnnotation(
          y1: AppConstants.mindfulnessMin,
          y2: AppConstants.mindfulnessMax,
          color: TensionZone.mindfulness.color.withValues(alpha: 0.08),
        ),
        HorizontalRangeAnnotation(
          y1: AppConstants.emotionRegulationMin,
          y2: AppConstants.emotionRegulationMax,
          color: TensionZone.emotionRegulation.color.withValues(alpha: 0.08),
        ),
        HorizontalRangeAnnotation(
          y1: AppConstants.stressToleranceMin,
          y2: AppConstants.stressToleranceMax,
          color: TensionZone.stressTolerance.color.withValues(alpha: 0.08),
        ),
      ],
    );
  }

  LineChartBarData _lineBarData(ThemeData theme, bool isDark) {
    // Only include points that have data
    final spots =
        dataPoints
            .where((p) => p.entryCount > 0)
            .map((p) => FlSpot(p.x, p.avgTension))
            .toList()
          ..sort((a, b) => a.x.compareTo(b.x));

    return LineChartBarData(
      spots: spots,
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
            strokeColor: Colors.white,
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
    );
  }

  LineTouchData _touchData(ThemeData theme) {
    return LineTouchData(
      enabled: true,
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (_) =>
            theme.colorScheme.surface.withValues(alpha: 0.95),
        tooltipRoundedRadius: 8,
        getTooltipItems: (spots) {
          return spots.map((spot) {
            final zone = TensionZoneExtension.fromValue(spot.y);
            final index = spot.x.toInt();
            final label = (index >= 0 && index < dataPoints.length)
                ? dataPoints[index].label
                : '';
            final count = (index >= 0 && index < dataPoints.length)
                ? dataPoints[index].entryCount
                : 0;
            return LineTooltipItem(
              '$label\n⌀ ${spot.y.toStringAsFixed(1)} ($count)',
              TextStyle(
                color: zone.color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            );
          }).toList();
        },
      ),
    );
  }
}
