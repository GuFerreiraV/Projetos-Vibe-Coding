import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_keys.dart';
import '../models/article.dart';

class NewsApiService {
  static const String _baseUrl = 'https://newsapi.org/v2';
  static const int pageSize = 5;

  /// Fetches news with pagination support
  Future<NewsResponse> fetchNews({int page = 1}) async {
    final url = Uri.parse(
      '$_baseUrl/everything?'
      'q=tecnologia OR tech OR software OR programação OR IA OR inteligência artificial OR NVIDIA&'
      'domains=g1.globo.com,tecmundo.com.br,olhardigital.com.br,canaltech.com.br&'
      'sortBy=publishedAt&'
      'pageSize=$pageSize&'
      'page=$page&'
      'apiKey=$newsApiKey',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'ok') {
          final articles = (data['articles'] as List)
              .map((article) => Article.fromJson(article))
              .where((article) => article.title != '[Removed]')
              .toList();

          final totalResults = data['totalResults'] as int? ?? 0;
          final hasMore = (page * pageSize) < totalResults;

          return NewsResponse(
            articles: articles,
            totalResults: totalResults,
            hasMore: hasMore,
          );
        } else {
          throw Exception('API Error: ${data['message']}');
        }
      } else if (response.statusCode == 426) {
        throw Exception(
          'Limite de requisições atingido. Tente novamente amanhã.',
        );
      } else if (response.statusCode == 401) {
        throw Exception('API Key inválida. Verifique sua configuração.');
      } else {
        throw Exception('Erro ao buscar notícias: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erro de conexão: $e');
    }
  }
}

class NewsResponse {
  final List<Article> articles;
  final int totalResults;
  final bool hasMore;

  NewsResponse({
    required this.articles,
    required this.totalResults,
    required this.hasMore,
  });
}
