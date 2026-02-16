/// Abstract interface for platform-specific notification implementations.
///
/// Each platform (mobile, web, stub) provides its own implementation
/// via conditional imports in [NotificationService].
abstract class NotificationPlatform {
  /// Initialize the notification subsystem for this platform.
  Future<void> initialize();

  /// Request notification permissions from the user.
  /// Returns `true` if permission was granted.
  Future<bool> requestPermissions();

  /// Schedule notifications for each time slot minus [minutesBefore].
  /// Cancels any previously scheduled reminders first.
  Future<void> scheduleDailyReminders({
    required List<DateTime> timeSlots,
    required int minutesBefore,
    required String title,
    required String body,
  });

  /// Cancel all previously scheduled reminders.
  Future<void> cancelAllReminders();
}
