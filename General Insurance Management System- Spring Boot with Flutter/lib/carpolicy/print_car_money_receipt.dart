import 'package:flutter/material.dart';
import 'package:general_insurance_management_system/model/carmoneyreceipt_model.dart';
import 'package:general_insurance_management_system/service/auth_service.dart';
import 'package:general_insurance_management_system/service/http_service.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:ui'; // For ImageFilter.blur

class PrintCarMoneyReceipt extends StatelessWidget {
  final CarMoneyReceiptModel moneyreceipt;

  const PrintCarMoneyReceipt({super.key, required this.moneyreceipt});

  static const double _defaultFontSize = 14;

  // --- Getters for Premium Calculations (Smart and Reusable) ---
  // (All calculation getters remain unchanged for consistency)
  double get _sumInsured => moneyreceipt.carBill?.carPolicy.sumInsured ?? 0.0;
  double get _carRate => moneyreceipt.carBill?.carRate ?? 0.0;
  double get _rsdRate => moneyreceipt.carBill?.rsd ?? 0.0;
  double get _taxRate => moneyreceipt.carBill?.tax ?? 0.0;
  double get _netPremium => moneyreceipt.carBill?.netPremium ?? 0.0;

  double get _grossPremium => moneyreceipt.carBill?.grossPremium ?? 0.0;

  // double get _totalCarRate => (_carRate * _sumInsured)/100;
  //
  // double get _totalRsd => (_rsdRate * _sumInsured)/100;
  //
  // double get _totalNetPremium => (_totalCarRate + _totalRsd)/100;
  //
  // double get _totalTax => (_totalNetPremium * _taxRate);
  //
  // double get _totalGrossPremiumWithTax => _totalNetPremium + _totalTax;

  double get _monthlyPayableAmount => _grossPremium / 12;

  // --- Date Formatting Helper ---
  String _formatDate(DateTime? date) =>
      date != null ? DateFormat('dd-MM-yyyy').format(date) : "N/A";

  // --- Convert Number to Words Helper ---
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

  // --- PDF Generator ---
  // (Unchanged logic for PDF generation)
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

