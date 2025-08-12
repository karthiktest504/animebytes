class AnimeStory {
  final String id;
  final String title;
  final String summary;
  final String? content;
  final String? imageUrl;
  final String? authorId;
  final String status;
  final int viewCount;
  final int likeCount;
  final int saveCount;
  final int shareCount;
  final bool isFeatured;
  final bool isTrending;
  final DateTime publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<AnimeTag>? tags;

  AnimeStory({
    required this.id,
    required this.title,
    required this.summary,
    this.content,
    this.imageUrl,
    this.authorId,
    required this.status,
    required this.viewCount,
    required this.likeCount,
    required this.saveCount,
    required this.shareCount,
    required this.isFeatured,
    required this.isTrending,
    required this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
    this.tags,
  });

  factory AnimeStory.fromJson(Map<String, dynamic> json) => AnimeStory(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        summary: json['summary'] ?? '',
        content: json['content'],
        imageUrl: json['image_url'],
        authorId: json['author_id'],
        status: json['status'] ?? 'published',
        viewCount: json['view_count'] ?? 0,
        likeCount: json['like_count'] ?? 0,
        saveCount: json['save_count'] ?? 0,
        shareCount: json['share_count'] ?? 0,
        isFeatured: json['is_featured'] ?? false,
        isTrending: json['is_trending'] ?? false,
        publishedAt: json['published_at'] != null
            ? DateTime.parse(json['published_at'])
            : DateTime.now(),
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'])
            : DateTime.now(),
        tags: json['anime_tags'] != null
            ? (json['anime_tags'] as List)
                .map((tag) => AnimeTag.fromJson(tag))
                .toList()
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'summary': summary,
        'content': content,
        'image_url': imageUrl,
        'author_id': authorId,
        'status': status,
        'view_count': viewCount,
        'like_count': likeCount,
        'save_count': saveCount,
        'share_count': shareCount,
        'is_featured': isFeatured,
        'is_trending': isTrending,
        'published_at': publishedAt.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

class AnimeTag {
  final String id;
  final String name;
  final String displayName;
  final String? description;
  final String iconEmoji;
  final bool isTrending;
  final bool isSystemTag;
  final int usageCount;
  final DateTime createdAt;

  AnimeTag({
    required this.id,
    required this.name,
    required this.displayName,
    this.description,
    required this.iconEmoji,
    required this.isTrending,
    required this.isSystemTag,
    required this.usageCount,
    required this.createdAt,
  });

  factory AnimeTag.fromJson(Map<String, dynamic> json) => AnimeTag(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        displayName: json['display_name'] ?? '',
        description: json['description'],
        iconEmoji: json['icon_emoji'] ?? '📺',
        isTrending: json['is_trending'] ?? false,
        isSystemTag: json['is_system_tag'] ?? false,
        usageCount: json['usage_count'] ?? 0,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'display_name': displayName,
        'description': description,
        'icon_emoji': iconEmoji,
        'is_trending': isTrending,
        'is_system_tag': isSystemTag,
        'usage_count': usageCount,
        'created_at': createdAt.toIso8601String(),
      };
}
