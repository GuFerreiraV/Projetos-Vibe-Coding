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
      'q=tecnologia OR software OR programação OR inteligência artificial&'
      'language=pt&'
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
              .where((article) => _isTechRelated(article.title))
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

  /// Verifica se o título contém palavras-chave relacionadas a tecnologia
  bool _isTechRelated(String title) {
    final lowerTitle = title.toLowerCase();
    final techKeywords = [
      'tech',
      'tecnologia',
      'software',
      'programação',
      'programador',
      'desenvolvedor',
      'desenvolvimento',
      'app',
      'aplicativo',
      'inteligência artificial',
      'ia',
      'ai',
      'machine learning',
      'startup',
      'google',
      'microsoft',
      'apple',
      'amazon',
      'meta',
      'nvidia',
      'openai',
      'chatgpt',
      'android',
      'iphone',
      'samsung',
      'internet',
      'cibersegurança',
      'hacker',
      'dados',
      'cloud',
      'nuvem',
      'computador',
      'notebook',
      'celular',
      'smartphone',
      'games',
      'jogos',
      'gaming',
      'console',
      'playstation',
      'xbox',
      'nintendo',
      'bitcoin',
      'cripto',
      'blockchain',
      'robô',
      'automação',
      'digital',
      '5g',
      'chip',
      'processador',
      'gpu',
      'cpu',
    ];

    return techKeywords.any((keyword) => lowerTitle.contains(keyword));
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
