import 'package:hive/hive.dart';

import 'package:uuid/uuid.dart';

part 'medicine.g.dart';

@HiveType(typeId: 0)
class Medicine extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String dosage;

  @HiveField(3)
  final List<String> times;

  @HiveField(4)
  final bool isActive;

  Medicine({
    String? id,
    required this.name,
    required this.dosage,
    required this.times,
    required this.isActive,
  }) : id = id ?? const Uuid().v4(); // 👈 auto-generate if null
}
