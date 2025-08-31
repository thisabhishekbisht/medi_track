import 'package:hive_flutter/hive_flutter.dart';

import '../models/medicine.dart';

class DBService {
  static const String boxName = 'medicines';

  /// Initialize Hive and open medicine box
  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(MedicineAdapter());
    }
    await Hive.openBox<Medicine>(boxName);
  }

  /// Add new medicine
  Future<void> addMedicine(Medicine medicine) async {
    final box = Hive.box<Medicine>(boxName);
    await box.add(medicine);
    print("✅ Medicine stored: ${medicine.name}");
  }

  /// Get all medicines
  List<Medicine> getAllMedicines() {
    final box = Hive.box<Medicine>(boxName);
    return box.values.toList();
  }

  /// Update medicine by index
  Future<void> updateMedicine(int index, Medicine updated) async {
    final box = Hive.box<Medicine>(boxName);
    await box.putAt(index, updated);
  }

  /// Delete medicine by index
  Future<void> deleteMedicine(int index) async {
    final box = Hive.box<Medicine>(boxName);
    await box.deleteAt(index);
  }

  /// Clear all medicines
  Future<void> clearMedicines() async {
    final box = Hive.box<Medicine>(boxName);
    await box.clear();
  }
}
