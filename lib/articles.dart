import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'webview_controller.dart';

class ArticleCard extends StatelessWidget {
  final String title;
  final String? author;
  final String? imageUrl;
  final List<String>? tags;
  final String url;
  final DateTime date;
  final String category;

  const ArticleCard({
    super.key,
    required this.title,
    this.author,
    this.imageUrl,
    this.tags,
    required this.url,
    required this.date,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WebViewApp(url: url)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image on the left - only show for Blogs and Resources
              if (imageUrl != null && category != 'Research Briefs') ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    imageUrl!,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
              ],
              // Content on the right
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('MMMM d, yyyy').format(date),
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Only show author for Blogs
                    if (category == 'Blogs' && author != null) ...[
                      Text(
                        'By $author',
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (tags != null && tags!.isNotEmpty) ...[
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children:
                            tags!
                                .map(
                                  (tag) => Chip(
                                    label: Text(
                                      tag,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    backgroundColor: Colors.grey[200],
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                )
                                .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ArticlesPage extends StatefulWidget {
  final String category;

  const ArticlesPage({super.key, required this.category});

  @override
  State<ArticlesPage> createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
  List<Map<String, dynamic>> articles = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchArticles();
  }

  Future<void> _fetchArticles() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection(widget.category)
              .orderBy('date', descending: true)
              .get();

      setState(() {
        articles =
            snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'title': data['title'] as String,
                'author': data['author'] as String?,
                'imageUrl': data['imageUrl'] as String?,
                'tags':
                    data['tags'] != null
                        ? List<String>.from(data['tags'] as List)
                        : null,
                'url': data['url'] as String,
                'date': (data['date'] as Timestamp).toDate(),
              };
            }).toList();
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error fetching articles: $e');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.category)),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : articles.isEmpty
              ? Center(
                child: Text(
                  'No ${widget.category} available',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              )
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: articles.length,
                separatorBuilder:
                    (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final article = articles[index];
                  return ArticleCard(
                    title: article['title'],
                    author: article['author'],
                    imageUrl: article['imageUrl'],
                    tags: article['tags'],
                    url: article['url'],
                    date: article['date'],
                    category: widget.category,
                  );
                },
              ),
    );
  }
}
