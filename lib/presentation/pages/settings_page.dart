import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i18next/i18next.dart';
import 'package:untense/core/constants/app_constants.dart';
import 'package:untense/core/utils/date_time_utils.dart';
import 'package:untense/presentation/bloc/settings/settings_bloc.dart';
import 'package:untense/presentation/bloc/settings/settings_event.dart';
import 'package:untense/presentation/bloc/settings/settings_state.dart';
import 'package:untense/presentation/bloc/tension/tension_bloc.dart';
import 'package:untense/presentation/bloc/tension/tension_event.dart';

/// Settings page for customizing the app
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final i18n = I18Next.of(context);

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        if (state is SettingsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is! SettingsLoaded) {
          return const SizedBox.shrink();
        }

        final config = state.config;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ===== Day Settings =====
            _SectionHeader(
              title: i18n?.t('settings.daySettings') ?? 'Day Settings',
              icon: Icons.schedule,
            ),
            Card(
              child: Column(
                children: [
                  // Day Start
                  ListTile(
                    leading: const Icon(Icons.wb_sunny_outlined),
                    title: Text(i18n?.t('settings.dayStart') ?? 'Day Start'),
                    trailing: Text(
                      AppDateTimeUtils.formatTimeOfDay(config.dayStart),
                      style: theme.textTheme.titleMedium,
                    ),
                    onTap: () => _pickDayStart(context, config.dayStart),
                  ),
                  const Divider(height: 1),
                  // Day End
                  ListTile(
                    leading: const Icon(Icons.nightlight_outlined),
                    title: Text(i18n?.t('settings.dayEnd') ?? 'Day End'),
                    trailing: Text(
                      AppDateTimeUtils.formatTimeOfDay(config.dayEnd),
                      style: theme.textTheme.titleMedium,
                    ),
                    onTap: () => _pickDayEnd(context, config.dayEnd),
                  ),
                  const Divider(height: 1),
                  // Interval
                  ListTile(
                    leading: const Icon(Icons.timelapse),
                    title: Text(
                      i18n?.t('settings.interval') ?? 'Entry Interval',
                    ),
                    trailing: DropdownButton<int>(
                      value: config.intervalMinutes,
                      underline: const SizedBox.shrink(),
                      items: _buildIntervalItems(i18n),
                      onChanged: (value) {
                        if (value != null) {
                          context.read<SettingsBloc>().add(
                            UpdateInterval(value),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ===== Notifications =====
            _SectionHeader(
              title: i18n?.t('settings.notifications') ?? 'Notifications',
              icon: Icons.notifications_outlined,
            ),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.alarm),
                    title: Text(
                      i18n?.t('settings.enableReminders') ?? 'Enable Reminders',
                    ),
                    value: config.reminderEnabled,
                    onChanged: (value) {
                      context.read<SettingsBloc>().add(ToggleReminders(value));
                    },
                  ),
                  if (config.reminderEnabled) ...[
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.timer_outlined),
                      title: Text(
                        i18n?.t('settings.reminderBefore') ?? 'Remind Before',
                      ),
                      trailing: DropdownButton<int>(
                        value: config.reminderMinutesBefore,
                        underline: const SizedBox.shrink(),
                        items: _buildReminderItems(i18n),
                        onChanged: (value) {
                          if (value != null) {
                            context.read<SettingsBloc>().add(
                              UpdateReminderMinutesBefore(value),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ===== Appearance =====
            _SectionHeader(
              title: i18n?.t('settings.appearance') ?? 'Appearance',
              icon: Icons.palette_outlined,
            ),
            Card(
              child: Column(
                children: [
                  // Theme
                  ListTile(
                    leading: const Icon(Icons.brightness_6),
                    title: Text(i18n?.t('settings.theme') ?? 'Theme'),
                    trailing: DropdownButton<ThemeMode>(
                      value: config.themeMode,
                      underline: const SizedBox.shrink(),
                      items: [
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Text(
                            i18n?.t('settings.themeSystem') ?? 'System',
                          ),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text(
                            i18n?.t('settings.themeLight') ?? 'Light',
                          ),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text(i18n?.t('settings.themeDark') ?? 'Dark'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          context.read<SettingsBloc>().add(
                            UpdateThemeMode(value),
                          );
                        }
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  // Language
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: Text(i18n?.t('settings.language') ?? 'Language'),
                    trailing: DropdownButton<String>(
                      value: config.locale,
                      underline: const SizedBox.shrink(),
                      items: [
                        DropdownMenuItem(
                          value: AppConstants.localeDe,
                          child: Text(
                            i18n?.t('settings.languageDe') ?? 'German',
                          ),
                        ),
                        DropdownMenuItem(
                          value: AppConstants.localeEn,
                          child: Text(
                            i18n?.t('settings.languageEn') ?? 'English',
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          context.read<SettingsBloc>().add(UpdateLocale(value));
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ===== Data =====
            _SectionHeader(
              title: i18n?.t('settings.data') ?? 'Data',
              icon: Icons.storage_outlined,
            ),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.delete_forever,
                      color: theme.colorScheme.error,
                    ),
                    title: Text(
                      i18n?.t('settings.deleteAllData') ?? 'Delete All Data',
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                    onTap: () => _confirmDeleteAll(context, i18n),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ===== About =====
            _SectionHeader(
              title: i18n?.t('settings.about') ?? 'About Untense',
              icon: Icons.info_outline,
            ),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.security),
                    title: Text(
                      i18n?.t('settings.privacyNote') ??
                          'All data is stored locally on your device.',
                    ),
                    subtitle: Text(
                      i18n?.t(
                            'settings.version',
                            variables: {'version': '0.1.0'},
                          ) ??
                          'Version 0.1.0',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        );
      },
    );
  }

  List<DropdownMenuItem<int>> _buildIntervalItems(I18Next? i18n) {
    final intervals = [30, 60, 90, 120, 180, 240];
    return intervals.map((minutes) {
      String label;
      if (minutes < 60) {
        label =
            i18n?.t(
              'settings.intervalMinutes_other',
              variables: {'count': minutes.toString()},
            ) ??
            '$minutes min';
      } else if (minutes == 60) {
        label = i18n?.t('settings.intervalHours_one') ?? '1 hour';
      } else {
        final hours = minutes ~/ 60;
        final remaining = minutes % 60;
        label =
            i18n?.t(
              'settings.intervalHours_other',
              variables: {'count': hours.toString()},
            ) ??
            '$hours hours';
        if (remaining > 0) {
          label += ' ${remaining}min';
        }
      }
      return DropdownMenuItem(value: minutes, child: Text(label));
    }).toList();
  }

  List<DropdownMenuItem<int>> _buildReminderItems(I18Next? i18n) {
    final values = [1, 2, 5, 10, 15, 30, 60];
    return values.map((minutes) {
      String label;
      if (minutes == 60) {
        label = i18n?.t('settings.reminderBeforeHour') ?? '1 hour before';
      } else {
        label =
            i18n?.t(
              'settings.reminderBeforeMinutes',
              variables: {'count': minutes.toString()},
            ) ??
            '$minutes min before';
      }
      return DropdownMenuItem(value: minutes, child: Text(label));
    }).toList();
  }

  Future<void> _pickDayStart(BuildContext context, TimeOfDay current) async {
    final picked = await showTimePicker(context: context, initialTime: current);
    if (picked != null && context.mounted) {
      context.read<SettingsBloc>().add(UpdateDayStart(picked));
    }
  }

  Future<void> _pickDayEnd(BuildContext context, TimeOfDay current) async {
    final picked = await showTimePicker(context: context, initialTime: current);
    if (picked != null && context.mounted) {
      context.read<SettingsBloc>().add(UpdateDayEnd(picked));
    }
  }

  void _confirmDeleteAll(BuildContext context, I18Next? i18n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          i18n?.t('settings.deleteAllConfirmTitle') ?? 'Delete All Data',
        ),
        content: Text(
          i18n?.t('settings.deleteAllConfirm') ??
              'Do you really want to delete all data?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(i18n?.t('common.cancel') ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<TensionBloc>().add(const DeleteAllEntries());
            },
            child: Text(
              i18n?.t('common.delete') ?? 'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
