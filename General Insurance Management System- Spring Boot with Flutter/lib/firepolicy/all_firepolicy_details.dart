import 'package:flutter/material.dart';
import 'package:general_insurance_management_system/model/firepolicy_model.dart';
import 'package:intl/intl.dart';

class AllFirePolicyDetails extends StatelessWidget {
  final PolicyModel policy;

  const AllFirePolicyDetails({super.key, required this.policy});

  static const double _fontSize = 15;
  static const double _titleSize = 18;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- AppBar: Unchanged Gradient for a vibrant look ---
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.greenAccent,
                Colors.deepOrangeAccent,
                Colors.cyan,
                Colors.amber,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            title: const Text(
              'Fire Policy Details',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
        ),
      ),

      // --- Body: Softer, Professional Gradient Background ---
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blueGrey.shade50,
              Colors.lightBlue.shade50,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Bill & Date Header
                _buildHeaderCard(context),
                const SizedBox(height: 16),

                // 2. Insured & Contact Details Card
                _buildDetailsCard(
                  context,
                  title: "Insured & Contact Details",
                  icon: Icons.person_pin_circle_outlined,
                  children: [
                    _buildDetailRow('Bank Name:', policy.bankName ?? 'Unnamed'),
                    _buildDetailRow(
                        'Policyholder:', policy.policyholder ?? 'N/A'),
                    _buildDetailRow(
                        'Address:', policy.address ?? 'No address',
                        isLongText: true),
                  ],
                ),
                const SizedBox(height: 16),

                // 3. Sum Insured & Coverage Card
                _buildDetailsCard(
                  context,
                  title: "Sum & Coverage",
                  icon: Icons.monetization_on_outlined,
                  children: [
                    // Highlighted Sum Insured
                    _buildDetailRow(
                      'Sum Insured:',
                      'TK ${policy.sumInsured?.toString() ?? 'No sum'}',
                      isHighlighted: true,
                    ),
                    _buildDetailRow(
                        'Stock Insured:', policy.stockInsured ?? 'N/A'),
                    _buildDetailRow(
                        'Interest Insured:', policy.interestInsured ?? 'N/A'),
                    _buildDetailRow('Coverage:', policy.coverage ?? 'N/A'),
                  ],
                ),
                const SizedBox(height: 16),

                // 4. Situation & Period Card
                _buildDetailsCard(
                  context,
                  title: "Situation & Policy Period",
                  icon: Icons.business_outlined,
                  children: [
                    _buildDetailRow('Location:', policy.location ?? 'N/A',
                        isLongText: true),
                    _buildDetailRow(
                        'Construction:', policy.construction ?? 'N/A'),
                    _buildDetailRow('Owner:', policy.owner ?? 'N/A'),
                    _buildDetailRow('Used As:', policy.usedAs ?? 'N/A'),
                    const Divider(height: 20),
                    _buildDetailRow(
                        'Period From:', formatDate(policy.periodFrom),
                        isBold: true),
                    _buildDetailRow('Period To:', formatDate(policy.periodTo),
                        isBold: true),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  /// বিল নম্বর এবং তারিখ দেখানোর জন্য একটি হালকা কার্ড
  Widget _buildHeaderCard(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.vpn_key,
                    color: Colors.blue.shade700, size: _fontSize + 4),
                const SizedBox(width: 8),
                Text(
                  'Bill No: ${policy.id?.toString() ?? 'No ID'}',
                  style: TextStyle(
                      fontSize: _fontSize + 2, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    color: Colors.red.shade700, size: _fontSize + 2),
                const SizedBox(width: 8),
                Text(
                  'Date: ${formatDate(policy.date)}',
                  style: TextStyle(fontSize: _fontSize, color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// সাধারণ তথ্যের কার্ড তৈরি করার জন্য একটি হেল্পার ফাংশন
  Widget _buildDetailsCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required List<Widget> children,
      }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.deepPurple, size: _titleSize + 2),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: _titleSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),
            ...children,
          ],
        ),
      ),
    );
  }

  /// প্রতিটি তথ্যের সারি তৈরির জন্য স্মার্ট হেল্পার ফাংশন
  Widget _buildDetailRow(String title, String value,
      {bool isHighlighted = false, bool isBold = false, bool isLongText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: isLongText ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title (Left Side)
          Text(
            title,
            style: TextStyle(
              fontSize: _fontSize,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(width: 10),
          // Value (Right Side)
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: isHighlighted ? _fontSize + 2 : _fontSize,
                fontWeight: isHighlighted || isBold ? FontWeight.bold : FontWeight.w500,
                color: isHighlighted ? Colors.green.shade700 : Colors.black87,
              ),
              maxLines: isLongText ? 3 : 2, // Allow more lines for address
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // --- Utility Function (Unchanged) ---
  String formatDate(DateTime? dateTime) {
    if (dateTime == null) {
      return "N/A";
    }
    return DateFormat('dd-MM-yyyy').format(dateTime);
  }
}