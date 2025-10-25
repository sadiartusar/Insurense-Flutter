import 'package:flutter/material.dart';
import 'package:general_insurance_management_system/model/firemoneyreceipt_model.dart';
import 'package:general_insurance_management_system/service/auth_service.dart';
import 'package:general_insurance_management_system/service/http_service.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:ui';

class PrintFireMoneyReceipt extends StatelessWidget {
  final FireMoneyReceiptModel moneyreceipt;

  const PrintFireMoneyReceipt({super.key, required this.moneyreceipt});

  static const double _defaultFontSize = 14;

  // *******************************************************************
  // ✅ FIX: গণনার লজিক পরিবর্তন করা হলো।
  // API থেকে সরাসরি প্রিমিয়াম মানগুলো ব্যবহার করা হচ্ছে।
  // *******************************************************************

  double get _sumInsured => moneyreceipt.fireBill?.firePolicy.sumInsured ?? 0.0;

  // API থেকে আসা সরাসরি মানগুলো ব্যবহার করা হয়েছে:
  double get _firePremium => moneyreceipt.fireBill?.fire ?? 0.0;
  double get _rsdPremium => moneyreceipt.fireBill?.rsd ?? 0.0;
  double get _netPremium => moneyreceipt.fireBill?.netPremium ?? 0.0;
  double get _taxAmount => moneyreceipt.fireBill?.tax ?? 0.0;
  double get _grossPremium => moneyreceipt.fireBill?.grossPremium ?? 0.0;

  // মাসিক প্রিমিয়াম গণনা (Gross Premium-কে 12 দিয়ে ভাগ করা হয়েছে)
  double get _monthlyPayableAmount => _grossPremium / 12.0;

  // *******************************************************************

  String _formatDate(DateTime? date) =>
      date != null ? DateFormat('dd-MM-yyyy').format(date) : "N/A";

  // এই ফাংশনটি শুধু ফরমেটিং এর জন্য, গণনা নয়।
  // তাই এটি নিরাপদভাবে ব্যবহার করা যাবে।
  String _formatCurrency(double amount) {
    // Tk. বা Taka প্রতীক সহ 2 দশমিক স্থান পর্যন্ত ফরমেট করা হলো
    return NumberFormat.currency(
      locale: 'en_US',
      symbol: 'TK',
      decimalDigits: 2,
    ).format(amount);
  }

