import 'package:flutter/material.dart';
import 'webview_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  Future<void> sendSMS(String phoneNumber) async {
    final Uri smsUri = Uri.parse('sms:$phoneNumber'); // `sms:` opens the messaging app
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      debugPrint('Could not launch SMS app');
    }
  }

  @override
  Widget build(BuildContext context) {
    // retrieves the appropriate translations based on the user's
    // language settings from the generated class "AppLocalizations"
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        // uses the content from the translation that it retrieved from the 
        // the generated class
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [ 
            SizedBox(height: 40), // Adds top margin
            Expanded(
              child: ElevatedButton(
              // uses the retrieved translation from the generated class which 
              // stores the appropriate translations based on the user's language
              // setting
              onPressed: () => sendSMS('sms:+18664887386'), // Replace with desired number
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 60), // Ensures full width
                textStyle: TextStyle(fontSize: 60), // Increases font size
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Makes it rounded rectangle
              ), ),
              child: Text(localizations.text),
            ),
            ),
            SizedBox(height: 25),
            Expanded(child: ElevatedButton(
              onPressed: () {
                // Navigate to the webview chat when pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WebViewApp(), 
                    ),
                  );
                },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 60), // Ensures full width
                textStyle: TextStyle(fontSize: 60), // Increases font size
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Makes it rounded rectangle
              ), ),
              child: Text(localizations.chat)
            ), ),
            SizedBox(height: 25),
            Expanded(child: ElevatedButton(
            onPressed: () {
              // Copied the webview button as a dummy so we can format with three buttons
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WebViewApp(), 
                  ),
                );
              },
            style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 60), // Ensures full width
                textStyle: TextStyle(fontSize: 60), // Increases font size
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Makes it rounded rectangle
              ), ),
            child: Text(localizations.chat)
            ),),
            
            SizedBox(height: 40),
          ],
        ),
      ),
    );
}
  }
