import 'dart:async';
import 'dart:js_interop';

import 'notification_platform.dart';

// ---------------------------------------------------------------------------
// JS bindings for the browser Notification API
// ---------------------------------------------------------------------------

/// Binding for the global `Notification` constructor and its static members.
@JS('Notification')
extension type _JSNotification._(JSObject _) implements JSObject {
  /// `new Notification(title, options?)` – shows a notification immediately.
  external _JSNotification(String title, [_NotificationOptions? options]);

  /// `Notification.permission` – "granted" | "denied" | "default".
  external static String get permission;

  /// `Notification.requestPermission()` – returns a Promise resolving
  /// to `"granted"`, `"denied"`, or `"default"`.
  external static JSPromise<JSString> requestPermission();
}

/// Plain JS object matching the `NotificationOptions` Web-IDL dictionary.
extension type _NotificationOptions._(JSObject _) implements JSObject {
  external factory _NotificationOptions({String? body, String? icon});
}

// ---------------------------------------------------------------------------
// Web implementation
// ---------------------------------------------------------------------------

/// Factory for conditional import – returns web implementation.
NotificationPlatform createNotificationPlatform() => WebNotificationPlatform();

/// Web notification implementation using the browser
/// [Notification API](https://developer.mozilla.org/en-US/docs/Web/API/Notification).
///
/// **Limitations compared to mobile:**
/// * Scheduled reminders use Dart [Timer]s and therefore only fire while the
///   PWA tab / window is open. True background push requires a push server
///   and the Push API – this can be added later without changing this
///   interface.
/// * The user must grant the browser notification permission.
class WebNotificationPlatform implements NotificationPlatform {
  final List<Timer> _scheduledTimers = [];
  bool _isSupported = false;

  // ---- lifecycle ----------------------------------------------------------

  @override
  Future<void> initialize() async {
    _isSupported = _checkBrowserSupport();
  }

  // ---- permissions --------------------------------------------------------

  @override
  Future<bool> requestPermissions() async {
    if (!_isSupported) return false;

    try {
      final current = _JSNotification.permission;
      if (current == 'granted') return true;
      if (current == 'denied') return false;

      // Prompt the user
      final result = await _JSNotification.requestPermission().toDart;
      return result.toDart == 'granted';
    } catch (_) {
      return false;
    }
  }

  // ---- scheduling ---------------------------------------------------------

  @override
  Future<void> scheduleDailyReminders({
    required List<DateTime> timeSlots,
    required int minutesBefore,
    required String title,
    required String body,
  }) async {
    await cancelAllReminders();

    if (!_isSupported) return;

    // Ensure permission before scheduling
    if (_JSNotification.permission != 'granted') {
      final granted = await requestPermissions();
      if (!granted) return;
    }

    for (final slot in timeSlots) {
      final reminderTime = slot.subtract(Duration(minutes: minutesBefore));
      if (reminderTime.isAfter(DateTime.now())) {
        final delay = reminderTime.difference(DateTime.now());
        _scheduledTimers.add(
          Timer(delay, () {
            _showNotification(title: title, body: body);
          }),
        );
      }
    }
  }

  @override
  Future<void> cancelAllReminders() async {
    for (final timer in _scheduledTimers) {
      timer.cancel();
    }
    _scheduledTimers.clear();
  }

  // ---- private helpers ----------------------------------------------------

  /// Show a browser notification immediately.
  void _showNotification({required String title, required String body}) {
    if (!_isSupported || _JSNotification.permission != 'granted') return;

    try {
      _JSNotification(
        title,
        _NotificationOptions(body: body, icon: 'icons/Icon-192.png'),
      );
    } catch (_) {
      // Silently ignore – e.g. user revoked permission in the meantime.
    }
  }

  /// Returns `true` when the browser exposes the Notification API.
  bool _checkBrowserSupport() {
    try {
      // Accessing the static getter throws if `Notification` is undefined.
      _JSNotification.permission;
      return true;
    } catch (_) {
      return false;
    }
  }
}
