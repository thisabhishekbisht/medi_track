import 'package:flutter/material.dart';

import '../../../../core/notification_service.dart';
import '../../../../models/medicine.dart';
import '../../../../services/db_service.dart';

class MedicineProvider extends ChangeNotifier {
  List<Medicine> _medicines = [];
  List<Medicine> get medicines => _medicines;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  MedicineProvider() {
    _loadMedicines();
  }

  void _loadMedicines() {
    _setLoading(true);
    _medicines = DBService.instance.getAllMedicines();
    _setLoading(false);
  }

  Future<void> addMedicine(Medicine medicine) async {
    await DBService.instance.addMedicine(medicine);
    if (medicine.isActive) {
      await NotificationService.scheduleMedicineReminder(
        id: medicine.notificationId,
        medicineName: medicine.name,
        dosage: medicine.dosage,
        time: medicine.time,
        payload: medicine.id,
      );
    }
    _loadMedicines(); // Reload list from DB
  }

  Future<void> updateMedicine(Medicine updatedMedicine) async {
    // We must find the medicine by its unique ID
    final index = _medicines.indexWhere((m) => m.id == updatedMedicine.id);
    if (index == -1) return; // Not found

    final oldMedicine = _medicines[index];

    // Cancel the old notification
    await NotificationService.cancelReminder(oldMedicine.notificationId);

    // Update in the database
    await DBService.instance.updateMedicine(index, updatedMedicine);

    // Schedule a new one if it's active
    if (updatedMedicine.isActive) {
      await NotificationService.scheduleMedicineReminder(
        id: updatedMedicine.notificationId,
        medicineName: updatedMedicine.name,
        dosage: updatedMedicine.dosage,
        time: updatedMedicine.time,
        payload: updatedMedicine.id,
      );
    }
    _loadMedicines(); // Reload
  }

  Future<void> deleteMedicine(String medicineId) async {
    final index = _medicines.indexWhere((m) => m.id == medicineId);
    if (index == -1) return;

    final medicineToDelete = _medicines[index];

    // Cancel the notification before deleting
    await NotificationService.cancelReminder(medicineToDelete.notificationId);

    // Delete from the database
    await DBService.instance.deleteMedicine(index);
    _loadMedicines();
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }
}
