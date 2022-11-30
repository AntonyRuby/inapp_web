import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';

List<String> recipient = ["6381305467"];

class SendSmsScreen extends StatefulWidget {
  @override
  _SendSmsScreenState createState() => _SendSmsScreenState();
}

class _SendSmsScreenState extends State<SendSmsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Send Sms")),
      ),
      body: Center(
        child: MaterialButton(
            textColor: Colors.white,
            color: Colors.blue,
            onPressed: () {
              _sendSMS("Just a test SMS", recipient);
            },
            child: Text("Send")),
      ),
    );
  }

  void _sendSMS(String message, List<String> recipient) async {
    String _result = await sendSMS(message: message, recipients: recipient)
        .catchError((onError) {});
  }
}
