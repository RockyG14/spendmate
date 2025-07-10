// This file initializes Hive and opens boxes for expenses and budget.
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/expense.dart';
import 'models/budget.dart';

Future<void> initLocalStorage() async {
  await Hive.initFlutter();
  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(BudgetAdapter());
  await Hive.openBox<Expense>('expenses');
  await Hive.openBox<Budget>('budget');
}
