import 'package:flutter/material.dart';
import 'package:general_insurance_management_system/model/account_model.dart';
import 'package:general_insurance_management_system/service/payment_service.dart';
import 'package:intl/intl.dart';

class AccountDetailsPage extends StatefulWidget {
  const AccountDetailsPage({super.key});

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
      final account = await _service.getLoggedInUserAccount();
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

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd-MM-yyyy hh:mm a').format(date);
  }

  String _formatAmount(double amount) {
    final formatter = NumberFormat.currency(locale: 'en', symbol: '৳');
    return formatter.format(amount);
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
                const SizedBox(height: 8),
                Text('👤 Name: ${_account!.name}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('💰 Amount: ${_formatAmount(_account!.amount)}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text(
                    '💳 Mode: ${_account!.paymentMode ?? 'N/A'}',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text(
                    '📅 Date: ${_formatDate(_account!.paymentDate)}',
                    style: const TextStyle(fontSize: 16)),
                if (_account!.user != null) ...[
                  const SizedBox(height: 8),
                  Text('📧 Email: ${_account!.user!.email}',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('📞 Phone: ${_account!.user!.phone}',
                      style: const TextStyle(fontSize: 16)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
