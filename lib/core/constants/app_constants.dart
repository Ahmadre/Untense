/// App-wide constants for Untense
class AppConstants {
  AppConstants._();

  // ============== Tension Zones ==============
  /// Mindfulness zone: 0–30
  static const double mindfulnessMin = 0;
  static const double mindfulnessMax = 30;

  /// Emotion regulation zone: 30–70
  static const double emotionRegulationMin = 30;
  static const double emotionRegulationMax = 70;

  /// Stress tolerance zone: 70–100
  static const double stressToleranceMin = 70;
  static const double stressToleranceMax = 100;

  /// First tipping point
  static const double tippingPoint1 = 30;

  /// Second tipping point
  static const double tippingPoint2 = 70;

  /// Minimum tension value
  static const double tensionMin = 0;

  /// Maximum tension value
  static const double tensionMax = 100;

  // ============== Day Defaults ==============
  /// Default day start hour
  static const int defaultDayStartHour = 8;

  /// Default day start minute
  static const int defaultDayStartMinute = 0;

  /// Default day end hour
  static const int defaultDayEndHour = 22;

  /// Default day end minute
  static const int defaultDayEndMinute = 0;

  /// Default entry interval in minutes
  static const int defaultIntervalMinutes = 120; // 2 hours

  /// Minimum allowed interval in minutes
  static const int minIntervalMinutes = 30;

  /// Maximum allowed interval in minutes
  static const int maxIntervalMinutes = 240; // 4 hours

  // ============== Reminder Defaults ==============
  /// Default reminder offset in minutes
  static const int defaultReminderMinutesBefore = 5;

  /// Minimum reminder offset in minutes
  static const int minReminderMinutesBefore = 1;

  /// Maximum reminder offset in minutes
  static const int maxReminderMinutesBefore = 60;

  // ============== Hive Box Names ==============
  static const String tensionEntriesBox = 'tension_entries';
  static const String settingsBox = 'app_settings';

  // ============== Hive Settings Keys ==============
  static const String settingsKeyDayStartHour = 'day_start_hour';
  static const String settingsKeyDayStartMinute = 'day_start_minute';
  static const String settingsKeyDayEndHour = 'day_end_hour';
  static const String settingsKeyDayEndMinute = 'day_end_minute';
  static const String settingsKeyIntervalMinutes = 'interval_minutes';
  static const String settingsKeyReminderEnabled = 'reminder_enabled';
  static const String settingsKeyReminderMinutesBefore =
      'reminder_minutes_before';
  static const String settingsKeyThemeMode = 'theme_mode';
  static const String settingsKeyLocale = 'locale';

  // ============== Hive Type Adapter IDs ==============
  static const int tensionEntryAdapterId = 0;

  // ============== Supported Locales ==============
  static const String localeDe = 'de-DE';
  static const String localeEn = 'en-GB';

  // ============== Notification ==============
  static const String notificationChannelId = 'untense_reminders';
  static const String notificationChannelName = 'Untense Reminders';
  static const String notificationChannelDescription =
      'Reminders to track your tension level';
}
