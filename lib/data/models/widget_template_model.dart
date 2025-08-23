class WidgetTemplateModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String previewImage;
  final String basePrompt;
  final List<String> requiredFields;
  final Map<String, dynamic> defaultValues;
  final int usageCount;
  final bool isPremium;
  final String creator;
  final DateTime createdAt;
  
  WidgetTemplateModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.previewImage,
    required this.basePrompt,
    required this.requiredFields,
    required this.defaultValues,
    required this.usageCount,
    required this.isPremium,
    required this.creator,
    required this.createdAt,
  });
  
  factory WidgetTemplateModel.fromJson(Map<String, dynamic> json) {
    return WidgetTemplateModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'General',
      previewImage: json['preview_image'] ?? json['previewImage'] ?? '',
      basePrompt: json['base_prompt'] ?? json['basePrompt'] ?? '',
      requiredFields: List<String>.from(json['required_fields'] ?? json['requiredFields'] ?? []),
      defaultValues: json['default_values'] ?? json['defaultValues'] ?? {},
      usageCount: json['usage_count'] ?? json['usageCount'] ?? 0,
      isPremium: json['is_premium'] ?? json['isPremium'] ?? false,
      creator: json['creator'] ?? 'AssetWorks',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'preview_image': previewImage,
      'base_prompt': basePrompt,
      'required_fields': requiredFields,
      'default_values': defaultValues,
      'usage_count': usageCount,
      'is_premium': isPremium,
      'creator': creator,
      'created_at': createdAt.toIso8601String(),
    };
  }
}