import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/widget_creation_service.dart';
import '../../services/prompt_management_service.dart';
import '../../data/models/widget_model.dart';
import '../../data/models/prompt_model.dart';

enum CreationMode { prompt, template, custom }

class WidgetStudioController extends GetxController {
  final WidgetCreationService _creationService = Get.put(WidgetCreationService());
  final PromptManagementService _promptService = Get.put(PromptManagementService());
  
  // Controllers
  final TextEditingController promptController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  
  // Observables
  final creationMode = CreationMode.prompt.obs;
  final isGenerating = false.obs;
  final generationStatus = 'Ready to generate'.obs;
  final generatedWidget = Rxn<WidgetModel>();
  final canGenerate = false.obs;
  
  // Enhancement options
  final selectedStyles = <String>[].obs;
  final selectedFeatures = <String>[].obs;
  final selectedTemplate = ''.obs;
  
  // Generation steps for UI feedback
  final currentStep = 0.obs;
  final totalSteps = 4.obs;
  
  @override
  void onInit() {
    super.onInit();
    
    // Listen to prompt changes
    promptController.addListener(_validateGeneration);
    codeController.addListener(_validateGeneration);
    
    // Listen to mode changes
    ever(creationMode, (_) => _validateGeneration());
  }
  
  @override
  void onClose() {
    promptController.dispose();
    codeController.dispose();
    super.onClose();
  }
  
  void setCreationMode(CreationMode mode) {
    creationMode.value = mode;
    _validateGeneration();
  }
  
  void updatePrompt(String value) {
    _validateGeneration();
  }
  
  void toggleStyle(String style) {
    if (selectedStyles.contains(style)) {
      selectedStyles.remove(style);
    } else {
      selectedStyles.add(style);
    }
  }
  
  void toggleFeature(String feature) {
    if (selectedFeatures.contains(feature)) {
      selectedFeatures.remove(feature);
    } else {
      selectedFeatures.add(feature);
    }
  }
  
  void selectTemplate(String templateName) {
    selectedTemplate.value = templateName;
    _validateGeneration();
  }
  
  void _validateGeneration() {
    switch (creationMode.value) {
      case CreationMode.prompt:
        canGenerate.value = promptController.text.trim().length > 10;
        break;
      case CreationMode.template:
        canGenerate.value = selectedTemplate.value.isNotEmpty;
        break;
      case CreationMode.custom:
        canGenerate.value = codeController.text.trim().length > 20;
        break;
    }
  }
  
