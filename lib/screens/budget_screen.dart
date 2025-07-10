import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense.dart';
import '../models/budget.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _budgetController = TextEditingController();

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  double _monthlyTotal(List<Expense> expenses) {
    final now = DateTime.now();
    return expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budget Viewer 💸')),
      body: ValueListenableBuilder<Box<Expense>>(
        valueListenable: Hive.box<Expense>('expenses').listenable(),
        builder: (context, expBox, _) {
          final expenses = expBox.values.toList();
          final spent = _monthlyTotal(expenses);
          return ValueListenableBuilder<Box<Budget>>(
            valueListenable: Hive.box<Budget>('budget').listenable(),
            builder: (context, budBox, _) {
              double budget = budBox.isNotEmpty ? budBox.getAt(0)!.monthlyBudget : 0.0;
              if (budget == 0.0) {
                _budgetController.text = '';
              } else {
                _budgetController.text = budget.toStringAsFixed(2);
              }
              double remaining = (budget - spent).clamp(0, budget);
              double percent = budget > 0 ? (spent / budget).clamp(0, 1) : 0;
              String message;
              Widget emoji = Text('🟢', style: TextStyle(fontSize: 32));
              if (percent < 0.3) {
                message = "You're doing great!";
                emoji = Text('🟢', style: TextStyle(fontSize: 32));
              } else if (percent < 0.8) {
                message = "Keep tracking your expenses!";
                emoji = Text('🧮', style: TextStyle(fontSize: 32));
              } else if (percent < 1.0) {
                message = "Warning: You're almost out of budget!";
                emoji = Text('⚠️', style: TextStyle(fontSize: 32));
              } else {
                message = "You went over your budget this month!";
                emoji = TweenAnimationBuilder<double>(
                  tween: Tween(begin: 1.0, end: 1.2),
                  duration: Duration(milliseconds: 600),
                  curve: Curves.elasticInOut,
                  builder: (context, scale, child) => Transform.scale(
                    scale: scale,
                    child: child,
                  ),
                  child: Text('💸', style: TextStyle(fontSize: 36)),
                );
              }
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.account_balance_wallet, color: Color(0xFFFFC542)),
                          SizedBox(width: 8),
                          Text('Monthly Budget', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF6C63FF))),
                        ],
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _budgetController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Set Monthly Budget',
                          prefixIcon: Icon(Icons.edit, color: Color(0xFF6C63FF)),
                        ),
                        onFieldSubmitted: (val) {
                          final b = double.tryParse(val) ?? 0.0;
                          if (budBox.isEmpty) {
                            budBox.add(Budget(monthlyBudget: b));
                          } else {
                            budBox.putAt(0, Budget(monthlyBudget: b));
                          }
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 24),
                      Text('Spent this month: \$${spent.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: percent > 1.0 ? 1.0 : 1 - percent,
                          minHeight: 18,
                          backgroundColor: Color(0xFFB6F09C),
                          color: percent < 0.8 ? Color(0xFF43B581) : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Remaining: \$${remaining.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 24),
                      Center(
                        child: Column(
                          children: [
                            emoji,
                            SizedBox(height: 8),
                            Text(
                              message,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: percent < 0.8 ? Color(0xFF43B581) : Colors.red,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
