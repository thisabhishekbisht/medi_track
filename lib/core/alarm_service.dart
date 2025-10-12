import 'package:flutter/material.dart';

@pragma('vm:entry-point')
void printHello() {
  final DateTime now = DateTime.now();
  final int isolateId = 1;
  debugPrint("Alarm fired at $now - isolate=$isolateId");
}
