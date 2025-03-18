import 'package:flutter/material.dart';
import 'webview_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyResourcesPage extends StatelessWidget {
  const MyResourcesPage({super.key});

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('These are so many great resources how resourceful'),
      ),
    );
  }
}