  // --- PDF Helper Methods (Unchanged) ---
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
              'Fire Bill No', moneyreceipt.carBill?.carPolicy.id?.toString() ?? "N/A",
              'Date', _formatDate(moneyreceipt.carBill?.carPolicy.date),
            ],
          ],
        ),
      ],
    );
  }

  pw.Widget _buildInsuredDetails() { /* ... unchanged ... */
    final policy = moneyreceipt.carBill?.carPolicy;
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
    final policy = moneyreceipt.carBill?.carPolicy;
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
    final policy = moneyreceipt.carBill?.carPolicy;
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
    final policy = moneyreceipt.carBill?.carPolicy;
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
          'Car Rate',
          '${(_carRate).toStringAsFixed(2)}% on ${_sumInsured.toStringAsFixed(2)}',
          'TK',
        ],
        [
          'RSD Rate',
          '${(_rsdRate).toStringAsFixed(2)}% on ${_sumInsured.toStringAsFixed(2)}',
          'TK',
        ],
        [
          'Net Premium (Car + RSD)',
          '',
          'TK',

        ],
        [
          'Tax on Net Premium',
          '${(_taxRate).toStringAsFixed(2)}% on ${_netPremium.toStringAsFixed(2)}',
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
                '${moneyreceipt.issuedAgainst} / ${moneyreceipt.carBill?.carPolicy.id?.toString() ?? "N/A"} / ${_formatDate(moneyreceipt.carBill?.carPolicy.date)}'),
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

  // --- FLUTTER UI SECTION (SMART CARD DESIGN) ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Cover Note Details', textAlign: TextAlign.center),
        backgroundColor: Colors.transparent, // Transparent for gradient
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.purple.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Card 1: Bill Info & Insured ---
            _buildSmartCard(
              context,
              title: "Bill & Insured Information",
              icon: Icons.assignment_ind_outlined,
              children: [
                _buildCardRow(
                    context, 'Cover Note No:', moneyreceipt.issuedAgainst ?? "N/A",
                    isBold: true),
                _buildCardRow(
                    context, 'Car Bill No:', moneyreceipt.carBill?.carPolicy.id?.toString() ?? "N/A"),
                _buildCardRow(
                    context, 'Issue Date:', _formatDate(moneyreceipt.carBill?.carPolicy.date)),
                const Divider(height: 15),
                _buildCardRow(
                    context, 'Policyholder:', moneyreceipt.carBill?.carPolicy.policyholder ?? "N/A",
                    isBold: true),
                _buildCardRow(
                    context, 'Bank Name:', moneyreceipt.carBill?.carPolicy.bankName ?? "N/A"),
                _buildCardRow(
                    context, 'Address:', moneyreceipt.carBill?.carPolicy.address ?? "N/A"),
              ],
            ),
            const SizedBox(height: 16),

            // --- Card 2: Coverage & Situation ---
            _buildSmartCard(
              context,
              title: "Coverage & Situation",
              icon: Icons.location_on_outlined,
              children: [
                _buildCardRow(
                    context, 'Sum Insured:', '${_sumInsured.toStringAsFixed(2)} TK',
                    color: Colors.green),
                _buildCardRow(
                    context, 'Stock Insured:', moneyreceipt.carBill?.carPolicy.stockInsured ?? "N/A"),
                _buildCardRow(
                    context, 'Location:', moneyreceipt.carBill?.carPolicy.location ?? "N/A"),
                _buildCardRow(
                    context, 'Used As:', moneyreceipt.carBill?.carPolicy.usedAs ?? "N/A"),
                _buildCardRow(
                    context, 'Period:', '${_formatDate(moneyreceipt.carBill?.carPolicy.periodFrom)} to ${_formatDate(moneyreceipt.carBill?.carPolicy.periodTo)}'),
              ],
            ),
            const SizedBox(height: 16),

            // --- Card 3: Premium Calculation ---
            _buildSmartCard(
              context,
              title: "Premium Calculation",
              icon: Icons.calculate_outlined,
              children: [
                _buildCalculationRow(context, 'Car Rate',
                    '${(_carRate ).toStringAsFixed(2)}%', _carRate),
                _buildCalculationRow(context, 'RSD Rate',
                    '${(_rsdRate).toStringAsFixed(2)}%', _rsdRate),
                const Divider(),
                _buildCalculationRow(context, 'Net Premium', 'Total',
                    _netPremium, isNet: true),
                _buildCalculationRow(context, 'Tax Rate',
                    '${(_taxRate).toStringAsFixed(2)}%', _taxRate),
              ],
            ),
            const SizedBox(height: 16),

            // --- Card 4: Total & Monthly Payable ---
            _buildTotalSummaryCard(context),
            const SizedBox(height: 24),

            // --- Action Buttons ---
            _buildActionButtons(context),
            const SizedBox(height: 20),
            _buildSendButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSendButton(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.send),
      label: const Text('Send to User'),
      onPressed: () async {
        final users = await AuthService().fetchAllUsers();
        String? selectedEmail;

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,

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

                          child: SizedBox(
                            width: double.infinity,
                            child: Text(
                              u.email ?? "unknown",
                              overflow: TextOverflow.ellipsis,
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
                        Expanded(
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
                                  "policyholder": moneyreceipt.carBill?.carPolicy.policyholder ?? "N/A",
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

  // --- Helper Widgets for Smart UI ---

  Widget _buildSmartCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required List<Widget> children,
      }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        // Subtle glassmorphism effect
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
                  Text(
                    title,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple),
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
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: _defaultFontSize,
                  fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
                  color: Colors.grey.shade700)),
          Flexible(
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

  // --- Helper Widget for Calculation Row (OverFlow Fix) ---
  Widget _buildCalculationRow(
      BuildContext context, String title, String rate, double amount,
      {bool isNet = false}) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Expanded(
            flex: 3,
            child: Text(
              title,
              style: TextStyle(
                  fontSize: _defaultFontSize,
                  fontWeight: isNet ? FontWeight.bold : FontWeight.w500,
                  color: isNet ? Colors.deepPurple : Colors.black87),
            ),
          ),


          Expanded(
            flex: 2,
            child: Text(
              rate,
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: _defaultFontSize,
                  fontWeight: isNet ? FontWeight.bold : FontWeight.w500,
                  color: isNet ? Colors.deepPurple : Colors.black87),
            ),
          ),

          const SizedBox(width: 8),


          SizedBox(
            width: 80,
            child: Text(
              '${amount.toStringAsFixed(2)} TK',
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: _defaultFontSize,
                  fontWeight: isNet ? FontWeight.w900 : FontWeight.w500,
                  color: isNet ? Colors.deepPurple.shade900 : Colors.black),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTotalSummaryCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.deepPurple.shade100),
      ),
      child: Column(
        children: [
          _buildTotalRow(
            context,
            'GROSS PREMIUM (with Tax)',
            _grossPremium,
            isFinal: true,
          ),
          const Divider(height: 20, thickness: 1.5, color: Colors.deepPurple),
          _buildTotalRow(
            context,
            'MONTHLY PAYABLE AMOUNT',
            _monthlyPayableAmount,
            isMonthly: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(BuildContext context, String title, double amount,
      {bool isFinal = false, bool isMonthly = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isFinal
                  ? Colors.deepPurple.shade800
                  : (isMonthly ? Colors.green.shade700 : Colors.black87)),
        ),
        Text(
          '${amount.toStringAsFixed(2)} TK',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isFinal
                  ? Colors.deepPurple.shade800
                  : (isMonthly ? Colors.green.shade700 : Colors.black)),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.download),
            label: const Text('Download PDF'),
            onPressed: () async {
              final pdf = await _generatePdf(context);
              await Printing.sharePdf(
                bytes: await pdf.save(),
                filename: 'car_bill_covernote.pdf',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.print),
            label: const Text('Print View'),
            onPressed: () async {
              try {
                await Printing.layoutPdf(
                  onLayout: (format) async => (await _generatePdf(context)).save(),
                );
              } catch (e) {
                // error handling
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),

      ],
    );
  }

}