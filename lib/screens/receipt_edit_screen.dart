import 'package:flutter/material.dart';
import 'package:receipt_ranger/models/receipt.dart';
import 'package:receipt_ranger/widgets/receipt_edit.dart';

class ReceiptEditScreen extends StatefulWidget {
  final Function(Receipt receipt) onSave;

  const ReceiptEditScreen({super.key, required this.onSave});

  @override
  State createState() => _ReceiptEditScreenState();
}

class _ReceiptEditScreenState extends State<ReceiptEditScreen> {
  final ReceiptEditController controller = ReceiptEditController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Receipt'), actions: [
        ElevatedButton(onPressed: () {
          widget.onSave(controller.receipt);
        }, child: Text('Save')),
      ],),
      body: ReceiptEdit(controller: controller),
    );
  }
}