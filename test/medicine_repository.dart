import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:medi_track/features/medicine/data/medicine_repository.dart';
import 'package:medi_track/models/medicine.dart';

void main() {
  late MedicineRepository repository;
/*
  setUp(() async {
    // Setup in-memory Hive for testing
    await setUpTestHive();
    Hive.registerAdapter(MedicineAdapter());
    await Hive.openBox<Medicine>('medicines');

    repository = MedicineRepository();
  });

  tearDown(() async {
    await tearDownTestHive();
  });

  test('addMedicine and getMedicines works correctly', () async {
    // Arrange
    final medicine = Medicine(
      name: 'Paracetamol',
      dosage: '500mg',
      times: ['08:00', '20:00'], isActive: true,
    );

    // Act
    await repository.addMedicine(medicine);
    final medicines = await repository.getMedicines();

    // Assert
    expect(medicines.length, 1);
    expect(medicines.first.name, 'Paracetamol');
    expect(medicines.first.dosage, '500mg');
  });

  test('deleteMedicine removes a medicine', () async {
    // Arrange
    final medicine = Medicine(
      name: 'Ibuprofen',
      dosage: '200mg',
      times: ['10:00'], isActive: false,
    );

    await repository.addMedicine(medicine);

    // Act
    await repository.deleteMedicine(2);
    final medicines = await repository.getMedicines();

    // Assert
    expect(medicines.isEmpty, true);
  });*/
}
