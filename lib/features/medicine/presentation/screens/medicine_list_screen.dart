import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/medicine.dart';
import '../providers/medicine_provider.dart';
import 'add_medicine_screen.dart';

class MedicineListScreen extends StatelessWidget {
  const MedicineListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicineProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Medicines"),
        centerTitle: true,
      ),
      body: provider.medicines.isEmpty
          ? const Center(
              child: Text(
                "💊 No medicines added yet.\nTap + to add one!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.medicines.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final medicine = provider.medicines[index];
                return MedicineCard(
                  medicine: medicine,
                  onUpdate: (updated) =>
                      provider.updateMedicine(index, updated),
                  onDelete: () => provider.deleteMedicine(index),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // 👇 wait for result
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddMedicineScreen()),
          );

          if (result != null && result is Medicine) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.teal,
                content: Text("⏰ Alarm set for ${result.name}"),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Medicine"),
      ),
    );
  }
}

class MedicineCard extends StatelessWidget {
  final Medicine medicine;
  final ValueChanged<Medicine> onUpdate;
  final VoidCallback onDelete;

  const MedicineCard({
    super.key,
    required this.medicine,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Medicine Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal.shade400, Colors.teal.shade200],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.medication_liquid,
                  size: 26, color: Colors.white),
            ),
            const SizedBox(width: 14),

            // Main Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicine.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    medicine.dosage,
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: medicine.times
                        .map(
                          (time) => Chip(
                            label: Text(time,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.teal)),
                            backgroundColor: Colors.teal.withOpacity(0.1),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: -2),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),

            // Actions Column
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Toggle
                Transform.scale(
                  scale: 0.9,
                  child: Switch(
                    value: medicine.isActive,
                    onChanged: (value) {
                      final updated = Medicine(
                        id: medicine.id,
                        name: medicine.name,
                        dosage: medicine.dosage,
                        times: medicine.times,
                        isActive: value,
                      );
                      onUpdate(updated);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor:
                              value ? Colors.green : Colors.grey[850],
                          content: Text(
                            value
                                ? "🔔 Reminders for ${medicine.name} enabled"
                                : "🔕 Reminders for ${medicine.name} disabled",
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit,
                          size: 18, color: Colors.blueAccent),
                      tooltip: "Edit",
                      onPressed: () async {
                        // 👇 wait for result
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AddMedicineScreen(existingMedicine: medicine),
                          ),
                        );

                        if (result != null && result is Medicine) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.blueAccent,
                              content: Text(
                                  "✏️ Updated reminder for ${result.name}"),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete,
                          size: 18, color: Colors.redAccent),
                      tooltip: "Delete",
                      onPressed: () => _showDeleteDialog(context),
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning, color: Colors.red, size: 40),
              const SizedBox(height: 10),
              Text("Delete Reminder?",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                "Are you sure you want to delete '${medicine.name}'?",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel")),
                  const SizedBox(width: 8),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent),
                      onPressed: () {
                        onDelete();
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.redAccent,
                            content: Text("❌ Deleted ${medicine.name}"),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: const Text("Confirm")),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
