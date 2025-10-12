import 'dart:io';
import 'dart:typed_data'; // for Int64List

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'medicine_channel_v1';
  static const String _channelName = 'Medicine Reminders';
  static const String _channelDescription = 'Reminds user to take medicine';

  /// Call this once at app startup (main)
  static Future<void> init() async {
    // timezone
    tz.initializeTimeZones();
    // set local location to device timezone
    try {
      tz.setLocalLocation(tz.getLocation(tz.local.name));
    } catch (_) {}

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosInit = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    final initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(initSettings,
        onDidReceiveNotificationResponse: _onNotificationResponse);

    await _createChannel();

    if (Platform.isAndroid) {
      await _requestAndroidPermissions();
    }
  }

  /// Shows a notification. This is intended to be called from the background isolate.
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }

  static Future<void> _requestAndroidPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  static Future<void> _createChannel() async {
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  static void _onNotificationResponse(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.id} ${response.payload}');
  }

  static Future<void> scheduleMedicineReminder({
    required int id,
    required String medicineName,
    required String dosage,
    required TimeOfDay time,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList(<int>[0, 500, 200, 500]),
      styleInformation: const DefaultStyleInformation(true, true),
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    debugPrint('Scheduling notification with id: $id at $scheduled');

    await _plugin.zonedSchedule(
      id,
      "Time to take your medicine 💊",
      "$medicineName (${dosage.isNotEmpty ? dosage : 'dose'})",
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );

    if (Platform.isAndroid) {
      final initialDelay = scheduled.difference(now);
      await Workmanager().registerPeriodicTask(
        id.toString(),
        "reschedule-notification-task",
        frequency: const Duration(days: 1),
        initialDelay: initialDelay,
        inputData: <String, dynamic>{
          'id': id, // Pass ID to background task
          'title': "Time to take your medicine 💊",
          'body": "$medicineName (${dosage.isNotEmpty ? dosage : 'dose'})",
          'payload': payload,
        },
      );
    }
  }

  static Future<void> cancelReminder(int id) async {
    await _plugin.cancel(id);
    if (Platform.isAndroid) {
      await Workmanager().cancelByUniqueName(id.toString());
    }
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
    if (Platform.isAndroid) {
      await Workmanager().cancelAll();
    }
  }
}
