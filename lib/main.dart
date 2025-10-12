import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_routes.dart';
import 'core/constants/strings.dart';
import 'core/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/work_manager_service.dart';
import 'features/medicine/presentation/providers/medicine_provider.dart';
import 'services/db_service.dart';

void main() async {
  // Required for using async code in main
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services BEFORE running the app
  await DBService.init(); 
  await NotificationService.init();
  WorkManagerService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MedicineProvider(),
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
