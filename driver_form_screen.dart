import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/driver_model.dart';
import '../providers/app_state_provider.dart';
import '../utils/constants.dart';
import '../widgets/custom_textfield.dart';

class DriverFormScreen extends StatefulWidget {
  final Driver? driver;
  const DriverFormScreen({super.key, this.driver});

  @override
  State<DriverFormScreen> createState() => _DriverFormScreenState();
}

class _DriverFormScreenState extends State<DriverFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _licenseCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _salaryCtrl;
  String _salaryType = AppConstants.salaryTypes.last;

  @override
  void initState() {
    super.initState();
    final d = widget.driver;
    _nameCtrl = TextEditingController(text: d?.name ?? '');
    _phoneCtrl = TextEditingController(text: d?.phone ?? '');
    _licenseCtrl = TextEditingController(text: d?.licenseNumber ?? '');
    _addressCtrl = TextEditingController(text: d?.address ?? '');
    _salaryCtrl = TextEditingController(text: d?.salaryAmount.toString() ?? '');
    if (d != null) _salaryType = d.salaryType;
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.driver != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Driver' : 'Add Driver')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(label: 'Name', controller: _nameCtrl, required: true),
            CustomTextField(label: 'Phone', controller: _phoneCtrl, required: true, keyboardType: TextInputType.phone),
            CustomTextField(label: 'License Number', controller: _licenseCtrl),
            CustomTextField(label: 'Address', controller: _addressCtrl, maxLines: 2),
            DropdownButtonFormField<String>(
              value: _salaryType,
              decoration: InputDecoration(labelText: 'Salary Type', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
              items: AppConstants.salaryTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _salaryType = v!),
            ),
            const SizedBox(height: 10),
            CustomTextField(label: 'Salary Amount', controller: _salaryCtrl, keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkBlue, foregroundColor: Colors.white, padding: const EdgeInsets.all(16)),
              onPressed: _save,
              child: Text(isEdit ? 'Update Driver' : 'Save Driver'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final appState = context.read<AppStateProvider>();
    final driver = Driver(
      id: widget.driver?.id,
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      licenseNumber: _licenseCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      salaryType: _salaryType,
      salaryAmount: double.tryParse(_salaryCtrl.text) ?? 0,
    );
    if (widget.driver != null) {
      await appState.updateDriver(driver);
    } else {
      await appState.addDriver(driver);
    }
    if (mounted) Navigator.pop(context);
  }
}