  Future<void> generateWidget() async {
    if (!canGenerate.value) return;
    
    isGenerating.value = true;
    currentStep.value = 0;
    
    try {
      switch (creationMode.value) {
        case CreationMode.prompt:
          await _generateFromPrompt();
          break;
        case CreationMode.template:
          await _generateFromTemplate();
          break;
        case CreationMode.custom:
          await _generateFromCode();
          break;
      }
    } catch (e) {
      generationStatus.value = 'Generation failed: ${e.toString()}';
      Get.snackbar(
        'Error',
        'Failed to generate widget: ${e.toString()}',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isGenerating.value = false;
    }
  }
  
  Future<void> _generateFromPrompt() async {
    // Step 1: Analyze prompt
    currentStep.value = 1;
    generationStatus.value = 'Analyzing your prompt...';
    await Future.delayed(const Duration(seconds: 1));
    
    // Step 2: Generate intention with selected prompts
    currentStep.value = 2;
    generationStatus.value = 'Understanding requirements...';
    
    // Get formatted prompt with selected system/user prompts
    final formattedPrompt = _promptService.getFormattedPrompt(
      userInput: _buildEnhancedPrompt(),
      theme: {
        'name': 'modern',
        'primary_color': '#007AFF',
        'background_color': '#FFFFFF',
        'text_color': '#000000',
        'font_family': 'SF Pro Display',
      },
    );
    
    // Use the formatted prompt for generation
    final intention = await _creationService.analyzePrompt(formattedPrompt);
    
    // Step 3: Generate widget
    currentStep.value = 3;
    generationStatus.value = 'Creating widget...';
    
    final widget = await _creationService.generateWidget(intention);
    
    // Step 4: Finalize
    currentStep.value = 4;
    generationStatus.value = 'Finalizing...';
    await Future.delayed(const Duration(milliseconds: 500));
    
    generatedWidget.value = widget;
    generationStatus.value = 'Widget generated successfully!';
    
    Get.snackbar(
      'Success',
      'Widget generated successfully!',
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
    );
  }
  
  Future<void> _generateFromTemplate() async {
    currentStep.value = 1;
    generationStatus.value = 'Loading template...';
    await Future.delayed(const Duration(seconds: 1));
    
    currentStep.value = 2;
    generationStatus.value = 'Customizing template...';
    
    final templatePrompt = 'Create a ${selectedTemplate.value} widget with modern design';
    final intention = await _creationService.analyzePrompt(templatePrompt);
    
    currentStep.value = 3;
    generationStatus.value = 'Generating from template...';
    
    final widget = await _creationService.generateWidget(intention);
    
    currentStep.value = 4;
    generationStatus.value = 'Applying customizations...';
    await Future.delayed(const Duration(milliseconds: 500));
    
    generatedWidget.value = widget;
    generationStatus.value = 'Template widget created!';
    
    Get.snackbar(
      'Success',
      'Widget created from template!',
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
    );
  }
  
  Future<void> _generateFromCode() async {
    currentStep.value = 1;
    generationStatus.value = 'Validating code...';
    await Future.delayed(const Duration(seconds: 1));
    
    currentStep.value = 2;
    generationStatus.value = 'Processing custom code...';
    
    // For custom code, we'll create a widget directly
    // In a real implementation, this would validate and compile the code
    final customPrompt = 'Process this custom code: ${codeController.text}';
    final intention = await _creationService.analyzePrompt(customPrompt);
    
    currentStep.value = 3;
    generationStatus.value = 'Building widget...';
    
    final widget = await _creationService.generateWidget(intention);
    
    currentStep.value = 4;
    generationStatus.value = 'Optimizing...';
    await Future.delayed(const Duration(milliseconds: 500));
    
    generatedWidget.value = widget;
    generationStatus.value = 'Custom widget created!';
    
    Get.snackbar(
      'Success',
      'Custom widget created successfully!',
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
    );
  }
  
  String _buildEnhancedPrompt() {
    final buffer = StringBuffer();
    buffer.write(promptController.text);
    
    if (selectedStyles.isNotEmpty) {
      buffer.write(' with ${selectedStyles.join(", ")} style');
    }
    
    if (selectedFeatures.isNotEmpty) {
      buffer.write(' including ${selectedFeatures.join(", ")} features');
    }
    
    return buffer.toString();
  }
  
  void editWidget() {
    if (generatedWidget.value == null) return;
    
    Get.snackbar(
      'Edit Mode',
      'Opening widget editor...',
      backgroundColor: Colors.blue.withOpacity(0.8),
      colorText: Colors.white,
    );
    
    // TODO: Navigate to widget editor with generatedWidget
  }
  
  Future<void> saveWidget() async {
    if (generatedWidget.value == null) return;
    
    try {
      await _creationService.saveWidget(generatedWidget.value!);
      
      Get.snackbar(
        'Saved',
        'Widget saved successfully!',
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save widget',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }
  
  void shareWidget() {
    if (generatedWidget.value == null) return;
    
    Get.snackbar(
      'Share',
      'Sharing widget...',
      backgroundColor: Colors.purple.withOpacity(0.8),
      colorText: Colors.white,
    );
    
    // TODO: Implement sharing functionality
  }
  
  void resetGeneration() {
    generatedWidget.value = null;
    currentStep.value = 0;
    generationStatus.value = 'Ready to generate';
  }
}