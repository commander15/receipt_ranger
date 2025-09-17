import 'package:flutter/material.dart';
import 'package:receipe_ranger/models/receipt.dart';

class ReceiptEdit extends StatefulWidget {
  final String title;
  final Function(Receipt receipt) onSave;

  const ReceiptEdit({super.key, this.title = 'Receipt', required this.onSave});

  @override
  State createState() => _ReceiptEditState();
}

class _ReceiptEditState extends State<ReceiptEdit> {
  final TextEditingController numberController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  DateTime date = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(left: 16, right: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                keyboardType: TextInputType.numberWithOptions(),
                controller: numberController,
                decoration: InputDecoration(labelText: 'Receipt Number'),
              ),
              SizedBox(height: 16.0),
              CalendarDatePicker(
                initialDate: DateTime.now(),
                firstDate: DateTime(2010),
                lastDate: DateTime.now(),
                onDateChanged: (value) => date = value,
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () => widget.onSave(
                    Receipt(number: numberController.text, date: date),
                  ),
                  child: Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
