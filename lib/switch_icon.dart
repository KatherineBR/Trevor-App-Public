import 'package:flutter/services.dart';

// Class that invokes a method on native side since flutter can't directly do this
class AppIconSwitcher {
  static const MethodChannel _channel = MethodChannel('com.trevor.app/kotlin');

  // Switch icon
  static Future<void> switchAppIcon(bool useTrevorIcon) async {
    try {
      print("Beginning to switch icon");
      await _channel.invokeMethod('switchAppIcon', {'useTrevorIcon': useTrevorIcon});
      print("Switched successfully");
    } on PlatformException catch (e) {
      print("Error switchiing app icon: ${e.message}");
    }
  }
}