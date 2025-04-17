import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GetChat {
  
  Future<void> GetChat() async {
    String batteryLevel;
    try {
      final result = await platform.invokeMethod<int>('getChat');
      batteryLevel = 'Battery level at $result % .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }

}

}