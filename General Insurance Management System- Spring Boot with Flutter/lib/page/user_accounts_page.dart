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
  final _balanceIdController = TextEditingController();

  final PaymentService _service = PaymentService();

  List<Payment> _payments = [];
  double? _balance;
  bool _loading = false;

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    _senderController.dispose();
    _receiverController.dispose();
    _amountController.dispose();
    _balanceIdController.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    if (_senderController.text.trim().isEmpty ||
        _receiverController.text.trim().isEmpty ||
        _amountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all payment fields')),
      );
      return;
    }

    final senderId = int.tryParse(_senderController.text);
    final receiverId = int.tryParse(_receiverController.text);
    final amount = double.tryParse(_amountController.text);

    if (senderId == null || receiverId == null || amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid input: IDs must be numbers, amount must be numeric')),
      );
      return;
    }

    setState(() => _loading = true);

    bool success = await _service.payPremium(
      senderId: senderId,
      receiverId: receiverId,
      amount: amount,
    );

    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? '✅ Payment successful' : '❌ Payment failed')),
    );
  }

  Future<void> _getBalance() async {
    if (_balanceIdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter User ID to check balance')),
      );
      return;
    }

    final userId = int.tryParse(_balanceIdController.text);
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid User ID')),
      );
      return;
    }

    setState(() => _loading = true);
    final bal = await _service.getBalance(userId);
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
            const Text(
              '💳 Pay Premium',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _senderController,
              decoration: const InputDecoration(labelText: 'Sender ID'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _receiverController,
              decoration: const InputDecoration(labelText: 'Receiver ID'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _pay, child: const Text('Pay')),

            const Divider(),

            const Text(
              '📊 Check Balance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _balanceIdController,
              decoration: const InputDecoration(labelText: 'User ID'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _getBalance, child: const Text('Get Balance')),
            if (_balance != null) Text('Balance: $_balance'),

            const Divider(),

            const Text(
              '📜 All Payments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
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
