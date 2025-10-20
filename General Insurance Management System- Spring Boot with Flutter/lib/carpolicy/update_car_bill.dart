import 'package:flutter/material.dart';
import 'package:general_insurance_management_system/carpolicy/view_car_bill.dart';
import 'package:general_insurance_management_system/model/carbill_model.dart';
import 'package:general_insurance_management_system/model/carpolicy_model.dart';
import 'package:general_insurance_management_system/service/carbill_service.dart';
import 'package:general_insurance_management_system/service/carpolicy_service.dart';



class UpdateCarBill extends StatefulWidget {
  const UpdateCarBill({Key? key, required this.bill}) : super(key: key);

  final CarBillModel bill;

  @override
  State<UpdateCarBill> createState() => _UpdateCarBillState();
}

class _UpdateCarBillState extends State<UpdateCarBill> {
  final TextEditingController carRateController = TextEditingController();
  final TextEditingController rsdController = TextEditingController();
  final TextEditingController netPremiumController = TextEditingController();
  final TextEditingController taxController = TextEditingController();
  final TextEditingController grossPremiumController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final CarBillService billService = CarBillService();

  List<CarPolicyModel> policies = [];
  List<String> uniqueBankNames = [];
  List<double> uniqueSumInsured = [];
  String? selectedPolicyholder;
  String? selectedBankName;
  double? selectedSumInsured;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _populateInitialData();
    _setupListeners();
  }

  void _populateInitialData() {
    carRateController.text = widget.bill.carRate.toString();
    rsdController.text = widget.bill.rsd.toString();
    netPremiumController.text = widget.bill.netPremium.toString();
    taxController.text = widget.bill.tax.toString();
    grossPremiumController.text = widget.bill.grossPremium.toString();
    selectedPolicyholder = widget.bill.carPolicy.policyholder;
    selectedBankName = widget.bill.carPolicy.bankName;
    selectedSumInsured = widget.bill.carPolicy.sumInsured;
  }

  Future<void> _fetchData() async {
    try {
      policies = await CarPolicyService().fetchPolicies();
      uniqueBankNames = policies
          .map((policy) => policy.bankName)
          .where((bankName) => bankName != null)
          .cast<String>()
          .toSet()
          .toList();

      uniqueSumInsured = policies
          .map((policy) => policy.sumInsured)
          .where((sumInsured) => sumInsured != null)
          .cast<double>()
          .toSet()
          .toList();

      setState(() {
        if (policies.isNotEmpty) {
          selectedPolicyholder = selectedPolicyholder ?? policies.first.policyholder;
          selectedBankName = selectedBankName ?? uniqueBankNames.first;
          selectedSumInsured = selectedSumInsured ?? uniqueSumInsured.first;
        }
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $error')),
      );
    }
  }

  void _setupListeners() {
    carRateController.addListener(_updateCalculatedFields);
    rsdController.addListener(_updateCalculatedFields);
  }

  void _updateCalculatedFields() {
    calculatePremiums();
  }

  void _updateBill() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        final selectedPolicy = policies.firstWhere(
              (policy) => policy.policyholder == selectedPolicyholder,
          orElse: () => CarPolicyModel(policyholder: '', id: null),
        );

        if (selectedPolicy.id == null) {
          _showErrorSnackBar('Selected policy does not have a valid ID');
          return;
        }

        await billService.updateBill(
          widget.bill.id!,
          CarBillModel(
            carRate: double.parse(carRateController.text),
            rsd: double.parse(rsdController.text),
            netPremium: double.parse(netPremiumController.text),
            tax: double.parse(taxController.text),
            grossPremium: double.parse(grossPremiumController.text),
            carPolicy: selectedPolicy,
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Car Bill Updated Successfully!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AllCarBillView()),
        );
      } catch (error) {
        _showErrorSnackBar('Error: $error');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    setState(() {
      isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void calculatePremiums() {
    double sumInsured = selectedSumInsured ?? 0.0;
    double carRate = _parseControllerValue(carRateController.text);
    double rsd = _parseControllerValue(rsdController.text);
    const double taxRate = 15.0;

    if (carRate > 100 || rsd > 100 || taxRate > 100) {
      _showErrorSnackBar('Rates must be less than or equal to 100%');
      return;
    }

    double netPremium = (sumInsured * (carRate + rsd)) / 100;
    double grossPremium = netPremium + (netPremium * taxRate) / 100;

    setState(() {
      netPremiumController.text = netPremium.toStringAsFixed(2);
      taxController.text = taxRate.toStringAsFixed(2);
      grossPremiumController.text = grossPremium.toStringAsFixed(2);
    });
  }

  double _parseControllerValue(String value) {
    return double.tryParse(value) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Fire Bill Form'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              _buildDropdownField(),
              const SizedBox(height: 20),
              _buildDropdownBankNameField(),
              const SizedBox(height: 20),
              _buildDropdownSumInsuredField(),
              const SizedBox(height: 20),
              _buildTextField(carRateController, 'Fire Rate', Icons.fire_extinguisher),
              const SizedBox(height: 20),
              _buildTextField(rsdController, 'Rsd Rate', Icons.dangerous),
              const SizedBox(height: 20),
              _buildReadOnlyField(netPremiumController, 'Net Premium', Icons.monetization_on),
              const SizedBox(height: 20),
              _buildReadOnlyField(taxController, 'Tax', Icons.money),
              const SizedBox(height: 20),
              _buildReadOnlyField(grossPremiumController, 'Gross Premium', Icons.monetization_on),
              const SizedBox(height: 20),
              _buildSubmitButton(),
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
        onPressed: _updateBill,
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
          "Update Fire Bill",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: selectedPolicyholder,
      onChanged: isLoading ? null : (String? newValue) {
        setState(() {
          selectedPolicyholder = newValue;
          final selectedPolicy = policies.firstWhere(
                (policy) => policy.policyholder == newValue,
            orElse: () => CarPolicyModel(policyholder: '', id: null, sumInsured: 0.0, bankName: ''),
          );
          selectedSumInsured = selectedPolicy.sumInsured;
          selectedBankName = selectedPolicy.bankName;
        });
      },
      decoration: _buildInputDecoration('Policyholder', Icons.person),
      items: policies.map<DropdownMenuItem<String>>((CarPolicyModel policy) {
        return DropdownMenuItem<String>(
          value: policy.policyholder,
          child: Text(policy.policyholder ?? '', style: TextStyle(fontSize: 14)),
        );
      }).toList(),
    );
  }

  Widget _buildDropdownBankNameField() {
    return DropdownButtonFormField<String>(
      value: selectedBankName,
      onChanged: isLoading ? null : (String? newValue) {
        setState(() {
          selectedBankName = newValue;
        });
      },
      decoration: _buildInputDecoration('Bank Name', Icons.account_balance),
      items: uniqueBankNames.map<DropdownMenuItem<String>>((String bankName) {
        return DropdownMenuItem<String>(
          value: bankName,
          child: Text(bankName,style: TextStyle(fontSize: 14)),
        );
      }).toList(),
    );
  }

  Widget _buildDropdownSumInsuredField() {
    return DropdownButtonFormField<double>(
      value: selectedSumInsured,
      onChanged: isLoading ? null : (double? newValue) {
        setState(() {
          selectedSumInsured = newValue;
        });
      },
      decoration: _buildInputDecoration('Sum Insured', Icons.account_balance_wallet),
      items: uniqueSumInsured.map<DropdownMenuItem<double>>((double sumInsured) {
        return DropdownMenuItem<double>(
          value: sumInsured,
          child: Text(sumInsured.toStringAsFixed(2)),
        );
      }).toList(),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: _buildInputDecoration(label, icon),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a value';
        }
        return null;
      },
    );
  }

  Widget _buildReadOnlyField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: _buildInputDecoration(label, icon),
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