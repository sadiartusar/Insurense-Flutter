import 'package:flutter/material.dart';
import 'package:general_insurance_management_system/model/carpolicy_model.dart';
import 'package:general_insurance_management_system/service/carpolicy_service.dart';
import 'package:intl/intl.dart';

class CarPolicyReportPage extends StatefulWidget {
  const CarPolicyReportPage({super.key});

  @override
  State<CarPolicyReportPage> createState() => _CarPolicyReportPageState();
}

class _CarPolicyReportPageState extends State<CarPolicyReportPage> {
  late int policyCount = 0;
  late double totalSumInsurd = 0.0;

  List<CarPolicyModel> allPolicy = [];
  List<CarPolicyModel> filteredPolicy = [];

  DateTime? startDate;
  DateTime? endDate;

  bool isLoading = true;
  bool isError = false;

  double _buttonScale = 1.0;

  @override
  void initState() {
    _fetchAllPolicy();
    super.initState();
  }

  _fetchAllPolicy() async {
    try {
      allPolicy = await CarPolicyService().fetchPolicies();
      setState(() {
        filteredPolicy = allPolicy;
        _updateStatistics();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        isError = true;
      });
      print('Error fetching policies: $e');
    }
  }

  _updateStatistics() {
    policyCount = filteredPolicy.length;
    totalSumInsurd = calculateTotalSumInsurd();
  }

  _filterBillsByDateRange(DateTime start, DateTime end) {
    setState(() {
      filteredPolicy = allPolicy.where((policy) {
        DateTime? billDate = policy.date;
        if (billDate == null) return false;
        return billDate.isAfter(start.subtract(const Duration(days: 1))) &&
            billDate.isBefore(end.add(const Duration(days: 1)));
      }).toList();
      _updateStatistics();
    });
  }

  _selectDateRange() async {
    DateTimeRange? pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedRange != null) {
      setState(() {
        startDate = pickedRange.start;
        endDate = pickedRange.end;
      });
      _filterBillsByDateRange(startDate!, endDate!);
    }
  }

  double calculateTotalSumInsurd() {
    return filteredPolicy.fold(0.0, (sum, policy) => sum + (policy.sumInsured ?? 0.0));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width; // responsive width
    final isSmallScreen = width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Policy Report'),
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
        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section (Date filter)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: isSmallScreen ? 1 : 0,
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 300),
                      scale: _buttonScale,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _selectDateRange,
                        onHover: (isHovered) {
                          setState(() {
                            _buttonScale = isHovered ? 1.1 : 1.0;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 8 : 16,
                              vertical: isSmallScreen ? 10 : 14),
                        ),
                        child: const Text(
                          'Date Wise Report',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  if (startDate != null && endDate != null)
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          "From: ${DateFormat('yyyy-MM-dd').format(startDate!)}\nTo: ${DateFormat('yyyy-MM-dd').format(endDate!)}",
                          style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // Loading or Error State
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (isError)
                const Center(child: Text('Error fetching data.'))
              else if (filteredPolicy.isEmpty)
                  const Text(
                    'No policies found for the selected date range.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  )
                else
                  Column(
                    children: [
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: [
                          SizedBox(
                              width: isSmallScreen ? width * 0.9 : width * 0.45,
                              child: _buildStatCard(
                                  'Car Policy', policyCount.toDouble(), Colors.blue)),
                          SizedBox(
                              width: isSmallScreen ? width * 0.9 : width * 0.45,
                              child: _buildStatCard(
                                  'Total Sum Insured', totalSumInsurd, Colors.orange)),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),

              const SizedBox(height: 40),

              // Navigation Buttons
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/home'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 20 : 30,
                          vertical: isSmallScreen ? 12 : 16),
                    ),
                    child: const Text(
                      'Go to Home',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (startDate != null && endDate != null)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          startDate = null;
                          endDate = null;
                          filteredPolicy = allPolicy;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade700,
                        padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 20 : 30,
                            vertical: isSmallScreen ? 12 : 16),
                      ),
                      child: const Text(
                        'Clear Date Filter',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, double value, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value.toStringAsFixed(2),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
