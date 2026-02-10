import 'package:flutter/material.dart';
import 'package:untense/core/constants/app_constants.dart';
import 'package:untense/core/constants/tension_zones.dart';

/// A custom slider for selecting tension level (0–100)
/// with visual zone indicators and haptic feedback.
class TensionSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const TensionSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final zone = TensionZoneExtension.fromValue(value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Value display
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: zone.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: zone.color.withValues(alpha: 0.3)),
            ),
            child: Text(
              value.toInt().toString(),
              style: theme.textTheme.headlineLarge?.copyWith(
                color: zone.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Zone indicator bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 8,
            child: Row(
              children: [
                Expanded(
                  flex: 30,
                  child: Container(
                    color: TensionZone.mindfulness.color.withValues(alpha: 0.6),
                  ),
                ),
                Expanded(
                  flex: 40,
                  child: Container(
                    color: TensionZone.emotionRegulation.color.withValues(
                      alpha: 0.6,
                    ),
                  ),
                ),
                Expanded(
                  flex: 30,
                  child: Container(
                    color: TensionZone.stressTolerance.color.withValues(
                      alpha: 0.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),

        // Slider
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: zone.color,
            inactiveTrackColor: zone.color.withValues(alpha: 0.2),
            thumbColor: zone.color,
            overlayColor: zone.color.withValues(alpha: 0.1),
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 14,
              elevation: 4,
            ),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
          ),
          child: Slider(
            value: value,
            min: AppConstants.tensionMin,
            max: AppConstants.tensionMax,
            divisions: 100,
            onChanged: onChanged,
          ),
        ),

        // Zone labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              Text(
                '30',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              Text(
                '70',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              Text(
                '100',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
