class AnalysisModel {
  final String id;
  final String title;
  final String? description;
  final String query;
  final String? result;
  final String status; // pending, processing, completed, failed
  final String? authorId;
  final String? authorName;
  final List<String> attachments;
  final Map<String, dynamic>? parameters;
  final Map<String, dynamic>? resultData;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int views;
  final int likes;
  final int shares;
  final bool isSaved;
  final bool isPublic;
  final String? category;
  final List<String> tags;
  final double? confidence;
  final String? errorMessage;
  
  AnalysisModel({
    required this.id,
    required this.title,
    this.description,
    required this.query,
    this.result,
    required this.status,
    this.authorId,
    this.authorName,
    this.attachments = const [],
    this.parameters,
    this.resultData,
    required this.createdAt,
    this.completedAt,
    this.views = 0,
    this.likes = 0,
    this.shares = 0,
    this.isSaved = false,
    this.isPublic = true,
    this.category,
    this.tags = const [],
    this.confidence,
    this.errorMessage,
  });
  
  factory AnalysisModel.fromJson(Map<String, dynamic> json) {
    return AnalysisModel(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      query: json['query'] ?? '',
      result: json['result'],
      status: json['status'] ?? 'pending',
      authorId: json['author_id'] ?? json['user_id'],
      authorName: json['author_name'] ?? json['username'],
      attachments: json['attachments'] != null 
          ? List<String>.from(json['attachments']) 
          : [],
      parameters: json['parameters'],
      resultData: json['result_data'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at']) 
          : null,
      views: json['views'] ?? 0,
      likes: json['likes'] ?? 0,
      shares: json['shares'] ?? 0,
      isSaved: json['is_saved'] ?? json['save'] ?? false,
      isPublic: json['is_public'] ?? true,
      category: json['category'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      confidence: json['confidence']?.toDouble(),
      errorMessage: json['error_message'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'query': query,
      'result': result,
      'status': status,
      'author_id': authorId,
      'author_name': authorName,
      'attachments': attachments,
      'parameters': parameters,
      'result_data': resultData,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'views': views,
      'likes': likes,
      'shares': shares,
      'is_saved': isSaved,
      'is_public': isPublic,
      'category': category,
      'tags': tags,
      'confidence': confidence,
      'error_message': errorMessage,
    };
  }
  
  bool get isPending => status == 'pending';
  bool get isProcessing => status == 'processing';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
}