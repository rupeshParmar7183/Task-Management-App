import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // Instance of FlutterLocalNotificationsPlugin to manage notifications.
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initializes the notification service.
  /// Call this once in main() to initialize notifications.
  static Future<void> initialize() async {
    tz.initializeTimeZones();
    // Set the local timezone to India (Asia/Kolkata)
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(settings);
  }

  /// Schedules a notification at [scheduledTime].
  /// 
  /// [id] - Unique identifier for the notification.
  /// [title] - Title of the notification.
  /// [body] - Body content of the notification.
  /// [scheduledTime] - Time at which the notification should be shown.
  /// [currentNotification] - If true, shows the notification immediately.
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required bool currentNotification,
  }) async {
    final tz.TZDateTime scheduledDate =
        tz.TZDateTime.from(scheduledTime, tz.local);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'task_channel_id',
      'Task Notifications',
      channelDescription: 'Notifications for task due dates',
      channelShowBadge: true,
      importance: Importance.max,
      priority: Priority.high,
      visibility: NotificationVisibility.public,
    );
    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    try {
      if (currentNotification) {
        await _notificationsPlugin.show(
          id,
          title,
          body,
          platformDetails,
          payload: 'task',
        );
      } else {
        await _notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledDate,
          platformDetails,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  /// Cancels the notification with given [id].
  /// 
  /// [id] - Unique identifier for the notification to be canceled.
  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}
