import 'package:flutter/material.dart';
import 'package:receipt_ranger/models/receipt.dart';

class ReceiptEditController {
  String? number;
  DateTime? date = DateTime.now();

  Receipt get receipt =>
      Receipt(number: number ?? '', date: date ?? DateTime(0));

  ReceiptEditController({this.number, this.date});
}

class ReceiptEdit extends StatefulWidget {
  final String title;
  final ReceiptEditController? controller;

  const ReceiptEdit({super.key, this.title = 'Receipt', this.controller});

  @override
  State createState() => _ReceiptEditState();
}

class _ReceiptEditState extends State<ReceiptEdit> {
  final TextEditingController numberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.only(left: 16, right: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              keyboardType: TextInputType.numberWithOptions(),
              controller: numberController,
              decoration: InputDecoration(labelText: 'Receipt Number'),
              onChanged: (value) => widget.controller?.number = value,
            ),
            SizedBox(height: 16.0),
            CalendarDatePicker(
              initialDate: DateTime.now(),
              firstDate: DateTime(2010),
              lastDate: DateTime.now(),
              onDateChanged: (value) => widget.controller?.date = value,
            ),
          ],
        ),
      ),
    );
  }
}
