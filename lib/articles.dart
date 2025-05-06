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
  List<Map<String, dynamic>> filteredArticles = []; // For search results
  bool _loading = true;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchArticles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterArticles(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredArticles = articles;
      });
      return;
    }

    setState(() {
      filteredArticles =
          articles
              .where(
                (article) =>
                    article['title'].toString().toLowerCase().contains(
                      query.toLowerCase(),
                    ) ||
                    (article['tags'] != null &&
                        (article['tags'] as List<String>).any(
                          (tag) =>
                              tag.toLowerCase().contains(query.toLowerCase()),
                        )),
              )
              .toList();
    });
  }

  Future<void> _fetchArticles() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot;
      if (widget.category == 'Blogs') {
        // Fetch from subcollection 'articles' inside 'resourcesPage/Blogs'
        snapshot =
            await FirebaseFirestore.instance
                .collection('resourcesPage')
                .doc('Blogs')
                .collection('articles')
                .orderBy('date', descending: true)
                .get();
      } else if (widget.category == 'Research Briefs') {
        // Fetch from subcollection 'articles' inside 'resourcesPage/Research Briefs'
        snapshot =
            await FirebaseFirestore.instance
                .collection('resourcesPage')
                .doc('Research Briefs')
                .collection('articles')
                .orderBy('date', descending: true)
                .get();
      } else if (widget.category == 'Resource Center') {
        // Fetch from subcollection 'articles' inside 'resourcesPage/Resource Center'
        snapshot =
            await FirebaseFirestore.instance
                .collection('resourcesPage')
                .doc('Resource Center')
                .collection('articles')
                .orderBy('date', descending: true)
                .get();
      } else if (widget.category == 'SpanishResources') {
        // Fetch from subcollection 'articles' inside 'resourcesPage/Resource Center'
        snapshot =
            await FirebaseFirestore.instance
                .collection('resourcesPage')
                .doc('SpanishResources')
                .collection('articles')
                .orderBy('date', descending: true)
                .get();
      } else {
        // Existing logic for other categories (update as needed for new structure later)
        snapshot =
            await FirebaseFirestore.instance
                .collection(widget.category)
                .orderBy('date', descending: true)
                .get();
      }

      setState(() {
        articles =
            snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'title': data['title'] as String,
                'author': data['author'] as String?,
                'imageUrl': data['imageUrl'] as String?,
                'categories':
                    data['categories'] != null
                        ? List<String>.from(data['categories'] as List)
                        : null,
                'tags':
                    data['tags'] != null
                        ? List<String>.from(data['tags'] as List)
                        : null,
                'url': data['url'] as String,
                'date': (data['date'] as Timestamp).toDate(),
              };
            }).toList();
        filteredArticles = articles; // Initialize filtered articles
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error fetching articles: $e');
      setState(() => _loading = false);
    }
  }

  PreferredSizeWidget _buildAppBar() {
    if (_isSearching) {
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchController.clear();
              filteredArticles = articles;
            });
          },
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search ${widget.category}...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey[400]),
          ),
          style: const TextStyle(color: Colors.black, fontSize: 16),
          onChanged: _filterArticles,
        ),
      );
    }

    return AppBar(
      title: Text(widget.category),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = true;
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : filteredArticles.isEmpty
              ? Center(
                child: Text(
                  _isSearching
                      ? 'No results found'
                      : 'No ${widget.category} available',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              )
              : widget.category == 'Resource Center'
              ? _buildResourceCenterSections()
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: filteredArticles.length,
                separatorBuilder:
                    (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final article = filteredArticles[index];
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

  Widget _buildResourceCenterSections() {
    // Collect all unique categories
    final Set<String> allCategories = {};
    for (final article in filteredArticles) {
      final List<String>? cats = article['categories'] as List<String>?;
      if (cats != null) {
        allCategories.addAll(cats);
      }
    }
    final List<String> sortedCategories = allCategories.toList()..sort();

    // For each category, list articles that have that category
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final category in sortedCategories) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Text(
              category,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          ...filteredArticles
              .where(
                (article) =>
                    (article['categories'] as List<String>?)?.contains(
                      category,
                    ) ??
                    false,
              )
              .map(
                (article) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: ArticleCard(
                    title: article['title'],
                    author: article['author'],
                    imageUrl: article['imageUrl'],
                    tags: article['tags'],
                    url: article['url'],
                    date: article['date'],
                    category: widget.category,
                  ),
                ),
              ),
        ],
      ],
    );
  }
}
