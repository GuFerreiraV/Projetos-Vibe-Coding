import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../widgets/news_card.dart';
import '../widgets/loading_indicator.dart';
import 'detail_screen.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Salvos')),
      body: Consumer<NewsProvider>(
        builder: (context, newsProvider, child) {
          final savedArticles = newsProvider.savedArticles;

          if (savedArticles.isEmpty) {
            return const EmptyState(
              icon: Icons.bookmark_border,
              title: 'Nenhum artigo salvo',
              subtitle:
                  'Salve artigos para ler depois tocando no ícone de bookmark.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: savedArticles.length,
            itemBuilder: (context, index) {
              final article = savedArticles[index];
              return Dismissible(
                key: Key(article.url),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Remover artigo?'),
                      content: const Text(
                        'Tem certeza que deseja remover este artigo dos salvos?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                            foregroundColor: theme.colorScheme.error,
                          ),
                          child: const Text('Remover'),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) {
                  newsProvider.removeArticle(article);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Artigo removido dos salvos'),
                      action: SnackBarAction(
                        label: 'Desfazer',
                        onPressed: () {
                          newsProvider.saveArticle(article);
                        },
                      ),
                    ),
                  );
                },
                child: NewsCard(
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}
