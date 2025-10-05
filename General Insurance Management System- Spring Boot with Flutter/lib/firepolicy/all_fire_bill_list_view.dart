import 'package:flutter/material.dart';
import 'package:general_insurance_management_system/model/firebill_model.dart';
import 'package:general_insurance_management_system/service/firebill_service.dart';

class AllFireBillListView extends StatefulWidget {
  const AllFireBillListView({super.key});

  @override
  State<AllFireBillListView> createState() => _AllFireBillListViewState();
}

class _AllFireBillListViewState extends State<AllFireBillListView> {
  final BillService billService = BillService();
  List<FirebillModel> bills = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchAllBills(); // ✅ fetch only once in initState
  }

  Future<void> _fetchAllBills() async {
    try {
      final result = await billService.fetchAllFireBills();
      if (mounted) {
        setState(() {
          bills = result;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Fire Bills')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
          ? const Center(child: Text('❌ Error fetching bills'))
          : ListView.builder(
        itemCount: bills.length,
        itemBuilder: (context, index) {
          final bill = bills[index];
          return ListTile(
            title: Text(bill.policy?.policyholder ?? 'No Name'),
            subtitle: Text('Net Premium: ${bill.netPremium}'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/viewfirebill',
                arguments: bill.id,
              );
            },
          );
        },
      ),
    );
  }
}
