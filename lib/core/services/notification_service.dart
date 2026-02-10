import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:untense/core/constants/app_constants.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

/// Service for handling local push notifications (reminders)
class NotificationService {
  NotificationService._();

  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initializes the notification plugin.
  /// Must be called once at app startup.
  Future<void> initialize() async {
    if (_isInitialized) return;

    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
    _isInitialized = true;
  }

  /// Requests notification permissions on supported platforms
  Future<bool> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      final iosImpl = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final granted = await iosImpl?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final granted = await androidImpl?.requestNotificationsPermission();
      return granted ?? false;
    }

    // Web: notifications not natively supported via this plugin
    return false;
  }

  /// Schedules daily reminders at each time slot minus the offset
  Future<void> scheduleDailyReminders({
    required List<DateTime> timeSlots,
    required int minutesBefore,
    required String title,
    required String body,
  }) async {
    // Cancel all existing reminders first
    await cancelAllReminders();

    for (int i = 0; i < timeSlots.length; i++) {
      final reminderTime = timeSlots[i].subtract(
        Duration(minutes: minutesBefore),
      );

      // Only schedule if the time is in the future
      if (reminderTime.isAfter(DateTime.now())) {
        await _scheduleNotification(
          id: i,
          scheduledTime: reminderTime,
          title: title,
          body: body,
        );
      }
    }
  }

  /// Schedules a single notification
  Future<void> _scheduleNotification({
    required int id,
    required DateTime scheduledTime,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      channelDescription: AppConstants.notificationChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzTime,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancels all scheduled reminders
  Future<void> cancelAllReminders() async {
    await _plugin.cancelAll();
  }
}
