import 'package:flutter/material.dart';
import 'package:medi_track/services/db_service.dart';
import 'package:provider/provider.dart';

import 'core/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/medicine/presentation/providers/medicine_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Hive/DB before the app starts
  await DBService.init();

  runApp(const MediTrackApp());
}

class MediTrackApp extends StatelessWidget {
  const MediTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MedicineProvider(DBService()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
