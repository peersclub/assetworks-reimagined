import 'dart:convert';
import 'package:dio/dio.dart';

Future<void> testWidgetCreation() async {
  final dio = Dio();
  
  const apiUrl = 'https://api.assetworks.ai/api/v1/prompts/result';
  const authToken = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiI2ODI4OTZkOTQ3NzdkM2U3N2EzODhhM2EiLCJrZXkiOiJkMWY2ZjA0Ni02MmI1LTRjIiwiZXhwIjoxNzU5NTk5NTMzfQ.qn8UgAb1TN2TVKOCt96h6rtgRLeyX2Q6qzF0nwkU4CE';
  
  final requestData = {
    'prompt': 'Alt season analysis 2025',
    'user_session_id': null,
    'ai_provider': 'claude',
  };
  
  print('Creating widget with prompt: Alt season analysis 2025');
  print('Request URL: $apiUrl');
  print('Request Data: ${jsonEncode(requestData)}');
  
  try {
    final response = await dio.post(
      apiUrl,
      data: requestData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ),
    );
    
    print('Response Status: ${response.statusCode}');
    print('Response Data: ${jsonEncode(response.data)}');
    
    if (response.statusCode == 200 && response.data['data'] != null) {
      print('✅ Widget created successfully!');
      print('Widget ID: ${response.data['data']['id']}');
      print('Widget Title: ${response.data['data']['title']}');
    }
  } catch (e) {
    print('❌ Error creating widget: $e');
    print('Using mock widget fallback...');
    
    // Mock widget response
    final mockWidget = {
      'success': true,
      'widget': {
        'id': 'mock_${DateTime.now().millisecondsSinceEpoch}',
        'title': 'Alt Season Analysis 2025',
        'description': 'Comprehensive analysis of altcoin market trends and opportunities for 2025',
        'code': '''
<div style="padding: 20px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border-radius: 12px; color: white;">
  <h2>Alt Season Analysis 2025</h2>
  <div style="margin: 20px 0;">
    <h3>Market Overview</h3>
    <p>Analyzing altcoin performance indicators for potential alt season in 2025.</p>
  </div>
  <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px; margin: 20px 0;">
    <div style="padding: 15px; background: rgba(255,255,255,0.1); border-radius: 8px;">
      <strong>Bitcoin Dominance</strong>
      <div style="font-size: 24px; margin-top: 10px;">42.3%</div>
      <small>↓ Decreasing trend</small>
    </div>
    <div style="padding: 15px; background: rgba(255,255,255,0.1); border-radius: 8px;">
      <strong>Alt Market Cap</strong>
      <div style="font-size: 24px; margin-top: 10px;">\$1.2T</div>
      <small>↑ Growing momentum</small>
    </div>
  </div>
  <div style="margin-top: 20px;">
    <h3>Top Performing Sectors</h3>
    <ul>
      <li>AI & Machine Learning tokens: +245%</li>
      <li>Layer 2 Solutions: +189%</li>
      <li>DeFi Protocols: +156%</li>
      <li>Gaming & Metaverse: +134%</li>
    </ul>
  </div>
  <div style="margin-top: 20px; padding: 15px; background: rgba(255,255,255,0.1); border-radius: 8px;">
    <strong>Alt Season Indicators:</strong>
    <div style="margin-top: 10px;">
      • 75% of top 50 alts outperforming BTC ✅<br>
      • Increased retail interest ✅<br>
      • Rising social sentiment ✅<br>
      • Technical breakouts on major alts ✅
    </div>
  </div>
</div>
        ''',
        'category': 'Crypto',
        'tags': ['altcoins', 'crypto', 'analysis', '2025'],
        'created_at': DateTime.now().toIso8601String(),
      }
    };
    
    print('✅ Mock widget generated');
    print('Mock Widget: ${jsonEncode(mockWidget)}');
  }
}

void main() async {
  await testWidgetCreation();
}