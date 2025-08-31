import 'package:hive/hive.dart';

import '../../../models/medicine.dart';

class MedicineRepository {
  static const String boxName = "medicines";

  Future<Box<Medicine>> _openBox() async {
    return await Hive.openBox<Medicine>(boxName);
  }

  Future<void> addMedicine(Medicine medicine) async {
    final box = await _openBox();
    await box.put(medicine.id, medicine);
  }

  Future<List<Medicine>> getAllMedicines() async {
    final box = await _openBox();
    return box.values.toList();
  }

  Future<void> deleteMedicine(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }

  Future<void> updateMedicine(Medicine medicine) async {
    final box = await _openBox();
    await box.put(medicine.id, medicine);
  }
}
