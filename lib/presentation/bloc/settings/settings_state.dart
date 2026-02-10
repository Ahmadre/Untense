import 'package:equatable/equatable.dart';
import 'package:untense/domain/entities/day_config.dart';

/// States for the SettingsBloc
abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

/// State while loading settings
class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

/// State when settings are loaded
class SettingsLoaded extends SettingsState {
  final DayConfig config;

  const SettingsLoaded(this.config);

  @override
  List<Object?> get props => [config];
}

/// State when an error occurred
class SettingsError extends SettingsState {
  final String message;

  const SettingsError(this.message);

  @override
  List<Object?> get props => [message];
}
