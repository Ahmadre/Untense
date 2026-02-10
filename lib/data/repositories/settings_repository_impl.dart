import 'package:flutter/material.dart';
import 'package:untense/core/constants/app_constants.dart';
import 'package:untense/data/datasources/hive_datasource.dart';
import 'package:untense/domain/entities/day_config.dart';
import 'package:untense/domain/repositories/settings_repository.dart';

/// Concrete implementation of [SettingsRepository] using Hive
class SettingsRepositoryImpl implements SettingsRepository {
  final HiveDataSource _dataSource;

  SettingsRepositoryImpl({required HiveDataSource dataSource})
    : _dataSource = dataSource;

  @override
  Future<DayConfig> loadSettings() async {
    final box = _dataSource.settingsBox;

    return DayConfig(
      dayStart: TimeOfDay(
        hour: box.get(
          AppConstants.settingsKeyDayStartHour,
          defaultValue: AppConstants.defaultDayStartHour,
        ),
        minute: box.get(
          AppConstants.settingsKeyDayStartMinute,
          defaultValue: AppConstants.defaultDayStartMinute,
        ),
      ),
      dayEnd: TimeOfDay(
        hour: box.get(
          AppConstants.settingsKeyDayEndHour,
          defaultValue: AppConstants.defaultDayEndHour,
        ),
        minute: box.get(
          AppConstants.settingsKeyDayEndMinute,
          defaultValue: AppConstants.defaultDayEndMinute,
        ),
      ),
      intervalMinutes: box.get(
        AppConstants.settingsKeyIntervalMinutes,
        defaultValue: AppConstants.defaultIntervalMinutes,
      ),
      reminderEnabled: box.get(
        AppConstants.settingsKeyReminderEnabled,
        defaultValue: false,
      ),
      reminderMinutesBefore: box.get(
        AppConstants.settingsKeyReminderMinutesBefore,
        defaultValue: AppConstants.defaultReminderMinutesBefore,
      ),
      themeMode: _parseThemeMode(
        box.get(AppConstants.settingsKeyThemeMode, defaultValue: 'system'),
      ),
      locale: box.get(
        AppConstants.settingsKeyLocale,
        defaultValue: AppConstants.localeDe,
      ),
    );
  }

  @override
  Future<void> saveSettings(DayConfig config) async {
    final box = _dataSource.settingsBox;
    await box.put(AppConstants.settingsKeyDayStartHour, config.dayStart.hour);
    await box.put(
      AppConstants.settingsKeyDayStartMinute,
      config.dayStart.minute,
    );
    await box.put(AppConstants.settingsKeyDayEndHour, config.dayEnd.hour);
    await box.put(AppConstants.settingsKeyDayEndMinute, config.dayEnd.minute);
    await box.put(
      AppConstants.settingsKeyIntervalMinutes,
      config.intervalMinutes,
    );
    await box.put(
      AppConstants.settingsKeyReminderEnabled,
      config.reminderEnabled,
    );
    await box.put(
      AppConstants.settingsKeyReminderMinutesBefore,
      config.reminderMinutesBefore,
    );
    await box.put(
      AppConstants.settingsKeyThemeMode,
      _themeModeToString(config.themeMode),
    );
    await box.put(AppConstants.settingsKeyLocale, config.locale);
  }

  @override
  Future<void> resetSettings() async {
    await _dataSource.settingsBox.clear();
  }

  ThemeMode _parseThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
