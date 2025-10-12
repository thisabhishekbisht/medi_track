import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/medicine.dart';
import '../providers/medicine_provider.dart';
import 'add_medicine_screen.dart';

class MedicineListScreen extends StatefulWidget {
  const MedicineListScreen({super.key});

  @override
  State<MedicineListScreen> createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends State<MedicineListScreen> {
  @override
  void initState() {
    super.initState();
    // Load medicines when the screen is first displayed
    Provider.of<MedicineProvider>(context, listen: false).loadMedicines();
  }

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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddMedicineScreen()),
          ).then((result) {
            if (result != null && result is Medicine) {
              _showSnackbar("⏰ Alarm set for ${result.name}", color: Colors.teal);
            }
          });
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Medicine"),
      ),
    );
  }

  void _showSnackbar(String message, {Color color = Colors.black}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Text(message),
        duration: const Duration(seconds: 2),
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
                  Chip(
                    label: Text(medicine.time.format(context),
                        style: const TextStyle(
                            fontSize: 12, color: Colors.teal)),
                    backgroundColor: Colors.teal.withOpacity(0.1),
                    materialTapTargetSize:
                        MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: -2),
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
                        hour: medicine.hour,
                        minute: medicine.minute,
                        isActive: value,
                      );
                      onUpdate(updated);

                      _showSnackbar(
                        value
                            ? "🔔 Reminders for ${medicine.name} enabled"
                            : "🔕 Reminders for ${medicine.name} disabled",
                        color: value ? Colors.green : Colors.grey[850]!,
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AddMedicineScreen(existingMedicine: medicine),
                          ),
                        ).then((result) {
                          if (result != null && result is Medicine) {
                            _showSnackbar(
                              "✏️ Updated reminder for ${result.name}",
                              color: Colors.blueAccent,
                            );
                          }
                        });
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

                      _showSnackbar(
                        "❌ Deleted ${medicine.name}",
                        color: Colors.redAccent,
                      );
                    },
                    child: const Text("Confirm"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackbar(String message, {required Color color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
