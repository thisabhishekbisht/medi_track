import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';

import 'core/app_routes.dart';
import 'core/constants/strings.dart';
import 'core/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/medicine/presentation/providers/medicine_provider.dart';
import 'services/db_service.dart';

void main() async {
  // Required for using async code in main
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services BEFORE running the app
  await DBService.init(); 
  await NotificationService.init();
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );

  runApp(const MyApp());
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // The 'id' is crucial for displaying the notification.
    final id = inputData!['id'] as int;
    final title = inputData['title'] as String;
    final body = inputData['body'] as String;
    final payload = inputData['payload'] as String?;

    // The notification service is already initialized, so we can directly call it.
    await NotificationService.showNotification(
      id: id,
      title: title,
      body: body,
      payload: payload,
    );

    return Future.value(true);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MedicineProvider()),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        onGenerateRoute: AppRoutes.generateRoute,
        initialRoute: AppRoutes.splash,
      ),
    );
  }
}
