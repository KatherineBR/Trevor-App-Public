import 'package:flutter/material.dart';
import 'webview_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyFeedbackPage extends StatelessWidget {
  const MyFeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wow I love this app this is the best app I have ever used'),
      ),
    );
  }
}