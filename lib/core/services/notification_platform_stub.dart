import 'notification_platform.dart';

/// Stub factory – used as fallback on unsupported platforms.
NotificationPlatform createNotificationPlatform() =>
    _StubNotificationPlatform();

/// No-op stub for platforms that are neither mobile nor web.
class _StubNotificationPlatform implements NotificationPlatform {
  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermissions() async => false;

  @override
  Future<void> scheduleDailyReminders({
    required List<DateTime> timeSlots,
    required int minutesBefore,
    required String title,
    required String body,
  }) async {}

  @override
  Future<void> cancelAllReminders() async {}
}
