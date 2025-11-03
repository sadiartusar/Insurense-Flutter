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

  String _convertToWords(double num) {
    // (Unchanged logic for number to words)
    const ones = [
      "", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine",
      "Ten", "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen",
      "Seventeen", "Eighteen", "Nineteen"
    ];
    const tens = [
      "", "", "Twenty", "Thirty", "Forty", "Fifty", "Sixty", "Seventy",
      "Eighty", "Ninety"
    ];

    String words(int n) {
      if (n == 0) return "";
      if (n < 20) return ones[n];
      if (n < 100) return '${tens[n ~/ 10]}${n % 10 != 0 ? " ${ones[n % 10]}" : ""}}';
      if (n < 1000) return '${ones[n ~/ 100]} Hundred${n % 100 != 0 ? " ${words(n % 100)}" : ""}';
      if (n < 1000000) return '${words(n ~/ 1000)} Thousand${n % 1000 != 0 ? " ${words(n % 1000)}" : ""}';
      if (n < 1000000000) return '${words(n ~/ 1000000)} Million${n % 1000000 != 0 ? " ${words(n % 1000000)}" : ""}';
      return "";
    }

    final intPart = num.toInt();
    final decimalPart = ((num - intPart) * 100).toInt();

    var result = words(intPart).trim();

    if (decimalPart > 0) {
      result += " Taka and ${words(decimalPart)} Point";
    } else {
      result += " Taka";
    }

    return result.trim().isEmpty ? "Zero Taka" : result.trim();
  }

  pw.Widget _buildHeader() { /* ... unchanged ... */
    return pw.Center(
      child: pw.Column(
        children: [
          pw.Text(
            "Green Insurance Company Bangladesh Ltd",
            style:
            pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text("DR Tower (14th floor), 65/2/2, Purana Paltan, Dhaka-1000."),
          pw.Text("Tel: 02478853405 | Mob: 01763001787"),
          pw.Text("Fax: +88 02 55112742"),
          pw.Text("Email: info@ciclbd.com"),
          pw.Text("Web: www.greeninsurance.com"),
        ],
      ),
    );
  }


  String _formatCurrency(double amount) {

    return NumberFormat.currency(
      locale: 'en_US',
      symbol: 'TK',
      decimalDigits: 2,
    ).format(amount);
  }

  // PDF লজিক আপডেট করা হলো
  // Future<pw.Document> _generatePdf(BuildContext context) async {
  //   final pdf = pw.Document();
  //   pdf.addPage(
  //     pw.Page(
  //       pageFormat: PdfPageFormat.a4,
  //       build: (context) => pw.Center(
  //         child: pw.Text(
  //           "Fire Cover Note\n\nPolicyholder: ${moneyreceipt.fireBill?.firePolicy.policyholder ?? 'N/A'}\nSum Insured: ${_formatCurrency(_sumInsured)}\nGross Premium: ${_formatCurrency(_grossPremium)}",
  //         ),
  //       ),
  //     ),
  //   );
  //   return pdf;
  // }

  Future<pw.Document> _generatePdf(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            pw.SizedBox(height: 5),
            _buildFireBillInfo(),
            _buildInsuredDetails(),
            _buildInsuredCondition(),
            _buildSumInsuredDetails(),
            _buildSituationDetails(),
            _buildPremiumAndTaxDetails(),
            pw.SizedBox(height: 20),
            _buildFooterDetails(),
          ],
        ),
      ),
    );

    return pdf;
  }

  pw.Widget _buildFireBillInfo() { /* ... unchanged ... */
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text("Fire Cover Note", style: _headerTextStyle()),
        pw.SizedBox(height: 10),
        pw.Table.fromTextArray(
          data: [
            [
              'Fire Cover Note No', moneyreceipt.issuedAgainst ?? "N/A",
              'Fire Bill No', moneyreceipt.fireBill?.firePolicy.id?.toString() ?? "N/A",
              'Date', _formatDate(moneyreceipt.fireBill?.firePolicy.date),
            ],
          ],
        ),
      ],
    );
  }

  pw.Widget _buildInsuredDetails() { /* ... unchanged ... */
    final policy = moneyreceipt.fireBill?.firePolicy;
    final addressDetails = '${policy?.bankName ?? "N/A"}\n'
        '${policy?.policyholder ?? "N/A"}\n'
        '${policy?.address ?? "N/A"}';

    return pw.Table.fromTextArray(
      data: [
        [
          'The Insured Name & Address',
          addressDetails,
        ],
      ],
    );
  }

  pw.Widget _buildInsuredCondition() { /* ... unchanged ... */
    final policy = moneyreceipt.fireBill?.firePolicy;
    final sumInsuredInWords = _convertToWords(policy?.sumInsured ?? 0.0);

    return pw.Table.fromTextArray(
      data: [
        [
          'Having this day proposed to effect an insurance against Fire and/or Lightning for 12 (Twelve) months from ${_formatDate(policy?.periodFrom)} to ${_formatDate(policy?.periodTo)} on the usual terms and conditions of the company’s Fire Policy. Having paid the undernoted premium in cash/cheque/P.O/D.D./C.A, the following property is hereby insured to the extent of ($sumInsuredInWords) Only in the manner specified below:'
        ],
      ],
    );
  }

  pw.Widget _buildSumInsuredDetails() { /* ... unchanged ... */
    final policy = moneyreceipt.fireBill?.firePolicy;
    final sumInsuredInWords = _convertToWords(policy?.sumInsured ?? 0.0);

    return pw.Table.fromTextArray(
      data: [
        ['Stock Insured', policy?.stockInsured ?? "N/A"],
        [
          'Sum Insured',
          'TK. ${policy?.sumInsured ?? "N/A"} ($sumInsuredInWords)',
        ],
      ],
    );
  }

  pw.Widget _buildSituationDetails() { /* ... unchanged ... */
    final policy = moneyreceipt.fireBill?.firePolicy;
    final fields = {
      'Interest Insured': policy?.interestInsured,
      'Coverage': policy?.coverage,
      'Location': policy?.location,
      'Construction': policy?.construction,
      'Owner': policy?.owner,
      'Used As': policy?.usedAs,
    };

    return pw.Table(
      border: pw.TableBorder.all(),
      children: fields.entries
          .map(
            (e) => pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text(e.key, style: const pw.TextStyle(fontSize: _defaultFontSize)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text(e.value ?? "N/A", style: const pw.TextStyle(fontSize: _defaultFontSize)),
            ),
          ],
        ),
      )
          .toList(),
    );
  }

  pw.Widget _buildPremiumAndTaxDetails() { /* ... unchanged ... */
    return pw.Table.fromTextArray(
      headers: ['Description', 'Rate', 'BDT', 'Amount'],
      data: [
        [
          'Fire Rate',
          '${(_firePremium).toStringAsFixed(2)}% on ${_sumInsured.toStringAsFixed(2)}',
          'TK',
        ],
        [
          'RSD Rate',
          '${(_rsdPremium).toStringAsFixed(2)}% on ${_sumInsured.toStringAsFixed(2)}',
          'TK',
        ],
        [
          'Net Premium (Car + RSD)',
          '',
          'TK',

        ],
        [
          'Tax on Net Premium',
          '${(_taxAmount).toStringAsFixed(2)}% on ${_netPremium.toStringAsFixed(2)}',
          'TK',
        ],
        [
          'Gross Premium with Tax',
          '',
          'TK',
          _grossPremium.toStringAsFixed(2)
        ],
        [
          'Monthly Payable Amount',
          '',
          'TK',
          _monthlyPayableAmount.toStringAsFixed(2)
        ],
      ],
    );
  }

  pw.Widget _buildFooterDetails() { /* ... unchanged ... */
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Renewal No:'),
            pw.Text(
                '${moneyreceipt.issuedAgainst} / ${moneyreceipt.fireBill?.firePolicy.id?.toString() ?? "N/A"} / ${_formatDate(moneyreceipt.fireBill?.firePolicy.date)}'),
            pw.Text('Checked by __________________'),
          ],
        ),
        pw.Column(
          children: [
            pw.Text('Fully Re-insured with'),
            pw.Text('Sadharan Bima Corporation'),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('For & on behalf of'),
            pw.Text('Green Insurance Com. Ltd.'),
            pw.Text('Authorized Officer __________________'),
          ],
        ),
      ],
    );
  }

  pw.TextStyle _headerTextStyle() =>
      pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold);

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

        // Modal Bottom Sheet ব্যবহার করে আপডেট করা হলো
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          // ড্রপডাউন মেনু যাতে কাটা না যায় তার জন্য `clipBehavior` যোগ করা হলো
          clipBehavior: Clip.antiAlias,
          builder: (context) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  top: 20, // উপরে কিছু প্যাডিং
                  left: 20,
                  right: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Select User to Send Data 📧",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    // DropdownButtonFormField পরিবর্তন
                    DropdownButtonFormField<String>(
                      // **গুরুত্বপূর্ণ পরিবর্তন: isExpanded: true যোগ করা হয়েছে**
                      // এটি নিশ্চিত করে যে ড্রপডাউন মেনুটি পুরো প্রস্থ জুড়ে বিস্তৃত হবে।
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: "User Email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      ),
                      hint: const Text("Select user email"),
                      items: users.map((u) {
                        return DropdownMenuItem<String>(
                          value: u.email,
                          // ড্রপডাউন আইটেমের টেক্সটকে SizedBox দিয়ে মোড়ানো হয়েছে
                          // যাতে এটি স্ক্রিনের বাইরে না যায়
                          child: SizedBox(
                            width: double.infinity,
                            child: Text(
                              u.email ?? "unknown",
                              overflow: TextOverflow.ellipsis, // অতিরিক্ত টেক্সট... দিয়ে দেখানো হবে
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        selectedEmail = value;
                      },
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          child: const Text("Cancel", style: TextStyle(fontSize: 16)),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 10),
                        Expanded( // "Send" বাটনকে এক্সপান্ড করা হয়েছে যাতে পুরো প্রস্থ জুড়ে বাটনটি সুন্দর দেখায়
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text("Send", style: TextStyle(fontSize: 16)),
                            onPressed: () async {
                              if (selectedEmail != null) {
                                final dataToSend = {
                                  "recipientEmail": selectedEmail,
                                  "coverNoteNo": moneyreceipt.issuedAgainst ?? "N/A",
                                  "policyholder": moneyreceipt.fireBill?.firePolicy.policyholder ?? "N/A",
                                  "sumInsured": _sumInsured,
                                  "grossPremium": _grossPremium,
                                  "monthlyPremium": _monthlyPayableAmount,
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
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
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

          _buildTotalRow(context, 'GROSS PREMIUM (with Tax)',
              _grossPremium, isFinal: true),
          const Divider(height: 20, thickness: 1.5, color: Colors.deepPurple),

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