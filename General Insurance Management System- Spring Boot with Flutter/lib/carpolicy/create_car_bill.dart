import 'package:flutter/material.dart';
import 'package:general_insurance_management_system/carpolicy/all_car_bill_list_view.dart';
import 'package:general_insurance_management_system/model/carbill_model.dart';
import 'package:general_insurance_management_system/model/carpolicy_model.dart';
import 'package:general_insurance_management_system/service/carbill_service.dart';
import 'package:general_insurance_management_system/service/carpolicy_service.dart';

class CreateCarBill extends StatefulWidget {
  const CreateCarBill({super.key});

  @override
  State<CreateCarBill> createState() => _CreateCarBillState();
}

class _CreateCarBillState extends State<CreateCarBill> {
  final TextEditingController carRateController = TextEditingController();
  final TextEditingController rsdController = TextEditingController();
  final TextEditingController netPremiumController = TextEditingController();
  final TextEditingController taxController = TextEditingController();
  final TextEditingController grossPremiumController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final CarBillService billService = CarBillService();

  List<CarPolicyModel> policies = [];
  List<CarPolicyModel> filteredPolicies = [];
  List<String> uniqueBankNames = [];
  List<double> uniqueSumInsured = [];
  String? selectedPolicyholder;
  String? selectedBankName;
  double? selectedSumInsured;
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
    _setupListeners();
    searchController.addListener(_filterPolicyholders);
  }

  Future<void> _fetchData() async {
    try {
      policies = await CarPolicyService().fetchPolicies();
      filteredPolicies = List.from(policies);
      uniqueBankNames = policies.map((p) => p.bankName).whereType<String>().toSet().toList();
      uniqueSumInsured = policies.map((p) => p.sumInsured).whereType<double>().toSet().toList();

      setState(() {
        if (policies.isNotEmpty) {
          selectedPolicyholder = policies.first.policyholder;
          selectedBankName = policies.first.bankName ?? uniqueBankNames.first;
          selectedSumInsured = policies.first.sumInsured ?? uniqueSumInsured.first;
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
    taxController.addListener(_updateCalculatedFields);
  }

  void _filterPolicyholders() {
    final query = searchController.text.toLowerCase();

    setState(() {
      filteredPolicies = policies.where((policy) {
        final holder = policy.policyholder?.toLowerCase() ?? '';
        return holder.contains(query);
      }).toList();
    });
  }


  void _updateCalculatedFields() => calculatePremiums();

  void _createCarBill() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      try {
        final selectedPolicy = policies.firstWhere(
              (p) => p.policyholder == selectedPolicyholder,
          orElse: () => CarPolicyModel(policyholder: '', id: null),
        );

        if (selectedPolicy.id == null) {
          _showErrorSnackBar('❌ Selected policy does not have a valid ID');
          return;
        }

        final newBill = CarBillModel(
          carRate: double.parse(carRateController.text),
          rsd: double.parse(rsdController.text),
          netPremium: _parseControllerValue(netPremiumController.text),
          tax: _parseControllerValue(taxController.text),
          grossPremium: _parseControllerValue(grossPremiumController.text),
          carPolicy: selectedPolicy,
        );

        final createdBill = await billService.createCarBill(newBill);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Car Bill Created Successfully!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AllCarBillListView()),
        );
      } catch (error) {
        _showErrorSnackBar('Error: $error');
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String msg) {
    setState(() => isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void calculatePremiums() {
    double sumInsured = selectedSumInsured ?? 0.0;
    double carRate = _parseControllerValue(carRateController.text);
    double rsd = _parseControllerValue(rsdController.text);
    const double taxRate = 15.0;

    double netPremium = (sumInsured * (carRate + rsd)) / 100;
    double grossPremium = netPremium + (netPremium * taxRate) / 100;

    netPremium = (netPremium + 0.5).toInt().toDouble();
    grossPremium = (grossPremium + 0.5).toInt().toDouble();

    setState(() {
      netPremiumController.text = netPremium.toStringAsFixed(0);
      taxController.text = taxRate.toStringAsFixed(2);
      grossPremiumController.text = grossPremium.toStringAsFixed(0);
    });
  }

  double _parseControllerValue(String v) => double.tryParse(v) ?? 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Car Bill Form'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSearchField(),
              const SizedBox(height: 20),
              _buildDropdownField(),
              const SizedBox(height: 20),
              _buildDropdownBankNameField(),
              const SizedBox(height: 20),
              _buildDropdownSumInsuredField(),
              const SizedBox(height: 20),
              _buildTextField(carRateController, 'Car Rate'),
              const SizedBox(height: 20),
              _buildTextField(rsdController, 'RSD Rate'),
              const SizedBox(height: 20),
              _buildReadOnlyField(netPremiumController, 'Net Premium'),
              const SizedBox(height: 20),
              _buildReadOnlyField(taxController, 'Tax Rate'),
              const SizedBox(height: 20),
              _buildReadOnlyField(grossPremiumController, 'Gross Premium'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createCarBill,
                child: const Text("Create Car Bill"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() => TextField(
    controller: searchController,
    decoration: const InputDecoration(labelText: 'Search Policyholder'),
  );

  Widget _buildDropdownField() {
    final uniquePolicyholders = {
      for (var policy in filteredPolicies) policy.policyholder
    }.whereType<String>().toList();

    return DropdownButtonFormField<String>(
      value: uniquePolicyholders.contains(selectedPolicyholder) ? selectedPolicyholder : null,
      onChanged: (val) {
        setState(() {
          selectedPolicyholder = val;
          final selectedPolicy = policies.firstWhere(
                (p) => p.policyholder == selectedPolicyholder,
            orElse: () => CarPolicyModel(bankName: null, sumInsured: null),
          );
          selectedBankName = selectedPolicy.bankName;
          selectedSumInsured = selectedPolicy.sumInsured;
        });
      },
      items: uniquePolicyholders.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
      decoration: const InputDecoration(labelText: 'Policy Holder'),
    );
  }

  Widget _buildDropdownBankNameField() => DropdownButtonFormField<String>(
    value: selectedBankName,
    onChanged: (val) => setState(() => selectedBankName = val),
    items: uniqueBankNames.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
    decoration: const InputDecoration(labelText: 'Bank Name'),
  );

  Widget _buildDropdownSumInsuredField() => DropdownButtonFormField<double>(
    value: selectedSumInsured,
    onChanged: (val) => setState(() => selectedSumInsured = val),
    items: uniqueSumInsured.map((s) => DropdownMenuItem(value: s, child: Text(s.toString()))).toList(),
    decoration: const InputDecoration(labelText: 'Sum Insured'),
  );

  Widget _buildTextField(TextEditingController c, String label) => TextFormField(
    controller: c,
    keyboardType: TextInputType.number,
    decoration: InputDecoration(labelText: label),
    validator: (v) => v == null || v.isEmpty ? 'Enter $label' : null,
  );

  Widget _buildReadOnlyField(TextEditingController c, String label) => TextFormField(
    controller: c,
    readOnly: true,
    decoration: InputDecoration(labelText: label),
  );


}
