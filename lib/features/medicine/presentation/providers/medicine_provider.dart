import 'package:flutter/foundation.dart';

import '../../../../models/medicine.dart';
import '../../../../services/db_service.dart';

class MedicineProvider extends ChangeNotifier {
  final DBService _dbService;

  // The list of medicines. It's initialized directly.
  List<Medicine> _medicines = [];

  // Public getter for the medicines list.
  List<Medicine> get medicines => _medicines;

  // A flag to indicate if data is being loaded.
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  MedicineProvider(this._dbService) {
    // Load medicines synchronously when the provider is created.
    _loadMedicines();
  }

  // Load medicines from the DB service.
  void _loadMedicines() {
    _setLoading(true);
    // getAllMedicines is synchronous as per the DBService interface.
    _medicines = _dbService.getAllMedicines();
    _setLoading(false);
  }

  // Add a new medicine and then reload the list from the DB.
  Future<void> addMedicine(Medicine medicine) async {
    await _dbService.addMedicine(medicine);
    _loadMedicines(); // Reload synchronously
  }

  // Update an existing medicine by its list index.
  Future<void> updateMedicine(int index, Medicine medicine) async {
    // The DB service expects the integer index for updates.
    await _dbService.updateMedicine(index, medicine);
    _loadMedicines(); // Reload synchronously
  }

  // Delete a medicine by its list index.
  Future<void> deleteMedicine(int index) async {
    // The DB service expects the integer index for deletion.
    await _dbService.deleteMedicine(index);
    _loadMedicines(); // Reload synchronously
  }

  // Helper to manage loading state and notify listeners.
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
