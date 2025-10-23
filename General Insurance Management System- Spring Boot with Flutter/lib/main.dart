import 'package:flutter/material.dart';
import 'package:general_insurance_management_system/carpolicy/view_car_bill.dart';
import 'package:general_insurance_management_system/carpolicy/view_car_money_receipt.dart';
import 'package:general_insurance_management_system/carpolicy/view_car_policy.dart';
import 'package:general_insurance_management_system/firepolicy/all_fire_bill_list_view.dart';
import 'package:general_insurance_management_system/firepolicy/view_fire_bill.dart';
import 'package:general_insurance_management_system/firepolicy/view_fire_money_receipt.dart';
import 'package:general_insurance_management_system/firepolicy/view_firepolicy.dart';
import 'package:general_insurance_management_system/page/admin_profile.dart';
import 'package:general_insurance_management_system/page/home.dart';
import 'package:general_insurance_management_system/page/login.dart';
import 'package:general_insurance_management_system/page/registration.dart';
import 'package:general_insurance_management_system/page/volt_account_page.dart';
import 'package:general_insurance_management_system/reports/fire_bill_reports.dart';
import 'package:general_insurance_management_system/reports/fire_money_receipt_report.dart';
import 'package:general_insurance_management_system/reports/fire_policy_reports.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // ✅ Fixed routes (no arguments)
      routes: {
        '/home': (context) => HomePage(),
        '/login': (context) => LoginPage(),
        '/registration': (context) => Registration(),
        '/viewfirepolicy': (context) => AllFirePolicyView(),
        '/viewfirebill': (context) => AllFireBillView(),
        '/viewfiremoneyreceipt': (context) => AllFireMoneyReceiptView(),
        '/viewpolicyreport': (context) => FirePolicyReportPage(),
        '/viewfirereports': (context) => FireBillReportPage(),
        '/viewcarpolicy':(context) =>AllCarPolicyView(),
        '/viewfiremoneyreceiptreports': (context) =>FireMoneyReceiptReportPage(),
        '/viewcarbill': (context) => AllCarBillView(),
        '/viewcarmoneyreceipt': (context) => AllCarMoneyReceiptView(),
        '/paymentDetails': (context) => PaymentDetailsPage(),
        // ✅ Keep your other routes as needed
      },

      // ✅ Dynamic route handler for routes with arguments
      onGenerateRoute: (settings) {
        if (settings.name == '/adminProfile') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => AdminProfile(profile: args),
          );
        }
        // if (settings.name == '/home') {
        //   final args = settings.arguments as Map<String, dynamic>;
        //   return MaterialPageRoute(
        //     builder: (context) => HomePage(profile: args),
        //   );
        // }

        // Unknown route fallback
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text("Page Not Found")),
            body: const Center(
              child: Text("The page you're looking for doesn't exist."),
            ),
          ),
        );
      },

      // ✅ Entry point
      home: LoginPage(),
    );
  }
}
