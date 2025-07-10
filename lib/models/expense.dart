import 'package:hive/hive.dart';

part 'expense.g.dart';

@HiveType(typeId: 0)
class Expense extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  double amount;

  @HiveField(2)
  String format; // Cash, Credit, Debit, Check

  @HiveField(3)
  String type; // Food, Transportation, etc.

  Expense({
    required this.date,
    required this.amount,
    required this.format,
    required this.type,
  });
}
