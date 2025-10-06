import 'package:flutter/material.dart';
import 'package:general_insurance_management_system/firepolicy/all_firebill_details.dart';
import 'package:general_insurance_management_system/firepolicy/create_fire_bill.dart';
import 'package:general_insurance_management_system/firepolicy/update_fire_bill.dart';
import 'package:general_insurance_management_system/model/firebill_model.dart';
import 'package:general_insurance_management_system/service/firebill_service.dart';


class AllFireBillView extends StatefulWidget {
  const AllFireBillView({Key? key}) : super(key: key);

  @override
  State<AllFireBillView> createState() => _AllFireBillViewState();
}

class _AllFireBillViewState extends State<AllFireBillView> {
  late Future<List<FirebillModel>> futureBills;
  List<FirebillModel> allBills = []; // Store all bills
  List<FirebillModel> filteredBills = []; // Store filtered bills
  String searchQuery = ''; // Store the search query
  DateTime? startDate;
  DateTime? endDate;
  final TextStyle commonStyle = const TextStyle(fontSize: 14, color: Colors.black);
  final TextEditingController searchController = TextEditingController();



  @override
  void initState() {
    super.initState();
    final service = BillService();
    futureBills = service.fetchAllFireBills().then((bills) {
      allBills = bills; // Initialize allBills with fetched data
      filteredBills = allBills; // Initially show all bills
      return bills;
    });

    // Optional: Debounce search input to reduce the number of times filtering occurs
    searchController.addListener(() {
      Future.delayed(const Duration(milliseconds: 300), () {
        _filterBills(searchController.text);
      });
    });
  }

  // Function to format DateTime as only date (without time)
  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

// Updated _filterBills function
  void _filterBills(String query) {
    setState(() {
      searchQuery = query.toLowerCase(); // Update the search query
      // Filter the bills based on ID, policyholder, or bank name
      filteredBills = allBills.where((bill) {
        final policyholder = bill.firePolicy.policyholder?.toLowerCase() ?? '';
        final bankName = bill.firePolicy.bankName?.toLowerCase() ?? '';
        final id = bill.id.toString();

        // Check if the bill matches the search query
        bool matchesSearch = policyholder.contains(searchQuery) ||
            bankName.contains(searchQuery) ||
            id.contains(searchQuery);

        // Check if the bill matches the date range
        bool matchesDateRange = true;

        if (startDate != null && endDate != null) {
          // Normalize the policy date to ignore the time portion
          DateTime policyDate = bill.firePolicy.date is DateTime
              ? normalizeDate(bill.firePolicy.date as DateTime)
              : normalizeDate(DateTime.parse(bill.firePolicy.date as String));

          // Normalize start and end dates
          DateTime start = normalizeDate(startDate!);
          DateTime end = normalizeDate(endDate!);

          // Check if the policy date is within the selected range (inclusive)
          matchesDateRange = (policyDate.isAtSameMomentAs(start) || policyDate.isAfter(start)) &&
              (policyDate.isAtSameMomentAs(end) || policyDate.isBefore(end));
        }

        return matchesSearch && matchesDateRange;
      }).toList();
    });
  }

// Function to normalize a DateTime object to only its date
  DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day); // Keeps only the year, month, and day
  }

// Future for selecting date range
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTime? pickedStartDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedStartDate != null) {
      final DateTime? pickedEndDate = await showDatePicker(
        context: context,
        initialDate: pickedStartDate.add(const Duration(days: 1)),
        firstDate: pickedStartDate,
        lastDate: DateTime(2100),
      );

      if (pickedEndDate != null) {
        setState(() {
          startDate = pickedStartDate;
          endDate = pickedEndDate;
        });
        _filterBills(searchQuery); // Re-filter the bills when date range is updated
      }
    }
  }

