import 'package:flutter/material.dart';
import 'package:general_insurance_management_system/carpolicy/view_car_policy.dart';
import 'package:general_insurance_management_system/firepolicy/view_firepolicy.dart';
import 'package:general_insurance_management_system/model/carpolicy_model.dart';
import 'package:general_insurance_management_system/model/firepolicy_model.dart';
import 'package:general_insurance_management_system/service/carpolicy_service.dart';
import 'package:general_insurance_management_system/service/firepolicy_service.dart';
import 'package:intl/intl.dart';

class UpdateCarPolicy extends StatefulWidget {
  const UpdateCarPolicy({super.key, required this.policy});

  final CarPolicyModel policy;

  @override
  State<UpdateCarPolicy> createState() => _UpdateCarPolicyState();
}

class _UpdateCarPolicyState extends State<UpdateCarPolicy> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController policyholderController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController stockInsuredController = TextEditingController();
  final TextEditingController sumInsuredController = TextEditingController();
  final TextEditingController interestInsuredController = TextEditingController();
  final TextEditingController coverageController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController ownerController = TextEditingController();
  final TextEditingController periodFromController = TextEditingController();
  final TextEditingController periodToController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final CarPolicyService policyService = CarPolicyService();

  final List<String> constructionTypes = [
    '1st Class',
    '2nd Class',
    '3rd Class'
  ];
  final List<String> usageTypes = [
    'Shop Only',
    'Godown Only',
    'Shop-Cum-Godown only'
  ];

  String? selectedConstruction;
  String? selectedusedAs;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    selectedConstruction = widget.policy.construction;
    selectedusedAs = widget.policy.usedAs;
    dateController.text = widget.policy.date != null
        ? DateFormat('yyyy-MM-dd').format(widget.policy.date!)
        : '';
    bankNameController.text = widget.policy.bankName ?? '';
    policyholderController.text = widget.policy.policyholder ?? '';
    addressController.text = widget.policy.address ?? '';
    stockInsuredController.text = widget.policy.stockInsured ?? '';
    sumInsuredController.text = widget.policy.sumInsured?.toString() ?? '';
    interestInsuredController.text = widget.policy.interestInsured ?? '';
    coverageController.text = widget.policy.coverage ?? '';
    locationController.text = widget.policy.location ?? '';
    ownerController.text = widget.policy.owner ?? '';
    periodFromController.text = widget.policy.periodFrom != null
        ? DateFormat('yyyy-MM-dd').format(widget.policy.periodFrom!)
        : '';
    periodToController.text = widget.policy.periodTo != null
        ? DateFormat('yyyy-MM-dd').format(widget.policy.periodTo!)
        : '';
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
    ownerController.dispose();
    periodFromController.dispose();
    periodToController.dispose();
    super.dispose();
  }

  void _updateCarPolicy() async {
    if (_formKey.currentState!.validate()) {
      int? id = widget.policy.id;
      PolicyModel policy = PolicyModel(
        id: id,
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
        usedAs: selectedusedAs ?? '',
        periodFrom: DateTime.parse(periodFromController.text),
        periodTo: DateTime.parse(periodToController.text),
      );

      try {
        await policyService.updateCarPolicy(id!, policy as CarPolicyModel);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AllCarPolicyView()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Car Policy updated successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating Fire Policy: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Car Policy Form'),
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
                _buildDateTextField(
                    dateController, 'Date', 'Please select a date'),
                SizedBox(height: 20),
                _buildTextField(bankNameController, 'Bank Name',
                    Icons.account_balance, 'Please enter a bank name'),
                SizedBox(height: 20),
                _buildTextField(policyholderController, 'Policyholder',
                    Icons.person, 'Please enter the policyholder name'),
                SizedBox(height: 20),
                _buildTextField(addressController, 'Address', Icons.location_on,
                    'Please enter an address'),
                SizedBox(height: 20),
                _buildTextField(stockInsuredController, 'Stock Insured',
                    Icons.inventory, 'Please enter the stock insured'),
                SizedBox(height: 20),
                _buildNumberTextField(sumInsuredController, 'Sum Insured',
                    Icons.money, 'Please enter the sum insured'),
                SizedBox(height: 20),
                _buildTextField(interestInsuredController, 'Interest Insured',
                    Icons.info, 'Please enter interest insured details'),
                SizedBox(height: 20),
                _buildTextField(coverageController, 'Coverage',
                    Icons.assignment, 'Please enter the coverage details',
                    readOnly: true),
                SizedBox(height: 20),
                _buildTextField(locationController, 'Location',
                    Icons.location_city, 'Please enter the location'),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: selectedConstruction,
                  decoration:
                  _buildInputDecoration('Construction Type', Icons.build),
                  items: constructionTypes.map((type) {
                    return DropdownMenuItem<String>(
                        value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedConstruction = value;
                    });
                  },
                  validator: (value) => value == null
                      ? 'Please select a construction type'
                      : null,
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: selectedusedAs,
                  decoration: _buildInputDecoration('Used As', Icons.business),
                  items: usageTypes.map((type) {
                    return DropdownMenuItem<String>(
                        value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedusedAs = value;
                    });
                  },
                  validator: (value) =>
                  value == null ? 'Please select how it is used' : null,
                ),
                SizedBox(height: 20),
                _buildTextField(ownerController, 'Owner', Icons.person,
                    'Please enter the owner name',
                    readOnly: true),
                SizedBox(height: 20),
                _buildDateTextField(periodFromController, 'Period From',
                    'Please enter a valid date',
                    isPeriodFrom: true),
                SizedBox(height: 20),
                _buildDateTextField(periodToController, 'Period To',
                    'Please enter a valid date'),
                SizedBox(height: 20),
                _buildSubmitButton(),
                SizedBox(height: 20),
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
        onPressed: _updateCarPolicy,
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
          "Update Fire Policy",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  TextFormField _buildTextField(TextEditingController controller, String label,
      IconData icon, String errorMsg,
      {bool readOnly = false}) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      decoration: _buildInputDecoration(label, icon),
      validator: (value) => value!.isEmpty ? errorMsg : null,
    );
  }

  TextFormField _buildNumberTextField(TextEditingController controller,
      String label, IconData icon, String errorMsg) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: _buildInputDecoration(label, icon),
      validator: (value) =>
      value!.isEmpty || double.tryParse(value) == null ? errorMsg : null,
    );
  }


  TextFormField _buildDateTextField(TextEditingController controller, String label, String errorMsg, {bool isPeriodFrom = false}) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: _buildInputDecoration(label, Icons.calendar_today),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: isPeriodFrom ? DateTime.now() : DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null) {
          setState(() {
            controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
            if (isPeriodFrom) {
              // Set 'Period To' to exactly 1 year after 'Period From'
              periodToController.text = DateFormat('yyyy-MM-dd').format(pickedDate.add(const Duration(days: 365)));
            }
          });
        }
      },
      validator: (value) => value!.isEmpty ? errorMsg : null,
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