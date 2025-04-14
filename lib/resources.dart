import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'webview_controller.dart';
import 'theme.dart';
import 'locationservice.dart';

// Defines a custom stateless widget for resourcecard
class ResourceCard extends StatelessWidget {
  // Required properties for the card
  final String title;
  final String description;
  final String url;

  // Constructor for the resource card requiring the previously defined properties
  const ResourceCard({
    super.key,
    required this.title,
    required this.description,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WebViewApp(url: url))
          );
        },
        style: AppTheme.getLargeButtonStyle(context, colorIndex: 1),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(description,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              )),
            ],
          ),
        ),
      ),
    );
  }
}

// Stateless widget for the entire list of resource cards
class ResourcesPage extends StatefulWidget {
  const ResourcesPage({super.key});

  @override
  State<ResourcesPage> createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage> {

  String _countryCode = 'US';
  bool _loading = true;


  @override
  void initState() {
    super.initState();
    // fetches the user's countrycode/location
    _initializeCountryCode();
  }

  Future<void> _initializeCountryCode() async {
    // tries to get the device's countrycode by calling on the getUserCountry
    // function in the Location service file
    try {
      final code = await LocationService.getUserCountry();
      debugPrint("Success! Country Code: $code");
      setState(() {
        _countryCode = code;
        _loading = false;
      });
    }
    // if there is an error, uses US as the default countryCode.
    catch (error) {
      debugPrint("Location error: $error. Defaulting to US.");
      setState(() {
        _countryCode = 'US';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    final List<Map<String, String>> resources = [
      {
        'title': localizations.resources,
        'description': localizations.resourceCardDescription,
        'url': 'https://www.thetrevorproject.org/resources/',
      },
      {
        'title': localizations.research,
        'description': localizations.resarchDescription,
        'url': 'https://www.thetrevorproject.org/research-briefs/',
      },
      {
        'title': localizations.breathing,
        'description': localizations.breathingDescription,
        'url': 'https://www.thetrevorproject.org/breathing-exercise/',
      },
      {
        'title': localizations.blogs,
        'description': localizations.blogsDescription,
        'url': 'https://www.thetrevorproject.org/blog/',
      },
  ];

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Margin
            Text(localizations.resources, style: theme.textTheme.displayLarge),
            // First button
            SizedBox(height: 16),
            Text(
              localizations.resourcesDecription,
              style: theme.textTheme.bodyLarge,
            ),
            // spacing
            SizedBox(height : 25),
            ...resources.map((resource) {
              // Creates a resourcecard for each item in the list
              return Column(
                children : [
                  ResourceCard(
                title: resource['title']!,
                description: resource['description']!,
                url: resource['url']!,
                ),
                // spacing between each card
                  SizedBox(height: 16),
                ],
              );
            })
          ],
        ),
      )
    );
  }
}