import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/article.dart';
import '../providers/news_provider.dart';
import '../widgets/loading_indicator.dart';

// Conditional import for WebView (not available on web)
import 'detail_screen_webview.dart'
    if (dart.library.html) 'detail_screen_web_stub.dart';

class DetailScreen extends StatefulWidget {
  final Article article;

  const DetailScreen({super.key, required this.article});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isLoading = true;
  bool _useWebView = false;
  String? _fullContent;

  // WebView controller - only used on mobile platforms
  WebViewControllerWrapper? _webViewController;

  @override
  void initState() {
    super.initState();
    _loadContent();
    if (!kIsWeb) {
      _webViewController = WebViewControllerWrapper();
      _webViewController!.init(
        onPageFinished: () {
          if (_useWebView && mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        },
      );
    }
  }

  Future<void> _loadContent() async {
    // First check if we already have the full content
    if (widget.article.fullContent != null) {
      setState(() {
        _fullContent = widget.article.fullContent;
        _isLoading = false;
      });
      return;
    }

    // Try to scrape the content
    final newsProvider = context.read<NewsProvider>();
    final success = await newsProvider.loadFullContent(widget.article);

    if (success) {
      // Find the updated article
      final updatedArticle = newsProvider.articles.firstWhere(
        (a) => a.url == widget.article.url,
        orElse: () => widget.article,
      );
      setState(() {
        _fullContent = updatedArticle.fullContent;
        _isLoading = false;
      });
    } else {
      // Fallback to WebView on mobile, or show "open in browser" on web
      setState(() {
        _useWebView = true;
        if (kIsWeb) {
          _isLoading = false;
        }
      });
      if (!kIsWeb && _webViewController != null) {
        _webViewController!.loadUrl(widget.article.url);
      }
    }
  }

  Future<void> _openInBrowser() async {
    final uri = Uri.parse(widget.article.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat("dd 'de' MMMM 'de' yyyy, HH:mm", 'pt_BR');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: widget.article.imageUrl != null ? 250 : 0,
            pinned: true,
            flexibleSpace: widget.article.imageUrl != null
                ? FlexibleSpaceBar(
                    background: CachedNetworkImage(
                      imageUrl: widget.article.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Container(color: theme.colorScheme.surface),
                      errorWidget: (context, url, error) => Container(
                        color: theme.colorScheme.surface,
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  )
                : null,
            actions: [
              IconButton(
                icon: const Icon(Icons.open_in_browser),
                onPressed: _openInBrowser,
                tooltip: 'Abrir no navegador',
              ),
              Consumer<NewsProvider>(
                builder: (context, newsProvider, _) {
                  final isSaved = newsProvider.isArticleSaved(
                    widget.article.url,
                  );
                  return IconButton(
                    icon: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                    ),
                    onPressed: () {
                      newsProvider.toggleSaveArticle(widget.article);
                    },
                    tooltip: isSaved ? 'Remover dos salvos' : 'Salvar',
                  );
                },
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.article.source,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Title
                  Text(
                    widget.article.title,
                    style: theme.textTheme.headlineMedium,
                  ),

                  const SizedBox(height: 12),

                  // Date
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateFormat.format(widget.article.publishedAt),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Divider
                  Divider(color: theme.dividerColor, height: 1),

                  const SizedBox(height: 24),

                  // Content
                  if (_isLoading)
                    const SizedBox(
                      height: 200,
                      child: LoadingIndicator(
                        message: 'Carregando conteúdo completo...',
                      ),
                    )
                  else if (_useWebView)
                    _buildWebViewOrFallback(theme)
                  else if (_fullContent != null)
                    SelectableText(
                      _fullContent!,
                      style: theme.textTheme.bodyLarge,
                    )
                  else
                    // Fallback to description
                    Text(
                      widget.article.description,
                      style: theme.textTheme.bodyLarge,
                    ),

                  const SizedBox(height: 32),

                  // Attribution
                  Center(
                    child: Text(
                      'Powered by NewsAPI',
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebViewOrFallback(ThemeData theme) {
    // On web platform, show a prompt to open in browser
    if (kIsWeb) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description as preview
          Text(widget.article.description, style: theme.textTheme.bodyLarge),

          const SizedBox(height: 24),

          // Open in browser card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.open_in_new,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  'Leia o artigo completo',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'O conteúdo completo está disponível no site original.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _openInBrowser,
                  icon: const Icon(Icons.open_in_browser),
                  label: const Text('Abrir no navegador'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.brightness == Brightness.dark
                        ? Colors.black
                        : Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // On mobile, show WebView
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.secondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Exibindo página original',
                  style: TextStyle(
                    color: theme.colorScheme.secondary,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_webViewController != null)
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _webViewController!.buildWidget(),
            ),
          ),
      ],
    );
  }
}
