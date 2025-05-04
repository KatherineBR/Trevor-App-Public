import 'package:flutter/services.dart';
import 'countrycodeservice.dart';

// Class that invokes a method on native side since flutter can't directly do this
class Chat {
  static const MethodChannel _channel = MethodChannel('com.trevor.app/kotlin');
  static final CountryCodeService _countryCodeService = CountryCodeService();

  // Call getChat
  static Future<void> getChat() async {
    try {
      final countryCode = _countryCodeService.countryCode.value;
      // print('countryCode is $countryCode');
      // print("Launching chat");
      await countryCode == "US" ? _channel.invokeMethod('getChatUS'): _channel.invokeMethod('getChatMX');
    } on PlatformException catch (e) {
      // print("Error opening chat: ${e.message}");
    }
  }
}