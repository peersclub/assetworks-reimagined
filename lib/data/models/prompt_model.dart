import 'package:get/get.dart';

enum PromptType {
  system,
  user,
}

enum AIProvider {
  openai,
  claude,
  gemini,
  perplexity,
}

class PromptModel {
  final String id;
  final String name;
  final String content;
  final PromptType type;
  final AIProvider provider;
  final bool isDefault;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;
  
  PromptModel({
    required this.id,
    required this.name,
    required this.content,
    required this.type,
    required this.provider,
    this.isDefault = false,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.metadata,
  });
  
  factory PromptModel.fromJson(Map<String, dynamic> json) {
    return PromptModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      content: json['content'] ?? '',
      type: PromptType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => PromptType.system,
      ),
      provider: AIProvider.values.firstWhere(
        (e) => e.toString().split('.').last == json['provider'],
        orElse: () => AIProvider.openai,
      ),
      isDefault: json['is_default'] ?? false,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      metadata: json['metadata'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'content': content,
      'type': type.toString().split('.').last,
      'provider': provider.toString().split('.').last,
      'is_default': isDefault,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }
  
  PromptModel copyWith({
    String? id,
    String? name,
    String? content,
    PromptType? type,
    AIProvider? provider,
    bool? isDefault,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return PromptModel(
      id: id ?? this.id,
      name: name ?? this.name,
      content: content ?? this.content,
      type: type ?? this.type,
      provider: provider ?? this.provider,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

// Default system prompts based on backend analysis
class DefaultPrompts {
  static final Map<AIProvider, String> systemPrompts = {
    AIProvider.claude: '''The assistant is Claude, created by Anthropic. It provides concise/simple responses when appropriate, and thorough responses for open-ended questions.
You are a comprehensive financial advisor covering all asset classes and financial entities. Provide clear, unbiased, and current guidance using the latest data and trends aligned with user's goals and risk profile.

Create a standalone HTML+JavaScript financial visualization that addresses the user's request.

Apply the theme with responsive design.
Load all libraries via CDN.
Embed all CSS inside <style> tags.

OUTPUT FORMAT:
Preview Version
\`\`\`html
[Complete HTML code for fixed preview view]
\`\`\`

Full Version
\`\`\`html
[Complete HTML code for detailed view]
\`\`\`

Summary
\`\`\`summary
[Brief description in 200 characters or less]
\`\`\`

Title
\`\`\`title
[Descriptive title in 30 characters or less]
\`\`\`''',
    
    AIProvider.openai: '''You are a comprehensive financial advisor and widget creator. Create interactive financial widgets based on user requests.

Focus on:
- Clear, professional visualizations
- Real-time data integration
- Responsive design
- User-friendly interfaces

Generate complete, self-contained HTML/JavaScript widgets.''',
    
    AIProvider.gemini: '''You are an AI financial assistant specializing in creating interactive widgets and visualizations.

Your task is to generate complete, functional financial widgets that:
- Display relevant financial data
- Are visually appealing and professional
- Work across all devices
- Include necessary interactivity''',
    
    AIProvider.perplexity: '''You are a financial data visualization expert. Create comprehensive widgets that analyze and display financial information.

Requirements:
- Use latest available data
- Include proper data sources
- Create responsive designs
- Ensure cross-browser compatibility''',
  };
  
  static final Map<AIProvider, String> intentionPrompts = {
    AIProvider.claude: '''You are an AI trained to extract the user's financial intention and classify the asset class.
Respond ONLY in this JSON format: { "asset_class": "[asset class]", "intentions": ["...", "..."], "title": "[title]", "tagline": "[tagline]" }.''',
    
    AIProvider.openai: '''Extract the user's intention from their request.
Return a JSON with: asset_class, intentions array, title, and tagline.''',
    
    AIProvider.gemini: '''Analyze the user prompt and identify their financial intention.
Output JSON format with asset_class, intentions, title, and tagline fields.''',
    
    AIProvider.perplexity: '''Determine the user's financial request intention.
Provide structured JSON response with asset classification and intent analysis.''',
  };
}