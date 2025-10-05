import 'package:flutter/material.dart';
import 'package:general_insurance_management_system/model/firebill_model.dart';
import 'package:general_insurance_management_system/service/firebill_service.dart';
import 'package:general_insurance_management_system/firepolicy/create_fire_bill.dart';

class AllFireBillView extends StatefulWidget {
  const AllFireBillView({Key? key}) : super(key: key);

  @override
  State<AllFireBillView> createState() => _AllFireBillViewState();
}

class _AllFireBillViewState extends State<AllFireBillView> {
  late Future<List<FirebillModel>> futureBills;
  List<FirebillModel> allBills = [];
  List<FirebillModel> filteredBills = [];
  final TextEditingController searchController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    final service = BillService();
    futureBills = service.fetchAllFireBills().then((bills) {
      allBills = bills;
      filteredBills = List.from(allBills);
      return bills;
    });

    searchController.addListener(() {
      _filterBills(searchController.text);
    });
  }

  void _filterBills(String query) {
    setState(() {
      filteredBills = allBills.where((bill) {
        final policyholder = bill.policy.policyholder?.toLowerCase() ?? '';
        final bankName = bill.policy.bankName?.toLowerCase() ?? '';
        final id = bill.id?.toString() ?? '';

        bool matchesSearch = policyholder.contains(query.toLowerCase()) ||
            bankName.contains(query.toLowerCase()) ||
            id.contains(query.toLowerCase());

        bool matchesDateRange = true;
        if (startDate != null && endDate != null) {
          DateTime policyDate = bill.policy.date != null
              ? DateTime.parse(bill.policy.date!)
              : DateTime.now();
          matchesDateRange = (policyDate.isAtSameMomentAs(startDate!) || policyDate.isAfter(startDate!)) &&
              (policyDate.isAtSameMomentAs(endDate!) || policyDate.isBefore(endDate!));
        }

        return matchesSearch && matchesDateRange;
      }).toList();
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTime? pickedStart = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedStart != null) {
      final DateTime? pickedEnd = await showDatePicker(
        context: context,
        initialDate: pickedStart.add(const Duration(days: 1)),
        firstDate: pickedStart,
        lastDate: DateTime(2100),
      );
      if (pickedEnd != null) {
        setState(() {
          startDate = pickedStart;
          endDate = pickedEnd;
        });
        _filterBills(searchController.text);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fire Bill List'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Search by Policyholder / Bank / ID',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _selectDateRange(context),
                child: const Text('Select Date Range'),
              ),
              if (startDate != null && endDate != null)
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    '${startDate!.day}-${startDate!.month}-${startDate!.year} to ${endDate!.day}-${endDate!.month}-${endDate!.year}',
                  ),
                ),
            ],
          ),
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
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(bill.policy.policyholder ?? 'No Policyholder'),
                          subtitle: Text('Bank: ${bill.policy.bankName ?? 'N/A'} | Fire: ${bill.fire}%'),
                          trailing: Text('Net: ${bill.netPremium}'),
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
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateFireBill()),
          );
        },
      ),
    );
  }
}
