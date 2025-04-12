import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Custom ArticleCard Widget
class ArticleCard extends StatelessWidget {
  final String title;
  final String author;
  final String imageUrl;
  final List<String> tags;

  const ArticleCard({
    super.key,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image on the left
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: Image.network(
              imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 100),
            ),
          ),
          // Title, author, and tags
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("By $author", style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: tags
                        .map((tag) => Chip(
                              label: Text(tag),
                              backgroundColor: Colors.blue.shade100,
                            ))
                        .toList(),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

// Articles Page
class ArticlesPage extends StatefulWidget {
  final String section;

  const ArticlesPage({super.key, required this.section});

  @override
  State<ArticlesPage> createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
  late final CollectionReference _articlesRef;

  @override
  void initState() {
    super.initState();
    _articlesRef = FirebaseFirestore.instance.collection(widget.section);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.section)),
      body: StreamBuilder<QuerySnapshot>(
        stream: _articlesRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No articles found."));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              return ArticleCard(
                title: data['title'] ?? 'No Title',
                author: data['author'] ?? 'Unknown',
                imageUrl: data['image'] ?? '',
                tags: List<String>.from(data['tags'] ?? []),
              );
            },
          );
        },
      ),
    );
  }
}
