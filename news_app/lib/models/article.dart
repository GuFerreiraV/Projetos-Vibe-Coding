import 'dart:convert';

class Article {
  final String title;
  final String description;
  final String url;
  final String? imageUrl;
  final String source;
  final DateTime publishedAt;
  String? fullContent;
  bool isSaved;

  Article({
    required this.title,
    required this.description,
    required this.url,
    this.imageUrl,
    required this.source,
    required this.publishedAt,
    this.fullContent,
    this.isSaved = false,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? 'Sem título',
      description: json['description'] ?? 'Sem descrição',
      url: json['url'] ?? '',
      imageUrl: json['urlToImage'],
      source: json['source']?['name'] ?? 'Fonte desconhecida',
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'])
          : DateTime.now(),
      fullContent: json['fullContent'],
      isSaved: json['isSaved'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': imageUrl,
      'source': {'name': source},
      'publishedAt': publishedAt.toIso8601String(),
      'fullContent': fullContent,
      'isSaved': isSaved,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory Article.fromJsonString(String jsonString) {
    return Article.fromJson(jsonDecode(jsonString));
  }

  Article copyWith({
    String? title,
    String? description,
    String? url,
    String? imageUrl,
    String? source,
    DateTime? publishedAt,
    String? fullContent,
    bool? isSaved,
  }) {
    return Article(
      title: title ?? this.title,
      description: description ?? this.description,
      url: url ?? this.url,
      imageUrl: imageUrl ?? this.imageUrl,
      source: source ?? this.source,
      publishedAt: publishedAt ?? this.publishedAt,
      fullContent: fullContent ?? this.fullContent,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Article && other.url == url;
  }

  @override
  int get hashCode => url.hashCode;
}
