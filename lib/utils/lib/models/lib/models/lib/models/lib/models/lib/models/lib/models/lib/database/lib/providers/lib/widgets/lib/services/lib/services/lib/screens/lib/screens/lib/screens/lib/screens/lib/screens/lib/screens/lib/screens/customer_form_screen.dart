4import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/customer_model.dart';
import '../providers/app_state_provider.dart';
import '../utils/constants.dart';
import '../widgets/custom_textfield.dart';

class CustomerFormScreen extends StatefulWidget {
  final Customer? customer;
  const CustomerFormScreen({super.key, this.customer});

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _cnicCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _creditLimitCtrl;

  @override
  void initState() {
    super.initState();
    final c = widget.customer;
    _nameCtrl = TextEditingController(text: c?.name ?? '');
    _phoneCtrl = TextEditingController(text: c?.phone ?? '');
    _cnicCtrl = TextEditingController(text: c?.cnicNtn ?? '');
    _addressCtrl = TextEditingController(text: c?.address ?? '');
    _creditLimitCtrl = TextEditingController(text: c?.creditLimit.toString() ?? '0');
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.customer != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Customer' : 'Add Customer')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(label: 'Company/Individual Name', controller: _nameCtrl, required: true),
            CustomTextField(label: 'Phone', controller: _phoneCtrl, required: true, keyboardType: TextInputType.phone),
            CustomTextField(label: 'CNIC/NTN', controller: _cnicCtrl),
            CustomTextField(label: 'Address', controller: _addressCtrl, maxLines: 2),
            CustomTextField(label: 'Credit Limit', controller: _creditLimitCtrl, keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkBlue, foregroundColor: Colors.white, padding: const EdgeInsets.all(16)),
              onPressed: _save,
              child: Text(isEdit ? 'Update Customer' : 'Save Customer'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final appState = context.read<AppStateProvider>();
    final customer = Customer(
      id: widget.customer?.id,
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      cnicNtn: _cnicCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      creditLimit: double.tryParse(_creditLimitCtrl.text) ?? 0,
    );
    if (widget.customer != null) {
      await appState.updateCustomer(customer);
    } else {
      await appState.addCustomer(customer);
    }
    if (mounted) Navigator.pop(context);
  }
}
