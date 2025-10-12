import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../models/medicine.dart';
import '../../../../services/db_service.dart';
import '../../../../core/notification_service.dart';

class MedicineProvider extends ChangeNotifier {
  final DBService _dbService;
  late final StreamSubscription _streamSubscription;

  List<Medicine> _medicines = [];
  List<Medicine> get medicines => _medicines;

  MedicineProvider(this._dbService) {
    _loadMedicines();
    // Listen to changes in the database
    _streamSubscription = _dbService.watch.listen((event) {
      _loadMedicines();
    });
  }

  void _loadMedicines() {
    _medicines = _dbService.getAllMedicines();
    notifyListeners();
  }

  Future<void> addMedicine(Medicine medicine) async {
    await _dbService.addMedicine(medicine);

    // Schedule the notification
    await NotificationService.scheduleMedicineReminder(
      id: medicine.id.hashCode, // Use a unique ID for the notification
      medicineName: medicine.name,
      dosage: medicine.dosage,
      time: medicine.time,
    );

    // No need to call notifyListeners() here, the stream will do it
  }

  Future<void> updateMedicine(int index, Medicine medicine) async {
    await _dbService.updateMedicine(index, medicine);
    // No need to call notifyListeners() here, the stream will do it
  }

  Future<void> deleteMedicine(int index) async {
    // Before deleting, cancel the notification
    final medicine = _medicines[index];
    await NotificationService.cancelReminder(medicine.id.hashCode);

    await _dbService.deleteMedicine(index);
    // No need to call notifyListeners() here, the stream will do it
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }
}
