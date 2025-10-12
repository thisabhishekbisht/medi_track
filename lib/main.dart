import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

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
  await DBService.init(); // This is the critical line that was missing
  await NotificationService.init();
  await AndroidAlarmManager.initialize();

  // The DBService is now static, so we don't need to pass it.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // The MedicineProvider can now create its own DBService instance or use the static methods
    return ChangeNotifierProvider(
      create: (_) => MedicineProvider(DBService()),
      child: MaterialApp(
        title: AppStrings.appName,
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        // Use the route generator for all navigation
        onGenerateRoute: AppRoutes.generateRoute,
        // The initial route is now handled by the generator
        initialRoute: AppRoutes.splash,
      ),
    );
  }
}
