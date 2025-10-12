import 'package:flutter/material.dart';
import 'package:medi_track/services/db_service.dart';
import 'package:provider/provider.dart';

import 'core/app_routes.dart';
import 'core/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/medicine/presentation/providers/medicine_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Hive/DB before the app starts
  await DBService.init();
  await NotificationService.init(); // 👈 call static method directly
  runApp(const MediTrackApp());
}

class MediTrackApp extends StatefulWidget {
  const MediTrackApp({super.key});

  @override
  State<MediTrackApp> createState() => _MediTrackAppState();
}

class _MediTrackAppState extends State<MediTrackApp> {
  late final MedicineProvider _medicineProvider;

  @override
  void initState() {
    super.initState();
    _medicineProvider = MedicineProvider(DBService());
  }

  @override
  void dispose() {
    _medicineProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _medicineProvider),
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
