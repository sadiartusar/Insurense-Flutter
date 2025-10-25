import 'package:flutter/material.dart';
import 'package:general_insurance_management_system/model/firemoneyreceipt_model.dart';
import 'package:general_insurance_management_system/service/auth_service.dart';
import 'package:general_insurance_management_system/service/http_service.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:ui'; // BackdropFilter এর জন্য

class PrintFireMoneyReceipt extends StatelessWidget {
  final FireMoneyReceiptModel moneyreceipt;

  const PrintFireMoneyReceipt({super.key, required this.moneyreceipt});

  // কনস্ট্যান্টগুলি অপরিবর্তিত
  static const double _defaultFontSize = 14;

  double get _sumInsured => moneyreceipt.fireBill?.firePolicy.sumInsured ?? 0.0;
  double get _fireRate => moneyreceipt.fireBill?.fire ?? 0.0;
  double get _rsdRate => moneyreceipt.fireBill?.rsd ?? 0.0;
  double get _taxRate => moneyreceipt.fireBill?.tax ?? 0.0;
  double get _totalFire => _fireRate * _sumInsured;
  double get _totalRsd => _rsdRate * _sumInsured;
  double get _totalNetPremium => _totalFire + _totalRsd;
  double get _totalTax => _totalNetPremium * _taxRate;
  double get _totalGrossPremiumWithTax => _totalNetPremium + _totalTax;
  double get _monthlyPayableAmount => _totalGrossPremiumWithTax / 12;

  String _formatDate(DateTime? date) =>
      date != null ? DateFormat('dd-MM-yyyy').format(date) : "N/A";

  // PDF লজিক অপরিবর্তিত
  Future<pw.Document> _generatePdf(BuildContext context) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Center(
          child: pw.Text(
            "Fire Cover Note\n\nPolicyholder: ${moneyreceipt.fireBill?.firePolicy.policyholder ?? 'N/A'}\nSum Insured: ${_sumInsured.toStringAsFixed(2)} TK\nGross Premium: ${_totalGrossPremiumWithTax.toStringAsFixed(2)} TK",
          ),
        ),
      ),
    );
    return pdf;
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold এবং body এর স্ট্রাকচার রেসপনসিভ আছে
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
              title: "Bill & Insured Information",
              icon: Icons.assignment_ind_outlined,
              children: [
                _buildCardRow(context, 'Cover Note No:',
                    moneyreceipt.issuedAgainst ?? "N/A",
                    isBold: true),
                _buildCardRow(context, 'Policyholder:',
                    moneyreceipt.fireBill?.firePolicy.policyholder ?? "N/A",
                    isBold: true),
                _buildCardRow(context, 'Sum Insured:',
                    '${_sumInsured.toStringAsFixed(2)} TK'),
              ],
            ),
            const SizedBox(height: 16),
            _buildTotalSummaryCard(context),
            const SizedBox(height: 20),
            // ✅ Row এর পরিবর্তে Column ব্যবহার করা হয়েছে যাতে ছোট স্ক্রিনে বাটন ওভারফ্লো না করে
            _buildActionButtons(context),
            const SizedBox(height: 10),
            _buildSendButton(context),
          ],
        ),
      ),
    );
  }

  /// ✅ Send Button — Admin selects user email and sends data
  Widget _buildSendButton(BuildContext context) {
    // এই লজিকটি ডেটাবেস অপারেশন এবং ডায়ালগ ডিসপ্লে এর জন্য, যা স্ক্রিন সাইজের উপর নির্ভরশীল নয়
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
                    // ... (API কল লজিক অপরিবর্তিত) ...
                    if (selectedEmail != null) {
                      final dataToSend = {
                        "recipientEmail": selectedEmail,
                        "coverNoteNo": moneyreceipt.issuedAgainst ?? "N/A",
                        "policyholder": moneyreceipt.fireBill?.firePolicy.policyholder ?? "N/A",
                        "sumInsured": _sumInsured,
                        "grossPremium": _totalGrossPremiumWithTax,
                        "monthlyPremium": _monthlyPayableAmount,
                        "fireRate": _fireRate,
                        "rsdRate": _rsdRate,
                        "taxRate": _taxRate,
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
    // এই কার্ডটি স্ক্রিনের প্রস্থ অনুযায়ী নিজে থেকেই রেসপনসিভ হবে
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
                  // টেক্সট ওভারফ্লো এড়াতে Flexible ব্যবহার করা যেতে পারে, তবে সাধারণত হেডার টেক্সট ছোট হয়
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

  // ✅ রেসপনসিভ ফিক্স: Long value text overflow এড়াতে Expanded/Flexible ব্যবহার করা হয়েছে
  Widget _buildCardRow(BuildContext context, String title, String value,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start, // লম্বা টেক্সট এর জন্য
        children: [
          // টাইটেল এর জন্য সীমিত প্রস্থ (উদাহরণস্বরূপ 50% বা তার কম)
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.4, // প্রায় 40% স্ক্রিন
            child: Text(title,
                style: TextStyle(
                    fontSize: _defaultFontSize,
                    fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
                    color: Colors.grey.shade700)),
          ),
          // ভ্যালুর জন্য বাকি স্পেস
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
          _buildTotalRow(context, 'GROSS PREMIUM (with Tax)',
              _totalGrossPremiumWithTax, isFinal: true),
          const Divider(height: 20, thickness: 1.5, color: Colors.deepPurple),
          _buildTotalRow(
              context, 'MONTHLY PAYABLE AMOUNT', _monthlyPayableAmount,
              isMonthly: true),
        ],
      ),
    );
  }

  // ✅ রেসপনসিভ ফিক্স: Long title text overflow এড়াতে Row কে Flexible/Expanded দিয়ে সুরক্ষিত করা
  Widget _buildTotalRow(BuildContext context, String title, double amount,
      {bool isFinal = false, bool isMonthly = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // টাইটেল ওভারফ্লো এড়াতে Flexible
        Flexible(
          child: Text(title,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isFinal
                      ? Colors.deepPurple.shade800
                      : (isMonthly ? Colors.green.shade700 : Colors.black87))),
        ),
        const SizedBox(width: 8), // টেক্সটের মাঝখানে সামান্য গ্যাপ
        // অ্যামাউন্ট ফিক্সড, কিন্তু টেক্সট ওভারফ্লো এড়াতে দরকার
        Text('${amount.toStringAsFixed(2)} TK',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isFinal
                    ? Colors.deepPurple.shade800
                    : (isMonthly ? Colors.green.shade700 : Colors.black))),
      ],
    );
  }

  // ✅ রেসপনসিভ ফিক্স: ছোট স্ক্রিনে বাটনগুলিকে উল্লম্বভাবে সাজানো (Vertical Layout)
  Widget _buildActionButtons(BuildContext context) {
    // 600 পিক্সেলের নিচে গেলে Column ব্যবহার করা
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
      // 600 পিক্সেল বা তার উপরে গেলে পাশাপাশি (Horizontal Layout)
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

  // বাটন তৈরি করার জন্য Helper function
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