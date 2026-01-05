import 'package:flutter/foundation.dart';
import '../models/article.dart';
import '../services/news_api_service.dart';
import '../services/content_scraper.dart';
import '../services/local_storage_service.dart';

class NewsProvider extends ChangeNotifier {
  final NewsApiService _apiService = NewsApiService();
  final ContentScraper _scraper = ContentScraper();
  final LocalStorageService _storageService = LocalStorageService();

  List<Article> _articles = [];
  List<Article> _savedArticles = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;
  int _totalResults = 0;

  // Getters
  List<Article> get articles => _articles;
  List<Article> get savedArticles => _savedArticles;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  bool get hasMore => _hasMore;
  int get totalResults => _totalResults;

  /// Load first page of news from API
  Future<void> loadNews() async {
    _isLoading = true;
    _error = null;
    _currentPage = 1;
    notifyListeners();

    try {
      final response = await _apiService.fetchNews(page: 1);
      _articles = response.articles;
      _hasMore = response.hasMore;
      _totalResults = response.totalResults;

      // Mark saved articles
      _markSavedArticles();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load more news (next page)
  Future<void> loadMoreNews() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      _currentPage++;
      final response = await _apiService.fetchNews(page: _currentPage);

      // Filter out duplicates based on URL or Title
      final existingUrls = _articles.map((a) => a.url).toSet();
      final existingTitles = _articles.map((a) => a.title).toSet();

      final newArticles = response.articles.where((article) {
        return !existingUrls.contains(article.url) &&
            !existingTitles.contains(article.title);
      }).toList();

      _articles.addAll(newArticles);

      // If we filtered all articles but API says there are more, load next page automatically?
      // For now, let's keep it simple. If data.length < response.articles.length it means we filtered some.

      _hasMore = response.hasMore;

      // Mark saved articles
      _markSavedArticles();
    } catch (e) {
      _currentPage--; // Revert page on error
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void _markSavedArticles() {
    final savedUrls = _savedArticles.map((a) => a.url).toSet();
    _articles = _articles.map((article) {
      if (savedUrls.contains(article.url)) {
        return article.copyWith(isSaved: true);
      }
      return article;
    }).toList();
  }

  /// Load saved articles from local storage
  Future<void> loadSavedArticles() async {
    _savedArticles = await _storageService.getSavedArticles();
    notifyListeners();
  }

  /// Save an article
  Future<void> saveArticle(Article article) async {
    await _storageService.saveArticle(article);
    await loadSavedArticles();

    // Update the article in the main list
    final index = _articles.indexWhere((a) => a.url == article.url);
    if (index != -1) {
      _articles[index] = _articles[index].copyWith(isSaved: true);
      notifyListeners();
    }
  }

  /// Remove a saved article
  Future<void> removeArticle(Article article) async {
    await _storageService.removeArticle(article);
    await loadSavedArticles();

    // Update the article in the main list
    final index = _articles.indexWhere((a) => a.url == article.url);
    if (index != -1) {
      _articles[index] = _articles[index].copyWith(isSaved: false);
      notifyListeners();
    }
  }

  /// Toggle save status of an article
  Future<void> toggleSaveArticle(Article article) async {
    if (article.isSaved) {
      await removeArticle(article);
    } else {
      await saveArticle(article);
    }
  }

  /// Load full content for an article
  /// Returns true if scraping was successful, false if WebView fallback is needed
  Future<bool> loadFullContent(Article article) async {
    final scraped = await _scraper.scrapeArticle(article.url);

    if (scraped != null && !scraped.useFallback) {
      // Update article with full content
      final index = _articles.indexWhere((a) => a.url == article.url);
      if (index != -1) {
        _articles[index] = _articles[index].copyWith(
          fullContent: scraped.content,
        );
      }

      // Also update in saved articles if present
      final savedIndex = _savedArticles.indexWhere((a) => a.url == article.url);
      if (savedIndex != -1) {
        _savedArticles[savedIndex] = _savedArticles[savedIndex].copyWith(
          fullContent: scraped.content,
        );
        await _storageService.saveArticle(_savedArticles[savedIndex]);
      }

      notifyListeners();
      return true;
    }

    return false; // Fallback to WebView
  }

  /// Check if an article is saved
  bool isArticleSaved(String url) {
    return _savedArticles.any((a) => a.url == url);
  }
}
