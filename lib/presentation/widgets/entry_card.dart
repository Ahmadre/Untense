import 'package:flutter/material.dart';
import 'package:i18next/i18next.dart';
import 'package:untense/core/constants/tension_zones.dart';
import 'package:untense/core/utils/date_time_utils.dart';
import 'package:untense/domain/entities/tension_entry.dart';

/// Card widget displaying a single tension entry summary
class EntryCard extends StatelessWidget {
  final TensionEntry entry;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const EntryCard({
    super.key,
    required this.entry,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final zone = TensionZoneExtension.fromValue(entry.tensionLevel);
    final i18n = I18Next.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Time
              Column(
                children: [
                  Text(
                    AppDateTimeUtils.formatTime(entry.timestamp),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),

              // Tension indicator
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: zone.color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: zone.color, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  entry.tensionLevel.toInt().toString(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: zone.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      i18n?.t(zone.nameKey) ?? zone.name,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: zone.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (entry.situation != null &&
                        entry.situation!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        entry.situation!,
                        style: theme.textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (entry.emotions.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        runSpacing: 2,
                        children: entry.emotions.take(3).map((emotion) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: zone.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              i18n?.t('emotions.$emotion') ?? emotion,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: zone.color,
                                fontSize: 10,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),

              // Arrow
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
