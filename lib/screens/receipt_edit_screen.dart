import 'package:flutter/material.dart';
import 'package:receipe_ranger/models/receipt.dart';
import 'package:receipe_ranger/widgets/receipt_edit.dart';

class ReceiptEditScreen extends StatelessWidget {
  final Function(Receipt receipt) onSave;

  const ReceiptEditScreen({super.key, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ReceiptEdit(onSave: (receipt) {
        onSave(receipt);
        Navigator.of(context).pop();
      },),
    );
  }
}