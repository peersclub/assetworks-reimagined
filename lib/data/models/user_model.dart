class UserModel {
  final String id;
  final String username;
  final String email;
  final String? fullName;
  final String? profilePicture;
  final String? bio;
  final int widgetCount;
  final int followersCount;
  final int followingCount;
  final bool isVerified;
  final bool isPremium;
  final DateTime joinedAt;
  
  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.profilePicture,
    this.bio,
    required this.widgetCount,
    required this.followersCount,
    required this.followingCount,
    required this.isVerified,
    required this.isPremium,
    required this.joinedAt,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Use full_name if username is empty
    String usernameValue = json['username'] ?? '';
    if (usernameValue.isEmpty && json['full_name'] != null) {
      usernameValue = json['full_name'];
    }
    
    return UserModel(
      id: json['id'] ?? '',
      username: usernameValue,
      email: json['email'] ?? '',
      fullName: json['full_name'],
      profilePicture: json['picture'] ?? json['profile_picture'] ?? json['profilePicture'],
      bio: json['bio'],
      widgetCount: json['widgets_count'] ?? json['widget_count'] ?? json['widgetCount'] ?? 0,
      followersCount: json['followers'] ?? json['followers_count'] ?? json['followersCount'] ?? 0,
      followingCount: json['followings'] ?? json['following_count'] ?? json['followingCount'] ?? 0,
      isVerified: json['is_verified'] ?? json['isVerified'] ?? false,
      isPremium: json['is_premium'] ?? json['isPremium'] ?? false,
      joinedAt: json['joined_at'] != null
          ? DateTime.parse(json['joined_at'])
          : json['joinedAt'] != null
              ? DateTime.parse(json['joinedAt'])
              : json['created_at'] != null
                  ? DateTime.fromMillisecondsSinceEpoch(json['created_at'])
                  : DateTime.now(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'full_name': fullName,
      'profile_picture': profilePicture,
      'bio': bio,
      'widget_count': widgetCount,
      'followers_count': followersCount,
      'following_count': followingCount,
      'is_verified': isVerified,
      'is_premium': isPremium,
      'joined_at': joinedAt.toIso8601String(),
    };
  }
  
  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? fullName,
    String? profilePicture,
    String? bio,
    int? widgetCount,
    int? followersCount,
    int? followingCount,
    bool? isVerified,
    bool? isPremium,
    DateTime? joinedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      profilePicture: profilePicture ?? this.profilePicture,
      bio: bio ?? this.bio,
      widgetCount: widgetCount ?? this.widgetCount,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      isVerified: isVerified ?? this.isVerified,
      isPremium: isPremium ?? this.isPremium,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}