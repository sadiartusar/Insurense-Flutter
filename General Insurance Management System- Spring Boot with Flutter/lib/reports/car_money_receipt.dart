import 'package:flutter/material.dart';
import 'package:general_insurance_management_system/model/carmoneyreceipt_model.dart';
import 'package:general_insurance_management_system/service/carmoneyreceipt_service.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:intl/intl.dart';

class CarMoneyReceiptReportPage extends StatefulWidget {
  @override
  State<CarMoneyReceiptReportPage> createState() => _CarMoneyReceiptReportPageState();
}

class _CarMoneyReceiptReportPageState extends State<CarMoneyReceiptReportPage> {
  late int billCount = 0;
  late double totalNetPremium = 0.0;
  late double totalTax = 0.0;
  late double totalGrossPremium = 0.0;

  List<CarMoneyReceiptModel> allMoneyReceipt = [];
  List<CarMoneyReceiptModel> filteredMoneyReceipt = [];

  DateTime? startDate;
  DateTime? endDate;

  bool isLoading = true; // Track loading state
  bool isError = false; // Track error state

  double _shadowScale = 1.0;
  double _buttonScale = 1.0; // For Button Animation

  @override
  void initState() {
    _fetchMoneyReceipts();
    super.initState();
  }

  _fetchMoneyReceipts() async {
    try {
      allMoneyReceipt = await CarMoneyReceiptService().fetchMoneyReceipts();
      setState(() {
        filteredMoneyReceipt = allMoneyReceipt; // Initially show all bills
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
    billCount = filteredMoneyReceipt.length;
    totalNetPremium = calculateTotalNetPremium();
    totalTax = calculateTotalTax();
    totalGrossPremium = calculateTotalGrossPremium();
  }

  double calculateTotalNetPremium() {
    return filteredMoneyReceipt.fold(0.0, (total, moneyreceipt) => total + (moneyreceipt.carBill?.netPremium ?? 0));
  }

  double calculateTotalTax() {
    return totalNetPremium * 0.15; // 15% tax
  }

  double calculateTotalGrossPremium() {
    return filteredMoneyReceipt.fold(
        0.0, (total, moneyreceipt) => total + (moneyreceipt.carBill?.grossPremium ?? 0));
  }

  _filterBillsByDateRange(DateTime start, DateTime end) {
    setState(() {
      filteredMoneyReceipt = allMoneyReceipt.where((bill) {
        DateTime? billDate = bill.date; // Corrected reference to 'bill'
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
    Map<String, double> dataMap = {
      "Net Premium": totalNetPremium,
      "Tax (15%)": totalTax,
      "Gross Premium": totalGrossPremium,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Money Receipt Report'),
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
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AnimatedScale(
                    duration: const Duration(milliseconds: 300),
                    scale: _buttonScale,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () {
                        setState(() {
                          _buttonScale = 1.1;
                        });
                        _selectDateRange();
                      },
                      onHover: (isHovered) {
                        setState(() {
                          _buttonScale = isHovered ? 1.1 : 1.0;
                        });
                      },
                      child: isLoading
                          ? CircularProgressIndicator()
                          : const Text('Date Wise Report'),
                    ),
                  ),
                  if (startDate != null && endDate != null)
                    Text(
                      "From: ${DateFormat('yyyy-MM-dd').format(startDate!)} To: ${DateFormat('yyyy-MM-dd').format(endDate!)}",
                      style: const TextStyle(fontSize: 14),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : isError
                  ? const Center(child: Text('Error fetching data.'))
                  : filteredMoneyReceipt.isEmpty
                  ? const Text('No bills found for the selected date range.')
                  : Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard('Fire Money Receipt', billCount.toDouble(), Colors.blue),
                      _buildStatCard('Net Premium', totalNetPremium, Colors.orange),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard('Tax (15%)', totalTax, Colors.red),
                      _buildStatCard('Gross Premium', totalGrossPremium, Colors.green),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Premium Distribution',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: MouseRegion(
                      onEnter: (_) {
                        setState(() {
                          _shadowScale = 1.1; // Increase scale on hover
                        });
                      },
                      onExit: (_) {
                        setState(() {
                          _shadowScale = 1.0; // Reset scale when the mouse leaves
                        });
                      },
                      child: PieChart(
                        key: ValueKey(_shadowScale),
                        dataMap: dataMap,
                        animationDuration: const Duration(milliseconds: 800),
                        chartType: ChartType.disc,
                        chartRadius: MediaQuery.of(context).size.width / 2.5,
                        colorList: [Colors.orange, Colors.red, Colors.green],
                        chartValuesOptions: const ChartValuesOptions(
                          showChartValuesInPercentage: true,
                        ),
                        legendOptions: const LegendOptions(
                          showLegends: true,
                          legendPosition: LegendPosition.right,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 100),
              AnimatedScale(
                duration: const Duration(milliseconds: 300),
                scale: _buttonScale,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/home');
                  },
                  child: const Text('Go to Home', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, double value, Color color) {
    return Expanded(
      child: MouseRegion(
        onEnter: (_) {
          setState(() {
            _shadowScale = 1.1;
          });
        },
        onExit: (_) {
          setState(() {
            _shadowScale = 1.0;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          transform: Matrix4.identity()..scale(_shadowScale, _shadowScale),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                offset: const Offset(0, 5),
                blurRadius: 15,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value.toStringAsFixed(2),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}