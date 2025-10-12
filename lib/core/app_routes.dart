import 'package:flutter/material.dart';
import 'package:medi_track/features/medicine/presentation/screens/add_medicine_screen.dart';
import 'package:medi_track/features/medicine/presentation/screens/medicine_list_screen.dart';
import 'package:medi_track/features/splash/presentation/screens/splash_screen.dart';
import 'package:medi_track/models/medicine.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String medicineList = '/medicines';
  static const String addMedicine = '/add-medicine';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case medicineList:
        return MaterialPageRoute(builder: (_) => const MedicineListScreen());
      case addMedicine: 
        final medicine = settings.arguments as Medicine?;
        return MaterialPageRoute(
          builder: (_) => AddMedicineScreen(medicine: medicine),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text(
                "404: Screen not found - ${settings.name}",
                style: const TextStyle(fontSize: 18, color: Colors.red),
              ),
            ),
          ),
        );
    }
  }
}
