import 'package:flutter/material.dart';
import 'package:general_insurance_management_system/service/payment_service.dart';

// কনস্ট্যান্ট স্টাইলিং (Const styling)
const Color primaryColor = Color(0xFF007BFF); // একটি আধুনিক নীল রঙ
const Color accentColor = Color(0xFF28A745); // সফলতার জন্য সবুজ রঙ

class DepositScreen extends StatelessWidget {
  // সার্ভিস এবং কন্ট্রোলার
  final PaymentService _paymentService = PaymentService();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  DepositScreen({super.key});

  // ডিপোজিট হ্যান্ডলিং ফাংশন
  void _handleDeposit(BuildContext context) async {
    final int? id = int.tryParse(_idController.text.trim());
    final double amount = double.tryParse(_amountController.text.trim()) ?? 0.0;

    // ইনপুট ভ্যালিডেশন
    if (id == null || id <= 0 || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('অনুগ্রহ করে সঠিক অ্যাকাউন্ট আইডি ও অর্থের পরিমাণ লিখুন।'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // লোডিং নির্দেশক দেখানো
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ডিপোজিট প্রক্রিয়া চলছে...'), duration: Duration(seconds: 1)),
    );

    try {
      // সার্ভিস কল
      String message = await _paymentService.depositMoney(id, amount);

      // সফল মেসেজ দেখানো
      ScaffoldMessenger.of(context).hideCurrentSnackBar(); // পূর্বের লোডিং মেসেজ লুকিয়ে
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('সফল! $message'),
          backgroundColor: accentColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      // সফল হলে ফিল্ড খালি করে দেওয়া
      _idController.clear();
      _amountController.clear();

    } catch (e) {
      // ত্রুটি মেসেজ দেখানো
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ত্রুটি: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // মূল বিল্ড ফাংশন
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('অ্যাকাউন্টে টাকা জমা করুন', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // ব্যাক বাটন সাদা করা
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // হেডার টেক্সট
            Text(
              'ডিপোজিট তথ্য',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 30),

            // অ্যাকাউন্ট আইডি ফিল্ড
            TextFormField(
              controller: _idController,
              decoration: InputDecoration(
                labelText: 'অ্যাকাউন্ট আইডি',
                hintText: 'আপনার অ্যাকাউন্ট নম্বর দিন',
                prefixIcon: const Icon(Icons.account_balance_wallet, color: primaryColor),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: primaryColor, width: 2),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 25),

            // ডিপোজিট অ্যামাউন্ট ফিল্ড
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'ডিপোজিট পরিমাণ',
                hintText: 'কত টাকা জমা করতে চান',
                prefixIcon: const Icon(Icons.attach_money, color: primaryColor),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: primaryColor, width: 2),
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 40),

            // ডিপোজিট বোতাম
            SizedBox(
              width: double.infinity, // পুরো প্রস্থ জুড়ে
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () => _handleDeposit(context),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text(
                  'ডিপোজিট নিশ্চিত করুন',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5, // সামান্য ছায়া যুক্ত করা
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}