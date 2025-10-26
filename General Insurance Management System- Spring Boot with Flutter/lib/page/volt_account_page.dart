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
  // সমস্ত পেমেন্ট ডেটা সংরক্ষণের জন্য
  List<Payment> allPayments = [];
  // বর্তমানে UI-তে প্রদর্শিত পেমেন্ট ডেটা (ফিল্টার করার পর)
  List<Payment> filteredPayments = [];
  bool isLoading = true;

  // সার্চ ফিল্ডের জন্য কন্ট্রোলার
  final TextEditingController _searchController = TextEditingController();

  final PaymentService paymentService = PaymentService();

  @override
  void initState() {
    super.initState();
    fetchPayments();
    // কন্ট্রোলারের পরিবর্তনগুলো শুনবে এবং ফিল্টার ফাংশন কল করবে
    _searchController.addListener(_filterPayments);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterPayments);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchPayments() async {
    try {
      final fetchedPayments = await paymentService.getAllPayments();
      setState(() {
        allPayments = fetchedPayments ?? [];
        // শুরুতে ফিল্টার্ড লিস্ট সমস্ত ডেটা দিয়ে পপুলেট হবে
        filteredPayments = allPayments;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching payment details: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // 🔎 ফিল্টারিং লজিক
  void _filterPayments() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        // সার্চ খালি থাকলে সমস্ত পেমেন্ট দেখাবে
        filteredPayments = allPayments;
      } else {
        // ইমেইল দিয়ে ফিল্টার করবে
        filteredPayments = allPayments.where((payment) {
          // Null check যোগ করা হয়েছে
          final email = payment.user.email?.toLowerCase() ?? '';
          return email.contains(query);
        }).toList();
      }
    });
  }

  // 🔹 Build PDF document (এখন filteredPayments ব্যবহার করবে)
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
          // যদি কোনো ফিল্টার প্রয়োগ করা হয়, সেটি PDF এ দেখানো
          if (_searchController.text.isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 10, bottom: 10),
              child: pw.Text(
                "Filter Applied (User Email): ${_searchController.text}",
                style: const pw.TextStyle(fontSize: 16, color: PdfColors.blueGrey),
              ),
            ),

          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            // ✅ এখন filteredPayments ব্যবহার করা হচ্ছে
            data: filteredPayments.map((p) {
              return [
                p.id.toString(),
                p.user.email ?? 'N/A', // Null safety
                p.amount.toString(),
                p.paymentDate.toLocal().toString().split(' ')[0],
                p.paymentMode,
              ];
            }).toList(),
            // ... (বাকি স্টাইল অপরিবর্তিত)
            headers: ["ID", "User Email", "Amount", "Payment Date", "Payment Mode"],
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

      final fileName = _searchController.text.isNotEmpty
          ? "Payment_Report_${_searchController.text}.pdf"
          : "Payment_Details_Report.pdf";

      if (kIsWeb) {
        // ✅ Web download
        final blob = html.Blob([bytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", fileName)
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
        final filePath = "${directory.path}/$fileName";
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
    // ⚠️ এই লাইনটি আর প্রয়োজন নেই, কারণ আমরা LayoutBuilder ব্যবহার করছি
    // final isWideScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Payment Details"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Preview PDF',
            // ✅ filteredPayments.isEmpty দিয়ে চেক করা হয়েছে
            onPressed: filteredPayments.isEmpty ? null : generateAndPreviewPdf,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Download PDF',
            // ✅ filteredPayments.isEmpty দিয়ে চেক করা হয়েছে
            onPressed: filteredPayments.isEmpty ? null : downloadPdf,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
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
                      // 🔎 সার্চ ফিল্ড যোগ করা হলো
                      TextFormField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: "Search by User Email",
                          hintText: "Enter user email to filter payments",
                          prefixIcon: const Icon(Icons.search, color: Colors.teal),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.red),
                            onPressed: () {
                              _searchController.clear();
                              // _filterPayments() স্বয়ংক্রিয়ভাবে কল হবে
                            },
                          )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.teal),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.teal, width: 2),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      // যদি ফিল্টারিং এর পরে কোনো ডেটা না থাকে
                      if (filteredPayments.isEmpty)
                        const Expanded(
                          child: Center(
                            child: Text(
                              "No payments match the search criteria.",
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ),
                        )
                      else // যদি ডেটা থাকে
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
                                  DataColumn(label: Text('User Email')), // Header আপডেট করা হলো
                                  DataColumn(label: Text('Amount')),
                                  DataColumn(label: Text('Payment Date')),
                                  DataColumn(label: Text('Payment Mode')),
                                ],
                                // ✅ এখন filteredPayments ব্যবহার করা হচ্ছে
                                rows: filteredPayments.map((p) {
                                  return DataRow(cells: [
                                    DataCell(Text(p.id.toString())),
                                    DataCell(Text(p.user.email ?? 'N/A')), // Null safety
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
                        // ✅ filteredPayments.isEmpty দিয়ে চেক করা হয়েছে
                        onPressed: filteredPayments.isEmpty ? null : downloadPdf,
                        icon: const Icon(Icons.download),
                        label: Text("Download PDF${_searchController.text.isNotEmpty ? ' (Filtered)' : ''}"),
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