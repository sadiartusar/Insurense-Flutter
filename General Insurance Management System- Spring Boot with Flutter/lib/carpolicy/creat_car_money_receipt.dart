import 'package:flutter/material.dart';
import 'package:general_insurance_management_system/carpolicy/view_car_money_receipt.dart';
import 'package:general_insurance_management_system/model/carbill_model.dart';
import 'package:general_insurance_management_system/model/carmoneyreceipt_model.dart';
import 'package:general_insurance_management_system/model/carpolicy_model.dart';
import 'package:general_insurance_management_system/service/carbill_service.dart';
import 'package:general_insurance_management_system/service/carmoneyreceipt_service.dart';
import 'package:intl/intl.dart';


class CreateCarMoneyReceipt extends StatefulWidget {
  const CreateCarMoneyReceipt({super.key});

  @override
  State<CreateCarMoneyReceipt> createState() => _CreateCarMoneyReceiptState();
}

class _CreateCarMoneyReceiptState extends State<CreateCarMoneyReceipt> {
  final TextEditingController issuingOfficeController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController modeOfPaymentController = TextEditingController();
  final TextEditingController issuedAgainstController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final CarMoneyReceiptService moneyReceiptService = CarMoneyReceiptService();

  List<CarBillModel> filteredBills = [];
  List<CarBillModel> bills = [];
  List<String> uniqueBankNames = [];
  List<double> uniqueSumInsured = [];
  String? selectedPolicyholder;
  String? selectedBankName;
  double? selectedSumInsured;
  String? selectedClassOfInsurance;
  String? selectedModeOfPayment;
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();


  final List<String> classOfInsuranceOptions = [
    'Fire Insurance',
    'Car Insurance',
  ];

  final List<String> modeOfPaymentOptions = [
    'Cash',
    'Credit Card',
    'Bank Transfer',
    'Cheque'
  ];

