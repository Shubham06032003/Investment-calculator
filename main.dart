import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Investment Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: _themeMode,
      home: InvestmentCalculator(onThemeToggle: _toggleTheme),
    );
  }
}

class InvestmentCalculator extends StatefulWidget {
  const InvestmentCalculator({super.key, required this.onThemeToggle});

  final VoidCallback onThemeToggle;

  @override
  State<InvestmentCalculator> createState() => _InvestmentCalculatorState();
}

class _InvestmentCalculatorState extends State<InvestmentCalculator> {
  final _monthlyInvestmentController = TextEditingController();
  final _sipReturnRateController = TextEditingController();
  final _sipInvestmentPeriodController = TextEditingController();
  final _lumpSumPrincipleController = TextEditingController();
  final _lumpSumReturnRateController = TextEditingController();
  final _lumpSumInvestmentPeriodController = TextEditingController();

  int _selectedTab = 0; // 0 for SIP, 1 for Lump Sum
  String _resultTitle = 'SIP Investment Growth';
  double _totalAmount = 0;
  double _totalInvested = 0;
  double _totalGained = 0;

  List<BarChartGroupData> _barChartData = [];
  List<FlSpot> _lineChartData = [];
  List<PieChartSectionData> _pieChartData = [];

  bool _showBarChart = true;
  bool _showLineChart = false;
  bool _showPieChart = false;

  @override
  void dispose() {
    _monthlyInvestmentController.dispose();
    _sipReturnRateController.dispose();
    _sipInvestmentPeriodController.dispose();
    _lumpSumPrincipleController.dispose();
    _lumpSumReturnRateController.dispose();
    _lumpSumInvestmentPeriodController.dispose();
    super.dispose();
  }

  void _calculateSip() {
    FocusScope.of(context).unfocus();
    final monthlyInvestment = double.tryParse(_monthlyInvestmentController.text);
    final annualReturnRate = double.tryParse(_sipReturnRateController.text);
    final investmentPeriod = double.tryParse(_sipInvestmentPeriodController.text);

    if (monthlyInvestment == null || annualReturnRate == null || investmentPeriod == null ||
        monthlyInvestment <= 0 || annualReturnRate < 0 || investmentPeriod <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid positive numbers for SIP')),
      );
      setState(() {
        _totalAmount = 0;
        _totalInvested = 0;
        _totalGained = 0;
        _barChartData = [];
        _lineChartData = [];
        _pieChartData = [];
      });
      return;
    }

    final monthlyRate = annualReturnRate / 100 / 12;
    final numberOfMonths = (investmentPeriod * 12).round();
    double futureValue = 0;
    _totalInvested = 0;

    _barChartData = [];
    _lineChartData = [];

