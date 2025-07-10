import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/expense.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _date = DateTime.now();
  final _amountController = TextEditingController();
  String _format = 'Cash';
  String _type = 'Food';

  final List<String> _formats = ['Cash', 'Credit', 'Debit', 'Check'];
  final List<String> _types = [
    'Food', 'Transportation', 'Fun', 'School', 'Health', 'Shopping', 'Subscriptions', 'Other'
  ];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      final expense = Expense(
        date: _date,
        amount: double.parse(_amountController.text),
        format: _format,
        type: _type,
      );
      final box = Hive.box<Expense>('expenses');
      await box.add(expense);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 1.0, end: 1.1),
                        duration: Duration(milliseconds: 700),
                        curve: Curves.elasticInOut,
                        builder: (context, scale, child) => Transform.scale(
                          scale: scale,
                          child: child,
                        ),
                        child: Text('📝', style: TextStyle(fontSize: 32)),
                      ),
                      SizedBox(width: 8),
                      Text('Add Expense', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF43B581))),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ListTile(
                    leading: Icon(Icons.calendar_today, color: Color(0xFFB6F09C)),
                    title: const Text('Date'),
                    subtitle: Text('${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF6C63FF)),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _date,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() => _date = picked);
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixIcon: Icon(Icons.attach_money, color: Color(0xFF43B581)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Enter amount';
                      if (double.tryParse(value) == null) return 'Enter valid number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _format,
                    items: _formats.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                    onChanged: (val) => setState(() => _format = val!),
                    decoration: const InputDecoration(
                      labelText: 'Format',
                      prefixIcon: Icon(Icons.payment, color: Color(0xFFB6F09C)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _type,
                    items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (val) => setState(() => _type = val!),
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      prefixIcon: Icon(Icons.category, color: Color(0xFF43B581)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _saveExpense,
                    icon: Icon(Icons.check_circle, color: Color(0xFFB6F09C)),
                    label: const Text('Submit'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 48),
                      backgroundColor: Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
