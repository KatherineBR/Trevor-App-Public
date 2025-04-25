import 'package:flutter/material.dart';
import 'webview_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'theme.dart';
import 'chat.dart';
import 'locationservice.dart';

// changed this class to include states
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  // creates the state for the page page
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>{
  // the two elements in this state
  String _countryCode = 'US'; // default country code is set to US
  bool _loading = true;

  // map that holds the two different urls with the country codes as the keys
  Map<String, String> chatUrl = {
    'US': 'http://chat.trvr.org/',
    'MX': 'http://chat.trvr.mx/',
  };

  // initstate method called when state object is inserted into the widget
  // tree for the first time, allowing initialization of country code before
  // the widget is built.
  @override
  void initState() {
    super.initState();
    _initializeCountryCode();
  }

  // tries to get the device's countrycode by calling on the getUserCountry
  // function in the Location service file
  Future<void> _initializeCountryCode() async {
    try {
      final code = await LocationService.getUserCountry();
      debugPrint("Success! Country Code: $code");
      setState(() {
        _countryCode = code;
        _loading = false;
      });
    }
    // if there is an error, the default countrycode is US
    catch (error) {
      debugPrint("Location error: $error. Defaulting to US.");
      setState(() {
        _countryCode = 'US';
        _loading = false;
      });
    }
  }

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

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(localizations.home, style: theme.textTheme.displayLarge),
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
                      MaterialPageRoute(builder: (context) => Chat()),
                    );
                  },
                  style:  AppTheme.getLargeButtonStyle(context, colorIndex: 1),
                  child: Text(localizations.chat),
                ),
              ),
              const SizedBox(height: 25),
              if (_countryCode != 'MX')
                  SizedBox(
                    height: 80,
                    child: ElevatedButton(
                      onPressed: () => sendSMS('sms:+18664887386'),
                      style:  AppTheme.getLargeButtonStyle(context, colorIndex: 1),
                      child: Text(localizations.text),
                    ),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    height: 80,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => openCallApp('+18664887386'),
                      style:  AppTheme.getLargeButtonStyle(context, colorIndex: 1),
                      child: Text(localizations.call),
                    ),
                  ),
              if (_countryCode == 'MX')
                SizedBox(
                  height: 80,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => openWhatsApp('+525592253337'),
                    style:  AppTheme.getLargeButtonStyle(context, colorIndex: 2),
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