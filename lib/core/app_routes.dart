import 'package:flutter/material.dart';
import '../../features/medicine/presentation/screens/medicine_list_screen.dart';
import '../../features/medicine/presentation/screens/add_medicine_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';

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
        return MaterialPageRoute(builder: (_) => const AddMedicineScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text(
                "404: Screen not found",
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            ),
          ),
        );
    }
  }
}
