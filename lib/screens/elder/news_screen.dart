import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../services/news_service.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  late Future<List<NewsArticle>> _newsFuture;

  @override
  void initState() {
    super.initState();
    _newsFuture = NewsService.fetchNews();
  }

  void _retry() {
    setState(() {
      _newsFuture = NewsService.fetchNews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Today\'s News',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<NewsArticle>>(
        future: _newsFuture,
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error
if (snapshot.hasError) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            size: 50,
          ),
          const SizedBox(height: 16),
          const Text(
            'News loading error',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            snapshot.error.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _retry,
            child: const Text('Try Again'),
          ),
        ],
      ),
    ),
  );
}
        

          final news = snapshot.data ?? [];

          // No articles
          if (news.isEmpty) {
            return const Center(
              child: Text(
                'No news available right now.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          // News list
          return ListView.builder(
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
                          category: article.category,
                          title: article.title,
                          content: article.description.isNotEmpty
                              ? article.description
                              : article.content,
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
                          article.category,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          article.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          article.sourceName,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tap to read',
                          style: TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class NewsArticleScreen extends StatefulWidget {
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
  State<NewsArticleScreen> createState() => _NewsArticleScreenState();
}

class _NewsArticleScreenState extends State<NewsArticleScreen> {
  final FlutterTts _tts = FlutterTts();

  Future<void> _readArticle() async {
    try {
      await _tts.stop();

      await _tts.setLanguage('en-IN');
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);

      await _tts.speak(
        '${widget.title}. ${widget.content}',
      );
    } catch (e) {
      debugPrint('TTS error: $e');
    }
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              widget.content,
              style: const TextStyle(
                fontSize: 19,
                height: 1.6,
              ),
            ),

            const SizedBox(height: 30),

            // KEEPING YOUR TEST SPEECH BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _readArticle,
                icon: const Icon(Icons.volume_up_rounded),
                label: const Text(
                  'Test Speech',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