  // PDF লজিক আপডেট করা হলো
  Future<pw.Document> _generatePdf(BuildContext context) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Center(
          child: pw.Text(
            "Fire Cover Note\n\nPolicyholder: ${moneyreceipt.fireBill?.firePolicy.policyholder ?? 'N/A'}\nSum Insured: ${_formatCurrency(_sumInsured)}\nGross Premium: ${_formatCurrency(_grossPremium)}",
          ),
        ),
      ),
    );
    return pdf;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fire Cover Note Details'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSmartCard(
              context,
              title: "Premium Breakdown",
              icon: Icons.calculate_outlined,
              children: [
                _buildCardRow(context, 'Fire Premium:',
                    _formatCurrency(_firePremium)),
                _buildCardRow(context, 'RSD Premium:',
                    _formatCurrency(_rsdPremium)),
                _buildCardRow(context, 'Net Premium:',
                    _formatCurrency(_netPremium),
                    isBold: true),
                _buildCardRow(context, 'Tax Amount:',
                    _formatCurrency(_taxAmount)),
              ],
            ),
            const SizedBox(height: 16),
            _buildSmartCard(
              context,
              title: "Policy & Insured Information",
              icon: Icons.assignment_ind_outlined,
              children: [
                _buildCardRow(context, 'Cover Note No:',
                    moneyreceipt.issuedAgainst ?? "N/A",
                    isBold: true),
                _buildCardRow(context, 'Policyholder:',
                    moneyreceipt.fireBill?.firePolicy.policyholder ?? "N/A",
                    isBold: true),
                _buildCardRow(context, 'Sum Insured:',
                    _formatCurrency(_sumInsured)),
              ],
            ),
            const SizedBox(height: 16),
            // ফিক্সড মান ব্যবহার করে সামারি কার্ড
            _buildTotalSummaryCard(context),
            const SizedBox(height: 20),
            _buildActionButtons(context),
            const SizedBox(height: 10),
            _buildSendButton(context),
          ],
        ),
      ),
    );
  }

  /// Send Button
  Widget _buildSendButton(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.send),
      label: const Text('Send to User'),
      onPressed: () async {
        final users = await AuthService().fetchAllUsers();
        String? selectedEmail;

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Select User to Send Data"),
              content: DropdownButtonFormField<String>(
                hint: const Text("Select user email"),
                items: users.map((u) {
                  return DropdownMenuItem(
                    value: u.email,
                    child: Text(u.email ?? "unknown"),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedEmail = value;
                },
              ),
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  child: const Text("Send"),
                  onPressed: () async {
                    if (selectedEmail != null) {
                      final dataToSend = {
                        "recipientEmail": selectedEmail,
                        "coverNoteNo": moneyreceipt.issuedAgainst ?? "N/A",
                        "policyholder": moneyreceipt.fireBill?.firePolicy.policyholder ?? "N/A",
                        "sumInsured": _sumInsured,
                        "grossPremium": _grossPremium, // ✅ ফিক্সড ভ্যালু
                        "monthlyPremium": _monthlyPayableAmount, // ✅ ফিক্সড ভ্যালু
                        // "fireRate": moneyreceipt.fireBill?.fire ?? 0.0, // রেট নয়, অ্যামাউন্ট
                        // "rsdRate": moneyreceipt.fireBill?.rsd ?? 0.0,
                        // "taxRate": moneyreceipt.fireBill?.tax ?? 0.0,
                        "issuedAt": DateTime.now().toIso8601String(),
                      };

                      try {
                        await HttpService().sendCoverNote(dataToSend);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text("Data sent successfully to $selectedEmail ✅"),
                              backgroundColor: Colors.green),
                        );
                      } catch (e) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text("Failed to send data: ${e.toString()} ❌"),
                              backgroundColor: Colors.red),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please select a user email.")),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ------- Smart UI helper widgets ---------
  Widget _buildSmartCard(BuildContext context,
      {required String title, required IconData icon, required List<Widget> children}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5))
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.deepPurple, size: 24),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      title,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20, thickness: 1),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardRow(BuildContext context, String title, String value,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            child: Text(title,
                style: TextStyle(
                    fontSize: _defaultFontSize,
                    fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
                    color: Colors.grey.shade700)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                  fontSize: _defaultFontSize,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                  color: color ?? Colors.black87),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSummaryCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.deepPurple.shade100),
      ),
      child: Column(
        children: [
          // ✅ FIX: _grossPremium ব্যবহার করা হয়েছে
          _buildTotalRow(context, 'GROSS PREMIUM (with Tax)',
              _grossPremium, isFinal: true),
          const Divider(height: 20, thickness: 1.5, color: Colors.deepPurple),
          // ✅ FIX: _monthlyPayableAmount ব্যবহার করা হয়েছে
          _buildTotalRow(
              context, 'MONTHLY PAYABLE AMOUNT', _monthlyPayableAmount,
              isMonthly: true),
        ],
      ),
    );
  }

  Widget _buildTotalRow(BuildContext context, String title, double amount,
      {bool isFinal = false, bool isMonthly = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(title,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isFinal
                      ? Colors.deepPurple.shade800
                      : (isMonthly ? Colors.green.shade700 : Colors.black87))),
        ),
        const SizedBox(width: 8),
        // ✅ ফিক্সড কারেন্সি ফরমেটিং ব্যবহার করা হয়েছে
        Text(_formatCurrency(amount),
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isFinal
                    ? Colors.deepPurple.shade800
                    : (isMonthly ? Colors.green.shade700 : Colors.black))),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (MediaQuery.of(context).size.width < 600) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildActionButton(
              icon: Icons.download,
              label: 'Download PDF',
              color: Colors.blue.shade700,
              onPressed: () async {
                final pdf = await _generatePdf(context);
                await Printing.sharePdf(
                  bytes: await pdf.save(),
                  filename: 'fire_bill_covernote.pdf',
                );
              }),
          const SizedBox(height: 10),
          _buildActionButton(
              icon: Icons.print,
              label: 'Print View',
              color: Colors.purple.shade700,
              onPressed: () async {
                await Printing.layoutPdf(
                  onLayout: (format) async => (await _generatePdf(context)).save(),
                );
              }),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: _buildActionButton(
                icon: Icons.download,
                label: 'Download PDF',
                color: Colors.blue.shade700,
                onPressed: () async {
                  final pdf = await _generatePdf(context);
                  await Printing.sharePdf(
                    bytes: await pdf.save(),
                    filename: 'fire_bill_covernote.pdf',
                  );
                }),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildActionButton(
                icon: Icons.print,
                label: 'Print View',
                color: Colors.purple.shade700,
                onPressed: () async {
                  await Printing.layoutPdf(
                    onLayout: (format) async => (await _generatePdf(context)).save(),
                  );
                }),
          ),
        ],
      );
    }
  }

  Widget _buildActionButton(
      {required IconData icon,
        required String label,
        required Color color,
        required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}