import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:receipt_ranger/screens/receipts_screen.dart';
import 'package:receipt_ranger/screens/splash_screen.dart';
import 'package:receipt_ranger/services/receipt_service.dart';
import 'package:receipt_ranger/services/scan_service.dart';

class HomeScreen extends StatefulWidget {
  final List<File>? files;
  const HomeScreen({super.key, this.files});

  @override
  State createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScanService scanService = ScanService();
  final ReceiptService receiptService = ReceiptService();
  late Widget _currentScreen;
  late ReceiptsScreen _receiptsScreen;

  @override
  void initState() {
    super.initState();

    _currentScreen = SplashScreen();
    _receiptsScreen = ReceiptsScreen(receiptService: receiptService);

    Timer(
      Duration(seconds: 3),
      () => setState(
        () => _currentScreen = _receiptsScreen,
      ),
    );
  }

  late int _currentPage;
  late List<Widget> _pages;

  _HomeScreenState() {
    _currentPage = -1;
    _pages = [ReceiptsScreen(receiptService: receiptService)];
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< Updated upstream
    return _currentScreen;
=======
    return (_currentPage < 0 ? SplashScreen() : _pages[_currentPage]);
>>>>>>> Stashed changes
  }
}
