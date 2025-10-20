import 'package:flutter/material.dart';
import 'package:general_insurance_management_system/model/carbill_model.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AllCarBillDetails extends StatelessWidget {
  final CarBillModel bill;

  const AllCarBillDetails({super.key, required this.bill});

  // 💡 রেসপন্সিভ সাইজিং এর জন্য হেল্পার ফাংশন (অপরিবর্তিত)
  double _rSize(BuildContext context, double baseSize) {
    double screenWidth = MediaQuery.of(context).size.width;
    double scale = (screenWidth / 400).clamp(0.8, 1.3);
    return baseSize * scale;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar আগের মতোই সুন্দর রাখা হয়েছে
      appBar: AppBar(
        title: Center(
            child: Text(
              'Car Bill Details',
              style: TextStyle(
                  fontSize: _rSize(context, 18), fontWeight: FontWeight.bold),
            )),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      // কার্ডগুলোকে ফুটিয়ে তোলার জন্য একটি হালকা ব্যাকগ্রাউন্ড রঙ
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: EdgeInsets.all(_rSize(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- কার্ড ১: বিল এবং পলিসিহোল্ডারের তথ্য ---
            _buildInfoCard(context),
            SizedBox(height: _rSize(context, 16)),

            // --- কার্ড ২: ইনসিওরেন্সের কভারেজ এবং পরিস্থিতি ---
            _buildCoverageCard(context),
            SizedBox(height: _rSize(context, 16)),

            // --- কার্ড ৩: প্রিমিয়াম এবং ট্যাক্সের হিসাব ---
            _buildPremiumCard(context),
            SizedBox(height: _rSize(context, 24)),

            // --- বাটন সেকশন ---
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  /// কার্ড ১: বিল এবং পলিসিহোল্ডারের সাধারণ তথ্য
  Widget _buildInfoCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(_rSize(context, 16)),
        child: Column(
          children: [
            _buildCardTitle(context, Icons.receipt_long, "Bill & Insured Info"),
            SizedBox(height: _rSize(context, 10)),
            _buildDetailRow(
                context, 'Fire Bill No:', '${bill.carPolicy.id ?? "N/A"}'),
            _buildDetailRow(
                context, 'Issue Date:', '${formatDate(bill.carPolicy.date)}'),
            _buildDetailRow(
                context, 'Bank Name:', '${bill.carPolicy.bankName ?? "N/A"}'),
            _buildDetailRow(context, 'Policyholder:',
                '${bill.carPolicy.policyholder ?? "N/A"}'),
            _buildDetailRow(
                context, 'Address:', '${bill.carPolicy.address ?? "N/A"}'),
          ],
        ),
      ),
    );
  }

  /// কার্ড ২: কভারেজ এবং অন্যান্য বিবরণ
  Widget _buildCoverageCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(_rSize(context, 16)),
        child: Column(
          children: [
            _buildCardTitle(context, Icons.shield_outlined, "Coverage Details"),
            SizedBox(height: _rSize(context, 10)),
            _buildDetailRow(context, 'Sum Insured:',
                '${bill.carPolicy.sumInsured ?? "N/A"} TK'),
            _buildDetailRow(context, 'Interest Insured:',
                '${bill.carPolicy.interestInsured ?? "N/A"}'),
            _buildDetailRow(
                context, 'Coverage:', '${bill.carPolicy.coverage ?? "N/A"}'),
            _buildDetailRow(
                context, 'Location:', '${bill.carPolicy.location ?? "N/A"}'),
            _buildDetailRow(context, 'Construction:',
                '${bill.carPolicy.construction ?? "N/A"}'),
            _buildDetailRow(context, 'Period:',
                '${formatDate(bill.carPolicy.periodFrom)} to ${formatDate(bill.carPolicy.periodTo)}'),
          ],
        ),
      ),
    );
  }

  /// কার্ড ৩: প্রিমিয়ামের বিস্তারিত হিসাব
  Widget _buildPremiumCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(_rSize(context, 16)),
        child: Column(
          children: [
            _buildCardTitle(
                context, Icons.calculate_outlined, "Premium Calculation"),
            SizedBox(height: _rSize(context, 15)),
            _buildPremiumRow(context, 'Fire @${bill.carRate ?? 0}%',
                '${getTotalCarRate().toStringAsFixed(2)} TK'),
            _buildPremiumRow(context, 'RSD @${bill.rsd ?? 0}%',
                '${getTotalRsd().toStringAsFixed(2)} TK'),
            Divider(
                height: _rSize(context, 20),
                thickness: 1,
                color: Colors.grey[300]),
            _buildPremiumRow(context, 'Net Premium',
                '${getTotalPremium().toStringAsFixed(2)} TK',
                isBold: true),
            _buildPremiumRow(context, 'Tax @${bill.tax ?? 0}%',
                '${getTotalTax().toStringAsFixed(2)} TK'),
            Divider(
                height: _rSize(context, 25),
                thickness: 2,
                color: Colors.grey[400]),
            _buildPremiumRow(
                context,
                'Gross Premium',
                '${getTotalPremiumWithTax().toStringAsFixed(2)} TK',
                isTotal: true),
          ],
        ),
      ),
    );
  }

  /// ডাউনলোড ও প্রিন্ট বাটন
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          icon: Icon(Icons.picture_as_pdf_outlined),
          label: Text('Download PDF'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, _rSize(context, 45)),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: () async {
            final pdf = await _generatePdf(context);
            final pdfBytes = await pdf.save();
            await Printing.sharePdf(
              bytes: pdfBytes,
              filename: 'fire_bill_information.pdf',
            );
          },
        ),
        SizedBox(height: _rSize(context, 10)),
        ElevatedButton.icon(
          icon: Icon(Icons.print_outlined),
          label: Text('Print View'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey[700],
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, _rSize(context, 45)),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: () async {
            await Printing.layoutPdf(onLayout: (PdfPageFormat format) async {
              final pdf = await _generatePdf(context);
              return pdf.save();
            });
          },
        ),
      ],
    );
  }

  // --- Helper Widgets for UI ---

  /// কার্ডের শিরোনাম তৈরির জন্য একটি হেল্পার
  Widget _buildCardTitle(
      BuildContext context, IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: _rSize(context, 22)),
        SizedBox(width: _rSize(context, 10)),
        Text(
          title,
          style: TextStyle(
            fontSize: _rSize(context, 17),
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  /// তথ্যের প্রতিটি সারি তৈরির জন্য নতুন এবং উন্নত হেল্পার
  Widget _buildDetailRow(BuildContext context, String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: _rSize(context, 7)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: _rSize(context, 14), color: Colors.black54),
          ),
          SizedBox(width: _rSize(context, 10)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: _rSize(context, 14),
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// প্রিমিয়াম কার্ডের সারি তৈরির জন্য বিশেষ হেল্পার
  Widget _buildPremiumRow(BuildContext context, String title, String amount,
      {bool isBold = false, bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: _rSize(context, isTotal ? 6 : 4)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: _rSize(context, isTotal ? 16 : 14),
              fontWeight: isBold || isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.deepPurple : Colors.black87,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: _rSize(context, isTotal ? 16 : 14),
              fontWeight: isBold || isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.deepPurple : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // --- UNCHANGED LOGIC AND PDF GENERATION ---

  Future<pw.Document> _generatePdf(BuildContext context) async {
    // এই ফাংশনে কোনো পরিবর্তন করা হয়নি
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

  // All other helper methods (_buildHeader, _buildFireBillInfo, etc.)
  // and calculation functions (getTotalFire, getTotalTax, etc.) remain unchanged.
  // ... (Paste all your unchanged functions here)
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
              'Car Bill No',
              '${bill.carPolicy.id ?? "N/A"}',
              'Issue Date',
              '${formatDate(bill.carPolicy.date)}'
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
            ['Bank Name', '${bill.carPolicy.bankName ?? "N/A"}'],
            ['Policyholder', '${bill.carPolicy.policyholder ?? "N/A"}'],
            ['Address', '${bill.carPolicy.address ?? "N/A"}'],
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
            ['Stock Insured', '${bill.carPolicy.stockInsured ?? "N/A"}'],
            ['Sum Insured', 'TK. ${bill.carPolicy.sumInsured ?? "N/A"}'],
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
            ['Interest Insured', '${bill.carPolicy.interestInsured ?? "N/A"}'],
            ['Coverage', '${bill.carPolicy.coverage ?? "N/A"}'],
            ['Location', '${bill.carPolicy.location ?? "N/A"}'],
            ['Construction', '${bill.carPolicy.construction ?? "N/A"}'],
            ['Owner', '${bill.carPolicy.owner ?? "N/A"}'],
            ['Used As', '${bill.carPolicy.usedAs ?? "N/A"}'],
            ['Period From', '${formatDate(bill.carPolicy.periodFrom)}'],
            ['Period To', '${formatDate(bill.carPolicy.periodTo)}'],
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
              'Car Rate',
              '${bill.carRate ?? 0}% on ${bill.carPolicy.sumInsured ?? "N/A"}',
              'TK',
              '${getTotalCarRate().toStringAsFixed(2)}'
            ],
            [
              'Rsd Rate',
              '${bill.rsd ?? 0}% on ${bill.carPolicy.sumInsured ?? "N/A"}',
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

  String formatDate(DateTime? date) {
    return date != null ? DateFormat('dd-MM-yyyy').format(date) : "N/A";
  }

  double getTotalCarRate() {
    return bill.carRate != null && bill.carPolicy.sumInsured != null
        ? (bill.carRate! / 100) * bill.carPolicy.sumInsured!
        : 0.0;
  }

  double getTotalRsd() {
    return bill.rsd != null && bill.carPolicy.sumInsured != null
        ? (bill.rsd! / 100) * bill.carPolicy.sumInsured!
        : 0.0;
  }

  double getTotalPremium() {
    return getTotalCarRate() + getTotalRsd();
  }

  double getTotalTax() {
    return (bill.tax != null ? bill.tax! / 100 : 0.0) * getTotalPremium();
  }

  double getTotalPremiumWithTax() {
    return getTotalPremium() + getTotalTax();
  }
}