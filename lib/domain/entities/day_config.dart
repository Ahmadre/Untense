import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:untense/core/constants/app_constants.dart';

/// Domain entity representing the user's day configuration
class DayConfig extends Equatable {
  final TimeOfDay dayStart;
  final TimeOfDay dayEnd;
  final int intervalMinutes;
  final bool reminderEnabled;
  final int reminderMinutesBefore;
  final ThemeMode themeMode;
  final String locale;

  const DayConfig({
    this.dayStart = const TimeOfDay(
      hour: AppConstants.defaultDayStartHour,
      minute: AppConstants.defaultDayStartMinute,
    ),
    this.dayEnd = const TimeOfDay(
      hour: AppConstants.defaultDayEndHour,
      minute: AppConstants.defaultDayEndMinute,
    ),
    this.intervalMinutes = AppConstants.defaultIntervalMinutes,
    this.reminderEnabled = false,
    this.reminderMinutesBefore = AppConstants.defaultReminderMinutesBefore,
    this.themeMode = ThemeMode.system,
    this.locale = AppConstants.localeDe,
  });

  DayConfig copyWith({
    TimeOfDay? dayStart,
    TimeOfDay? dayEnd,
    int? intervalMinutes,
    bool? reminderEnabled,
    int? reminderMinutesBefore,
    ThemeMode? themeMode,
    String? locale,
  }) {
    return DayConfig(
      dayStart: dayStart ?? this.dayStart,
      dayEnd: dayEnd ?? this.dayEnd,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderMinutesBefore:
          reminderMinutesBefore ?? this.reminderMinutesBefore,
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }

  @override
  List<Object?> get props => [
    dayStart,
    dayEnd,
    intervalMinutes,
    reminderEnabled,
    reminderMinutesBefore,
    themeMode,
    locale,
  ];
}
