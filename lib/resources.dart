import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'webview_controller.dart';
import 'theme.dart';

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
    final theme = Theme.of(context);
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
class ResourcesPage extends StatelessWidget {
  final List<Map<String, String>> resources = [
    // List of sample data for the resource card
    {
      'title': 'Resources',
      'description': 'A collection of helpful resources.',
      'url': 'https://www.thetrevorproject.org/resources/',
    },
    {
      'title': 'Research Briefs',
      'description': 'Explore the latest research studies.',
      'url': 'https://www.thetrevorproject.org/research-briefs/',
    },
    {
      'title': 'Breathing Exercises',
      'description': 'Learn to manage stress with breathing techniques.',
      'url': 'https://www.thetrevorproject.org/breathing-exercise/',
    },
    {
      'title': 'Blogs',
      'description': 'Read inspiring stories and updates.',
      'url': 'https://www.thetrevorproject.org/blog/',
    },
  ];

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
            Text('Resources', style: theme.textTheme.displayLarge),
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