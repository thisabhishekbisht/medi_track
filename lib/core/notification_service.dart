import 'dart:io';
import 'dart:typed_data'; // for Int64List

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';

import 'work_manager_service.dart';

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
      final String local = DateTime.now().timeZoneName;
      // best-effort; tz.local is already set but this avoids some platform issues
      tz.setLocalLocation(tz.getLocation(tz.local.name));
    } catch (_) {}

    // Android initialization
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization (if needed)
    final iosInit = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    final initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(initSettings,
        onDidReceiveNotificationResponse: _onNotificationResponse);

    // create channel for Android
    await _createChannel();

    // Request runtime permission on Android
    if (Platform.isAndroid) {
      await _requestAndroidPermissions();
    }
  }

  static Future<void> _requestAndroidPermissions() async {
    // Request notification permission
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    // Request exact alarm permission
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

  // Handler when notification is tapped
  static void _onNotificationResponse(NotificationResponse response) {
    // handle taps if needed (navigate, open app, etc.)
    debugPrint('Notification tapped: ${response.id} ${response.payload}');
  }

  /// Schedules a daily alarm at given TimeOfDay.
  /// Use a unique int id (e.g. medicine.id.hashCode + index).
  static Future<void> scheduleMedicineReminder({
    required int id,
    required String medicineName,
    required String dosage,
    required TimeOfDay time,
    String? payload,
  }) async {
    // Build Android/iOS details
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
      // If you added a custom sound in android/app/src/main/res/raw named alarm.mp3:
      // sound: RawResourceAndroidNotificationSound('alarm'),
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      // sound: 'alarm.aiff' // if you provided sound on iOS bundle
    );

    final details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    // Compute next instance of the time
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

    // Schedule the notification
    await _plugin.zonedSchedule(
      id,
      "Time to take your medicine 💊",
      "$medicineName (${dosage.isNotEmpty ? dosage : 'dose'})",
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // repeats daily
      payload: payload,
    );

    // Schedule background task
    if (Platform.isAndroid) {
      final initialDelay = scheduled.difference(now);
      WorkManagerService.scheduleAlarmLog(
        medicineName: medicineName,
        dosage: dosage,
        initialDelay: initialDelay,
        uniqueName: id.toString(),
      );
    }
  }

  /// Cancel a scheduled reminder by int id
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

  /// For testing: show immediate notification (useful to test sound/vibration)
  static Future<void> showImmediateTestNotification({
    required int id,
    required String title,
    required String body,
  }) =>
      _plugin.show(
        id,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            vibrationPattern: Int64List.fromList(<int>[0, 500, 200, 500]),
          ),
          iOS:
              DarwinNotificationDetails(presentSound: true, presentAlert: true),
        ),
      );
}
