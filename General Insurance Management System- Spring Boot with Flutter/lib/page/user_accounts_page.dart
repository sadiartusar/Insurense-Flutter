

import 'package:flutter/material.dart';
import 'package:general_insurance_management_system/model/payment_model.dart';
import 'package:general_insurance_management_system/service/payment_service.dart';

class UserAccountsPage extends StatefulWidget {

  const UserAccountsPage({super.key});

  @override
  State<UserAccountsPage> createState() => _UserAccountsPageState();
}

class _UserAccountsPageState extends State<UserAccountsPage> {
  final _senderController = TextEditingController();
  final _receiverController = TextEditingController();
  final _amountController = TextEditingController();
  final _depositAmountController = TextEditingController();
  final _balanceIdController = TextEditingController();

  final PaymentService _service = PaymentService();

  List<Payment> _payments = [];
  double? _balance;
  bool _loading = false;

  @override
  void initState() {
    super.initState();

  }

  Future<void> _pay() async {
    setState(() => _loading = true);
    bool success = await _service.payPremium(
      senderId: int.parse(_senderController.text),
      receiverId: int.parse(_receiverController.text),
      amount: double.parse(_amountController.text),
    );
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(success ? '✅ Payment successful' : '❌ Payment failed'),
    ));
  }

  Future<void> _deposit() async {
    setState(() => _loading = true);
    bool success = await _service.deposit(
      id: int.parse(_senderController.text),
      amount: double.parse(_depositAmountController.text),
    );
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(success ? '✅ Deposit successful' : '❌ Deposit failed'),
    ));
  }

  Future<void> _getBalance() async {
    setState(() => _loading = true);
    final bal = await _service.getBalance(int.parse(_balanceIdController.text));
    setState(() {
      _balance = bal;
      _loading = false;
    });
  }

  Future<void> _loadPayments() async {
    setState(() => _loading = true);
    final payments = await _service.getAllPayments();
    setState(() {
      _payments = payments ?? [];
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DAO Operations')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('💳 Pay Premium', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(controller: _senderController, decoration: const InputDecoration(labelText: 'Sender ID')),
            TextField(controller: _receiverController, decoration: const InputDecoration(labelText: 'Receiver ID')),
            TextField(controller: _amountController, decoration: const InputDecoration(labelText: 'Amount')),
            ElevatedButton(onPressed: _pay, child: const Text('Pay')),

            const Divider(),

            const Text('🏦 Deposit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(controller: _depositAmountController, decoration: const InputDecoration(labelText: 'Deposit Amount')),
            ElevatedButton(onPressed: _deposit, child: const Text('Deposit')),

            const Divider(),

            const Text('📊 Check Balance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(controller: _balanceIdController, decoration: const InputDecoration(labelText: 'User ID')),
            ElevatedButton(onPressed: _getBalance, child: const Text('Get Balance')),
            if (_balance != null) Text('Balance: $_balance'),

            const Divider(),

            const Text('📜 All Payments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ElevatedButton(onPressed: _loadPayments, child: const Text('Load Payment History')),
            ..._payments.map((p) => ListTile(
              title: Text('Amount: ${p.amount} | Mode: ${p.paymentMode}'),
              subtitle: Text('By: ${p.user.name} on ${p.paymentDate.toLocal()}'),
            )),
          ],
        ),
      ),
    );
  }
}
