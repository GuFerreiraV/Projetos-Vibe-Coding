import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';

class ContentScraper {
  /// Attempts to extract the full article content from a URL
  /// Returns null if scraping fails (indicating WebView fallback should be used)
  Future<ScrapedContent?> scrapeArticle(String url) async {
    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return null;
      }

      final document = parser.parse(response.body);

      // Remove unwanted elements
      _removeUnwantedElements(document);

      // Try to find the article content using common selectors
      String? content = _extractContent(document);

      if (content == null || content.length < 200) {
        return null; // Content too short, probably failed
      }

      return ScrapedContent(content: content, useFallback: false);
    } catch (e) {
      // Return null to indicate fallback to WebView
      return null;
    }
  }

  void _removeUnwantedElements(Document document) {
    // Remove scripts, styles, ads, comments, etc.
    final selectorsToRemove = [
      'script',
      'style',
      'nav',
      'header',
      'footer',
      'aside',
      'iframe',
      '.ad',
      '.ads',
      '.advertisement',
      '.social-share',
      '.comments',
      '.related-posts',
      '#comments',
      '.sidebar',
    ];

    for (final selector in selectorsToRemove) {
      document
          .querySelectorAll(selector)
          .forEach((element) => element.remove());
    }
  }

  String? _extractContent(Document document) {
    // Priority list of selectors to try
    final contentSelectors = [
      'article',
      '[itemprop="articleBody"]',
      '.article-content',
      '.article-body',
      '.post-content',
      '.entry-content',
      '.content-text',
      '.materia-texto',
      '.texto',
      '.news-content',
      'main',
      '.main-content',
    ];

    for (final selector in contentSelectors) {
      final elements = document.querySelectorAll(selector);
      if (elements.isNotEmpty) {
        final content = _extractTextFromElement(elements.first);
        if (content.length > 200) {
          return content;
        }
      }
    }

    // Fallback: try to get all paragraphs
    final paragraphs = document.querySelectorAll('p');
    if (paragraphs.length > 3) {
      final buffer = StringBuffer();
      for (final p in paragraphs) {
        final text = p.text.trim();
        if (text.length > 50) {
          buffer.writeln(text);
          buffer.writeln();
        }
      }
      final content = buffer.toString().trim();
      if (content.length > 200) {
        return content;
      }
    }

    return null;
  }

  String _extractTextFromElement(Element element) {
    final buffer = StringBuffer();

    // Get all paragraphs within the element
    final paragraphs = element.querySelectorAll('p');

    if (paragraphs.isNotEmpty) {
      for (final p in paragraphs) {
        final text = p.text.trim();
        if (text.isNotEmpty && text.length > 20) {
          buffer.writeln(text);
          buffer.writeln();
        }
      }
    } else {
      // If no paragraphs, get all text
      buffer.write(element.text.trim());
    }

    return buffer.toString().trim();
  }
}

class ScrapedContent {
  final String content;
  final bool useFallback;

  ScrapedContent({required this.content, required this.useFallback});
}
