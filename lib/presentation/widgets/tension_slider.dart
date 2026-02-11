import 'package:flutter/material.dart';
import 'package:untense/core/constants/app_constants.dart';
import 'package:untense/core/constants/tension_zones.dart';

/// A custom slider for selecting tension level (0–100).
///
/// The track permanently shows all three zone colours (green → orange → red).
/// Only the **thumb** and the **value display** change colour depending on
/// the active zone.
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

        // Slider with zone-coloured track
        SliderTheme(
          data: SliderThemeData(
            trackShape: _ZoneTrackShape(),
            trackHeight: 8,
            thumbColor: zone.color,
            overlayColor: zone.color.withValues(alpha: 0.1),
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 14,
              elevation: 4,
            ),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
            // Not used visually — overridden by custom track — but required.
            activeTrackColor: Colors.transparent,
            inactiveTrackColor: Colors.transparent,
          ),
          child: Slider(
            value: value,
            min: AppConstants.tensionMin,
            max: AppConstants.tensionMax,
            divisions: 100,
            onChanged: onChanged,
          ),
        ),

        // Zone labels — positioned to match the track boundaries
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14), // thumb radius
          child: LayoutBuilder(
            builder: (context, constraints) {
              final trackWidth = constraints.maxWidth;
              Widget label(String text, double fraction) {
                return Positioned(
                  left: fraction * trackWidth,
                  child: FractionalTranslation(
                    translation: const Offset(-0.5, 0),
                    child: Text(
                      text,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ),
                );
              }

              return SizedBox(
                height: 16,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    label('0', 0),
                    label('30', 0.30),
                    label('70', 0.70),
                    label('100', 1.0),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Custom track that always paints the three zone colours.
// ═══════════════════════════════════════════════════════════════

class _ZoneTrackShape extends SliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight ?? 8;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final trackLeft = offset.dx + 14; // thumb radius
    final trackWidth = parentBox.size.width - 28; // 2 × thumb radius
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isEnabled = false,
    bool isDiscrete = false,
    required TextDirection textDirection,
  }) {
    final rect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
    );

    final radius = Radius.circular(rect.height / 2);
    final totalWidth = rect.width;

    // Zone proportions: 0-30 (30%), 30-70 (40%), 70-100 (30%)
    final zone1Width = totalWidth * 0.30;
    final zone2Width = totalWidth * 0.40;

    final canvas = context.canvas;

    // ── Zone 1: Mindfulness (green) ──
    final zone1Rect = Rect.fromLTWH(
      rect.left,
      rect.top,
      zone1Width,
      rect.height,
    );
    canvas.drawRRect(
      RRect.fromRectAndCorners(zone1Rect, topLeft: radius, bottomLeft: radius),
      Paint()..color = TensionZone.mindfulness.color.withValues(alpha: 0.7),
    );

    // ── Zone 2: Emotion Regulation (orange) ──
    final zone2Rect = Rect.fromLTWH(
      rect.left + zone1Width,
      rect.top,
      zone2Width,
      rect.height,
    );
    canvas.drawRect(
      zone2Rect,
      Paint()
        ..color = TensionZone.emotionRegulation.color.withValues(alpha: 0.7),
    );

    // ── Zone 3: Stress Tolerance (red) ──
    final zone3Rect = Rect.fromLTWH(
      rect.left + zone1Width + zone2Width,
      rect.top,
      totalWidth - zone1Width - zone2Width,
      rect.height,
    );
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        zone3Rect,
        topRight: radius,
        bottomRight: radius,
      ),
      Paint()..color = TensionZone.stressTolerance.color.withValues(alpha: 0.7),
    );
  }
}
