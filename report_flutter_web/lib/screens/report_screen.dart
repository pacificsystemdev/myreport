import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/reports_provider.dart';
import '../models/models.dart';
import 'reports_list_screen.dart';
import 'login_screen.dart';

class ReportScreen extends StatefulWidget {
  final Report? existingReport;

  const ReportScreen({super.key, this.existingReport});

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _workactivityController;
  late final TextEditingController _workactivitywithCustController;
  late final TextEditingController _customerNameController;
  late final TextEditingController _customerContactController;
  late final TextEditingController _customerFeeController;
  bool _isLoading = false;
  late DateTime selectedDate;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  late bool isEdit;

  @override
  void initState() {
    super.initState();
    isEdit = widget.existingReport != null;
    _workactivityController = TextEditingController();
    _workactivitywithCustController = TextEditingController();
    _customerNameController = TextEditingController();
    _customerContactController = TextEditingController();
    _customerFeeController = TextEditingController(text: '0');
    selectedDate = DateTime.now();

    if (isEdit) {
      final report = widget.existingReport!;
      _workactivityController.text = report.workactivity;
      _workactivitywithCustController.text = report.workactivitywithCust;
      _customerNameController.text = report.customerName;
      _customerContactController.text = report.customerContact;
      _customerFeeController.text = report.customerFee.toStringAsFixed(0);
      selectedDate = report.reportDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
      return SizedBox();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text(isEdit ? 'Edit Report' : 'New Report'),
        actions: [
          IconButton(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            icon: Icon(Icons.list),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ReportsListScreen()),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _workactivityController,
              decoration: InputDecoration(labelText: 'Work Activity'),
              maxLines: 3,
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _workactivitywithCustController,
              decoration: InputDecoration(labelText: 'Work with Customer'),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _customerNameController,
              decoration: InputDecoration(labelText: 'Customer Name'),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _customerContactController,
              decoration: InputDecoration(labelText: 'Customer Contact'),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _customerFeeController,
              decoration: InputDecoration(labelText: 'Fee'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            ListTile(
              title: const Text('Report Date'),
              subtitle: Text(_dateFormat.format(selectedDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,

              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 20,
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),

              child: _isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    )
                  : Text(
                      isEdit ? 'Update Report' : 'Submit Report',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = {
      'workactivity': _workactivityController.text,
      'workactivitywithCust':
          _workactivitywithCustController.text.trim().isEmpty
          ? 'N/A'
          : _workactivitywithCustController.text,
      'customerName': _customerNameController.text.trim().isEmpty
          ? 'N/A'
          : _customerNameController.text,
      'customerContact': _customerContactController.text.trim().isEmpty
          ? 'N/A'
          : _customerContactController.text,
      'customerFee': _customerFeeController.text.trim().isEmpty
          ? 0
          : double.tryParse(_customerFeeController.text) ?? 0,
      'reportDate': selectedDate.toIso8601String().split('T')[0], // YYYY-MM-DD
    };

    final auth = context.read<AuthProvider>();
    final reportsProvider = context.read<ReportsProvider>();

    dynamic response;
    bool success;
    if (isEdit) {
      response = await reportsProvider.updateReport(
        widget.existingReport!.reportId,
        data,
        auth.user!.token,
        auth.user!.userId,
      );
      success = response == true;
    } else {
      response = await reportsProvider.submitReport(
        data,
        auth.user!.token,
        auth.user!.userId,
      );
      success = response == true;
    }

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEdit ? 'Report updated!' : 'Report submitted!'),
        ),
      );
      if (isEdit) {
        Navigator.pop(context);
      } else {
        _workactivityController.clear();
        _workactivitywithCustController.clear();
        _customerNameController.clear();
        _customerContactController.clear();
        _customerFeeController.clear();
      }
    } else {
      String errorMsg = '';
      if (response is Map && response['error'] != null) {
        errorMsg = response['error'].toString();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Submit/Update failed${errorMsg.isNotEmpty ? ': $errorMsg' : ''}',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _workactivityController.dispose();
    _workactivitywithCustController.dispose();
    _customerNameController.dispose();
    _customerContactController.dispose();
    _customerFeeController.dispose();
    super.dispose();
  }
}
