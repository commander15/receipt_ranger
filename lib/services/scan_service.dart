import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:receipt_ranger/models/receipt.dart';

class ScanService {
  DateTime _lastScanTime = DateTime.now();
  final Duration _interval = Duration(milliseconds: 500);

  final dateRegExp = RegExp(r'(\d{2}\.\d{2}\.\d{4})( \d{2}:\d{2}:\d{2})?');

  final BarcodeScanner barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.qrCode]);
  final TextRecognizer textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<Receipt?> scanReceipt(InputImage image, Future<DateTime> Function(String number) onDateRequested) async {
    final now = DateTime.now();
    if (now.difference(_lastScanTime).inSeconds < _interval.inSeconds) {
      _lastScanTime = now;
      return null;
    }
    
    Barcode? barcode;

    try {
      final barcodes = await barcodeScanner.processImage(image);
      barcode = barcodes.first;
    } catch (e) {
      print(e);
    }

    if (barcode == null) {
      return null;
    }

    final rawText = await textRecognizer.processImage(image);


    // Reg exp for date (23.12.2025 14:16:57) or (23.12.2025)
    final dateMatch = dateRegExp.firstMatch(rawText.text);
    DateTime date;
    if (dateMatch == null) {
      date = await onDateRequested(barcode.rawValue!);
    } else {
      date = DateTime.parse(dateMatch.group(1)!.split('.').reversed.join('-') + (dateMatch.group(2) ?? 'T00:00:00'));
    }

    return Receipt(number: barcode.rawValue!, date: date);
  }
}