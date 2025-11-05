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

  final List<Payment> _payments = [];
  double? _balance;
  bool _loading = false;
  // নতুন স্টেট: বর্তমানে কোন অ্যাকশনটি লোড হচ্ছে তা বোঝানোর জন্য
  String? _currentAction;

  // --- Theme/Style Constants ---
  static const Color _primaryColor = Colors.deepPurple;
  static const Color _secondaryColor = Colors.amber;
  static const Color _backgroundColor = Color(0xFFF5F5F5);

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    _senderController.dispose();
    _receiverController.dispose();
    _amountController.dispose();
    _balanceIdController.dispose();
    super.dispose();
  }

  // --- Payment Logic ---
  Future<void> _pay() async {
    if (_senderController.text.trim().isEmpty ||
        _receiverController.text.trim().isEmpty ||
        _amountController.text.trim().isEmpty) {
      _showSnackBar('Please fill all payment fields', isError: true);
      return;
    }

    final senderId = int.tryParse(_senderController.text);
    final receiverId = int.tryParse(_receiverController.text);
    final amount = double.tryParse(_amountController.text);

    if (senderId == null || receiverId == null || amount == null) {
      _showSnackBar('Invalid input: IDs must be numbers, amount must be numeric', isError: true);
      return;
    }

    setState(() {
      _loading = true;
      _currentAction = 'pay';
    });

    bool success = await _service.payPremium(
      senderId: senderId,
      receiverId: receiverId,
      amount: amount,
    );

    setState(() {
      _loading = false;
      _currentAction = null;
    });

    if (success) {
      _showSnackBar('✅ Payment successful');
      _senderController.clear();
      _receiverController.clear();
      _amountController.clear();
    } else {
      _showSnackBar('❌ Payment failed. Check your balance or network.', isError: true);
    }
  }

  // --- Helper Functions ---
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --- Smart Input Field Widget ---
  Widget _buildSmartTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: _primaryColor),
          prefixIcon: Icon(icon, color: _primaryColor.withOpacity(0.7)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _primaryColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _primaryColor, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _primaryColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  // --- Main Widget Builder ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('User Account Operations'),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Payment Card
            _buildPaymentCard(),

            const SizedBox(height: 30),

          ],
        ),
      ),
    );
  }

  // --- Widget for Pay Premium Section ---
  Widget _buildPaymentCard() {
    final isPaying = _loading && _currentAction == 'pay';
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.payment, color: _primaryColor, size: 28),
                const SizedBox(width: 10),
                const Text(
                  'Pay Premium',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
              ],
            ),
            const Divider(height: 25, thickness: 1.5),

            // Sender ID
            _buildSmartTextField(
              controller: _senderController,
              label: 'Sender Account ID (Your ID)',
              icon: Icons.person_outline,
              keyboardType: TextInputType.number,
            ),
            // Receiver ID
            _buildSmartTextField(
              controller: _receiverController,
              label: 'Receiver Account ID (Company ID)',
              icon: Icons.business,
              keyboardType: TextInputType.number,
            ),
            // Amount
            _buildSmartTextField(
              controller: _amountController,
              label: 'Amount (Premium)',
              icon: Icons.attach_money,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 20),

            // Pay Button
            ElevatedButton(
              onPressed: isPaying ? null : _pay,
              style: ElevatedButton.styleFrom(
                backgroundColor: _secondaryColor,
                foregroundColor: _primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 4,
              ),
              child: isPaying
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: _primaryColor,
                  strokeWidth: 3,
                ),
              )
                  : const Text(
                'Execute Payment',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Action Placeholder Widget (for future functionality) ---
  Widget _buildActionPlaceholder(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _primaryColor),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: _primaryColor),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: _primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}