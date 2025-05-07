import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'webview_controller.dart';
import 'theme.dart';
import 'locationservice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'articles.dart';

// Defines a custom stateless widget for resourcecard
class ResourceCard extends StatelessWidget {
  // Required properties for the card
  final String title;
  final String description;
  final String url;

  // List of categories that should route to the ArticlesPage
  static const List<String> articleCategories = [
    'Blogs',
    'Research Briefs',
    'Resource Center',
    'SpanishResources',
  ];

  // Constructor for the resource card requiring the previously defined properties
  const ResourceCard({
    super.key,
    required this.title,
    required this.description,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    final bool isArticleCategory = articleCategories.contains(title);

    return SizedBox(
      height: 80,
      child: ElevatedButton(
        onPressed: () {
          if (isArticleCategory) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ArticlesPage(category: title),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WebViewApp(url: url)),
            );
          }
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
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
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
  bool errorLoading = false;
  List<Map<String, String>> resources = [];
  List<Map<String, dynamic>> spanishArticles = [];

  @override
  void initState() {
    super.initState();
    // fetches the user's countrycode/location
    _initializeCountryCode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    if (locale.languageCode == 'es') {
      _fetchSpanishArticles();
    } else {
      _fetchResources(); // Fetch the resources from Firebase backend
    }
    if (errorLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching resources!')),
      );
    }
  }

  Future<void> _initializeCountryCode() async {
    try {
      final code = await LocationService.getUserCountry();
      setState(() {
        _countryCode = code;
        _loading = false;
      });
    } catch (error) {
      setState(() {
        _countryCode = 'US';
        _loading = false;
      });
    }
  }

  Future<void> _fetchSpanishArticles() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('resourcesPage')
              .doc('SpanishResources')
              .collection('articles')
              .orderBy('date', descending: true)
              .get();
      setState(() {
        spanishArticles =
            snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'title': data['title'] as String,
                'imageUrl': data['imageUrl'] as String?,
                'url': data['url'] as String,
                'date': (data['date'] as Timestamp).toDate(),
                'topic': data['topic'] as String?,
              };
            }).toList();
      });
    } catch (e) {
      errorLoading = true;
    }
  }

  Future<void> _fetchResources() async {
    final localizations = AppLocalizations.of(context);
    try {
      String resourcesPage = localizations!.resourcePage;
      final snapshot =
          await FirebaseFirestore.instance.collection(resourcesPage).get();

      final docs = snapshot.docs;

      setState(() {
        resources =
            docs
                .map((doc) => doc.data())
                .where((data) => data['title'] != null)
                .map(
                  (data) => {
                    'title': data['title'].toString(),
                    'description': data['description'].toString(),
                    'url': data['url'].toString(),
                  },
                )
                .toList();
      });
    } catch (e) {
      errorLoading = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

    if (_loading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if(locale.languageCode == 'es' && !spanishArticles.isNotEmpty){
      //TODO: put something that says no resources found
    }

    if (locale.languageCode == 'es' && spanishArticles.isNotEmpty) {
      // Group Spanish articles by topic
      final Map<String, List<Map<String, dynamic>>> articlesByTopic = {};
      for (final article in spanishArticles) {
        final topic = article['topic'] ?? 'Otros';
        if (!articlesByTopic.containsKey(topic)) {
          articlesByTopic[topic] = [];
        }
        articlesByTopic[topic]!.add(article);
      }
      final sortedTopics = articlesByTopic.keys.toList()..sort();

      return Scaffold(
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          children: [
            Text('Recursos en Español', style: theme.textTheme.displayLarge),
            const SizedBox(height: 16),
            for (final topic in sortedTopics) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(topic, style: theme.textTheme.headlineSmall),
              ),
              ...articlesByTopic[topic]!.map(
                (article) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: ArticleCard(
                    title: article['title'],
                    author: null,
                    imageUrl: article['imageUrl'],
                    categories: null,
                    url: article['url'],
                    date: article['date'],
                    category: 'SpanishResources',
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Margin
            Text(localizations.resources, style: theme.textTheme.displayLarge),
            // First button
            const SizedBox(height: 16),
            Text(
              localizations.resourcesDescription,
              style: theme.textTheme.bodyLarge,
            ),
            // spacing
            const SizedBox(height: 25),
            ...resources.map((resource) {
              // Creates a resourcecard for each item in the list
              return Column(
                children: [
                  ResourceCard(
                    title: resource['title']!,
                    description: resource['description']!,
                    url: resource['url']!,
                  ),
                  // spacing between each card
                  const SizedBox(height: 16),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
