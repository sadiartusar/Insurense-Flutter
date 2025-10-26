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

  // --- Design Constants ---
  static const Color _primaryColor = Colors.teal; // মূল রঙ হিসেবে টিল ব্যবহার করা হয়েছে
  static const Color _secondaryColor = Colors.amber;
  static const Color _backgroundColor = Color(0xFFF0F4F8); // হালকা ব্যাকগ্রাউন্ড

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
        // ত্রুটি মেসেজ পরিষ্কার করার জন্য
        _error = 'Failed to load account: ${e.toString().contains('Exception:') ? e.toString().split('Exception:').last.trim() : 'Server Error'}';
        _loading = false;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    // আরও ব্যবহারকারী-বান্ধব ফরম্যাট
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  String _formatAmount(double amount) {
    // টাকা প্রতীক সহ উন্নত কারেন্সি ফরম্যাটিং
    final formatter = NumberFormat.currency(locale: 'bn_BD', symbol: '৳', decimalDigits: 2);
    return formatter.format(amount);
  }

  // --- Helper Widget for Detail Rows ---
  Widget _buildDetailRow(
      {required String title,
        required String value,
        required IconData icon,
        Color? iconColor,
        bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor ?? _primaryColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: isHighlight ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isHighlight ? 20 : 16,
                    fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
                    color: isHighlight ? _primaryColor : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Main Widget Builder ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('Account Details'),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _loadAccount,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _primaryColor))
          : _error != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text('$_error', textAlign: TextAlign.center, style: TextStyle(color: Colors.red.shade700, fontSize: 16)),
        ),
      )
          : _account == null
          ? const Center(
        child: Text(
          'No account found. Please check your user login status.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Account Balance Card (Highlight)
            _buildBalanceCard(_account!),

            const SizedBox(height: 20),

            // 2. Main Details Card
            _buildDetailsCard(_account!),
          ],
        ),
      ),
    );
  }

  // --- Balance Card Widget ---
  Widget _buildBalanceCard(AccountModel account) {
    return Card(
      elevation: 8,
      margin: EdgeInsets.zero,
      color: _primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Balance',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.monetization_on_outlined, color: _secondaryColor, size: 36),
                const SizedBox(width: 10),
                Text(
                  _formatAmount(account.amount),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // শেষ আপডেটের সময়
            // Text(
            //   'Last updated: ${_formatDate(account.updatedAt)}',
            //   style: const TextStyle(
            //     fontSize: 12,
            //     color: Colors.white54,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  // --- Details Card Widget ---
  Widget _buildDetailsCard(AccountModel account) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
            ),
            const Divider(height: 30, thickness: 1.5),

            // 1. Account ID
            _buildDetailRow(
              title: 'Account ID',
              value: account.id.toString(),
              icon: Icons.vpn_key_outlined,
              iconColor: Colors.deepOrange,
            ),
            const SizedBox(height: 8),

            // 2. Account Name
            _buildDetailRow(
              title: 'Account Name',
              value: account.name ?? 'N/A',
              icon: Icons.badge_outlined,
              iconColor: Colors.blue,
            ),

            // 3. User Details (if available)
            if (account.user != null) ...[
              const Divider(height: 30),
              Text(
                'User Profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _primaryColor,
                ),
              ),
              const SizedBox(height: 10),

              // User Email
              _buildDetailRow(
                title: 'Email Address',
                value: account.user!.email ?? 'N/A',
                icon: Icons.email_outlined,
              ),

              // User Phone
              _buildDetailRow(
                title: 'Phone Number',
                value: account.user!.phone ?? 'N/A',
                icon: Icons.phone_android_outlined,
              ),
            ],

            const Divider(height: 30),

            // 4. Creation Date
            // _buildDetailRow(
            //   title: 'Account Created On',
            //   value: _formatDate(account.createdAt),
            //   icon: Icons.calendar_today_outlined,
            //   iconColor: Colors.grey,
            // ),
          ],
        ),
      ),
    );
  }
}