import 'dart:convert';
import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:receipt_ranger/models/receipt.dart';

class ReceiptService {
  final Box<Receipt> box = Hive.box<Receipt>('receipts');

  Future<int> getReceiptsCount() async {
    return box.length;
  }

  Future<List<DateTime>> getReceiptsDates() async {
    // Fetch all receipts
    List<Receipt> receipts = await getReceipts();

    // Extract unique dates by converting to a Set and back to List
    List<DateTime> dates = receipts
        .map(
          (receipt) =>
              DateTime(receipt.date.year, receipt.date.month, receipt.date.day),
        )
        .toSet()
        .toList();

    dates.sort();
    return dates;
  }

  Future<List<Receipt>> getReceipts({DateTime? date}) async {
    // Retrieve all receipts, optionally filtering by date and sorting by number
    return box.values.where((receipt) {
      if (date == null) return true;
      return receipt.date.year == date.year &&
          receipt.date.month == date.month &&
          receipt.date.day == date.day;
    }).toList()..sort((a, b) {
      final number1 = a.number.substring(5);
      final number2 = b.number.substring(5);
      return number1.compareTo(number2);
    
      // If time are not present on both receipts and they point at the same day, we sort by number 
      if (a.date.hour == 0 && b.date.hour == 0 && a.date.year == b.date.year && a.date.month == b.date.month && a.date.day == b.date.day) {
        return a.number.compareTo(b.number);
      }

      return a.date.compareTo(b.date);
    });
  }

  Future<Receipt> getReceipt({required String number}) async {
    return box.values.firstWhere((receipt) => receipt.number == number);
  }

  Future<void> updateReceipt({required Receipt receipt}) async {
    await receipt.save();
  }

  Future<void> addReceipt({required Receipt receipt}) async {
    if (box.values.any((element) => element.number == receipt.number)) {
      box.values
          .where((element) => element.number == receipt.number)
          .map((e) => receipt);
    } else {
      await box.add(receipt);
    }
  }

  Future<void> deleteReceipt({required Receipt receipt}) {
    return receipt.delete();
  }

  Future<int> clearReceipts() {
    return box.clear();
  }

  Future<void> backupReceipts(String filePath) async {
    List<Receipt> receipts = await getReceipts();

    mapper(Receipt receipt) {
      return {'number': receipt.number, 'date': receipt.date.toIso8601String()};
    }

    final Map<String, dynamic> json = {
      'receipts': receipts.map(mapper).toList(),
      'date': DateTime.now().toIso8601String(),
    };

    File backupFile = File(filePath);
    final file = await backupFile.open(mode: FileMode.writeOnly);
    await file.writeString(jsonEncode(json));
  }

  Future<void> restoreReceipts(String filePath) async {
    File backupFile = File(filePath);
    final raw = await backupFile.readAsString();

    final Map<String, dynamic> json = jsonDecode(raw);
    final List<dynamic> data = json['receipts'];

    for (Map<String, dynamic> receiptData in data) {
      await addReceipt(
        receipt: Receipt(
          number: receiptData['number'],
          date: DateTime.parse(receiptData['date']),
        ),
      );
    }
  }
}
