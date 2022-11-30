import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:inapp_webview/screen/pdf_view_screen.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class LoadHtmlScreen extends StatefulWidget {
  @override
  _LoadHtmlScreenState createState() => _LoadHtmlScreenState();
}

class _LoadHtmlScreenState extends State<LoadHtmlScreen> {
  InAppWebViewController? webViewController;
  String? generatedPdfFilePath;
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
  PDFDocument? document;

  bool downloading = true;
  String downloadingStr = "No data";
  String savePath = "";
  double progressPercentage = 0;
  String? htmlContent;
  final GlobalKey webViewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    getData("assets/web.html").then((value) => htmlContent = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text('WebView'))),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: InAppWebView(
                initialFile: "assets/web.html",
                onProgressChanged: (controller, percentage) {
                  setState(() {
                    progressPercentage = percentage / 100;
                    if (progressPercentage == 1) {
                      downloading = true;
                    }
                  });
                },
                onWebViewCreated: (controller) {
                  webViewController = controller;
                },
                onLoadStop: (controller, url) async {
                  webViewController = controller;
                },
              ),
            ),
            Row(
              children: [
                MaterialButton(
                    color: Colors.blue,
                    child: Text("PDF"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PdfViewScreen(htmlContent!)),
                      );
                    }),
              ],
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await webViewController!.evaluateJavascript(
              source: 'value("Antony", "Alexia", "Female")');
          htmlContent = await webViewController!.getHtml();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<String> getData(String path) async {
    return await rootBundle.loadString(path);
  }
}
