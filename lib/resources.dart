import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'webview_controller.dart';
import 'theme.dart';
import 'locationservice.dart';
import 'switch_icon.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
        style: AppTheme.largeButtonStyle,
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
  // TODO: Remove temp var
  bool _iconSwitched = false;

  List<Map<String, String>> resources = [];
    /*
    'MX': {
      'Resources': 'https://www.thetrevorproject.mx/recursos/',
      'Research Briefs': 'https://www.thetrevorproject.org/research-briefs/',
      'Breathing Exercises': 'https://www.thetrevorproject.org/breathing-exercise/',
      'Blogs': 'https://www.thetrevorproject.org/blog/',
    },
    */

  @override
  void initState() {
    super.initState();
    // fetches the user's countrycode/location
    _initializeCountryCode();
    _fetchResources(); // Fetch the resources from Firebase backend
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

  Future<void> _fetchResources() async {
    try {
      final snapshot = await FirebaseFirestore.instance
        .collection('resourcesPage')
        .get();
      
      final docs = snapshot.docs;

      setState(() {
        resources = docs.map((doc) {
          final data = doc.data();
          return {
            'title': data['title'].toString(),
            'description': data['description'].toString(),
            'url': data['url'].toString(),
          };
        }).toList();
      });
    } catch (e) {
      print('Error fetching resources');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Margin
            SizedBox(height: 24),
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
      ),
      // Temporary switch icon button at the bottom to test
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          setState(() {
            _iconSwitched = !_iconSwitched;
          });
          await AppIconSwitcher.switchAppIcon(_iconSwitched);
        },
        label: const Text("Switch Icon"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}