// Example Usage
// To display formatted date only without time
  void displayFormattedDate(DateTime date) {
    print(formatDate(date)); // Example: "15-11-2024"
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fire Bill List'),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context, '/home');
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search ',
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(color: Colors.green, width: 1.0),
                ),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search, color: Colors.green),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(color: Colors.green, width: 1.0),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10), // Add some spacing below the search bar
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _selectDateRange(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10), // Adjust padding as needed
                ),
                child: Row(
                  children: const [
                    Icon(Icons.calendar_today, color: Colors.green),
                    SizedBox(width: 5),
                    Text(
                      'Select Date Rang',
                      style: TextStyle(color: Colors.green),
                    ),
                  ],
                ),
              ),
              if (startDate != null && endDate != null) ...[
                const SizedBox(width: 10),
                Text(
                  'From: ${startDate != null ? formatDate(startDate!) : ''} To: ${endDate != null ? formatDate(endDate!) : ''}',
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ],
            ],
          ),


          const SizedBox(height: 10),
          Expanded(
            child: FutureBuilder<List<FirebillModel>>(
              future: futureBills,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No bills available'));
                } else {
                  return ListView.builder(
                    itemCount: filteredBills.length,
                    itemBuilder: (context, index) {
                      final bill = filteredBills[index];
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.red,
                              Colors.orange,
                              Colors.yellow,
                              Colors.green,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        margin: const EdgeInsets.all(10),
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bill No : ${bill.firePolicy.id ?? 'N/A'}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  bill.firePolicy.bankName ?? 'Unnamed Policy',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  bill.firePolicy.policyholder ?? 'No policyholder available',
                                  style: commonStyle,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        bill.firePolicy.address ?? 'No address',
                                        style: commonStyle,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Tk ${bill.firePolicy.sumInsured?.toString() ?? 'No sum'}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Fire: ${bill.fire.toString() ?? 'No data'}%', style: commonStyle),
                                    Text('RSD: ${bill.rsd.toString() ?? 'No data'}%', style: commonStyle),
                                    Text('Net: ${bill.netPremium.toString() ?? 'No data'}', style: commonStyle),
                                    Text('Tax: ${bill.tax.toString() ?? 'No data'}%', style: commonStyle),
                                    Text('Gross: ${bill.grossPremium.toString() ?? 'No data'}', style: commonStyle),
                                  ],
                                ),
                                _buildActionButtons(bill),
                              ],
                            ),
                          ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateFireBill()),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildActionButtons(FirebillModel bill) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.visibility, color: Colors.blue),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AllFireBillDetails(bill: bill)),
            );
          },
          tooltip: 'View Details',
        ),
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            _confirmDeleteBill(bill.id!);
          },
          tooltip: 'Delete Bill',
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.cyan),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UpdateFireBill(bill: bill),
              ),
            );
          },
          tooltip: 'Edit Bill',
        ),

      ],
    );
  }


  // Method to calculate the total number of bills
  int calculateBillCount() {
    return filteredBills.length; // Simply count the number of filtered bills
  }

  double calculateTotalNetPremium() {
    // Assuming filteredBills contains the bills you want to sum up
    return filteredBills.fold(0.0, (total, bill) => total + (bill.netPremium ?? 0));
  }

  double calculateTotalTax() {
    double totalNetPremium = calculateTotalNetPremium();
    return totalNetPremium * 0.15; // 15% tax of the total net premium
  }

  double calculateTotalGrossPremium() {
    // Sum up the gross premium of all filtered bills
    return filteredBills.fold(0.0, (total, bill) => total + (bill.grossPremium ?? 0));
  }



  void _confirmDeleteBill(int billId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this bill?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteBill(billId); // Call your delete method
                Navigator.pop(context); // Close the dialog
                // Show the snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fire Bill deleted successfully!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }


  void _deleteBill(int billId) async {
    final service = BillService();
    try {
      await service.deleteBill(billId); // Delete the bill
      setState(() {
        futureBills = service.fetchAllFireBills(); // Reload the bills
      });
    } catch (e) {
      print('Error deleting bill: $e');
    }
  }
}