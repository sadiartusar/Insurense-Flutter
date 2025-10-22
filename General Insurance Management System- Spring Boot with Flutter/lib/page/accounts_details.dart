import 'package:flutter/material.dart';
import 'package:general_insurance_management_system/model/account_model.dart';
import 'package:general_insurance_management_system/service/payment_service.dart';

class AccountDetailsPage extends StatefulWidget {
  final int userId;
  const AccountDetailsPage({super.key, required this.userId});

  @override
  State<AccountDetailsPage> createState() => _AccountDetailsPageState();
}

class _AccountDetailsPageState extends State<AccountDetailsPage> {
  final PaymentService _service = PaymentService();
  AccountModel? _account;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAccount();
  }

  Future<void> _loadAccount() async {
    try {
      final account = await _service.getAccountDetails(widget.userId);
      setState(() {
        _account = account;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account Details')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('❌ $_error'))
          : _account == null
          ? const Center(child: Text('No account found'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🆔 ID: ${_account!.id}',
                    style: const TextStyle(fontSize: 18)),
                Text('💰 Amount: ${_account!.amount}',
                    style: const TextStyle(fontSize: 18)),
                Text('👤 Name: ${_account!.name}',
                    style: const TextStyle(fontSize: 18)),
                if (_account!.paymentDate != null)
                  Text(
                      '📅 Date: ${_account!.paymentDate!.toLocal()}',
                      style: const TextStyle(fontSize: 16)),
                if (_account!.paymentMode != null)
                  Text('💳 Mode: ${_account!.paymentMode}',
                      style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
