import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/notification_service.dart';
import '../../../../models/medicine.dart';
import '../providers/medicine_provider.dart';

class AddMedicineScreen extends StatefulWidget {
  final Medicine? existingMedicine;

  const AddMedicineScreen({super.key, this.existingMedicine});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _timeController = TextEditingController();

  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    if (widget.existingMedicine != null) {
      _nameController.text = widget.existingMedicine!.name;
      _dosageController.text = widget.existingMedicine!.dosage;
      _selectedTime = widget.existingMedicine!.time;
      _timeController.text = _selectedTime!.format(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicineProvider>(context, listen: false);
    final isEditing = widget.existingMedicine != null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.9),
              Theme.of(context).colorScheme.secondary.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: Theme.of(context)
                                .primaryColor
                                .withOpacity(0.15),
                            child: const Icon(Icons.medication_liquid,
                                size: 28, color: Colors.teal),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            isEditing ? "Edit Medicine" : "Add Medicine",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),

                      const Divider(height: 30),

                      // Medicine Name
                      _fieldInput(
                        label: "Medicine Name",
                        controller: _nameController,
                        icon: Icons.medication,
                        validator: (v) =>
                            v == null || v.isEmpty ? "Enter a name" : null,
                      ),
                      const SizedBox(height: 16),

                      // Dosage
                      _fieldInput(
                        label: "Dosage",
                        controller: _dosageController,
                        icon: Icons.local_pharmacy,
                        validator: (v) =>
                            v == null || v.isEmpty ? "Enter dosage" : null,
                      ),
                      const SizedBox(height: 16),

                      // Time
                      _fieldInput(
                        label: "Time",
                        controller: _timeController,
                        icon: Icons.access_time,
                        readOnly: true,
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: _selectedTime ?? TimeOfDay.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              _selectedTime = picked;
                              _timeController.text = picked.format(context);
                            });
                          }
                        },
                        validator: (v) =>
                            v == null || v.isEmpty ? "Pick a time" : null,
                      ),

                      const SizedBox(height: 24),

                      // Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () async {
                              if (_formKey.currentState!.validate() &&
                                  _selectedTime != null) {
                                final id = widget.existingMedicine?.id ??
                                    const Uuid().v4();

                                final updated = Medicine(
                                  id: id,
                                  name: _nameController.text.trim(),
                                  dosage: _dosageController.text.trim(),
                                  hour: _selectedTime!.hour,
                                  minute: _selectedTime!.minute,
                                  isActive:
                                      widget.existingMedicine?.isActive ?? true,
                                );

                                if (isEditing) {
                                  final index = provider.medicines
                                      .indexWhere((m) => m.id == updated.id);
                                  if (index != -1) {
                                    await provider.updateMedicine(index, updated);
                                  } // Handle case where index is not found?

                                  // Cancel old notification before scheduling a new one
                                  await NotificationService.cancelReminder(
                                      updated.id.hashCode);
                                } else {
                                  await provider.addMedicine(updated);
                                }

                                try {
                                  await NotificationService
                                      .scheduleMedicineReminder(
                                    id: updated.id.hashCode,
                                    medicineName: updated.name,
                                    dosage: updated.dosage,
                                    time: _selectedTime!,
                                  );
                                } catch (e) {
                                  debugPrint("⚠️ Failed to schedule alarm: $e");
                                }

                                if (context.mounted) {
                                  Navigator.pop(context, updated);
                                }
                              }
                            },
                            icon: Icon(isEditing ? Icons.save : Icons.check),
                            label: Text(isEditing ? "Update" : "Save"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
            filled: true,
            fillColor: Theme.of(context).primaryColor.withOpacity(0.06),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _timeController.dispose();
    super.dispose();
  }
}
