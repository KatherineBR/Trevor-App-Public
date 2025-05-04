import 'package:flutter/material.dart';
import 'locationservice.dart';

class CountryCodeService {
  static final CountryCodeService _instance = CountryCodeService._internal();
  factory CountryCodeService() => _instance;
  CountryCodeService._internal() { initialize(); }

  final ValueNotifier<String> countryCode = ValueNotifier<String>('US');

  Future<void> initialize() async {
    try {
      final code = await LocationService.getUserCountry();
      countryCode.value = code;
    } catch (e) {
      countryCode.value = 'US';
    }
  }
}