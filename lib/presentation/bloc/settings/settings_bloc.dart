import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untense/domain/repositories/settings_repository.dart';
import 'package:untense/presentation/bloc/settings/settings_event.dart';
import 'package:untense/presentation/bloc/settings/settings_state.dart';

/// BLoC for managing app settings
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _settingsRepository;

  SettingsBloc({required SettingsRepository settingsRepository})
    : _settingsRepository = settingsRepository,
      super(const SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateDayStart>(_onUpdateDayStart);
    on<UpdateDayEnd>(_onUpdateDayEnd);
    on<UpdateInterval>(_onUpdateInterval);
    on<ToggleReminders>(_onToggleReminders);
    on<UpdateReminderMinutesBefore>(_onUpdateReminderMinutesBefore);
    on<UpdateThemeMode>(_onUpdateThemeMode);
    on<UpdateLocale>(_onUpdateLocale);
    on<ResetSettings>(_onResetSettings);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    try {
      final config = await _settingsRepository.loadSettings();
      emit(SettingsLoaded(config));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onUpdateDayStart(
    UpdateDayStart event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      try {
        final currentConfig = (state as SettingsLoaded).config;
        final newConfig = currentConfig.copyWith(dayStart: event.dayStart);
        await _settingsRepository.saveSettings(newConfig);
        emit(SettingsLoaded(newConfig));
      } catch (e) {
        emit(SettingsError(e.toString()));
      }
    }
  }

  Future<void> _onUpdateDayEnd(
    UpdateDayEnd event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      try {
        final currentConfig = (state as SettingsLoaded).config;
        final newConfig = currentConfig.copyWith(dayEnd: event.dayEnd);
        await _settingsRepository.saveSettings(newConfig);
        emit(SettingsLoaded(newConfig));
      } catch (e) {
        emit(SettingsError(e.toString()));
      }
    }
  }

  Future<void> _onUpdateInterval(
    UpdateInterval event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      try {
        final currentConfig = (state as SettingsLoaded).config;
        final newConfig = currentConfig.copyWith(
          intervalMinutes: event.intervalMinutes,
        );
        await _settingsRepository.saveSettings(newConfig);
        emit(SettingsLoaded(newConfig));
      } catch (e) {
        emit(SettingsError(e.toString()));
      }
    }
  }

  Future<void> _onToggleReminders(
    ToggleReminders event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      try {
        final currentConfig = (state as SettingsLoaded).config;
        final newConfig = currentConfig.copyWith(
          reminderEnabled: event.enabled,
        );
        await _settingsRepository.saveSettings(newConfig);
        emit(SettingsLoaded(newConfig));
      } catch (e) {
        emit(SettingsError(e.toString()));
      }
    }
  }

  Future<void> _onUpdateReminderMinutesBefore(
    UpdateReminderMinutesBefore event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      try {
        final currentConfig = (state as SettingsLoaded).config;
        final newConfig = currentConfig.copyWith(
          reminderMinutesBefore: event.minutes,
        );
        await _settingsRepository.saveSettings(newConfig);
        emit(SettingsLoaded(newConfig));
      } catch (e) {
        emit(SettingsError(e.toString()));
      }
    }
  }

  Future<void> _onUpdateThemeMode(
    UpdateThemeMode event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      try {
        final currentConfig = (state as SettingsLoaded).config;
        final newConfig = currentConfig.copyWith(themeMode: event.themeMode);
        await _settingsRepository.saveSettings(newConfig);
        emit(SettingsLoaded(newConfig));
      } catch (e) {
        emit(SettingsError(e.toString()));
      }
    }
  }

  Future<void> _onUpdateLocale(
    UpdateLocale event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      try {
        final currentConfig = (state as SettingsLoaded).config;
        final newConfig = currentConfig.copyWith(locale: event.locale);
        await _settingsRepository.saveSettings(newConfig);
        emit(SettingsLoaded(newConfig));
      } catch (e) {
        emit(SettingsError(e.toString()));
      }
    }
  }

  Future<void> _onResetSettings(
    ResetSettings event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _settingsRepository.resetSettings();
      final config = await _settingsRepository.loadSettings();
      emit(SettingsLoaded(config));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }
}
