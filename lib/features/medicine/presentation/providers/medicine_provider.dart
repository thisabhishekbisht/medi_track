// lib/features/medicine/presentation/providers/medicine_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../models/medicine.dart';
import '../../../../services/db_service.dart';

class MedicineProvider with ChangeNotifier {
  final DBService dbService;

  MedicineProvider(this.dbService);

  List<Medicine> _medicines = [];

  List<Medicine> get medicines => _medicines;

  /// Load all medicines from DB
  Future<void> loadMedicines() async {
    _medicines = dbService.getAllMedicines();
    notifyListeners();
  }

  /// Add a new medicine and refresh list
  Future<void> addMedicine(Medicine medicine) async {
    await dbService.addMedicine(medicine);
    await loadMedicines(); // 👈 important to refresh UI
  }

  /// Update medicine at given index
  Future<void> updateMedicine(int index, Medicine updated) async {
    await dbService.updateMedicine(index, updated);
    await loadMedicines();
  }

  /// Delete medicine by index
  Future<void> deleteMedicine(int index) async {
    await dbService.deleteMedicine(index);
    await loadMedicines();
  }

  /// Clear all medicines
  Future<void> clearMedicines() async {
    await dbService.clearMedicines();
    await loadMedicines();
  }
}
