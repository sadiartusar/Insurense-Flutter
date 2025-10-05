import 'package:flutter/material.dart';
import 'package:general_insurance_management_system/model/firepolicy_model.dart';
import 'package:intl/intl.dart'; // Make sure to import this package for date formatting


class AllFirePolicyDetails extends StatelessWidget {
  final PolicyModel policy;

  const AllFirePolicyDetails({super.key, required this.policy});

  // Define a constant for the font size
  static const double _fontSize = 14;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.greenAccent,
                Colors.deepOrangeAccent,
                Colors.cyan,
                Colors.amber,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            title: const Text('Fire Policy Details'),
            centerTitle: true,
            backgroundColor: Colors.transparent, // Make the AppBar transparent
            elevation: 0, // Remove shadow
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blueAccent,
              Colors.greenAccent,
              Colors.yellowAccent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView( // Add SingleChildScrollView here
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row for ID and Date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bill No: ${policy.id?.toString() ?? 'No ID'}',
                          style: TextStyle(fontSize: _fontSize, color: Colors.black),
                        ),
                        Text(
                          'Date: ${formatDate(policy.date)}',
                          style: TextStyle(fontSize: _fontSize, color: Colors.black),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Bank Name: ${policy.bankName ?? 'Unnamed'}',
                      style: TextStyle(fontSize: _fontSize, color: Colors.black),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Policyholder: ${policy.policyholder ?? 'No policyholder'}',
                      style: TextStyle(fontSize: _fontSize, color: Colors.black),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Address: ${policy.address ?? 'No address'}',
                      style: TextStyle(fontSize: _fontSize, color: Colors.black),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Sum Insured: Tk ${policy.sumInsured?.toString() ?? 'No sum'}',
                      style: TextStyle(fontSize: _fontSize, color: Colors.black),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Stock Insured: ${policy.stockInsured ?? 'Not specified'}',
                      style: TextStyle(fontSize: _fontSize, color: Colors.black),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Interest Insured: ${policy.interestInsured ?? 'Not specified'}',
                      style: TextStyle(fontSize: _fontSize, color: Colors.black),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Coverage: ${policy.coverage ?? 'Not specified'}',
                      style: TextStyle(fontSize: _fontSize, color: Colors.black),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Location: ${policy.location ?? 'Not specified'}',
                      style: TextStyle(fontSize: _fontSize, color: Colors.black),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Construction: ${policy.construction ?? 'Not specified'}',
                      style: TextStyle(fontSize: _fontSize, color: Colors.black),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Owner: ${policy.owner ?? 'Not specified'}',
                      style: TextStyle(fontSize: _fontSize, color: Colors.black),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Used As: ${policy.usedAs ?? 'Not specified'}',
                      style: TextStyle(fontSize: _fontSize, color: Colors.black),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Period From: ${formatDate(policy.periodFrom)}',
                      style: TextStyle(fontSize: _fontSize, color: Colors.black),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Period To: ${formatDate(policy.periodTo)}',
                      style: TextStyle(fontSize: _fontSize, color: Colors.black),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String formatDate(DateTime? dateTime) {
    if (dateTime == null) {
      return "N/A"; // Return "N/A" if date is null
    }
    return DateFormat('dd-MM-yyyy').format(dateTime); // Format the date
  }
}