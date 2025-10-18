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
    _fetchAllBills();
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

  // 💡 রেসপন্সিভ সাইজিং এর জন্য হেল্পার ফাংশন
  double _rSize(BuildContext context, double baseSize) {
    double screenWidth = MediaQuery.of(context).size.width;
    // 400px কে বেসলাইন ধরে স্কেল করা হয়েছে
    double scale = (screenWidth / 400).clamp(0.8, 1.3);
    return baseSize * scale;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Fire Bills',
          // 💡 রেসপন্সিভ ফন্ট সাইজ
          style: TextStyle(fontSize: _rSize(context, 18)),
        ),
        // 💡 অন্যান্য পেজের সাথে মিল রেখে ডিজাইন
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
      body: _buildBody(context), // 💡 বডিকে আলাদা ফাংশনে নেওয়া হলো
    );
  }

  Widget _buildBody(BuildContext context) {
    if (isLoading) {
      return Center(
        // 💡 লোডিং ইন্ডিকেটরের সাইজও রেসপন্সিভ করা হলো
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

    // 💡 ListView এখন রেসপন্সিভ প্যাডিং এবং Card ব্যবহার করছে
    return ListView.builder(
      // 💡 তালিকার চারপাশে রেসপন্সিভ প্যাডিং
      padding: EdgeInsets.all(_rSize(context, 8)),
      itemCount: bills.length,
      itemBuilder: (context, index) {
        final bill = bills[index];
        // 💡 ListTile কে Card দিয়ে মোড়ানো হলো
        return Card(
          elevation: 2,
          margin: EdgeInsets.symmetric(vertical: _rSize(context, 5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_rSize(context, 10)),
          ),
          child: ListTile(
            // 💡 আইটেমগুলোকে দেখতে আকর্ষণীয় করার জন্য leading আইকন
            leading: Icon(
              Icons.local_fire_department_rounded,
              color: Colors.redAccent,
              size: _rSize(context, 30),
            ),
            // 💡 ListTile এর ভেতরের প্যাডিং
            contentPadding: EdgeInsets.symmetric(
              horizontal: _rSize(context, 16),
              vertical: _rSize(context, 8),
            ),
            title: Text(
              bill.firePolicy?.policyholder ?? 'No Name',
              style: TextStyle(
                fontSize: _rSize(context, 16),
                fontWeight: FontWeight.w600, // টাইটেলকে সামান্য বোল্ড করা হলো
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
              Icons.arrow_forward_ios, // আইকন পরিবর্তন করা হলো
              size: _rSize(context, 16),
              color: Colors.grey,
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/viewfirebill',
                arguments: bill.id,
              );
            },
          ),
        );
      },
    );
  }
}