import 'package:flutter/material.dart';
import 'package:general_insurance_management_system/model/firemoneyreceipt_model.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PrintFireMoneyReceipt extends StatelessWidget {
  final FireMoneyReceiptModel moneyreceipt;

  const PrintFireMoneyReceipt({super.key, required this.moneyreceipt});

  static const double _defaultFontSize = 14;

  // --- Getters for Premium Calculations (Smart and Reusable) ---

  double get _sumInsured => moneyreceipt.fireBill?.firePolicy.sumInsured ?? 0.0;
  double get _fireRate => moneyreceipt.fireBill?.fire ?? 0.0;
  double get _rsdRate => moneyreceipt.fireBill?.rsd ?? 0.0;
  double get _taxRate => moneyreceipt.fireBill?.tax ?? 0.0;

  double get _totalFire => _fireRate * _sumInsured;

  double get _totalRsd => _rsdRate * _sumInsured;

  double get _totalNetPremium => _totalFire + _totalRsd;

  double get _totalTax => _totalNetPremium * _taxRate;

  double get _totalGrossPremiumWithTax => _totalNetPremium + _totalTax;

  double get _monthlyPayableAmount=> _totalGrossPremiumWithTax/12;

  // --- Date Formatting Helper ---
  String _formatDate(DateTime? date) =>
      date != null ? DateFormat('dd-MM-yyyy').format(date) : "N/A";

  // --- Convert Number to Words Helper ---
  String _convertToWords(double num) {
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
      if (n < 100) return '${tens[n ~/ 10]}${n % 10 != 0 ? " ${ones[n % 10]}" : ""}';
      if (n < 1000) return '${ones[n ~/ 100]} Hundred${n % 100 != 0 ? " ${words(n % 100)}" : ""}';
      if (n < 1000000) return '${words(n ~/ 1000)} Thousand${n % 1000 != 0 ? " ${words(n % 1000)}" : ""}';
      if (n < 1000000000) return '${words(n ~/ 1000000)} Million${n % 1000000 != 0 ? " ${words(n % 1000000)}" : ""}';
      // Added a large number case if needed, otherwise this is a safe default
      return "";
    }

    final intPart = num.toInt();
    final decimalPart = ((num - intPart) * 100).toInt();

    var result = words(intPart).trim();

    // Simple approach for decimal part (e.g., "Point Five Zero" for .50)
    // If you need proper decimal words (e.g., "and Fifty Paisa"), the logic would change.
    if (decimalPart > 0) {
      result += " Point ${words(decimalPart)}";
    }

    // Ensuring the final result doesn't start with a space
    return result.trim().isEmpty ? "Zero" : result.trim();
  }

  // --- PDF Generator ---
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

  // --- Header Section ---
  pw.Widget _buildHeader() => pw.Center(
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

  // --- Fire Bill Info ---
  pw.Widget _buildFireBillInfo() => pw.Column(
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

  // --- Insured Details ---
  pw.Widget _buildInsuredDetails() {
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

  // --- Insured Condition ---
  pw.Widget _buildInsuredCondition() {
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

  // --- Sum Insured Details ---
  pw.Widget _buildSumInsuredDetails() {
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

  // --- Situation Details ---
  pw.Widget _buildSituationDetails() {
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

  // --- Premium and Tax Details ---
  pw.Widget _buildPremiumAndTaxDetails() => pw.Table.fromTextArray(
    headers: ['Description', 'Rate', 'BDT', 'Amount'],
    data: [
      [
        'Fire Rate',
        '${(_fireRate * 100).toStringAsFixed(2)}% on ${_sumInsured.toStringAsFixed(2)}',
        'TK',
        _totalFire.toStringAsFixed(2)
      ],
      [
        'RSD Rate',
        '${(_rsdRate * 100).toStringAsFixed(2)}% on ${_sumInsured.toStringAsFixed(2)}',
        'TK',
        _totalRsd.toStringAsFixed(2)
      ],
      [
        'Net Premium (Fire + RSD)',
        '',
        'TK',
        _totalNetPremium.toStringAsFixed(2)
      ],
      [
        'Tax on Net Premium',
        '${(_taxRate * 100).toStringAsFixed(2)}% on ${_totalNetPremium.toStringAsFixed(2)}',
        'TK',
        _totalTax.toStringAsFixed(2)
      ],
      [
        'Gross Premium with Tax',
        '',
        'TK',
        _totalGrossPremiumWithTax.toStringAsFixed(2)
      ],
      [
        'Monthly Payable Amount',
        '',
        'TK',
        _monthlyPayableAmount.toStringAsFixed(2)
      ],
    ],
  );

  // --- Footer ---
  pw.Widget _buildFooterDetails() => pw.Row(
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

  pw.TextStyle _headerTextStyle() =>
      pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold);

  // --- UI Section ---
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Fire Bill Cover Note', textAlign: TextAlign.center),
      // Using a modern, non-deprecated way to apply a gradient to the AppBar
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.green, Colors.orange, Colors.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ..._infoRows(),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.download),
            label: const Text('Download PDF'),
            onPressed: () async {
              final pdf = await _generatePdf(context);
              // Printing.sharePdf is still a valid method for sharing the PDF bytes
              await Printing.sharePdf(
                bytes: await pdf.save(),
                filename: 'fire_bill_covernote.pdf',
              );
            },
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            icon: const Icon(Icons.print),
            label: const Text('Print View'),
            onPressed: () async {
              // Printing.layoutPdf is the modern way for printing on-the-fly
              await Printing.layoutPdf(
                onLayout: (format) async => (await _generatePdf(context)).save(),
              );
            },
          ),
        ],
      ),
    ),
  );

  List<Widget> _infoRows() {
    final policy = moneyreceipt.fireBill?.firePolicy;
    return [
      _buildRow('Fire Bill No:', policy?.id?.toString() ?? "N/A"),
      _buildRow('Issue Date:', _formatDate(policy?.date)),
      _buildRow('Bank Name:', policy?.bankName ?? "N/A"),
      _buildRow('Policyholder:', policy?.policyholder ?? "N/A"),
      _buildRow('Address:', policy?.address ?? "N/A"),
      _buildRow('Stock Insured:', policy?.stockInsured ?? "N/A"),
      _buildRow('Sum Insured:', '${policy?.sumInsured ?? "N/A"} TK'),
      _buildRow('Interest Insured:', policy?.interestInsured ?? "N/A"),
      _buildRow('Coverage:', policy?.coverage ?? "N/A"),
      _buildRow('Location:', policy?.location ?? "N/A"),
      _buildRow('Construction:', policy?.construction ?? "N/A"),
      _buildRow('Owner:', policy?.owner ?? "N/A"),
      _buildRow('Used As:', policy?.usedAs ?? "N/A"),
      _buildRow('Period From:', _formatDate(policy?.periodFrom)),
      _buildRow('Period To:', _formatDate(policy?.periodTo)),
      // Adding premium details to the Flutter UI for completeness
      const Divider(),
      _buildRow('Net Premium:', '${_totalNetPremium.toStringAsFixed(2)} TK'),
      _buildRow('Total Tax:', '${_totalTax.toStringAsFixed(2)} TK'),
      _buildRow('Gross Premium:', '${_totalGrossPremiumWithTax.toStringAsFixed(2)} TK'),
      _buildRow('Monthly Payable Amount:','${_monthlyPayableAmount.toStringAsFixed(2)} TK')
    ];
  }

  Widget _buildRow(String title, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: _defaultFontSize, fontWeight: FontWeight.bold)),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(fontSize: _defaultFontSize),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    ),
  );
}