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

// ... অন্যান্য সব import অপরিবর্তিত থাকবে ...

class _PaymentDetailsPageState extends State<PaymentDetailsPage> {
  List<Payment> allPayments = [];
  List<Payment> filteredPayments = [];
  List<User> userList=[];
  bool isLoading = true;

  // সার্চ ফিল্ডের জন্য কন্ট্রোলার
  final TextEditingController _searchController = TextEditingController();

  final PaymentService paymentService = PaymentService();

  @override
  void initState() {
    super.initState();
    fetchPayments();

    _searchController.addListener(_filterPayments);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterPayments);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchPayments() async {
    // ... (আপনার fetchPayments মেথড অপরিবর্তিত থাকবে)
    try {
      final fetchedPayments = await paymentService.getAllPayments();
      setState(() {
        allPayments = fetchedPayments ?? [];
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

  // ⭐️⭐️⭐️ মূল পরিবর্তন এখানে: _filterPayments() ⭐️⭐️⭐️
  void _filterPayments() {
    final query = _searchController.text.trim().toLowerCase();

    // ⭐️ নতুন পরিবর্তন: কমা (,) দ্বারা বিভক্ত আইডিগুলোর একটি তালিকা তৈরি করা ⭐️
    final List<int> queryIds = query.split(',')
        .map((s) => int.tryParse(s.trim())) // প্রতিটি অংশকে int-এ পার্স করার চেষ্টা
        .where((id) => id != null)        // যেগুলো সফলভাবে পার্স হয়েছে, শুধু সেগুলোকে রাখা
        .cast<int>()                      // নিশ্চিত করা যে তালিকাটি শুধুমাত্র int রাখবে
        .toList();

    setState(() {
      if (query.isEmpty) {
        filteredPayments = allPayments;
      } else {
        filteredPayments = allPayments.where((payment) {
          // ১. ইমেইল দিয়ে ম্যাচ করার চেষ্টা
          final emailMatch = payment.user.email?.toLowerCase().contains(query) ?? false;

          // ২. ইউজার আইডি দিয়ে ম্যাচ করার চেষ্টা (যদি queryIds লিস্টে থাকে)
          // queryIds.contains(payment.user.id) চেক করবে, ইউজার আইডিটি ইনপুট করা আইডিগুলোর মধ্যে আছে কি না
          final userIdMatch = queryIds.contains(payment.user.id);

          // ৩. পেমেন্ট আইডি দিয়ে ম্যাচ করার চেষ্টা (যদি queryIds লিস্টে থাকে)
          final paymentIdMatch = queryIds.contains(payment.id);

          // ইমেইল OR ইউজার আইডি OR পেমেন্ট আইডি যেকোনো একটি ম্যাচ করলেই যথেষ্ট
          return emailMatch || userIdMatch || paymentIdMatch;
        }).toList();
      }
    });
  }
  // ⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️

  // 🔹 Build PDF document (এখানে কোনো পরিবর্তন দরকার নেই, কারণ এটি filteredPayments ব্যবহার করে)
  Future<pw.Document> _buildPdfDocument() async {
    // ... (মেথডটি অপরিবর্তিত থাকবে)
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

          if (_searchController.text.isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 10, bottom: 10),
              child: pw.Text(
                "Filter Applied (Email/ID): ${_searchController.text}", // টেক্সট পরিবর্তন
                style: const pw.TextStyle(fontSize: 16, color: PdfColors.blueGrey),
              ),
            ),

          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(

            data: filteredPayments.map((p) {
              return [
                p.id.toString(),
                p.user.email ?? 'N/A', // Null safety যোগ করা
                p.amount.toString(),
                p.paymentDate.toLocal().toString().split(' ')[0],
                p.paymentMode,
              ];
            }).toList(),

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

  // ... (generateAndPreviewPdf এবং downloadPdf মেথড অপরিবর্তিত থাকবে)
  Future<void> generateAndPreviewPdf() async {
    final pdf = await _buildPdfDocument();
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  Future<void> downloadPdf() async {
    try {
      final pdf = await _buildPdfDocument();
      final bytes = await pdf.save();

      final fileName = _searchController.text.isNotEmpty
          ? "Payment_Report_Filter.pdf" // নাম একটু ছোট করে দিলাম
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

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Payment Details"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Preview PDF',

            onPressed: filteredPayments.isEmpty ? null : generateAndPreviewPdf,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Download PDF',

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

                      // ⭐️⭐️⭐️ মূল পরিবর্তন এখানে: TextFormField ⭐️⭐️⭐️
                      TextFormField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: "Search by User Email or Account ID", // লেবেল পরিবর্তন
                          hintText: "Enter email or ID to filter payments",
                          prefixIcon: const Icon(Icons.search, color: Colors.teal),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.red),
                            onPressed: () {
                              _searchController.clear();

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
                        // keyboardType: TextInputType.emailAddress, // কিবোর্ড টাইপ removed, কারণ সংখ্যা ও অক্ষর দুটোই আসতে পারে
                      ),
                      const SizedBox(height: 16),

                      if (filteredPayments.isEmpty)
                        const Expanded(
                          child: Center(
                            child: Text(
                              "No payments match the search criteria.",
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ),
                        )
                      else
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
                                  DataColumn(label: Text('User Email')),
                                  DataColumn(label: Text('Amount')),
                                  DataColumn(label: Text('Payment Date')),
                                  DataColumn(label: Text('Payment Mode')),
                                ],

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