import 'package:untense/domain/entities/day_config.dart';

/// Abstract repository for app settings.
/// Follows the Dependency Inversion Principle (DIP).
abstract class SettingsRepository {
  /// Loads the current settings
  Future<DayConfig> loadSettings();

  /// Saves settings to persistent storage
  Future<void> saveSettings(DayConfig config);

  /// Resets all settings to defaults
  Future<void> resetSettings();
}
