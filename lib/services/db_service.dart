import 'package:hive_flutter/hive_flutter.dart';

import '../models/medicine.dart';

class DBService {
  static const String _boxName = 'medicines';
  static late final Box<Medicine> _box;

  /// Initialize Hive and open medicine box
  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(MedicineAdapter());
    }
    _box = await Hive.openBox<Medicine>(_boxName);
  }

  /// Provides a stream of box events
  Stream<BoxEvent> get watch => _box.watch();

  /// Add new medicine
  Future<void> addMedicine(Medicine medicine) async {
    await _box.add(medicine);
    print("✅ Medicine stored: ${medicine.name}");
  }

  /// Get all medicines
  List<Medicine> getAllMedicines() {
    return _box.values.toList();
  }

  /// Update medicine by index
  Future<void> updateMedicine(int index, Medicine updated) async {
    await _box.putAt(index, updated);
  }

  /// Delete medicine by index
  Future<void> deleteMedicine(int index) async {
    await _box.deleteAt(index);
  }

  /// Clear all medicines
  Future<void> clearMedicines() async {
    await _box.clear();
  }
}
