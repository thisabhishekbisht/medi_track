import 'dart:async';

import 'package:flutter/foundation.dart';

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
    await NotificationService.scheduleNotification(
      medicine.id.hashCode, // Use a unique ID for the notification
      medicine.name,
      'Time to take your ${medicine.dosage} dose',
      medicine.hour,
      medicine.minute,
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
    await NotificationService.cancelNotification(medicine.id.hashCode);

    await _dbService.deleteMedicine(index);
    // No need to call notifyListeners() here, the stream will do it
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }
}
