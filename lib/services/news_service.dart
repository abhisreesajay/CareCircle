import 'dart:convert';

import 'package:http/http.dart' as http;

class NewsArticle {
  final String category;
  final String title;
  final String description;
  final String content;
  final String sourceName;
  final String url;

  NewsArticle({
    required this.category,
    required this.title,
    required this.description,
    required this.content,
    required this.sourceName,
    required this.url,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      category: 'India',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      sourceName: json['source']?['name'] ?? '',
      url: json['url'] ?? '',
    );
  }
}

class NewsService {
  static const String _apiKey = '31cdb1bcec591ee934c823a4a4220bea';

  static Future<List<NewsArticle>> fetchNews() async {
    if (_apiKey.isEmpty) {
      throw Exception('GNews API key is missing.');
    }

    final uri = Uri.parse(
      'https://gnews.io/api/v4/top-headlines'
      '?category=general'
      '&lang=en'
      '&country=in'
      '&max=10'
      '&apikey=$_apiKey',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
  throw Exception(
    'GNews error ${response.statusCode}: ${response.body}',
  );
}

    final data = jsonDecode(response.body);

    final articles = data['articles'] as List;

    return articles
        .map(
          (article) => NewsArticle.fromJson(
            article as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}