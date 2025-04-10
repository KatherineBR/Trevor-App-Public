import 'package:flutter/material.dart';
import 'webview_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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

  @override
  Widget build(BuildContext context) {
    // retrieves the appropriate translations based on the user's
    // language settings from the generated class "AppLocalizations"
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text('Home')),
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
                    builder: (context) => WebViewApp(url: chatUrl[_countryCode] ?? chatUrl['US']!),
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
              onPressed: () => openCallApp('+18664887386'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 60), // Ensures full width
                textStyle: TextStyle(fontSize: 60), // Increases font size
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Makes it rounded rectangle
              ), ),
              child: Text(localizations.call),
            ), ), 
            SizedBox(height: 25),
          ],
        ),
      ),
    );
}
  }
