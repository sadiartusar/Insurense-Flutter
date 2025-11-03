import 'package:flutter/material.dart';
import 'package:general_insurance_management_system/model/carbill_model.dart';
import 'package:general_insurance_management_system/service/carbill_service.dart';



class AllCarBillListView extends StatefulWidget {
  const AllCarBillListView({super.key});

  @override
  State<AllCarBillListView> createState() => _AllCarBillListViewState();
}

class _AllCarBillListViewState extends State<AllCarBillListView> {
  final CarBillService billService = CarBillService();
  List<CarBillModel> bills = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchAllBills();
  }

  Future<void> _fetchAllBills() async {
    try {
      final result = await billService.fetchAllCarBills();
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


  double _rSize(BuildContext context, double baseSize) {
    double screenWidth = MediaQuery.of(context).size.width;

    double scale = (screenWidth / 400).clamp(0.8, 1.3);
    return baseSize * scale;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Car Bills',

          style: TextStyle(fontSize: _rSize(context, 18)),
        ),

        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.green],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (isLoading) {
      return Center(

        child: CircularProgressIndicator(
          strokeWidth: _rSize(context, 3.5),
        ),
      );
    }

    if (hasError) {
      return Center(
        child: Text(
          '❌ Error fetching bills',
          // 💡 এরর মেসেজের ফন্ট সাইজ
          style: TextStyle(fontSize: _rSize(context, 16)),
        ),
      );
    }

    if (bills.isEmpty) {
      return Center(
        child: Text(
          'No bills found.',
          style: TextStyle(fontSize: _rSize(context, 16), color: Colors.grey),
        ),
      );
    }


    return ListView.builder(

      padding: EdgeInsets.all(_rSize(context, 8)),
      itemCount: bills.length,
      itemBuilder: (context, index) {
        final bill = bills[index];

        return Card(
          elevation: 2,
          margin: EdgeInsets.symmetric(vertical: _rSize(context, 5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_rSize(context, 10)),
          ),
          child: ListTile(

            leading: Icon(
              Icons.local_car_wash_rounded,
              color: Colors.redAccent,
              size: _rSize(context, 30),
            ),

            contentPadding: EdgeInsets.symmetric(
              horizontal: _rSize(context, 16),
              vertical: _rSize(context, 8),
            ),
            title: Text(
              bill.carPolicy?.policyholder ?? 'No Name',
              style: TextStyle(
                fontSize: _rSize(context, 16),
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'Net Premium: ${bill.netPremium}',
              style: TextStyle(
                fontSize: _rSize(context, 14),
                color: Colors.black54,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: _rSize(context, 16),
              color: Colors.grey,
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/viewcarbill',
                arguments: bill.id,
              );
            },
          ),
        );
      },
    );
  }
}