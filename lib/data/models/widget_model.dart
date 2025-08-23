class WidgetModel {
  final String id;
  final String title;
  final String description;
  final String? thumbnail;
  final String? authorId;
  final String? authorName;
  final String? authorAvatar;
  final Map<String, dynamic> config;
  final List<String> tags;
  final int likes;
  final int comments;
  final int shares;
  final int views;
  final bool isSaved;
  final bool isLiked;
  final bool isPublic;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? category;
  final double? rating;
  final String? sourceUrl;
  final Map<String, dynamic>? metadata;
  
  WidgetModel({
    required this.id,
    required this.title,
    required this.description,
    this.thumbnail,
    this.authorId,
    this.authorName,
    this.authorAvatar,
    required this.config,
    this.tags = const [],
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.views = 0,
    this.isSaved = false,
    this.isLiked = false,
    this.isPublic = true,
    this.isFeatured = false,
    required this.createdAt,
    this.updatedAt,
    this.category,
    this.rating,
    this.sourceUrl,
    this.metadata,
  });
  
  factory WidgetModel.fromJson(Map<String, dynamic> json) {
    return WidgetModel(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? json['summary'] ?? '',
      thumbnail: json['thumbnail'] ?? json['preview_version_url'],
      authorId: json['author_id'] ?? json['user_id'],
      authorName: json['author_name'] ?? json['username'],
      authorAvatar: json['author_avatar'],
      config: json['config'] ?? {},
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      shares: json['shares'] ?? 0,
      views: json['views'] ?? 0,
      isSaved: json['is_saved'] ?? json['saved'] ?? false,
      isLiked: json['is_liked'] ?? json['like'] ?? false,
      isPublic: json['is_public'] ?? json['visibility'] == 'public' ?? true,
      isFeatured: json['is_featured'] ?? false,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? 
                 (json['created_at'] is int ? DateTime.fromMillisecondsSinceEpoch(json['created_at']) : DateTime.now()),
      updatedAt: json['updated_at'] != null ? 
                 (json['updated_at'] is int ? DateTime.fromMillisecondsSinceEpoch(json['updated_at']) : 
                  DateTime.tryParse(json['updated_at'].toString())) : null,
      category: json['category'],
      rating: json['rating']?.toDouble(),
      sourceUrl: json['source_url'] ?? json['full_version_url'],
      metadata: json['metadata'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnail': thumbnail,
      'author_id': authorId,
      'author_name': authorName,
      'author_avatar': authorAvatar,
      'config': config,
      'tags': tags,
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'views': views,
      'is_saved': isSaved,
      'is_liked': isLiked,
      'is_public': isPublic,
      'is_featured': isFeatured,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'category': category,
      'rating': rating,
      'source_url': sourceUrl,
      'metadata': metadata,
    };
  }
  
  WidgetModel copyWith({
    String? id,
    String? title,
    String? description,
    String? thumbnail,
    String? authorId,
    String? authorName,
    String? authorAvatar,
    Map<String, dynamic>? config,
    List<String>? tags,
    int? likes,
    int? comments,
    int? shares,
    int? views,
    bool? isSaved,
    bool? isLiked,
    bool? isPublic,
    bool? isFeatured,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? category,
    double? rating,
    String? sourceUrl,
    Map<String, dynamic>? metadata,
  }) {
    return WidgetModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnail: thumbnail ?? this.thumbnail,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      config: config ?? this.config,
      tags: tags ?? this.tags,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      views: views ?? this.views,
      isSaved: isSaved ?? this.isSaved,
      isLiked: isLiked ?? this.isLiked,
      isPublic: isPublic ?? this.isPublic,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      metadata: metadata ?? this.metadata,
    );
  }
}