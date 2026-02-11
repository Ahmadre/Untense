import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:i18next/i18next.dart';
import 'package:untense/core/routing/route_paths.dart';
import 'package:untense/core/utils/date_time_utils.dart';
import 'package:untense/presentation/bloc/settings/settings_bloc.dart';
import 'package:untense/presentation/bloc/settings/settings_state.dart';
import 'package:untense/presentation/bloc/tension/tension_bloc.dart';
import 'package:untense/presentation/bloc/tension/tension_event.dart';
import 'package:untense/presentation/bloc/tension/tension_state.dart';
import 'package:untense/presentation/widgets/entry_card.dart';
import 'package:untense/presentation/widgets/tension_chart.dart';
import 'package:untense/presentation/widgets/untense_logo_widget.dart';
import 'package:untense/presentation/widgets/zone_indicator.dart';

/// Home page showing today's tension entries and chart
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final i18n = I18Next.of(context);

    return BlocBuilder<TensionBloc, TensionState>(
      builder: (context, state) {
        if (state is TensionLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is TensionError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(state.message, style: theme.textTheme.bodyMedium),
              ],
            ),
          );
        }

        if (state is TensionLoaded) {
          return _buildContent(context, state, theme, i18n);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    TensionLoaded state,
    ThemeData theme,
    I18Next? i18n,
  ) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final settingsState = context.watch<SettingsBloc>().state;
    final dayStart = settingsState is SettingsLoaded
        ? settingsState.config.dayStart
        : const TimeOfDay(hour: 8, minute: 0);
    final dayEnd = settingsState is SettingsLoaded
        ? settingsState.config.dayEnd
        : const TimeOfDay(hour: 22, minute: 0);

    return RefreshIndicator(
      onRefresh: () async {
        context.read<TensionBloc>().add(const LoadTodayEntries());
      },
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          i18n?.t('home.greeting') ?? 'How are you?',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppDateTimeUtils.formatDate(state.selectedDate),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const UntenseLogoWidget(size: 48, borderRadius: 12),
                ],
              ),
            ),
          ),

          // Chart toggle
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    i18n?.t('chart.title') ?? 'Tension Curve',
                    style: theme.textTheme.titleMedium,
                  ),
                  TextButton.icon(
                    onPressed: () {
                      context.read<TensionBloc>().add(
                        const ToggleChartVisibility(),
                      );
                    },
                    icon: Icon(
                      state.isChartVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      size: 18,
                    ),
                    label: Text(
                      state.isChartVisible
                          ? (i18n?.t('home.hideChart') ?? 'Hide')
                          : (i18n?.t('home.showChart') ?? 'Show'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Chart
          if (state.isChartVisible)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TensionChart(
                  entries: state.entries,
                  dayStart: dayStart,
                  dayEnd: dayEnd,
                ),
              ),
            ),

          // Zone indicator for latest entry
          if (state.entries.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ZoneIndicator(
                  tensionLevel: state.entries.last.tensionLevel,
                ),
              ),
            ),

          // Statistics
          if (state.entries.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    _StatCard(
                      label: 'Ø ${i18n?.t('chart.tensionLevel') ?? 'Avg'}',
                      value: state.averageTension.toStringAsFixed(0),
                      theme: theme,
                    ),
                    const SizedBox(width: 8),
                    _StatCard(
                      icon: Icons.arrow_upward_rounded,
                      label: 'Max',
                      value: state.maxTension.toStringAsFixed(0),
                      theme: theme,
                    ),
                    const SizedBox(width: 8),
                    _StatCard(
                      value: state.minTension.toStringAsFixed(0),
                      theme: theme,
                      icon: Icons.arrow_downward_rounded,
                      label: 'Min',
                    ),
                  ],
                ),
              ),
            ),

          // Section header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                i18n?.t('home.title') ?? 'Today',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Entries list
          if (state.entries.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.edit_note,
                        size: 64,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        i18n?.t('home.noEntries') ??
                            'No entries for today yet.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final entry = state.entries[index];
                return EntryCard(
                  entry: entry,
                  onTap: () => _navigateToEditEntry(context, entry.id),
                );
              }, childCount: state.entries.length),
            ),

          // Bottom padding
          SliverToBoxAdapter(child: SizedBox(height: bottomInset + 80)),
        ],
      ),
    );
  }

  void _navigateToEditEntry(BuildContext context, String entryId) {
    context.push(RoutePaths.editEntryPath(entryId));
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;
  final IconData? icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.theme,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final subtleColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 12, color: subtleColor),
                  const SizedBox(width: 3),
                ],
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: subtleColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
