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

    // Schedule the notification for the new medicine
    await NotificationService.scheduleMedicineReminder(
      id: medicine.id.hashCode, // Use a unique int ID
      medicineName: medicine.name,
      dosage: medicine.dosage,
      time: medicine.time,
    );

    _loadMedicines(); // Reload list from DB
  }

  Future<void> updateMedicine(int index, Medicine newMedicine) async {
    // Get the old medicine to cancel its notification
    final oldMedicine = _medicines[index];

    // Cancel the old reminder first
    await NotificationService.cancelReminder(oldMedicine.id.hashCode);

    // Update in the database
    await DBService.instance.updateMedicine(index, newMedicine);

    // Schedule a new reminder with the updated details
    await NotificationService.scheduleMedicineReminder(
      id: newMedicine.id.hashCode, // Use the same ID
      medicineName: newMedicine.name,
      dosage: newMedicine.dosage,
      time: newMedicine.time,
    );

    _loadMedicines(); // Reload list from DB
  }

  Future<void> deleteMedicine(int index) async {
    final medicineToDelete = _medicines[index];

    // Cancel the notification before deleting
    await NotificationService.cancelReminder(medicineToDelete.id.hashCode);

    // Delete from the database
    await DBService.instance.deleteMedicine(index);

    _loadMedicines(); // Reload list from DB
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }
}
