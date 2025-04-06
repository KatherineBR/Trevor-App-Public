import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'webview_controller.dart';
import 'locationservice.dart';

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

class ResourcesUrl {
  static final Map<String, Map<String, String>> urls = {
    'US': {
      'Resources': 'https://www.thetrevorproject.org/resources/',
      'Research Briefs': 'https://www.thetrevorproject.org/research-briefs/',
      'Breathing Exercises': 'https://www.thetrevorproject.org/breathing-exercise/',
      'Blogs': 'https://www.thetrevorproject.org/blog/',
    },
    'MX': {
      'Resources': 'https://www.thetrevorproject.mx/recursos/',
      'Research Briefs': 'https://www.thetrevorproject.org/research-briefs/',
      'Breathing Exercises': 'https://www.thetrevorproject.org/breathing-exercise/',
      'Blogs': 'https://www.thetrevorproject.org/blog/',
    },
  };
  static getUrl(title, countryCode) {
    //fetches the url for the given title under the countrycode
    // the "!" operator asserts that the values are not null
    return urls[countryCode]![title]!;
  }
}

// a class that contains a state
class ResourcesPage extends StatefulWidget {
  const ResourcesPage({super.key});

  @override
  State<ResourcesPage> createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage> {
  String _countryCode = 'US';
  bool _loading = true;

  final List<Map<String, String>> resources = [
    // list of sample data for the resource card
    {
      'title': 'Resources',
      'description': 'A collection of helpful resources.',
    },
    {
      'title': 'Research Briefs',
      'description': 'Explore the latest research studies.',
    },
    {
      'title': 'Breathing Exercises',
      'description': 'Learn to manage stress with breathing techniques.',
    },
    {
      'title': 'Blogs',
      'description': 'Read inspiring stories and updates.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeCountryCode();
  }


  Future<void> _initializeCountryCode() async {
    try {
      final code = await LocationService.getUserCountry();
      debugPrint("Success! Country Code: $code");
      setState(() {
        _countryCode = code;
        _loading = false;
      });
    }
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
    return Scaffold(
      appBar: AppBar(title: Text('Resources')),
      // body of the page contains listview for multiple resourcecard widgets to be displayed
      // body of the page contains listview for multiple resourcecard widgets to be displayed
   body: _loading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
          itemCount: resources.length,
          itemBuilder: (context, index) {
            // creates a resourcecard for each item in the list
            final resource = resources[index];
            final title = resource['title']!;
            final description = resource['description']!;
            final url = ResourcesUrl.getUrl(title, _countryCode);
            return ResourceCard(
              title: title,
              description: description,
              url: url,
            );
          },
        ),
    );
  }
}
