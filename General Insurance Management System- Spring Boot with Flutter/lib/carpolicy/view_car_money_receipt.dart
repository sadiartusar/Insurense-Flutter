import 'package:flutter/material.dart';
import 'package:general_insurance_management_system/carpolicy/creat_car_money_receipt.dart';
import 'package:general_insurance_management_system/carpolicy/print_car_money_receipt.dart';
import 'package:general_insurance_management_system/carpolicy/update_car_money_receipt.dart';
import 'package:general_insurance_management_system/model/carmoneyreceipt_model.dart';
import 'package:general_insurance_management_system/service/carmoneyreceipt_service.dart';


class AllCarMoneyReceiptView extends StatefulWidget {
  const AllCarMoneyReceiptView({super.key});

  @override
  State<AllCarMoneyReceiptView> createState() => _AllCarMoneyReceiptViewState();
}

class _AllCarMoneyReceiptViewState extends State<AllCarMoneyReceiptView> {
  late Future<List<CarMoneyReceiptModel>> fetchMoneyReceipts;
  List<CarMoneyReceiptModel> allMoneyReceipts = [];
  List<CarMoneyReceiptModel> filteredMoneyReceipts = [];
  final TextEditingController searchController = TextEditingController();

  // Responsive helper
  double responsiveSize(BuildContext context, double baseSize) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return baseSize * 0.8; // very small phones
    if (screenWidth < 480) return baseSize * 0.9; // small phones
    if (screenWidth < 600) return baseSize;       // normal phones
    return baseSize * 1.1;                        // tablets & large screens
  }

  @override
  void initState() {
    super.initState();
    final service = CarMoneyReceiptService();
    fetchMoneyReceipts = service.fetchMoneyReceipts().then((receipts) {
      allMoneyReceipts = receipts;
      filteredMoneyReceipts = receipts;
      return receipts;
    });
  }

  void filterReceipts(String query) {
    if (query.isEmpty) {
      setState(() => filteredMoneyReceipts = allMoneyReceipts);
      return;
    }
    setState(() {
      filteredMoneyReceipts = allMoneyReceipts.where((receipt) {
        final bankName = receipt.carBill?.carPolicy.bankName?.toLowerCase() ?? '';
        final policyholder = receipt.carBill?.carPolicy.policyholder?.toLowerCase() ?? '';
        final id = receipt.id.toString();
        return bankName.contains(query.toLowerCase()) ||
            policyholder.contains(query.toLowerCase()) ||
            id.contains(query);
      }).toList();
    });
  }

  Future<void> onDelete(int id) async {
    final service = CarMoneyReceiptService();
    try {
      bool success = await service.deleteMoneyReceipt(id);
      if (success) {
        setState(() {
          filteredMoneyReceipts.removeWhere((receipt) => receipt.id == id);
          allMoneyReceipts.removeWhere((receipt) => receipt.id == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Money Receipt Deleted successfully',
              style: TextStyle(fontSize: responsiveSize(context, 13)),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error deleting receipt: $e',
            style: TextStyle(fontSize: responsiveSize(context, 13)),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final commonStyle = TextStyle(
      fontSize: responsiveSize(context, 13),
      color: Colors.black,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fire Money Receipt',
          style: TextStyle(
            fontSize: responsiveSize(context, 18),
            fontWeight: FontWeight.bold,
          ),
        ),
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
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: responsiveSize(context, 8),
                vertical: responsiveSize(context, 5),
              ),
              child: TextField(
                controller: searchController,
                onChanged: filterReceipts,
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(fontSize: responsiveSize(context, 14)),
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
              child: FutureBuilder<List<CarMoneyReceiptModel>>(
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
                          margin: EdgeInsets.all(responsiveSize(context, 6)),
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
                          child: Align(
                            alignment: Alignment.center,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.95,
                              ),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 4,
                                child: Padding(
                                  padding: EdgeInsets.all(responsiveSize(context, 10)),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Bill No : ${moneyreceipt.carBill?.carPolicy.id ?? 'N/A'}',
                                        style: TextStyle(
                                          fontSize: responsiveSize(context, 13),
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      SizedBox(height: responsiveSize(context, 5)),
                                      Text(
                                        moneyreceipt.carBill?.carPolicy.bankName ?? 'Unnamed Policy',
                                        style: TextStyle(
                                          fontSize: responsiveSize(context, 15),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: responsiveSize(context, 5)),
                                      Text(
                                        moneyreceipt.carBill?.carPolicy.policyholder ?? 'No policyholder available',
                                        style: commonStyle,
                                        softWrap: true,
                                        overflow: TextOverflow.visible,
                                      ),
                                      SizedBox(height: responsiveSize(context, 5)),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              moneyreceipt.carBill?.carPolicy.address ?? 'No address',
                                              style: commonStyle,
                                              softWrap: true,
                                              overflow: TextOverflow.visible,
                                            ),
                                          ),
                                          SizedBox(width: responsiveSize(context, 6)),
                                          Text(
                                            'Tk ${moneyreceipt.carBill?.carPolicy.sumInsured?.round() ?? 'No sum'}',
                                            style: TextStyle(
                                              fontSize: responsiveSize(context, 13),
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: responsiveSize(context, 5)),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Net: Tk ${moneyreceipt.carBill?.netPremium ?? 'No data'}', style: commonStyle),
                                          Text('Tax: ${moneyreceipt.carBill?.tax ?? 'No data'}%', style: commonStyle),
                                          Text('Gross: Tk ${moneyreceipt.carBill?.grossPremium ?? 'No data'}', style: commonStyle),
                                        ],
                                      ),
                                      SizedBox(height: responsiveSize(context, 10)),
                                      Wrap(
                                        spacing: responsiveSize(context, 6),
                                        runSpacing: responsiveSize(context, 6),
                                        children: [
                                          SizedBox(
                                            width: responsiveSize(context, 100),
                                            height: responsiveSize(context, 28),
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => PrintCarMoneyReceipt(
                                                      moneyreceipt: moneyreceipt,
                                                    ),
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blue,
                                                foregroundColor: Colors.black,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(30),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                  vertical: responsiveSize(context, 6),
                                                  horizontal: responsiveSize(context, 10),
                                                ),
                                                textStyle: TextStyle(fontSize: responsiveSize(context, 12)),
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: const [
                                                  Icon(Icons.visibility),
                                                  SizedBox(width: 5),
                                                  Text('Print'),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: responsiveSize(context, 140),
                                            height: responsiveSize(context, 28),
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => PrintCarMoneyReceipt(
                                                      moneyreceipt: moneyreceipt,
                                                    ),
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                foregroundColor: Colors.black,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(30),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                  vertical: responsiveSize(context, 6),
                                                  horizontal: responsiveSize(context, 10),
                                                ),
                                                textStyle: TextStyle(fontSize: responsiveSize(context, 12)),
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: const [
                                                  Icon(Icons.print),
                                                  SizedBox(width: 5),
                                                  Text('Cover Note'),
                                                ],
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () {
                                              if (moneyreceipt.id != null) {
                                                onDelete(moneyreceipt.id!);
                                              }
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.cyan),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => UpdateCarMoneyReceipt(
                                                    moneyreceipt: moneyreceipt,
                                                  ),
                                                ),
                                              );
                                            },
                                            tooltip: 'Edit',
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateCarMoneyReceipt()),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}
