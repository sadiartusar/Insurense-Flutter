import 'package:flutter/material.dart';
import 'package:general_insurance_management_system/model/firebill_model.dart';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AllFireBillDetails extends StatelessWidget {
  final FirebillModel bill;

  const AllFireBillDetails({super.key, required this.bill});

  static const double _fontSize = 14;

  // Function to create PDF with table format
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

  // Helper methods for building PDF sections
  pw.Widget _buildHeader() {
    return pw.Center(
      child: pw.Column(
        children: [
          pw.Text("Islami Insurance Company Bangladesh Ltd",
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
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
            ['Fire Bill No', '${bill.firePolicy.id ?? "N/A"}', 'Issue Date', '${formatDate(bill.firePolicy.date)}'],
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
            ['Fire Rate', '${bill.fire ?? 0}% on ${bill.firePolicy.sumInsured ?? "N/A"}', 'TK', '${getTotalFire().toStringAsFixed(2)}'],
            ['Rsd Rate', '${bill.rsd ?? 0}% on ${bill.firePolicy.sumInsured ?? "N/A"}', 'TK', '${getTotalRsd().toStringAsFixed(2)}'],
            ['Net Premium (Fire + RSD)', '', 'TK', '${getTotalPremium().toStringAsFixed(2)}'],
            ['Tax on Net Premium', '${bill.tax ?? 0}% on ${getTotalPremium().toStringAsFixed(2)}', 'TK', '${getTotalTax().toStringAsFixed(2)}'],
            ['Gross Premium with Tax', '', 'TK', '${getTotalPremiumWithTax().toStringAsFixed(2)}'],
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
        title: const Center(child: Text('Fire Bill Details')),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildRow('Fire Bill No:', '${bill.firePolicy.id ?? "N/A"}'),
            _buildRow('Issue Date:', '${formatDate(bill.firePolicy.date)}'),
            _buildRow('Bank Name:', '${bill.firePolicy.bankName ?? "N/A"}'),
            _buildRow('Policyholder:', '${bill.firePolicy.policyholder ?? "N/A"}'),
            _buildRow('Address:', '${bill.firePolicy.address ?? "N/A"}'),
            _buildRow('Stock Insured:', '${bill.firePolicy.stockInsured ?? "N/A"}'),
            _buildRow('Sum Insured:', '${bill.firePolicy.sumInsured ?? "N/A"} TK'),
            _buildRow('Interest Insured:', '${bill.firePolicy.interestInsured ?? "N/A"}'),
            _buildRow('Coverage:', '${bill.firePolicy.coverage ?? "N/A"}'),
            _buildRow('Location:', '${bill.firePolicy.location ?? "N/A"}'),
            _buildRow('Construction:', '${bill.firePolicy.construction ?? "N/A"}'),
            _buildRow('Owner:', '${bill.firePolicy.owner ?? "N/A"}'),
            _buildRow('Used As:', '${bill.firePolicy.usedAs ?? "N/A"}'),
            _buildRow('Period From:', '${formatDate(bill.firePolicy.periodFrom)}'),
            _buildRow('Period To:', '${formatDate(bill.firePolicy.periodTo)}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final pdf = await _generatePdf(context);  // Generate PDF
                final pdfBytes = await pdf.save(); // Get the bytes of the generated PDF

                await Printing.sharePdf(
                  bytes: pdfBytes,
                  filename: 'fire_bill_information.pdf',
                );
              },
              child: const Text('Download PDF'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                await Printing.layoutPdf(onLayout: (PdfPageFormat format) async {
                  final pdf = await _generatePdf(context);  // Generate PDF
                  return pdf.save();  // Return the saved bytes for printing
                });
              },
              child: const Text('Print View'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: _fontSize)),
        Text(value, style: const TextStyle(fontSize: _fontSize)),
      ],
    );
  }

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