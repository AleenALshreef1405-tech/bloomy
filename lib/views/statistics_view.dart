import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StatisticsView extends StatefulWidget {
  const StatisticsView({super.key});

  @override
  State<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> {
  final supabase = Supabase.instance.client;

  Map<int, String> weeklyFlowers = {}; // رقم اليوم ← اسم الشعور
  String mostFrequentWeeklyFlower = "Loading...";

  Map<String, int> monthlyFlowers = {};
  String mostFrequentMonthlyFlower = "Loading...";

  bool isLoading = true;

  final dayLabels = const {
    1: "Mon",
    2: "Tue",
    3: "Wed",
    4: "Thu",
    5: "Fri",
    6: "Sat",
    7: "Sun",
  };

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));

      final weeklyResponse = await supabase
          .from('garden_flowers')
          .select('flower_name, created_at')
          .eq('user_id', user.id)
          .gte('created_at', startOfWeek.toIso8601String())
          .lte('created_at', endOfWeek.toIso8601String());

      Map<int, String> tempWeek = {};
      Map<String, int> weekFreq = {};

      for (var row in weeklyResponse) {
        final date = DateTime.parse(row['created_at']).toLocal();
        final weekday = date.weekday;
        final flower = row['flower_name'] ?? 'Unknown';
        tempWeek[weekday] = flower;
        weekFreq[flower] = (weekFreq[flower] ?? 0) + 1;
      }

      // حساب المشاعر الشهرية
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      final monthlyResponse = await supabase
          .from('garden_flowers')
          .select('flower_name')
          .eq('user_id', user.id)
          .gte('created_at', startOfMonth.toIso8601String())
          .lte('created_at', endOfMonth.toIso8601String());

      Map<String, int> monthFreq = {};
      for (var row in monthlyResponse) {
        final flower = row['flower_name'] ?? 'Unknown';
        monthFreq[flower] = (monthFreq[flower] ?? 0) + 1;
      }

      String mostCommonWeek = weekFreq.entries.isNotEmpty
          ? weekFreq.entries.reduce((a, b) => a.value > b.value ? a : b).key
          : "None";
      String mostCommonMonth = monthFreq.entries.isNotEmpty
          ? monthFreq.entries.reduce((a, b) => a.value > b.value ? a : b).key
          : "None";

      setState(() {
        weeklyFlowers = tempWeek;
        mostFrequentWeeklyFlower = mostCommonWeek;
        monthlyFlowers = monthFreq;
        mostFrequentMonthlyFlower = mostCommonMonth;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading statistics: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F2),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWeeklyStatisticsCard(),
                    const SizedBox(height: 20),
                    _buildMonthlyStatisticsCard(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildWeeklyStatisticsCard() {
    final colors = [
      Colors.pinkAccent,
      Colors.purpleAccent,
      Colors.cyan,
      Colors.orange,
      Colors.amber,
      Colors.deepOrange,
      Colors.teal
    ];
    final values = List<double>.filled(7, 6.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFBEE3CB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Weekly Statistics",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF064232))),
          const SizedBox(height: 4),
          Text("This Week (${_getDateRangeText()})",
              style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 10),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 48,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index < 0 || index >= 7) {
                          return const SizedBox();
                        }
                        final dayLabel = dayLabels[index + 1]!;
                        final flower = weeklyFlowers[index + 1] ?? "–";
                        final hasFlower = weeklyFlowers.containsKey(index + 1);

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              flower,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                color: hasFlower
                                    ? Colors.black87
                                    : Colors.grey.shade500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dayLabel,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(7, (i) {
                  final hasFlower = weeklyFlowers.containsKey(i + 1);
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: values[i],
                        color: hasFlower
                            ? colors[i % colors.length]
                            : Colors.grey.shade400,
                        width: 18,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text("• Your most frequent feeling this week: $mostFrequentWeeklyFlower",
              style: const TextStyle(fontSize: 14, color: Color(0xFF064232))),
        ],
      ),
    );
  }

  Widget _buildMonthlyStatisticsCard() {
    final total = monthlyFlowers.values.fold<int>(0, (a, b) => a + b);
    final colors = [
      Colors.pinkAccent,
      Colors.purpleAccent,
      Colors.orangeAccent,
      Colors.cyan,
      Colors.teal,
      Colors.amber,
      Colors.lightBlueAccent,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF5F2), Color(0xFFDDEBFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Monthly Statistics",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF064232))),
          const SizedBox(height: 4),
          Text("This Month (${_getMonthName(DateTime.now().month)})",
              style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: monthlyFlowers.isEmpty
                ? const Center(
                    child: Text("No data yet!",
                        style: TextStyle(color: Colors.black45)),
                  )
                : PieChart(
                    PieChartData(
                      centerSpaceRadius: 60,
                      sectionsSpace: 4,
                      sections: List.generate(monthlyFlowers.length, (i) {
                        final flower = monthlyFlowers.keys.elementAt(i);
                        final count = monthlyFlowers[flower]!;
                        final percentage = (count / total) * 100;
                        return PieChartSectionData(
                          color: colors[i % colors.length],
                          value: count.toDouble(),
                          title: "${percentage.toStringAsFixed(0)}%",
                          radius: 50,
                          titleStyle: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        );
                      }),
                    ),
                  ),
          ),
          const SizedBox(height: 10),
          Text("• Most frequent this month: $mostFrequentMonthlyFlower",
              style: const TextStyle(fontSize: 14, color: Color(0xFF064232))),
          const SizedBox(height: 4),
          Text("• Total feelings recorded this month: $total",
              style: const TextStyle(fontSize: 13, color: Colors.black54)),
        ],
      ),
    );
  }

  String _getDateRangeText() {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    final end = start.add(const Duration(days: 6));
    return "${start.day}–${end.day} ${_getMonthName(now.month)}";
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}
