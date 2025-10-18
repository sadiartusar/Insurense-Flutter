import 'package:flutter/material.dart';
import 'package:general_insurance_management_system/firepolicy/all_firebill_details.dart';
import 'package:general_insurance_management_system/firepolicy/create_fire_bill.dart';
import 'package:general_insurance_management_system/firepolicy/update_fire_bill.dart';
import 'package:general_insurance_management_system/model/firebill_model.dart';
import 'package:general_insurance_management_system/service/firebill_service.dart';

class AllCarBillView extends StatefulWidget {
  const AllCarBillView({Key? key}) : super(key: key);

  @override
  State<AllCarBillView> createState() => _AllCareBillViewState();
}

class _AllCareBillViewState extends State<AllCarBillView> {
  late Future<List<FirebillModel>> futureBills;
  List<FirebillModel> allBills = [];
  List<FirebillModel> filteredBills = [];
  String searchQuery = '';
  DateTime? startDate;
  DateTime? endDate;
  final TextEditingController searchController = TextEditingController();

  final TextStyle commonStyle = const TextStyle(fontSize: 14, color: Colors.black);

  @override
  void initState() {
    super.initState();
    final service = BillService();
    futureBills = service.fetchAllFireBills().then((bills) {
      allBills = bills;
      filteredBills = allBills;
      return bills;
    });

    searchController.addListener(() {
      Future.delayed(const Duration(milliseconds: 300), () {
        _filterBills(searchController.text);
      });
    });
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  void _filterBills(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredBills = allBills.where((bill) {
        final policyholder = bill.firePolicy.policyholder?.toLowerCase() ?? '';
        final bankName = bill.firePolicy.bankName?.toLowerCase() ?? '';
        final id = bill.id.toString();

        bool matchesSearch = policyholder.contains(searchQuery) ||
            bankName.contains(searchQuery) ||
            id.contains(searchQuery);

        bool matchesDateRange = true;

        if (startDate != null && endDate != null) {
          DateTime policyDate = bill.firePolicy.date is DateTime
              ? normalizeDate(bill.firePolicy.date as DateTime)
              : normalizeDate(DateTime.parse(bill.firePolicy.date as String));

          DateTime start = normalizeDate(startDate!);
          DateTime end = normalizeDate(endDate!);

          matchesDateRange = (policyDate.isAtSameMomentAs(start) || policyDate.isAfter(start)) &&
              (policyDate.isAtSameMomentAs(end) || policyDate.isBefore(end));
        }

        return matchesSearch && matchesDateRange;
      }).toList();
    });
  }

  DateTime normalizeDate(DateTime date) => DateTime(date.year, date.month, date.day);

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTime? pickedStartDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedStartDate != null) {
      final DateTime? pickedEndDate = await showDatePicker(
        context: context,
        initialDate: pickedStartDate.add(const Duration(days: 1)),
        firstDate: pickedStartDate,
        lastDate: DateTime(2100),
      );

      if (pickedEndDate != null) {
        setState(() {
          startDate = pickedStartDate;
          endDate = pickedEndDate;
        });
        _filterBills(searchQuery);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final height = media.size.height;
    final isSmall = width < 400;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fire Bill List'),
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
          onPressed: () => Navigator.pushNamed(context, '/home'),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.03, vertical: height * 0.01),
        child: Column(
          children: [
            // 🔍 Responsive Search Bar
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(color: Colors.green, width: 1.0),
                ),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search, color: Colors.green),
              ),
            ),

            SizedBox(height: height * 0.015),

            // 📅 Date Range Selector (Responsive)
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _selectDateRange(context),
                  icon: const Icon(Icons.calendar_today, color: Colors.green),
                  label: const Text('Select Date Range', style: TextStyle(color: Colors.green)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        horizontal: width * 0.04, vertical: height * 0.012),
                  ),
                ),
                if (startDate != null && endDate != null)
                  Text(
                    'From: ${formatDate(startDate!)} To: ${formatDate(endDate!)}',
                    style: TextStyle(fontSize: isSmall ? 12 : 16),
                  ),
              ],
            ),

            SizedBox(height: height * 0.01),

            // 📋 Bill List
            Expanded(
              child: FutureBuilder<List<FirebillModel>>(
                future: futureBills,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No bills available'));
                  } else {
                    return ListView.builder(
                      itemCount: filteredBills.length,
                      itemBuilder: (context, index) {
                        final bill = filteredBills[index];
                        return Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.red, Colors.orange, Colors.yellow, Colors.green],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            child: Padding(
                              padding: EdgeInsets.all(width * 0.04),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bill No: ${bill.firePolicy.id ?? 'N/A'}',
                                    style: TextStyle(
                                      fontSize: isSmall ? 14 : 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  SizedBox(height: height * 0.005),
                                  Text(
                                    bill.firePolicy.bankName ?? 'Unnamed Policy',
                                    style: TextStyle(
                                        fontSize: isSmall ? 14 : 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: height * 0.005),
                                  Text(bill.firePolicy.policyholder ?? 'No policyholder',
                                      style: commonStyle),
                                  SizedBox(height: height * 0.005),

                                  // 💰 Financial Row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          bill.firePolicy.address ?? 'No address',
                                          style: commonStyle,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Tk ${bill.firePolicy.sumInsured?.toString() ?? 'N/A'}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold, color: Colors.green),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: height * 0.005),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: [
                                      Text('Fire: ${bill.fire ?? 0}%', style: commonStyle),
                                      Text('RSD: ${bill.rsd ?? 0}%', style: commonStyle),
                                      Text('Net: ${bill.netPremium ?? 0}', style: commonStyle),
                                      Text('Tax: ${bill.tax ?? 0}%', style: commonStyle),
                                      Text('Gross: ${bill.grossPremium ?? 0}', style: commonStyle),
                                    ],
                                  ),

                                  // ⚙️ Action Buttons
                                  _buildActionButtons(bill, isSmall),
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
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => const CreateFireBill()));
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildActionButtons(FirebillModel bill, bool isSmall) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.visibility, color: Colors.blue),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AllFireBillDetails(bill: bill)),
            );
          },
          tooltip: 'View Details',
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _confirmDeleteBill(bill.id!),
          tooltip: 'Delete Bill',
        ),
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.cyan),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UpdateFireBill(bill: bill)),
            );
          },
          tooltip: 'Edit Bill',
        ),
      ],
    );
  }

  void _confirmDeleteBill(int billId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this bill?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              _deleteBill(billId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fire Bill deleted successfully!')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteBill(int billId) async {
    final service = BillService();
    try {
      await service.deleteBill(billId);
      setState(() {
        futureBills = service.fetchAllFireBills();
      });
    } catch (e) {
      print('Error deleting bill: $e');
    }
  }
}
