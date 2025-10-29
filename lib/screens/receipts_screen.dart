import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:receipt_ranger/models/receipt.dart';
import 'package:receipt_ranger/screens/camera_screen.dart';
import 'package:receipt_ranger/screens/receipt_edit_screen.dart';
import 'package:receipt_ranger/services/receipt_service.dart';
import 'package:receipt_ranger/services/scan_service.dart';
import 'package:share_plus/share_plus.dart';

class ReceiptsScreen extends StatefulWidget {
  final ReceiptService receiptService;

  const ReceiptsScreen({super.key, required this.receiptService});

  @override
  State createState() => _ReceiptsScreenState();
}

class _ReceiptsScreenState extends State<ReceiptsScreen> {
  DateTime? date;
  int? selected;
  Future<int>? futureCount;
  Future<List<DateTime>>? futureDates;
  Future<List<Receipt>>? futureReceipts;
  final List<Receipt> _removedReceipts = List.empty(growable: true);

  final ScanService scanService = ScanService();

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
    setState(_reload);
  }

  void setDate(DateTime? date) {
    this.date = date;
    refresh();
  }

  void _reload() {
    selected = null;
    futureCount = widget.receiptService.getReceiptsCount();
    futureDates = widget.receiptService.getReceiptsDates();
    futureReceipts = widget.receiptService.getReceipts(date: date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder(
          future: futureCount,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text('Receipts (${snapshot.requireData})');
            } else {
              return Text('Receipts');
            }
          },
        ),
        actions: [
          IconButton(
            onPressed: () => _clear(context),
            icon: Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
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
                            : _buildDate(context, date);

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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addRecords(context),
        child: Icon(Icons.add),
      ),
    );
  }

  Widget buildContent(BuildContext context, List<Receipt> receipts) {
    //

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

    receipts.removeWhere((element) => _removedReceipts.contains(element));

    return Expanded(
      child: ListView.builder(
        itemBuilder: (context, index) {
          final receipt = receipts[index];
          return Dismissible(
            key: ValueKey(receipt),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 16.0),
              child: Icon(Icons.delete, color: Colors.white),
            ),
            secondaryBackground: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) => _removeReceipt(receipt),

            child: ListTile(
              selected: selected != null && selected == index,
              selectedColor: Colors.redAccent,
              leading: Icon(Icons.receipt, size: 32),
              trailing: Text(
                '${index + 1}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              title: Text(
                receipt.number,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: _buildDate(context, receipt.date, withTime: true),
              onTap: () {
                setState(() {
                  if (selected != null && selected == index) {
                    selected = null;
                  } else {
                    selected = index;
                  }
                });
              },
            ),
          );
        },
        itemCount: receipts.length,
        shrinkWrap: true,
      ),
    );
  }

  Widget _buildDate(
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
      final minute = date.hour >= 10 ? date.hour.toString() : '0${date.hour}';
      final second = date.second >= 10
          ? date.second.toString()
          : '0${date.second}';
      return Text('$dateString $hour:$minute:$second');
    }
  }

  Future<void> _removeReceipt(Receipt receipt) async {
    setState(() {
      _removedReceipts.add(receipt);
    });

    try {
      await widget.receiptService.deleteReceipt(receipt: receipt);
      _removedReceipts.remove(receipt);
    } catch (e) {
      //
    }

    refresh();
  }

  void _addRecords(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera),
              title: Text('Camera'),
              trailing: Icon(Icons.auto_awesome),
              onTap: () => _openCamera(context, pop: true),
            ),
            ListTile(
              leading: Icon(Icons.keyboard),
              title: Text('Keyboard'),
              onTap: () => _openEdit(context, pop: true),
            ),
            ListTile(
              leading: Icon(Icons.input),
              title: Text('Import'),
              onTap: () => _importData(context, pop: true),
            ),
            ListTile(
              leading: Icon(Icons.output),
              title: Text('Export'),
              onTap: () => _exportData(context, pop: true),
            ),
            SizedBox(height: 16),
          ],
        ));
      },
    );
  }

  void _openCamera(BuildContext context, {bool pop = false}) {
    final nav = Navigator.of(context);

    if (pop) {
      nav.pop();
    }

    nav.push(
      MaterialPageRoute(
        builder: (context) => CameraScreen(
          scanService: scanService,
          onReceiptScanned: _saveReceipt,
        ),
      ),
    );
  }

  void _openEdit(BuildContext context, {bool pop = false}) {
    final nav = Navigator.of(context);

    if (pop) {
      nav.pop();
    }

    nav.push(
      MaterialPageRoute(
        builder: (context) => ReceiptEditScreen(onSave: _saveReceipt),
      ),
    );
  }

  Future<void> _importData(BuildContext context, {bool pop = true}) async {
    final nav = Navigator.of(context);

    if (pop) {
      nav.pop();
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      allowMultiple: false,
    );

    if (result == null || result.files.single.path == null) {
      return;
    }

    try {
      await widget.receiptService.restoreReceipts(result.files.single.path!);
      refresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _exportData(BuildContext context, {bool pop = true}) async {
    final nav = Navigator.of(context);

    if (pop) {
      nav.pop();
    }

    final status = await Permission.storage.request();
    if (status.isDenied && false) {
      return;
    }

    String fileName =
        'receipts_backup_${DateTime.now().toString().replaceAll(' ', '_')}.json';
    Directory downloads = Directory(
      '${(await getDownloadsDirectory())!.path}/Backup',
    );

    try {
      if (!(await downloads.exists())) {
        downloads = await downloads.create(recursive: true);
      }

      final filePath = '${downloads.path}/$fileName';
      await widget.receiptService.backupReceipts(filePath);
      await SharePlus.instance.share(ShareParams(files: [XFile(filePath)]));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _saveReceipt(Receipt receipt) async {
    await widget.receiptService.addReceipt(receipt: receipt);
    refresh();
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
              onPressed: () async {
                await widget.receiptService.clearReceipts();
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
