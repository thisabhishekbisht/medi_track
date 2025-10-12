import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/medicine.dart';
import '../providers/medicine_provider.dart';

class AddMedicineScreen extends StatefulWidget {
  final Medicine? medicine; // Can be null if adding a new one

  const AddMedicineScreen({super.key, this.medicine});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _dosage;
  late TimeOfDay _time;

  bool get _isEditing => widget.medicine != null;

  @override
  void initState() {
    super.initState();
    _name = widget.medicine?.name ?? '';
    _dosage = widget.medicine?.dosage ?? '';
    _time = widget.medicine?.time ?? TimeOfDay.now();
  }

  // Force the time picker to a 12-hour format
  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _time) {
      setState(() {
        _time = picked;
      });
    }
  }

  // Make submit asynchronous to ensure saving completes before popping
  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final provider = Provider.of<MedicineProvider>(context, listen: false);

      final newMedicine = Medicine(
        id: widget.medicine?.id, // Keep the same ID when editing
        name: _name,
        dosage: _dosage,
        hour: _time.hour,
        minute: _time.minute,
      );

      // Await the provider action to ensure it completes
      if (_isEditing) {
          await provider.updateMedicine(newMedicine);
      } else {
        await provider.addMedicine(newMedicine);
      }

      // Only pop the screen after the operation is complete
      if (mounted) { // Check if the widget is still in the tree
          Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Medicine' : 'Add Medicine'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(
                  labelText: 'Medicine Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.medication),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a name' : null,
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 20),
              TextFormField(
                initialValue: _dosage,
                decoration: const InputDecoration(
                  labelText: 'Dosage (e.g., 500mg, 1 tablet)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.medical_services_outlined),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a dosage' : null,
                onSaved: (value) => _dosage = value!,
              ),
              const SizedBox(height: 20),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: BorderSide(color: Colors.grey.shade400),
                ),
                leading: const Icon(Icons.access_time),
                title: Text('Time: ${_time.format(context)}'),
                onTap: () => _selectTime(context),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: Text(_isEditing ? 'Update' : 'Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
