import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Initialize timezone data
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
    InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(settings);
  }

  /// Schedule a daily alarm at [time] for [medicineName]
  static Future<void> scheduleMedicineReminder({
    required int id, // unique ID per alarm
    required String medicineName,
    required String dosage,
    required TimeOfDay time,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'medicine_channel',
      'Medicine Reminders',
      channelDescription: 'Reminds user to take medicine',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      sound: const RawResourceAndroidNotificationSound('alarm'), // put alarm.mp3 in android/app/src/main/res/raw
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    final now = DateTime.now();
    final scheduleTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      "Time to take your medicine 💊",
      "$medicineName ($dosage)",
      tz.TZDateTime.from(scheduleTime, tz.local).isBefore(tz.TZDateTime.now(tz.local))
          ? tz.TZDateTime.from(scheduleTime.add(const Duration(days: 1)), tz.local)
          : tz.TZDateTime.from(scheduleTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // repeats daily
    );
  }

  /// Cancel specific reminder
  static Future<void> cancelReminder(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  /// Cancel all reminders
  static Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}
