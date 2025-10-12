import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medi_track/features/medicine/presentation/providers/medicine_provider.dart';
import 'package:medi_track/features/medicine/presentation/screens/medicine_list_screen.dart';
import 'package:medi_track/services/db_service.dart';
import 'package:provider/provider.dart';

// Mock DBService for testing purposes
class MockDBService implements DBService {
  @override
  Future<void> addMedicine(medicine) async {}

  @override
  Future<void> clearMedicines() async {}

  @override
  Future<void> deleteMedicine(int index) async {}

  @override
  List<Medicine> getAllMedicines() => [];

  @override
  Future<void> updateMedicine(int index, updated) async {}

  @override
  Stream<BoxEvent> get watch => const Stream.empty();
}

void main() {
  // No need for Hive setup for this widget test

  testWidgets('Shows empty state message when no medicines are available',
      (WidgetTester tester) async {
    // Arrange: Create a mock provider with no medicines
    final provider = MedicineProvider(MockDBService());

    // Act: Pump the widget tree
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(
          home: MedicineListScreen(),
        ),
      ),
    );

    // Let the widget tree settle
    await tester.pump();

    // Assert: Find the empty state message
    expect(find.text('💊 No medicines added yet.\nTap + to add one!'),
        findsOneWidget);

    // Assert: Verify that no medicine cards are present
    expect(find.byType(MedicineCard), findsNothing);
  });
}