    for (int i = 1; i <= numberOfMonths; i++) {
      futureValue = (futureValue + monthlyInvestment) * (1 + monthlyRate);
      _totalInvested += monthlyInvestment;

      if (i % 12 == 0) {
        final year = i ~/ 12;
        _barChartData.add(
          BarChartGroupData(
            x: year,
            barRods: [
              BarChartRodData(
                toY: _totalInvested,
                color: Colors.indigo.shade400,
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
              BarChartRodData(
                toY: futureValue - _totalInvested,
                color: Colors.deepPurple.shade400,
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        );
        _lineChartData.add(FlSpot(year.toDouble(), futureValue));
      }
    }

    _totalAmount = futureValue;
    _totalGained = _totalAmount - _totalInvested;

    _pieChartData = [
      PieChartSectionData(
        value: _totalInvested,
        color: Colors.indigo.shade400,
        title: 'Invested',
        radius: 80,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        value: _totalGained,
        color: Colors.deepPurple.shade400,
        title: 'Gained',
        radius: 80,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ];

    setState(() {});
  }

  void _calculateLumpSum() {
    FocusScope.of(context).unfocus();
    final principleInvested = double.tryParse(_lumpSumPrincipleController.text);
    final annualReturnRate = double.tryParse(_lumpSumReturnRateController.text);
    final investmentPeriod = double.tryParse(_lumpSumInvestmentPeriodController.text);

    if (principleInvested == null || annualReturnRate == null || investmentPeriod == null ||
        principleInvested <= 0 || annualReturnRate < 0 || investmentPeriod <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid positive numbers for Lump Sum')),
      );
      setState(() {
        _totalAmount = 0;
        _totalInvested = 0;
        _totalGained = 0;
        _barChartData = [];
        _lineChartData = [];
        _pieChartData = [];
      });
      return;
    }

    final futureValue = principleInvested *
        math.pow(1 + annualReturnRate / 100, investmentPeriod);
    _totalInvested = principleInvested;
    _totalGained = futureValue - principleInvested;

    _barChartData = [
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(
            toY: _totalInvested,
            color: Colors.indigo.shade400,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
          BarChartRodData(
            toY: _totalGained,
            color: Colors.deepPurple.shade400,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    ];

    _lineChartData = [
      FlSpot(0, principleInvested),
      FlSpot(investmentPeriod.toDouble(), futureValue.toDouble()),
    ];

    _pieChartData = [
      PieChartSectionData(
        value: _totalInvested,
        color: Colors.indigo.shade400,
        title: 'Invested',
        radius: 80,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        value: _totalGained,
        color: Colors.deepPurple.shade400,
        title: 'Gained',
        radius: 80,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ];

    _totalAmount = futureValue;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Investment Calculator',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: isDarkMode
                          ? const Icon(Icons.wb_sunny)
                          : const Icon(Icons.dark_mode_outlined),
                      onPressed: widget.onThemeToggle,
                    ),
                  ],
                ),
                const SizedBox(height: 16,width: 25,),
                // Tabs
                Container(
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _buildTabButton('SIP Investment', 0),
                      _buildTabButton('Lump Sum Investment', 1),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Input Section
                if (_selectedTab == 0) ...[
                  _buildInputSection(
                    'Monthly Investment',
                    _monthlyInvestmentController,
                    'Expected Return Rate (%)',
                    _sipReturnRateController,
                    'Investment Period (years)',
                    _sipInvestmentPeriodController,
                    'Calculate SIP',
                    _calculateSip,
                  ),
                ] else ...[
                  _buildInputSection(
                    'Principle Invested',
                    _lumpSumPrincipleController,
                    'Expected Return Rate (%)',
                    _lumpSumReturnRateController,
                    'Investment Period (years)',
                    _lumpSumInvestmentPeriodController,
                    'Calculate Lump Sum',
                    _calculateLumpSum,
                  ),
                ],
                const SizedBox(height: 24),
                // Result and Graph Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _resultTitle,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${_totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total Invested: ₹${_totalInvested.toStringAsFixed(2)} | Total Gained: ₹${_totalGained.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 14, color: Colors.green.shade400),
                    ),
                    const SizedBox(height: 24),
                    // Chart Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Compare with:', style: TextStyle(fontWeight: FontWeight.w500)),
                        Row(
                          children: [
                            _buildChartButton('Bar Chart', _showBarChart, () {
                              setState(() {
                                _showBarChart = true;
                                _showLineChart = false;
                                _showPieChart = false;
                              });
                            }),
                            _buildChartButton('Line Chart', _showLineChart, () {
                              setState(() {
                                _showBarChart = false;
                                _showLineChart = true;
                                _showPieChart = false;
                              });
                            }),
                            _buildChartButton('Pie Chart', _showPieChart, () {
                              setState(() {
                                _showBarChart = false;
                                _showLineChart = false;
                                _showPieChart = true;
                              });
                            }),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Chart Widget
                    _buildChart(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    final isSelected = _selectedTab == index;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTab = index;
            _resultTitle = isSelected ? _resultTitle : (index == 0 ? 'SIP Investment Growth' : 'Lump Sum Investment Growth');
            _totalAmount = 0;
            _totalInvested = 0;
            _totalGained = 0;
            _barChartData = [];
            _lineChartData = [];
            _pieChartData = [];
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.indigo.shade600 : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : (isDarkMode ? Colors.white70 : Colors.black87),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputSection(
      String label1,
      TextEditingController controller1,
      String label2,
      TextEditingController controller2,
      String label3,
      TextEditingController controller3,
      String buttonText,
      VoidCallback onPressed) {
    return Column(
      children: [
        _buildTextField(label1, controller1),
        const SizedBox(height: 16),
        _buildTextField(label2, controller2),
        const SizedBox(height: 16),
        _buildTextField(label3, controller3),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16,horizontal: 30),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
    );
  }

  Widget _buildChartButton(String title, bool isSelected, VoidCallback onTap) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.indigo.shade600
              : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : (isDarkMode ? Colors.white70 : Colors.black87),
          ),
        ),
      ),
    );
  }

  Widget _buildChart() {
    if (_showBarChart) {
      return SizedBox(
        height: 250,
        child: BarChart(
          BarChartData(
            barGroups: _barChartData,
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text('₹${value.toStringAsFixed(0)}', style: const TextStyle(fontSize: 10));
                    },
                  )),
              bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text('${value.toInt()}', style: const TextStyle(fontSize: 10));
                    },
                  )),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(show: true, drawVerticalLine: false),
          ),
        ),
      );
    } else if (_showLineChart) {
      return SizedBox(
        height: 250,
        child: LineChart(
          LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: _lineChartData,
                color: Colors.indigo.shade400,
                isCurved: true,
                belowBarData: BarAreaData(show: true, color: Colors.indigo.shade400.withOpacity(0.3)),
              ),
            ],
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text('₹${value.toStringAsFixed(0)}', style: const TextStyle(fontSize: 10));
                    },
                  )),
              bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text('Year ${value.toInt()}', style: const TextStyle(fontSize: 10));
                    },
                  )),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(show: true),
            borderData: FlBorderData(show: true),
          ),
        ),
      );
    } else if (_showPieChart) {
      return SizedBox(
        height: 250,
        child: PieChart(
          PieChartData(
            sections: _pieChartData,
            centerSpaceRadius: 40,
            sectionsSpace: 4,
          ),
        ),
      );
    }
    return Container(
      height: 250,
      alignment: Alignment.center,
      child: const Text('Enter values to see the graph', style: TextStyle(color: Colors.white54)),
    );
  }
}
