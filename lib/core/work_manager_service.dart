import 'package:workmanager/workmanager.dart';

const logAlarmTask = "logAlarmTask";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    if (task == logAlarmTask) {
      final medicineName = inputData?['medicineName'] ?? 'Unknown Medicine';
      final dosage = inputData?['dosage'] ?? 'Unknown Dosage';
      print(
          "Alarm fired for $medicineName ($dosage) at ${DateTime.now()} - isolate=1");
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
