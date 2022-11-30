import 'dart:io';

import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';

class PdfViewScreen extends StatefulWidget {
  String htmlContent;
  PdfViewScreen(this.htmlContent);
  @override
  _PdfViewScreenState createState() => _PdfViewScreenState();
}

class _PdfViewScreenState extends State<PdfViewScreen> {
  late String generatedPdfFilePath;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  PDFDocument? document;

  @override
  void initState() {
    super.initState();

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iOS = IOSInitializationSettings();
    final initSettings = InitializationSettings(android: android, iOS: iOS);

    flutterLocalNotificationsPlugin.initialize(initSettings,
        onSelectNotification: selectNotification);

    generateExampleDocument();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pdf'),
        actions: [
          ElevatedButton(
              onPressed: () {
                Share.shareFiles([generatedPdfFilePath]);
              },
              child: Icon(Icons.share))
        ],
      ),
      body: document != null
          ? Center(child: PDFViewer(document: document!))
          : Center(
              child: CircularProgressIndicator(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          generateExampleDocument();
          _showNotification();
        },
        tooltip: 'Download',
        child: Icon(Icons.file_download),
      ),
    );
  }

  Future<void> _download() async {
    final dir = await _getDownloadDirectory();
    final isPermissionStatusGranted = await _requestPermissions();

    if (isPermissionStatusGranted) {
      await File(generatedPdfFilePath).create(recursive: true);
      _showNotification();
    } else {}
  }

  Future<Directory> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      return await getExternalStorageDirectory().then((value) => value!);
    }

    return await getApplicationDocumentsDirectory();
  }

  Future selectNotification(String? payload) async {}

  Future<bool> _requestPermissions() async {
    var status = await Permission.storage.status;

    if (status != PermissionStatus.granted) {
      await Permission.storage.request();
    }
    return status == PermissionStatus.granted;
  }

  Future<void> _showNotification() async {
    final android = AndroidNotificationDetails(
        'channel id', 'channel name', 'channel description',
        priority: Priority.high, importance: Importance.max);
    final iOS = IOSNotificationDetails();
    final platform = NotificationDetails(android: android, iOS: iOS);

    final isSuccess = true;

    await flutterLocalNotificationsPlugin.show(
      0,
      isSuccess ? 'Success' : 'Failure',
      isSuccess
          ? 'File has been downloaded successfully!'
          : 'There was an error while downloading the file.',
      platform,
    );
  }

  Future<void> generateExampleDocument() async {
    Directory appDocDir = await _getDownloadDirectory();
    final targetPath = appDocDir.path;
    final targetFileName = "web-pdf";

    final generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(
        widget.htmlContent, targetPath, targetFileName);
    generatedPdfFilePath = generatedPdfFile.path;
    document = await PDFDocument.fromFile(File(generatedPdfFilePath));

    setState(() {});
  }
}
