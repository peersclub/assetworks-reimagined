import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/models/widget_template_model.dart';
import '../../controllers/template_controller.dart';

class WidgetTemplatesScreen extends StatefulWidget {
  const WidgetTemplatesScreen({Key? key}) : super(key: key);
  
  @override
  State<WidgetTemplatesScreen> createState() => _WidgetTemplatesScreenState();
}

class _WidgetTemplatesScreenState extends State<WidgetTemplatesScreen> {
  late TemplateController _controller;
  String _selectedCategory = 'All';
  
  final List<String> _categories = [
    'All',
    'Analytics',
    'Finance',
    'Marketing',
    'Sales',
    'Operations',
    'HR',
    'Custom',
  ];
  
  @override
  void initState() {
    super.initState();
    _controller = Get.put(TemplateController());
    _controller.loadTemplates();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Widget Templates'),
        actions: [
          IconButton(
            onPressed: _showInfo,
            icon: const Icon(LucideIcons.info, size: 22),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    checkmarkColor: AppColors.primary,
                  ),
                );
              },
            ),
          ),
          
          // Templates Grid
          Expanded(
            child: Obx(() {
              if (_controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final templates = _selectedCategory == 'All'
                  ? _controller.templates
                  : _controller.templates.where((t) => t.category == _selectedCategory).toList();
              
              if (templates.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.layout,
                        size: 64,
                        color: isDark ? AppColors.neutral600 : AppColors.neutral400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No templates available',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: templates.length,
                itemBuilder: (context, index) {
                  final template = templates[index];
                  return _buildTemplateCard(template);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTemplateCard(dynamic template) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AppCard(
      onTap: () => _useTemplate(template),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preview Image
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: isDark ? AppColors.neutral900 : AppColors.neutral100,
              borderRadius: BorderRadius.circular(8),
              image: template.previewImage.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(template.previewImage),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: template.previewImage.isEmpty
                ? Center(
                    child: Icon(
                      _getCategoryIcon(template.category),
                      size: 32,
                      color: AppColors.primary.withOpacity(0.5),
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          
          // Title
          Row(
            children: [
              Expanded(
                child: Text(
                  template.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (template.isPremium)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.crown,
                        size: 10,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'PRO',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          
          // Description
          Text(
            template.description,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          
          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Category
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  template.category,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.primary,
                  ),
                ),
              ),
              // Usage Count
              Row(
                children: [
                  Icon(
                    LucideIcons.users,
                    size: 12,
                    color: isDark ? AppColors.neutral600 : AppColors.neutral400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${template.usageCount}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.neutral600 : AppColors.neutral400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Analytics':
        return LucideIcons.barChart3;
      case 'Finance':
        return LucideIcons.dollarSign;
      case 'Marketing':
        return LucideIcons.trendingUp;
      case 'Sales':
        return LucideIcons.shoppingCart;
      case 'Operations':
        return LucideIcons.settings;
      case 'HR':
        return LucideIcons.users;
      default:
        return LucideIcons.layout;
    }
  }
  
  void _useTemplate(dynamic template) {
    // Premium check removed - all templates are available
    
    Get.toNamed('/template-customize', arguments: template);
  }
  
  void _showInfo() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'About Templates',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(LucideIcons.x),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoItem(
                icon: LucideIcons.sparkles,
                title: 'Pre-built Solutions',
                description: 'Ready-to-use widget templates for common business needs',
              ),
              const SizedBox(height: 12),
              _buildInfoItem(
                icon: LucideIcons.edit3,
                title: 'Customizable',
                description: 'Modify templates to match your specific requirements',
              ),
              const SizedBox(height: 12),
              _buildInfoItem(
                icon: LucideIcons.zap,
                title: 'Quick Start',
                description: 'Get started instantly with proven widget designs',
              ),
              const SizedBox(height: 12),
              _buildInfoItem(
                icon: LucideIcons.crown,
                title: 'Premium Templates',
                description: 'Access advanced templates with Pro subscription',
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  void _showPremiumDialog() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(LucideIcons.crown, color: AppColors.warning),
            const SizedBox(width: 8),
            const Text('Premium Template'),
          ],
        ),
        content: const Text(
          'This template requires a Pro subscription. Upgrade to access premium templates and advanced features.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.toNamed('/subscription');
            },
            child: Text(
              'Upgrade to Pro',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}