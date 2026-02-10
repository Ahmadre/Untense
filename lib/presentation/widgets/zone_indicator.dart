import 'package:flutter/material.dart';
import 'package:i18next/i18next.dart';
import 'package:untense/core/constants/tension_zones.dart';

/// Displays the current tension zone with color and description
class ZoneIndicator extends StatelessWidget {
  final double tensionLevel;
  final bool showDescription;

  const ZoneIndicator({
    super.key,
    required this.tensionLevel,
    this.showDescription = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final zone = TensionZoneExtension.fromValue(tensionLevel);
    final i18n = I18Next.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: zone.lightColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: zone.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: zone.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  i18n?.t(zone.nameKey) ?? zone.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: zone.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (showDescription) ...[
                  const SizedBox(height: 4),
                  Text(
                    i18n?.t(zone.descriptionKey) ?? '',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: zone.color.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
