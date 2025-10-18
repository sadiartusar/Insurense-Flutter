import 'package:flutter/material.dart';
import 'package:general_insurance_management_system/model/firebill_model.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AllFireBillDetails extends StatelessWidget {
  final FirebillModel bill;

  const AllFireBillDetails({super.key, required this.bill});

  // 💡 রেসপন্সিভ সাইজিং এর জন্য হেল্পার ফাংশন
  // এটি স্ক্রিনের প্রস্থের উপর ভিত্তি করে একটি সাইজ রিটার্ন করে
  double _rSize(BuildContext context, double baseSize) {
    double screenWidth = MediaQuery.of(context).size.width;
    // 400px কে বেসলাইন ধরে স্কেল করা হয়েছে এবং 0.8x থেকে 1.3x এর মধ্যে সীমাবদ্ধ রাখা হয়েছে
    double scale = (screenWidth / 400).clamp(0.8, 1.3);
    return baseSize * scale;
  }

  // Function to create PDF with table format (Unchanged)
  Future<pw.Document> _generatePdf(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              pw.SizedBox(height: 10),
              _buildFireBillInfo(),
              pw.SizedBox(height: 10),
              _buildInsuredDetails(),
              pw.SizedBox(height: 10),
              _buildSumInsuredDetails(),
              pw.SizedBox(height: 10),
              _buildSituationDetails(),
              pw.SizedBox(height: 10),
              _buildPremiumAndTaxDetails(),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  // Helper methods for building PDF sections (Unchanged)
  pw.Widget _buildHeader() {
    return pw.Center(
      child: pw.Column(
        children: [
          pw.Text("Islami Insurance Company Bangladesh Ltd",
              style:
              pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.Text("DR Tower (14th floor), 65/2/2, Purana Paltan, Dhaka-1000."),
          pw.Text("Tel: 02478853405, Mob: 01763001787"),
          pw.Text("Fax: +88 02 55112742"),
          pw.Text("Email: infociclbd.com"),
          pw.Text("Web: www.islamiinsurance.com"),
        ],
      ),
    );
  }

  pw.Widget _buildFireBillInfo() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text("Fire Bill Information", style: _headerTextStyle()),
        pw.SizedBox(height: 10),
        pw.Table.fromTextArray(
          data: [
            [
              'Fire Bill No',
              '${bill.firePolicy.id ?? "N/A"}',
              'Issue Date',
              '${formatDate(bill.firePolicy.date)}'
            ],
          ],
        ),
      ],
    );
  }

  pw.Widget _buildInsuredDetails() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text("Insured Details", style: _headerTextStyle()),
        pw.Table.fromTextArray(
          data: [
            ['Bank Name', '${bill.firePolicy.bankName ?? "N/A"}'],
            ['Policyholder', '${bill.firePolicy.policyholder ?? "N/A"}'],
            ['Address', '${bill.firePolicy.address ?? "N/A"}'],
          ],
        ),
      ],
    );
  }

  pw.Widget _buildSumInsuredDetails() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text("Segregation of The Sum Insured", style: _headerTextStyle()),
        pw.Table.fromTextArray(
          data: [
            ['Stock Insured', '${bill.firePolicy.stockInsured ?? "N/A"}'],
            ['Sum Insured', 'TK. ${bill.firePolicy.sumInsured ?? "N/A"}'],
          ],
        ),
      ],
    );
  }

  pw.Widget _buildSituationDetails() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text("Situation", style: _headerTextStyle()),
        pw.Table.fromTextArray(
          data: [
            ['Interest Insured', '${bill.firePolicy.interestInsured ?? "N/A"}'],
            ['Coverage', '${bill.firePolicy.coverage ?? "N/A"}'],
            ['Location', '${bill.firePolicy.location ?? "N/A"}'],
            ['Construction', '${bill.firePolicy.construction ?? "N/A"}'],
            ['Owner', '${bill.firePolicy.owner ?? "N/A"}'],
            ['Used As', '${bill.firePolicy.usedAs ?? "N/A"}'],
            ['Period From', '${formatDate(bill.firePolicy.periodFrom)}'],
            ['Period To', '${formatDate(bill.firePolicy.periodTo)}'],
          ],
        ),
      ],
    );
  }

  pw.Widget _buildPremiumAndTaxDetails() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text("Premium and Tax", style: _headerTextStyle()),
        pw.Table.fromTextArray(
          headers: ['Description', 'Rate', 'BDT', 'Amount'],
          data: [
            [
              'Fire Rate',
              '${bill.fire ?? 0}% on ${bill.firePolicy.sumInsured ?? "N/A"}',
              'TK',
              '${getTotalFire().toStringAsFixed(2)}'
            ],
            [
              'Rsd Rate',
              '${bill.rsd ?? 0}% on ${bill.firePolicy.sumInsured ?? "N/A"}',
              'TK',
              '${getTotalRsd().toStringAsFixed(2)}'
            ],
            [
              'Net Premium (Fire + RSD)',
              '',
              'TK',
              '${getTotalPremium().toStringAsFixed(2)}'
            ],
            [
              'Tax on Net Premium',
              '${bill.tax ?? 0}% on ${getTotalPremium().toStringAsFixed(2)}',
              'TK',
              '${getTotalTax().toStringAsFixed(2)}'
            ],
            [
              'Gross Premium with Tax',
              '',
              'TK',
              '${getTotalPremiumWithTax().toStringAsFixed(2)}'
            ],
          ],
        ),
      ],
    );
  }

  pw.TextStyle _headerTextStyle() {
    return pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
              'Fire Bill Details',
              // 💡 রেসপন্সিভ ফন্ট সাইজ
              style: TextStyle(fontSize: _rSize(context, 18)),
            )),
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
        // 💡 রেসপন্সিভ প্যাডিং
        padding: EdgeInsets.all(_rSize(context, 16)),
        child: Column(
          // 💡 বাটনগুলোকে পুরো প্রস্থ দেওয়ার জন্য
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 💡 _buildRow এখন context নেয়
            _buildRow(context, 'Fire Bill No:', '${bill.firePolicy.id ?? "N/A"}'),
            _buildRow(context, 'Issue Date:', '${formatDate(bill.firePolicy.date)}'),
            _buildRow(context, 'Bank Name:', '${bill.firePolicy.bankName ?? "N/A"}'),
            _buildRow(
                context, 'Policyholder:', '${bill.firePolicy.policyholder ?? "N/A"}'),
            _buildRow(context, 'Address:', '${bill.firePolicy.address ?? "N/A"}'),
            _buildRow(context, 'Stock Insured:',
                '${bill.firePolicy.stockInsured ?? "N/A"}'),
            _buildRow(context, 'Sum Insured:',
                '${bill.firePolicy.sumInsured ?? "N/A"} TK'),
            _buildRow(context, 'Interest Insured:',
                '${bill.firePolicy.interestInsured ?? "N/A"}'),
            _buildRow(
                context, 'Coverage:', '${bill.firePolicy.coverage ?? "N/A"}'),
            _buildRow(
                context, 'Location:', '${bill.firePolicy.location ?? "N/A"}'),
            _buildRow(context, 'Construction:',
                '${bill.firePolicy.construction ?? "N/A"}'),
            _buildRow(context, 'Owner:', '${bill.firePolicy.owner ?? "N/A"}'),
            _buildRow(context, 'Used As:', '${bill.firePolicy.usedAs ?? "N/A"}'),
            _buildRow(context, 'Period From:',
                '${formatDate(bill.firePolicy.periodFrom)}'),
            _buildRow(
                context, 'Period To:', '${formatDate(bill.firePolicy.periodTo)}'),
            SizedBox(height: _rSize(context, 20)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: _rSize(context, 12)),
              ),
              onPressed: () async {
                final pdf = await _generatePdf(context); // Generate PDF
                final pdfBytes =
                await pdf.save(); // Get the bytes of the generated PDF

                await Printing.sharePdf(
                  bytes: pdfBytes,
                  filename: 'fire_bill_information.pdf',
                );
              },
              child: Text(
                'Download PDF',
                style: TextStyle(fontSize: _rSize(context, 15)),
              ),
            ),
            SizedBox(height: _rSize(context, 10)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: _rSize(context, 12)),
              ),
              onPressed: () async {
                await Printing.layoutPdf(
                    onLayout: (PdfPageFormat format) async {
                      final pdf = await _generatePdf(context); // Generate PDF
                      return pdf.save(); // Return the saved bytes for printing
                    });
              },
              child: Text(
                'Print View',
                style: TextStyle(fontSize: _rSize(context, 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 💡 সম্পূর্ণ নতুন _buildRow ফাংশন, যা রেসপন্সিভ
  Widget _buildRow(BuildContext context, String title, String value) {
    final double fontSize = _rSize(context, 15);

    return Padding(
      // প্রতিটা সারির মধ্যে রেসপন্সিভ প্যাডিং
      padding: EdgeInsets.symmetric(vertical: _rSize(context, 6)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // লেখা উপরে অ্যালাইন রাখার জন্য
        children: [
          // শিরোনাম (Title)
          Text(
            title,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold, // শিরোনামকে বোল্ড করা হয়েছে
              color: Colors.black87,
            ),
          ),
          SizedBox(width: _rSize(context, 10)), // দুটির মধ্যে ফাঁকা জায়গা

          // তথ্য (Value)
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right, // ডানদিকে অ্যালাইন করা
              style: TextStyle(
                fontSize: fontSize,
                color: Colors.black54, // তথ্যের রঙ কিছুটা হালকা করা হয়েছে
              ),
              softWrap: true, // লেখা বড় হলে নতুন লাইনে যাবে
            ),
          ),
        ],
      ),
    );
  }

  // Helper functions (Unchanged)
  String formatDate(DateTime? date) {
    return date != null ? DateFormat('dd-MM-yyyy').format(date) : "N/A";
  }

  double getTotalFire() {
    return bill.fire != null && bill.firePolicy.sumInsured != null
        ? (bill.fire! / 100) * bill.firePolicy.sumInsured!
        : 0.0;
  }

  double getTotalRsd() {
    return bill.rsd != null && bill.firePolicy.sumInsured != null
        ? (bill.rsd! / 100) * bill.firePolicy.sumInsured!
        : 0.0;
  }

  double getTotalPremium() {
    return getTotalFire() + getTotalRsd();
  }

  double getTotalTax() {
    return (bill.tax != null ? bill.tax! / 100 : 0.0) * getTotalPremium();
  }

  double getTotalPremiumWithTax() {
    return getTotalPremium() + getTotalTax();
  }
}