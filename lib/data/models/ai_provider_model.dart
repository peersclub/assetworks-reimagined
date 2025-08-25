import 'package:flutter/material.dart';

enum AIProvider {
  claude,
  openai,
  gemini,
  perplexity,
}

extension AIProviderExtension on AIProvider {
  String get name {
    switch (this) {
      case AIProvider.claude:
        return 'Claude';
      case AIProvider.openai:
        return 'OpenAI';
      case AIProvider.gemini:
        return 'Gemini';
      case AIProvider.perplexity:
        return 'Perplexity';
    }
  }

  String get description {
    switch (this) {
      case AIProvider.claude:
        return 'Advanced reasoning and analysis';
      case AIProvider.openai:
        return 'Versatile and creative solutions';
      case AIProvider.gemini:
        return 'Google\'s latest AI technology';
      case AIProvider.perplexity:
        return 'Real-time search and insights';
    }
  }

  String get apiEndpoint {
    switch (this) {
      case AIProvider.claude:
        return '/admin/api/v1/claude';
      case AIProvider.openai:
        return '/admin/api/v1/openai';
      case AIProvider.gemini:
        return '/admin/api/v1/gemini';
      case AIProvider.perplexity:
        return '/admin/api/v1/perplexity';
    }
  }

  IconData get icon {
    switch (this) {
      case AIProvider.claude:
        return Icons.psychology;
      case AIProvider.openai:
        return Icons.smart_toy;
      case AIProvider.gemini:
        return Icons.auto_awesome;
      case AIProvider.perplexity:
        return Icons.search;
    }
  }

  Color get color {
    switch (this) {
      case AIProvider.claude:
        return const Color(0xFF6B4C9A);
      case AIProvider.openai:
        return const Color(0xFF00A67E);
      case AIProvider.gemini:
        return const Color(0xFF4285F4);
      case AIProvider.perplexity:
        return const Color(0xFF1DA1F2);
    }
  }

  List<String> get features {
    switch (this) {
      case AIProvider.claude:
        return [
          'Complex reasoning',
          'Code analysis',
          'Long-form content',
          'Nuanced understanding',
        ];
      case AIProvider.openai:
        return [
          'GPT-4 powered',
          'Image generation',
          'Code completion',
          'Creative writing',
        ];
      case AIProvider.gemini:
        return [
          'Multimodal AI',
          'Fast responses',
          'Google integration',
          'Latest model',
        ];
      case AIProvider.perplexity:
        return [
          'Real-time data',
          'Web search',
          'Citation sources',
          'Current events',
        ];
    }
  }
}

class AIProviderConfig {
  final AIProvider provider;
  final bool isEnabled;
  final bool isPremium;
  final int? creditCost;
  final double? modelVersion;
  final Map<String, dynamic>? additionalSettings;

  AIProviderConfig({
    required this.provider,
    this.isEnabled = true,
    this.isPremium = false,
    this.creditCost,
    this.modelVersion,
    this.additionalSettings,
  });

  factory AIProviderConfig.fromJson(Map<String, dynamic> json) {
    return AIProviderConfig(
      provider: AIProvider.values.firstWhere(
        (e) => e.toString().split('.').last == json['provider'],
        orElse: () => AIProvider.openai,
      ),
      isEnabled: json['isEnabled'] ?? true,
      isPremium: json['isPremium'] ?? false,
      creditCost: json['creditCost'],
      modelVersion: json['modelVersion']?.toDouble(),
      additionalSettings: json['additionalSettings'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider': provider.toString().split('.').last,
      'isEnabled': isEnabled,
      'isPremium': isPremium,
      'creditCost': creditCost,
      'modelVersion': modelVersion,
      'additionalSettings': additionalSettings,
    };
  }
}

class AIProviderResponse {
  final String result;
  final AIProvider provider;
  final String? requestId;
  final int? tokensUsed;
  final int? creditsUsed;
  final Duration? processingTime;
  final Map<String, dynamic>? metadata;

  AIProviderResponse({
    required this.result,
    required this.provider,
    this.requestId,
    this.tokensUsed,
    this.creditsUsed,
    this.processingTime,
    this.metadata,
  });

  factory AIProviderResponse.fromJson(Map<String, dynamic> json) {
    return AIProviderResponse(
      result: json['result'] ?? '',
      provider: AIProvider.values.firstWhere(
        (e) => e.toString().split('.').last == json['provider'],
        orElse: () => AIProvider.openai,
      ),
      requestId: json['requestId'],
      tokensUsed: json['tokensUsed'],
      creditsUsed: json['creditsUsed'],
      processingTime: json['processingTime'] != null
          ? Duration(milliseconds: json['processingTime'])
          : null,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'result': result,
      'provider': provider.toString().split('.').last,
      'requestId': requestId,
      'tokensUsed': tokensUsed,
      'creditsUsed': creditsUsed,
      'processingTime': processingTime?.inMilliseconds,
      'metadata': metadata,
    };
  }
}