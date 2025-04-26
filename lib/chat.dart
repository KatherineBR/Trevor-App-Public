import 'package:flutter/services.dart';

// Class that invokes a method on native side since flutter can't directly do this
class Chat {
  static const MethodChannel _channel = MethodChannel('com.trevor.app/kotlin');

  // Call getChat
  static Future<void> getChat() async {
    try {
      print("Launching chat");
      await _channel.invokeMethod('getChat');
    } on PlatformException catch (e) {
      print("Error opening chat: ${e.message}");
    }
  }
  
}