import 'package:flutter/material.dart';
import 'package:general_insurance_management_system/firepolicy/all_fire_bill_list_view.dart';
import 'package:general_insurance_management_system/firepolicy/view_fire_bill.dart';
import 'package:general_insurance_management_system/firepolicy/view_fire_money_receipt.dart';
import 'package:general_insurance_management_system/firepolicy/view_firepolicy.dart';
import 'package:general_insurance_management_system/page/home.dart';
import 'package:general_insurance_management_system/page/login.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}


  class _MyAppState extends State<MyApp> {
  int _hoverIndex = -1; // Variable to track hover state


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (context) => HomePage(),
        // '/login': (context) => Login(),
        // '/registration': (context) => Registration(),
        '/viewfirepolicy': (context) => AllFirePolicyView(),
        '/viewfirebill': (context) => AllFireBillView(),
         '/viewfiremoneyreceipt': (context) => AllFireMoneyReceiptView(),
        // '/viewmarinepolicy': (context) => AllMarinePolicyView(),
        // '/viewmarinebill': (context) => AllMarineBillView(),
        // '/viewmarinemoneyreceipt': (context) => AllMarineMoneyReceiptView(),
        // '/viewpolicyreport': (context) => FirePolicyReportPage(),
        // '/viewfirereports': (context) => FireBillReportPage(),
        // '/viewmarinereports': (context) => MarineBillReportPage(),
        // '/viewcombindreports': (context) => CombinedReport(),
        // '/viewmarinereport': (context) => MarinePolicyReportPage(),
        // '/viewfiremoneyreceiptreports': (context) => FireMoneyReceiptReportPage(),
        // '/viewmarinemoneyreceiptreports': (context) => MarineMoneyReceiptReportPage(),
        // '/viewcombindmoneyreports': (context) => CombinedMoneyReceiptReport(),
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text("Page Not Found")),
          body: const Center(
              child: Text("The page you're looking for doesn't exist.")),
        ),
      ),
      home: LoginPage(),
    );
  }
  }



