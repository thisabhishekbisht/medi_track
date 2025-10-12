import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:workmanager/workmanager.dart';

const logAlarmTask = "logAlarmTask";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    if (task == logAlarmTask) {
      final medicineName = inputData?['medicineName'] ?? 'Unknown Medicine';
      final dosage = inputData?['dosage'] ?? 'Unknown Dosage';
      final message = "Time for $medicineName ($dosage)";
      print("Alarm fired: $message at ${DateTime.now()} - isolate=1");

      // Show toast
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
    return Future.value(true);
  });
}

class WorkManagerService {
  static void initialize() {
    Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );
  }

  static void scheduleAlarmLog({
    required String medicineName,
    required String dosage,
    required Duration initialDelay,
    required String uniqueName,
  }) {
    Workmanager().registerOneOffTask(
      uniqueName,
      logAlarmTask,
      initialDelay: initialDelay,
      inputData: {
        'medicineName': medicineName,
        'dosage': dosage,
      },
    );
  }
}
