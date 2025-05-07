import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'webview_controller.dart';

Map categoryMap =  {7: 'Advocacy', 456: 'Blog', 6: 'Campaigns', 256: 'Community', 11: 'Conversion Therapy', 4: 'Donations', 8: 'Education', 12: 'Events', 244: 'Gender Identity', 183: 'LGBTQ'};
Map tagMap = {215: 'advocacy', 255: 'allyship', 278: 'anxious-feelings', 530: 'bipoc', 259: 'bisexual', 436: 'blacktrevor', 281: 'brand', 537: 'celebrities-creators', 246: 'coming-out', 437: 'communities-of-color'};
Map spanishCategoryMap = {16: 'aliadx', 20: 'amigxs', 23: 'autoconocimiento', 25: 'autocuidado', 17: 'bisexual', 13: 'comunidad', 22: 'educacion-lgbtq', 15: 'expresion-de-genero', 21: 'familia', 14: 'hablar-de-suicidio'};

class ArticleCard extends StatelessWidget {
  final String title;
  final String? author;
  final String? photo;
  final List<String>? categories;
  final String url;
  final DateTime date;
  final String category;

  const ArticleCard({
    super.key,
    required this.title,
    this.author,
    this.photo,
    this.categories,
    required this.url,
    required this.date,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
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
              if (photo != null && category != 'Research Briefs') ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.network(
                    photo!,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 120,
                        height: 120,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported, color: Colors.grey),
                      );
                    },
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
                    if (categories != null && categories!.isNotEmpty) ...[
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children:
                            categories!
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
  // List of articles fetched from Firestore
  List<Map<String, dynamic>> articles = [];
  // separate filtered articles from the original list to avoid modifying the original list
  List<Map<String, dynamic>> filteredArticles = [];
  bool _loading = true;
  // TextEditingController for the search bar
  final TextEditingController _searchController = TextEditingController();
  List<String> selectedCategories = [];
  List<String> availableCategories = [];

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


  // Filter articles based on the search query and selected categories
  void _filterArticles(String query) {
    // if there are no categories shown, don't do anything
    if (query.isEmpty) {
      setState(() {
        if (selectedCategories.isNotEmpty) {
          _filterByCategories();
        } else {
          filteredArticles = articles;
        }
      });
      return;
    }

    setState(() {
      // '\b' is used to match the first word character, then RegExp.escape(query) ignores any special characters in the query
      // This regex will match the query at the start of a word
      RegExp startOfWordRegex = RegExp(r'\b' + RegExp.escape(query), caseSensitive: false);

      filteredArticles = articles.where((article) {
        // Check if title matches
        bool titleMatch = startOfWordRegex.hasMatch(article['title'].toString());

        // Check if categories match
        bool tagMatch = false;
        if (article['categories'] != null) {
          tagMatch = (article['categories'] as List<String>).any(
            (tag) => startOfWordRegex.hasMatch(tag),
          );
        }

        // If we have selected categories, filter by them too
        bool tagFilterMatch = true;
        if (selectedCategories.isNotEmpty) {
          if (article['categories'] == null) {
            tagFilterMatch = false;
          } else {
            List<String> articleCategories = List<String>.from(article['categories'] as List);
            tagFilterMatch = selectedCategories.any(
              (tag) => articleCategories.contains(tag)
            );
          }
        }
        // Return true if either title or categories match, and if selected categories match
        return (titleMatch || tagMatch) && tagFilterMatch;
      }).toList();
    });
  }

  void _filterByCategories() {
    if (selectedCategories.isEmpty) {
      setState(() {
        if (_searchController.text.isNotEmpty) {
          _filterArticles(_searchController.text);
        } else {
          filteredArticles = articles;
        }
      });
      return;
    }

    setState(() {
      filteredArticles = articles.where((article) {
        if (article['categories'] == null) return false;

        List<String> articleCategories = List<String>.from(article['categories'] as List);
        return selectedCategories.any(
          (tag) => articleCategories.contains(tag)
        );
      }).toList();

      if (_searchController.text.isNotEmpty) {
        _filterArticles(_searchController.text);
      }
    });
  }

  // Extract all unique categories from the articles
  void _extractAvailableCategories() {
    final Set<String> tagSet = <String>{};
    // Iterate through each article and add its categories to the set
    for (var article in articles) {
      if (article['categories'] != null) {
        final categories = List<String>.from(article['categories'] as List);
        tagSet.addAll(categories);
      }
    }

    setState(() {
      availableCategories = tagSet.toList()..sort();
    });
  }

  Future<void> _fetchArticles() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot;
      // no need for the if statement
      snapshot = await FirebaseFirestore.instance
          .collection('resourcesPage')
          .doc(widget.category)
          .collection('articles')
          .orderBy('date', descending: true)
          .get();

      // Check if widget is still mounted before calling setState
      if (!mounted) return;

      setState(() {
        articles =
            snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'title': data['title'] as String,
                'author': data['author'] as String?,
                'photo': data['photo'] as String?,
                'categories':
                    data['categories'] != null
                        ? List<String>.from(data['categories'] as List)
                        : null,
                'url': data['url'] as String,
                'date': (data['date'] as Timestamp).toDate(),
              };
            }).toList();
        filteredArticles = articles; // Initialize filtered articles
        _loading = false;

