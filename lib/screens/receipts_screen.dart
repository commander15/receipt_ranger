import 'package:flutter/material.dart';
import 'package:receipe_ranger/models/receipt.dart';
import 'package:receipe_ranger/screens/camera_screen.dart';
import 'package:receipe_ranger/services/receipt_service.dart';
import 'package:receipe_ranger/services/scan_service.dart';

class ReceiptsScreen extends StatefulWidget {
  final ReceiptService receiptService;

  const ReceiptsScreen({super.key, required this.receiptService});

  @override
  State createState() => _ReceiptsScreenState();
}

class _ReceiptsScreenState extends State<ReceiptsScreen> {
  DateTime? date;
  int? selected;
  Future<List<DateTime>>? futureDates;
  Future<List<Receipt>>? futureReceipts;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  @override
  void activate() {
    super.activate();
    refresh();
  }

  void refresh() {
    setState(() {
      selected = null;
      futureDates = widget.receiptService.getReceiptsDates();
      futureReceipts = widget.receiptService.getReceipts(date: date);
      print("DATA REFRESH !");
    });
  }

  void setDate(DateTime? date) {
    this.date = date;
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Receipts'),
        actions: [
          IconButton(
            onPressed: () => _clear(context),
            icon: Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
      body: Column(
        children: [
          FutureBuilder(
            future: futureDates,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final dates = snapshot.requireData;
                return SizedBox(
                  height: 32,
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      final date = index > 0 ? dates[index - 1] : null;
                      final text = date == null
                          ? Text('All')
                          : buildDate(context, date);

                      if (date == this.date) {
                        return ElevatedButton(
                          onPressed: () => setDate(date),
                          child: text,
                        );
                      } else {
                        return IconButton(
                          onPressed: () => setDate(date),
                          icon: text,
                        );
                      }
                    },
                    itemExtent: 128,
                    itemCount: dates.length + 1,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                  ),
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
          FutureBuilder(
            future: futureReceipts,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      refresh();
                    },
                    child: Container(
                      margin: EdgeInsets.all(16.0),
                      child: buildContent(context, snapshot.requireData),
                    ),
                  ),
                );
              } else {
                return CircularProgressIndicator.adaptive();
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CameraScreen(
                scanService: ScanService(),
                onReceiptScanned: (receipt) {
                  widget.receiptService.addReceipt(receipt: receipt);
                  refresh();
                },
              ),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget buildContent(BuildContext context, List<Receipt> receipts) {
    if (receipts.isEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Spacer(),
          Center(
            child: Icon(
              Icons.error_outline_outlined,
              color: Colors.grey,
              size: 64,
            ),
          ),
          Text(
            'Empty',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          SizedBox(height: 16),
          Text('There is not receipts recorded yet, please add some ones.'),
          Spacer(flex: 4),
          Row(
            children: [
              Spacer(),
              Text(
                'Click here ->',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: kFloatingActionButtonMargin * 5),
            ],
          ),
          SizedBox(height: kFloatingActionButtonMargin),
        ],
      );
    }

    return Expanded(child: ListView.builder(
      itemBuilder: (context, index) {
        final receipt = receipts[index];
        return ListTile(
          selected: selected != null && selected == index,
          selectedColor: Colors.redAccent,
          leading: Icon(Icons.receipt),
          title: Text(
            "${index + 1} - ${receipt.number}",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: buildDate(context, receipt.date, withTime: true),
          onTap: () {
            setState(() {
              if (selected != null && selected == index) {
                selected = null;
              } else {
                selected = index;
              }
            });
          },
        );
      },
      itemCount: receipts.length,
      shrinkWrap: true,
    ));
  }

  Widget buildDate(
    BuildContext context,
    DateTime date, {
    bool withTime = false,
  }) {
    final day = date.day >= 10 ? date.day.toString() : '0${date.day}';
    final month = date.month >= 10 ? date.month.toString() : '0${date.month}';
    final dateString = '$day/$month/${date.year}';

    if (!withTime) {
      return Text(dateString);
    } else {
      final hour = date.hour >= 10 ? date.hour.toString() : '0${date.hour}';
      final minute = date.hour >= 10
          ? date.hour.toString()
          : '0${date.hour}';
      final second = date.second >= 10
          ? date.second.toString()
          : '0${date.second}';
      return Text('$dateString $hour:$minute:$second');
    }
  }

  void _clear(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Data wipe'),
          content: Text('Do you realy want to delete today\'s data ?'),
          actions: [
            ElevatedButton(
              onPressed: Navigator.of(context).pop,
              child: Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                widget.receiptService.clearReceipts();
                Navigator.of(context).pop();
                refresh();
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}
