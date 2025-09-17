import 'package:flutter/material.dart';
import 'package:receipe_ranger/models/receipt.dart';
import 'package:receipe_ranger/screens/camera_screen.dart';
import 'package:receipe_ranger/screens/receipts_screen.dart';
import 'package:receipe_ranger/services/receipt_service.dart';
import 'package:receipe_ranger/services/scan_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State createState() => _HomeScreenState(); 
}

class _HomeScreenState extends State<HomeScreen> {
  final ScanService scanService = ScanService();
  final ReceiptService receiptService = ReceiptService();

  @override
  Widget build(BuildContext context) {
    return ReceiptsScreen(receiptService: receiptService);
    return CameraScreen(scanService: scanService, onReceiptScanned: (receipt) => receiptService.addReceipt(receipt: receipt));
  }
}