        // Extract available categories from the articles
        _extractAvailableCategories();
      });
    } catch (e) {
      // Check if widget is still mounted before calling setState
      if (!mounted) return;

      debugPrint('Error fetching articles: $e');
      setState(() => _loading = false);
    }
  }

  // Little popup for the tag filters
  void _showTagFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Filter by Categories'),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: availableCategories.isEmpty
                    ? const Center(child: Text('No categories available'))
                    : ListView(
                        shrinkWrap: true,
                        children: availableCategories.map((tag) {
                          return CheckboxListTile(
                            title: Text(tag),
                            value: selectedCategories.contains(tag),
                            activeColor: Theme.of(context).primaryColor,
                            onChanged: (bool? value) {
                              setStateDialog(() {
                                if (value == true) {
                                  selectedCategories.add(tag);
                                } else {
                                  selectedCategories.remove(tag);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
              ),
              actions: [
                TextButton(
                  child: const Text('Clear All'),
                  onPressed: () {
                    setStateDialog(() {
                      selectedCategories.clear();
                    });
                  },
                ),
                ElevatedButton(
                  child: const Text('Apply Filters'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _filterByCategories();
                  },
                ),
              ],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              buttonPadding: const EdgeInsets.symmetric(horizontal: 16),
              actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            );
          },
        );
      },
    );
  }

  // Build the search bar and filter chips
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(50),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search ${widget.category}...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey[400]),
              ),
              onChanged: _filterArticles,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: selectedCategories.isNotEmpty ? Colors.blue.withAlpha(50) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.filter_list,
                color: selectedCategories.isNotEmpty ? Theme.of(context).primaryColor : Colors.grey[600],
              ),
              onPressed: _showTagFilterDialog,
              tooltip: 'Filter by Categories',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    if (selectedCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${filteredArticles.length} results',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedCategories.clear();
                    _filterByCategories();
                  });
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Clear all'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: selectedCategories.map((tag) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Chip(
                    label: Text(
                      tag,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Colors.blue.shade100,
                    onDeleted: () {
                      setState(() {
                        selectedCategories.remove(tag);
                        _filterByCategories();
                      });
                    },
                    deleteIconColor: Colors.blue.shade800,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // This should be implemented to handle the Resource Center layout
  Widget _buildResourceCenterSections() {
    // Group articles by their first category (if available)
    final Map<String, List<Map<String, dynamic>>> articlesByCategory = {};

    for (final article in filteredArticles) {
      String categoryKey = 'Uncategorized';
      if (article['categories'] != null && (article['categories'] as List<String>).isNotEmpty) {
        categoryKey = (article['categories'] as List<String>)[0];
      }

      if (!articlesByCategory.containsKey(categoryKey)) {
        articlesByCategory[categoryKey] = [];
      }
      articlesByCategory[categoryKey]!.add(article);
    }

    // Sort the categories alphabetically
    final sortedCategories = articlesByCategory.keys.toList()..sort();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final category in sortedCategories) ...[
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              category,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const Divider(),
          ...articlesByCategory[category]!.map((article) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: ArticleCard(
              title: article['title'],
              author: article['author'],
              photo: article['photo'],
              categories: article['categories'],
              url: article['url'],
              date: article['date'],
              category: widget.category,
            ),
          )),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSearchBar(),
                _buildFilterChips(),
                Expanded(
                  child: filteredArticles.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                _searchController.text.isNotEmpty || selectedCategories.isNotEmpty
                                    ? 'No results found'
                                    : 'No ${widget.category} available',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (_searchController.text.isNotEmpty || selectedCategories.isNotEmpty)
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                      selectedCategories.clear();
                                      filteredArticles = articles;
                                    });
                                  },
                                  child: const Text('Clear all filters'),
                                ),
                            ],
                          ),
                        )
                      : widget.category == 'Resource Center'
                          ? _buildResourceCenterSections()
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredArticles.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final article = filteredArticles[index];
                                return ArticleCard(
                                  title: article['title'],
                                  author: article['author'],
                                  photo: article['photo'],
                                  categories: article['categories'],
                                  url: article['url'],
                                  date: article['date'],
                                  category: widget.category,
                                );
                              },
                            ),
                ),
              ],
            ),
    );
  }
}