import 'package:flutter_test/flutter_test.dart';

import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:medi_track/models/medicine.dart';


void main() {
  setUp(() async {
    await setUpTestHive(); // ✅ sets up in-memory Hive
    Hive.registerAdapter(MedicineAdapter()); // ✅ register your adapter
  });

  tearDown(() async {
    await tearDownTestHive();
  });

  testWidgets('App loads main screen', (WidgetTester tester) async {
    // Now Hive is ready to open boxes in your repository
    // Your test code here
  });
}
