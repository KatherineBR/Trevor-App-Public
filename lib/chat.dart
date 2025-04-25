import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Chat extends StatefulWidget {
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  static const platform = MethodChannel('com.trevor.app/kotlin');

  @override
  void initState() {
    super.initState();
    _openNativeChat();
  }

  Future<void> _openNativeChat() async {
    try {
      await platform.invokeMethod('getChat');
    } on PlatformException catch (e) {
      print("Failed to open native chat: ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: Center(child: Text('Launching chat...')),
    );
  }
}
