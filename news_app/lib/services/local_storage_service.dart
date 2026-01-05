import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/article.dart';

class LocalStorageService {
  static const String _savedArticlesKey = 'saved_articles';
  static const String _themeKey = 'is_dark_mode';

  /// Save an article to local storage
  Future<void> saveArticle(Article article) async {
    final prefs = await SharedPreferences.getInstance();
    final savedArticles = await getSavedArticles();

    // Check if already saved
    if (!savedArticles.any((a) => a.url == article.url)) {
      savedArticles.add(article.copyWith(isSaved: true));
      await _saveArticlesList(prefs, savedArticles);
    }
  }

  /// Remove an article from local storage
  Future<void> removeArticle(Article article) async {
    final prefs = await SharedPreferences.getInstance();
    final savedArticles = await getSavedArticles();

    savedArticles.removeWhere((a) => a.url == article.url);
    await _saveArticlesList(prefs, savedArticles);
  }

  /// Get all saved articles
  Future<List<Article>> getSavedArticles() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_savedArticlesKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => Article.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Check if an article is saved
  Future<bool> isArticleSaved(String url) async {
    final savedArticles = await getSavedArticles();
    return savedArticles.any((a) => a.url == url);
  }

  /// Save theme preference
  Future<void> saveThemePreference(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDarkMode);
  }

  /// Get theme preference
  Future<bool> getThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? true; // Default to dark mode
  }

  Future<void> _saveArticlesList(
    SharedPreferences prefs,
    List<Article> articles,
  ) async {
    final jsonList = articles.map((a) => a.toJson()).toList();
    await prefs.setString(_savedArticlesKey, jsonEncode(jsonList));
  }
}
