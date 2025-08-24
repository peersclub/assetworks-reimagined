class UserProfile {
  final String id;
  final String? name;
  final String? email;
  final String? username;
  final String? bio;
  final String? avatar;
  final String? cover_image;
  final int? followers_count;
  final int? following_count;
  final int? widgets_count;
  final bool? verified;
  final bool? is_following;
  final DateTime? created_at;
  final Map<String, dynamic>? settings;
  final Map<String, dynamic>? social_links;

  UserProfile({
    required this.id,
    this.name,
    this.email,
    this.username,
    this.bio,
    this.avatar,
    this.cover_image,
    this.followers_count,
    this.following_count,
    this.widgets_count,
    this.verified,
    this.is_following,
    this.created_at,
    this.settings,
    this.social_links,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      name: json['name'],
      email: json['email'],
      username: json['username'],
      bio: json['bio'],
      avatar: json['avatar'] ?? json['profile_picture'],
      cover_image: json['cover_image'],
      followers_count: json['followers_count'] ?? 0,
      following_count: json['following_count'] ?? 0,
      widgets_count: json['widgets_count'] ?? 0,
      verified: json['verified'] ?? false,
      is_following: json['is_following'] ?? false,
      created_at: json['created_at'] != null 
          ? (json['created_at'] is int 
              ? DateTime.fromMillisecondsSinceEpoch(json['created_at'])
              : DateTime.parse(json['created_at'].toString()))
          : null,
      settings: json['settings'],
      social_links: json['social_links'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'username': username,
      'bio': bio,
      'avatar': avatar,
      'cover_image': cover_image,
      'followers_count': followers_count,
      'following_count': following_count,
      'widgets_count': widgets_count,
      'verified': verified,
      'is_following': is_following,
      'created_at': created_at?.toIso8601String(),
      'settings': settings,
      'social_links': social_links,
    };
  }
}