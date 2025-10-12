import 'package:flutter/material.dart';
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
  final int hour;

  @HiveField(4)
  final int minute;

  @HiveField(5)
  final bool isActive;

  Medicine({
    String? id,
    required this.name,
    required this.dosage,
    required this.hour,
    required this.minute,
    this.isActive = true,
  }) : id = id ?? const Uuid().v4();

  TimeOfDay get time => TimeOfDay(hour: hour, minute: minute);

  /// We need a unique integer as a notification ID.
  /// Using the first 8 characters of the UUID and converting to an integer
  /// is a decent way to get a unique integer.
  int get notificationId => id.substring(0, 8).hashCode;
}
