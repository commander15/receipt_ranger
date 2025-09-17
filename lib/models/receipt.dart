import 'package:hive/hive.dart';

part 'receipt.g.dart';

@HiveType(typeId: 0)
class Receipt extends HiveObject {
  @HiveField(0)
  final String number;

  @HiveField(1)
  final DateTime date;

  Receipt({required this.number, required this.date});

  @override
  String toString() {
    return { 'number': number, 'date': date }.toString();
  }
}
