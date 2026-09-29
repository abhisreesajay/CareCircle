import 'package:flutter/material.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  final List<Map<String, String>> news = const [
    {
      'category': 'India',
      'title': 'Important national news headline will appear here.',
      'content':
          'This is where the complete news article will be displayed. '
          'Later, this content will come from the news service.',
    },
    {
      'category': 'World',
      'title': 'Important world news headline will appear here.',
      'content':
          'The complete article will appear here when the user opens '
          'the selected news story.',
    },
    {
      'category': 'Health',
      'title': 'Important health news headline will appear here.',
      'content':
          'Health-related news will be shown here in a simple format '
          'that is easy for elders to read.',
    },
    {
      'category': 'Technology',
      'title': 'Important technology news headline will appear here.',
      'content':
          'Technology news will appear here with simple and readable '
          'article content.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Today\'s News',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: news.length,
        itemBuilder: (context, index) {
          final article = news[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NewsArticleScreen(
                      category: article['category']!,
                      title: article['title']!,
                      content: article['content']!,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article['category']!,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      article['title']!,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Tap to read', style: TextStyle(fontSize: 15)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class NewsArticleScreen extends StatelessWidget {
  final String category;
  final String title;
  final String content;

  const NewsArticleScreen({
    super.key,
    required this.category,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(category)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(content, style: const TextStyle(fontSize: 19, height: 1.6)),
          ],
        ),
      ),
    );
  }
}
