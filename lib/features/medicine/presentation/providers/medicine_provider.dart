import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../../../models/medicine.dart';
import '../../../../services/db_service.dart';

class MedicineProvider with ChangeNotifier {
  final DBService dbService;
  late final StreamSubscription<BoxEvent> _subscription;

  MedicineProvider(this.dbService) {
    _subscription = dbService.watch.listen((event) {
      // Reload medicines on any change
      loadMedicines();
    });
  }

  List<Medicine> _medicines = [];

  List<Medicine> get medicines => _medicines;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  /// Load all medicines from DB
  Future<void> loadMedicines() async {
    _medicines = dbService.getAllMedicines();
    notifyListeners();
  }

  /// Add a new medicine and refresh list
  Future<void> addMedicine(Medicine medicine) async {
    await dbService.addMedicine(medicine);
  }

  /// Update medicine at given index
  Future<void> updateMedicine(int index, Medicine updated) async {
    await dbService.updateMedicine(index, updated);
  }

  /// Delete medicine by index
  Future<void> deleteMedicine(int index) async {
    await dbService.deleteMedicine(index);
  }

  /// Clear all medicines
  Future<void> clearMedicines() async {
    await dbService.clearMedicines();
  }
}
