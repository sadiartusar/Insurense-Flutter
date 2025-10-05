import 'dart:convert';

import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:general_insurance_management_system/firepolicy/view_firepolicy.dart';
import 'package:general_insurance_management_system/model/firepolicy_model.dart';
import 'package:general_insurance_management_system/service/firepolicy_service.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateFirePolicy extends StatefulWidget {
  const CreateFirePolicy({super.key});

  @override
  State<CreateFirePolicy> createState() => _CreateFirePolicyState();
}

class _CreateFirePolicyState extends State<CreateFirePolicy> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController policyholderController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController stockInsuredController = TextEditingController();
  final TextEditingController sumInsuredController = TextEditingController();
  final TextEditingController interestInsuredController = TextEditingController();
  final TextEditingController coverageController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController constructionController = TextEditingController();
  final TextEditingController ownerController = TextEditingController();
  final TextEditingController usedAsController = TextEditingController();
  final TextEditingController periodFromController = TextEditingController();
  final TextEditingController periodToController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final FirePolicyService policyService = FirePolicyService();

  // Dropdown values
  final List<String> constructionTypes = ['1st Class', '2nd Class', '3rd Class'];
  final List<String> usageTypes = ['Shop Only', 'Godown Only', 'Shop-Cum-Godown only'];

  String? selectedConstruction;
  String? selectedUsage;


  @override
  void initState() {
    super.initState();
    dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    coverageController.text = "Fire &/or Lightning only";
    ownerController.text = "The Insured";
  }

  Future<http.Response> createFirePolicy(PolicyModel policy) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');  // authToken key মিলিয়ে নিন

      final response = await http.post(
        Uri.parse('http://localhost:8085/api/firepolicy/add'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',  // ✅ Token পাঠানো হলো
        },
        body: jsonEncode(policy.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response;
      } else {
        throw Exception('Failed to create fire policy: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }


  @override
  void dispose() {
    dateController.dispose();
    bankNameController.dispose();
    policyholderController.dispose();
    addressController.dispose();
    stockInsuredController.dispose();
    sumInsuredController.dispose();
    interestInsuredController.dispose();
    coverageController.dispose();
    locationController.dispose();
    constructionController.dispose();
    ownerController.dispose();
    usedAsController.dispose();
    periodFromController.dispose();
    periodToController.dispose();
    super.dispose();
  }

  void _createFirePolicy() async {
    if (_formKey.currentState!.validate()) {
      try {
        PolicyModel policy = PolicyModel(
          date: DateTime.parse(dateController.text),
          bankName: bankNameController.text,
          policyholder: policyholderController.text,
          address: addressController.text,
          stockInsured: stockInsuredController.text,
          sumInsured: double.tryParse(sumInsuredController.text) ?? 0,
          interestInsured: interestInsuredController.text,
          coverage: coverageController.text,
          location: locationController.text,
          construction: selectedConstruction ?? '',
          owner: ownerController.text,
          usedAs: selectedUsage ?? '',
          periodFrom: DateTime.parse(periodFromController.text),
          periodTo: DateTime.parse(periodToController.text),
        );

        final response = await createFirePolicy(policy);

        if (response.statusCode == 201 || response.statusCode == 200) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AllFirePolicyView()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed with status: ${response.statusCode}')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Fire Policy Form'),
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 10),
                _buildDateTextField(),
                const SizedBox(height: 20),
                _buildTextField(bankNameController, 'Bank Name', Icons.account_balance, 'Please enter a bank name'),
                const SizedBox(height: 20),
                _buildTextField(policyholderController, 'Policyholder', Icons.person, 'Please enter the policyholder name'),
                const SizedBox(height: 20),
                _buildTextField(addressController, 'Address', Icons.location_on, 'Please enter an address'),
                const SizedBox(height: 20),
                _buildTextField(stockInsuredController, 'Stock Insured', Icons.inventory, 'Please enter the stock insured'),
                const SizedBox(height: 20),
                _buildNumberTextField(sumInsuredController, 'Sum Insured', Icons.monetization_on, 'Please enter the sum insured'),
                const SizedBox(height: 20),
                _buildTextField(interestInsuredController, 'Interest Insured', Icons.info, 'Please enter interest insured details'),
                const SizedBox(height: 20),
                _buildTextField(coverageController, 'Coverage', Icons.assignment, 'Please enter the coverage details', readOnly: true),
                const SizedBox(height: 20),
                _buildTextField(locationController, 'Location', Icons.location_city, 'Please enter the location'),
                const SizedBox(height: 20),
                // Construction Type Dropdown
                DropdownButtonFormField<String>(
                  value: selectedConstruction,
                  decoration: _buildInputDecoration('Construction Type', Icons.build),
                  items: constructionTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedConstruction = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a construction type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Used As Dropdown
                DropdownButtonFormField<String>(
                  value: selectedUsage,
                  decoration: _buildInputDecoration('Used As', Icons.business),
                  items: usageTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedUsage = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select how it is used';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildTextField(ownerController, 'Owner', Icons.person, 'Please enter the owner name', readOnly: true),
                const SizedBox(height: 20),
                _buildPeriodFromTextField(),
                const SizedBox(height: 20),
                _buildPeriodToTextField(),
                const SizedBox(height: 20),
                _buildSubmitButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isHovered = false;
  Widget _buildSubmitButton() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: ElevatedButton(
        onPressed: _createFirePolicy,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isHovered ? Colors.green : Colors.blueAccent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          shadowColor: Colors.pink,  // Shadow color
          elevation: _isHovered ? 12 : 4,  // Higher elevation on hover
        ),
        child: const Text(
          "Create Fire Policy",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }




  Widget _buildDateTextField() {
    return TextFormField(
      controller: dateController,
      decoration: _buildInputDecoration('Date', Icons.calendar_today),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a date';
        }
        return null;
      },
      readOnly: true,
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, String validationMessage, {bool readOnly = false}) {
    return TextFormField(
      controller: controller,
      decoration: _buildInputDecoration(label, icon),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validationMessage;
        }
        return null;
      },
      readOnly: readOnly,
    );
  }

  Widget _buildNumberTextField(TextEditingController controller, String label, IconData icon, String validationMessage) {
    return TextFormField(
      controller: controller,
      decoration: _buildInputDecoration(label, icon),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validationMessage;
        }
        if (double.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        return null;
      },
    );
  }

  Widget _buildPeriodFromTextField() {
    return TextFormField(
      controller: periodFromController,
      decoration: _buildInputDecoration('Period From', Icons.date_range),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a start date';
        }
        return null;
      },
      readOnly: true, // To prevent typing, only show the calendar
      onTap: () async {
        FocusScope.of(context).requestFocus(FocusNode()); // Close the keyboard
        DateTime? selectedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        if (selectedDate != null) {
          periodFromController.text = DateFormat('yyyy-MM-dd').format(selectedDate);

          // Automatically set Period To to one year after the selected date
          DateTime periodTo = DateTime(selectedDate.year + 1, selectedDate.month, selectedDate.day);
          periodToController.text = DateFormat('yyyy-MM-dd').format(periodTo);
        }
      },
    );
  }

  Widget _buildPeriodToTextField() {
    return TextFormField(
      controller: periodToController,
      decoration: _buildInputDecoration('Period To', Icons.date_range),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter an end date';
        }
        return null;
      },
      readOnly: true, // To prevent typing, only show the calendar
      onTap: () async {
        FocusScope.of(context).requestFocus(FocusNode()); // Close the keyboard
        DateTime? selectedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        if (selectedDate != null) {
          periodToController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
        }
      },
    );
  }



  InputDecoration _buildInputDecoration(String labelText, IconData icon) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(
        fontWeight: FontWeight.w400,
        color: Colors.grey,
      ),
      prefixIcon: Icon(icon, color: Colors.green),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.0),
        borderSide: const BorderSide(color: Colors.green, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.0),
        borderSide: const BorderSide(color: Colors.green, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.0),
        borderSide: const BorderSide(color: Colors.purple, width: 2.0),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      isDense: true,
    );
  }
}