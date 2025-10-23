import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:general_insurance_management_system/model/payment_model.dart';
import 'package:general_insurance_management_system/service/payment_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';


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

  Future<void> generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Payment Details Report",
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: [
                  "ID",
                  "User Name",
                  "Amount",
                  "Payment Date",
                  "Payment Mode"
                ],
                data: payments.map((p) {
                  return [
                    p.id.toString(),
                    p.user.name,
                    p.amount.toString(),
                    p.paymentDate.toLocal().toString().split(' ')[0],
                    p.paymentMode,
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: pw.BoxDecoration(color: PdfColors.blueGrey900),
                border: pw.TableBorder.all(color: PdfColors.grey),
                cellAlignment: pw.Alignment.centerLeft,
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Payment Details"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: payments.isEmpty ? null : generatePdf,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : payments.isEmpty
          ? Center(child: Text("No payment data found"))
          : SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
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
              DataCell(Text(p.user.name)),
              DataCell(Text(p.amount.toString())),
              DataCell(Text(p.paymentDate.toLocal().toString().split(' ')[0])), // yyyy-mm-dd
              DataCell(Text(p.paymentMode)),
            ]);
          }).toList(),
        ),

      ),
    );
  }
}
