class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type; // like, comment, follow, mention, system, achievement, analysis, widget
  final String? actionType;
  final String? actionId;
  final String? fromUserId;
  final String? fromUserName;
  final String? fromUserAvatar;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? data;
  final String? imageUrl;
  final String? deepLink;
  
  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.actionType,
    this.actionId,
    this.fromUserId,
    this.fromUserName,
    this.fromUserAvatar,
    required this.timestamp,
    this.isRead = false,
    this.data,
    this.imageUrl,
    this.deepLink,
  });
  
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? json['body'] ?? '',
      type: json['type'] ?? 'system',
      actionType: json['action_type'],
      actionId: json['action_id'],
      fromUserId: json['from_user_id'],
      fromUserName: json['from_user_name'],
      fromUserAvatar: json['from_user_avatar'],
      timestamp: DateTime.parse(json['timestamp'] ?? json['created_at'] ?? DateTime.now().toIso8601String()),
      isRead: json['is_read'] ?? false,
      data: json['data'],
      imageUrl: json['image_url'],
      deepLink: json['deep_link'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'action_type': actionType,
      'action_id': actionId,
      'from_user_id': fromUserId,
      'from_user_name': fromUserName,
      'from_user_avatar': fromUserAvatar,
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead,
      'data': data,
      'image_url': imageUrl,
      'deep_link': deepLink,
    };
  }
  
  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    String? actionType,
    String? actionId,
    String? fromUserId,
    String? fromUserName,
    String? fromUserAvatar,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? data,
    String? imageUrl,
    String? deepLink,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      actionType: actionType ?? this.actionType,
      actionId: actionId ?? this.actionId,
      fromUserId: fromUserId ?? this.fromUserId,
      fromUserName: fromUserName ?? this.fromUserName,
      fromUserAvatar: fromUserAvatar ?? this.fromUserAvatar,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
      imageUrl: imageUrl ?? this.imageUrl,
      deepLink: deepLink ?? this.deepLink,
    );
  }
}