import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/expense.dart';

class BreakdownScreen extends StatefulWidget {
  const BreakdownScreen({super.key});

  @override
  State<BreakdownScreen> createState() => _BreakdownScreenState();
}

class _BreakdownScreenState extends State<BreakdownScreen> {
  String _filter = 'Last 1 Month';
  final List<String> _filters = [
    'Last 1 Day', 'Last 1 Week', 'Last 1 Month', 'Last 6 Months'
  ];

  List<Expense> _filteredExpenses(List<Expense> all) {
    final now = DateTime.now();
    DateTime from;
    switch (_filter) {
      case 'Last 1 Day':
        from = now.subtract(const Duration(days: 1));
        break;
      case 'Last 1 Week':
        from = now.subtract(const Duration(days: 7));
        break;
      case 'Last 1 Month':
        from = DateTime(now.year, now.month - 1, now.day);
        break;
      case 'Last 6 Months':
        from = DateTime(now.year, now.month - 6, now.day);
        break;
      default:
        from = DateTime(2000);
    }
    return all.where((e) => e.date.isAfter(from)).toList();
  }

  Map<String, double> _categoryTotals(List<Expense> expenses) {
    final map = <String, double>{};
    for (var e in expenses) {
      map[e.type] = (map[e.type] ?? 0) + e.amount;
    }
    return map;
  }

  Map<String, double> _formatTotals(List<Expense> expenses) {
    final map = <String, double>{};
    for (var e in expenses) {
      map[e.format] = (map[e.format] ?? 0) + e.amount;
    }
    return map;
  }

  // Pie chart color helper
  List<Color> greenShades(int count) {
    return List.generate(count, (i) => Color.lerp(Color(0xFF43B581), Color(0xFFB6F09C), i / (count > 1 ? (count - 1) : 1))!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Spending Breakdown 🥧')),
      body: ValueListenableBuilder<Box<Expense>>(
        valueListenable: Hive.box<Expense>('expenses').listenable(),
        builder: (context, box, _) {
          final all = box.values.toList();
          final filtered = _filteredExpenses(all);
          final catTotals = _categoryTotals(filtered);
          final fmtTotals = _formatTotals(filtered);
          return ListView(
            padding: const EdgeInsets.all(8),
            children: [
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.filter_alt, color: Color(0xFF6C63FF)),
                          SizedBox(width: 8),
                          Expanded(
                            child: DropdownButton<String>(
                              value: _filter,
                              items: _filters.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                              onChanged: (val) => setState(() => _filter = val!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...filtered.map((e) => Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        child: ListTile(
                          leading: Icon(Icons.monetization_on, color: Color(0xFFB6F09C)),
                          title: Text('${e.date.year}-${e.date.month.toString().padLeft(2, '0')}-${e.date.day.toString().padLeft(2, '0')}', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${e.format} – ${e.type}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('\$ ${e.amount.toStringAsFixed(2)}', style: TextStyle(color: Color(0xFF43B581), fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.redAccent),
                                tooltip: 'Delete',
                                onPressed: () async {
                                  final box = Hive.box<Expense>('expenses');
                                  await e.delete();
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('By Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      SizedBox(
                        height: 180,
                        child: PieChart(
                          PieChartData(
                            sections: [
                              for (var i = 0; i < catTotals.entries.length; i++)
                                PieChartSectionData(
                                  value: catTotals.entries.elementAt(i).value,
                                  title: catTotals.entries.elementAt(i).key.length > 8 ? catTotals.entries.elementAt(i).key.substring(0, 7) + '…' : catTotals.entries.elementAt(i).key,
                                  color: greenShades(catTotals.length)[i],
                                  radius: 60,
                                  titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                  badgeWidget: Tooltip(
                                    message: catTotals.entries.elementAt(i).key,
                                    child: SizedBox.shrink(),
                                  ),
                                ),
                            ],
                            sectionsSpace: 2,
                            centerSpaceRadius: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('By Format', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      SizedBox(
                        height: 180,
                        child: PieChart(
                          PieChartData(
                            sections: [
                              for (var i = 0; i < fmtTotals.entries.length; i++)
                                PieChartSectionData(
                                  value: fmtTotals.entries.elementAt(i).value,
                                  title: fmtTotals.entries.elementAt(i).key.length > 8 ? fmtTotals.entries.elementAt(i).key.substring(0, 7) + '…' : fmtTotals.entries.elementAt(i).key,
                                  color: greenShades(fmtTotals.length)[i],
                                  radius: 60,
                                  titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                  badgeWidget: Tooltip(
                                    message: fmtTotals.entries.elementAt(i).key,
                                    child: SizedBox.shrink(),
                                  ),
                                ),
                            ],
                            sectionsSpace: 2,
                            centerSpaceRadius: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
