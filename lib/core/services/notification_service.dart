import 'notification_platform.dart';
import 'notification_platform_stub.dart'
    if (dart.library.io) 'notification_platform_io.dart'
    if (dart.library.html) 'notification_platform_web.dart';

/// Unified notification service for all platforms.
///
/// Delegates to the platform-specific [NotificationPlatform] implementation
/// selected at compile time via conditional imports:
/// * **Mobile** (Android / iOS): `flutter_local_notifications`
/// * **Web**: Browser Notification API with [Timer]-based scheduling
/// * **Other**: No-op stub
class NotificationService {
  NotificationService._();

  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;

  final NotificationPlatform _platform = createNotificationPlatform();

  bool _isInitialized = false;

  /// Initializes the notification subsystem.
  /// Must be called once at app startup.
  Future<void> initialize() async {
    if (_isInitialized) return;
    await _platform.initialize();
    _isInitialized = true;
  }

  /// Requests notification permissions on the current platform.
  /// Returns `true` if permission was granted.
  Future<bool> requestPermissions() => _platform.requestPermissions();

  /// Schedules daily reminders at each time slot minus [minutesBefore].
  Future<void> scheduleDailyReminders({
    required List<DateTime> timeSlots,
    required int minutesBefore,
    required String title,
    required String body,
  }) => _platform.scheduleDailyReminders(
    timeSlots: timeSlots,
    minutesBefore: minutesBefore,
    title: title,
    body: body,
  );

  /// Cancels all scheduled reminders.
  Future<void> cancelAllReminders() => _platform.cancelAllReminders();
}
