import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../presentation/controllers/widget_studio_controller.dart';
import '../widgets/ios_glass_card.dart';
import '../services/prompt_management_service.dart';
import '../data/models/prompt_model.dart';
import 'prompt_management_screen.dart';

class WidgetStudioScreen extends StatelessWidget {
  const WidgetStudioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WidgetStudioController());
    final promptService = Get.find<PromptManagementService>();
    
    return Scaffold(
      backgroundColor: CupertinoColors.black,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: Colors.black.withOpacity(0.8),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Widget Studio',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.purple.withOpacity(0.3),
                      Colors.blue.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(CupertinoIcons.back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            actions: [
              IconButton(
                icon: const Icon(CupertinoIcons.doc_text, color: Colors.white),
                onPressed: () => Get.to(() => PromptManagementScreen()),
                tooltip: 'Manage Prompts',
              ),
              IconButton(
                icon: const Icon(Icons.help_outline, color: Colors.white),
                onPressed: () => _showHelp(context),
              ),
            ],
          ),
          
          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Creation Mode Selector
                _buildCreationModeSelector(controller),
                const SizedBox(height: 24),
                
                // Dynamic Content Based on Mode
                Obx(() {
                  switch (controller.creationMode.value) {
                    case CreationMode.prompt:
                      return _buildPromptMode(controller);
                    case CreationMode.template:
                      return _buildTemplateMode(controller);
                    case CreationMode.custom:
                      return _buildCustomMode(controller);
                  }
                }),
              ]),
            ),
          ),
        ],
      ),
      
      // Floating Action Button
      floatingActionButton: Obx(() {
        if (controller.canGenerate.value) {
          return FloatingActionButton.extended(
            onPressed: controller.generateWidget,
            backgroundColor: Colors.purple,
            label: const Text('Generate Widget'),
            icon: const Icon(Icons.auto_awesome),
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }
  
  Widget _buildCreationModeSelector(WidgetStudioController controller) {
    return Container(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildModeCard(
            controller,
            CreationMode.prompt,
            'AI Prompt',
            LucideIcons.sparkles,
            'Describe your widget in natural language',
            Colors.purple,
          ),
          const SizedBox(width: 12),
          _buildModeCard(
            controller,
            CreationMode.template,
            'Templates',
            LucideIcons.layout,
            'Start from pre-built templates',
            Colors.blue,
          ),
          const SizedBox(width: 12),
          _buildModeCard(
            controller,
            CreationMode.custom,
            'Custom',
            LucideIcons.code,
            'Build from scratch with code',
            Colors.green,
          ),
        ],
      ),
    );
  }
  
  Widget _buildModeCard(
    WidgetStudioController controller,
    CreationMode mode,
    String title,
    IconData icon,
    String description,
    Color color,
  ) {
    return Obx(() {
      final isSelected = controller.creationMode.value == mode;
      
      return GestureDetector(
        onTap: () => controller.setCreationMode(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 160,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? color : Colors.white.withOpacity(0.1),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
  
  Widget _buildPromptMode(WidgetStudioController controller) {
    final promptService = Get.find<PromptManagementService>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Prompt Selection Card
        IOSGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(CupertinoIcons.doc_text_viewfinder, color: Colors.cyan, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Prompt Configuration',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  CupertinoButton(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    color: Colors.cyan.withOpacity(0.2),
                    child: Text(
                      'Manage',
                      style: TextStyle(fontSize: 14, color: Colors.cyan),
                    ),
                    onPressed: () => Get.to(() => PromptManagementScreen()),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // System Prompt Selector
              Obx(() {
                final systemPrompts = promptService.systemPrompts;
                final selectedSystem = promptService.selectedSystemPrompt.value;
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'System Prompt',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: DropdownButton<String>(
                        value: selectedSystem?.id,
                        hint: Text('Select system prompt', style: TextStyle(color: Colors.white60)),
                        dropdownColor: Colors.grey[900],
                        isExpanded: true,
                        underline: SizedBox(),
                        style: TextStyle(color: Colors.white),
                        items: systemPrompts.map((prompt) => DropdownMenuItem(
                          value: prompt.id,
                          child: Row(
                            children: [
                              Icon(
                                _getProviderIcon(prompt.provider),
                                size: 16,
                                color: _getProviderColor(prompt.provider),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  prompt.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (prompt.isDefault) 
                                Container(
                                  margin: EdgeInsets.only(left: 8),
                                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text('DEFAULT', style: TextStyle(fontSize: 10)),
                                ),
                            ],
                          ),
                        )).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            promptService.selectedSystemPrompt.value = 
                              systemPrompts.firstWhere((p) => p.id == value);
                          }
                        },
                      ),
                    ),
                  ],
                );
              }),
              
              const SizedBox(height: 16),
              
              // User Prompt Selector (Optional)
              Obx(() {
                final userPrompts = promptService.userPrompts;
                final selectedUser = promptService.selectedUserPrompt.value;
                
                if (userPrompts.isEmpty) {
                  return SizedBox();
                }
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Prompt Template (Optional)',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: DropdownButton<String?>(
                        value: selectedUser?.id,
                        hint: Text('None selected', style: TextStyle(color: Colors.white60)),
                        dropdownColor: Colors.grey[900],
                        isExpanded: true,
                        underline: SizedBox(),
                        style: TextStyle(color: Colors.white),
                        items: [
                          DropdownMenuItem(
                            value: null,
                            child: Text('None'),
                          ),
                          ...userPrompts.map((prompt) => DropdownMenuItem(
                            value: prompt.id,
                            child: Text(prompt.name),
                          )),
                        ],
                        onChanged: (value) {
                          promptService.selectedUserPrompt.value = 
                            value != null ? userPrompts.firstWhere((p) => p.id == value) : null;
                        },
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Prompt Input
        IOSGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.messageSquare, color: Colors.purple, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Describe Your Widget',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.promptController,
                maxLines: 5,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Example: Create a stock ticker widget that shows real-time prices for AAPL with a clean, minimal design',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.purple),
                  ),
                ),
                onChanged: (value) => controller.updatePrompt(value),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Enhancement Options
        IOSGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.sliders, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Enhancement Options',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Style Options
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildChip('Minimal', controller.toggleStyle),
                  _buildChip('Modern', controller.toggleStyle),
                  _buildChip('iOS Native', controller.toggleStyle),
                  _buildChip('Material', controller.toggleStyle),
                  _buildChip('Glassmorphism', controller.toggleStyle),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Features
              Text(
                'Features',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildChip('Real-time Data', controller.toggleFeature),
                  _buildChip('Interactive', controller.toggleFeature),
                  _buildChip('Dark Mode', controller.toggleFeature),
                  _buildChip('Animations', controller.toggleFeature),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Preview Area (if generating)
        Obx(() {
          if (controller.isGenerating.value) {
            return IOSGlassCard(
              child: Column(
                children: [
                  const CircularProgressIndicator(color: Colors.purple),
                  const SizedBox(height: 16),
                  Text(
                    controller.generationStatus.value,
                    style: TextStyle(color: Colors.white.withOpacity(0.8)),
                  ),
                ],
              ),
            );
          }
          
          if (controller.generatedWidget.value != null) {
            return _buildPreviewCard(controller);
          }
          
          return const SizedBox.shrink();
        }),
      ],
    );
  }
  
  Widget _buildTemplateMode(WidgetStudioController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IOSGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.layout, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Choose a Template',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Template Categories
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildCategoryChip('Finance', true),
                    const SizedBox(width: 8),
                    _buildCategoryChip('Health', false),
                    const SizedBox(width: 8),
                    _buildCategoryChip('Productivity', false),
                    const SizedBox(width: 8),
                    _buildCategoryChip('Social', false),
                    const SizedBox(width: 8),
                    _buildCategoryChip('Analytics', false),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Template Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return _buildTemplateCard(controller, index);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildCustomMode(WidgetStudioController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IOSGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.code, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Custom Widget Code',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Code Editor Placeholder
              Container(
                height: 400,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: TextField(
                  controller: controller.codeController,
                  maxLines: null,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'monospace',
                    fontSize: 14,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '// Enter your widget code here...',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildChip(String label, Function(String) onTap) {
    return GestureDetector(
      onTap: () => onTap(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }
  
  Widget _buildCategoryChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.withOpacity(0.3) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.white.withOpacity(0.2),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.blue : Colors.white.withOpacity(0.8),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
  
  Widget _buildTemplateCard(WidgetStudioController controller, int index) {
    final templates = [
      {'name': 'Stock Ticker', 'icon': LucideIcons.trendingUp},
      {'name': 'Portfolio', 'icon': LucideIcons.pieChart},
      {'name': 'Crypto Price', 'icon': LucideIcons.bitcoin},
      {'name': 'Budget Tracker', 'icon': LucideIcons.wallet},
      {'name': 'Exchange Rates', 'icon': LucideIcons.dollarSign},
      {'name': 'Investment Goal', 'icon': LucideIcons.target},
    ];
    
    final template = templates[index];
    
    return GestureDetector(
      onTap: () => controller.selectTemplate(template['name'] as String),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              template['icon'] as IconData,
              color: Colors.white.withOpacity(0.8),
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              template['name'] as String,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPreviewCard(WidgetStudioController controller) {
    return IOSGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.eye, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Widget Preview',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(LucideIcons.edit, color: Colors.white.withOpacity(0.6)),
                    onPressed: controller.editWidget,
                  ),
                  IconButton(
                    icon: Icon(LucideIcons.save, color: Colors.white.withOpacity(0.6)),
                    onPressed: controller.saveWidget,
                  ),
                  IconButton(
                    icon: Icon(LucideIcons.share2, color: Colors.white.withOpacity(0.6)),
                    onPressed: controller.shareWidget,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Preview Container
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Center(
              child: Text(
                'Widget Preview Here',
                style: TextStyle(color: Colors.white.withOpacity(0.5)),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Widget Studio Help',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Widget Studio allows you to create custom widgets in three ways:\n\n'
          '1. AI Prompt: Describe what you want in natural language\n'
          '2. Templates: Start from pre-built templates\n'
          '3. Custom: Write your own widget code\n\n'
          'All widgets are powered by our AI backend for intelligent generation.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it', style: TextStyle(color: Colors.purple)),
          ),
        ],
      ),
    );
  }
  
  Color _getProviderColor(AIProvider provider) {
    switch (provider) {
      case AIProvider.claude:
        return Color(0xFF6B4C9A);
      case AIProvider.openai:
        return Color(0xFF10A37F);
      case AIProvider.gemini:
        return Color(0xFF4285F4);
      case AIProvider.perplexity:
        return Color(0xFF00D4FF);
    }
  }
  
  IconData _getProviderIcon(AIProvider provider) {
    switch (provider) {
      case AIProvider.claude:
        return CupertinoIcons.chat_bubble_2;
      case AIProvider.openai:
        return CupertinoIcons.sparkles;
      case AIProvider.gemini:
        return CupertinoIcons.star_circle;
      case AIProvider.perplexity:
        return CupertinoIcons.search_circle;
    }
  }
}