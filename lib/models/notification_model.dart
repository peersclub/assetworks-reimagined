class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String message;
  final String? user_id;
  final String? user_name;
  final String? user_avatar;
  final String? widget_id;
  final String? widget_title;
  final String? action_url;
  final bool is_read;
  final DateTime created_at;
  final Map<String, dynamic>? metadata;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.user_id,
    this.user_name,
    this.user_avatar,
    this.widget_id,
    this.widget_title,
    this.action_url,
    this.is_read = false,
    required this.created_at,
    this.metadata,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? 'general',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      user_id: json['user_id']?.toString(),
      user_name: json['user_name'],
      user_avatar: json['user_avatar'],
      widget_id: json['widget_id']?.toString(),
      widget_title: json['widget_title'],
      action_url: json['action_url'],
      is_read: json['is_read'] ?? false,
      created_at: json['created_at'] != null 
          ? (json['created_at'] is int 
              ? DateTime.fromMillisecondsSinceEpoch(json['created_at'])
              : DateTime.parse(json['created_at'].toString()))
          : DateTime.now(),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'user_id': user_id,
      'user_name': user_name,
      'user_avatar': user_avatar,
      'widget_id': widget_id,
      'widget_title': widget_title,
      'action_url': action_url,
      'is_read': is_read,
      'created_at': created_at.toIso8601String(),
      'metadata': metadata,
    };
  }
}