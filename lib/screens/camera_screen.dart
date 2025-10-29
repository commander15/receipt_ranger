import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:receipt_ranger/models/receipt.dart';
import 'package:receipt_ranger/screens/receipt_edit_screen.dart';
import 'package:receipt_ranger/services/scan_service.dart';

class CameraScreen extends StatefulWidget {
  final ScanService scanService;
  final Function(Receipt receipt) onReceiptScanned;

  const CameraScreen({
    super.key,
    required this.scanService,
    required this.onReceiptScanned,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  Future<void>? futureInitialize;
  CameraController? cameraController;

  bool auto = true;
  bool capturing = false;
  XFile? captureFile;
  String? messageText;
  Color? messageColor;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    futureInitialize = initializeCamera();
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }

    cameraController?.dispose();
    super.dispose();
  }

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();

    if (cameras.isEmpty) {
      throw Exception('No cameras found !');
    }

    cameraController = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await cameraController!.initialize();
    await cameraController!.setFlashMode(FlashMode.auto);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      body: SafeArea(
        child: FutureBuilder(
          future: futureInitialize,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                futureInitialize == null) {
              return buildLoader(context);
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error initializing camera: ${snapshot.error}'),
              );
            } else {
              return buildUi(context);
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _getFromInput(context),
        child: Icon(Icons.keyboard),
      ),
    );
  }

  Widget buildLoader(BuildContext context) {
    return Center(child: CircularProgressIndicator());
  }

  Widget buildUi(BuildContext context) {
    return Stack(
      children: [
        if (!capturing) cameraController!.buildPreview(),
        if (captureFile != null)
          Positioned.fill(
            child: Image.file(File(captureFile!.path), fit: BoxFit.cover),
          ),
        Positioned(right: 16, top: 32, child: Text('Amadou Benjamain')),
        Positioned(
          bottom: 32,
          left: 32,
          child: IconButton(
            onPressed: () {
              setState(() {
                auto = !auto;
              });
            },
            icon: Text(
              "AUTO",
              style: TextStyle(
                color: auto ? Colors.blueGrey : null,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        if (messageText != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: kBottomNavigationBarHeight * 2,
            child: Center(
              child: Card(
                margin: EdgeInsets.all(16.0),
                child: Text(
                  " ${messageText!} ",
                  style: TextStyle(color: messageColor, fontSize: 18),
                ),
              ),
            ),
          ),
        if (capturing)
          Positioned.fill(child: Center(child: CircularProgressIndicator())),
        Positioned(
          bottom: 16.0,
          left: 0,
          right: 0,
          child: Center(
            child: IconButton(
              onPressed: _processImage,
              icon: Icon(Icons.camera, color: Colors.blueGrey, size: 64),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _processImage() async {
    if (cameraController == null) {
      return;
    }

    XFile file = await cameraController!.takePicture();

    setState(() {
      capturing = true;
      captureFile = file;
    });

    InputImage image = InputImage.fromFilePath(captureFile!.path);
    Receipt? receipt = await widget.scanService.scanReceipt(
      image,
      (number) => _askDate(context, number, null),
    );

    if (receipt == null) {
      _showMessage(
        context,
        message: "Can't read receipt data !",
        color: Colors.pink,
      );
    } else {
      if (!auto) {
        DateTime date = await _askDate(context, receipt.number, receipt.date);
        _reportScan(
          date == receipt.date
              ? receipt
              : Receipt(number: receipt.number, date: date),
        );
      } else {
        _reportScan(receipt);
      }
    }

    setState(() {
      capturing = false;
      captureFile = null;
    });
  }

  void _reportScan(Receipt receipt) {
    _showMessage(context, message: 'OK', color: Colors.green);
    widget.onReceiptScanned(receipt);
  }

  void _showMessage(
    BuildContext context, {
    required String message,
    Color? color,
  }) {
    setState(() {
      messageText = message;
      messageColor = color ?? Colors.blueAccent;
    });

    _timer = Timer(Duration(seconds: 3), () {
      setState(() {
        messageText = null;
        messageColor = null;
      });
    });
  }

  Future<DateTime> _askDate(
    BuildContext context,
    String number,
    DateTime? initialDate,
  ) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      helpText: "Receipt $number",
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2021),
      lastDate: DateTime.now(),
    );

    return selected ?? DateTime.now();
  }

  void _getFromInput(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReceiptEditScreen(
          onSave: (receipt) {
            Navigator.of(context).pop();
            _reportScan(receipt);
          },
        ),
      ),
    );
  }
}
