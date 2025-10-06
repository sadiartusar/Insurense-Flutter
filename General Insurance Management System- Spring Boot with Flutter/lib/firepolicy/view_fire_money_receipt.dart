import 'package:flutter/material.dart';
import 'package:general_insurance_management_system/firepolicy/create_fire_money_receipt.dart';
import 'package:general_insurance_management_system/firepolicy/print_fire_money_receipt.dart';
import 'package:general_insurance_management_system/firepolicy/update_fire_money_receipt.dart';
import 'package:general_insurance_management_system/model/firemoneyreceipt_model.dart';
import 'package:general_insurance_management_system/service/fire_money_receipt_service.dart';


class AllFireMoneyReceiptView extends StatefulWidget {
  const AllFireMoneyReceiptView({super.key});

  @override
  State<AllFireMoneyReceiptView> createState() =>
      _AllFireMoneyReceiptViewState();
}

class _AllFireMoneyReceiptViewState extends State<AllFireMoneyReceiptView> {
  late Future<List<FireMoneyReceiptModel>> fetchMoneyReceipts;
  List<FireMoneyReceiptModel> allMoneyReceipts = [];
  List<FireMoneyReceiptModel> filteredMoneyReceipts = [];
  final TextStyle commonStyle = TextStyle(fontSize: 14, color: Colors.black);
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final service = MoneyReceiptService();
    fetchMoneyReceipts = service.fetchMoneyReceipts().then((receipts) {
      allMoneyReceipts = receipts;
      filteredMoneyReceipts = receipts; // Initialize with all receipts
      return receipts;
    });
  }

  void filterReceipts(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredMoneyReceipts = allMoneyReceipts;
      });
      return;
    }

    setState(() {
      filteredMoneyReceipts = allMoneyReceipts.where((receipt) {
        final bankName = receipt.fireBill?.firePolicy.bankName?.toLowerCase() ?? '';
        final policyholder =
            receipt.fireBill?.firePolicy.policyholder?.toLowerCase() ?? '';
        final id =
        receipt.id.toString(); // Assuming receipt has an 'id' property

        return bankName.contains(query.toLowerCase()) ||
            policyholder.contains(query.toLowerCase()) ||
            id.contains(query);
      }).toList();
    });
  }

  Future<void> onDelete(int id) async {
    final service = MoneyReceiptService();
    try {
      bool success = await service.deleteMoneyReceipt(id);
      if (success) {
        setState(() {
          // Remove the deleted receipt from the list
          filteredMoneyReceipts.removeWhere((receipt) => receipt.id == id);
          allMoneyReceipts.removeWhere((receipt) => receipt.id == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Money Receipt Delete successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting receipt: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fire Money Receipt'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.yellow.withOpacity(0.8),
                Colors.green.withOpacity(0.8),
                Colors.orange.withOpacity(0.8),
                Colors.red.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context, '/home');
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: TextField(
              controller: searchController,
              onChanged: filterReceipts, // Correctly call the filter function
              decoration: InputDecoration(
                hintText: 'Search ',
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(color: Colors.green, width: 1.0),
                ),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search, color: Colors.green),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(color: Colors.green, width: 1.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<FireMoneyReceiptModel>>(
              future: fetchMoneyReceipts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No bills available'));
                } else {
                  return ListView.builder(
                    itemCount: filteredMoneyReceipts.length,
                    itemBuilder: (context, index) {
                      final moneyreceipt = filteredMoneyReceipts[index];
                      return Container(
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: LinearGradient(
                            colors: [
                              Colors.red,
                              Colors.orange,
                              Colors.yellow,
                              Colors.green,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bill No : ${moneyreceipt.fireBill?.firePolicy.id ?? 'N/A'}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  moneyreceipt.fireBill?.firePolicy.bankName ??
                                      'Unnamed Policy',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  moneyreceipt.fireBill?.firePolicy.policyholder ??
                                      'No policyholder available',
                                  style: commonStyle,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        moneyreceipt.fireBill?.firePolicy.address ??
                                            'No address',
                                        style: commonStyle,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Tk ${moneyreceipt.fireBill?.firePolicy.sumInsured?.round() ?? 'No sum'}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        'Net: Tk ${moneyreceipt.fireBill?.netPremium?? 'No data'}',
                                        style: commonStyle),
                                    Text(
                                        'Tax: ${moneyreceipt.fireBill?.tax?? 'No data'}%',
                                        style: commonStyle),
                                    Text(
                                        'Gross: Tk ${moneyreceipt.fireBill?.grossPremium?? 'No data'}',
                                        style: commonStyle),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 125,
                                      height: 30,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PrintFireMoneyReceipt(
                                                      moneyreceipt:
                                                      moneyreceipt),
                                            ),
                                          );
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: const [
                                            Icon(Icons.visibility),
                                            SizedBox(width: 8),
                                            Text('Print'),
                                          ],
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.black,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(30),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 24,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    SizedBox(
                                      width: 160,
                                      height: 30,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PrintFireMoneyReceipt(
                                                      moneyreceipt:
                                                      moneyreceipt),
                                            ),
                                          );
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: const [
                                            Icon(Icons.print),
                                            SizedBox(width: 8),
                                            Text('Cover Note'),
                                          ],
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.black,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(30),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 24,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () {
                                        if (moneyreceipt.id != null) {
                                          onDelete(moneyreceipt
                                              .id!); // Use the null assertion operator
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Receipt ID is null, cannot delete.')),
                                          );
                                        }
                                      },
                                    ),

                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.cyan),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => UpdateFireMoneyReceipt(moneyreceipt: moneyreceipt),
                                          ),
                                        );
                                      },
                                      tooltip: 'Edit ',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const CreateFireMoneyReceipt()),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}