  @override
  void initState() {
    super.initState();
    _fetchData();
    searchController.addListener(_filterPolicyholders);


    // Set the current date to the dateController
    dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);
    try {
      bills = await CarBillService().fetchAllCarBills();
      uniqueBankNames = bills.map((carBill) => carBill.carPolicy.bankName).whereType<String>().toSet().toList();
      uniqueSumInsured = bills.map((carBill) => carBill.carPolicy.sumInsured).whereType<double>().toSet().toList();

      if (bills.isNotEmpty) {
        setState(() {
          filteredBills = List.from(bills);
          selectedPolicyholder = bills.first.carPolicy.policyholder;
          selectedBankName = bills.first.carPolicy.bankName ?? uniqueBankNames.first;
          selectedSumInsured = bills.first.carPolicy.sumInsured ?? uniqueSumInsured.first;
        });
      }
    } catch (error) {
      _showErrorSnackBar('Error fetching data: $error');
      print('Error fetching data: $error');
    } finally {
      setState(() => isLoading = false);
    }
  }


  void _filterPolicyholders() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredBills = bills.where((carBill) {
        return carBill.carPolicy.policyholder?.toLowerCase().contains(query) ?? false;
      }).toList();
    });
  }

  void _createMoneyReceipt() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      try {
        final selectedPolicy = bills.firstWhere(
              (carBill) =>
              carBill.carPolicy.policyholder == selectedPolicyholder,
        );

        if (selectedPolicy.id == null) {
          _showErrorSnackBar('Selected policy does not have a valid ID');
          return;
        }

        await moneyReceiptService.createMoneyReceipt(
          CarMoneyReceiptModel(
            issuingOffice: issuingOfficeController.text,
            classOfInsurance: selectedClassOfInsurance!,
            modeOfPayment: selectedModeOfPayment!,
            date: DateTime.parse(dateController.text),
            issuedAgainst: issuedAgainstController.text,
            carBill: selectedPolicy,
          ),
          selectedPolicy.id!,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Car Money Receipt created successfully!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AllCarMoneyReceiptView()),
        );
      } catch (error) {
        _showErrorSnackBar('Error: $error');
        print('Error creating receipt: $error');
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Car Money Receipt Form'),
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              _buildSearchField(),
              const SizedBox(height: 20),
              _buildDropdownField(),
              SizedBox(height: 20),
              _buildDropdownBankNameField(),
              SizedBox(height: 20),
              _buildDropdownSumInsuredField(),
              SizedBox(height: 20),
              _buildTextField(issuingOfficeController, 'Issuing Office',
                  Icons.production_quantity_limits_outlined),
              SizedBox(height: 20),
              _buildClassOfInsuranceDropdown(),
              SizedBox(height: 20),
              _buildDateField(),
              SizedBox(height: 20),
              _buildModeOfPaymentDropdown(),
              // Icons.attach_money),
              SizedBox(height: 20),
              _buildTextField(issuedAgainstController, 'Issued Against',
                  Icons.receipt),
              SizedBox(height: 20),
              _buildSubmitButton(),
              const SizedBox(height: 20),
            ],
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
        onPressed: _createMoneyReceipt,
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
          "Create Money Receipt",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: searchController,
      decoration: _inputDecoration('Search Policyholder',Icons.search),
    );

  }

  Widget _buildDropdownField() {
    // Extract unique policyholders from filteredBills
    final uniquePolicyholders = {
      for (var carBill in filteredBills) carBill.carPolicy.policyholder
    }.where((policyholder) => policyholder != null).cast<String>().toList();

    // Set the initial selected value if none has been set
    if (selectedPolicyholder == null && uniquePolicyholders.isNotEmpty) {
      selectedPolicyholder = uniquePolicyholders.first;
    }

    return DropdownButtonFormField<String>(
      initialValue: uniquePolicyholders.contains(selectedPolicyholder) ? selectedPolicyholder : null,
      onChanged: isLoading ? null : (String? newValue) {
        setState(() {
          selectedPolicyholder = newValue;

          // Find the first bill with the selected policyholder
          final selectedBill = bills.firstWhere(
                (carBill) => carBill.carPolicy.policyholder == selectedPolicyholder,
            orElse: () => CarBillModel(
              carPolicy: CarPolicyModel(bankName: null, sumInsured: null),
              carRate: 0.0, // Default value
              rsd: 0.0, // Default value
              netPremium: 0.0, // Default value
              tax: 0.0, // Default value
              grossPremium: 0.0, // Default value
            ),
          );

          // Update bankName and sumInsured based on selected policyholder's policy
          selectedSumInsured = selectedBill.carPolicy.sumInsured;
          selectedBankName = selectedBill.carPolicy.bankName;
        });
      },
      decoration: _inputDecoration('Policyholder', Icons.person),
      items: uniquePolicyholders.map<DropdownMenuItem<String>>((String policyholder) {
        return DropdownMenuItem<String>(
          value: policyholder,
          child: Text(policyholder, style: const TextStyle(fontSize: 14)),
        );
      }).toList(),
    );
  }




  Widget _buildDropdownBankNameField() {
    return DropdownButtonFormField<String>(
      initialValue: selectedBankName,
      onChanged: isLoading
          ? null
          : (String? newValue) {
        setState(() {
          selectedBankName = newValue;
        });
      },
      decoration: _inputDecoration('Bank Name', Icons.account_balance),
      items: uniqueBankNames.map<DropdownMenuItem<String>>((String bankName) {
        return DropdownMenuItem<String>(
          value: bankName,
          child: Text(bankName,  style: TextStyle(fontSize: 14)),
        );
      }).toList(),
    );
  }

  Widget _buildDropdownSumInsuredField() {
    return DropdownButtonFormField<double>(
      initialValue: selectedSumInsured,
      onChanged: isLoading
          ? null
          : (double? newValue) {
        setState(() {
          selectedSumInsured = newValue;
        });
      },
      decoration: _inputDecoration('Sum Insured', Icons.account_balance_wallet),
      items:
      uniqueSumInsured.map<DropdownMenuItem<double>>((double sumInsured) {
        return DropdownMenuItem<double>(
          value: sumInsured,
          child: Text(sumInsured.toString()),
        );
      }).toList(),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: _inputDecoration(label, icon),
      validator: (value) =>
      value == null || value.isEmpty ? 'Please enter $label' : null,
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: dateController,
      decoration: _inputDecoration('Date', Icons.date_range),
      readOnly: true,
      onTap: () async {
        FocusScope.of(context).requestFocus(FocusNode()); // Unfocus the field
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null) {
          setState(() {
            dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
          });
        }
      },
      validator: (value) =>
      value == null || value.isEmpty ? 'Please select a date' : null,
    );
  }

  Widget _buildClassOfInsuranceDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: selectedClassOfInsurance,
      onChanged: (String? newValue) {
        setState(() {
          selectedClassOfInsurance = newValue;
        });
      },
      decoration: _inputDecoration('Class of Insurance', Icons.category),
      items:
      classOfInsuranceOptions.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      validator: (value) =>
      value == null || value.isEmpty ? 'Please select a class' : null,
    );
  }

  Widget _buildModeOfPaymentDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: selectedModeOfPayment,
      onChanged: (String? newValue) {
        setState(() {
          selectedModeOfPayment = newValue;
        });
      },
      decoration: _inputDecoration('Mode of Payment', Icons.category),
      items: modeOfPaymentOptions.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      validator: (value) =>
      value == null || value.isEmpty ? 'Please select a Payment' : null,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
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
      fillColor: Colors.white,
    );
  }


}