import 'package:hive_flutter/hive_flutter.dart';
import 'package:receipe_ranger/models/receipt.dart';

class ReceiptService {
  final Box<Receipt> box = Hive.box<Receipt>('receipts');

  Future<List<DateTime>> getReceiptsDates() async {
    // Fetch all receipts
    List<Receipt> receipts = await getReceipts();

    // Extract unique dates by converting to a Set and back to List
    List<DateTime> dates = receipts
        .map((receipt) => DateTime(receipt.date.year, receipt.date.month, receipt.date.day))
        .toSet()
        .toList();

    return dates;
  }

  Future<List<Receipt>> getReceipts({DateTime? date}) async {
    // Retrieve all receipts, optionally filtering by date and sorting by number
    return box.values.where((receipt) {
      if (date == null) return true;
      return receipt.date.year == date.year &&
          receipt.date.month == date.month &&
          receipt.date.day == date.day;
    }).toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  Future<Receipt> getReceipt({required String number}) async {
    return box.values.firstWhere((receipt) => receipt.number == number);
  }

  Future<void> updateReceipt({required Receipt receipt}) async {
    await receipt.save();
  }

  Future<void> addReceipt({required Receipt receipt}) async {
    if (box.values.any((element) => element.number == receipt.number)) {
      box.values.where((element) => element.number == receipt.number).map((e) => receipt);
    } else {
      await box.add(receipt);
    }
  }

  Future<void> deleteReceipt({required Receipt receipt}) async {
    await receipt.delete();
  }

  Future<void> clearReceipts() async {
    await box.clear();
  }
}
