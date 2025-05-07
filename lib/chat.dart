import 'package:flutter/services.dart';
import 'countrycodeservice.dart';

// Class that invokes a method on native side since flutter can't directly do this
class Chat {
  static const MethodChannel _channel = MethodChannel('com.trevor.app/kotlin');
  static final CountryCodeService _countryCodeService = CountryCodeService();
  late String? fcmToken;

  static final Chat _instance = Chat._internal();
  factory Chat() => _instance;

  void init(String? token){
    fcmToken = token;
  }

  Chat._internal(); // private constructor

  // Call getChat
  Future<void> getChat() async {
    try {
      final countryCode = _countryCodeService.countryCode.value;
      // print('countryCode is $countryCode');
      // print("Launching chat");
      await countryCode == "US" ? _channel.invokeMethod('getChatUS', {fcmToken}): _channel.invokeMethod('getChatMX', {fcmToken});
    } on PlatformException catch (e) {
      // print("Error opening chat: ${e.message}");
    }
  }
}