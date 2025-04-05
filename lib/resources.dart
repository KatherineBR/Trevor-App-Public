import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'webview_controller.dart';

//defines a custom stateless widget for resourcecard
class ResourceCard extends StatelessWidget {
  // required properties for the card
  final String title;
  final String description;
  final String url;

  // constructor for the resource card requiring the previously defined properties
  const ResourceCard({
    super.key,
    required this.title,
    required this.description,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    // determines the characteristics of each of the cards
    return Card(
      color: const Color.fromARGB(255, 169, 228, 255),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WebViewApp(url: url)), // Replace with your destination
          );
        }
      ),
    );
  }
}

// stateless widget for the entire list of resource cards
class ResourcesPage extends StatelessWidget {
  final List<Map<String, String>> resources = [
    // list of sample data for the resource card
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
    return Scaffold(
      appBar: AppBar(title: Text('Resources')),
      // body of the page contains listview for multiple resourcecard widgets to be displayed
      body: ListView.builder(
        itemCount: resources.length,
        itemBuilder: (context, index) {
          // creates a resourcecard for each item in the list
          final resource = resources[index];
          return ResourceCard(
            title: resource['title']!,
            description: resource['description']!,
            url: resource['url']!,
          );
        },
      ),
    );
  }
}
