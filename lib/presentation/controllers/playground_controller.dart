import 'package:get/get.dart';
import '../../core/utils/storage_helper.dart';

class PlaygroundController extends GetxController {
  // Observable states
  final savedTemplates = <Map<String, dynamic>>[].obs;
  final isAutoRun = true.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadSavedTemplates();
  }
  
  void loadSavedTemplates() {
    final templates = StorageHelper.getList('playground_templates') ?? [];
    savedTemplates.value = List<Map<String, dynamic>>.from(templates);
  }
  
  Future<void> saveTemplate({
    required String title,
    required String html,
    required String css,
    required String js,
  }) async {
    final template = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'html': html,
      'css': css,
      'js': js,
      'createdAt': DateTime.now().toIso8601String(),
    };
    
    savedTemplates.add(template);
    
    // Save to local storage
    await StorageHelper.saveList('playground_templates', savedTemplates);
  }
  
  void deleteTemplate(String id) {
    savedTemplates.removeWhere((t) => t['id'] == id);
    StorageHelper.saveList('playground_templates', savedTemplates);
  }
  
  Map<String, dynamic>? getTemplate(String id) {
    try {
      return savedTemplates.firstWhere((t) => t['id'] == id);
    } catch (e) {
      return null;
    }
  }
  
  void toggleAutoRun() {
    isAutoRun.value = !isAutoRun.value;
  }
}