class DashboardWidget {
  final String id;
  final String? title;
  final String? description;
  final String? username;
  final String? user_id;
  final String? preview_version_url;
  final String? code_url;
  final int? views_count;
  final int? likes_count;
  final int? comments_count;
  final int? shares_count;
  bool like;
  bool save;
  bool follow;
  final bool? verified;
  final DateTime? created_at;
  final Map<String, dynamic>? metadata;

  DashboardWidget({
    required this.id,
    this.title,
    this.description,
    this.username,
    this.user_id,
    this.preview_version_url,
    this.code_url,
    this.views_count,
    this.likes_count,
    this.comments_count,
    this.shares_count,
    this.like = false,
    this.save = false,
    this.follow = false,
    this.verified,
    this.created_at,
    this.metadata,
  });

  factory DashboardWidget.fromJson(Map<String, dynamic> json) {
    return DashboardWidget(
      id: json['id'] ?? '',
      title: json['title'],
      description: json['description'],
      username: json['username'] ?? json['user_name'],
      user_id: json['user_id'],
      preview_version_url: json['preview_version_url'] ?? json['preview_url'],
      code_url: json['code_url'],
      views_count: json['views_count'] ?? 0,
      likes_count: json['likes_count'] ?? 0,
      comments_count: json['comments_count'] ?? 0,
      shares_count: json['shares_count'] ?? 0,
      like: json['like'] ?? false,
      save: json['save'] ?? false,
      follow: json['follow'] ?? false,
      verified: json['verified'] ?? false,
      created_at: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : null,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'username': username,
      'user_id': user_id,
      'preview_version_url': preview_version_url,
      'code_url': code_url,
      'views_count': views_count,
      'likes_count': likes_count,
      'comments_count': comments_count,
      'shares_count': shares_count,
      'like': like,
      'save': save,
      'follow': follow,
      'verified': verified,
      'created_at': created_at?.toIso8601String(),
      'metadata': metadata,
    };
  }
}