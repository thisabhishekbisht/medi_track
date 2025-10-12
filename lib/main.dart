import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_routes.dart';
import 'core/constants/strings.dart';
import 'core/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/medicine/presentation/providers/medicine_provider.dart';
import 'services/db_service.dart';

void main() async {
  // Required for using async code in main
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  final dbService = DBService();
  // await dbService.init(); // This was incorrect, DBService does not have an init method
  await NotificationService.init();

  runApp(MyApp(dbService: dbService));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.dbService});

  final DBService dbService;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MedicineProvider(dbService),
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
