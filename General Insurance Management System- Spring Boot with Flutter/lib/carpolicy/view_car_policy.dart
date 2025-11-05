import 'package:flutter/material.dart';
import 'package:general_insurance_management_system/carpolicy/all_car_policy_details.dart';
import 'package:general_insurance_management_system/carpolicy/create_car_policy.dart';
import 'package:general_insurance_management_system/carpolicy/update_car_policy.dart';
import 'package:general_insurance_management_system/model/carpolicy_model.dart';
import 'package:general_insurance_management_system/service/carpolicy_service.dart';


class AllCarPolicyView extends StatefulWidget {
  const AllCarPolicyView({super.key});

  @override
  State<AllCarPolicyView> createState() => _AllCarPolicyViewState();
}

class _AllCarPolicyViewState extends State<AllCarPolicyView>
    with TickerProviderStateMixin {
  late Future<List<CarPolicyModel>> futurePolicies;
  final CarPolicyService carPolicyService = CarPolicyService();
  final TextStyle commonStyle = const TextStyle(fontSize: 14, color: Colors.black);
  String searchTerm = '';
  List<CarPolicyModel> allPolicies = [];
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    loadPolicies();
  }

  Future<void> loadPolicies() async {
    futurePolicies = carPolicyService.fetchPolicies();
    setState(() {});
  }

  Future<void> _confirmDeletePolicy(int policyId) async {
    bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this policy?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.delete, color: Colors.white),
            label: const Text('Delete'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await _deletePolicy(policyId);
    }
  }

  Future<void> _deletePolicy(int policyId) async {
    try {
      await carPolicyService.deleteCarPolicy(policyId);
      await loadPolicies();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Policy deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting policy: $e')),
      );
    }
  }

  void _filterPolicies(String query) {
    setState(() {
      searchTerm = query.toLowerCase();
    });
  }

  List<CarPolicyModel> _getFilteredPolicies() {
    List<CarPolicyModel> filteredPolicies = allPolicies;

    if (startDate != null && endDate != null) {
      filteredPolicies = filteredPolicies.where((policy) {
        final rawDate = policy.date; // <-- use your real field here
        if (rawDate == null) return false;

        final policyDate = rawDate;

        return policyDate.isAfter(startDate!) && policyDate.isBefore(endDate!);
      }).toList();
    }


    if (searchTerm.isNotEmpty) {
      filteredPolicies = filteredPolicies.where((policy) {
        final policyholder = policy.policyholder?.toLowerCase() ?? '';
        final bankName = policy.bankName?.toLowerCase() ?? '';
        final id = policy.id.toString();
        return policyholder.contains(searchTerm) ||
            bankName.contains(searchTerm) ||
            id.contains(searchTerm);
      }).toList();
    }

    return filteredPolicies;
  }

  Future<void> _selectStartDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null && selectedDate != startDate) {
      setState(() {
        startDate = selectedDate;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null && selectedDate != endDate) {
      setState(() {
        endDate = selectedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Policy List', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 5,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orangeAccent, Colors.redAccent, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushNamed(context, '/home'),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        child: Column(
          children: [
            _buildSearchBar(),
            // _buildDateFilterRow(),
            Expanded(
              child: FutureBuilder<List<CarPolicyModel>>(
                future: futurePolicies,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No policy available'));
                  } else {
                    allPolicies = snapshot.data!;
                    final filteredPolicies = _getFilteredPolicies();
                    return AnimatedList(
                      key: GlobalKey<AnimatedListState>(),
                      initialItemCount: filteredPolicies.length,
                      itemBuilder: (context, index, animation) {
                        final carPolicy = filteredPolicies[index];
                        return SlideTransition(
                          position: Tween<Offset>(
                              begin: const Offset(0, 0.1), end: Offset.zero)
                              .animate(CurvedAnimation(
                              parent: animation, curve: Curves.easeOut)),
                          child: FadeTransition(
                            opacity: animation,
                            child: _buildPolicyCard(carPolicy),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateCarPolicy()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('New Policy'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: TextField(
        onChanged: _filterPolicies,
        decoration: InputDecoration(
          hintText: 'Search by ID, name, or bank',
          prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.deepPurpleAccent)),
        ),
      ),
    );
  }

  // Widget _buildDateFilterRow() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 6.0),
  //     child: Wrap(
  //       spacing: 10,
  //       alignment: WrapAlignment.center,
  //       children: [
  //         _animatedFilterButton(
  //             label: startDate == null
  //                 ? 'Select Start Date'
  //                 : 'Start: ${startDate!.toLocal().toString().split(' ')[0]}',
  //             onTap: () => _selectStartDate(context)),
  //         _animatedFilterButton(
  //             label: endDate == null
  //                 ? 'Select End Date'
  //                 : 'End: ${endDate!.toLocal().toString().split(' ')[0]}',
  //             onTap: () => _selectEndDate(context)),
  //       ],
  //     ),
  //   );
  // }

  Widget _animatedFilterButton({required String label, required VoidCallback onTap}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.date_range),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple.shade100,
          foregroundColor: Colors.deepPurple,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildPolicyCard(CarPolicyModel policy) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      tween: Tween(begin: 0.95, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            shadowColor: Colors.deepPurpleAccent.withOpacity(0.3),
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AllCarPolicyDetails(policy: policy)),
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.shade100,
                      Colors.deepPurple.shade200,
                      Colors.indigo.shade100,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bill No: ${policy.id}', style: commonStyle),
                    const SizedBox(height: 4),
                    Text(policy.bankName ?? 'Unnamed Policy',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    const SizedBox(height: 8),
                    Text(policy.policyholder ?? 'No policyholder', style: commonStyle),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(policy.address ?? 'No address', style: commonStyle),
                        Text(
                          'Tk ${policy.sumInsured ?? 'N/A'}',
                          style: const TextStyle(
                              color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.visibility, color: Colors.blueAccent),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    AllCarPolicyDetails(policy: policy)),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.cyan),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UpdateCarPolicy(policy: policy),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _confirmDeletePolicy(policy.id!),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
