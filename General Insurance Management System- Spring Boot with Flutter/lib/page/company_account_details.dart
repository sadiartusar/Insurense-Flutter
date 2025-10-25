// page/company_volt_details_page.dart

import 'package:flutter/material.dart';
import 'package:general_insurance_management_system/service/http_service.dart';
import 'package:general_insurance_management_system/service/payment_service.dart';

class CompanyVoltDetailsPage extends StatefulWidget {
  const CompanyVoltDetailsPage({super.key});

  @override
  State<CompanyVoltDetailsPage> createState() => _CompanyVoltDetailsPageState();
}

class _CompanyVoltDetailsPageState extends State<CompanyVoltDetailsPage> {
  late Future<List<Map<String, dynamic>>> _voltDetailsFuture;

  @override
  void initState() {
    super.initState();
    // পেজ লোড হওয়ার সাথে সাথেই ডেটা ফেচ করা
    _voltDetailsFuture = PaymentService().fetchCompanyVoltDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Volt Account Details'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _voltDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error.toString()}\nCheck Admin Token and API path.')
            );
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text('No company account details found.'));
          } else {
            final detailsList = snapshot.data!;

            // যেহেতু আপনার এনটিটিটি 'Volt Account' তাই ধরে নিচ্ছি সাধারণত একটিই থাকে,
            // তবুও আমরা পুরো লিস্টটি ডিসপ্লে করছি।
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: detailsList.length,
              itemBuilder: (context, index) {
                final detail = detailsList[index];
                return _buildVoltAccountCard(detail);
              },
            );
          }
        },
      ),
    );
  }

  // UI Helper Widget
  Widget _buildVoltAccountCard(Map<String, dynamic> detail) {
    // এখানে 'name', 'balance', 'id' Spring Boot থেকে JSON এর Key হিসেবে আসছে
    final String name = detail['name'] ?? 'N/A';
    final double balance = detail['balance'] ?? 0.0;
    final int id = detail['id'] ?? 0;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo),
            ),
            const Divider(height: 15),
            _buildDetailRow('Account ID', id.toString()),
            _buildDetailRow('Current Balance', '${balance.toStringAsFixed(2)} TK', isBalance: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value, {bool isBalance = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 15, color: Colors.grey.shade700)),
          Text(value, style: TextStyle(
            fontSize: 16,
            fontWeight: isBalance ? FontWeight.w900 : FontWeight.w600,
            color: isBalance ? Colors.green.shade700 : Colors.black87,
          )),
        ],
      ),
    );
  }
}