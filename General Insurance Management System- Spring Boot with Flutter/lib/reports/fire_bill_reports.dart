import 'package:flutter/material.dart';
import 'package:general_insurance_management_system/model/firebill_model.dart';
import 'package:general_insurance_management_system/service/firebill_service.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';

class FireBillReportPage extends StatefulWidget {
  const FireBillReportPage({super.key});

  @override
  State<FireBillReportPage> createState() => _FireBillReportPageState();
}

class _FireBillReportPageState extends State<FireBillReportPage> {
  late int billCount = 0;
  late double totalNetPremium = 0.0;
  late double totalTax = 0.0;
  late double totalGrossPremium = 0.0;

  List<FirebillModel> allBills = [];
  List<FirebillModel> filteredBills = [];

  DateTime? startDate;
  DateTime? endDate;

  bool isLoading = true;
  bool isError = false;

  final double _shadowScale = 1.0;
  final double _buttonScale = 1.0;

  @override
  void initState() {
    _fetchAllBills();
    super.initState();
  }

  _fetchAllBills() async {
    try {
      allBills = await BillService().fetchAllFireBills();
      setState(() {
        filteredBills = allBills;
        _updateStatistics();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        isError = true;
      });
      print('Error fetching bills: $e');
    }
  }

  _updateStatistics() {
    billCount = filteredBills.length;
    totalNetPremium = calculateTotalNetPremium();
    totalTax = calculateTotalTax();
    totalGrossPremium = calculateTotalGrossPremium();
  }

  double calculateTotalNetPremium() {
    return filteredBills.fold(0.0, (total, bill) => total + (bill.netPremium ?? 0));
  }

  double calculateTotalTax() {
    return totalNetPremium * 0.15; // 15% tax
  }

  double calculateTotalGrossPremium() {
    return filteredBills.fold(0.0, (total, bill) => total + (bill.grossPremium ?? 0));
  }

  _filterBillsByDateRange(DateTime start, DateTime end) {
    setState(() {
      filteredBills = allBills.where((bill) {
        DateTime? billDate = bill.firePolicy.date;
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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isSmallScreen = width < 600;

    Map<String, double> dataMap = {
      "Net Premium": totalNetPremium,
      "Tax (15%)": totalTax,
      "Gross Premium": totalGrossPremium,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fire Bill Report'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.purple.withOpacity(0.8),
                Colors.green.withOpacity(0.8),
                Colors.orange.withOpacity(0.8),
                Colors.red.withOpacity(0.8),
                Colors.deepPurpleAccent.withOpacity(0.8),
                Colors.limeAccent.withOpacity(0.8),
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
              // 🔹 Date Filter Section
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
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 10 : 20,
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

              // 🔹 Loading / Error / Data Display
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (isError)
                const Center(child: Text('Error fetching data.'))
              else if (filteredBills.isEmpty)
                  const Text(
                    'No bills found for the selected date range.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  )
                else
                  Column(
                    children: [
                      // 🔸 Responsive Stat Cards
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: [
                          SizedBox(
                              width: isSmallScreen ? width * 0.9 : width * 0.45,
                              child: _buildStatCard('Bills', billCount.toDouble(), Colors.blue)),
                          SizedBox(
                              width: isSmallScreen ? width * 0.9 : width * 0.45,
                              child: _buildStatCard('Net Premium', totalNetPremium, Colors.orange)),
                          SizedBox(
                              width: isSmallScreen ? width * 0.9 : width * 0.45,
                              child: _buildStatCard('Tax (15%)', totalTax, Colors.red)),
                          SizedBox(
                              width: isSmallScreen ? width * 0.9 : width * 0.45,
                              child: _buildStatCard('Gross Premium', totalGrossPremium, Colors.green)),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // 🔸 Pie Chart Section
                      const Text(
                        'Premium Distribution',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade100,
                        ),
                        child: PieChart(
                          dataMap: dataMap,
                          animationDuration: const Duration(milliseconds: 800),
                          chartType: ChartType.disc,
                          chartRadius: isSmallScreen
                              ? width / 2.2
                              : width / 3, // Adjust chart size for small screens
                          colorList: [Colors.orange, Colors.red, Colors.green],
                          chartValuesOptions: const ChartValuesOptions(
                            showChartValuesInPercentage: true,
                            decimalPlaces: 1,
                          ),
                          legendOptions: LegendOptions(
                            showLegends: true,
                            legendPosition: isSmallScreen
                                ? LegendPosition.bottom
                                : LegendPosition.right,
                            legendTextStyle: TextStyle(
                                fontSize: isSmallScreen ? 12 : 14,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),

              const SizedBox(height: 40),

              // 🔹 Navigation Buttons
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/home'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 24 : 30,
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
                          filteredBills = allBills;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade700,
                        padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 24 : 30,
                            vertical: isSmallScreen ? 12 : 16),
                      ),
                      child: const Text(
                        'Clear Date Filter',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔸 Responsive Stat Card Widget
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
