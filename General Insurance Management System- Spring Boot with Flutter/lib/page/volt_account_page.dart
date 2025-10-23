import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:general_insurance_management_system/model/payment_model.dart';
import 'package:general_insurance_management_system/service/payment_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';

// ⚠️ Import this for Flutter Web download
import 'dart:html' as html;

class PaymentDetailsPage extends StatefulWidget {
  @override
  _PaymentDetailsPageState createState() => _PaymentDetailsPageState();
}

class _PaymentDetailsPageState extends State<PaymentDetailsPage> {
  List<Payment> payments = [];
  bool isLoading = true;

  final PaymentService paymentService = PaymentService();

  @override
  void initState() {
    super.initState();
    fetchPayments();
  }

  Future<void> fetchPayments() async {
    try {
      final fetchedPayments = await paymentService.getAllPayments();
      setState(() {
        payments = fetchedPayments ?? [];
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching payment details: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // 🔹 Build PDF document
  Future<pw.Document> _buildPdfDocument() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Center(
            child: pw.Text(
              "Payment Details Report",
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headers: ["ID", "User Email", "Amount", "Payment Date", "Payment Mode"],
            data: payments.map((p) {
              return [
                p.id.toString(),
                p.user.email,
                p.amount.toString(),
                p.paymentDate.toLocal().toString().split(' ')[0],
                p.paymentMode,
              ];
            }).toList(),
            headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: pw.BoxDecoration(color: PdfColors.teal),
            border: pw.TableBorder.all(color: PdfColors.grey),
            cellAlignment: pw.Alignment.centerLeft,
          ),
        ],
      ),
    );

    return pdf;
  }

  // 🔹 PDF preview (for print or viewing)
  Future<void> generateAndPreviewPdf() async {
    final pdf = await _buildPdfDocument();
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  // 🔹 Cross-platform PDF download (works on Web + Mobile)
  Future<void> downloadPdf() async {
    try {
      final pdf = await _buildPdfDocument();
      final bytes = await pdf.save();

      if (kIsWeb) {
        // ✅ Web download
        final blob = html.Blob([bytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", "Payment_Details_Report.pdf")
          ..click();
        html.Url.revokeObjectUrl(url);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("PDF downloaded successfully!"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        // ✅ Mobile/Desktop download
        final directory = await getApplicationDocumentsDirectory();
        final filePath = "${directory.path}/Payment_Details_Report.pdf";
        final file = File(filePath);
        await file.writeAsBytes(bytes);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("PDF saved to: $filePath"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print("PDF download error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to download PDF."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Payment Details"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Preview PDF',
            onPressed: payments.isEmpty ? null : generateAndPreviewPdf,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Download PDF',
            onPressed: payments.isEmpty ? null : downloadPdf,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : payments.isEmpty
          ? const Center(
        child: Text(
          "No payment data found",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;
          return Center(
            child: Container(
              width: isWide ? 900 : constraints.maxWidth * 0.95,
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "All Payment Records",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columnSpacing: isWide ? 30 : 16,
                              headingRowColor:
                              WidgetStateProperty.all(
                                  Colors.teal.shade100),
                              border: TableBorder.all(
                                  color: Colors.teal.shade200),
                              columns: const [
                                DataColumn(label: Text('ID')),
                                DataColumn(label: Text('User Name')),
                                DataColumn(label: Text('Amount')),
                                DataColumn(label: Text('Payment Date')),
                                DataColumn(label: Text('Payment Mode')),
                              ],
                              rows: payments.map((p) {
                                return DataRow(cells: [
                                  DataCell(Text(p.id.toString())),
                                  DataCell(Text(p.user.email)),
                                  DataCell(Text("₹${p.amount}")),
                                  DataCell(Text(p.paymentDate
                                      .toLocal()
                                      .toString()
                                      .split(' ')[0])),
                                  DataCell(Text(p.paymentMode)),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: payments.isEmpty ? null : downloadPdf,
                        icon: const Icon(Icons.download),
                        label: const Text("Download PDF"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
