

import 'package:flutter/material.dart';
import 'package:general_insurance_management_system/service/payment_service.dart';


class DepositScreen extends StatelessWidget {
  final PaymentService _paymentService = PaymentService();
  final TextEditingController _idController = TextEditingController(text: '0'); // উদাহরণ ID
  final TextEditingController _amountController = TextEditingController(text: '0'); // উদাহরণ অ্যামাউন্ট

  DepositScreen({super.key});

  void _handleDeposit(BuildContext context) async {
    final int? id = int.tryParse(_idController.text);
    final double amount = double.tryParse(_amountController.text) ?? 0.0;

    if (id == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid ID and Amount')),
      );
      return;
    }

    try {
      String message = await _paymentService.depositMoney(id, amount);
      // সফল মেসেজ দেখানো
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Success: $message')),
      );
    } catch (e) {
      // ত্রুটি মেসেজ দেখানো
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Deposit Money')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _idController, decoration: const InputDecoration(labelText: 'Account ID')),
            TextField(controller: _amountController, decoration: const InputDecoration(labelText: 'Deposit Amount'), keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _handleDeposit(context),
              child: const Text('Deposit'),
            ),
          ],
        ),
      ),
    );
  }
}