import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vehicle_model.dart';
import '../providers/app_state_provider.dart';
import '../utils/constants.dart';
import '../widgets/custom_textfield.dart';

class VehicleFormScreen extends StatefulWidget {
  final Vehicle? vehicle;
  const VehicleFormScreen({super.key, this.vehicle});

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _numberCtrl;
  late TextEditingController _modelCtrl;
  late TextEditingController _partnerShareCtrl;
  late TextEditingController _notesCtrl;

  String _type = AppConstants.vehicleTypes.first;
  String _ownership = AppConstants.ownershipTypes.first;
  int? _partnerId;
  DateTime? _insuranceExpiry;
  DateTime? _tokenExpiry;
  DateTime? _fitnessExpiry;

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;
    _numberCtrl = TextEditingController(text: v?.vehicleNumber ?? '');
    _modelCtrl = TextEditingController(text: v?.model ?? '');
    _partnerShareCtrl = TextEditingController(text: v?.partnerSharePercent.toString() ?? '0');
    _notesCtrl = TextEditingController(text: v?.notes ?? '');
    if (v != null) {
      _type = v.type;
      _ownership = v.ownershipType;
      _partnerId = v.partnerId;
      _insuranceExpiry = v.insuranceExpiry;
      _tokenExpiry = v.tokenExpiry;
      _fitnessExpiry = v.fitnessExpiry;
    }
  }

  Future<void> _pickDate(void Function(DateTime) onPicked, DateTime? initial) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final isEdit = widget.vehicle != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Vehicle' : 'Add Vehicle')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(label: 'Vehicle Number', controller: _numberCtrl, required: true),
            DropdownButtonFormField<String>(
              value: _type,
              decoration: InputDecoration(labelText: 'Type', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
              items: AppConstants.vehicleTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _type = v!),
            ),
            const SizedBox(height: 10),
            CustomTextField(label: 'Model', controller: _modelCtrl),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _ownership,
              decoration: InputDecoration(labelText: 'Ownership Type', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
              items: AppConstants.ownershipTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _ownership = v!),
            ),
            if (_ownership == 'Partnership') ...[
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                value: _partnerId,
                decoration: InputDecoration(labelText: 'Partner', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                items: appState.partners.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                onChanged: (v) => setState(() => _partnerId = v),
              ),
              CustomTextField(
                label: 'Partner Share %',
                controller: _partnerShareCtrl,
                keyboardType: TextInputType.number,
              ),
            ],
            const SizedBox(height: 14),
            _dateTile('Insurance Expiry', _insuranceExpiry, (d) => setState(() => _insuranceExpiry = d)),
            _dateTile('Token Expiry', _tokenExpiry, (d) => setState(() => _tokenExpiry = d)),
            _dateTile('Fitness Expiry', _fitnessExpiry, (d) => setState(() => _fitnessExpiry = d)),
            const SizedBox(height: 10),
            CustomTextField(label: 'Notes', controller: _notesCtrl, maxLines: 3),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkBlue, foregroundColor: Colors.white, padding: const EdgeInsets.all(16)),
              onPressed: _save,
              child: Text(isEdit ? 'Update Vehicle' : 'Save Vehicle'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateTile(String label, DateTime? value, void Function(DateTime) onPicked) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(value != null ? '${value.day}/${value.month}/${value.year}' : 'Not set'),
      trailing: const Icon(Icons.calendar_today),
      onTap: () => _pickDate(onPicked, value),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final appState = context.read<AppStateProvider>();

    final vehicle = Vehicle(
      id: widget.vehicle?.id,
      vehicleNumber: _numberCtrl.text.trim(),
      type: _type,
      model: _modelCtrl.text.trim(),
      ownershipType: _ownership,
      partnerId: _ownership == 'Partnership' ? _partnerId : null,
      partnerSharePercent: double.tryParse(_partnerShareCtrl.text) ?? 0,
      insuranceExpiry: _insuranceExpiry,
      tokenExpiry: _tokenExpiry,
      fitnessExpiry: _fitnessExpiry,
      notes: _notesCtrl.text.trim(),
    );

    if (widget.vehicle != null) {
      await appState.updateVehicle(vehicle);
    } else {
      await appState.addVehicle(vehicle);
    }
    if (mounted) Navigator.pop(context);
  }
}
