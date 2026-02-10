import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Events for the SettingsBloc
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Load settings from storage
class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

/// Update the day start time
class UpdateDayStart extends SettingsEvent {
  final TimeOfDay dayStart;

  const UpdateDayStart(this.dayStart);

  @override
  List<Object?> get props => [dayStart];
}

/// Update the day end time
class UpdateDayEnd extends SettingsEvent {
  final TimeOfDay dayEnd;

  const UpdateDayEnd(this.dayEnd);

  @override
  List<Object?> get props => [dayEnd];
}

/// Update the entry interval in minutes
class UpdateInterval extends SettingsEvent {
  final int intervalMinutes;

  const UpdateInterval(this.intervalMinutes);

  @override
  List<Object?> get props => [intervalMinutes];
}

/// Toggle reminders on/off
class ToggleReminders extends SettingsEvent {
  final bool enabled;

  const ToggleReminders(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

/// Update reminder offset in minutes
class UpdateReminderMinutesBefore extends SettingsEvent {
  final int minutes;

  const UpdateReminderMinutesBefore(this.minutes);

  @override
  List<Object?> get props => [minutes];
}

/// Update the theme mode
class UpdateThemeMode extends SettingsEvent {
  final ThemeMode themeMode;

  const UpdateThemeMode(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

/// Update the locale
class UpdateLocale extends SettingsEvent {
  final String locale;

  const UpdateLocale(this.locale);

  @override
  List<Object?> get props => [locale];
}

/// Reset all settings to defaults
class ResetSettings extends SettingsEvent {
  const ResetSettings();
}
