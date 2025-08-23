class WidgetResponseModel {
  final String id;
  final String userId;
  final String title;
  final String tagline;
  final String summary;
  final String username;
  final String originalPrompt;
  final String fullVersionUrl;
  final String previewVersionUrl;
  final int likes;
  final int dislikes;
  final int followers;
  final int shares;
  final String category;
  final bool save;
  final bool like;
  final bool dislike;
  final bool follow;
  final bool unfollow;
  final bool shared;
  final bool reported;
  final int createdAt;
  final int updatedAt;
  final String? userSessionId; // For AI conversation continuity
  
  // Remix fields
  final bool isRemix;
  final String? remixedFromId;
  final String? remixedFromTitle;
  final String? remixedFromUsername;
  final String? remixedFromUserId;
  final String? remixedFromUrl;
  final String? remixedFromPrompt;
  final int? remixedFromCreatedAt;
  
  WidgetResponseModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.tagline,
    required this.summary,
    required this.username,
    required this.originalPrompt,
    required this.fullVersionUrl,
    required this.previewVersionUrl,
    required this.likes,
    required this.dislikes,
    required this.followers,
    required this.shares,
    required this.category,
    required this.save,
    required this.like,
    required this.dislike,
    required this.follow,
    required this.unfollow,
    required this.shared,
    required this.reported,
    required this.createdAt,
    required this.updatedAt,
    this.userSessionId,
    this.isRemix = false,
    this.remixedFromId,
    this.remixedFromTitle,
    this.remixedFromUsername,
    this.remixedFromUserId,
    this.remixedFromUrl,
    this.remixedFromPrompt,
    this.remixedFromCreatedAt,
  });
  
  factory WidgetResponseModel.fromJson(Map<String, dynamic> json) {
    return WidgetResponseModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? json['userId'] ?? '',
      title: json['title'] ?? '',
      tagline: json['tagline'] ?? '',
      summary: json['summary'] ?? '',
      username: json['username'] ?? '',
      originalPrompt: json['original_prompt'] ?? json['originalPrompt'] ?? '',
      fullVersionUrl: json['full_version_url'] ?? json['fullVersionUrl'] ?? '',
      previewVersionUrl: json['preview_version_url'] ?? json['previewVersionUrl'] ?? '',
      likes: json['likes'] ?? 0,
      dislikes: json['dislikes'] ?? 0,
      followers: json['followers'] ?? 0,
      shares: json['shares'] ?? 0,
      category: json['category'] ?? 'General',
      save: json['save'] ?? false,
      like: json['like'] ?? false,
      dislike: json['dislike'] ?? false,
      follow: json['follow'] ?? false,
      unfollow: json['unfollow'] ?? false,
      shared: json['shared'] ?? false,
      reported: json['reported'] ?? false,
      createdAt: json['created_at'] ?? json['createdAt'] ?? 0,
      updatedAt: json['updated_at'] ?? json['updatedAt'] ?? 0,
      userSessionId: json['user_session_id'] ?? json['userSessionId'],
      isRemix: json['is_remix'] ?? json['isRemix'] ?? false,
      remixedFromId: json['remixed_from_id'] ?? json['remixedFromId'],
      remixedFromTitle: json['remixed_from_title'] ?? json['remixedFromTitle'],
      remixedFromUsername: json['remixed_from_username'] ?? json['remixedFromUsername'],
      remixedFromUserId: json['remixed_from_user_id'] ?? json['remixedFromUserId'],
      remixedFromUrl: json['remixed_from_url'] ?? json['remixedFromUrl'],
      remixedFromPrompt: json['remixed_from_prompt'] ?? json['remixedFromPrompt'],
      remixedFromCreatedAt: json['remixed_from_created_at'] ?? json['remixedFromCreatedAt'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'tagline': tagline,
      'summary': summary,
      'username': username,
      'original_prompt': originalPrompt,
      'full_version_url': fullVersionUrl,
      'preview_version_url': previewVersionUrl,
      'likes': likes,
      'dislikes': dislikes,
      'followers': followers,
      'shares': shares,
      'category': category,
      'save': save,
      'like': like,
      'dislike': dislike,
      'follow': follow,
      'unfollow': unfollow,
      'shared': shared,
      'reported': reported,
      'created_at': createdAt,
      'updated_at': updatedAt,
      if (userSessionId != null) 'user_session_id': userSessionId,
      'is_remix': isRemix,
      if (remixedFromId != null) 'remixed_from_id': remixedFromId,
      if (remixedFromTitle != null) 'remixed_from_title': remixedFromTitle,
      if (remixedFromUsername != null) 'remixed_from_username': remixedFromUsername,
      if (remixedFromUserId != null) 'remixed_from_user_id': remixedFromUserId,
      if (remixedFromUrl != null) 'remixed_from_url': remixedFromUrl,
      if (remixedFromPrompt != null) 'remixed_from_prompt': remixedFromPrompt,
      if (remixedFromCreatedAt != null) 'remixed_from_created_at': remixedFromCreatedAt,
    };
  }
  
  WidgetResponseModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? tagline,
    String? summary,
    String? username,
    String? originalPrompt,
    String? fullVersionUrl,
    String? previewVersionUrl,
    int? likes,
    int? dislikes,
    int? followers,
    int? shares,
    String? category,
    bool? save,
    bool? like,
    bool? dislike,
    bool? follow,
    bool? unfollow,
    bool? shared,
    bool? reported,
    int? createdAt,
    int? updatedAt,
    String? userSessionId,
    bool? isRemix,
    String? remixedFromId,
    String? remixedFromTitle,
    String? remixedFromUsername,
    String? remixedFromUserId,
    String? remixedFromUrl,
    String? remixedFromPrompt,
    int? remixedFromCreatedAt,
  }) {
    return WidgetResponseModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      tagline: tagline ?? this.tagline,
      summary: summary ?? this.summary,
      username: username ?? this.username,
      originalPrompt: originalPrompt ?? this.originalPrompt,
      fullVersionUrl: fullVersionUrl ?? this.fullVersionUrl,
      previewVersionUrl: previewVersionUrl ?? this.previewVersionUrl,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
      followers: followers ?? this.followers,
      shares: shares ?? this.shares,
      category: category ?? this.category,
      save: save ?? this.save,
      like: like ?? this.like,
      dislike: dislike ?? this.dislike,
      follow: follow ?? this.follow,
      unfollow: unfollow ?? this.unfollow,
      shared: shared ?? this.shared,
      reported: reported ?? this.reported,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userSessionId: userSessionId ?? this.userSessionId,
      isRemix: isRemix ?? this.isRemix,
      remixedFromId: remixedFromId ?? this.remixedFromId,
      remixedFromTitle: remixedFromTitle ?? this.remixedFromTitle,
      remixedFromUsername: remixedFromUsername ?? this.remixedFromUsername,
      remixedFromUserId: remixedFromUserId ?? this.remixedFromUserId,
      remixedFromUrl: remixedFromUrl ?? this.remixedFromUrl,
      remixedFromPrompt: remixedFromPrompt ?? this.remixedFromPrompt,
      remixedFromCreatedAt: remixedFromCreatedAt ?? this.remixedFromCreatedAt,
    );
  }
}