import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/news_card.dart';
import '../widgets/loading_indicator.dart';
import 'detail_screen.dart';
import 'saved_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadData() async {
    final newsProvider = context.read<NewsProvider>();
    await newsProvider.loadSavedArticles();
    await newsProvider.loadNews();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<NewsProvider>().loadMoreNews();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tech News'),
        actions: [
          IconButton(
            icon: Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) => Icon(
                themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              ),
            ),
            onPressed: () {
              context.read<ThemeProvider>().toggleTheme();
            },
            tooltip: 'Alternar tema',
          ),
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SavedScreen()),
              );
            },
            tooltip: 'Artigos salvos',
          ),
        ],
      ),
      body: Consumer<NewsProvider>(
        builder: (context, newsProvider, child) {
          if (newsProvider.isLoading) {
            return const LoadingIndicator(message: 'Carregando notícias...');
          }

          if (newsProvider.error != null) {
            return ErrorDisplay(
              message: newsProvider.error!,
              onRetry: () => newsProvider.loadNews(),
            );
          }

          if (newsProvider.articles.isEmpty) {
            return const EmptyState(
              icon: Icons.article_outlined,
              title: 'Nenhuma notícia encontrada',
              subtitle: 'Tente novamente mais tarde.',
            );
          }

          return RefreshIndicator(
            onRefresh: () => newsProvider.loadNews(),
            color: theme.colorScheme.primary,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount:
                  newsProvider.articles.length +
                  1, // +1 for load more indicator
              itemBuilder: (context, index) {
                // Load more indicator at the end
                if (index == newsProvider.articles.length) {
                  if (newsProvider.isLoadingMore) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  } else if (newsProvider.hasMore) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: TextButton.icon(
                          onPressed: () => newsProvider.loadMoreNews(),
                          icon: const Icon(Icons.expand_more),
                          label: const Text('Carregar mais'),
                        ),
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          'Você viu todas as ${newsProvider.totalResults} notícias',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    );
                  }
                }

                final article = newsProvider.articles[index];
                return NewsCard(
                  article: article,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(article: article),
                      ),
                    );
                  },
                  onSave: () {
                    newsProvider.toggleSaveArticle(article);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
