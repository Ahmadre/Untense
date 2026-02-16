import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:untense/core/constants/app_constants.dart';
import 'notification_platform.dart';

/// Factory for conditional import – returns mobile implementation.
NotificationPlatform createNotificationPlatform() =>
    MobileNotificationPlatform();

/// Mobile (Android / iOS) notification implementation
/// using [flutter_local_notifications].
class MobileNotificationPlatform implements NotificationPlatform {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  @override
  Future<void> initialize() async {
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
  }

  @override
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

    return false;
  }

  @override
  Future<void> scheduleDailyReminders({
    required List<DateTime> timeSlots,
    required int minutesBefore,
    required String title,
    required String body,
  }) async {
    await cancelAllReminders();

    for (int i = 0; i < timeSlots.length; i++) {
      final reminderTime = timeSlots[i].subtract(
        Duration(minutes: minutesBefore),
      );

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

  @override
  Future<void> cancelAllReminders() async {
    await _plugin.cancelAll();
  }
}
