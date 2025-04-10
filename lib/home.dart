import 'package:flutter/material.dart';
import 'webview_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'theme.dart';

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

  Future<void> openCallApp(String phoneNumber) async {
    final Uri telUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    } else {
      debugPrint('Could not launch Phone app');
    }
  }

  Future<void> openWhatsApp(String phoneNumber) async {
    final whatsappUri = Uri.parse("https://wa.me/$phoneNumber");
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    } else {
      debugPrint('Could not launch WhatsApp. Make sure WhatsApp is installed.');
    }
  }
    @override
      Widget build(BuildContext context) {
        final localizations = AppLocalizations.of(context)!;
        final theme = Theme.of(context);
        final homeButtonsStyle = AppTheme.largeButtonStyle;
        const tempCondition = false; // Placeholder for actual condition for later

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Text('Home', style: theme.textTheme.displayLarge),
              const SizedBox(height: 16),
              Text(
                localizations.homeDescription,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 40),
              SizedBox(
                height: 80,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const WebViewApp(url: 'https://chat.trvr.org/'),
                      ),
                    );
                  },
                  style: homeButtonsStyle,
                  child: Text(localizations.chat),
                ),
              ),
              const SizedBox(height: 25),
              if (tempCondition)
                ...[
                  SizedBox(
                    height: 80,
                    child: ElevatedButton(
                      onPressed: () => sendSMS('sms:+18664887386'),
                      style: homeButtonsStyle,
                      child: Text(localizations.text),
                    ),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    height: 80,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => openCallApp('+18664887386'),
                      style: homeButtonsStyle,
                      child: Text(localizations.call),
                    ),
                  ),
                ]
              else
                SizedBox(
                  height: 80,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => openWhatsApp('+525592253337'),
                    style: homeButtonsStyle,
                    child: Text(localizations.text),
                  ),
                ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}