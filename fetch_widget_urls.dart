import 'dart:convert';
import 'package:dio/dio.dart';

Future<void> fetchWidgetUrls() async {
  final dio = Dio();
  
  const authToken = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiI2ODI4OTZkOTQ3NzdkM2U3N2EzODhhM2EiLCJrZXkiOiJkMWY2ZjA0Ni02MmI1LTRjIiwiZXhwIjoxNzU5NTk5NTMzfQ.qn8UgAb1TN2TVKOCt96h6rtgRLeyX2Q6qzF0nwkU4CE';
  
  print('=== Fetching Widget URLs ===\n');
  
  // Fetch dashboard widgets
  try {
    print('1. Fetching Dashboard Widgets...');
    final dashboardResponse = await dio.get(
      'https://api.assetworks.ai/api/v1/personalization/dashboard/widgets',
      options: Options(
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
          'X-Requested-Page': '1',
          'X-Requested-Limit': '5',
        },
      ),
    );
    
    if (dashboardResponse.statusCode == 200 && dashboardResponse.data['data'] != null) {
      final widgets = dashboardResponse.data['data'] as List;
      print('Found ${widgets.length} widgets in dashboard\n');
      
      for (var widget in widgets.take(3)) {
        print('Widget: ${widget['title'] ?? 'Untitled'}');
        print('  ID: ${widget['id']}');
        print('  Preview URL: ${widget['preview_version_url'] ?? 'Not available'}');
        print('  Full URL: ${widget['full_version_url'] ?? 'Not available'}');
        print('  Code URL: ${widget['code_url'] ?? 'Not available'}');
        
        // Generate widget URLs based on ID
        final widgetId = widget['id'];
        print('  Generated URLs:');
        print('    - Preview: https://widgets.assetworks.ai/preview/$widgetId');
        print('    - Full: https://widgets.assetworks.ai/full/$widgetId');
        print('    - Share: https://assetworks.ai/widget/$widgetId');
        print('');
      }
    }
  } catch (e) {
    print('Error fetching dashboard widgets: $e\n');
  }
  
  // Fetch user's personal widgets/prompts
  try {
    print('2. Fetching Personal Widget History...');
    final historyResponse = await dio.get(
      'https://api.assetworks.ai/api/v1/personal/prompts',
      options: Options(
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      ),
    );
    
    if (historyResponse.statusCode == 200 && historyResponse.data['data'] != null) {
      final prompts = historyResponse.data['data'] as List;
      print('Found ${prompts.length} prompts in history\n');
      
      for (var prompt in prompts.take(3)) {
        print('Prompt: ${prompt['title'] ?? prompt['original_prompt'] ?? 'Untitled'}');
        print('  ID: ${prompt['id']}');
        
        // Check if widget was created from this prompt
        if (prompt['widget_id'] != null) {
          print('  Widget ID: ${prompt['widget_id']}');
          print('  Widget URLs:');
          print('    - Preview: https://widgets.assetworks.ai/preview/${prompt['widget_id']}');
          print('    - Full: https://widgets.assetworks.ai/full/${prompt['widget_id']}');
        } else {
          print('  No widget generated yet');
        }
        print('');
      }
    }
  } catch (e) {
    print('Error fetching personal history: $e\n');
  }
  
  // Fetch trending widgets
  try {
    print('3. Fetching Trending Widgets...');
    final trendingResponse = await dio.get(
      'https://api.assetworks.ai/api/v1/widgets/trending',
      options: Options(
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      ),
    );
    
    if (trendingResponse.statusCode == 200 && trendingResponse.data['data'] != null) {
      final widgets = trendingResponse.data['data'] as List;
      print('Found ${widgets.length} trending widgets\n');
      
      for (var widget in widgets.take(2)) {
        print('Widget: ${widget['title'] ?? 'Untitled'}');
        print('  ID: ${widget['id']}');
        print('  Author: ${widget['username'] ?? 'Unknown'}');
        print('  Views: ${widget['views_count'] ?? 0}');
        print('  Likes: ${widget['likes_count'] ?? 0}');
        print('  Widget URLs:');
        print('    - Preview: ${widget['preview_version_url'] ?? 'Not available'}');
        print('    - Full: ${widget['full_version_url'] ?? 'Not available'}');
        print('    - Public: https://assetworks.ai/widget/${widget['id']}');
        print('');
      }
    }
  } catch (e) {
    print('Error fetching trending widgets: $e\n');
  }
  
  // Fetch specific widget by ID (if you have one)
  const specificWidgetId = '689dc9e21c826ceb054e4c3f'; // Example ID
  try {
    print('4. Fetching Specific Widget...');
    final widgetResponse = await dio.get(
      'https://api.assetworks.ai/api/v1/widgets/$specificWidgetId',
      options: Options(
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      ),
    );
    
    if (widgetResponse.statusCode == 200 && widgetResponse.data['data'] != null) {
      final widget = widgetResponse.data['data'];
      print('Found widget: ${widget['title']}\n');
      print('  URLs:');
      print('    - Preview: ${widget['preview_version_url'] ?? 'Not available'}');
      print('    - Full: ${widget['full_version_url'] ?? 'Not available'}');
      print('    - Code: ${widget['code_url'] ?? 'Not available'}');
      print('    - Public: https://assetworks.ai/widget/${widget['id']}');
    }
  } catch (e) {
    print('Error fetching specific widget: $e\n');
  }
  
  print('\n=== URL Patterns ===');
  print('Preview: https://widgets.assetworks.ai/preview/{widget_id}');
  print('Full: https://widgets.assetworks.ai/full/{widget_id}');
  print('Code: https://widgets.assetworks.ai/code/{widget_id}');
  print('Public Share: https://assetworks.ai/widget/{widget_id}');
  print('Embed: <iframe src="https://widgets.assetworks.ai/embed/{widget_id}"></iframe>');
}

void main() async {
  await fetchWidgetUrls();
}